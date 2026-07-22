#!/usr/bin/env Rscript
# bootstrap_vsp.R — Virtual-species parametric bootstrap (Stage A)
# Fits the selected model from a method directory, generates B virtual
# presence/absence datasets with xsdm::vsp over the same M_buffer, refits the
# same model, and records the parameter distributions.

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(terra)
})

# ─── CLI parsing ─────────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

method_dir    <- parse_arg("--method_dir")
B             <- as.integer(parse_arg("--B", "10"))
num_starts    <- as.integer(parse_arg("--num_starts", "50"))
num_threads   <- as.integer(parse_arg("--num_threads", "4"))
bioclim_dir   <- parse_arg("--bioclim_dir", Sys.getenv("BIOCLIM_DIR", "/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim"))
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
output_dir    <- parse_arg("--output_dir", method_dir)

if (is.null(method_dir)) stop("--method_dir required", call. = FALSE)

years <- as.integer(strsplit(years_str, ",")[[1]])

# ─── Constants ───────────────────────────────────────────────────────────────
KELVIN_OFFSET <- 273.15
TEMP_BIO_CODES <- c("bio01", "bio05", "bio06", "bio08", "bio09", "bio10", "bio11")

resolve_bioclim_code <- function(var_name) {
  mapping <- c(T1 = "bio01", T2 = "bio10", T3 = "bio11",
               P1 = "bio12", P2 = "bio16", P3 = "bio17")
  if (var_name %in% names(mapping)) return(unname(mapping[[var_name]]))
  if (grepl("^bio[0-9]{2}$", var_name)) return(var_name)
  stop("Unsupported model variable: ", var_name, call. = FALSE)
}

# ─── Helper: build scaled env list (same as compute_tss_v7.R) ─────────────────
build_env_list <- function(vars, scale_factors, bioclim_dir, years, polygon_vect) {
  env_list <- vector("list", length(vars))
  names(env_list) <- vars

  for (var in vars) {
    bio_code <- resolve_bioclim_code(var)
    scale <- suppressWarnings(as.numeric(scale_factors[[var]]))
    if (length(scale) == 0 || is.na(scale) || scale == 0) {
      stop("Missing or invalid scale factor for variable: ", var, call. = FALSE)
    }

    paths <- file.path(bioclim_dir, as.character(years),
                       paste0(bio_code, "_", years, ".tif"))
    missing <- paths[!file.exists(paths)]
    if (length(missing) > 0) {
      stop("Missing bioclim files for ", var, " (", bio_code, "): ",
           paste(missing, collapse = ", "), call. = FALSE)
    }

    r <- terra::rast(paths)
    terra::crs(polygon_vect) <- terra::crs(r)
    r <- terra::crop(r, polygon_vect)
    r <- terra::mask(r, polygon_vect)
    if (bio_code %in% TEMP_BIO_CODES) {
      r <- r - KELVIN_OFFSET
    }
    r <- r / scale
    names(r) <- as.character(years)
    env_list[[var]] <- r
  }
  env_list
}

# ─── Helper: extract env array at lon/lat from env_list ───────────────────────
build_env_array <- function(occ_df, env_list, vars, years) {
  n <- nrow(occ_df)
  p <- length(vars)
  n_time <- length(years)
  pts <- cbind(occ_df$lon, occ_df$lat)
  arr <- array(NA_real_, dim = c(n, n_time, p),
               dimnames = list(NULL, as.character(years), vars))
  for (vi in seq_along(vars)) {
    v <- vars[vi]
    r <- env_list[[v]]
    vals <- terra::extract(r, pts, df = TRUE)
    vals <- vals[, -1, drop = FALSE]  # remove ID column
    if (ncol(vals) != n_time) {
      stop("Extracted variable ", v, " has ", ncol(vals), " columns, expected ", n_time)
    }
    arr[, , vi] <- as.matrix(vals)
  }
  arr
}

# ─── Load selected model ──────────────────────────────────────────────────────
sp_dir      <- file.path(method_dir, "Acris_blanchardi")
models_dir  <- file.path(sp_dir, "models")
model_files <- list.files(models_dir, pattern = "\\.rds$", full.names = TRUE)
if (length(model_files) == 0) stop("No model RDS found in ", models_dir, call. = FALSE)

# Prefer the model reported as final by the model-selection report
report_md <- file.path(sp_dir, "model_selection_report.md")
model_name <- NULL
if (file.exists(report_md)) {
  lines <- readLines(report_md, warn = FALSE)
  final_line <- grep("^- \\*\\*Final model:\\*\\*", lines, value = TRUE)
  if (length(final_line) > 0) {
    m <- regexpr("`([^`]+)`", final_line[1], perl = TRUE)
    if (m[1] != -1) {
      model_name <- substring(final_line[1], attr(m, "capture.start"), attr(m, "capture.start") + attr(m, "capture.length") - 1)
    }
  }
}

if (!is.null(model_name)) {
  model_rds <- file.path(models_dir, paste0(model_name, ".rds"))
  if (file.exists(model_rds)) {
    fit <- tryCatch(readRDS(model_rds), error = function(e) NULL)
  }
}

if (is.null(model_name) || is.null(fit) || is.null(fit$status) || fit$status != "success") {
  # Fallback: first successful model with finite pBIC
  fit <- NULL
  for (i in seq_along(model_files)) {
    tmp <- tryCatch(readRDS(model_files[i]), error = function(e) NULL)
    if (!is.null(tmp) && !is.null(tmp$status) && tmp$status == "success" &&
        !is.null(tmp$pBIC) && is.finite(tmp$pBIC)) {
      if (is.null(fit) || isTRUE(tmp$pBIC < fit$pBIC)) {
        fit <- tmp
      }
    }
  }
}

if (is.null(fit)) stop("No successful model found in ", models_dir, call. = FALSE)

model_name <- fit$model_name
message("Bootstrap using model: ", model_name)

p <- fit$p
vars <- fit$vars
mask <- fit$mask
scale_factors <- fit$scale_factors

param_list <- tryCatch(
  xsdm::math_to_bio(fit$best_par),
  error = function(e) stop("math_to_bio failed: ", e$message, call. = FALSE)
)

# ─── Load original occurrence to get counts and polygon ──────────────────────
occ_csv <- file.path(sp_dir, "occ_v7.csv")
if (!file.exists(occ_csv)) stop("occ_v7.csv not found: ", occ_csv, call. = FALSE)
occ_orig <- read.csv(occ_csv, stringsAsFactors = FALSE)
if (!("presence" %in% names(occ_orig))) {
  names(occ_orig)[names(occ_orig) == "occ"] <- "presence"
}
n_pres <- sum(occ_orig$presence == 1)
n_abs  <- sum(occ_orig$presence == 0)
message(sprintf("Original data: %d presences, %d pseudo-absences", n_pres, n_abs))

m_buffer_shp <- file.path(sp_dir, "gis", "M_buffer.shp")
if (!file.exists(m_buffer_shp)) stop("M_buffer.shp not found: ", m_buffer_shp, call. = FALSE)
polygon_vect <- terra::vect(m_buffer_shp)

# ─── Build scaled env list over M_buffer ─────────────────────────────────────
message("Building env list for variables: ", paste(vars, collapse = ", "))
env_list <- build_env_list(vars, scale_factors, bioclim_dir, years, polygon_vect)

# ─── Bootstrap loop ──────────────────────────────────────────────────────────
param_names <- names(fit$best_par)
bio_names <- c("mu", "sigltil", "sigrtil", "ctil", "pd")

param_mat <- matrix(NA_real_, nrow = B, ncol = length(param_names),
                    dimnames = list(NULL, param_names))
loglik_vec <- numeric(B)
pbic_vec   <- numeric(B)
status_vec <- character(B)

for (b in seq_len(B)) {
  message("Bootstrap iteration ", b, "/", B)

  # Generate virtual species from the fitted model over M_buffer
  vsp_df <- tryCatch(
    xsdm::vsp(
      param_list    = param_list,
      env_data      = env_list,
      size_presence = n_pres,
      size_absence  = n_abs,
      threshold     = 0.5
    ),
    error = function(e) {
      warning("vsp failed: ", e$message)
      return(NULL)
    }
  )

  if (is.null(vsp_df) || nrow(vsp_df) == 0) {
    status_vec[b] <- "vsp_failed"
    next
  }

  # Build env array at the virtual coordinates
  env_arr <- tryCatch(
    build_env_array(vsp_df, env_list, vars, years),
    error = function(e) {
      warning("build_env_array failed: ", e$message)
      return(NULL)
    }
  )

  if (is.null(env_arr)) {
    status_vec[b] <- "extract_failed"
    next
  }

  # Drop rows with any NA
  good <- apply(env_arr, 1, function(x) !any(is.na(x)))
  if (sum(good) < 3) {
    status_vec[b] <- "too_few_good"
    next
  }
  env_arr <- env_arr[good, , , drop = FALSE]
  occ_b <- as.integer(vsp_df$presence[good])

  # Refit
  fit_b <- tryCatch(
    xsdm::optimize_likelihood(
      env_dat     = env_arr,
      occ         = occ_b,
      mask        = mask,
      num_starts  = num_starts,
      parallel    = FALSE,
      num_threads = num_threads,
      verbose     = FALSE
    ),
    error = function(e) {
      warning("optimize_likelihood failed: ", e$message)
      NULL
    }
  )

  if (is.null(fit_b) || is.null(fit_b$best$par)) {
    status_vec[b] <- "fit_failed"
    next
  }

  param_mat[b, names(fit_b$best$par)] <- as.vector(fit_b$best$par)
  loglik_vec[b] <- fit_b$best$loglik
  n_free <- if (is.null(mask)) num_par(p) else num_par(p) - length(mask)
  pbic_vec[b] <- -2 * fit_b$best$loglik + n_free * log(sum(good))
  status_vec[b] <- "success"
}

# ─── Save parameter trace ─────────────────────────────────────────────────────
out_df <- as.data.frame(param_mat)
out_df$iteration <- seq_len(B)
out_df$status <- status_vec
out_df$loglik <- loglik_vec
out_df$pBIC <- pbic_vec

# Reorder columns
out_df <- out_df[, c("iteration", "status", "loglik", "pBIC", param_names), drop = FALSE]

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
params_file <- file.path(output_dir, "boostra_params_vsp.csv")
write.csv(out_df, params_file, row.names = FALSE)
message("Wrote ", params_file)

# ─── Compute bootstrap CIs and compare to original estimate ───────────────────
ci_df <- data.frame(
  parameter = param_names,
  original = as.vector(fit$best_par),
  stringsAsFactors = FALSE
)
ci_df$ci_lower <- apply(param_mat, 2, function(x) quantile(x, probs = 0.025, na.rm = TRUE))
ci_df$ci_upper <- apply(param_mat, 2, function(x) quantile(x, probs = 0.975, na.rm = TRUE))
ci_df$ci_median <- apply(param_mat, 2, median, na.rm = TRUE)
ci_df$inside_95 <- (ci_df$original >= ci_df$ci_lower) & (ci_df$original <= ci_df$ci_upper)
ci_df$n_success <- sum(status_vec == "success")

ci_file <- file.path(output_dir, "boostra_CI_vsp.csv")
write.csv(ci_df, ci_file, row.names = FALSE)
message("Wrote ", ci_file)

message("\nBootstrap summary:")
message("  Success: ", sum(status_vec == "success"), "/", B)
print(ci_df)

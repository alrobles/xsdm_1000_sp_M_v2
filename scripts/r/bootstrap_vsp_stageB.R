#!/usr/bin/env Rscript
# bootstrap_vsp_stageB.R — Virtual-species parametric bootstrap Stage B
# Simulates virtual presences from the fitted model, then RE-SAMPLES pseudo-
# absences with the same spatial design used by the original method, refits the
# same final model, and records the parameter distribution.

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
start_iter    <- as.integer(parse_arg("--start_iter", "1"))
num_starts    <- as.integer(parse_arg("--num_starts", "50"))
num_threads   <- as.integer(parse_arg("--num_threads", "4"))
bioclim_dir   <- parse_arg("--bioclim_dir",
                            Sys.getenv("BIOCLIM_DIR",
                                       "/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim"))
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
output_dir    <- parse_arg("--output_dir", method_dir)

# Pseudo-absence design to replicate (taken from original prepare run)
pa_method     <- tolower(parse_arg("--pa_method"))
pa_factor     <- as.numeric(parse_arg("--pa_factor", "1"))
pa_in_buffer  <- tolower(parse_arg("--pa_in_buffer", "false"))
pa_exp_scale  <- as.numeric(parse_arg("--pa_exp_scale", "3"))

if (is.null(method_dir)) stop("--method_dir required", call. = FALSE)
if (is.null(pa_method))  stop("--pa_method required", call. = FALSE)
if (!pa_in_buffer %in% c("true", "false")) stop("--pa_in_buffer must be 'true' or 'false'", call. = FALSE)
pa_in_buffer <- (pa_in_buffer == "true")

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

# ─── Load final model ────────────────────────────────────────────────────────
sp_dir      <- file.path(method_dir, "Acris_blanchardi")
models_dir  <- file.path(sp_dir, "models")
report_md   <- file.path(sp_dir, "model_selection_report.md")

model_name <- NULL
if (file.exists(report_md)) {
  lines <- readLines(report_md, warn = FALSE)
  final_line <- grep("^- \\*\\*Final model:\\*\\*", lines, value = TRUE)
  if (length(final_line) > 0) {
    m <- regexpr("`([^`]+)`", final_line[1], perl = TRUE)
    if (m[1] != -1) {
      model_name <- substring(final_line[1], attr(m, "capture.start"),
                              attr(m, "capture.start") + attr(m, "capture.length") - 1)
    }
  }
}

model_files <- list.files(models_dir, pattern = "\\.rds$", full.names = TRUE)
if (is.null(model_name)) {
  # fallback: first successful model with finite pBIC
  fit <- NULL
  for (f in model_files) {
    tmp <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.null(tmp) && !is.null(tmp$status) && tmp$status == "success" &&
        !is.null(tmp$pBIC) && is.finite(tmp$pBIC)) {
      if (is.null(fit) || isTRUE(tmp$pBIC < fit$pBIC)) fit <- tmp
    }
  }
} else {
  fit <- tryCatch(readRDS(file.path(models_dir, paste0(model_name, ".rds"))),
                  error = function(e) NULL)
}
if (is.null(fit) || is.null(fit$best_par)) stop("No usable final model found", call. = FALSE)
model_name <- fit$model_name
vars <- fit$vars
mask <- fit$mask
scale_factors <- fit$scale_factors
param_list <- xsdm::math_to_bio(fit$best_par)

message("Stage B bootstrap for method_dir: ", method_dir)
message("Final model: ", model_name)
message("Variables: ", paste(vars, collapse = ", "))
message("PA design: ", pa_method, " | pa_factor=", pa_factor,
        " | pa_in_buffer=", pa_in_buffer)

# ─── Determine sample sizes and masks ────────────────────────────────────────
occ_csv <- file.path(sp_dir, "occ_v7.csv")
if (!file.exists(occ_csv)) stop("occ_v7.csv not found: ", occ_csv, call. = FALSE)
occ_orig <- read.csv(occ_csv, stringsAsFactors = FALSE)
if (!("presence" %in% names(occ_orig))) names(occ_orig)[names(occ_orig) == "occ"] <- "presence"
n_pres <- sum(occ_orig$presence == 1)
n_abs  <- sum(occ_orig$presence == 0)
message(sprintf("Original sample: %d presences, %d pseudo-absences", n_pres, n_abs))

m_shp       <- file.path(sp_dir, "gis", "M.shp")
m_buffer_shp <- file.path(sp_dir, "gis", "M_buffer.shp")
if (!file.exists(m_shp))        stop("M.shp not found: ", m_shp, call. = FALSE)
if (!file.exists(m_buffer_shp)) stop("M_buffer.shp not found: ", m_buffer_shp, call. = FALSE)

M <- terra::vect(m_shp)
M_buffer <- terra::vect(m_buffer_shp)

# ─── Build env_list once over M for virtual presence sampling ───────────────
env_list_M <- build_env_list(vars, scale_factors, bioclim_dir, years, M)

# ─── Paths to helper scripts ─────────────────────────────────────────────────
repo_root <- Sys.getenv("REPO_ROOT", "/home/a474r867/work/xsdm_1000_sp_M_v2")
prepare_script  <- file.path(repo_root, "scripts", "r", "prepare_inputs_v8.R")
fit_script      <- file.path(repo_root, "scripts", "r", "orchestrator", "fit_single_model_v7.R")
if (!file.exists(prepare_script)) stop("prepare_inputs_v8.R not found: ", prepare_script, call. = FALSE)
if (!file.exists(fit_script))     stop("fit_single_model_v7.R not found: ", fit_script, call. = FALSE)

# ─── Bootstrap loop ───────────────────────────────────────────────────────────
param_names <- names(fit$best_par)
param_mat <- matrix(NA_real_, nrow = B, ncol = length(param_names),
                    dimnames = list(NULL, param_names))
loglik_vec <- numeric(B)
pbic_vec   <- numeric(B)
n_pres_vec <- integer(B)
n_abs_vec  <- integer(B)
status_vec <- character(B)

vars_str <- paste(vars, collapse = ",")
mask_str <- if (is.null(mask)) "" else paste(paste(names(mask), mask, sep = "="), collapse = ",")

for (b in seq_len(B)) {
  message("\n=== Bootstrap iteration ", b, "/", B, " ===")
  iter_dir <- file.path(output_dir, sprintf("iter_%03d", b))
  prepare_out <- file.path(iter_dir, "prepared")
  dir.create(prepare_out, recursive = TRUE, showWarnings = FALSE)

  # 1. Generate virtual presences from the fitted model over M
  vsp_df <- tryCatch({
    df <- xsdm::vsp(
      param_list    = param_list,
      env_data      = env_list_M,
      size_presence = n_pres,
      size_absence  = 1L,    # vsp requires positive count; we discard the absence
      threshold     = 0.5
    )
    # Keep only the presence pool and force the label to 1 (observed presence)
    df <- df[df$presence == 1, , drop = FALSE]
    if (nrow(df) == 0) stop("No virtual presences generated")
    df$presence <- 1L
    df[, c("lon", "lat", "presence"), drop = FALSE]
  }, error = function(e) {
    warning("vsp failed: ", e$message)
    return(NULL)
  })

  if (is.null(vsp_df) || nrow(vsp_df) < 3) {
    status_vec[b] <- "vsp_failed"
    next
  }
  if (nrow(vsp_df) > n_pres) vsp_df <- vsp_df[seq_len(n_pres), , drop = FALSE]

  sim_occ_csv <- file.path(iter_dir, "sim_occ.csv")
  write.csv(vsp_df, sim_occ_csv, row.names = FALSE)

  # 2. Re-apply the original pseudo-absence sampling design
  prepare_cmd <- c(
    "--vanilla", "--no-save", "--no-restore",
    prepare_script,
    "--species", "Acris_blanchardi",
    "--occ_csv", sim_occ_csv,
    "--m_shp", m_shp,
    "--m_buffer_shp", m_buffer_shp,
    "--bioclim_dir", bioclim_dir,
    "--output_dir", prepare_out,
    "--years", years_str,
    "--pa_method", pa_method,
    "--pa_factor", as.character(pa_factor),
    "--pa_in_buffer", ifelse(pa_in_buffer, "true", "false"),
    "--pa_exp_scale", as.character(pa_exp_scale),
    "--land_mask_mode", "first_year"
  )

  prep_ok <- system2("Rscript", prepare_cmd,
                     stdout = file.path(iter_dir, "prepare.out"),
                     stderr = file.path(iter_dir, "prepare.err")) == 0
  if (!prep_ok) {
    status_vec[b] <- "prepare_failed"
    next
  }

  prepared_occ <- file.path(prepare_out, "Acris_blanchardi", "occ_v7.csv")
  if (!file.exists(prepared_occ)) {
    status_vec[b] <- "prepare_no_occ"
    next
  }
  occ_b <- read.csv(prepared_occ, stringsAsFactors = FALSE)
  n_pres_vec[b] <- sum(occ_b$presence == 1)
  n_abs_vec[b]  <- sum(occ_b$presence == 0)

  # 3. Refit the same final model to the new presences + pseudo-absences
  fit_cmd <- c(
    "--vanilla", "--no-save", "--no-restore",
    fit_script,
    "--species", "Acris_blanchardi",
    "--model_name", model_name,
    "--env_csv_dir", prepare_out,
    "--occ_csv", prepared_occ,
    "--vars", vars_str,
    "--output_dir", prepare_out,
    "--num_starts", as.character(num_starts),
    "--num_threads", as.character(num_threads),
    "--years", years_str
  )
  if (nzchar(mask_str)) {
    fit_cmd <- c(fit_cmd, "--mask", mask_str)
  }

  fit_ok <- system2("Rscript", fit_cmd,
                    stdout = file.path(iter_dir, "fit.out"),
                    stderr = file.path(iter_dir, "fit.err")) == 0
  if (!fit_ok) {
    status_vec[b] <- "fit_failed"
    next
  }

  rds_file <- file.path(prepare_out, "Acris_blanchardi", "models", paste0(model_name, ".rds"))
  fit_b <- tryCatch(readRDS(rds_file), error = function(e) NULL)
  if (is.null(fit_b) || is.null(fit_b$best_par) || fit_b$status != "success") {
    status_vec[b] <- "read_failed"
    next
  }

  param_mat[b, names(fit_b$best_par)] <- as.vector(fit_b$best_par)
  loglik_vec[b] <- fit_b$loglik
  n_free <- if (is.null(mask)) xsdm::num_par(length(vars)) else xsdm::num_par(length(vars)) - length(mask)
  pbic_vec[b] <- -2 * fit_b$loglik + n_free * log(nrow(occ_b))
  status_vec[b] <- "success"

  # Clean up heavy per-iteration files, keep the CSVs if needed for debug
  # unlink(iter_dir, recursive = TRUE, force = TRUE)
}

# ─── Save parameter trace ─────────────────────────────────────────────────────
out_df <- as.data.frame(param_mat)
out_df$iteration <- seq_len(B) + start_iter - 1
out_df$status <- status_vec
out_df$loglik <- loglik_vec
out_df$pBIC <- pbic_vec
out_df$n_pres <- n_pres_vec
out_df$n_abs <- n_abs_vec
out_df <- out_df[, c("iteration", "status", "n_pres", "n_abs", "loglik", "pBIC", param_names), drop = FALSE]

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
params_file <- file.path(output_dir, "boostra_params_vsp_stageB.csv")
write.csv(out_df, params_file, row.names = FALSE)
message("Wrote ", params_file)

# ─── CI vs original estimate ──────────────────────────────────────────────────
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

ci_file <- file.path(output_dir, "boostra_CI_vsp_stageB.csv")
write.csv(ci_df, ci_file, row.names = FALSE)
message("Wrote ", ci_file)

message("\nStage B summary:")
message("  Success: ", sum(status_vec == "success"), "/", B)
print(ci_df)

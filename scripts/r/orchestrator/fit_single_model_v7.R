#!/usr/bin/env Rscript
# fit_single_model.R — Worker script: fits ONE model (L1 or L2 boundary)
# Called by the orchestrator with args:
#   --species "Species name"
#   --model_name "T1_P1"
#   --env_csv_dir "/path/to/env"
#   --output_dir "/path/to/results"
#   --num_starts 1500
#   --num_threads 4
#   --mask "pd=Inf,sigltil1=Inf"  (optional, for boundary models)
#   --vars "T1,P1"  (which variables to use)

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
})

local({
  this_dir <- tryCatch({
    f <- commandArgs(trailingOnly = FALSE)
    f <- sub("^--file=", "", f[grepl("^--file=", f)])
    if (length(f) == 1) dirname(normalizePath(f)) else NULL
  }, error = function(e) NULL)
  helper <- if (!is.null(this_dir)) file.path(this_dir, "occ_prefilter.R") else "occ_prefilter.R"
  if (file.exists(helper)) sys.source(helper, envir = topenv())
})

local({
  this_dir <- tryCatch({
    f <- commandArgs(trailingOnly = FALSE)
    f <- sub("^--file=", "", f[grepl("^--file=", f)])
    if (length(f) == 1) dirname(normalizePath(f)) else NULL
  }, error = function(e) NULL)
  helper <- if (!is.null(this_dir)) file.path(this_dir, "wb_flags.R") else "wb_flags.R"
  if (file.exists(helper)) sys.source(helper, envir = topenv())
})

prefilter_enabled <- function() {
  tolower(Sys.getenv("APPLY_PREFILTER", "true")) %in% c("true", "1", "yes", "t")
}

# ─── CLI parsing ─────────────────────────────────────────────────────────────

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name <- parse_arg("--species")
model_name   <- parse_arg("--model_name")
env_csv_dir  <- parse_arg("--env_csv_dir",
                          "/home/a474r867/scratch/xsdm_env_extraction_19")
occ_csv      <- parse_arg("--occ_csv")
output_dir   <- parse_arg("--output_dir",
                          "/home/a474r867/scratch/xsdm_results_v6")
num_starts   <- as.integer(parse_arg("--num_starts", "1500"))
num_threads  <- as.integer(parse_arg("--num_threads", "4"))
mask_str     <- parse_arg("--mask", "")
vars_str     <- parse_arg("--vars")
years_str    <- parse_arg("--years", paste(1980:2020, collapse = ","))

years <- as.integer(strsplit(years_str, ",")[[1]])

if (is.null(species_name)) stop("--species required", call. = FALSE)
if (is.null(model_name))   stop("--model_name required", call. = FALSE)
if (is.null(vars_str))     stop("--vars required", call. = FALSE)

var_names <- strsplit(vars_str, ",")[[1]]

# Parse mask
mask <- NULL
if (nzchar(mask_str)) {
  pairs <- strsplit(mask_str, ",")[[1]]
  mask <- numeric(length(pairs))
  names(mask) <- character(length(pairs))
  for (i in seq_along(pairs)) {
    kv <- strsplit(pairs[i], "=")[[1]]
    names(mask)[i] <- kv[1]
    mask[i] <- as.numeric(kv[2])
  }
}

cat(sprintf("fit_single_model: %s | model=%s | vars=%s | starts=%d | mask=%s\n",
            species_name, model_name, vars_str, num_starts,
            if (is.null(mask)) "none" else mask_str))

# ─── Reuse guard ─────────────────────────────────────────────────────────────
# When REUSE_EXISTING_FITS is truthy, skip re-fitting a model whose output
# already exists and converged successfully. Model fits are independent of the
# dist_between_params / well-behaved checks, so a previously-successful fit can
# be reused when only the downstream L3 scan needs to be recomputed.
reuse_existing <- tolower(Sys.getenv("REUSE_EXISTING_FITS", "")) %in%
  c("1", "true", "yes")
if (reuse_existing) {
  sp_safe_chk <- gsub(" ", "_", species_name)
  existing_rds <- file.path(output_dir, sp_safe_chk, "models",
                            paste0(model_name, ".rds"))
  if (file.exists(existing_rds)) {
    prev <- tryCatch(readRDS(existing_rds), error = function(e) NULL)
    if (!is.null(prev) && identical(prev$status, "success")) {
      cat(sprintf("REUSE_EXISTING_FITS: %s already fit (status=success) — skipping\n",
                  model_name))
      quit(save = "no", status = 0)
    }
  }
}

# ─── Variable mapping ────────────────────────────────────────────────────────

var_map <- list(
  T1 = "T1_bio01",
  T2 = "T10_bio10",
  T3 = "T11_bio11",
  P1 = "P12_bio12",
  P2 = "P16_bio16",
  P3 = "P17_bio17"
)

# ─── Load data ───────────────────────────────────────────────────────────────

sp_safe    <- gsub(" ", "_", species_name)
env_sp_dir <- file.path(env_csv_dir, sp_safe)
if (!dir.exists(env_sp_dir))
  stop("Env dir not found: ", env_sp_dir, call. = FALSE)

# Read occurrence from filtered override when provided, otherwise from first variable
first_csv <- file.path(env_sp_dir, paste0(var_map[[var_names[1]]], ".csv"))
if (is.null(occ_csv) || !nzchar(occ_csv)) {
  occ_raw <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
} else {
  occ_raw <- read.csv(occ_csv, stringsAsFactors = FALSE, check.names = FALSE)
}
occ_vec <- if ("occ" %in% names(occ_raw)) occ_raw$occ else occ_raw$presence
n_pts   <- nrow(occ_raw)
n_time    <- length(years)

# Load required variables
env_data_list <- list()
for (vname in var_names) {
  csv_file <- file.path(env_sp_dir, paste0(var_map[[vname]], ".csv"))
  if (!file.exists(csv_file)) stop("Missing: ", csv_file, call. = FALSE)
  env_df <- read.csv(csv_file, stringsAsFactors = FALSE, check.names = FALSE)
  if ("row_id" %in% names(occ_raw)) {
    row_ids <- occ_raw$row_id
    if (anyNA(row_ids) || any(row_ids < 1L) || any(row_ids > nrow(env_df))) {
      stop("Invalid row_id values in filtered occurrence CSV for ", csv_file, call. = FALSE)
    }
    env_df <- env_df[row_ids, , drop = FALSE]
  }
  mat <- matrix(NA_real_, nrow = n_pts, ncol = n_time)
  for (ti in seq_along(years)) {
    ycol <- as.character(years[ti])
    if (ycol %in% names(env_df)) mat[, ti] <- env_df[[ycol]]
  }
  env_data_list[[vname]] <- mat
}

# ─── Kelvin → Celsius for temperature variables ──────────────────────────────
# ERA5Land absolute-temperature bioclimatics are in Kelvin; convert to Celsius
# so the fitted niche centre (mu) is interpretable in degrees Celsius. This is
# a pure location shift: it leaves IQR-based scaling and pBIC ranking
# unchanged, and must match the prediction path in build_env_list(). It is
# applied ONLY to absolute temperatures: the thermal indices bio02/bio03/bio04
# and bio07 are differences/ratios, not Kelvin, so they are left as-is.
KELVIN_OFFSET <- 273.15
temp_model_vars <- intersect(c("T1", "T2", "T3"), var_names)
for (vname in temp_model_vars) {
  env_data_list[[vname]] <- env_data_list[[vname]] - KELVIN_OFFSET
}

# ─── Adaptive rescaling (IQR-based) ──────────────────────────────────────────
# Compare IQR of each variable. If any variable has IQR orders of magnitude
# larger than others, divide by the nearest power of 10 to equalize scales.
# This prevents the optimizer from struggling with mixed-scale variables.

temp_vars   <- c("T1", "T2", "T3")
precip_vars <- c("P1", "P2", "P3")

# Compute IQR for each loaded variable (using all non-NA values across space+time)
iqr_vals <- sapply(var_names, function(vname) {
  vals <- as.vector(env_data_list[[vname]])
  vals <- vals[!is.na(vals)]
  if (length(vals) < 10) return(NA_real_)
  IQR(vals, na.rm = TRUE)
})

# Find reference IQR (median IQR of temperature variables, or all if no temp)
temp_in_model <- intersect(temp_vars, var_names)
if (length(temp_in_model) > 0) {
  ref_iqr <- median(iqr_vals[temp_in_model], na.rm = TRUE)
} else {
  ref_iqr <- median(iqr_vals, na.rm = TRUE)
}

# Rescale variables whose IQR is >10x the reference
scale_factors <- setNames(rep(1, length(var_names)), var_names)
for (vname in var_names) {
  if (is.na(iqr_vals[vname]) || is.na(ref_iqr) || ref_iqr < 1e-10) next
  ratio <- iqr_vals[vname] / ref_iqr
  if (ratio > 10) {
    # Divide by nearest power of 10
    power <- floor(log10(ratio))
    scale_factors[vname] <- 10^power
    env_data_list[[vname]] <- env_data_list[[vname]] / (10^power)
  }
}

cat(sprintf("IQR rescaling: ref_iqr=%.2f | scales: %s\n",
            ref_iqr,
            paste(sprintf("%s=1/%g", var_names, scale_factors[var_names]), collapse = ", ")))

# ─── Build env array ─────────────────────────────────────────────────────────

p <- length(var_names)
arr <- array(NA_real_, dim = c(n_pts, n_time, p),
             dimnames = list(NULL, as.character(years), var_names))
for (vi in seq_along(var_names)) {
  arr[, , vi] <- env_data_list[[var_names[vi]]]
}

# Geographic outlier prefilter: drop occurrence points (presence or absence)
# whose lon/lat fall outside the central-quantile box of the presences, so a
# stray record (e.g. a Florida point for a Brazilian species) cannot distort the
# fitted niche. A separate DROP_TOP_K knob drops the k most distant points from
# the presence-coordinate median, regardless of APPLY_PREFILTER. Applied
# identically in the prediction/TSS path (compute_tss.R).
geo_keep <- rep(TRUE, n_pts)
if (exists("occ_prefilter_keep", mode = "function") &&
    all(c("lon", "lat") %in% names(occ_raw))) {
  if (prefilter_enabled()) {
    q <- prefilter_quantile()
    keep_q <- occ_prefilter_keep(occ_raw$lon, occ_raw$lat, occ_vec, quantile = q)
    geo_keep <- geo_keep & keep_q
    cat(sprintf("occ_prefilter: enabled (quantile=%.3f)\n", q))
    if (sum(!keep_q) > 0) {
      cat(sprintf("occ_prefilter: dropped %d/%d points outside presence lon/lat central %.1f%% box\n",
                  sum(!keep_q), n_pts, 100 * q))
    }
  } else {
    cat("occ_prefilter: DISABLED (APPLY_PREFILTER=false)\n")
  }
}

if (exists("occ_drop_top_k_keep", mode = "function") &&
    all(c("lon", "lat") %in% names(occ_raw))) {
  k_drop <- prefilter_drop_top_k()
  keep_k <- occ_drop_top_k_keep(occ_raw$lon, occ_raw$lat, occ_vec, k = k_drop)
  geo_keep <- geo_keep & keep_k
  drop_idx <- which(!keep_k)
  if (length(drop_idx) > 0) {
    cat(sprintf("occ_drop_top_k: dropped %d point(s) (k=%d)\n", length(drop_idx), k_drop))
    for (i in drop_idx) {
      cls <- if (as.integer(occ_vec[i]) == 1L) "presence" else "absence"
      cat(sprintf("  drop lon=%.6f lat=%.6f class=%s\n",
                  occ_raw$lon[i], occ_raw$lat[i], cls))
    }
  } else if (k_drop > 0L) {
    cat(sprintf("occ_drop_top_k: no-op (k=%d, n=%d)\n", k_drop, n_pts))
  }
}

# Remove rows with NA
good <- apply(arr, 1, function(x) !any(is.na(x))) & geo_keep
env_dat <- arr[good, , , drop = FALSE]
occ     <- occ_vec[good]

n <- nrow(env_dat)
occ_src <- if (is.null(occ_csv) || !nzchar(occ_csv)) first_csv else occ_csv
cat(sprintf("Filtered input: occ_csv=%s | vars=%s | Data: %d pts (after NA removal), %d presences\n",
            occ_src, paste(var_names, collapse = ","), n, sum(occ == 1)))
cat(sprintf("Data: %d pts (after NA removal), %d presences, %d vars, %d years\n",
            n, sum(occ == 1), p, n_time))

if (sum(occ == 1) < 3) {
  cat("ERROR: Too few presences (<3). Saving NULL result.\n")
  result_out <- list(model_name = model_name, species = species_name,
                     status = "too_few_presences", vars = var_names, mask = mask)
  sp_out_dir <- file.path(output_dir, sp_safe, "models")
  dir.create(sp_out_dir, recursive = TRUE, showWarnings = FALSE)
  saveRDS(result_out, file.path(sp_out_dir, paste0(model_name, ".rds")))
  quit(save = "no", status = 0)
}

# ─── Fit model ───────────────────────────────────────────────────────────────

t0 <- proc.time()[3]

fit <- tryCatch(
  optimize_likelihood(
    env_dat     = env_dat,
    occ         = occ,
    mask        = mask,
    num_starts  = num_starts,
    num_threads = num_threads,
    parallel    = FALSE,
    verbose     = FALSE
  ),
  error = function(e) {
    cat(sprintf("ERROR in optimize_likelihood: %s\n", e$message))
    NULL
  }
)

dt <- proc.time()[3] - t0

if (is.null(fit) || is.null(fit$best$par)) {
  cat(sprintf("FAILED after %.1fs\n", dt))
  result_out <- list(model_name = model_name, species = species_name,
                     status = "failed", vars = var_names, mask = mask,
                     scale_factors = scale_factors[var_names], time_s = dt)
} else {
  n_free <- if (is.null(mask)) num_par(p) else num_par(p) - length(mask)
  pBIC   <- -2 * fit$best$loglik + n_free * log(n)

  cat(sprintf("SUCCESS: pBIC=%.1f logLik=%.4f n_free=%d (%.1fs)\n",
              pBIC, fit$best$loglik, n_free, dt))

  result_out <- list(
    model_name    = model_name,
    species       = species_name,
    status        = "success",
    vars          = var_names,
    mask          = mask,
    n             = n,
    p             = p,
    n_free        = n_free,
    loglik        = fit$best$loglik,
    pBIC          = pBIC,
    best_par      = fit$best$par,
    solutions     = fit$solutions,
    scale_factors = scale_factors[var_names],
    env_dat       = env_dat,
    occ           = occ,
    time_s        = dt
  )

  if (exists("wb_compute_result", mode = "function")) {
    wb_result <- tryCatch(
      wb_compute_result(result_out, verbose = FALSE),
      error = function(e) {
        cat(sprintf("WARNING: wb computation failed for %s: %s\n", model_name, e$message))
        NULL
      }
    )
    if (!is.null(wb_result)) {
      wb_dir <- file.path(output_dir, sp_safe, "wb")
      dir.create(wb_dir, recursive = TRUE, showWarnings = FALSE)
      saveRDS(wb_result, file.path(wb_dir, paste0(model_name, "_wb.rds")))
    }
  }
}

# ─── Save ────────────────────────────────────────────────────────────────────

sp_out_dir <- file.path(output_dir, sp_safe, "models")
dir.create(sp_out_dir, recursive = TRUE, showWarnings = FALSE)
out_file <- file.path(sp_out_dir, paste0(model_name, ".rds"))
saveRDS(result_out, out_file)
cat(sprintf("Saved: %s\n", out_file))

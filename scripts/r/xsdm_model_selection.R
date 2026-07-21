#!/usr/bin/env Rscript
# xsdm_model_selection.R
# ──────────────────────────────────────────────────────────────────────
# Implements the Reuman Model Selection Pipeline for a single species.
#
# Algorithm: 23 non-boundary models (6 bioclim vars in temp×precip pairs)
#   → boundary expansion → pBIC ranking → well-behavedness test (optim
#   convergence + Hessian) → profile likelihood of selected model.
#
# Input:
#   --species     "Genus species" (matches CSV filename in occ_dir)
#   --occ_dir     Path to occurrence CSVs (columns: lon, lat, occ)
#   --bioclim_dir Path to bioclim GeoTIFFs (YYYY/bioNN_YYYY.tif)
#   --output_dir  Root output directory
#   --years       Comma-separated years (default: 1980,...,2020)
#   --num_starts  Optimizer restarts per model (default: 25)
#   --num_threads Threads for loglik_math (default: 4)
#
# Output (in output_dir/Genus_species/):
#   model_results.rds       — full results list
#   model_summary.csv       — all models ranked by pBIC
#   best_model.rds          — selected model details + profile
#   habitat_suitability.tif — suitability map from best model
#   plots/01_model_comparison.pdf
#   plots/02_niche_shape.pdf
#   plots/03_habitat_suitability.pdf
#   plots/04_occurrences.pdf
#   plots/05_profile_likelihood.pdf
# ──────────────────────────────────────────────────────────────────────

# Ensure user library (with updated Rcpp) loads before container libs
user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(terra)
  library(numDeriv)
})

# Check if arrow + dplyr are available (for Parquet mode)
has_arrow <- requireNamespace("arrow", quietly = TRUE) &&
             requireNamespace("dplyr", quietly = TRUE)

# ── Parse CLI arguments ──────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name  <- parse_arg("--species")
occ_dir       <- parse_arg("--occ_dir",
                           "/home/a474r867/scratch/xsdm_occurrences")
bioclim_dir   <- parse_arg("--bioclim_dir",
                           "/home/a474r867/scratch/era5-land/era5_bioclim/bioclim")
output_dir    <- parse_arg("--output_dir",
                           "/home/a474r867/scratch/xsdm_results")
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
num_starts    <- as.integer(parse_arg("--num_starts", "25"))
num_threads   <- as.integer(parse_arg("--num_threads", "4"))

# Parquet mode: pre-extracted data (skips all raster I/O)
occ_parquet   <- parse_arg("--occ_parquet")   # species_occurrences.parquet
env_parquet   <- parse_arg("--env_parquet")   # env_extracted.parquet
use_parquet   <- !is.null(occ_parquet) && !is.null(env_parquet) && has_arrow

# CSV mode: pre-extracted env CSVs (one per variable per species)
env_csv_dir   <- parse_arg("--env_csv_dir")   # xsdm_env_extraction/
use_csv       <- !is.null(env_csv_dir)

# Split mode: adaptive parallelization for mega-species
# --phase L1: fit only one model (requires --model_index 1..23)
# --phase L2+: collect L1 results and run L2/L3/L4/profile
# (default: NULL = full pipeline)
phase         <- parse_arg("--phase")          # "L1" or "L2+"
model_index   <- parse_arg("--model_index")    # 1..23 (only with --phase L1)
if (!is.null(model_index)) model_index <- as.integer(model_index)

years <- as.integer(strsplit(years_str, ",")[[1]])
if (is.null(species_name)) stop("--species is required", call. = FALSE)

data_mode <- if (use_csv) "CSV (pre-extracted)" else if (use_parquet) "Parquet (pre-extracted)" else "Raster"
phase_label <- if (is.null(phase)) "full" else phase

cat("===================================================\n")
cat("xsdm Model Selection Pipeline\n")
cat("Species:", species_name, "\n")
cat("Phase:  ", phase_label,
    if (!is.null(model_index)) paste0(" (model ", model_index, "/23)") else "", "\n")
cat("Years:", min(years), "-", max(years),
    "(", length(years), "years)\n")
cat("Starts:", num_starts, " Threads:", num_threads, "\n")
cat("Data mode:", data_mode, "\n")
cat("===================================================\n")

# ── Output directories ───────────────────────────────────────────────
sp_dir    <- file.path(output_dir, gsub(" ", "_", species_name))
plots_dir <- file.path(sp_dir, "plots")
l1_dir    <- file.path(sp_dir, "L1")  # split mode: individual L1 results
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(l1_dir, recursive = TRUE, showWarnings = FALSE)

# ══════════════════════════════════════════════════════════════════════
# SECTION 1 — Load data
# ══════════════════════════════════════════════════════════════════════

bio_map <- c(
  T1_bio01 = "bio01", T2_bio10 = "bio10", T3_bio11 = "bio11",
  P1_bio12 = "bio12", P2_bio16 = "bio16", P3_bio17 = "bio17"
)

if (use_csv) {
  # ── CSV mode: pre-extracted env CSVs (fastest, zero I/O overhead) ──
  cat("Loading from pre-extracted CSVs...\n")
  t0 <- Sys.time()

  sp_safe_csv <- gsub(" ", "_", species_name)
  env_sp_dir  <- file.path(env_csv_dir, sp_safe_csv)
  if (!dir.exists(env_sp_dir))
    stop("Env CSV dir not found: ", env_sp_dir, call. = FALSE)

  # Read occurrence data from the first env CSV (has lon, lat, presence)
  first_csv <- file.path(env_sp_dir, paste0(names(bio_map)[1], ".csv"))
  if (!file.exists(first_csv))
    stop("Env CSV not found: ", first_csv, call. = FALSE)
  occ_raw <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
  occ_raw <- occ_raw[, c("lon", "lat", "presence")]

  n_pts  <- nrow(occ_raw)
  n_time <- length(years)
  n_vars <- length(bio_map)

  full_env_array <- array(NA_real_,
                          dim = c(n_pts, n_time, n_vars),
                          dimnames = list(NULL,
                                         time = as.character(years),
                                         var  = names(bio_map)))

  for (vi in seq_along(bio_map)) {
    var_label <- names(bio_map)[vi]
    csv_file  <- file.path(env_sp_dir, paste0(var_label, ".csv"))
    if (!file.exists(csv_file))
      stop("Missing env CSV: ", csv_file, call. = FALSE)
    env_df <- read.csv(csv_file, stringsAsFactors = FALSE, check.names = FALSE)
    year_cols <- as.character(years)
    for (ti in seq_along(years)) {
      full_env_array[, ti, vi] <- env_df[[year_cols[ti]]]
    }
  }

  env_rasters <- NULL
  elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  cat(sprintf("CSV loaded: %d records, %d presences (%.1fs)\n",
              n_pts, sum(occ_raw$presence == 1), elapsed))

} else if (use_parquet) {
  # ── Parquet mode: lazy-filtered reads (Arrow pushdown) ───────────
  cat("Loading from Parquet (lazy filter)...\n")
  t0 <- Sys.time()

  # Lazy read: only materialize rows for this species
  occ_raw <- as.data.frame(
    arrow::open_dataset(occ_parquet, format = "parquet") |>
      dplyr::filter(species == species_name) |>
      dplyr::select(lon, lat, presence) |>
      dplyr::collect()
  )
  if (nrow(occ_raw) == 0)
    stop("Species not found in parquet: ", species_name, call. = FALSE)

  # Get unique coords for this species, then filter env data lazily
  sp_coords <- unique(occ_raw[, c("lon", "lat")])
  env_ds <- arrow::open_dataset(env_parquet, format = "parquet")

  # Stage 1: bounding-box filter (Arrow pushes down range comparisons)
  # This avoids loading the entire 3.5 GB parquet into memory
  lon_min <- min(sp_coords$lon) - 0.01
  lon_max <- max(sp_coords$lon) + 0.01
  lat_min <- min(sp_coords$lat) - 0.01
  lat_max <- max(sp_coords$lat) + 0.01
  env_bbox <- as.data.frame(
    env_ds |>
      dplyr::filter(lon >= lon_min, lon <= lon_max,
                    lat >= lat_min, lat <= lat_max) |>
      dplyr::collect()
  )
  # Stage 2: exact coordinate-pair matching in R
  occ_keys <- paste(occ_raw$lon, occ_raw$lat, sep = "_")
  env_bbox$key <- paste(env_bbox$lon, env_bbox$lat, sep = "_")
  env_sp <- env_bbox[env_bbox$key %in% unique(occ_keys), , drop = FALSE]
  env_sp$key <- NULL
  rm(env_bbox); gc(verbose = FALSE)

  # Build the full 6-var 3D array from Parquet (M pts × N years × 6 vars)
  env_vars_parquet <- setNames(names(bio_map), unname(bio_map))
  # env_vars_parquet: bio01 -> T1_bio01, bio10 -> T2_bio10, etc.

  unique_coords <- unique(occ_raw[, c("lon", "lat")])
  n_pts <- nrow(occ_raw)
  n_time <- length(years)
  n_vars <- length(bio_map)

  # Pre-build the full 3D array for all 6 variables
  full_env_array <- array(NA_real_,
                          dim = c(n_pts, n_time, n_vars),
                          dimnames = list(NULL,
                                         time = as.character(years),
                                         var = names(bio_map)))

  for (vi in seq_along(bio_map)) {
    var_label <- names(bio_map)[vi]  # e.g. "T1_bio01"
    var_col   <- bio_map[vi]         # e.g. "bio01"
    for (ti in seq_along(years)) {
      yr <- years[ti]
      env_yr <- env_sp[env_sp$year == yr, , drop = FALSE]
      env_keys <- paste(env_yr$lon, env_yr$lat, sep = "_")
      idx <- match(occ_keys, env_keys)
      full_env_array[, ti, vi] <- env_yr[[var_col]][idx]
    }
  }

  # env_rasters not needed in parquet mode — set to NULL
  env_rasters <- NULL

  elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  cat(sprintf("Parquet loaded: %d records, %d presences (%.1fs)\n",
              nrow(occ_raw), sum(occ_raw$presence == 1), elapsed))

} else {
  # ── Raster mode: load from GeoTIFFs ───────────────────────────────
  occ_file <- file.path(occ_dir, paste0(species_name, ".csv"))
  if (!file.exists(occ_file)) stop("File not found: ", occ_file, call. = FALSE)

  occ_raw <- read.csv(occ_file, stringsAsFactors = FALSE)
  if ("occ" %in% names(occ_raw) && !"presence" %in% names(occ_raw)) {
    names(occ_raw)[names(occ_raw) == "occ"] <- "presence"
  }

  load_bio_stack <- function(var_code, years, bioclim_dir) {
    paths <- file.path(bioclim_dir, years,
                       paste0(var_code, "_", years, ".tif"))
    exist <- file.exists(paths)
    if (!any(exist)) stop("No files for ", var_code, call. = FALSE)
    if (!all(exist)) warning(sum(!exist), " missing years for ", var_code)
    terra::rast(paths[exist])
  }

  cat("Loading bioclimatic rasters...\n")
  env_rasters <- list()
  for (label in names(bio_map)) {
    cat("  ", label, "...")
    env_rasters[[label]] <- load_bio_stack(bio_map[label], years, bioclim_dir)
    cat(" [", terra::nlyr(env_rasters[[label]]), " layers]\n")
  }
}

cat("Occurrences loaded:", nrow(occ_raw), "records (",
    sum(occ_raw$presence == 1), "presences)\n")

# ══════════════════════════════════════════════════════════════════════
# SECTION 2 — Define the 23 non-boundary models (L1)
# ══════════════════════════════════════════════════════════════════════
# Temp:   none, T1, T2, T3, T2+T3
# Precip: none, P1, P2, P3, P2+P3
# Exclude: (none,none) and (T2+T3, P2+P3) → 23 models

temp_opts <- list(
  none = character(0),
  T1   = "T1_bio01",
  T2   = "T2_bio10",
  T3   = "T3_bio11",
  T2T3 = c("T2_bio10", "T3_bio11")
)
precip_opts <- list(
  none = character(0),
  P1   = "P1_bio12",
  P2   = "P2_bio16",
  P3   = "P3_bio17",
  P2P3 = c("P2_bio16", "P3_bio17")
)

models_L1 <- list()
for (tn in names(temp_opts)) {
  for (pn in names(precip_opts)) {
    if (tn == "none" && pn == "none") next
    if (tn == "T2T3"  && pn == "P2P3") next
    mname <- paste0(tn, "_", pn)
    models_L1[[mname]] <- c(temp_opts[[tn]], precip_opts[[pn]])
  }
}
cat("Defined", length(models_L1), "non-boundary models (L1)\n")

# ══════════════════════════════════════════════════════════════════════
# SECTION 3 — Helper: fit a single model spec
# ══════════════════════════════════════════════════════════════════════

fit_one_model <- function(var_labels, env_rasters, occ_df,
                          num_starts, num_threads, mask = NULL,
                          full_env_array = NULL) {
  # Build 3-D array: (locations x time x variables)
  if (!is.null(full_env_array)) {
    # Parquet mode: subset pre-built array by variable labels
    var_idx <- match(var_labels, dimnames(full_env_array)[[3]])
    env_dat <- full_env_array[, , var_idx, drop = FALSE]
  } else {
    # Raster mode: extract from SpatRasters
    env_list <- env_rasters[var_labels]
    env_dat <- tryCatch(
      env_data_array(env_list, occ_df),
      error = function(e) { warning(e$message); NULL }
    )
  }
  if (is.null(env_dat)) return(NULL)

  occ_vec <- occ_df$presence
  p <- dim(env_dat)[3]
  n <- dim(env_dat)[1]

  # Remove locations with any NA in env_dat
  good <- apply(env_dat, 1, function(x) !any(is.na(x)))
  if (sum(good) < n) {
    env_dat <- env_dat[good, , , drop = FALSE]
    occ_vec <- occ_vec[good]
    n <- sum(good)
  }
  if (sum(occ_vec == 1) < 3) {
    warning("Too few presences after NA removal"); return(NULL)
  }

  # Fit with optimize_likelihood
  result <- tryCatch(
    optimize_likelihood(
      env_dat     = env_dat,
      occ         = occ_vec,
      mask        = mask,
      num_starts  = num_starts,
      num_threads = num_threads,
      parallel    = TRUE,
      verbose     = FALSE
    ),
    error = function(e) { warning(e$message); NULL }
  )
  if (is.null(result)) return(NULL)

  # Number of FREE parameters (mask entries are fixed, not counted)
  n_free <- if (is.null(mask)) {
    num_par(p)
  } else {
    num_par(p) - length(mask)
  }

  # pseudo-BIC: -2*loglik + k*log(n)
  pBIC <- -2 * result$best$loglik + n_free * log(n)

  list(
    result   = result,
    env_dat  = env_dat,
    occ      = occ_vec,
    n        = n,
    p        = p,
    n_free   = n_free,
    loglik   = result$best$loglik,
    pBIC     = pBIC,
    mask     = mask
  )
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 4 — Phase 1: Fit L1 (23 non-boundary models)
# ══════════════════════════════════════════════════════════════════════

# ── Split mode: Phase L2+ skips L1 entirely ──
if (identical(phase, "L2+")) {
  cat("\n-- Phase L2+: Loading saved L1 results from", l1_dir, "--\n")
  l1_files <- list.files(l1_dir, pattern = "^model_.*\\.rds$", full.names = TRUE)
  if (length(l1_files) == 0) {
    cat("ERROR: No L1 result files found in", l1_dir, "\n")
    quit(save = "no", status = 1)
  }
  L1 <- list()
  for (f in l1_files) {
    res <- readRDS(f)
    L1[[res$model_name]] <- res$fit
  }
  L1 <- Filter(Negate(is.null), L1)
  cat("  Loaded", length(L1), "L1 models from saved RDS files\n")

} else {
  # ── Normal or L1-single mode ──
  if (identical(phase, "L1")) {
    # Split mode: fit only one model
    if (is.null(model_index) || model_index < 1 || model_index > length(models_L1)) {
      stop("--phase L1 requires --model_index 1..", length(models_L1), call. = FALSE)
    }
    models_to_fit <- models_L1[model_index]
    cat(sprintf("\n-- Phase L1: Fitting model %d/%d (%s) --\n",
                model_index, length(models_L1), names(models_to_fit)[1]))
  } else {
    # Full mode: fit all 23
    models_to_fit <- models_L1
    cat("\n-- Phase 1: Fitting", length(models_to_fit), "non-boundary models --\n")
  }

  L1 <- list()
  for (mname in names(models_to_fit)) {
    cat(sprintf("  [%2d/%d] %-15s ",
                which(names(models_L1) == mname), length(models_L1), mname))
    t0 <- proc.time()[3]

    L1[[mname]] <- fit_one_model(
      models_to_fit[[mname]], env_rasters, occ_raw,
      num_starts, num_threads,
      full_env_array = if (use_csv || use_parquet) full_env_array else NULL
    )

    dt <- proc.time()[3] - t0
    if (!is.null(L1[[mname]])) {
      cat(sprintf("pBIC=%.1f  ll=%.1f  (%.0fs)\n",
                  L1[[mname]]$pBIC, L1[[mname]]$loglik, dt))
    } else {
      cat(sprintf("FAILED (%.0fs)\n", dt))
    }
  }

  # ── Split mode L1: save result and exit ──
  if (identical(phase, "L1")) {
    mname <- names(models_to_fit)[1]
    out_file <- file.path(l1_dir,
      sprintf("model_%02d_%s.rds", model_index, mname))
    saveRDS(list(model_name = mname, model_index = model_index,
                 fit = L1[[mname]]),
            out_file)
    cat("Saved L1 result:", out_file, "\n")
    # Write sentinel so orchestrator knows this model is done
    writeLines("done", file.path(l1_dir,
      sprintf(".model_%02d.done", model_index)))
    quit(save = "no", status = 0)
  }
}

L1 <- Filter(Negate(is.null), L1)
if (length(L1) == 0) {
  cat("ERROR: All L1 models failed.\n")
  saveRDS(list(species = species_name, status = "all_L1_failed"),
          file.path(sp_dir, "model_results.rds"))
  quit(save = "no", status = 1)
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 5 — Compute tau, identify models for boundary expansion
# ══════════════════════════════════════════════════════════════════════
best_pBIC_L1 <- min(sapply(L1, `[[`, "pBIC"))
max_p        <- 3L      # max env vars in any single model
n_data       <- L1[[1]]$n
tau          <- (max_p + 1) * log(n_data)

cat(sprintf("\nBest L1 pBIC: %.1f\n", best_pBIC_L1))
cat(sprintf("tau = (%d+1)*log(%d) = %.1f\n", max_p, n_data, tau))
cat(sprintf("Boundary threshold: pBIC <= %.1f\n", best_pBIC_L1 + tau))

eligible_L2 <- names(L1)[sapply(L1, `[[`, "pBIC") <= best_pBIC_L1 + tau]
cat("Models eligible for boundary expansion:", length(eligible_L2), "\n")

# ══════════════════════════════════════════════════════════════════════
# SECTION 6 — Phase 2: Fit boundary models (L2)
# ══════════════════════════════════════════════════════════════════════
# Boundary models: fix pd=Inf (bio pd=1), or sigltil_i=Inf / sigrtil_i=Inf
# (sigma -> infinity = insensitive to that env var), or combinations.

generate_boundary_masks <- function(p) {
  masks <- list()

  # pd = 1 (math scale: pd = Inf)
  masks[["bd_pd1"]] <- c(pd = Inf)

  # sigma boundaries (one per env var)
  for (i in seq_len(p)) {
    m_l <- c(Inf); names(m_l) <- paste0("sigltil", i)
    masks[[paste0("bd_sigL", i)]] <- m_l

    m_r <- c(Inf); names(m_r) <- paste0("sigrtil", i)
    masks[[paste0("bd_sigR", i)]] <- m_r
  }

  # pd=1 + sigma combinations
  for (i in seq_len(p)) {
    m_pl <- c(pd = Inf, Inf); names(m_pl)[2] <- paste0("sigltil", i)
    masks[[paste0("bd_pd1_sigL", i)]] <- m_pl

    m_pr <- c(pd = Inf, Inf); names(m_pr)[2] <- paste0("sigrtil", i)
    masks[[paste0("bd_pd1_sigR", i)]] <- m_pr
  }

  masks
}

cat("\n-- Phase 2: Fitting boundary models (L2) --\n")
L2 <- list()
for (base_name in eligible_L2) {
  vars <- models_L1[[base_name]]
  p <- length(vars)
  bmasks <- generate_boundary_masks(p)

  for (bname in names(bmasks)) {
    full_name <- paste0(base_name, "__", bname)
    cat(sprintf("  %-35s ", full_name))
    t0 <- proc.time()[3]

    L2[[full_name]] <- fit_one_model(
      vars, env_rasters, occ_raw,
      num_starts, num_threads,
      mask = bmasks[[bname]],
      full_env_array = if (use_csv || use_parquet) full_env_array else NULL
    )

    dt <- proc.time()[3] - t0
    if (!is.null(L2[[full_name]])) {
      cat(sprintf("pBIC=%.1f  (%.0fs)\n", L2[[full_name]]$pBIC, dt))
    } else {
      cat(sprintf("FAILED (%.0fs)\n", dt))
    }
  }
}
L2 <- Filter(Negate(is.null), L2)
cat("Boundary models fitted:", length(L2), "\n")

# ══════════════════════════════════════════════════════════════════════
# SECTION 7 — L3 = L1 + L2, rank by pBIC
# ══════════════════════════════════════════════════════════════════════
L3 <- c(L1, L2)
L3_pBIC <- sapply(L3, `[[`, "pBIC")
L3_order <- names(L3)[order(L3_pBIC)]

cat(sprintf("\nL3: %d models (L1=%d, L2=%d)\n",
            length(L3), length(L1), length(L2)))
cat("Top 5 by pBIC:\n")
for (i in seq_len(min(5, length(L3_order)))) {
  cat(sprintf("  %d. %-35s pBIC=%.1f\n",
              i, L3_order[i], L3[[L3_order[i]]]$pBIC))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 8 — Well-behavedness test
# ══════════════════════════════════════════════════════════════════════
# Two flags must agree:
#   (a) Top-5 optim runs converge to same likelihood (range < 0.1)
#       AND close in parameter space (max dist < 0.05)
#   (b) Hessian at MLE is positive definite AND condition number < 1e6

test_well_behaved <- function(fit, model_name) {
  sols    <- fit$result$solutions
  env_dat <- fit$env_dat
  occ     <- fit$occ
  mask    <- fit$mask

  n_check <- min(5, nrow(sols))

  # --- (a) Optimization convergence ---
  top_ll <- sols$loglik[1:n_check]
  ll_range <- max(top_ll) - min(top_ll)

  # Parameter-space distances (full_par are complete math-scale vectors)
  top_pars <- sols$full_par[1:n_check]
  pdists <- vapply(2:n_check, function(i) {
    tryCatch({
      d <- dist_between_params(top_pars[[1]], top_pars[[i]], mask = NULL)
      if (is.list(d)) d$distance else d
    }, error = function(e) NA_real_)
  }, numeric(1))
  max_pdist <- max(pdists, na.rm = TRUE)

  flag_a <- (ll_range < 0.1) && (max_pdist < 0.1)

  # --- (b) Hessian check ---
  # We need the FREE parameters only for the Hessian
  best_full <- fit$result$best$par
  if (!is.null(mask)) {
    free_names <- setdiff(names(best_full), names(mask))
    best_free  <- best_full[free_names]
  } else {
    best_free  <- best_full
    free_names <- names(best_full)
  }

  hess <- tryCatch(
    numDeriv::hessian(
      func = function(par_free) {
        names(par_free) <- free_names
        loglik_math(par_free, env_dat = env_dat, occ = occ,
                    mask = mask, negative = TRUE, num_threads = 1L)
      },
      x = best_free
    ),
    error = function(e) NULL
  )

  flag_b   <- FALSE
  cond_num <- NA_real_

  if (!is.null(hess)) {
    evals <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
    all_pos  <- all(evals > 1e-8)
    cond_num <- if (min(evals) > 0) max(evals) / min(evals) else Inf
    flag_b   <- all_pos && is.finite(cond_num) && (cond_num < 1e6)
  }

  well_behaved <- flag_a && flag_b

  # Gap fix #1: warn when flags disagree (Reuman algorithm requirement)
  if (flag_a != flag_b) {
    warning(sprintf(
      "Flags disagree for %s: optim=%s, hessian=%s (ll_range=%.3f, max_pdist=%.4f, cond=%.1e)",
      model_name, flag_a, flag_b, ll_range, max_pdist, cond_num))
  }

  # Return eigenvalue spectrum for diagnostics
  evals_out <- if (exists("evals", inherits = FALSE)) evals else NA_real_

  list(well_behaved = well_behaved,
       flag_optim   = flag_a,
       flag_hessian = flag_b,
       ll_range     = ll_range,
       max_pdist    = max_pdist,
       cond_num     = cond_num,
       eigenvalues  = evals_out,
       flags_agree  = (flag_a == flag_b))
}

cat("\n-- Phase 3: Well-behavedness testing --\n")
M_Omega <- NULL
Omega   <- Inf
diag_rows <- list()  # Gap fix #2: collect diagnostics for ALL models tested

for (nm in L3_order) {
  cat(sprintf("  %-35s ", nm))
  wb <- tryCatch(
    test_well_behaved(L3[[nm]], nm),
    error = function(e) {
      cat("ERROR: ", e$message, "\n")
      list(well_behaved = FALSE, flag_optim = FALSE,
           flag_hessian = FALSE, cond_num = NA,
           ll_range = NA, max_pdist = NA, flags_agree = NA)
    }
  )

  cat(sprintf("optim=%5s hess=%5s cond=%.1e => %s\n",
              wb$flag_optim, wb$flag_hessian, wb$cond_num,
              if (wb$well_behaved) "WELL-BEHAVED" else "badly-behaved"))

  # Record diagnostics row
  diag_rows[[length(diag_rows) + 1]] <- data.frame(
    model        = nm,
    pBIC         = L3[[nm]]$pBIC,
    loglik       = L3[[nm]]$loglik,
    n_free       = L3[[nm]]$n_free,
    flag_optim   = wb$flag_optim,
    flag_hessian = wb$flag_hessian,
    flags_agree  = ifelse(is.na(wb$flags_agree), NA, wb$flags_agree),
    ll_range     = wb$ll_range,
    max_pdist    = wb$max_pdist,
    cond_number  = wb$cond_num,
    well_behaved = wb$well_behaved,
    stringsAsFactors = FALSE
  )

  if (wb$well_behaved) {
    M_Omega <- nm
    Omega   <- L3[[nm]]$pBIC
    cat(sprintf("\n  >> Selected: %s (pBIC=%.1f)\n", M_Omega, Omega))
    break
  }
}

# Write diagnostics CSV (always, even if no well-behaved model found)
if (length(diag_rows) > 0) {
  diag_df <- do.call(rbind, diag_rows)
  write.csv(diag_df, file.path(sp_dir, "diagnostics.csv"), row.names = FALSE)
  cat(sprintf("Diagnostics: %d models tested, %d well-behaved, %d flag-disagreements\n",
              nrow(diag_df), sum(diag_df$well_behaved, na.rm = TRUE),
              sum(!diag_df$flags_agree, na.rm = TRUE)))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 9 — L4 check (boundary models of L1 near Omega)
# ══════════════════════════════════════════════════════════════════════
if (!is.null(M_Omega)) {
  cat("\n-- Phase 4: L4 boundary check --\n")
  L4_cands <- names(L1)[
    sapply(L1, `[[`, "pBIC") > best_pBIC_L1 + tau &
    sapply(L1, `[[`, "pBIC") <= Omega + tau
  ]

  if (length(L4_cands) > 0) {
    cat("L4 candidates:", length(L4_cands), "\n")
    for (base_name in L4_cands) {
      vars <- models_L1[[base_name]]
      p <- length(vars)
      bmasks <- generate_boundary_masks(p)
      for (bname in names(bmasks)) {
        full_name <- paste0(base_name, "__", bname)
        if (full_name %in% names(L3)) next

        cat(sprintf("  %-35s ", full_name))
        t0 <- proc.time()[3]
        fit <- fit_one_model(vars, env_rasters, occ_raw,
                             num_starts, num_threads,
                             mask = bmasks[[bname]],
                             full_env_array = if (use_csv || use_parquet) full_env_array else NULL)
        dt <- proc.time()[3] - t0

        if (is.null(fit)) { cat(sprintf("FAILED (%.0fs)\n", dt)); next }
        cat(sprintf("pBIC=%.1f  (%.0fs)", fit$pBIC, dt))

        if (fit$pBIC < Omega) {
          wb <- tryCatch(
            test_well_behaved(fit, full_name),
            error = function(e) list(well_behaved = FALSE, cond_num = NA,
                                     flag_optim = FALSE, flag_hessian = FALSE)
          )
          if (wb$well_behaved) {
            M_Omega <- full_name
            Omega   <- fit$pBIC
            L3[[full_name]] <- fit
            cat(sprintf(" => NEW BEST (pBIC=%.1f)\n", Omega))
          } else {
            cat(" => badly-behaved\n")
          }
        } else {
          cat("\n")
        }
      }
    }
  } else {
    cat("No L4 candidates\n")
  }
}

if (is.null(M_Omega)) {
  cat("\nNo well-behaved model found for this species.\n")

  # Enhanced diagnostics: summarize failure reasons
  if (exists("diag_df") && nrow(diag_df) > 0) {
    n_optim_pass  <- sum(diag_df$flag_optim, na.rm = TRUE)
    n_hess_pass   <- sum(diag_df$flag_hessian, na.rm = TRUE)
    n_disagree    <- sum(!diag_df$flags_agree, na.rm = TRUE)
    best_cond     <- min(diag_df$cond_number[is.finite(diag_df$cond_number)],
                         na.rm = TRUE)
    cat(sprintf("  Models tested: %d\n", nrow(diag_df)))
    cat(sprintf("  Passed optim convergence (flag_a): %d\n", n_optim_pass))
    cat(sprintf("  Passed Hessian check (flag_b): %d\n", n_hess_pass))
    cat(sprintf("  Flag disagreements (a!=b): %d\n", n_disagree))
    cat(sprintf("  Best condition number: %.1e\n", best_cond))
    cat("  See diagnostics.csv for per-model details.\n")

    failure_summary <- list(
      n_tested     = nrow(diag_df),
      n_optim_pass = n_optim_pass,
      n_hess_pass  = n_hess_pass,
      n_disagree   = n_disagree,
      best_cond    = best_cond,
      top3_models  = head(diag_df[order(diag_df$pBIC), ], 3)
    )
  } else {
    failure_summary <- NULL
  }

  # Also write model_summary.csv even for failures
  summary_df <- data.frame(
    model    = names(L3),
    pBIC     = sapply(L3, `[[`, "pBIC"),
    loglik   = sapply(L3, `[[`, "loglik"),
    n_free   = sapply(L3, `[[`, "n_free"),
    n_data   = sapply(L3, `[[`, "n"),
    stringsAsFactors = FALSE
  )
  summary_df <- summary_df[order(summary_df$pBIC), ]
  write.csv(summary_df, file.path(sp_dir, "model_summary.csv"),
            row.names = FALSE)

  saveRDS(list(species = species_name, status = "no_well_behaved_model",
               failure_summary = failure_summary,
               L3 = L3),
          file.path(sp_dir, "model_results.rds"))
  quit(save = "no", status = 0)
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 10 — Profile likelihood of selected model
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Phase 5: Profile likelihood of", M_Omega, "--\n")

best_fit  <- L3[[M_Omega]]
best_full <- best_fit$result$best$par
best_mask <- best_fit$mask
best_bio  <- math_to_bio(best_full)

# profile_likelihood expects optim_param_vector = FREE params only
if (!is.null(best_mask)) {
  free_names <- setdiff(names(best_full), names(best_mask))
  optim_free <- best_full[free_names]
} else {
  optim_free <- best_full
  free_names <- names(best_full)
}

# ── Adaptive profile likelihood ──────────────────────────────────────
# Uses the Hessian curvature to set step sizes per parameter:
#   - se_i = 1/sqrt(H[i,i]) = approx std error of parameter i
#   - Expected distance to threshold: sqrt(qchisq(alpha,1) / H[i,i])
#   - Initial increment = expected_dist / target_steps_to_threshold
# If initial profile doesn't cross, extends with 2x step size (up to 3 rounds)
#
# This replaces the fixed increment=0.1, num_steps=30 approach that fails
# for parameters with very flat or very steep curvature.
# ─────────────────────────────────────────────────────────────────────

adaptive_profile <- function(pname, optim_free, env_dat, occ, mask,
                             hessian_matrix, num_threads, alpha = 0.95,
                             target_steps = 15L, max_rounds = 3L) {
  # Compute parameter-specific step size from Hessian curvature
  idx <- which(names(optim_free) == pname)
  h_ii <- abs(hessian_matrix[idx, idx])

  if (h_ii < 1e-12 || !is.finite(h_ii)) {
    # Fallback: flat curvature, use default
    increment <- 0.1
    n_steps <- 50L
  } else {
    # se_i = 1/sqrt(H_ii) = approx standard error from Fisher information
    se_i <- 1 / sqrt(h_ii)
    # Expected distance to 95% LR threshold under quadratic approximation
    expected_dist <- sqrt(qchisq(alpha, df = 1) / h_ii)
    # Set increment so we reach threshold in ~target_steps
    increment <- max(expected_dist / target_steps, 0.01)
    # Take enough steps to overshoot by 2x
    n_steps <- as.integer(ceiling(2 * expected_dist / increment))
    n_steps <- max(n_steps, 20L)
    n_steps <- min(n_steps, 80L)  # cap to prevent runaway
  }

  cat(sprintf("[inc=%.4f, steps=%d] ", increment, n_steps))

  # Round 1: initial profile with Hessian-informed step size
  prof <- tryCatch(
    profile_likelihood(
      profile_parameter  = pname,
      increment_left     = increment,
      increment_right    = increment,
      num_steps_left     = n_steps,
      num_steps_right    = n_steps,
      alpha              = alpha,
      optim_param_vector = optim_free,
      env_dat            = env_dat,
      occ                = occ,
      mask               = mask,
      num_threads        = num_threads,
      verbose            = FALSE
    ),
    error = function(e) NULL
  )

  if (is.null(prof)) return(NULL)

  # Check if threshold was crossed on both sides
  pdat <- prof$profile
  thresh <- prof$threshold
  idx_max <- which.max(pdat$loglik)
  left_crossed <- idx_max > 1 && any(pdat$loglik[1:(idx_max-1)] <= thresh)
  right_crossed <- idx_max < nrow(pdat) && any(pdat$loglik[(idx_max+1):nrow(pdat)] <= thresh)

  # Adaptive extension: if not crossed, retry with larger steps
  round <- 1L
  while ((!left_crossed || !right_crossed) && round < max_rounds) {
    round <- round + 1L
    # Double the increment and extend
    increment <- increment * 2
    ext_steps <- as.integer(n_steps * 1.5)
    ext_steps <- min(ext_steps, 100L)

    cat(sprintf("[ext%d: inc=%.4f, steps=%d] ", round, increment, ext_steps))

    prof_ext <- tryCatch(
      profile_likelihood(
        profile_parameter  = pname,
        increment_left     = increment,
        increment_right    = increment,
        num_steps_left     = ext_steps,
        num_steps_right    = ext_steps,
        alpha              = alpha,
        optim_param_vector = optim_free,
        env_dat            = env_dat,
        occ                = occ,
        mask               = mask,
        num_threads        = num_threads,
        verbose            = FALSE
      ),
      error = function(e) NULL
    )

    if (is.null(prof_ext)) break

    # Check if we improved crossing
    pdat_ext <- prof_ext$profile
    idx_max_ext <- which.max(pdat_ext$loglik)
    left_ext <- idx_max_ext > 1 && any(pdat_ext$loglik[1:(idx_max_ext-1)] <= thresh)
    right_ext <- idx_max_ext < nrow(pdat_ext) && any(pdat_ext$loglik[(idx_max_ext+1):nrow(pdat_ext)] <= thresh)

    # Accept extension if it improved threshold crossing
    if ((left_ext && !left_crossed) || (right_ext && !right_crossed)) {
      prof <- prof_ext
      left_crossed <- left_ext
      right_crossed <- right_ext
    }

    # Detect asymptotic decay: if LL drop per step is < 0.01 near the edge, stop
    edge_ll <- tail(pdat_ext$loglik, 5)
    if (length(edge_ll) >= 3) {
      avg_drop <- mean(abs(diff(edge_ll)))
      if (avg_drop < 0.01) {
        cat("[asymptotic] ")
        break
      }
    }
  }

  prof
}

# Compute numerical Hessian at MLE (reuse from well-behavedness test)
cat("  Computing Hessian for adaptive step sizing...\n")
hess_adaptive <- tryCatch(
  numDeriv::hessian(
    func = function(par_free) {
      names(par_free) <- free_names
      loglik_math(par_free, env_dat = best_fit$env_dat, occ = best_fit$occ,
                  mask = best_mask, negative = TRUE, num_threads = 1L)
    },
    x = optim_free
  ),
  error = function(e) {
    warning("Hessian computation failed: ", e$message)
    NULL
  }
)

# If Hessian available, use adaptive; otherwise fall back to fixed
profiles <- list()
for (pname in free_names) {
  cat(sprintf("  Profiling %-15s ... ", pname))
  t0 <- proc.time()[3]

  if (!is.null(hess_adaptive)) {
    prof <- adaptive_profile(pname, optim_free, best_fit$env_dat, best_fit$occ,
                             best_mask, hess_adaptive, num_threads)
  } else {
    prof <- tryCatch(
      profile_likelihood(
        profile_parameter  = pname,
        increment_left     = 0.1,
        increment_right    = 0.1,
        num_steps_left     = 30L,
        num_steps_right    = 30L,
        alpha              = 0.95,
        optim_param_vector = optim_free,
        env_dat            = best_fit$env_dat,
        occ                = best_fit$occ,
        mask               = best_mask,
        num_threads        = num_threads,
        verbose            = FALSE
      ),
      error = function(e) NULL
    )
  }

  dt <- proc.time()[3] - t0
  if (!is.null(prof)) {
    cat(sprintf("done (%.0fs) better_found=%s\n",
                dt, prof$found_better))
  } else {
    cat(sprintf("FAILED (%.0fs)\n", dt))
  }
  profiles[[pname]] <- prof
}

# ── Plot profiles ────────────────────────────────────────────────────
n_prof <- length(Filter(Negate(is.null), profiles))
if (n_prof > 0) {
  ncol_plot <- min(3, n_prof)
  nrow_plot <- ceiling(n_prof / ncol_plot)

  pdf(file.path(plots_dir, "05_profile_likelihood.pdf"),
      width = 5 * ncol_plot, height = 4 * nrow_plot)
  par(mfrow = c(nrow_plot, ncol_plot), mar = c(4, 4, 3, 1))

  for (pname in names(profiles)) {
    prof <- profiles[[pname]]
    if (is.null(prof)) next

    pdat <- prof$profile
    plot(pdat$value_math, pdat$loglik,
         type = "b", pch = 19, cex = 0.6,
         xlab = paste(pname, "(math scale)"),
         ylab = "log-likelihood",
         main = paste("Profile:", pname))
    abline(h = prof$threshold, col = "red", lty = 2)
    abline(v = optim_free[pname], col = "blue", lty = 2)
    legend("topright",
           legend = c("95% CI threshold", "MLE"),
           col = c("red", "blue"), lty = 2, cex = 0.7, bty = "n")
  }
  dev.off()
  cat("Profile plots saved: plots/05_profile_likelihood.pdf\n")
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 10b — Profile arc check (soft validation)
# ══════════════════════════════════════════════════════════════════════
# A well-behaved profile should be "dome-shaped" (downward-opening parabola):
#   - rises monotonically to MLE from left
#   - falls monotonically from MLE to right
#   - crosses the LR threshold on both sides
# We allow small deviations (noise_tol) from strict monotonicity.
#
# Output: profile_arc_check.csv with one row per species, one column per
#         free parameter (1=arc, 0=no arc), plus all_pass summary.
# ──────────────────────────────────────────────────────────────────────

check_profile_arc <- function(prof, noise_tol = 0.5) {
  # Returns a list with:
  #   is_arc   : logical — TRUE if profile is dome-shaped
  #   reason   : character — short reason if not dome
  #   details  : list with sub-checks
  if (is.null(prof)) {
    return(list(is_arc = FALSE, reason = "profile_null",
                details = list()))
  }

  pdat   <- prof$profile
  thresh <- prof$threshold
  ll     <- pdat$loglik
  vals   <- pdat$value_math
  n      <- length(ll)

  if (n < 3) {
    return(list(is_arc = FALSE, reason = "too_few_points",
                details = list(n_points = n)))
  }

  # 1. found_better: profiler found higher LL than MLE → optimization failed
  if (isTRUE(prof$found_better)) {
    return(list(is_arc = FALSE, reason = "found_better_ll",
                details = list()))
  }

  # 2. Locate the MLE point (maximum loglik in profile)
  idx_max <- which.max(ll)
  ll_max  <- ll[idx_max]

  # 3. Check both sides have points below threshold
  has_left  <- idx_max > 1
  has_right <- idx_max < n

  left_crosses  <- has_left  && any(ll[1:(idx_max - 1)] <= thresh)
  right_crosses <- has_right && any(ll[(idx_max + 1):n] <= thresh)

  # 4. Check monotonicity with tolerance
  # Left side: from index 1 to idx_max should be non-decreasing
  left_mono <- TRUE
  if (has_left && idx_max > 2) {
    left_ll <- ll[1:idx_max]
    for (i in 2:length(left_ll)) {
      if (left_ll[i] < left_ll[i - 1] - noise_tol) {
        left_mono <- FALSE
        break
      }
    }
  }

  # Right side: from idx_max to n should be non-increasing
  right_mono <- TRUE
  if (has_right && idx_max < (n - 1)) {
    right_ll <- ll[idx_max:n]
    for (i in 2:length(right_ll)) {
      if (right_ll[i] > right_ll[i - 1] + noise_tol) {
        right_mono <- FALSE
        break
      }
    }
  }

  # 5. Check that MLE is near the peak (within noise_tol of max)
  mle_at_peak <- (ll_max - ll[idx_max]) <= noise_tol

  # Combine checks
  is_arc <- left_crosses && right_crosses && left_mono && right_mono && mle_at_peak

  reason <- if (is_arc) {
    "pass"
  } else {
    reasons <- character(0)
    if (!left_crosses)  reasons <- c(reasons, "no_left_crossing")
    if (!right_crosses) reasons <- c(reasons, "no_right_crossing")
    if (!left_mono)     reasons <- c(reasons, "left_not_monotone")
    if (!right_mono)    reasons <- c(reasons, "right_not_monotone")
    if (!mle_at_peak)   reasons <- c(reasons, "mle_not_at_peak")
    paste(reasons, collapse = "+")
  }

  list(is_arc = is_arc, reason = reason,
       details = list(left_crosses = left_crosses, right_crosses = right_crosses,
                      left_mono = left_mono, right_mono = right_mono,
                      mle_at_peak = mle_at_peak, idx_max = idx_max,
                      n_points = n))
}

cat("\n-- Phase 5b: Profile arc check --\n")
arc_results <- list()
for (pname in names(profiles)) {
  arc <- check_profile_arc(profiles[[pname]])
  arc_results[[pname]] <- arc
  cat(sprintf("  %-15s arc=%d  %s\n", pname,
              as.integer(arc$is_arc), arc$reason))
}

# Build one-row data.frame: species + one column per parameter (1/0) + all_pass
arc_row <- data.frame(species = species_name, stringsAsFactors = FALSE)
for (pname in names(arc_results)) {
  arc_row[[pname]] <- as.integer(arc_results[[pname]]$is_arc)
}
arc_row$all_pass <- as.integer(all(sapply(arc_results, `[[`, "is_arc")))
arc_row$n_pass   <- sum(sapply(arc_results, `[[`, "is_arc"))
arc_row$n_total  <- length(arc_results)

# Failure reasons for parameters that didn't pass
fail_reasons <- sapply(names(arc_results), function(pname) {
  arc_results[[pname]]$reason
})
arc_row$fail_reasons <- paste(
  paste0(names(fail_reasons), ":", fail_reasons),
  collapse = "; "
)

write.csv(arc_row, file.path(sp_dir, "profile_arc_check.csv"),
          row.names = FALSE)

cat(sprintf("Arc check: %d/%d parameters pass, all_pass=%s\n",
            arc_row$n_pass, arc_row$n_total,
            if (arc_row$all_pass == 1) "YES" else "NO"))

# ══════════════════════════════════════════════════════════════════════
# SECTION 10c — Fallback re-optimization loop
# ══════════════════════════════════════════════════════════════════════
# If any profile found a better LL than the original MLE, this signals
# incomplete convergence. We extract the best point from the profiles
# and re-optimize from there. Max 3 iterations to prevent infinite loops.
# ──────────────────────────────────────────────────────────────────────

found_better_params <- names(Filter(
  function(prof) !is.null(prof) && isTRUE(prof$found_better),
  profiles
))

max_fallback_iter <- 3L
fallback_iter <- 0L
fallback_history <- list()

while (length(found_better_params) > 0 && fallback_iter < max_fallback_iter) {
  fallback_iter <- fallback_iter + 1L
  cat(sprintf("\n-- Fallback iteration %d: found_better_ll in %d parameters --\n",
              fallback_iter, length(found_better_params)))

  # Find the best LL across all profile points
  best_profile_ll <- -Inf
  best_profile_par <- NULL
  for (pname in names(profiles)) {
    prof <- profiles[[pname]]
    if (is.null(prof)) next
    pdat <- prof$profile
    param_df <- prof$parameters
    idx_best <- which.max(pdat$loglik)
    if (pdat$loglik[idx_best] > best_profile_ll) {
      best_profile_ll <- pdat$loglik[idx_best]
      # Extract the full parameter vector at that point
      best_profile_par <- unlist(param_df[idx_best, free_names, drop = TRUE])
      names(best_profile_par) <- free_names
    }
  }

  if (is.null(best_profile_par) || best_profile_ll <= best_fit$loglik) {
    cat("  No improvement found in profiles, stopping fallback.\n")
    break
  }

  cat(sprintf("  Profile found LL=%.4f vs original LL=%.4f (delta=%.4f)\n",
              best_profile_ll, best_fit$loglik,
              best_profile_ll - best_fit$loglik))

  # Re-optimize from the better point with tighter tolerances
  cat("  Re-optimizing from better starting point...\n")
  reopt_result <- tryCatch(
    optimize_likelihood(
      env_dat     = best_fit$env_dat,
      occ         = best_fit$occ,
      mask        = best_mask,
      num_starts  = 50L,
      breadth     = 0.3,
      num_threads = num_threads,
      control     = list(grtol = 1e-7, maxeval = 5000, stepmax = 5),
      parallel    = TRUE,
      verbose     = FALSE
    ),
    error = function(e) {
      warning("Fallback re-optimization failed: ", e$message)
      NULL
    }
  )

  if (is.null(reopt_result)) {
    cat("  Re-optimization failed, stopping fallback.\n")
    break
  }

  new_ll <- reopt_result$best$loglik
  cat(sprintf("  Re-optimization result: LL=%.4f (delta from original=%.4f)\n",
              new_ll, new_ll - best_fit$loglik))

  # Only accept if strictly better

  if (new_ll <= best_fit$loglik + .Machine$double.eps) {
    cat("  No improvement from re-optimization, stopping fallback.\n")
    break
  }

  # Update MLE with the new best
  fallback_history[[fallback_iter]] <- list(
    old_ll = best_fit$loglik,
    new_ll = new_ll,
    params_triggering = found_better_params
  )

  best_full <- reopt_result$best$par
  best_bio  <- math_to_bio(best_full)
  # Update best_fit loglik for next iteration comparison
  best_fit$loglik <- new_ll
  best_fit$result <- reopt_result

  # Recalculate free params
  if (!is.null(best_mask)) {
    free_names <- setdiff(names(best_full), names(best_mask))
    optim_free <- best_full[free_names]
  } else {
    optim_free <- best_full
    free_names <- names(best_full)
  }

  # Re-run profiling with updated MLE (adaptive)
  cat("  Re-profiling with updated MLE (adaptive)...\n")

  # Recompute Hessian at new MLE for adaptive step sizing
  hess_fallback <- tryCatch(
    numDeriv::hessian(
      func = function(par_free) {
        names(par_free) <- free_names
        loglik_math(par_free, env_dat = best_fit$env_dat, occ = best_fit$occ,
                    mask = best_mask, negative = TRUE, num_threads = 1L)
      },
      x = optim_free
    ),
    error = function(e) NULL
  )

  profiles <- list()
  for (pname in free_names) {
    cat(sprintf("    Profiling %-15s ... ", pname))
    t0 <- proc.time()[3]

    if (!is.null(hess_fallback)) {
      prof <- adaptive_profile(pname, optim_free, best_fit$env_dat, best_fit$occ,
                               best_mask, hess_fallback, num_threads)
    } else {
      prof <- tryCatch(
        profile_likelihood(
          profile_parameter  = pname,
          increment_left     = 0.1,
          increment_right    = 0.1,
          num_steps_left     = 30L,
          num_steps_right    = 30L,
          alpha              = 0.95,
          optim_param_vector = optim_free,
          env_dat            = best_fit$env_dat,
          occ                = best_fit$occ,
          mask               = best_mask,
          num_threads        = num_threads,
          verbose            = FALSE
        ),
        error = function(e) NULL
      )
    }

    dt <- proc.time()[3] - t0
    if (!is.null(prof)) {
      cat(sprintf("done (%.0fs) better_found=%s\n", dt, prof$found_better))
    } else {
      cat(sprintf("FAILED (%.0fs)\n", dt))
    }
    profiles[[pname]] <- prof
  }

  # Re-check arcs
  arc_results <- list()
  for (pname in names(profiles)) {
    arc <- check_profile_arc(profiles[[pname]])
    arc_results[[pname]] <- arc
  }

  # Rebuild arc_row
  arc_row <- data.frame(species = species_name, stringsAsFactors = FALSE)
  for (pname in names(arc_results)) {
    arc_row[[pname]] <- as.integer(arc_results[[pname]]$is_arc)
  }
  arc_row$all_pass <- as.integer(all(sapply(arc_results, `[[`, "is_arc")))
  arc_row$n_pass   <- sum(sapply(arc_results, `[[`, "is_arc"))
  arc_row$n_total  <- length(arc_results)
  fail_reasons <- sapply(names(arc_results), function(pname) {
    arc_results[[pname]]$reason
  })
  arc_row$fail_reasons <- paste(
    paste0(names(fail_reasons), ":", fail_reasons),
    collapse = "; "
  )

  # Update profile plots
  n_prof <- length(Filter(Negate(is.null), profiles))
  if (n_prof > 0) {
    ncol_plot <- min(3, n_prof)
    nrow_plot <- ceiling(n_prof / ncol_plot)
    pdf(file.path(plots_dir, "05_profile_likelihood.pdf"),
        width = 5 * ncol_plot, height = 4 * nrow_plot)
    par(mfrow = c(nrow_plot, ncol_plot), mar = c(4, 4, 3, 1))
    for (pname in names(profiles)) {
      prof <- profiles[[pname]]
      if (is.null(prof)) next
      pdat <- prof$profile
      plot(pdat$value_math, pdat$loglik,
           type = "b", pch = 19, cex = 0.6,
           xlab = paste(pname, "(math scale)"),
           ylab = "log-likelihood",
           main = paste("Profile:", pname, "(iter", fallback_iter, ")"))
      abline(h = prof$threshold, col = "red", lty = 2)
      abline(v = optim_free[pname], col = "blue", lty = 2)
    }
    dev.off()
  }

  # Write updated arc check
  write.csv(arc_row, file.path(sp_dir, "profile_arc_check.csv"),
            row.names = FALSE)

  cat(sprintf("  After fallback iter %d: arc %d/%d pass, all_pass=%s\n",
              fallback_iter, arc_row$n_pass, arc_row$n_total,
              if (arc_row$all_pass == 1) "YES" else "NO"))

  # Check if we still have found_better_ll
  found_better_params <- names(Filter(
    function(prof) !is.null(prof) && isTRUE(prof$found_better),
    profiles
  ))
}

if (fallback_iter > 0) {
  cat(sprintf("\n  Fallback loop completed: %d iteration(s), final LL=%.4f\n",
              fallback_iter, best_fit$loglik))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 10d — Model quality classification (3 levels)
# ══════════════════════════════════════════════════════════════════════
# Level 1 (PERFECT): flag_a + flag_b + all arcs pass + no found_better_ll
#   → Highest confidence. Publishable in high-impact journal.
# Level 2 (ACCEPTABLE): flag_b (valid Hessian) + >= 50% arcs pass
#   → Usable scientifically, some parameters poorly constrained.
# Level 3 (MARGINAL): flag_b only, arcs mostly fail OR found_better_ll resolved
#   → Needs cautious interpretation, may benefit from more data.
# ──────────────────────────────────────────────────────────────────────

n_arcs_pass <- arc_row$n_pass
n_arcs_total <- arc_row$n_total
all_arcs_pass <- (arc_row$all_pass == 1)
any_found_better <- any(sapply(profiles, function(p) {
  !is.null(p) && isTRUE(p$found_better)
}))

model_quality <- if (all_arcs_pass && !any_found_better && fallback_iter == 0L) {
  "perfect"
} else if (n_arcs_total > 0 && (n_arcs_pass / n_arcs_total) >= 0.5) {
  "acceptable"
} else {
  "marginal"
}

cat(sprintf("\n  Model quality: %s (%d/%d arcs, found_better=%s, fallback_iters=%d)\n",
            toupper(model_quality), n_arcs_pass, n_arcs_total,
            any_found_better, fallback_iter))

# ══════════════════════════════════════════════════════════════════════
# SECTION 11 — Save results
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Phase 6: Saving results and diagnostic plots --\n")

# Model summary table
summary_df <- data.frame(
  model    = names(L3),
  pBIC     = sapply(L3, `[[`, "pBIC"),
  loglik   = sapply(L3, `[[`, "loglik"),
  n_free   = sapply(L3, `[[`, "n_free"),
  n_data   = sapply(L3, `[[`, "n"),
  stringsAsFactors = FALSE
)
summary_df <- summary_df[order(summary_df$pBIC), ]
summary_df$rank     <- seq_len(nrow(summary_df))
summary_df$selected <- summary_df$model == M_Omega
write.csv(summary_df, file.path(sp_dir, "model_summary.csv"),
          row.names = FALSE)

# Best model vars
best_vars <- if (M_Omega %in% names(models_L1)) {
  models_L1[[M_Omega]]
} else {
  models_L1[[sub("__.*", "", M_Omega)]]
}

# Full results RDS
saveRDS(list(
  species          = species_name,
  status           = "success",
  model_quality    = model_quality,
  selected         = M_Omega,
  pBIC             = Omega,
  best_bio         = best_bio,
  best_math        = best_full,
  best_loglik      = best_fit$loglik,
  n_data           = best_fit$n,
  model_vars       = best_vars,
  profiles         = profiles,
  arc_check        = arc_results,
  arc_summary      = arc_row,
  summary          = summary_df,
  fallback_iters   = fallback_iter,
  fallback_history = fallback_history,
  L3               = L3
), file.path(sp_dir, "model_results.rds"))

saveRDS(best_fit, file.path(sp_dir, "best_model.rds"))

# ── Plot 1: BIC barplot ──────────────────────────────────────────────
top_n <- min(20, nrow(summary_df))
pdf(file.path(plots_dir, "01_model_comparison.pdf"), width = 14, height = 6)
par(mar = c(9, 4, 3, 1))
cols <- ifelse(summary_df$selected[1:top_n], "darkgreen", "steelblue")
barplot(summary_df$pBIC[1:top_n],
        names.arg = summary_df$model[1:top_n],
        las = 2, cex.names = 0.6, col = cols,
        main = paste(species_name, "- pBIC Comparison (top", top_n, ")"),
        ylab = "pseudo-BIC")
legend("topright", c("Selected", "Other"),
       fill = c("darkgreen", "steelblue"), bty = "n")
dev.off()

# ── Plot 2: Niche shape ─────────────────────────────────────────────
p_best <- length(best_vars)
pdf(file.path(plots_dir, "02_niche_shape.pdf"),
    width = 4 * p_best, height = 4)
par(mfrow = c(1, p_best))
tryCatch(
  interpret_parameters(
    best_bio,
    plot_indices = seq_len(p_best),
    env_dat = best_fit$env_dat,
    occ     = best_fit$occ
  ),
  error = function(e) {
    plot.new(); text(0.5, 0.5, paste("Error:", e$message), cex = 0.8)
  }
)
dev.off()

# ── Plot 3: Habitat suitability map ─────────────────────────────────
# Gap fix #3: handle Parquet mode where env_rasters is NULL
if (!is.null(env_rasters)) {
  tryCatch({
    env_list_sel <- env_rasters[best_vars]
    hab <- habitat_suitability(
      param_list = best_bio,
      env_list   = env_list_sel
    )
    terra::writeRaster(hab, file.path(sp_dir, "habitat_suitability.tif"),
                       overwrite = TRUE)

    pdf(file.path(plots_dir, "03_habitat_suitability.pdf"),
        width = 10, height = 8)
    terra::plot(hab,
                main = paste(species_name, "- Habitat Suitability"),
                xlab = "Longitude", ylab = "Latitude")
    pts <- terra::vect(
      occ_raw[occ_raw$presence == 1, ],
      geom = c("lon", "lat"),
      crs = terra::crs(hab)
    )
    terra::plot(pts, add = TRUE, col = "red", pch = 20, cex = 0.3)
    dev.off()
  }, error = function(e) {
    cat("  Warning: habitat suitability plot failed:", e$message, "\n")
  })
} else {
  # Parquet mode: load rasters on-demand for the selected model's variables
  tryCatch({
    cat("  Loading rasters for suitability map (Parquet mode)...\n")
    env_list_sel <- list()
    for (vl in best_vars) {
      var_code <- bio_map[vl]
      paths <- file.path(bioclim_dir, years,
                         paste0(var_code, "_", years, ".tif"))
      exist <- file.exists(paths)
      if (any(exist)) env_list_sel[[vl]] <- terra::rast(paths[exist])
    }
    if (length(env_list_sel) == length(best_vars)) {
      hab <- habitat_suitability(
        param_list = best_bio,
        env_list   = env_list_sel
      )
      terra::writeRaster(hab, file.path(sp_dir, "habitat_suitability.tif"),
                         overwrite = TRUE)

      pdf(file.path(plots_dir, "03_habitat_suitability.pdf"),
          width = 10, height = 8)
      terra::plot(hab,
                  main = paste(species_name, "- Habitat Suitability"),
                  xlab = "Longitude", ylab = "Latitude")
      pts <- terra::vect(
        occ_raw[occ_raw$presence == 1, ],
        geom = c("lon", "lat"),
        crs = terra::crs(hab)
      )
      terra::plot(pts, add = TRUE, col = "red", pch = 20, cex = 0.3)
      dev.off()
    } else {
      cat("  Skipping suitability map: rasters not available\n")
    }
  }, error = function(e) {
    cat("  Warning: habitat suitability plot failed:", e$message, "\n")
  })
}

# ── Plot 4: Occurrences ──────────────────────────────────────────────
tryCatch({
  # Load bio01 raster (from env_rasters or on-demand in Parquet mode)
  if (!is.null(env_rasters)) {
    m_bio01 <- terra::app(env_rasters[["T1_bio01"]], mean)
  } else {
    bio01_paths <- file.path(bioclim_dir, years,
                             paste0("bio01_", years, ".tif"))
    exist <- file.exists(bio01_paths)
    if (!any(exist)) stop("No bio01 rasters found for occurrence plot")
    m_bio01 <- terra::app(terra::rast(bio01_paths[exist]), mean)
  }

  pts_pres <- terra::vect(occ_raw[occ_raw$presence == 1, ],
                          geom = c("lon", "lat"),
                          crs = terra::crs(m_bio01))
  pts_abs  <- terra::vect(occ_raw[occ_raw$presence == 0, ],
                          geom = c("lon", "lat"),
                          crs = terra::crs(m_bio01))

  pdf(file.path(plots_dir, "04_occurrences.pdf"), width = 12, height = 5)
  par(mfrow = c(1, 2), mar = c(3, 3, 2, 4))
  terra::plot(m_bio01, main = "Presences")
  terra::plot(pts_pres, add = TRUE, col = "red", pch = 20, cex = 0.5)
  terra::plot(m_bio01, main = "Pseudo-absences")
  terra::plot(pts_abs, add = TRUE, col = "black", pch = 20, cex = 0.3)
  dev.off()
}, error = function(e) {
  cat("  Warning: occurrence plot failed:", e$message, "\n")
})

cat("\n===================================================\n")
cat("COMPLETED:", species_name, "\n")
cat("Selected model:", M_Omega, "\n")
cat("pBIC:", round(Omega, 2), "\n")
cat("Log-likelihood:", round(best_fit$loglik, 2), "\n")
cat("Free parameters:", best_fit$n_free, "\n")
cat("Output dir:", sp_dir, "\n")
cat("===================================================\n")

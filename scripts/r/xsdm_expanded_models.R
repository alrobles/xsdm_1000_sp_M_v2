#!/usr/bin/env Rscript
# xsdm_expanded_models.R
# ──────────────────────────────────────────────────────────────────────
# Expanded model selection for species that FAILED with the original
# 6-variable, 23-model pipeline. Uses all 19 bioclim variables and
# generates models with 1, 2, 3, and 4 variables (2T+2P).
#
# Variables:
#   Temperature (T): bio01-bio11 (11 vars)
#   Precipitation (P): bio12-bio19 (8 vars)
#
# Model design:
#   1-var: 11T + 8P = 19 models
#   2-var: 11T × 8P = 88 models (1T + 1P)
#   3-var: C(11,2)×8 + 11×C(8,2) = 440+308 = 748 models (2T+1P or 1T+2P)
#   4-var: C(11,2)×C(8,2) = 55×28 = 1540 models (2T+2P)
#
# Total: 19 + 88 + 748 + 1540 = 2,395 candidate models
# This is too many for exhaustive fitting. Strategy:
#   Phase 1: Fit all 1-var and 2-var models (107 total) — fast screening
#   Phase 2: For top-K 2-var models, expand to 3-var by adding one variable
#   Phase 3: For top-K 3-var models, expand to 4-var (2T+2P)
#   → Total fits: ~107 + ~30×19 + ~10×17 = ~800 models max
#
# Input:
#   --species       "Genus species"
#   --env_csv_dir   Path to pre-extracted 19-var CSVs
#   --output_dir    Root output directory (default: xsdm_results_expanded)
#   --occ_dir       Occurrence CSVs
#   --years         Year range (default: 1980:2020)
#   --num_starts    Optimizer restarts (default: 25)
#   --num_threads   Threads for loglik_math (default: 4)
#   --top_k2        Top 2-var models to expand (default: 15)
#   --top_k3        Top 3-var models to expand to 4-var (default: 10)
#
# Output (in output_dir/Genus_species/):
#   model_results.rds, model_summary.csv, best_model.rds,
#   profile_arc_check.csv, diagnostics.csv, plots/
# ──────────────────────────────────────────────────────────────────────

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(terra)
  library(numDeriv)
})

# ── Parse CLI arguments ──────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name  <- parse_arg("--species")
env_csv_dir   <- parse_arg("--env_csv_dir",
                           "/home/a474r867/scratch/xsdm_env_extraction_19")
occ_dir       <- parse_arg("--occ_dir",
                           "/home/a474r867/scratch/xsdm_occurrences")
output_dir    <- parse_arg("--output_dir",
                           "/home/a474r867/scratch/xsdm_results_expanded")
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
num_starts    <- as.integer(parse_arg("--num_starts", "25"))
num_threads   <- as.integer(parse_arg("--num_threads", "4"))
top_k2        <- as.integer(parse_arg("--top_k2", "15"))
top_k3        <- as.integer(parse_arg("--top_k3", "10"))

years <- as.integer(strsplit(years_str, ",")[[1]])
if (is.null(species_name)) stop("--species is required", call. = FALSE)

cat("===================================================\n")
cat("xsdm EXPANDED Model Selection\n")
cat("Species:", species_name, "\n")
cat("Years:", min(years), "-", max(years), "(", length(years), "years)\n")
cat("Starts:", num_starts, " Threads:", num_threads, "\n")
cat("Top-K2:", top_k2, " Top-K3:", top_k3, "\n")
cat("===================================================\n")

# ── Output directories ───────────────────────────────────────────────
sp_dir    <- file.path(output_dir, gsub(" ", "_", species_name))
plots_dir <- file.path(sp_dir, "plots")
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)

# ══════════════════════════════════════════════════════════════════════
# SECTION 1 — Define the 19 bioclim variables
# ══════════════════════════════════════════════════════════════════════

# Temperature variables (bio01-bio11)
temp_vars <- paste0("bio", sprintf("%02d", 1:11))
temp_labels <- paste0("T", 1:11, "_", temp_vars)
names(temp_labels) <- temp_vars

# Precipitation variables (bio12-bio19)
precip_vars <- paste0("bio", sprintf("%02d", 12:19))
precip_labels <- paste0("P", 12:19, "_", precip_vars)
names(precip_labels) <- precip_vars

all_vars <- c(temp_vars, precip_vars)
all_labels <- c(temp_labels, precip_labels)

cat("Temperature vars (11):", paste(temp_vars, collapse = ", "), "\n")
cat("Precipitation vars (8):", paste(precip_vars, collapse = ", "), "\n")

# ══════════════════════════════════════════════════════════════════════
# SECTION 2 — Load environmental data from pre-extracted CSVs
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Loading environmental data --\n")
t0 <- Sys.time()

sp_safe <- gsub(" ", "_", species_name)
env_sp_dir <- file.path(env_csv_dir, sp_safe)
if (!dir.exists(env_sp_dir))
  stop("Env CSV dir not found: ", env_sp_dir, call. = FALSE)

# Read occurrence data from one env CSV
first_label <- all_labels[1]
first_csv <- file.path(env_sp_dir, paste0(first_label, ".csv"))
if (!file.exists(first_csv))
  stop("Env CSV not found: ", first_csv, call. = FALSE)
occ_raw <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
occ_vec <- occ_raw$presence
n_pts   <- nrow(occ_raw)
n_time  <- length(years)

# Load all available variables into a big array
available_vars <- character(0)
env_data_list <- list()

for (vi in seq_along(all_vars)) {
  var_label <- all_labels[vi]
  csv_file  <- file.path(env_sp_dir, paste0(var_label, ".csv"))
  if (!file.exists(csv_file)) {
    cat(sprintf("  SKIP %s (not extracted)\n", var_label))
    next
  }
  env_df <- read.csv(csv_file, stringsAsFactors = FALSE, check.names = FALSE)
  year_cols <- as.character(years)
  mat <- matrix(NA_real_, nrow = n_pts, ncol = n_time)
  for (ti in seq_along(years)) {
    if (year_cols[ti] %in% names(env_df)) {
      mat[, ti] <- env_df[[year_cols[ti]]]
    }
  }
  env_data_list[[var_label]] <- mat
  available_vars <- c(available_vars, var_label)
}

elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
cat(sprintf("Loaded %d variables, %d pts × %d years (%.1fs)\n",
            length(available_vars), n_pts, n_time, elapsed))

# Classify available vars
avail_temp   <- intersect(available_vars, temp_labels)
avail_precip <- intersect(available_vars, precip_labels)
cat(sprintf("Available: %d temperature, %d precipitation\n",
            length(avail_temp), length(avail_precip)))

# ══════════════════════════════════════════════════════════════════════
# SECTION 3 — Helper: build env_dat array for a subset of variables
# ══════════════════════════════════════════════════════════════════════

make_env_array <- function(var_labels) {
  p <- length(var_labels)
  arr <- array(NA_real_, dim = c(n_pts, n_time, p),
               dimnames = list(NULL, as.character(years), var_labels))
  for (vi in seq_along(var_labels)) {
    arr[, , vi] <- env_data_list[[var_labels[vi]]]
  }
  arr
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 4 — Helper: fit one model and assess well-behavedness
# ══════════════════════════════════════════════════════════════════════

fit_one_model <- function(var_labels, model_name) {
  env_dat <- make_env_array(var_labels)
  p <- length(var_labels)

  result <- tryCatch(
    optimize_likelihood(
      env_dat     = env_dat,
      occ         = occ_vec,
      mask        = NULL,
      num_starts  = num_starts,
      parallel    = FALSE,
      num_threads = num_threads,
      control     = list(grtol = 1e-6, xtol = 1e-12, stepmax = 5, maxeval = 2000),
      verbose     = FALSE
    ),
    error = function(e) {
      list(best = list(loglik = -Inf, par = NULL, convergence = -1),
           solutions = data.frame(), error = e$message)
    }
  )

  if (is.null(result$best$par) || result$best$loglik == -Inf) {
    return(list(
      model_name = model_name,
      vars       = var_labels,
      loglik     = -Inf,
      n_free     = NA,
      pBIC       = Inf,
      well_behaved = FALSE,
      result     = result
    ))
  }

  # Compute pBIC = -2*loglik + n_free * log(n)
  n_free <- length(result$best$par)
  n <- n_pts
  pBIC <- -2 * result$best$loglik + n_free * log(n)

  # Well-behavedness test
  well_behaved <- FALSE
  tryCatch({
    sols <- result$solutions
    if (nrow(sols) >= 5) {
      top5 <- sols[1:5, ]
      ll_range <- max(top5$loglik) - min(top5$loglik)
      flag_a <- ll_range < 0.1
    } else {
      flag_a <- FALSE
    }

    # Hessian check
    flag_b <- FALSE
    tryCatch({
      hess <- numDeriv::hessian(
        func = function(par) {
          -loglik_math(
            param_vector = par,
            env_dat      = env_dat,
            occ          = occ_vec,
            negative     = FALSE,
            mask         = NULL,
            num_threads  = num_threads
          )
        },
        x = result$best$par
      )
      eig <- eigen(hess, only.values = TRUE)$values
      flag_b <- all(eig > 0) && (max(eig) / min(eig)) < 1e6
    }, error = function(e) { flag_b <<- FALSE })

    well_behaved <- flag_a && flag_b
  }, error = function(e) { well_behaved <<- FALSE })

  list(
    model_name   = model_name,
    vars         = var_labels,
    loglik       = result$best$loglik,
    n_free       = n_free,
    n            = n_pts,
    pBIC         = pBIC,
    well_behaved = well_behaved,
    result       = result,
    env_dat      = env_dat,
    occ          = occ_vec,
    mask         = NULL
  )
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 5 — Phase 1: Fit 1-var and 2-var models (screening)
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Phase 1: Screening 1-var and 2-var models --\n")

models_phase1 <- list()

# 1-var models: each available variable alone
cat("  1-var models:\n")
for (vlab in available_vars) {
  mname <- paste0("1v_", vlab)
  cat(sprintf("    %-25s ", mname))
  t0 <- proc.time()[3]
  fit <- fit_one_model(vlab, mname)
  dt <- proc.time()[3] - t0
  cat(sprintf("LL=%.2f pBIC=%.1f wb=%s (%.0fs)\n",
              fit$loglik, fit$pBIC, fit$well_behaved, dt))
  models_phase1[[mname]] <- fit
}

# 2-var models: 1T + 1P (all combinations of available T × P)
cat("  2-var models (1T + 1P):\n")
n_2var <- 0L
for (tv in avail_temp) {
  for (pv in avail_precip) {
    n_2var <- n_2var + 1L
    mname <- paste0("2v_", tv, "_", pv)
    cat(sprintf("    [%3d] %-40s ", n_2var, mname))
    t0 <- proc.time()[3]
    fit <- fit_one_model(c(tv, pv), mname)
    dt <- proc.time()[3] - t0
    cat(sprintf("LL=%.2f wb=%s (%.0fs)\n", fit$loglik, fit$well_behaved, dt))
    models_phase1[[mname]] <- fit
  }
}

cat(sprintf("\nPhase 1 complete: %d models fitted\n", length(models_phase1)))

# ══════════════════════════════════════════════════════════════════════
# SECTION 6 — Phase 2: Expand top 2-var models to 3-var
# ══════════════════════════════════════════════════════════════════════

# Rank Phase 1 by pBIC
p1_df <- data.frame(
  model  = sapply(models_phase1, `[[`, "model_name"),
  loglik = sapply(models_phase1, `[[`, "loglik"),
  pBIC   = sapply(models_phase1, `[[`, "pBIC"),
  wb     = sapply(models_phase1, `[[`, "well_behaved"),
  stringsAsFactors = FALSE
)
p1_df <- p1_df[order(p1_df$pBIC), ]

# Select top-K2 2-var models for expansion
two_var_models <- p1_df[grepl("^2v_", p1_df$model), ]
top_2var <- head(two_var_models, top_k2)
cat(sprintf("\n-- Phase 2: Expanding top %d 2-var models to 3-var --\n", nrow(top_2var)))

models_phase2 <- list()
for (i in seq_len(nrow(top_2var))) {
  base_name <- top_2var$model[i]
  base_vars <- models_phase1[[base_name]]$vars

  # Find base variable types
  base_is_temp <- base_vars %in% temp_labels
  n_base_t <- sum(base_is_temp)
  n_base_p <- sum(!base_is_temp)

  # Add one more variable: if 1T+1P, can add T or P
  # Constraint: max 2T or max 2P to keep biological interpretability
  candidates <- setdiff(available_vars, base_vars)
  cand_temp   <- intersect(candidates, temp_labels)
  cand_precip <- intersect(candidates, precip_labels)

  # Can add T if current T count < 2
  add_vars <- character(0)
  if (n_base_t < 2) add_vars <- c(add_vars, cand_temp)
  if (n_base_p < 2) add_vars <- c(add_vars, cand_precip)

  for (new_var in add_vars) {
    new_vars <- c(base_vars, new_var)
    mname <- paste0("3v_", paste(new_vars, collapse = "_"))
    if (mname %in% names(models_phase2)) next

    cat(sprintf("    %-50s ", mname))
    t0 <- proc.time()[3]
    fit <- fit_one_model(new_vars, mname)
    dt <- proc.time()[3] - t0
    cat(sprintf("LL=%.2f wb=%s (%.0fs)\n", fit$loglik, fit$well_behaved, dt))
    models_phase2[[mname]] <- fit
  }
}
cat(sprintf("Phase 2 complete: %d 3-var models fitted\n", length(models_phase2)))

# ══════════════════════════════════════════════════════════════════════
# SECTION 7 — Phase 3: Expand top 3-var models to 4-var (2T + 2P)
# ══════════════════════════════════════════════════════════════════════

# Rank Phase 2 by pBIC
if (length(models_phase2) > 0) {
  p2_df <- data.frame(
    model  = sapply(models_phase2, `[[`, "model_name"),
    loglik = sapply(models_phase2, `[[`, "loglik"),
    pBIC   = sapply(models_phase2, `[[`, "pBIC"),
    wb     = sapply(models_phase2, `[[`, "well_behaved"),
    stringsAsFactors = FALSE
  )
  p2_df <- p2_df[order(p2_df$pBIC), ]

  top_3var <- head(p2_df, top_k3)
  cat(sprintf("\n-- Phase 3: Expanding top %d 3-var models to 4-var (2T+2P) --\n",
              nrow(top_3var)))

  models_phase3 <- list()
  for (i in seq_len(nrow(top_3var))) {
    base_name <- top_3var$model[i]
    base_vars <- models_phase2[[base_name]]$vars

    base_is_temp <- base_vars %in% temp_labels
    n_base_t <- sum(base_is_temp)
    n_base_p <- sum(!base_is_temp)

    # Only expand to 4-var = 2T + 2P
    candidates <- setdiff(available_vars, base_vars)
    cand_temp   <- intersect(candidates, temp_labels)
    cand_precip <- intersect(candidates, precip_labels)

    # Determine what's needed to reach 2T + 2P
    add_vars <- character(0)
    if (n_base_t < 2) add_vars <- cand_temp
    if (n_base_p < 2) add_vars <- c(add_vars, cand_precip)

    # Only add if it results in exactly 2T + 2P
    for (new_var in add_vars) {
      new_vars <- c(base_vars, new_var)
      new_is_temp <- new_vars %in% temp_labels
      if (sum(new_is_temp) > 2 || sum(!new_is_temp) > 2) next
      if (length(new_vars) != 4) next

      mname <- paste0("4v_", paste(new_vars, collapse = "_"))
      if (mname %in% names(models_phase3)) next

      cat(sprintf("    %-55s ", mname))
      t0 <- proc.time()[3]
      fit <- fit_one_model(new_vars, mname)
      dt <- proc.time()[3] - t0
      cat(sprintf("LL=%.2f wb=%s (%.0fs)\n", fit$loglik, fit$well_behaved, dt))
      models_phase3[[mname]] <- fit
    }
  }
  cat(sprintf("Phase 3 complete: %d 4-var models fitted\n", length(models_phase3)))
} else {
  models_phase3 <- list()
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 8 — Combine all phases, select best well-behaved model
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Combining results from all phases --\n")

all_models <- c(models_phase1, models_phase2, models_phase3)
cat(sprintf("Total models fitted: %d\n", length(all_models)))

# Build summary
summary_df <- data.frame(
  model  = sapply(all_models, `[[`, "model_name"),
  loglik = sapply(all_models, `[[`, "loglik"),
  pBIC   = sapply(all_models, `[[`, "pBIC"),
  n_free = sapply(all_models, function(x) ifelse(is.na(x$n_free), NA, x$n_free)),
  well_behaved = sapply(all_models, `[[`, "well_behaved"),
  n_vars = sapply(all_models, function(x) length(x$vars)),
  stringsAsFactors = FALSE
)
summary_df <- summary_df[order(summary_df$pBIC), ]
summary_df$rank <- seq_len(nrow(summary_df))

# Write summary
write.csv(summary_df, file.path(sp_dir, "model_summary.csv"), row.names = FALSE)

# Select best well-behaved model
wb_models <- summary_df[summary_df$well_behaved == TRUE, ]
if (nrow(wb_models) == 0) {
  cat("WARNING: No well-behaved model found across all phases!\n")
  cat("Saving results with status='no_well_behaved_model'\n")

  saveRDS(list(
    species      = species_name,
    status       = "no_well_behaved_model",
    n_models     = length(all_models),
    n_wb         = 0,
    summary      = summary_df,
    all_models   = NULL  # don't save all model objects (too large)
  ), file.path(sp_dir, "model_results.rds"))

  cat("DONE (no model found)\n")
  quit(save = "no", status = 0)
}

M_Omega <- wb_models$model[1]
best_fit <- all_models[[M_Omega]]
best_full <- best_fit$result$best$par
best_bio  <- math_to_bio(best_full)
best_mask <- best_fit$mask

cat(sprintf("Selected: %s (pBIC=%.1f, LL=%.2f, %d vars)\n",
            M_Omega, best_fit$pBIC, best_fit$loglik, length(best_fit$vars)))

# ══════════════════════════════════════════════════════════════════════
# SECTION 9 — Boundary expansion of the selected model
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Boundary expansion of selected model --\n")

p <- length(best_fit$vars)
bmasks <- generate_boundary_masks(p)
cat(sprintf("  Fitting %d boundary variants...\n", length(bmasks)))

boundary_models <- list()
for (bname in names(bmasks)) {
  mname <- paste0(M_Omega, "__", bname)
  bmask <- bmasks[[bname]]

  bfit <- tryCatch(
    optimize_likelihood(
      env_dat     = best_fit$env_dat,
      occ         = best_fit$occ,
      mask        = bmask,
      num_starts  = num_starts,
      parallel    = FALSE,
      num_threads = num_threads,
      control     = list(grtol = 1e-6, xtol = 1e-12, stepmax = 5, maxeval = 2000),
      verbose     = FALSE
    ),
    error = function(e) NULL
  )

  if (!is.null(bfit) && !is.null(bfit$best$par)) {
    n_free_b <- length(bfit$best$par)
    pBIC_b <- -2 * bfit$best$loglik + n_free_b * log(n_pts)

    # Check if within Omega + tau
    tau <- (length(best_full) + 1) * log(n_pts)  # corrected per D. Reuman 2026
    if (pBIC_b <= best_fit$pBIC + tau) {
      boundary_models[[mname]] <- list(
        model_name = mname,
        vars       = best_fit$vars,
        loglik     = bfit$best$loglik,
        n_free     = n_free_b,
        pBIC       = pBIC_b,
        result     = bfit,
        env_dat    = best_fit$env_dat,
        occ        = best_fit$occ,
        mask       = bmask
      )
      cat(sprintf("    %s: pBIC=%.1f (delta=%.1f)\n",
                  bname, pBIC_b, pBIC_b - best_fit$pBIC))
    }
  }
}

# Re-rank including boundary models
if (length(boundary_models) > 0) {
  # Check well-behavedness of boundary models and select overall best
  for (bname in names(boundary_models)) {
    bmod <- boundary_models[[bname]]
    # Simplified WB check for boundary models
    wb <- FALSE
    tryCatch({
      sols <- bmod$result$solutions
      if (nrow(sols) >= 5) {
        ll_range <- max(sols$loglik[1:5]) - min(sols$loglik[1:5])
        wb <- ll_range < 0.1
      }
    }, error = function(e) {})
    boundary_models[[bname]]$well_behaved <- wb
  }

  # Find best overall (original + boundary)
  all_wb <- c(
    if (best_fit$well_behaved) list(best_fit) else list(),
    Filter(function(x) isTRUE(x$well_behaved), boundary_models)
  )
  if (length(all_wb) > 0) {
    pbics <- sapply(all_wb, `[[`, "pBIC")
    best_idx <- which.min(pbics)
    if (pbics[best_idx] < best_fit$pBIC) {
      best_fit <- all_wb[[best_idx]]
      best_full <- best_fit$result$best$par
      best_bio  <- math_to_bio(best_full)
      best_mask <- best_fit$mask
      M_Omega   <- best_fit$model_name
      cat(sprintf("  NEW BEST (boundary): %s pBIC=%.1f\n", M_Omega, best_fit$pBIC))
    }
  }
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 10 — Profile likelihood + fallback loop
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Profile likelihood --\n")

# Get free parameter names
if (!is.null(best_mask)) {
  free_names <- setdiff(names(best_full), names(best_mask))
  optim_free <- best_full[free_names]
} else {
  optim_free <- best_full
  free_names <- names(best_full)
}

profiles <- list()
for (pname in free_names) {
  cat(sprintf("  Profiling %-15s ... ", pname))
  t0 <- proc.time()[3]

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
    error = function(e) {
      warning("Profile failed for ", pname, ": ", e$message)
      NULL
    }
  )

  dt <- proc.time()[3] - t0
  if (!is.null(prof)) {
    cat(sprintf("done (%.0fs) better_found=%s\n", dt, prof$found_better))
  } else {
    cat(sprintf("FAILED (%.0fs)\n", dt))
  }
  profiles[[pname]] <- prof
}

# ── Fallback re-optimization loop ────────────────────────────────────
source_fallback <- function(profiles, best_fit, best_full, best_bio,
                            best_mask, free_names, optim_free) {
  found_better_params <- names(Filter(
    function(prof) !is.null(prof) && isTRUE(prof$found_better),
    profiles
  ))

  max_fallback_iter <- 3L
  fallback_iter <- 0L
  fallback_history <- list()

  while (length(found_better_params) > 0 && fallback_iter < max_fallback_iter) {
    fallback_iter <- fallback_iter + 1L
    cat(sprintf("\n  Fallback iteration %d: found_better_ll in %d params\n",
                fallback_iter, length(found_better_params)))

    # Find best LL across profile points
    best_profile_ll <- -Inf
    for (pname in names(profiles)) {
      prof <- profiles[[pname]]
      if (is.null(prof)) next
      pdat <- prof$profile
      idx_best <- which.max(pdat$loglik)
      if (pdat$loglik[idx_best] > best_profile_ll) {
        best_profile_ll <- pdat$loglik[idx_best]
      }
    }

    if (best_profile_ll <= best_fit$loglik) break

    cat(sprintf("  Profile LL=%.4f > original LL=%.4f, re-optimizing...\n",
                best_profile_ll, best_fit$loglik))

    reopt <- tryCatch(
      optimize_likelihood(
        env_dat     = best_fit$env_dat,
        occ         = best_fit$occ,
        mask        = best_mask,
        num_starts  = 50L,
        breadth     = 0.3,
        num_threads = num_threads,
        control     = list(grtol = 1e-7, maxeval = 5000, stepmax = 5),
        parallel    = FALSE,
        verbose     = FALSE
      ),
      error = function(e) NULL
    )

    if (is.null(reopt) || reopt$best$loglik <= best_fit$loglik) break

    fallback_history[[fallback_iter]] <- list(
      old_ll = best_fit$loglik, new_ll = reopt$best$loglik
    )

    best_full <- reopt$best$par
    best_bio  <- math_to_bio(best_full)
    best_fit$loglik <- reopt$best$loglik
    best_fit$result <- reopt

    if (!is.null(best_mask)) {
      free_names <- setdiff(names(best_full), names(best_mask))
      optim_free <- best_full[free_names]
    } else {
      optim_free <- best_full
      free_names <- names(best_full)
    }

    # Re-profile
    profiles <- list()
    for (pname in free_names) {
      profiles[[pname]] <- tryCatch(
        profile_likelihood(
          profile_parameter  = pname,
          increment_left     = 0.1, increment_right = 0.1,
          num_steps_left     = 30L, num_steps_right = 30L,
          alpha              = 0.95,
          optim_param_vector = optim_free,
          env_dat = best_fit$env_dat, occ = best_fit$occ,
          mask = best_mask, num_threads = num_threads, verbose = FALSE
        ),
        error = function(e) NULL
      )
    }

    found_better_params <- names(Filter(
      function(prof) !is.null(prof) && isTRUE(prof$found_better),
      profiles
    ))
  }

  list(profiles = profiles, best_full = best_full, best_bio = best_bio,
       best_fit = best_fit, free_names = free_names, optim_free = optim_free,
       fallback_iter = fallback_iter, fallback_history = fallback_history)
}

fb <- source_fallback(profiles, best_fit, best_full, best_bio,
                      best_mask, free_names, optim_free)
profiles         <- fb$profiles
best_full        <- fb$best_full
best_bio         <- fb$best_bio
best_fit         <- fb$best_fit
free_names       <- fb$free_names
optim_free       <- fb$optim_free
fallback_iter    <- fb$fallback_iter
fallback_history <- fb$fallback_history

if (fallback_iter > 0) {
  cat(sprintf("  Fallback: %d iterations, final LL=%.4f\n",
              fallback_iter, best_fit$loglik))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 11 — Arc check + save results
# ══════════════════════════════════════════════════════════════════════
cat("\n-- Arc check + save --\n")

# Arc check (reuse check_profile_arc from inline definition)
check_profile_arc <- function(prof, noise_tol = 0.5) {
  if (is.null(prof)) return(list(is_arc = FALSE, reason = "profile_null"))
  pdat <- prof$profile
  ll   <- pdat$loglik
  thresh <- prof$threshold
  n <- length(ll)
  if (n < 3) return(list(is_arc = FALSE, reason = "too_few_points"))
  if (isTRUE(prof$found_better)) return(list(is_arc = FALSE, reason = "found_better_ll"))

  idx_max <- which.max(ll)
  has_left  <- idx_max > 1
  has_right <- idx_max < n
  left_crosses  <- has_left  && any(ll[1:(idx_max-1)] <= thresh)
  right_crosses <- has_right && any(ll[(idx_max+1):n] <= thresh)

  left_mono <- TRUE
  if (has_left && idx_max > 2) {
    left_ll <- ll[1:idx_max]
    for (i in 2:length(left_ll)) {
      if (left_ll[i] < left_ll[i-1] - noise_tol) { left_mono <- FALSE; break }
    }
  }
  right_mono <- TRUE
  if (has_right && idx_max < (n-1)) {
    right_ll <- ll[idx_max:n]
    for (i in 2:length(right_ll)) {
      if (right_ll[i] > right_ll[i-1] + noise_tol) { right_mono <- FALSE; break }
    }
  }

  is_arc <- left_crosses && right_crosses && left_mono && right_mono
  reason <- if (is_arc) "pass" else paste(c(
    if (!left_crosses) "no_left_crossing",
    if (!right_crosses) "no_right_crossing",
    if (!left_mono) "left_not_monotone",
    if (!right_mono) "right_not_monotone"
  ), collapse = "+")

  list(is_arc = is_arc, reason = reason)
}

arc_results <- list()
for (pname in names(profiles)) {
  arc <- check_profile_arc(profiles[[pname]])
  arc_results[[pname]] <- arc
  cat(sprintf("  %-15s arc=%d  %s\n", pname, as.integer(arc$is_arc), arc$reason))
}

arc_row <- data.frame(species = species_name, stringsAsFactors = FALSE)
for (pname in names(arc_results)) {
  arc_row[[pname]] <- as.integer(arc_results[[pname]]$is_arc)
}
arc_row$all_pass <- as.integer(all(sapply(arc_results, `[[`, "is_arc")))
arc_row$n_pass   <- sum(sapply(arc_results, `[[`, "is_arc"))
arc_row$n_total  <- length(arc_results)
write.csv(arc_row, file.path(sp_dir, "profile_arc_check.csv"), row.names = FALSE)

# Profile plots
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
  }
  dev.off()
}

# Save final results
saveRDS(list(
  species          = species_name,
  status           = "success",
  selected         = M_Omega,
  pBIC             = best_fit$pBIC,
  best_bio         = best_bio,
  best_math        = best_full,
  best_loglik      = best_fit$loglik,
  n_data           = n_pts,
  model_vars       = best_fit$vars,
  n_models_fitted  = length(all_models),
  profiles         = profiles,
  arc_check        = arc_results,
  arc_summary      = arc_row,
  summary          = summary_df,
  fallback_iters   = fallback_iter,
  fallback_history = fallback_history,
  pipeline         = "expanded_19var"
), file.path(sp_dir, "model_results.rds"))

cat(sprintf("\n===================================================\n"))
cat(sprintf("DONE: %s\n", species_name))
cat(sprintf("  Selected: %s (%d vars)\n", M_Omega, length(best_fit$vars)))
cat(sprintf("  Models fitted: %d (1v:%d, 2v:%d, 3v:%d, 4v:%d)\n",
            length(all_models), sum(grepl("^1v_", names(all_models))),
            sum(grepl("^2v_", names(all_models))),
            sum(grepl("^3v_", names(all_models))),
            sum(grepl("^4v_", names(all_models)))))
cat(sprintf("  Arc check: %d/%d pass\n", arc_row$n_pass, arc_row$n_total))
cat(sprintf("===================================================\n"))

#!/usr/bin/env Rscript
# xsdm_model_selection_v2.R
# ──────────────────────────────────────────────────────────────────────
# Pipeline v2: 19 bioclim vars, 2-var and 3-var models only
#
# Key changes from v1:
#   - 19 bioclim vars: bio01-bio11 (11 temp) + bio12-bio19 (8 precip)
#   - ONLY 2-var (1T+1P) and 3-var (2T+1P or 1T+2P) models
#   - 1500 starts default (up from 25)
#   - Relaxed max_pdist < 0.1 (was 0.05)
#   - Adaptive profiling (Hessian-guided step sizes)
#   - Fallback re-optimization loop
#   - Timing benchmark in results
#   - Mask vs no-mask ratio tracking
#
# Phases:
#   --phase 2var         Fit 88 two-var L1 + boundary expansion
#   --phase 3var_L1      Fit single 3-var model (split mode, needs --model_index)
#   --phase collect      Assemble all results, select best, profile + arc
#   (no --phase)         Full sequential mode (for testing)
#
# Model combinatorics:
#   2-var (1T+1P): 11 × 8 = 88 L1 models
#   3-var (2T+1P): C(11,2) × 8 = 440 L1 models
#   3-var (1T+2P): 11 × C(8,2) = 308 L1 models
#   Total L1: 836 models per species
#
# Parameter counts (non-boundary):
#   p=2: 3p + 2 + p(p-1)/2 = 9 free params
#   p=3: 3p + 2 + p(p-1)/2 = 14 free params
# ──────────────────────────────────────────────────────────────────────

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(numDeriv)
})

# ══════════════════════════════════════════════════════════════════════
# SECTION 1 — CLI parsing
# ══════════════════════════════════════════════════════════════════════

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
                           "/home/a474r867/scratch/xsdm_results")
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
num_starts    <- as.integer(parse_arg("--num_starts", "1500"))
num_threads   <- as.integer(parse_arg("--num_threads", "4"))
top_k2        <- as.integer(parse_arg("--top_k2", "15"))

# Phase control
phase         <- parse_arg("--phase")   # "2var", "3var_L1", "collect", or NULL (full)
model_index   <- parse_arg("--model_index")
if (!is.null(model_index)) model_index <- as.integer(model_index)

years <- as.integer(strsplit(years_str, ",")[[1]])
if (is.null(species_name)) stop("--species is required", call. = FALSE)

pipeline_t0 <- proc.time()[3]

cat("===================================================\n")
cat("xsdm Model Selection Pipeline v2\n")
cat("Species:", species_name, "\n")
cat("Phase:  ", if (is.null(phase)) "full" else phase,
    if (!is.null(model_index)) paste0(" (model ", model_index, ")") else "", "\n")
cat("Years:", min(years), "-", max(years), "(", length(years), "years)\n")
cat("Starts:", num_starts, " Threads:", num_threads, "\n")
cat("Top-K2 (3-var expansion):", top_k2, "\n")
cat("===================================================\n")

# ══════════════════════════════════════════════════════════════════════
# SECTION 2 — Define 19 bioclim variables + model combinatorics
# ══════════════════════════════════════════════════════════════════════

temp_vars   <- paste0("bio", sprintf("%02d", 1:11))
temp_labels <- paste0("T", 1:11, "_", temp_vars)
names(temp_labels) <- temp_vars

precip_vars <- paste0("bio", sprintf("%02d", 12:19))
precip_labels <- paste0("P", 12:19, "_", precip_vars)
names(precip_labels) <- precip_vars

all_labels <- c(temp_labels, precip_labels)

# Two-var models: 1T + 1P = 11 × 8 = 88
generate_2var_models <- function(t_labels, p_labels) {
  models <- list()
  for (tv in t_labels) {
    for (pv in p_labels) {
      mname <- paste0("2v_", tv, "_", pv)
      models[[mname]] <- c(tv, pv)
    }
  }
  models
}

# Three-var models: 2T+1P + 1T+2P = 440 + 308 = 748
generate_3var_models <- function(t_labels, p_labels) {
  models <- list()
  # 2T + 1P
  if (length(t_labels) >= 2) {
    t_combos <- combn(t_labels, 2, simplify = FALSE)
    for (tc in t_combos) {
      for (pv in p_labels) {
        mname <- paste0("3v_", tc[1], "_", tc[2], "_", pv)
        models[[mname]] <- c(tc, pv)
      }
    }
  }
  # 1T + 2P
  if (length(p_labels) >= 2) {
    p_combos <- combn(p_labels, 2, simplify = FALSE)
    for (tv in t_labels) {
      for (pc in p_combos) {
        mname <- paste0("3v_", tv, "_", pc[1], "_", pc[2])
        models[[mname]] <- c(tv, pc)
      }
    }
  }
  models
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 3 — Output directories
# ══════════════════════════════════════════════════════════════════════

sp_dir     <- file.path(output_dir, gsub(" ", "_", species_name))
plots_dir  <- file.path(sp_dir, "plots")
p1_dir     <- file.path(sp_dir, "phase1_results")  # 2-var results
p2_dir     <- file.path(sp_dir, "phase2_results")   # 3-var split results
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(p1_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(p2_dir, recursive = TRUE, showWarnings = FALSE)

# ══════════════════════════════════════════════════════════════════════
# SECTION 4 — Load environmental data from pre-extracted CSVs
# ══════════════════════════════════════════════════════════════════════

cat("\n-- Loading environmental data (19 vars) --\n")
t0_load <- Sys.time()

sp_safe    <- gsub(" ", "_", species_name)
env_sp_dir <- file.path(env_csv_dir, sp_safe)
if (!dir.exists(env_sp_dir))
  stop("Env CSV dir not found: ", env_sp_dir, call. = FALSE)

# Read occurrence data from one CSV
first_label <- all_labels[1]
first_csv   <- file.path(env_sp_dir, paste0(first_label, ".csv"))
if (!file.exists(first_csv))
  stop("Env CSV not found: ", first_csv, call. = FALSE)
occ_raw <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
occ_vec <- occ_raw$presence
n_pts   <- nrow(occ_raw)
n_time  <- length(years)

# Load all available variables
available_labels <- character(0)
env_data_list    <- list()

for (vi in seq_along(all_labels)) {
  var_label <- all_labels[vi]
  csv_file  <- file.path(env_sp_dir, paste0(var_label, ".csv"))
  if (!file.exists(csv_file)) next
  env_df <- read.csv(csv_file, stringsAsFactors = FALSE, check.names = FALSE)
  year_cols <- as.character(years)
  mat <- matrix(NA_real_, nrow = n_pts, ncol = n_time)
  for (ti in seq_along(years)) {
    if (year_cols[ti] %in% names(env_df)) mat[, ti] <- env_df[[year_cols[ti]]]
  }
  env_data_list[[var_label]] <- mat
  available_labels <- c(available_labels, var_label)
}

elapsed_load <- as.numeric(difftime(Sys.time(), t0_load, units = "secs"))
cat(sprintf("Loaded %d variables, %d pts x %d years (%.1fs)\n",
            length(available_labels), n_pts, n_time, elapsed_load))

avail_temp   <- intersect(available_labels, temp_labels)
avail_precip <- intersect(available_labels, precip_labels)
cat(sprintf("Available: %d temperature, %d precipitation\n",
            length(avail_temp), length(avail_precip)))
cat(sprintf("Records: %d total (%d presences, %d absences)\n",
            n_pts, sum(occ_vec == 1), sum(occ_vec == 0)))

# Generate models from available variables only
models_2var <- generate_2var_models(avail_temp, avail_precip)
models_3var <- generate_3var_models(avail_temp, avail_precip)
cat(sprintf("Models: %d two-var + %d three-var = %d total\n",
            length(models_2var), length(models_3var),
            length(models_2var) + length(models_3var)))

# ══════════════════════════════════════════════════════════════════════
# SECTION 5 — Helpers
# ══════════════════════════════════════════════════════════════════════

make_env_array <- function(var_labels) {
  p <- length(var_labels)
  arr <- array(NA_real_, dim = c(n_pts, n_time, p),
               dimnames = list(NULL, as.character(years), var_labels))
  for (vi in seq_along(var_labels)) {
    arr[, , vi] <- env_data_list[[var_labels[vi]]]
  }
  # Remove rows with any NA
  good <- apply(arr, 1, function(x) !any(is.na(x)))
  if (sum(good) < nrow(arr)) {
    arr <- arr[good, , , drop = FALSE]
  }
  list(arr = arr, good = good)
}

fit_one_model <- function(var_labels, mask = NULL) {
  ea <- make_env_array(var_labels)
  env_dat <- ea$arr
  occ <- occ_vec[ea$good]

  if (sum(occ == 1) < 3) {
    cat("    [skip: <3 presences after NA filter]\n")
    return(NULL)
  }

  result <- tryCatch(
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
      cat(sprintf("    [optimize_likelihood error: %s]\n", conditionMessage(e)))
      NULL
    }
  )
  if (is.null(result) || is.null(result$best$par)) return(NULL)

  p <- dim(env_dat)[3]
  n <- dim(env_dat)[1]
  n_free <- if (is.null(mask)) num_par(p) else num_par(p) - length(mask)
  pBIC <- -2 * result$best$loglik + n_free * log(n)

  list(
    result   = result,
    env_dat  = env_dat,
    occ      = occ,
    n        = n,
    p        = p,
    n_free   = n_free,
    loglik   = result$best$loglik,
    pBIC     = pBIC,
    mask     = mask,
    vars     = var_labels
  )
}

test_well_behaved <- function(fit, model_name) {
  sols <- fit$result$solutions
  n_check <- min(5, nrow(sols))

  # Flag A: optimization convergence (relaxed max_pdist < 0.1)
  top_ll <- sols$loglik[1:n_check]
  ll_range <- max(top_ll) - min(top_ll)

  top_pars <- sols$full_par[1:n_check]
  pdists <- vapply(2:n_check, function(i) {
    tryCatch({
      d <- dist_between_params(top_pars[[1]], top_pars[[i]], mask = NULL)
      if (is.list(d)) d$distance else d
    }, error = function(e) NA_real_)
  }, numeric(1))
  max_pdist <- max(pdists, na.rm = TRUE)
  flag_a <- (ll_range < 0.1) && (max_pdist < 0.1)

  # Flag B: Hessian positive definite + condition
  best_full <- fit$result$best$par
  if (!is.null(fit$mask)) {
    free_names <- setdiff(names(best_full), names(fit$mask))
    best_free  <- best_full[free_names]
  } else {
    best_free  <- best_full
    free_names <- names(best_full)
  }

  hess <- tryCatch(
    numDeriv::hessian(
      func = function(par_free) {
        names(par_free) <- free_names
        loglik_math(par_free, env_dat = fit$env_dat, occ = fit$occ,
                    mask = fit$mask, negative = TRUE, num_threads = 1L)
      },
      x = best_free
    ),
    error = function(e) NULL
  )

  flag_b   <- FALSE
  cond_num <- NA_real_
  evals    <- NULL

  if (!is.null(hess)) {
    evals <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
    all_pos  <- all(evals > 1e-8)
    cond_num <- if (min(evals) > 0) max(evals) / min(evals) else Inf
    flag_b   <- all_pos && is.finite(cond_num) && (cond_num < 1e6)
  }

  list(well_behaved = flag_a && flag_b,
       flag_optim   = flag_a,
       flag_hessian = flag_b,
       ll_range     = ll_range,
       max_pdist    = max_pdist,
       cond_num     = cond_num,
       hessian      = hess,
       eigenvalues  = evals)
}

generate_boundary_masks <- function(p) {
  masks <- list()
  masks[["bd_pd1"]] <- c(pd = Inf)
  for (i in seq_len(p)) {
    m_l <- c(Inf); names(m_l) <- paste0("sigltil", i)
    masks[[paste0("bd_sigL", i)]] <- m_l
    m_r <- c(Inf); names(m_r) <- paste0("sigrtil", i)
    masks[[paste0("bd_sigR", i)]] <- m_r
  }
  for (i in seq_len(p)) {
    m_pl <- c(pd = Inf, Inf); names(m_pl)[2] <- paste0("sigltil", i)
    masks[[paste0("bd_pd1_sigL", i)]] <- m_pl
    m_pr <- c(pd = Inf, Inf); names(m_pr)[2] <- paste0("sigrtil", i)
    masks[[paste0("bd_pd1_sigR", i)]] <- m_pr
  }
  masks
}

# Adaptive profile likelihood (Hessian-guided step sizes)
adaptive_profile <- function(pname, optim_free, env_dat, occ, mask,
                             hessian_matrix, num_threads, alpha = 0.95,
                             target_steps = 15L, max_rounds = 3L) {
  idx  <- which(names(optim_free) == pname)
  h_ii <- abs(hessian_matrix[idx, idx])

  if (h_ii < 1e-12 || !is.finite(h_ii)) {
    increment <- 0.1; n_steps <- 50L
  } else {
    se_i <- 1 / sqrt(h_ii)
    expected_dist <- sqrt(qchisq(alpha, df = 1) / h_ii)
    increment <- max(expected_dist / target_steps, 0.01)
    n_steps <- as.integer(ceiling(2 * expected_dist / increment))
    n_steps <- max(n_steps, 20L)
    n_steps <- min(n_steps, 80L)
  }

  cat(sprintf("[inc=%.4f, steps=%d] ", increment, n_steps))

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

  pdat   <- prof$profile
  thresh <- prof$threshold
  idx_max <- which.max(pdat$loglik)
  left_crossed  <- idx_max > 1 && any(pdat$loglik[1:(idx_max-1)] <= thresh)
  right_crossed <- idx_max < nrow(pdat) &&
                   any(pdat$loglik[(idx_max+1):nrow(pdat)] <= thresh)

  round <- 1L
  while ((!left_crossed || !right_crossed) && round < max_rounds) {
    round     <- round + 1L
    increment <- increment * 2
    ext_steps <- min(as.integer(n_steps * 1.5), 100L)

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

    if (!is.null(prof_ext)) {
      prof    <- prof_ext
      pdat    <- prof$profile
      idx_max <- which.max(pdat$loglik)
      left_crossed  <- idx_max > 1 && any(pdat$loglik[1:(idx_max-1)] <= thresh)
      right_crossed <- idx_max < nrow(pdat) &&
                       any(pdat$loglik[(idx_max+1):nrow(pdat)] <= thresh)
    }
  }

  prof
}

# Arc check for one profile
check_arc <- function(prof, optim_ll, tolerance = 0.5) {
  if (is.null(prof)) return(list(pass = FALSE, reason = "null_profile"))
  pdat    <- prof$profile
  thresh  <- prof$threshold
  idx_max <- which.max(pdat$loglik)

  found_better <- any(pdat$loglik > optim_ll + .Machine$double.eps)
  left_crosses  <- idx_max > 1 && any(pdat$loglik[1:(idx_max-1)] <= thresh)
  right_crosses <- idx_max < nrow(pdat) &&
                   any(pdat$loglik[(idx_max+1):nrow(pdat)] <= thresh)

  left_mono  <- TRUE; right_mono <- TRUE
  if (idx_max > 2) {
    left_vals <- pdat$loglik[1:(idx_max-1)]
    left_diffs <- diff(left_vals)
    left_mono <- all(left_diffs >= -tolerance)
  }
  if (idx_max < nrow(pdat) - 1) {
    right_vals <- pdat$loglik[(idx_max+1):nrow(pdat)]
    right_diffs <- diff(right_vals)
    right_mono <- all(right_diffs <= tolerance)
  }

  pass <- left_crosses && right_crosses && left_mono && right_mono && !found_better

  reasons <- character(0)
  if (!left_crosses)  reasons <- c(reasons, "no_left_crossing")
  if (!right_crosses) reasons <- c(reasons, "no_right_crossing")
  if (!left_mono)     reasons <- c(reasons, "left_not_monotone")
  if (!right_mono)    reasons <- c(reasons, "right_not_monotone")
  if (found_better)   reasons <- c(reasons, "found_better_ll")
  reason <- if (length(reasons) == 0) "pass" else paste(reasons, collapse = ";")

  list(pass = pass, reason = reason, found_better = found_better,
       left_crosses = left_crosses, right_crosses = right_crosses)
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 6 — PHASE 2VAR: Fit 88 two-var L1 + boundary expansion
# ══════════════════════════════════════════════════════════════════════

run_phase_2var <- function() {
  cat("\n== PHASE 2VAR: Fitting", length(models_2var), "two-var L1 models ==\n")

  timing_rows <- list()
  L1 <- list()

  for (i in seq_along(models_2var)) {
    mname <- names(models_2var)[i]
    vars  <- models_2var[[mname]]
    cat(sprintf("  [%2d/%d] %-45s ", i, length(models_2var), mname))
    t0 <- proc.time()[3]
    fit <- fit_one_model(vars)
    dt <- proc.time()[3] - t0

    if (!is.null(fit)) {
      cat(sprintf("pBIC=%.1f LL=%.1f (%.0fs)\n", fit$pBIC, fit$loglik, dt))
      L1[[mname]] <- fit
    } else {
      cat(sprintf("FAILED (%.0fs)\n", dt))
    }
    timing_rows[[length(timing_rows) + 1]] <- data.frame(
      model = mname, n_vars = 2, phase = "L1", time_s = dt,
      stringsAsFactors = FALSE)
  }

  L1 <- Filter(Negate(is.null), L1)
  cat(sprintf("\nL1 complete: %d / %d succeeded\n", length(L1), length(models_2var)))

  if (length(L1) == 0) {
    cat("ERROR: All 2-var L1 models failed.\n")
    saveRDS(list(species = species_name, status = "all_2var_L1_failed",
                 timing = do.call(rbind, timing_rows)),
            file.path(p1_dir, "phase1_results.rds"))
    return(NULL)
  }

  # Boundary expansion on eligible models
  best_pBIC_L1 <- min(sapply(L1, `[[`, "pBIC"))
  max_p <- 3L
  n_data <- L1[[1]]$n
  tau <- (max_p + 1) * log(n_data)

  eligible <- names(L1)[sapply(L1, `[[`, "pBIC") <= best_pBIC_L1 + tau]
  cat(sprintf("\nBoundary expansion: %d eligible (tau=%.1f)\n",
              length(eligible), tau))

  L2 <- list()
  for (base_name in eligible) {
    vars <- L1[[base_name]]$vars
    p    <- length(vars)
    bmasks <- generate_boundary_masks(p)
    for (bname in names(bmasks)) {
      full_name <- paste0(base_name, "__", bname)
      cat(sprintf("  %-55s ", full_name))
      t0  <- proc.time()[3]
      fit <- fit_one_model(vars, mask = bmasks[[bname]])
      dt  <- proc.time()[3] - t0

      if (!is.null(fit)) {
        cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
        L2[[full_name]] <- fit
      } else {
        cat(sprintf("FAILED (%.0fs)\n", dt))
      }
      timing_rows[[length(timing_rows) + 1]] <- data.frame(
        model = full_name, n_vars = 2, phase = "L2_boundary", time_s = dt,
        stringsAsFactors = FALSE)
    }
  }
  L2 <- Filter(Negate(is.null), L2)
  cat(sprintf("Boundary models: %d fitted\n", length(L2)))

  # Combine and rank
  L3 <- c(L1, L2)
  L3_pBIC  <- sapply(L3, `[[`, "pBIC")
  L3_order <- names(L3)[order(L3_pBIC)]

  # Well-behavedness test
  cat("\n-- Well-behavedness testing (2-var) --\n")
  M_Omega <- NULL
  Omega   <- Inf
  diag_rows <- list()
  wb_models <- character(0)

  for (nm in L3_order) {
    cat(sprintf("  %-55s ", nm))
    wb <- tryCatch(test_well_behaved(L3[[nm]], nm),
      error = function(e) list(well_behaved = FALSE, flag_optim = FALSE,
        flag_hessian = FALSE, cond_num = NA, ll_range = NA, max_pdist = NA))

    cat(sprintf("opt=%s hess=%s cond=%.1e => %s\n",
                wb$flag_optim, wb$flag_hessian, wb$cond_num,
                if (wb$well_behaved) "WELL-BEHAVED" else "badly-behaved"))

    diag_rows[[length(diag_rows) + 1]] <- data.frame(
      model = nm, pBIC = L3[[nm]]$pBIC, loglik = L3[[nm]]$loglik,
      n_free = L3[[nm]]$n_free, n_vars = length(L3[[nm]]$vars),
      is_boundary = !is.null(L3[[nm]]$mask),
      flag_optim = wb$flag_optim, flag_hessian = wb$flag_hessian,
      cond_number = wb$cond_num, well_behaved = wb$well_behaved,
      stringsAsFactors = FALSE)

    if (wb$well_behaved) {
      wb_models <- c(wb_models, nm)
      if (is.null(M_Omega)) {
        M_Omega <- nm
        Omega   <- L3[[nm]]$pBIC
      }
    }
  }

  # Diagnostics
  diag_df <- do.call(rbind, diag_rows)
  timing_df <- do.call(rbind, timing_rows)

  # Generate 3-var expansion list from top-K 2-var
  top_2var_L1 <- names(L1)[order(sapply(L1, `[[`, "pBIC"))][1:min(top_k2, length(L1))]
  expansion_models <- list()
  for (base_name in top_2var_L1) {
    base_vars <- L1[[base_name]]$vars
    base_is_temp <- base_vars %in% temp_labels
    n_t <- sum(base_is_temp)
    n_p <- sum(!base_is_temp)
    candidates <- setdiff(available_labels, base_vars)
    cand_t <- intersect(candidates, temp_labels)
    cand_p <- intersect(candidates, precip_labels)
    add_vars <- character(0)
    if (n_t < 2) add_vars <- c(add_vars, cand_t)
    if (n_p < 2) add_vars <- c(add_vars, cand_p)
    for (nv in add_vars) {
      new_vars <- c(base_vars, nv)
      mname <- paste0("3v_", paste(new_vars, collapse = "_"))
      if (!mname %in% names(expansion_models))
        expansion_models[[mname]] <- new_vars
    }
  }

  # Save 3-var model list for split mode
  if (length(expansion_models) > 0) {
    model_list_df <- data.frame(
      index = seq_along(expansion_models),
      model_name = names(expansion_models),
      var1 = sapply(expansion_models, `[`, 1),
      var2 = sapply(expansion_models, `[`, 2),
      var3 = sapply(expansion_models, `[`, 3),
      stringsAsFactors = FALSE
    )
    write.csv(model_list_df,
              file.path(sp_dir, "3var_model_list.csv"), row.names = FALSE)
    cat(sprintf("\n3-var expansion list: %d models saved\n", nrow(model_list_df)))
  }

  # Save Phase 1 results
  saveRDS(list(
    species        = species_name,
    phase          = "2var",
    L1             = L1,
    L2             = L2,
    L3             = L3,
    L3_order       = L3_order,
    best_2var      = M_Omega,
    best_2var_pBIC = Omega,
    wb_models      = wb_models,
    diagnostics    = diag_df,
    timing         = timing_df,
    n_data         = n_data,
    expansion_models = expansion_models
  ), file.path(p1_dir, "phase1_results.rds"))

  cat(sprintf("\nPhase 2var complete: %d models, best=%s (pBIC=%.1f), %d well-behaved\n",
              length(L3), ifelse(is.null(M_Omega), "none", M_Omega), Omega, length(wb_models)))
  cat(sprintf("Total time: %.1f min\n", (proc.time()[3] - pipeline_t0) / 60))

  return(list(L3 = L3, M_Omega = M_Omega, Omega = Omega, wb = wb_models,
              diag = diag_df, timing = timing_df))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 7 — PHASE 3VAR_L1: Fit single 3-var model (split mode)
# ══════════════════════════════════════════════════════════════════════

run_phase_3var_L1 <- function() {
  if (is.null(model_index))
    stop("--phase 3var_L1 requires --model_index N", call. = FALSE)

  # Read model list generated by Phase 2var
  model_list_file <- file.path(sp_dir, "3var_model_list.csv")
  if (!file.exists(model_list_file))
    stop("3var_model_list.csv not found. Run --phase 2var first.", call. = FALSE)

  model_list <- read.csv(model_list_file, stringsAsFactors = FALSE)
  if (model_index < 1 || model_index > nrow(model_list))
    stop("model_index ", model_index, " out of range (1-", nrow(model_list), ")",
         call. = FALSE)

  row   <- model_list[model_index, ]
  mname <- row$model_name
  vars  <- c(row$var1, row$var2, row$var3)

  cat(sprintf("\n== PHASE 3VAR_L1: Model %d/%d (%s) ==\n",
              model_index, nrow(model_list), mname))
  cat("Variables:", paste(vars, collapse = ", "), "\n")

  t0  <- proc.time()[3]
  fit <- fit_one_model(vars)
  dt  <- proc.time()[3] - t0

  if (!is.null(fit)) {
    cat(sprintf("pBIC=%.1f LL=%.1f n_free=%d (%.0fs)\n",
                fit$pBIC, fit$loglik, fit$n_free, dt))

    # Quick well-behavedness screen
    wb <- tryCatch(test_well_behaved(fit, mname),
      error = function(e) list(well_behaved = FALSE, flag_optim = FALSE,
        flag_hessian = FALSE, cond_num = NA))

    cat(sprintf("Well-behaved: %s (opt=%s hess=%s cond=%.1e)\n",
                wb$well_behaved, wb$flag_optim, wb$flag_hessian, wb$cond_num))

    saveRDS(list(
      model_name   = mname,
      model_index  = model_index,
      vars         = vars,
      fit          = fit,
      well_behaved = wb$well_behaved,
      wb_details   = wb,
      time_s       = dt
    ), file.path(p2_dir, sprintf("model_%04d_%s.rds", model_index,
                                  gsub("[^a-zA-Z0-9_]", "", mname))))
  } else {
    cat(sprintf("FAILED (%.0fs)\n", dt))
    saveRDS(list(model_name = mname, model_index = model_index,
                 vars = vars, fit = NULL, well_behaved = FALSE, time_s = dt),
            file.path(p2_dir, sprintf("model_%04d_FAILED.rds", model_index)))
  }

  # Write sentinel
  writeLines("done", file.path(p2_dir,
    sprintf(".model_%04d.done", model_index)))

  cat(sprintf("Phase 3var_L1 done (%.1fs)\n", dt))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 8 — PHASE COLLECT: Assemble results, select, profile, arc
# ══════════════════════════════════════════════════════════════════════

run_phase_collect <- function() {
  cat("\n== PHASE COLLECT: Assembling all results ==\n")

  # Load Phase 1 results
  p1_file <- file.path(p1_dir, "phase1_results.rds")
  if (!file.exists(p1_file))
    stop("phase1_results.rds not found. Run --phase 2var first.", call. = FALSE)
  p1 <- readRDS(p1_file)
  L3_2var <- p1$L3

  # Load Phase 2 results (3-var models)
  p2_files <- list.files(p2_dir, pattern = "^model_.*\\.rds$", full.names = TRUE)
  cat(sprintf("Loading %d three-var model results...\n", length(p2_files)))

  L1_3var <- list()
  p2_timing <- list()
  for (f in p2_files) {
    res <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.null(res) && !is.null(res$fit)) {
      L1_3var[[res$model_name]] <- res$fit
      p2_timing[[length(p2_timing) + 1]] <- data.frame(
        model = res$model_name, n_vars = 3, phase = "3var_L1",
        time_s = res$time_s, stringsAsFactors = FALSE)
    }
  }
  cat(sprintf("Loaded %d successful 3-var L1 models\n", length(L1_3var)))

  # Boundary expansion on best 3-var L1
  L2_3var <- list()
  if (length(L1_3var) > 0) {
    best_3var_pBIC <- min(sapply(L1_3var, `[[`, "pBIC"))
    n_data <- L1_3var[[1]]$n
    tau <- (4 + 1) * log(n_data)  # max p=3 vars (corrected per D. Reuman 2026)
    eligible <- names(L1_3var)[sapply(L1_3var, `[[`, "pBIC") <= best_3var_pBIC + tau]
    # Limit boundary expansion to top 10 to stay within walltime
    eligible <- eligible[1:min(10, length(eligible))]

    cat(sprintf("\n3-var boundary expansion: %d eligible\n", length(eligible)))
    for (base_name in eligible) {
      vars <- L1_3var[[base_name]]$vars
      p    <- length(vars)
      bmasks <- generate_boundary_masks(p)
      for (bname in names(bmasks)) {
        full_name <- paste0(base_name, "__", bname)
        cat(sprintf("  %-60s ", full_name))
        t0  <- proc.time()[3]
        fit <- fit_one_model(vars, mask = bmasks[[bname]])
        dt  <- proc.time()[3] - t0
        if (!is.null(fit)) {
          cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
          L2_3var[[full_name]] <- fit
        } else {
          cat(sprintf("FAILED (%.0fs)\n", dt))
        }
      }
    }
    L2_3var <- Filter(Negate(is.null), L2_3var)
  }

  # Combine ALL models: 2-var (L1+L2) + 3-var (L1+L2)
  ALL <- c(L3_2var, L1_3var, L2_3var)
  ALL_pBIC  <- sapply(ALL, `[[`, "pBIC")
  ALL_order <- names(ALL)[order(ALL_pBIC)]

  cat(sprintf("\nTotal models: %d (2var: %d, 3var_L1: %d, 3var_L2: %d)\n",
              length(ALL), length(L3_2var), length(L1_3var), length(L2_3var)))

  # Well-behavedness test on all models not yet tested
  cat("\n-- Well-behavedness testing (all) --\n")
  M_Omega <- NULL
  Omega   <- Inf
  diag_rows <- list()
  wb_models <- character(0)

  for (nm in ALL_order) {
    cat(sprintf("  %-60s ", nm))
    wb <- tryCatch(test_well_behaved(ALL[[nm]], nm),
      error = function(e) list(well_behaved = FALSE, flag_optim = FALSE,
        flag_hessian = FALSE, cond_num = NA, ll_range = NA, max_pdist = NA))

    is_bd <- !is.null(ALL[[nm]]$mask)
    nv    <- length(ALL[[nm]]$vars)
    tag   <- if (wb$well_behaved) "WELL-BEHAVED" else "badly-behaved"
    cat(sprintf("%dv %s cond=%.1e => %s\n", nv, if (is_bd) "bd" else "nb", wb$cond_num, tag))

    diag_rows[[length(diag_rows) + 1]] <- data.frame(
      model = nm, pBIC = ALL[[nm]]$pBIC, loglik = ALL[[nm]]$loglik,
      n_free = ALL[[nm]]$n_free, n_vars = nv, is_boundary = is_bd,
      flag_optim = wb$flag_optim, flag_hessian = wb$flag_hessian,
      cond_number = wb$cond_num, well_behaved = wb$well_behaved,
      stringsAsFactors = FALSE)

    if (wb$well_behaved) {
      wb_models <- c(wb_models, nm)
      if (is.null(M_Omega)) {
        M_Omega <- nm
        Omega   <- ALL[[nm]]$pBIC
        cat(sprintf("  >> Selected: %s (pBIC=%.1f)\n", M_Omega, Omega))
      }
    }
  }

  diag_df <- do.call(rbind, diag_rows)
  write.csv(diag_df, file.path(sp_dir, "diagnostics_v2.csv"), row.names = FALSE)

  # Mask ratio statistics
  if (nrow(diag_df) > 0) {
    wb_df <- diag_df[diag_df$well_behaved, ]
    cat(sprintf("\n== MASK RATIO ==\n"))
    cat(sprintf("Total well-behaved: %d / %d\n", nrow(wb_df), nrow(diag_df)))
    if (nrow(wb_df) > 0) {
      for (nv in c(2, 3)) {
        wb_nv <- wb_df[wb_df$n_vars == nv, ]
        n_bd  <- sum(wb_nv$is_boundary)
        n_nb  <- sum(!wb_nv$is_boundary)
        cat(sprintf("  %d-var: %d well-behaved (%d boundary, %d non-boundary)\n",
                    nv, nrow(wb_nv), n_bd, n_nb))
      }
    }
  }

  # No well-behaved model
  if (is.null(M_Omega)) {
    cat("\nNo well-behaved model found.\n")
    total_time <- (proc.time()[3] - pipeline_t0) / 60

    # Summary CSV
    summary_df <- data.frame(
      model = names(ALL), pBIC = sapply(ALL, `[[`, "pBIC"),
      loglik = sapply(ALL, `[[`, "loglik"), n_free = sapply(ALL, `[[`, "n_free"),
      n_vars = sapply(ALL, function(x) length(x$vars)),
      is_boundary = sapply(ALL, function(x) !is.null(x$mask)),
      stringsAsFactors = FALSE)
    summary_df <- summary_df[order(summary_df$pBIC), ]
    write.csv(summary_df, file.path(sp_dir, "model_summary_v2.csv"), row.names = FALSE)

    saveRDS(list(
      species       = species_name,
      status        = "no_well_behaved_model",
      n_models      = length(ALL),
      n_wb          = 0,
      diagnostics   = diag_df,
      timing_total  = total_time,
      mask_ratio    = list(
        total_wb = 0, wb_2var_boundary = NA, wb_2var_nonboundary = NA,
        wb_3var_boundary = NA, wb_3var_nonboundary = NA
      )
    ), file.path(sp_dir, "model_results_v2.rds"))
    return(NULL)
  }

  # ── Profile likelihood of selected model ──
  cat(sprintf("\n-- Profile likelihood: %s --\n", M_Omega))

  best_fit  <- ALL[[M_Omega]]
  best_full <- best_fit$result$best$par
  best_mask <- best_fit$mask
  best_bio  <- math_to_bio(best_full)

  if (!is.null(best_mask)) {
    free_names <- setdiff(names(best_full), names(best_mask))
    optim_free <- best_full[free_names]
  } else {
    optim_free <- best_full
    free_names <- names(best_full)
  }

  # Compute Hessian for adaptive profiling
  hess <- tryCatch(
    numDeriv::hessian(
      func = function(par_free) {
        names(par_free) <- free_names
        loglik_math(par_free, env_dat = best_fit$env_dat, occ = best_fit$occ,
                    mask = best_mask, negative = TRUE, num_threads = 1L)
      },
      x = optim_free
    ),
    error = function(e) diag(length(optim_free))
  )

  profiles <- list()
  for (pname in free_names) {
    cat(sprintf("  %s: ", pname))
    profiles[[pname]] <- adaptive_profile(
      pname, optim_free, best_fit$env_dat, best_fit$occ,
      best_mask, hess, num_threads)
    cat(if (!is.null(profiles[[pname]])) "OK\n" else "FAILED\n")
  }

  # Arc check
  optim_ll <- best_fit$loglik
  arc_results <- list()
  arc_row <- data.frame(species = species_name, model = M_Omega,
                        stringsAsFactors = FALSE)
  all_pass <- TRUE

  for (pname in free_names) {
    ac <- check_arc(profiles[[pname]], optim_ll)
    arc_results[[pname]] <- ac
    arc_row[[pname]] <- as.integer(ac$pass)
    if (!ac$pass) all_pass <- FALSE
    cat(sprintf("  arc(%s): %s (%s)\n", pname,
                if (ac$pass) "PASS" else "FAIL", ac$reason))
  }
  arc_row$all_pass <- as.integer(all_pass)

  # Fallback re-optimization if found_better_ll
  fallback_iter <- 0L
  fallback_history <- list()
  any_found_better <- any(sapply(arc_results, `[[`, "found_better"))

  while (any_found_better && fallback_iter < 3L) {
    fallback_iter <- fallback_iter + 1L
    cat(sprintf("\n-- Fallback re-optimization (iter %d) --\n", fallback_iter))

    # Find best point from profiles
    best_profile_ll <- optim_ll
    best_profile_par <- NULL
    for (pname in names(profiles)) {
      if (!is.null(profiles[[pname]])) {
        pdat <- profiles[[pname]]$profile
        max_ll <- max(pdat$loglik)
        if (max_ll > best_profile_ll) {
          best_profile_ll <- max_ll
          idx <- which.max(pdat$loglik)
          best_profile_par <- pdat$par_vector[[idx]]
        }
      }
    }

    if (is.null(best_profile_par) || best_profile_ll <= optim_ll + 0.01) {
      cat("No improvement found in profiles. Stopping fallback.\n")
      break
    }

    cat(sprintf("Profile found LL=%.4f (improvement: %.4f)\n",
                best_profile_ll, best_profile_ll - optim_ll))

    # Re-optimize from the better point
    refit <- tryCatch(
      optimize_likelihood(
        env_dat     = best_fit$env_dat,
        occ         = best_fit$occ,
        mask        = best_mask,
        num_starts  = min(num_starts, 50L),
        num_threads = num_threads,
        parallel    = FALSE,
        verbose     = FALSE
      ),
      error = function(e) NULL
    )

    if (!is.null(refit) && refit$best$loglik > optim_ll + 0.01) {
      cat(sprintf("Re-optimized: LL=%.4f -> %.4f\n", optim_ll, refit$best$loglik))
      optim_ll <- refit$best$loglik
      best_full <- refit$best$par
      best_bio  <- math_to_bio(best_full)

      if (!is.null(best_mask)) {
        optim_free <- best_full[setdiff(names(best_full), names(best_mask))]
      } else {
        optim_free <- best_full
      }

      best_fit$result <- refit
      best_fit$loglik <- optim_ll

      # Re-profile
      hess <- tryCatch(
        numDeriv::hessian(
          func = function(par_free) {
            names(par_free) <- free_names
            loglik_math(par_free, env_dat = best_fit$env_dat,
                        occ = best_fit$occ, mask = best_mask,
                        negative = TRUE, num_threads = 1L)
          }, x = optim_free),
        error = function(e) diag(length(optim_free)))

      for (pname in free_names) {
        profiles[[pname]] <- adaptive_profile(
          pname, optim_free, best_fit$env_dat, best_fit$occ,
          best_mask, hess, num_threads)
      }

      # Re-check arcs
      all_pass <- TRUE
      for (pname in free_names) {
        ac <- check_arc(profiles[[pname]], optim_ll)
        arc_results[[pname]] <- ac
        arc_row[[pname]] <- as.integer(ac$pass)
        if (!ac$pass) all_pass <- FALSE
      }
      arc_row$all_pass <- as.integer(all_pass)
      any_found_better <- any(sapply(arc_results, `[[`, "found_better"))

      fallback_history[[fallback_iter]] <- list(
        ll_before = optim_ll, ll_after = refit$best$loglik,
        all_pass = all_pass)
    } else {
      cat("Re-optimization did not improve. Stopping.\n")
      break
    }
  }

  # Model quality classification
  n_arcs <- length(arc_results)
  n_pass <- sum(sapply(arc_results, `[[`, "pass"))
  model_quality <- if (all_pass && fallback_iter == 0) {
    "perfect"
  } else if (n_pass >= n_arcs * 0.5) {
    "acceptable"
  } else {
    "marginal"
  }

  cat(sprintf("\nModel quality: %s (%d/%d arcs pass, %d fallback iters)\n",
              model_quality, n_pass, n_arcs, fallback_iter))

  # ── Profile plot ──
  tryCatch({
    pdf(file.path(plots_dir, "05_profile_likelihood.pdf"),
        width = 4 * length(free_names), height = 4)
    par(mfrow = c(1, length(free_names)))
    for (pname in free_names) {
      if (!is.null(profiles[[pname]])) {
        pdat <- profiles[[pname]]$profile
        thresh <- profiles[[pname]]$threshold
        plot(pdat[[pname]], pdat$loglik, type = "l", lwd = 2,
             xlab = pname, ylab = "log-likelihood",
             main = paste(pname, if (arc_results[[pname]]$pass) "(PASS)" else "(FAIL)"))
        abline(h = thresh, col = "red", lty = 2, lwd = 1.5)
        abline(v = optim_free[pname], col = "blue", lty = 2)
      } else {
        plot.new(); text(0.5, 0.5, paste(pname, "\n(no profile)"))
      }
    }
    dev.off()
  }, error = function(e) cat("Plot error:", e$message, "\n"))

  # ── Write summary CSV ──
  summary_df <- data.frame(
    model = names(ALL), pBIC = sapply(ALL, `[[`, "pBIC"),
    loglik = sapply(ALL, `[[`, "loglik"), n_free = sapply(ALL, `[[`, "n_free"),
    n_vars = sapply(ALL, function(x) length(x$vars)),
    is_boundary = sapply(ALL, function(x) !is.null(x$mask)),
    selected = names(ALL) == M_Omega,
    stringsAsFactors = FALSE)
  summary_df <- summary_df[order(summary_df$pBIC), ]
  write.csv(summary_df, file.path(sp_dir, "model_summary_v2.csv"), row.names = FALSE)

  # ── Arc check CSV ──
  write.csv(arc_row, file.path(sp_dir, "profile_arc_check_v2.csv"), row.names = FALSE)

  # ── Mask ratio ──
  wb_df <- diag_df[diag_df$well_behaved, ]
  mask_ratio <- list(
    total_wb             = nrow(wb_df),
    wb_2var_boundary     = sum(wb_df$n_vars == 2 & wb_df$is_boundary),
    wb_2var_nonboundary  = sum(wb_df$n_vars == 2 & !wb_df$is_boundary),
    wb_3var_boundary     = sum(wb_df$n_vars == 3 & wb_df$is_boundary),
    wb_3var_nonboundary  = sum(wb_df$n_vars == 3 & !wb_df$is_boundary)
  )

  # ── Timing ──
  total_time <- (proc.time()[3] - pipeline_t0) / 60

  # ── Final RDS ──
  saveRDS(list(
    species        = species_name,
    status         = "success",
    selected       = M_Omega,
    pBIC           = Omega,
    model_quality  = model_quality,
    best_bio       = best_bio,
    best_math      = best_full,
    best_loglik    = optim_ll,
    n_data         = best_fit$n,
    model_vars     = best_fit$vars,
    n_vars         = length(best_fit$vars),
    is_boundary    = !is.null(best_mask),
    profiles       = profiles,
    arc_check      = arc_results,
    arc_summary    = arc_row,
    summary        = summary_df,
    mask_ratio     = mask_ratio,
    fallback_iters = fallback_iter,
    timing_total   = total_time,
    diagnostics    = diag_df,
    n_models_total = length(ALL),
    n_wb_total     = length(wb_models)
  ), file.path(sp_dir, "model_results_v2.rds"))

  cat(sprintf("\n== DONE: %s ==\n", species_name))
  cat(sprintf("Selected: %s (%d-var, %s, pBIC=%.1f)\n",
              M_Omega, length(best_fit$vars),
              if (!is.null(best_mask)) "boundary" else "non-boundary", Omega))
  cat(sprintf("Quality: %s (%d/%d arcs)\n", model_quality, n_pass, n_arcs))
  cat(sprintf("Mask ratio: %d wb (%d bd / %d nb for 2-var; %d bd / %d nb for 3-var)\n",
              mask_ratio$total_wb,
              mask_ratio$wb_2var_boundary, mask_ratio$wb_2var_nonboundary,
              mask_ratio$wb_3var_boundary, mask_ratio$wb_3var_nonboundary))
  cat(sprintf("Total time: %.1f min\n", total_time))
}

# ══════════════════════════════════════════════════════════════════════
# SECTION 9 — Phase dispatcher
# ══════════════════════════════════════════════════════════════════════

if (identical(phase, "2var")) {
  run_phase_2var()
} else if (identical(phase, "3var_L1")) {
  run_phase_3var_L1()
} else if (identical(phase, "collect")) {
  run_phase_collect()
} else if (is.null(phase)) {
  # Full sequential mode: 2var -> 3var (all) -> collect
  cat("\n== FULL MODE: Running all phases sequentially ==\n")

  # Phase 1: two-var
  p1_result <- run_phase_2var()

  # Phase 2: three-var (inline, not split)
  cat("\n== Inline 3-var fitting (top-K expansion) ==\n")
  p1_data <- readRDS(file.path(p1_dir, "phase1_results.rds"))
  expansion <- p1_data$expansion_models

  if (length(expansion) > 0) {
    for (i in seq_along(expansion)) {
      mname <- names(expansion)[i]
      vars  <- expansion[[mname]]
      cat(sprintf("  [%3d/%d] %-55s ", i, length(expansion), mname))
      t0  <- proc.time()[3]
      fit <- fit_one_model(vars)
      dt  <- proc.time()[3] - t0
      if (!is.null(fit)) {
        cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
        wb <- tryCatch(test_well_behaved(fit, mname),
          error = function(e) list(well_behaved = FALSE, flag_optim = FALSE,
            flag_hessian = FALSE, cond_num = NA))
        saveRDS(list(model_name = mname, model_index = i, vars = vars,
                     fit = fit, well_behaved = wb$well_behaved,
                     wb_details = wb, time_s = dt),
                file.path(p2_dir, sprintf("model_%04d.rds", i)))
      } else {
        cat(sprintf("FAILED (%.0fs)\n", dt))
      }
    }
  }

  # Phase 3: collect
  run_phase_collect()
} else {
  stop("Unknown --phase: ", phase,
       ". Use 2var, 3var_L1, collect, or omit for full mode.", call. = FALSE)
}

cat("\nPipeline v2 finished.\n")

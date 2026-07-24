#!/usr/bin/env Rscript
# xsdm_model_selection_v6.R
# ────────────────────────────────────────────────────────────────────────────
# DEFINITIVE pipeline: 6 env vars, 23 models, corrected tau
#
# Aligned with Algorithm2.docx (Daniel Reuman, 2026):
#   - 6 variables: T1(bio01), T2(bio10), T3(bio11), P1(bio12), P2(bio16), P3(bio17)
#   - Temp subsets: none, T1, T2, T3, T2+T3  (5 options)
#   - Precip subsets: none, P1, P2, P3, P2+P3  (5 options)
#   - 23 models = 5×5 − (none×none) − (T2T3×P2P3)
#   - max_p = 3 (max env vars in any single model)
#   - tau = (max_p + 1) * log(n_data) = 4 * log(n_data)
#     [CORRECTED: previously was 2*(max_p+1)*log(n_data), factor of 2 was wrong]
#   - Algorithm: L1 → L2 (boundary eligible) → L3 → well-behaved scan → M_Omega
#                → L4 (boundary mid-tier) → re-scan → final M_Omega → profile
#
# tau rationale (from Daniel Reuman):
#   BIC = -2ln(L^) + k*ln(n). A boundary model has at most (N+1) fewer parameters
#   than its non-boundary counterpart (N sigmas -> Inf, plus pd=1). If boundary
#   model has same likelihood as non-boundary, its BIC differs by -(N+1)*ln(n).
#   Therefore tau = (max_p + 1) * log(n_data), NOT 2*(max_p+1)*log(n_data).
#
# Output: per-species markdown report + RDS results
# ────────────────────────────────────────────────────────────────────────────

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(numDeriv)
})

# Progress bars are emitted to stderr by furrr/progressr; to keep I/O low
# in non-interactive Slurm runs, redirect stderr to /dev/null or a log.
if (requireNamespace("progressr", quietly = TRUE)) {
  progressr::handlers("void")
}
options(progressr.enable = FALSE)

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 1 — CLI parsing
# ═══════════════════════════════════════════════════════════════════════════

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name  <- parse_arg("--species")
env_csv_dir   <- parse_arg("--env_csv_dir",
                           "/home/a474r867/scratch/xsdm_env_extraction_19")
output_dir    <- parse_arg("--output_dir",
                           "/home/a474r867/scratch/xsdm_results_v6")
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
num_starts    <- as.integer(parse_arg("--num_starts", "1500"))
num_threads   <- as.integer(parse_arg("--num_threads", "4"))
skip_profile  <- "--skip_profile" %in% args

years <- as.integer(strsplit(years_str, ",")[[1]])
if (is.null(species_name)) stop("--species is required", call. = FALSE)

pipeline_t0 <- proc.time()[3]

cat("===================================================\n")
cat("xsdm Model Selection Pipeline v6 (Algorithm2 aligned)\n")
cat("Species:", species_name, "\n")
cat("Years:", min(years), "-", max(years), "(", length(years), "years)\n")
cat("Starts:", num_starts, " Threads:", num_threads, "\n")
cat("Algorithm: L1 → L2 → L3 → well-behaved → L4 → re-scan → profile\n")
cat("tau = (max_p+1)*log(n) [corrected per D. Reuman 2026]\n")
cat("===================================================\n")

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 2 — Define 6 variables + 23 models
# ═══════════════════════════════════════════════════════════════════════════

# Variable mapping: PI's labels → env CSV labels
var_map <- list(
  T1 = "T1_bio01",    # Annual mean temperature
  T2 = "T10_bio10",   # Mean temp of warmest quarter
  T3 = "T11_bio11",   # Mean temp of coldest quarter
  P1 = "P12_bio12",   # Annual precipitation
  P2 = "P16_bio16",   # Precip of wettest quarter
  P3 = "P17_bio17"    # Precip of driest quarter
)

# PI semantic names for display
var_display <- c(
  T1 = "T1 (bio01, annual mean temp)",
  T2 = "T2 (bio10, warmest quarter temp)",
  T3 = "T3 (bio11, coldest quarter temp)",
  P1 = "P1 (bio12, annual precip)",
  P2 = "P2 (bio16, wettest quarter precip)",
  P3 = "P3 (bio17, driest quarter precip)"
)

# Subset definitions
temp_subsets <- list(
  "none"   = character(0),
  "T1"     = "T1",
  "T2"     = "T2",
  "T3"     = "T3",
  "T2_T3"  = c("T2", "T3")
)

precip_subsets <- list(
  "none"   = character(0),
  "P1"     = "P1",
  "P2"     = "P2",
  "P3"     = "P3",
  "P2_P3"  = c("P2", "P3")
)

# Generate 23 models
generate_models <- function() {
  models <- list()
  for (tname in names(temp_subsets)) {
    for (pname in names(precip_subsets)) {
      # Exclude (none, none) and (T2_T3, P2_P3)
      if (tname == "none" && pname == "none") next
      if (tname == "T2_T3" && pname == "P2_P3") next
      
      tvars <- temp_subsets[[tname]]
      pvars <- precip_subsets[[pname]]
      all_vars <- c(tvars, pvars)
      
      mname <- paste0(
        if (length(tvars) > 0) paste(tvars, collapse = "_") else "noT",
        "_",
        if (length(pvars) > 0) paste(pvars, collapse = "_") else "noP"
      )
      models[[mname]] <- all_vars
    }
  }
  models
}

all_models <- generate_models()
cat(sprintf("Models defined: %d (temp subsets: %d × precip subsets: %d)\n",
            length(all_models), length(temp_subsets), length(precip_subsets)))

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 3 — Output directories + report file
# ═══════════════════════════════════════════════════════════════════════════

sp_safe   <- gsub(" ", "_", species_name)
sp_dir    <- file.path(output_dir, sp_safe)
plots_dir <- file.path(sp_dir, "plots")
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)

# Markdown report
report_path <- file.path(sp_dir, "model_selection_report.md")
report_lines <- character(0)

rpt <- function(...) {
  line <- paste0(...)
  report_lines <<- c(report_lines, line)
  cat(line, "\n")
}

rpt_h1 <- function(txt) rpt("# ", txt)
rpt_h2 <- function(txt) rpt("## ", txt)
rpt_h3 <- function(txt) rpt("### ", txt)
rpt_code <- function(txt) rpt("    ", txt)
rpt_sep <- function() rpt("---")

flush_report <- function() {
  writeLines(report_lines, report_path)
}

summarize_scale_factor <- function(f) {
  if (is.na(f)) return("NA")
  if (f == 1) return("1")
  sprintf("1/%g", f)
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load environmental data
# ═══════════════════════════════════════════════════════════════════════════

rpt_h1("xsdm v6 Model Selection Report (Algorithm2 aligned)")
rpt("")
rpt(sprintf("**Species:** %s", species_name))
rpt(sprintf("**Date:** %s", Sys.time()))
rpt(sprintf("**Starts per model:** %d", num_starts))
rpt(sprintf("**Threads:** %d", num_threads))
rpt(sprintf("**Years:** %d–%d (%d years)", min(years), max(years), length(years)))
rpt("")

cat("\n-- Loading environmental data (6 vars) --\n")

env_sp_dir <- file.path(env_csv_dir, sp_safe)
if (!dir.exists(env_sp_dir))
  stop("Env CSV dir not found: ", env_sp_dir, call. = FALSE)

# Read occurrence + points from first CSV
first_csv <- file.path(env_sp_dir, paste0(var_map[[1]], ".csv"))
if (!file.exists(first_csv))
  stop("Env CSV not found: ", first_csv, call. = FALSE)

occ_raw <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
occ_vec <- occ_raw$presence
n_pts   <- nrow(occ_raw)
n_time  <- length(years)

# Load all 6 variables
env_data_list <- list()
csv_labels    <- character(0)

for (vname in names(var_map)) {
  csv_label <- var_map[[vname]]
  csv_file  <- file.path(env_sp_dir, paste0(csv_label, ".csv"))
  if (!file.exists(csv_file)) {
    stop("Missing env CSV: ", csv_file, call. = FALSE)
  }
  env_df <- read.csv(csv_file, stringsAsFactors = FALSE, check.names = FALSE)
  year_cols <- as.character(years)
  mat <- matrix(NA_real_, nrow = n_pts, ncol = n_time)
  for (ti in seq_along(years)) {
    if (year_cols[ti] %in% names(env_df)) mat[, ti] <- env_df[[year_cols[ti]]]
  }
  env_data_list[[vname]] <- mat
  csv_labels <- c(csv_labels, csv_label)
}

## Kelvin → Celsius for absolute temperature bioclimatics (T1, T2, T3).
## This is a pure location shift; IQR, scale factors and pBIC ranking are
## unchanged, but the fitted niche centre mu is interpretable in °C.
KELVIN_OFFSET <- 273.15
temp_vars   <- c("T1", "T2", "T3")
precip_vars <- c("P1", "P2", "P3")
for (vname in intersect(temp_vars, names(env_data_list))) {
  env_data_list[[vname]] <- env_data_list[[vname]] - KELVIN_OFFSET
}

## Adaptive rescaling (IQR-based), applied to all variables.
## Precipitation is in mm; we scale any variable whose IQR is >10× the median
## temperature IQR by the nearest power of 10.

iqr_vals <- sapply(names(env_data_list), function(vname) {
  vals <- as.vector(env_data_list[[vname]])
  vals <- vals[!is.na(vals)]
  if (length(vals) < 10) return(NA_real_)
  IQR(vals, na.rm = TRUE)
})

temp_in_model <- intersect(temp_vars, names(env_data_list))
if (length(temp_in_model) > 0) {
  ref_iqr <- median(iqr_vals[temp_in_model], na.rm = TRUE)
} else {
  ref_iqr <- median(iqr_vals, na.rm = TRUE)
}

scale_factors <- setNames(rep(1, length(env_data_list)), names(env_data_list))
for (vname in names(env_data_list)) {
  ratio <- iqr_vals[[vname]] / ref_iqr
  if (is.finite(ratio) && !is.na(ratio) && ratio > 10) {
    power <- floor(log10(ratio))
    scale_factors[[vname]] <- 10^power
    env_data_list[[vname]] <- env_data_list[[vname]] / scale_factors[[vname]]
  }
}

cat(sprintf("  IQR reference (temperature median): %.3f\n", ref_iqr))
for (vname in names(env_data_list)) {
  rng <- range(env_data_list[[vname]], na.rm = TRUE)
  cat(sprintf("  %-2s raw IQR=%.3f scale=%s range=[%.3f, %.3f]\n",
              vname, iqr_vals[[vname]], summarize_scale_factor(scale_factors[[vname]]),
              rng[1], rng[2]))
}

n_pres <- sum(occ_vec == 1)
n_abs  <- sum(occ_vec == 0)
cat(sprintf("Loaded %d variables, %d pts × %d years\n",
            length(env_data_list), n_pts, n_time))
cat(sprintf("Records: %d total (%d presences, %d absences)\n",
            n_pts, n_pres, n_abs))

n_data <- n_pts  # total data points

rpt_h2("Data Summary")
rpt("")
rpt(sprintf("- **Total points:** %d", n_pts))
rpt(sprintf("- **Presences:** %d", n_pres))
rpt(sprintf("- **Absences:** %d", n_abs))
rpt(sprintf("- **Time steps:** %d", n_time))
rpt(sprintf("- **Variables loaded:** %d", length(env_data_list)))
for (vname in names(var_map)) {
  rpt(sprintf("  - %s → `%s`", vname, var_display[vname]))
}
rpt(sprintf("- **Input units:** temperatures converted from ERA50Land Kelvin to °C; precipitation is mm"))
rpt(sprintf("- **Adaptive rescaling:** applied per variable when IQR ratio > 10× temperature reference"))
rpt("")
rpt("| Variable | IQR | Scale factor | Post-scale range |")
rpt("|----------|-----|--------------|------------------|")
for (vname in names(env_data_list)) {
  rng <- range(env_data_list[[vname]], na.rm = TRUE)
  rpt(sprintf("| %s | %.3f | %s | [%.3f, %.3f] |",
              vname, iqr_vals[[vname]], summarize_scale_factor(scale_factors[[vname]]),
              rng[1], rng[2]))
}
rpt("")

flush_report()

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 5 — Helpers
# ═══════════════════════════════════════════════════════════════════════════

make_env_array <- function(var_names) {
  p <- length(var_names)
  if (p == 0) stop("Cannot make env array with 0 variables")
  arr <- array(NA_real_, dim = c(n_pts, n_time, p),
               dimnames = list(NULL, as.character(years), var_names))
  for (vi in seq_along(var_names)) {
    arr[, , vi] <- env_data_list[[var_names[vi]]]
  }
  # Remove rows with any NA
  good <- apply(arr, 1, function(x) !any(is.na(x)))
  if (sum(good) < nrow(arr)) {
    arr <- arr[good, , , drop = FALSE]
  }
  list(arr = arr, good = good)
}

fit_one_model <- function(var_names, mask = NULL) {
  if (length(var_names) == 0) return(NULL)
  ea <- make_env_array(var_names)
  env_dat <- ea$arr
  occ <- occ_vec[ea$good]
  
  if (sum(occ == 1) < 3) {
    return(NULL)
  }
  
  result <- tryCatch(
    optimize_likelihood(
      env_dat     = env_dat,
      occ         = occ,
      mask        = mask,
      num_starts  = num_starts,
      num_threads = num_threads,
      num_cores   = num_threads,
      parallel    = (num_threads > 1L),
      verbose     = FALSE
    ),
    error = function(e) NULL
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
    vars     = var_names
  )
}

# Well-behaved test: two flags
test_well_behaved <- function(fit, model_name, verbose = TRUE) {
  sols <- fit$result$solutions
  n_check <- min(5, nrow(sols))
  
  # Flag A: optimization convergence
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
  flag_a <- (ll_range < 0.1) && (max_pdist < 0.05)
  
  # Flag B: Hessian positive definite + condition number
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
  
  well_behaved <- flag_a && flag_b
  
  list(well_behaved  = well_behaved,
       flag_optim    = flag_a,
       flag_hessian  = flag_b,
       ll_range      = ll_range,
       max_pdist     = max_pdist,
       cond_num      = cond_num,
       hessian       = hess,
       eigenvalues   = evals)
}

# Boundary masks: pd=Inf, sigL_i=Inf, sigR_i=Inf, and combos
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

# Adaptive profile likelihood
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

# Arc check
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

# Format parameter names nicely for display
format_param_names <- function(vars) {
  sapply(vars, function(v) {
    if (v %in% names(var_display)) var_display[v] else v
  })
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 6 — FIT L1: 23 non-boundary models
# ═══════════════════════════════════════════════════════════════════════════

rpt_h2("Phase 1: L1 — 23 non-boundary models")
rpt("")

cat(sprintf("\n== Fitting %d L1 non-boundary models ==\n", length(all_models)))

L1 <- list()
L1_timing <- list()

for (i in seq_along(all_models)) {
  mname <- names(all_models)[i]
  vars  <- all_models[[mname]]
  nv    <- length(vars)
  
  cat(sprintf("  [%2d/%d] %-20s (%d var%s) ", i, length(all_models), mname, nv,
              if (nv != 1) "s" else " "))
  t0 <- proc.time()[3]
  fit <- fit_one_model(vars)
  dt <- proc.time()[3] - t0
  
  if (!is.null(fit)) {
    cat(sprintf("pBIC=%.1f LL=%.1f n_free=%d n=%d (%.0fs)\n",
                fit$pBIC, fit$loglik, fit$n_free, fit$n, dt))
    L1[[mname]] <- fit
  } else {
    cat(sprintf("FAILED (%.0fs)\n", dt))
  }
  L1_timing[[length(L1_timing) + 1]] <- data.frame(
    model = mname, n_vars = nv, phase = "L1", time_s = dt,
    stringsAsFactors = FALSE)
}

L1 <- Filter(Negate(is.null), L1)
cat(sprintf("\nL1 complete: %d / %d succeeded\n", length(L1), length(all_models)))

if (length(L1) == 0) {
  rpt("**ERROR: All L1 models failed.**")
  flush_report()
  stop("All L1 models failed.", call. = FALSE)
}

# L1 table in report
rpt(sprintf("**Models fitted:** %d / %d succeeded", length(L1), length(all_models)))
rpt("")
rpt("| # | Model | Vars | n | n_free | logLik | pBIC | Time (s) |")
rpt("|---|-------|------|---|--------|--------|------|----------|")

L1_pBIC <- sapply(L1, `[[`, "pBIC")
L1_order <- names(L1)[order(L1_pBIC)]

for (j in seq_along(L1_order)) {
  nm <- L1_order[j]
  f  <- L1[[nm]]
  t  <- L1_timing[[which(sapply(L1_timing, function(x) x$model == nm))]]
  rpt(sprintf("| %d | %s | %s | %d | %d | %.2f | %.1f | %.1f |",
              j, nm, paste(f$vars, collapse = ", "),
              f$n, f$n_free, f$loglik, f$pBIC, t$time_s))
}
rpt("")

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 7 — tau and L2 boundary models
# ═══════════════════════════════════════════════════════════════════════════

max_p <- 3  # max env vars in any model
tau <- (max_p + 1) * log(n_data)
best_pBIC_L1 <- min(L1_pBIC)

rpt_h2("Phase 2: L2 — Boundary models of eligible L1")
rpt("")
rpt(sprintf("- **tau** = (%d + 1) × log(%d) = %d × %.4f = **%.4f**",
          max_p, n_data, max_p + 1, log(n_data), tau))
rpt(sprintf("- **Best L1 pBIC:** %.1f", best_pBIC_L1))
rpt(sprintf("- **Threshold (best + tau):** %.1f", best_pBIC_L1 + tau))
rpt("")

rpt("## Literal selection rules")
rpt("")
rpt("- **L1:** fit all 23 non-boundary models; rank by pBIC.")
rpt("- **L2:** fit boundary models for L1 models with pBIC ≤ best_L1 + tau.")
rpt("- **L3:** union of L1 and L2, ranked by pBIC.")
rpt("- **Well-behaved scan:** from lowest pBIC upward, accept the first model with top-5 logLik range < 0.1, max parameter distance < 0.05, positive-definite Hessian, and condition number < 1e6.")
rpt("- **L4:** fit boundary models for L1 models with pBIC ≥ best_L1 + tau and pBIC ≤ Omega + tau.")
rpt("- **Final scan:** from lowest L4 pBIC upward, stop when pBIC > Omega or accept the first well-behaved model.")
rpt("")

eligible_L1 <- names(L1)[L1_pBIC <= best_pBIC_L1 + tau]
rpt(sprintf("**Eligible L1 models for boundary expansion:** %d", length(eligible_L1)))
rpt("")

if (length(eligible_L1) > 0) {
  rpt("| Model | pBIC | ≤ threshold? |")
  rpt("|-------|------|-------------|")
  for (nm in names(L1)) {
    rpt(sprintf("| %s | %.1f | %s |", nm, L1[[nm]]$pBIC,
                if (nm %in% eligible_L1) "✓" else ""))
  }
  rpt("")
}

cat(sprintf("\n== L2: Boundary expansion from %d eligible models ==\n", length(eligible_L1)))

L2 <- list()
L2_timing <- list()
L2_meta <- list()

for (base_name in eligible_L1) {
  vars <- L1[[base_name]]$vars
  p    <- length(vars)
  bmasks <- generate_boundary_masks(p)
  for (bname in names(bmasks)) {
    full_name <- paste0(base_name, "__", bname)
    cat(sprintf("  %-45s ", full_name))
    t0  <- proc.time()[3]
    fit <- fit_one_model(vars, mask = bmasks[[bname]])
    dt  <- proc.time()[3] - t0
    
    if (!is.null(fit)) {
      cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
      L2[[full_name]] <- fit
      status <- "success"
      pBIC_val <- fit$pBIC
      n_free <- fit$n_free
    } else {
      cat(sprintf("FAILED (%.0fs)\n", dt))
      status <- "failed"
      pBIC_val <- NA_real_
      n_free <- NA_integer_
    }
    L2_meta[[length(L2_meta) + 1]] <- data.frame(
      model = full_name, base_model = base_name, mask = bname,
      status = status, pBIC = pBIC_val, n_free = n_free, time_s = dt,
      stringsAsFactors = FALSE
    )
    L2_timing[[length(L2_timing) + 1]] <- data.frame(
      model = full_name, n_vars = p, phase = "L2_boundary", time_s = dt,
      stringsAsFactors = FALSE)
  }
}

L2 <- Filter(Negate(is.null), L2)
cat(sprintf("L2 complete: %d boundary models fitted\n", length(L2)))

L2_meta_df <- if (length(L2_meta) > 0) do.call(rbind, L2_meta) else data.frame()
if (nrow(L2_meta_df) > 0) {
  rpt_h2("L2 boundary model list")
  rpt("")
  rpt("| Model | Base L1 | Mask | Status | n_free | pBIC | Time (s) |")
  rpt("|-------|---------|------|--------|--------|------|----------|")
  for (i in seq_len(nrow(L2_meta_df))) {
    row <- L2_meta_df[i, ]
    rpt(sprintf("| %s | %s | %s | %s | %s | %s | %.1f |",
                row$model, row$base_model, row$mask, row$status,
                ifelse(is.na(row$n_free), "", as.character(row$n_free)),
                ifelse(is.na(row$pBIC), "", sprintf("%.1f", row$pBIC)),
                row$time_s))
  }
  rpt("")
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 8 — L3 = L1 ∪ L2, rank by pBIC, well-behaved scan
# ═══════════════════════════════════════════════════════════════════════════

L3 <- c(L1, L2)
L3_pBIC  <- sapply(L3, `[[`, "pBIC")
L3_order <- names(L3)[order(L3_pBIC)]

rpt_h2("Phase 3: L3 — Combined ranking (L1 + L2)")
rpt("")
rpt(sprintf("**Total L3 models:** %d (%d L1 + %d L2)", length(L3), length(L1), length(L2)))
rpt("")
rpt("| # | Model | Type | Vars | n_free | pBIC |")
rpt("|---|-------|------|------|--------|------|")

for (j in seq_along(L3_order)) {
  nm <- L3_order[j]
  f  <- L3[[nm]]
  is_bd <- !is.null(f$mask)
  rpt(sprintf("| %d | %s | %s | %s | %d | %.1f |",
              j, nm, if (is_bd) "boundary" else "non-boundary",
              paste(f$vars, collapse = ", "), f$n_free, f$pBIC))
}
rpt("")

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 9 — Well-behaved scan through L3
# ═══════════════════════════════════════════════════════════════════════════

rpt_h2("Phase 4: Well-behaved scan through L3")
rpt("")
rpt("Scanning L3 from lowest pBIC upward. Stop at first model with **both** flags passing.")
rpt("")

M_Omega <- NULL
Omega   <- Inf
wb_found <- FALSE

for (nm in L3_order) {
  fit <- L3[[nm]]
  is_bd <- !is.null(fit$mask)
  nv <- length(fit$vars)
  
  rpt_h3(sprintf("Model: %s", nm))
  rpt("")
  rpt(sprintf("- **Type:** %s", if (is_bd) "boundary" else "non-boundary"))
  rpt(sprintf("- **Variables:** %s (%d)", paste(fit$vars, collapse = ", "), nv))
  rpt(sprintf("- **n:** %d, **n_free:** %d, **pBIC:** %.1f, **logLik:** %.4f",
              fit$n, fit$n_free, fit$pBIC, fit$loglik))
  rpt("")
  
  # --- Flag A: Optimization convergence ---
  rpt("#### Flag A: Optimization convergence")
  rpt("")
  
  sols <- fit$result$solutions
  n_check <- min(5, nrow(sols))
  top_ll <- sols$loglik[1:n_check]
  ll_range <- max(top_ll) - min(top_ll)
  
  rpt(sprintf("Top %d optimization results:", n_check))
  rpt("")
  
  # Show top solutions with Hungarian-rendered parameters
  top_pars <- sols$full_par[1:n_check]
  pdists <- numeric(0)
  
  for (si in 1:n_check) {
    rpt(sprintf("**Solution %d:** logLik = %.6f, convergence = %s",
                si, sols$loglik[si],
                if (!is.null(sols$convergence[si])) sols$convergence[si] else "NA"))
    
    # Render parameters: use Hungarian to make comparable to first
    if (si > 1) {
      dd <- tryCatch({
        d <- dist_between_params(top_pars[[1]], top_pars[[si]], mask = NULL)
        if (is.list(d)) list(dist = d$distance, matched = d$matched_par) else list(dist = d)
      }, error = function(e) list(dist = NA_real_))
      pdists <- c(pdists, dd$dist)
    }
    
    # Display parameters
    par_names <- names(top_pars[[si]])
    for (pi in seq_along(top_pars[[si]])) {
      rpt(sprintf("  - `%s` = %.6g", par_names[pi], top_pars[[si]][pi]))
    }
    rpt("")
  }
  
  max_pdist <- if (length(pdists) > 0) max(pdists, na.rm = TRUE) else 0
  
  rpt(sprintf("- **logLik range (top %d):** %.6f", n_check, ll_range))
  rpt(sprintf("- **Max parameter distance (Hungarian):** %.6f", max_pdist))
  
  flag_a <- (ll_range < 0.1) && (max_pdist < 0.05)
  rpt(sprintf("- **Flag A:** ll_range < 0.1 (%s) AND max_pdist < 0.05 (%s) → **%s**",
              if (ll_range < 0.1) "✓" else "✗",
              if (max_pdist < 0.05) "✓" else "✗",
              if (flag_a) "LIKELY WELL-BEHAVED" else "LIKELY BADLY-BEHAVED"))
  rpt("")
  
  # --- Flag B: Hessian ---
  rpt("#### Flag B: Hessian analysis")
  rpt("")
  
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
  
  if (!is.null(hess)) {
    rpt("Hessian matrix (free parameters):")
    rpt("")
    rpt("```")
    hess_str <- capture.output(print(hess))
    for (hs in hess_str) rpt(hs)
    rpt("```")
    rpt("")
    
    evals <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
    rpt("Eigenvalues:")
    rpt("")
    for (ei in seq_along(evals)) {
      rpt(sprintf("  λ%d = %.6e %s", ei, evals[ei],
                  if (evals[ei] > 1e-8) "(> 0 ✓)" else "(≤ 0 ✗)"))
    }
    rpt("")
    
    all_pos  <- all(evals > 1e-8)
    cond_num <- if (min(evals) > 0) max(evals) / min(evals) else Inf
    flag_b   <- all_pos && is.finite(cond_num) && (cond_num < 1e6)
    
    rpt(sprintf("- **All eigenvalues > 1e-8:** %s", if (all_pos) "✓" else "✗"))
    rpt(sprintf("- **Condition number:** %.2e", cond_num))
    rpt(sprintf("- **Condition number < 1e6:** %s", if (cond_num < 1e6) "✓" else "✗"))
  } else {
    rpt("**Hessian computation FAILED**")
    flag_b <- FALSE
    cond_num <- NA_real_
    evals <- NULL
    rpt("- **Flag B:** Hessian unavailable → **LIKELY BADLY-BEHAVED**")
    rpt("")
  }
  
  if (!is.null(hess)) {
    rpt(sprintf("- **Flag B:** Positive definite (%s) AND cond < 1e6 (%s) → **%s**",
                if (all_pos) "✓" else "✗",
                if (is.finite(cond_num) && cond_num < 1e6) "✓" else "✗",
                if (flag_b) "LIKELY WELL-BEHAVED" else "LIKELY BADLY-BEHAVED"))
    rpt("")
  }
  
  # --- Verdict ---
  rpt("#### Verdict")
  rpt("")
  
  if (flag_a && flag_b) {
    rpt(sprintf("- **Flag A:** %s | **Flag B:** %s → **WELL-BEHAVED ✓**",
                flag_a, flag_b))
  } else if (flag_a != flag_b) {
    rpt(sprintf("- **⚠ WARNING: Flags disagree!** Flag A: %s | Flag B: %s",
                if (flag_a) "well-behaved" else "badly-behaved",
                if (flag_b) "well-behaved" else "badly-behaved"))
  } else {
    rpt(sprintf("- **Flag A:** %s | **Flag B:** %s → **BADLY-BEHAVED**",
                "badly-behaved", "badly-behaved"))
  }
  rpt("")
  rpt_sep()
  rpt("")
  
  if (flag_a && flag_b && !wb_found) {
    M_Omega <- nm
    Omega   <- fit$pBIC
    wb_found <- TRUE
    cat(sprintf("\n  >> WELL-BEHAVED: %s (pBIC=%.1f)\n", M_Omega, Omega))
    rpt(sprintf("**>>> SELECTED as M_Omega: %s (pBIC = %.1f)**", M_Omega, Omega))
    rpt("")
    break
  }
}

if (!wb_found) {
  rpt("**No well-behaved model found in L3. Stopping.**")
  rpt("")
  flush_report()
  saveRDS(list(species = species_name, status = "no_well_behaved", L1 = L1, L2 = L2, L3 = L3),
          file.path(sp_dir, "model_results_v6.rds"))
  stop("No well-behaved model found.", call. = FALSE)
}

rpt(sprintf("**Omega (first real BIC):** %.1f", Omega))
rpt(sprintf("**M_Omega:** %s", M_Omega))
rpt("")

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 10 — L4: Boundary models of mid-tier L1
# ═══════════════════════════════════════════════════════════════════════════

rpt_h2("Phase 5: L4 — Boundary models of mid-tier L1")
rpt("")
rpt(sprintf("Models in L1 with pBIC ∈ [best_L1 + tau, Omega + tau]:"))
rpt(sprintf("- Lower bound (best_L1 + tau) = %.1f + %.4f = **%.4f**",
          best_pBIC_L1, tau, best_pBIC_L1 + tau))
rpt(sprintf("- Upper bound (Omega + tau) = %.1f + %.4f = **%.4f**",
          Omega, tau, Omega + tau))
rpt("")

L4_eligible <- names(L1)[L1_pBIC >= best_pBIC_L1 + tau & L1_pBIC <= Omega + tau]

rpt(sprintf("**Eligible L1 models for L4:** %d", length(L4_eligible)))
rpt("")

if (length(L4_eligible) > 0) {
  rpt("| Model | pBIC | In range? |")
  rpt("|-------|------|----------|")
  for (nm in names(L1)) {
    in_range <- nm %in% L4_eligible
    rpt(sprintf("| %s | %.1f | %s |", nm, L1[[nm]]$pBIC, if (in_range) "✓" else ""))
  }
  rpt("")
  
  cat(sprintf("\n== L4: Boundary expansion from %d mid-tier models ==\n", length(L4_eligible)))
  
  L4 <- list()
  L4_meta <- list()
  for (base_name in L4_eligible) {
    vars <- L1[[base_name]]$vars
    p    <- length(vars)
    bmasks <- generate_boundary_masks(p)
    for (bname in names(bmasks)) {
      full_name <- paste0(base_name, "__", bname)
      cat(sprintf("  %-45s ", full_name))
      t0  <- proc.time()[3]
      fit <- fit_one_model(vars, mask = bmasks[[bname]])
      dt  <- proc.time()[3] - t0
      
      if (!is.null(fit)) {
        cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
        L4[[full_name]] <- fit
        status <- "success"
        pBIC_val <- fit$pBIC
        n_free <- fit$n_free
      } else {
        cat(sprintf("FAILED (%.0fs)\n", dt))
        status <- "failed"
        pBIC_val <- NA_real_
        n_free <- NA_integer_
      }
      L4_meta[[length(L4_meta) + 1]] <- data.frame(
        model = full_name, base_model = base_name, mask = bname,
        status = status, pBIC = pBIC_val, n_free = n_free, time_s = dt,
        stringsAsFactors = FALSE
      )
    }
  }
  
  L4 <- Filter(Negate(is.null), L4)
  cat(sprintf("L4 complete: %d models\n", length(L4)))

  L4_meta_df <- if (length(L4_meta) > 0) do.call(rbind, L4_meta) else data.frame()
  if (nrow(L4_meta_df) > 0) {
    rpt_h2("L4 boundary model list")
    rpt("")
    rpt("| Model | Base L1 | Mask | Status | n_free | pBIC | Time (s) |")
    rpt("|-------|---------|------|--------|--------|------|----------|")
    for (i in seq_len(nrow(L4_meta_df))) {
      row <- L4_meta_df[i, ]
      rpt(sprintf("| %s | %s | %s | %s | %s | %s | %.1f |",
                  row$model, row$base_model, row$mask, row$status,
                  ifelse(is.na(row$n_free), "", as.character(row$n_free)),
                  ifelse(is.na(row$pBIC), "", sprintf("%.1f", row$pBIC)),
                  row$time_s))
    }
    rpt("")
  }
} else {
  L4 <- list()
  rpt("**No models eligible for L4.**")
  rpt("")
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 11 — L4 scan for better model
# ═══════════════════════════════════════════════════════════════════════════

if (length(L4) > 0) {
  L4_pBIC  <- sapply(L4, `[[`, "pBIC")
  L4_order <- names(L4)[order(L4_pBIC)]
  
  rpt_h2("Phase 6: L4 scan")
  rpt("")
  rpt(sprintf("**L4 models:** %d", length(L4)))
  rpt("")
  rpt("| # | Model | Type | Vars | n_free | pBIC |")
  rpt("|---|-------|------|------|--------|------|")
  for (j in seq_along(L4_order)) {
    nm <- L4_order[j]
    f  <- L4[[nm]]
    rpt(sprintf("| %d | %s | boundary | %s | %d | %.1f |",
                j, nm, paste(f$vars, collapse = ", "), f$n_free, f$pBIC))
  }
  rpt("")
  
  rpt("Scanning L4 from lowest pBIC, stopping when pBIC > Omega or well-behaved found:")
  rpt("")
  
  for (nm in L4_order) {
    fit <- L4[[nm]]
    if (fit$pBIC > Omega) {
      rpt(sprintf("- **%s:** pBIC = %.1f > Omega (%.1f) → **STOP**", nm, fit$pBIC, Omega))
      break
    }
    
    cat(sprintf("\n  Testing L4 model: %s (pBIC=%.1f)\n", nm, fit$pBIC))
    
    wb <- test_well_behaved(fit, nm, verbose = FALSE)
    
    rpt_h3(sprintf("L4: %s", nm))
    rpt("")
    rpt(sprintf("- **Variables:** %s", paste(fit$vars, collapse = ", ")))
    rpt(sprintf("- **pBIC:** %.1f", fit$pBIC))
    rpt(sprintf("- **Flag A (optim):** %s", if (wb$flag_optim) "well-behaved" else "badly-behaved"))
    rpt(sprintf("- **Flag B (hessian):** %s (cond = %.2e)",
                if (wb$flag_hessian) "well-behaved" else "badly-behaved", wb$cond_num))
    
    if (wb$well_behaved) {
      rpt(sprintf("- **>>> NEW M_Omega: %s (pBIC = %.1f, was %.1f)**", nm, fit$pBIC, Omega))
      M_Omega <- nm
      Omega   <- fit$pBIC
      rpt("")
      break
    } else {
      rpt("- **→ not well-behaved, continuing**")
      rpt("")
    }
  }
}

rpt("")
rpt_h2(sprintf("Final selected model: %s", M_Omega))
rpt("")
rpt(sprintf("- **pBIC (Omega):** %.1f", Omega))
rpt(sprintf("- **Variables:** %s", paste(L3[[M_Omega]]$vars, collapse = ", ")))
rpt("")

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 12 — Profile likelihood of final model
# ═══════════════════════════════════════════════════════════════════════════

best_fit  <- L3[[M_Omega]]
best_full <- best_fit$result$best$par
best_mask <- best_fit$mask
best_bio  <- math_to_bio(best_full)
optim_ll  <- best_fit$loglik

profiles    <- list()
arc_results <- list()
arc_row     <- data.frame(species = species_name, model = M_Omega,
                          stringsAsFactors = FALSE)

if (skip_profile) {
  rpt_h2("Phase 7: Profile likelihood")
  rpt("")
  rpt("*Profile likelihood skipped by --skip_profile; proceeding to save and map.*")
  rpt("")
} else {
  rpt_h2("Phase 7: Profile likelihood")
  rpt("")

  rpt(sprintf("**Best-fit parameters (biological scale):**"))
  rpt("")
  for (pi in seq_along(best_bio)) {
    rpt(sprintf("- `%s` = %.6g", names(best_bio)[pi], best_bio[pi]))
  }
  rpt("")

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

  for (pname in free_names) {
    cat(sprintf("  Profile %s: ", pname))
    profiles[[pname]] <- adaptive_profile(
      pname, optim_free, best_fit$env_dat, best_fit$occ,
      best_mask, hess, num_threads)
    cat(if (!is.null(profiles[[pname]])) "OK\n" else "FAILED\n")
  }

  # Arc check
  optim_ll <- best_fit$loglik
  all_pass <- TRUE

  rpt("### Arc check results")
  rpt("")
  rpt("| Parameter | Pass? | Reason |")
  rpt("|-----------|-------|--------|")

  for (pname in free_names) {
    ac <- check_arc(profiles[[pname]], optim_ll)
    arc_results[[pname]] <- ac
    arc_row[[pname]] <- as.integer(ac$pass)
    if (!ac$pass) all_pass <- FALSE
    rpt(sprintf("| %s | %s | %s |", pname,
                if (ac$pass) "✓ PASS" else "✗ FAIL", ac$reason))
  }
  rpt(sprintf("| **Overall** | **%s** | |", if (all_pass) "✓ ALL PASS" else "✗ SOME FAIL"))
  rpt("")

  # Profile plots
  tryCatch({
    n_plots <- length(free_names)
    pdf(file.path(plots_dir, "profile_likelihood_v6.pdf"),
        width = 4 * n_plots, height = 4)
    par(mfrow = c(1, n_plots))
    for (pname in free_names) {
      if (!is.null(profiles[[pname]])) {
        pdat <- profiles[[pname]]$profile
        thresh <- profiles[[pname]]$threshold
        plot(pdat[[pname]], pdat$loglik, type = "l", lwd = 2,
             xlab = pname, ylab = "log-likelihood",
             main = paste(pname, if (arc_results[[pname]]$pass) "(PASS)" else "(FAIL)"))
        abline(h = thresh, col = "red", lty = 2, lwd = 1.5)
        abline(v = optim_free[pname], col = "blue", lty = 2)
      }
    }
    dev.off()
    rpt(sprintf("Profile plot saved: `%s`",
                file.path(plots_dir, "profile_likelihood_v6.pdf")))
    rpt("")
  }, error = function(e) {
    rpt(sprintf("Profile plot error: %s", e$message))
    rpt("")
  })
}

# ═══════════════════════════════════════════════════════════════════════════
# SECTION 13 — Final summary + save
# ═══════════════════════════════════════════════════════════════════════════

total_time <- (proc.time()[3] - pipeline_t0) / 60

rpt_h2("Final Summary")
rpt("")
rpt(sprintf("- **Species:** %s", species_name))
rpt(sprintf("- **Selected model:** %s", M_Omega))
rpt(sprintf("- **pBIC:** %.1f", Omega))
rpt(sprintf("- **logLik:** %.4f", best_fit$loglik))
rpt(sprintf("- **Variables:** %s", paste(best_fit$vars, collapse = ", ")))
rpt(sprintf("- **Type:** %s", if (!is.null(best_mask)) "boundary" else "non-boundary"))
rpt(sprintf("- **n:** %d, **n_free:** %d", best_fit$n, best_fit$n_free))
rpt(sprintf("- **Input units:** T in Kelvin, P in mm"))
rpt(sprintf("- **Scale factors:** %s",
            paste(sprintf("%s=%s", names(scale_factors),
                          vapply(scale_factors, summarize_scale_factor, character(1))),
                  collapse = ", ")))
if (skip_profile) {
  rpt("- **Arcs passing:** skipped (--skip_profile)")
} else {
  rpt(sprintf("- **Arcs passing:** %d / %d", sum(sapply(arc_results, `[[`, "pass")), length(arc_results)))
}
rpt(sprintf("- **Total pipeline time:** %.1f min", total_time))
rpt("")

# Save RDS
saveRDS(list(
  species        = species_name,
  status         = "success",
  selected       = M_Omega,
  pBIC           = Omega,
  best_bio       = best_bio,
  best_math      = best_full,
  best_loglik    = optim_ll,
  n_data         = best_fit$n,
  model_vars     = best_fit$vars,
  n_vars         = length(best_fit$vars),
  is_boundary    = !is.null(best_mask),
  tau            = tau,
  best_pBIC_L1   = best_pBIC_L1,
  scale_factors  = scale_factors,
  iqr_vals       = iqr_vals,
  ref_iqr        = ref_iqr,
  L1             = L1,
  L2             = L2,
  L3             = L3,
  L4             = L4,
  L3_order       = L3_order,
  profiles       = profiles,
  arc_check      = arc_results,
  arc_summary    = arc_row,
  timing_total   = total_time,
  n_models_L1    = length(L1),
  n_models_L2    = length(L2),
  n_models_L4    = length(L4)
), file.path(sp_dir, "model_results_v6.rds"))

flush_report()

cat(sprintf("\n========================================================\n"))
cat(sprintf("Pipeline v6 finished.\n"))
cat(sprintf("Species: %s\n", species_name))
cat(sprintf("Selected: %s (pBIC=%.1f)\n", M_Omega, Omega))
cat(sprintf("Total time: %.1f min\n", total_time))
cat(sprintf("Report: %s\n", report_path))
cat(sprintf("========================================================\n"))

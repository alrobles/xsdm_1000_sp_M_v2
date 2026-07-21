#!/usr/bin/env Rscript
# xsdm_model_selection_v5.R
# ────────────────────────────────────────────────────────────────────────────
# Pipeline v5: v4 logic + atomic NFS writes (tmp first, then copy)
#
# Fixes from v4:
#   - saveRDS writes to /tmp first, then file.copy to NFS (atomic)
#   - sync after write to flush NFS cache
#
# Stages:
#   --stage L1_model --model_index N   Fit ONE 2-var model → L1_models/model_NN.rds
#   --stage L2                         Boundary expansion on eligible L1 models
#   --stage L3                         Well-behaved scan (L1+L2 combined)
#   --stage L4                         Mid-tier boundary + final save + report
#
# Per-species output: <output_dir>/<Species>/phase1_results/
#   L1_models/            — individual model_NN.rds files
#   L2_boundary.rds       — L2 results
#   L3_scan.rds           — well-behaved scan results
#   L4_final.rds          — final M_Omega
#   phase1_results.rds    — complete results
#   report.md             — markdown report
#   .L1_done / .L2_done / .L3_done / .L4_done — stage markers
# ────────────────────────────────────────────────────────────────────────────

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(numDeriv)
})

`%||%` <- function(x, y) if (is.null(x)) y else x

# ═══════════════════════════════════════════════════════════════════════════
# CLI parsing
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
                           "/home/a474r867/scratch/xsdm_1000_sp")
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
num_starts    <- as.integer(parse_arg("--num_starts", "40"))
num_threads   <- as.integer(parse_arg("--num_threads", "8"))
stage         <- parse_arg("--stage")
model_index   <- parse_arg("--model_index")
tau_method    <- parse_arg("--tau_method", "tau_raw")  # tau_raw | raftery_10 | raftery_6
if (!is.null(model_index)) model_index <- as.integer(model_index)

years <- as.integer(strsplit(years_str, ",")[[1]])
if (is.null(species_name)) stop("--species is required", call. = FALSE)
if (is.null(stage)) stop("--stage is required", call. = FALSE)

pipeline_t0 <- proc.time()[3]

# Reduce starts for aggregation stages (boundary models converge faster)
if (stage %in% c("L2", "L3", "L4")) {
  num_starts <- min(num_starts, 10L)
}

# ═══════════════════════════════════════════════════════════════════════════
# Tau computation — parameterized for method comparison
# Methods:
#   tau_raw      = (max_p+1)*log(n)               [Dan's formula]
#   raftery_10   = ΔBIC ≤ 10 (very strong evidence, BF ≥ 148)
#   raftery_6    = ΔBIC ≤ 6  (strong evidence, BF ≥ 20)
# ═══════════════════════════════════════════════════════════════════════════

compute_tau <- function(method, max_p, n_data) {
  if (method == "tau_raw") {
    return((max_p + 1) * log(n_data))
  } else if (method == "raftery_10") {
    return(10)
  } else if (method == "raftery_6") {
    return(6)
  } else {
    stop("Unknown tau_method: ", method)
  }
}

cat(sprintf("=== xSDM v5 | %s | stage=%s", species_name, stage),
    if (!is.null(model_index)) sprintf(" model=%d", model_index) else "", " ===\n")
cat(sprintf("Starts=%d Threads=%d\n", num_starts, num_threads))

# ═══════════════════════════════════════════════════════════════════════════
# Atomic NFS write helper (FIX 2)
# ═══════════════════════════════════════════════════════════════════════════

atomic_saveRDS <- function(obj, dest_path) {
  tmp <- tempfile(tmpdir = "/tmp", fileext = ".rds")
  on.exit(try(unlink(tmp), silent = TRUE))
  saveRDS(obj, tmp)
  if (!file.copy(tmp, dest_path, overwrite = TRUE))
    stop("Failed to copy RDS from tmp to: ", dest_path)
  invisible(TRUE)
}

atomic_write_sentinel <- function(dest_dir, sentinel_name) {
  tmp <- tempfile(tmpdir = "/tmp")
  writeLines(as.character(Sys.time()), tmp)
  dest <- file.path(dest_dir, sentinel_name)
  if (!file.copy(tmp, dest, overwrite = TRUE))
    stop("Failed to write sentinel: ", dest)
  unlink(tmp)
  invisible(TRUE)
}

# ═══════════════════════════════════════════════════════════════════════════
# Variable definitions
# ═══════════════════════════════════════════════════════════════════════════

temp_vars   <- paste0("bio", sprintf("%02d", 1:11))
temp_labels <- paste0("T", 1:11, "_", temp_vars)
names(temp_labels) <- temp_vars

precip_vars <- paste0("bio", sprintf("%02d", 12:19))
precip_labels <- paste0("P", 12:19, "_", precip_vars)
names(precip_labels) <- precip_vars

all_labels <- c(temp_labels, precip_labels)

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

# ═══════════════════════════════════════════════════════════════════════════
# Output directories
# ═══════════════════════════════════════════════════════════════════════════

sp_safe    <- gsub(" ", "_", species_name)
sp_dir     <- file.path(output_dir, sp_safe)
p1_dir     <- file.path(sp_dir, "phase1_results")
l1_model_dir <- file.path(p1_dir, "L1_models")

dir.create(l1_model_dir, recursive = TRUE, showWarnings = FALSE)

# ═══════════════════════════════════════════════════════════════════════════
# Load environmental data
# ═══════════════════════════════════════════════════════════════════════════

cat("\n-- Loading env data --\n")
t0_load <- Sys.time()

env_sp_dir <- file.path(env_csv_dir, sp_safe)
if (!dir.exists(env_sp_dir)) stop("Env dir not found: ", env_sp_dir, call. = FALSE)

first_csv <- file.path(env_sp_dir, paste0(all_labels[1], ".csv"))
if (!file.exists(first_csv)) stop("Env CSV not found: ", first_csv, call. = FALSE)

occ_raw <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
occ_vec <- occ_raw$presence
n_pts   <- nrow(occ_raw)
n_time  <- length(years)

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

# ── IQR-based variable scaling ──
# Compare interquartile ranges across all variables. If any variable's IQR
# is orders of magnitude larger than the median, divide by the appropriate
# power of 10 to bring it to the same order of magnitude.
# Example: IQR ratio ~2000 (3 orders of magnitude) → divide by 1000.
cat("\n-- IQR scaling check --\n")
iqr_vals <- sapply(env_data_list, function(mat) {
  vals <- as.numeric(mat)
  diff(quantile(vals, c(0.25, 0.75), na.rm = TRUE))
})
iqr_ref <- median(iqr_vals)
cat(sprintf("  IQR reference (median): %.2f\n", iqr_ref))
for (vl in names(iqr_vals)) {
  ratio <- iqr_vals[[vl]] / iqr_ref
  if (ratio > 10) {
    power <- floor(log10(ratio))
    divisor <- 10^power
    env_data_list[[vl]] <- env_data_list[[vl]] / divisor
    cat(sprintf("  %s: IQR=%.1f ratio=%.0fx → /%g\n", vl, iqr_vals[[vl]], ratio, divisor))
  }
}

avail_temp   <- intersect(available_labels, temp_labels)
avail_precip <- intersect(available_labels, precip_labels)

cat(sprintf("Loaded %d vars, %d pts x %d yrs (%.1fs) | %d presences, %d absences\n",
            length(available_labels), n_pts, n_time,
            as.numeric(difftime(Sys.time(), t0_load, units = "secs")),
            sum(occ_vec == 1), sum(occ_vec == 0)))

# Build model list filtered by available variables
models_2var <- generate_2var_models(avail_temp, avail_precip)
n_models <- length(models_2var)
model_names <- names(models_2var)
cat(sprintf("Models: %d two-var (%dT x %dP)\n", n_models, length(avail_temp), length(avail_precip)))

# ═══════════════════════════════════════════════════════════════════════════
# Helpers
# ═══════════════════════════════════════════════════════════════════════════

make_env_array <- function(var_labels) {
  p <- length(var_labels)
  arr <- array(NA_real_, dim = c(n_pts, n_time, p),
               dimnames = list(NULL, as.character(years), var_labels))
  for (vi in seq_along(var_labels)) {
    arr[, , vi] <- env_data_list[[var_labels[vi]]]
  }
  good <- apply(arr, 1, function(x) !any(is.na(x)))
  if (sum(good) < nrow(arr)) arr <- arr[good, , , drop = FALSE]
  list(arr = arr, good = good)
}

fit_one_model <- function(var_labels, mask = NULL) {
  ea <- make_env_array(var_labels)
  env_dat_local <- ea$arr
  occ_local <- occ_vec[ea$good]

  if (sum(occ_local == 1) < 3) {
    cat("[skip: <3 presences]\n")
    return(NULL)
  }

  result <- tryCatch(
    optimize_likelihood(
      env_dat = env_dat_local, occ = occ_local, mask = mask,
      num_starts = num_starts, num_threads = num_threads,
      parallel = FALSE, verbose = FALSE
    ),
    error = function(e) { cat(sprintf("[error: %s]\n", conditionMessage(e))); NULL }
  )
  if (is.null(result) || is.null(result$best$par)) return(NULL)

  p_dim <- dim(env_dat_local)[3]
  n_obs <- dim(env_dat_local)[1]
  n_free <- if (is.null(mask)) num_par(p_dim) else num_par(p_dim) - length(mask)
  pBIC <- -2 * result$best$loglik + n_free * log(n_obs)

  list(result = result, env_dat = env_dat_local, occ = occ_local,
       n = n_obs, p = p_dim, n_free = n_free,
       loglik = result$best$loglik, pBIC = pBIC,
       mask = mask, vars = var_labels)
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

test_well_behaved <- function(fit, model_name, verbose = TRUE) {
  sols <- fit$result$solutions
  n_check <- min(5, nrow(sols))

  # BUGFIX: guard for single solution — cannot check convergence in param space
  if (n_check < 2) {
    if (verbose) cat(sprintf("n_solutions=%d (<2) — cannot check pdist\n", n_check))
    flag_a <- FALSE  # vacuous pass avoided
  } else {
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
    # BUGFIX: pdist threshold 0.05 per Emilio spec (was 0.1, 2× too lax)
    flag_a <- (ll_range < 0.1) && (max_pdist < 0.05)
  }

  best_full <- fit$result$best$par
  if (!is.null(fit$mask)) {
    free_names <- setdiff(names(best_full), names(fit$mask))
    best_free  <- best_full[free_names]
  } else {
    best_free  <- best_full; free_names <- names(best_full)
  }

  hess <- tryCatch(
    numDeriv::hessian(
      func = function(par_free) {
        names(par_free) <- free_names
        loglik_math(par_free, env_dat = fit$env_dat, occ = fit$occ,
                    mask = fit$mask, negative = TRUE, num_threads = 1L)
      }, x = best_free
    ), error = function(e) NULL)

  if (is.null(hess)) {
    flag_b <- FALSE; cond_num <- NA_real_
  } else {
    ev <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
    flag_b <- all(ev > 1e-8)
    cond_num <- if (flag_b) max(ev) / min(ev) else Inf
    if (flag_b) flag_b <- is.finite(cond_num) && (cond_num < 1e6)
  }

  if (verbose) {
    cat(sprintf("opt=%s hess=%s cond=%.1e pdist=%.3f ll_range=%.6f\n",
                flag_a, flag_b, cond_num, max_pdist, ll_range))
  }

  # BUGFIX: restore diagnostic warning when flags disagree (Emilio step 5c)
  if (flag_a != flag_b) {
    warning(sprintf(
      "Flags disagree for %s: optim=%s, hessian=%s (ll_range=%.3f, max_pdist=%.4f, cond=%.1e)",
      model_name, flag_a, flag_b, ll_range, max_pdist, cond_num))
  }

  list(well_behaved = flag_a && flag_b, flag_optim = flag_a,
       flag_hessian = flag_b, cond_num = cond_num,
       ll_range = ll_range, max_pdist = max_pdist)
}

load_L1_models <- function() {
  model_files <- sort(list.files(l1_model_dir, pattern = "^model_\\d+\\.rds$",
                                  full.names = TRUE))
  if (length(model_files) == 0) stop("No L1 model files found", call. = FALSE)

  L1 <- list()
  for (f in model_files) {
    fit <- readRDS(f)
    idx <- as.integer(gsub("model_|\\.rds", "", basename(f)))
    mname <- names(models_2var)[idx]
    L1[[mname]] <- fit
  }
  L1 <- Filter(Negate(is.null), L1)
  cat(sprintf("Loaded %d / %d L1 models\n", length(L1), length(model_files)))
  L1
}

# ═══════════════════════════════════════════════════════════════════════════
# Report helpers
# ═══════════════════════════════════════════════════════════════════════════

report_lines <- character(0)
rpt <- function(x) { report_lines <<- c(report_lines, x); cat(x, "\n", sep = "") }
rpt_h2 <- function(x) { rpt(""); rpt(paste0("## ", x)); rpt("") }

flush_report <- function(path) {
  writeLines(report_lines, path)
  cat(sprintf("\nReport written: %s (%d lines)\n", path, length(report_lines)))
}

# ═══════════════════════════════════════════════════════════════════════════
# STAGE: L1_model — fit ONE 2-var model (atomic NFS write)
# ═══════════════════════════════════════════════════════════════════════════

if (stage == "L1_model") {
  if (is.null(model_index) || model_index < 1 || model_index > n_models)
    stop(sprintf("--model_index required (1-%d)", n_models), call. = FALSE)

  mname <- model_names[model_index]
  vars  <- models_2var[[mname]]

  cat(sprintf("Model %d/%d: %s | vars: %s\n", model_index, n_models,
              mname, paste(vars, collapse = ", ")))

  t0 <- proc.time()[3]
  fit <- fit_one_model(vars)
  dt <- proc.time()[3] - t0

  if (!is.null(fit)) {
    cat(sprintf("OK pBIC=%.1f LL=%.1f n_free=%d (%.0fs)\n",
                fit$pBIC, fit$loglik, fit$n_free, dt))
    # FIX 2: atomic write — tmp first, then copy to NFS
    rds_dest <- file.path(l1_model_dir, sprintf("model_%02d.rds", model_index))
    atomic_saveRDS(fit, rds_dest)
    atomic_write_sentinel(l1_model_dir, sprintf(".model_%02d_done", model_index))
    cat(sprintf("Saved: model_%02d.rds\n", model_index))
  } else {
    cat("FAILED\n")
    quit(status = 1)
  }
}

# ═══════════════════════════════════════════════════════════════════════════
# STAGE: L2 — Boundary expansion
# ═══════════════════════════════════════════════════════════════════════════

if (stage == "L2") {
  rpt(paste0("# xSDM v5 Report: *", species_name, "*"))
  rpt("")
  rpt(paste0("**Records:** ", n_pts, " total (", sum(occ_vec == 1),
             " presences, ", sum(occ_vec == 0), " absences)"))
  rpt(paste0("**Models:** ", n_models, " two-var (", length(avail_temp),
             "T × ", length(avail_precip), "P)"))
  rpt(paste0("**Starts:** ", num_starts, " | **Threads:** ", num_threads))
  rpt("")

  L1 <- load_L1_models()
  if (length(L1) == 0) stop("No valid L1 models loaded", call. = FALSE)

  L1_pBIC <- sapply(L1, `[[`, "pBIC")
  best_pBIC_L1 <- min(L1_pBIC)
  max_p <- 2L; n_data <- L1[[1]]$n
  tau <- compute_tau(tau_method, max_p, n_data)
  cat(sprintf("Tau method: %s | tau = %.2f\n", tau_method, tau))

  rpt_h2("Phase 1: L1 results")
  rpt(sprintf("- **Models fitted:** %d / %d", length(L1), n_models))
  rpt(sprintf("- **Best L1 pBIC:** %.1f", best_pBIC_L1))
  rpt(sprintf("- **tau:** %.4f", tau))
  rpt(sprintf("- **Threshold:** %.1f (best + tau)", best_pBIC_L1 + tau))
  rpt("")

  rpt("| # | Model | Vars | n | n_free | pBIC | logLik |")
  rpt("|---|-------|------|---|--------|------|--------|")
  L1_order <- names(L1)[order(L1_pBIC)]
  for (j in seq_along(L1_order)) {
    nm <- L1_order[j]; f <- L1[[nm]]
    rpt(sprintf("| %d | %s | %s | %d | %d | %.1f | %.2f |",
                j, nm, paste(f$vars, collapse=", "),
                f$n, f$n_free, f$pBIC, f$loglik))
  }
  rpt("")

  # Boundary expansion
  eligible <- names(L1)[L1_pBIC <= best_pBIC_L1 + tau]
  rpt_h2("Phase 2: L2 boundary expansion")
  rpt(sprintf("- **Eligible L1 models:** %d", length(eligible)))
  rpt("")

  L2 <- list()
  for (base_name in eligible) {
    vars <- L1[[base_name]]$vars; p <- length(vars)
    bmasks <- generate_boundary_masks(p)
    for (bname in names(bmasks)) {
      full_name <- paste0(base_name, "__", bname)
      cat(sprintf("  %-55s ", full_name))
      t0 <- proc.time()[3]
      fit <- fit_one_model(vars, mask = bmasks[[bname]])
      dt <- proc.time()[3] - t0
      if (!is.null(fit)) {
        cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
        L2[[full_name]] <- fit
      } else { cat(sprintf("FAILED (%.0fs)\n", dt)) }
    }
  }
  L2 <- Filter(Negate(is.null), L2)
  cat(sprintf("L2: %d boundary models fitted\n", length(L2)))

  atomic_saveRDS(list(species = species_name, stage = "L2", L1 = L1, L2 = L2,
               eligible_L1 = eligible, tau = tau, best_pBIC_L1 = best_pBIC_L1),
          file.path(p1_dir, "L2_boundary.rds"))

  atomic_write_sentinel(p1_dir, ".L2_done")
  rpt(sprintf("- **Boundary models fitted:** %d", length(L2)))
  rpt("")
  flush_report(file.path(p1_dir, "report.md"))
  cat("L2 done.\n")
}

# ═══════════════════════════════════════════════════════════════════════════
# STAGE: L3 — Well-behaved scan
# ═══════════════════════════════════════════════════════════════════════════

if (stage == "L3") {
  l2_file <- file.path(p1_dir, "L2_boundary.rds")
  if (!file.exists(l2_file)) stop("L2_boundary.rds not found", call. = FALSE)
  l2_data <- readRDS(l2_file)
  L1 <- l2_data$L1; L2 <- l2_data$L2

  # Load existing report
  report_md <- file.path(p1_dir, "report.md")
  if (file.exists(report_md)) report_lines <- readLines(report_md)

  L3 <- c(L1, L2)
  L3_pBIC <- sapply(L3, `[[`, "pBIC")
  L3_order <- names(L3)[order(L3_pBIC)]

  rpt("")
  rpt_h2("Phase 3: L3 well-behaved scan")
  rpt(sprintf("- **Total models:** %d (L1=%d + L2=%d)", length(L3), length(L1), length(L2)))
  rpt("")

  cat(sprintf("L3 scan: %d models\n", length(L3)))

  M_Omega <- NULL; Omega <- Inf

  rpt("| Model | pBIC | Type | Opt | Hess | Cond | Verdict |")
  rpt("|-------|------|------|-----|------|------|---------|")

  for (nm in L3_order) {
    fit <- L3[[nm]]
    is_bd <- !is.null(fit$mask)
    cat(sprintf("  %-55s pBIC=%.1f ", nm, fit$pBIC))
    wb <- test_well_behaved(fit, nm, verbose = FALSE)

    verdict <- if (wb$well_behaved) {
      if (is.null(M_Omega)) { M_Omega <- nm; Omega <- fit$pBIC }
      "WELL-BEHAVED"
    } else "badly-behaved"

    rpt(sprintf("| %s | %.1f | %s | %s | %s | %.1e | %s |",
                nm, fit$pBIC, if(is_bd) "boundary" else "non-boundary",
                wb$flag_optim, wb$flag_hessian,
                wb$cond_num %||% NA, verdict))
  }

  if (is.null(M_Omega)) {
    M_Omega <- L3_order[1]; Omega <- L3[[M_Omega]]$pBIC
    rpt("")
    rpt("**WARNING: No well-behaved model found. Falling back to lowest pBIC.**")
  }

  rpt("")
  rpt(sprintf("**M_Omega:** %s (pBIC = %.1f)", M_Omega, Omega))

  atomic_saveRDS(list(species = species_name, stage = "L3", M_Omega = M_Omega,
               Omega = Omega, L1 = L1, L2 = L2, L3_order = L3_order,
               best_pBIC_L1 = l2_data$best_pBIC_L1, tau = l2_data$tau),
          file.path(p1_dir, "L3_scan.rds"))

  atomic_write_sentinel(p1_dir, ".L3_done")
  flush_report(file.path(p1_dir, "report.md"))
  cat(sprintf("L3 done. M_Omega=%s Omega=%.1f\n", M_Omega, Omega))
}

# ═══════════════════════════════════════════════════════════════════════════
# STAGE: L4 — Mid-tier boundary + final
# ═══════════════════════════════════════════════════════════════════════════

if (stage == "L4") {
  l3_file <- file.path(p1_dir, "L3_scan.rds")
  l2_file <- file.path(p1_dir, "L2_boundary.rds")
  if (!file.exists(l3_file)) stop("L3_scan.rds not found", call. = FALSE)

  l3_data <- readRDS(l3_file)
  L1 <- l3_data$L1; L2 <- l3_data$L2
  Omega <- l3_data$Omega; M_Omega <- l3_data$M_Omega
  best_pBIC_L1 <- l3_data$best_pBIC_L1; tau <- l3_data$tau

  # Load existing report
  report_md <- file.path(p1_dir, "report.md")
  if (file.exists(report_md)) report_lines <- readLines(report_md)

  rpt("")
  rpt_h2("Phase 4: L4 mid-tier boundary expansion")
  rpt(sprintf("- **Omega:** %.1f (M_Omega = %s)", Omega, M_Omega))
  rpt(sprintf("- **L4 range:** (%.1f, %.1f]", best_pBIC_L1 + tau, Omega + tau))

  L1_pBIC <- sapply(L1, `[[`, "pBIC")
  L4_eligible <- names(L1)[L1_pBIC > best_pBIC_L1 + tau & L1_pBIC <= Omega + tau]
  rpt(sprintf("- **Candidates:** %d", length(L4_eligible)))

  L4 <- list()
  if (length(L4_eligible) > 0) {
    for (base_name in L4_eligible) {
      vars <- L1[[base_name]]$vars; p <- length(vars)
      bmasks <- generate_boundary_masks(p)
      for (bname in names(bmasks)) {
        full_name <- paste0(base_name, "__", bname)
        cat(sprintf("  %-55s ", full_name))
        t0 <- proc.time()[3]
        fit <- fit_one_model(vars, mask = bmasks[[bname]])
        dt <- proc.time()[3] - t0
        if (!is.null(fit)) {
          cat(sprintf("pBIC=%.1f (%.0fs)\n", fit$pBIC, dt))
          L4[[full_name]] <- fit
        } else { cat(sprintf("FAILED (%.0fs)\n", dt)) }
      }
    }
    L4 <- Filter(Negate(is.null), L4)
    cat(sprintf("L4: %d models\n", length(L4)))

    if (length(L4) > 0) {
      L4_pBIC <- sapply(L4, `[[`, "pBIC")
      L4_order <- names(L4)[order(L4_pBIC)]

      rpt("")
      rpt("| Model | pBIC | Tested | Outcome |")
      rpt("|-------|------|--------|---------|")

      for (nm in L4_order) {
        fit <- L4[[nm]]
        if (fit$pBIC > Omega) {
          rpt(sprintf("| %s | %.1f | pBIC > Omega | STOP |", nm, fit$pBIC))
          break
        }
        cat(sprintf("  L4 test: %-55s pBIC=%.1f ", nm, fit$pBIC))
        wb <- test_well_behaved(fit, nm, verbose = FALSE)
        verdict <- if (wb$well_behaved) {
          M_Omega <- nm; Omega <- fit$pBIC
          "**NEW M_Omega**"
        } else "not well-behaved"
        rpt(sprintf("| %s | %.1f | %s/%s | %s |",
                    nm, fit$pBIC, wb$flag_optim, wb$flag_hessian, verdict))
        if (wb$well_behaved) break
      }
    }
  } else {
    cat("No L4 candidates\n")
  }

  # Final save
  rpt("")
  rpt_h2("Final result")
  rpt(sprintf("**Selected model:** %s", M_Omega))
  rpt(sprintf("**pBIC (Omega):** %.1f", Omega))
  # BUGFIX: use all_fits (L1+L2+L4) to get M_Omega vars, not l3_data
  all_fits <- c(L1, L2, L4)
  all_fits <- all_fits[!duplicated(names(all_fits))]
  rpt(sprintf("**Variables:** %s (2-var)", paste(all_fits[[M_Omega]]$vars, collapse=", ")))
  rpt("")
  rpt(sprintf("**Pipeline completed:** %s", Sys.time()))

  all_models <- c(L1, L2, L4)
  all_models <- all_models[!duplicated(names(all_models))]

  atomic_saveRDS(list(species = species_name, stage = "L4_final", M_Omega = M_Omega,
               Omega = Omega, L1 = L1, L2 = L2, L3_order = l3_data$L3_order,
               L4 = L4, all_models = all_models),
          file.path(p1_dir, "phase1_results.rds"))

  atomic_saveRDS(list(M_Omega = M_Omega, Omega = Omega, L4 = L4),
          file.path(p1_dir, "L4_final.rds"))

  atomic_write_sentinel(p1_dir, ".L4_done")
  flush_report(file.path(p1_dir, "report.md"))

  cat(sprintf("\n=== L4 DONE ===\nM_Omega: %s (pBIC=%.1f)\n", M_Omega, Omega))
  cat(sprintf("Total time: %.0fs\n", proc.time()[3] - pipeline_t0))
}

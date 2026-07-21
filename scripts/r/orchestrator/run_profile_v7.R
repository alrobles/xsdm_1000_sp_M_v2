#!/usr/bin/env Rscript
# run_profile.R — Runs adaptive profile likelihood on the selected model
#   --model_rds "/path/to/model.rds"
#   --output_dir "/path/to/species/dir"
#   --num_threads 4

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(numDeriv)
})

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

model_rds   <- parse_arg("--model_rds")
output_dir  <- parse_arg("--output_dir")
num_threads <- as.integer(parse_arg("--num_threads", "4"))

if (is.null(model_rds))  stop("--model_rds required", call. = FALSE)
if (is.null(output_dir)) stop("--output_dir required", call. = FALSE)

fit <- readRDS(model_rds)
if (fit$status != "success") stop("Model not successful", call. = FALSE)

cat(sprintf("Profile: %s | %s | pBIC=%.1f\n", fit$species, fit$model_name, fit$pBIC))

# ─── Setup ───────────────────────────────────────────────────────────────────

best_full <- fit$best_par
best_mask <- fit$mask

if (!is.null(best_mask)) {
  free_names <- setdiff(names(best_full), names(best_mask))
  optim_free <- best_full[free_names]
} else {
  optim_free <- best_full
  free_names <- names(best_full)
}

# Hessian for adaptive stepping
hess <- tryCatch(
  numDeriv::hessian(
    func = function(par_free) {
      names(par_free) <- free_names
      loglik_math(par_free, env_dat = fit$env_dat, occ = fit$occ,
                  mask = best_mask, negative = TRUE, num_threads = 1L)
    },
    x = optim_free
  ),
  error = function(e) diag(length(optim_free))
)

# ─── Adaptive profile for each free parameter ────────────────────────────────

alpha <- 0.95

profiles <- list()
for (pname in free_names) {
  cat(sprintf("  Profiling %s: ", pname))

  idx  <- which(names(optim_free) == pname)
  h_ii <- abs(hess[idx, idx])

  if (h_ii < 1e-12 || !is.finite(h_ii)) {
    increment <- 0.1; n_steps <- 50L
  } else {
    expected_dist <- sqrt(qchisq(alpha, df = 1) / h_ii)
    increment <- max(expected_dist / 15L, 0.01)
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
      env_dat            = fit$env_dat,
      occ                = fit$occ,
      mask               = best_mask,
      num_threads        = num_threads,
      verbose            = FALSE
    ),
    error = function(e) NULL
  )

  # Adaptive extension if threshold not crossed
  if (!is.null(prof)) {
    pdat    <- prof$profile
    thresh  <- prof$threshold
    idx_max <- which.max(pdat$loglik)
    left_crossed  <- idx_max > 1 && any(pdat$loglik[1:(idx_max-1)] <= thresh)
    right_crossed <- idx_max < nrow(pdat) &&
      any(pdat$loglik[(idx_max+1):nrow(pdat)] <= thresh)

    round <- 1L
    while ((!left_crossed || !right_crossed) && round < 3L) {
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
          env_dat            = fit$env_dat,
          occ                = fit$occ,
          mask               = best_mask,
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
  }

  profiles[[pname]] <- prof
  cat(if (!is.null(prof)) "OK\n" else "FAILED\n")
}

# ─── Arc check ───────────────────────────────────────────────────────────────

optim_ll <- fit$loglik
arc_results <- list()
all_pass <- TRUE

for (pname in free_names) {
  prof <- profiles[[pname]]
  if (is.null(prof)) {
    arc_results[[pname]] <- list(pass = FALSE, reason = "null_profile")
    all_pass <- FALSE
    next
  }
  pdat    <- prof$profile
  thresh  <- prof$threshold
  idx_max <- which.max(pdat$loglik)

  found_better  <- any(pdat$loglik > optim_ll + .Machine$double.eps)
  left_crosses  <- idx_max > 1 && any(pdat$loglik[1:(idx_max-1)] <= thresh)
  right_crosses <- idx_max < nrow(pdat) &&
    any(pdat$loglik[(idx_max+1):nrow(pdat)] <= thresh)

  left_mono <- TRUE; right_mono <- TRUE
  if (idx_max > 2) {
    left_vals <- pdat$loglik[1:(idx_max-1)]
    left_mono <- all(diff(left_vals) >= -0.5)
  }
  if (idx_max < nrow(pdat) - 1) {
    right_vals <- pdat$loglik[(idx_max+1):nrow(pdat)]
    right_mono <- all(diff(right_vals) <= 0.5)
  }

  pass <- left_crosses && right_crosses && left_mono && right_mono && !found_better
  if (!pass) all_pass <- FALSE

  reasons <- character(0)
  if (!left_crosses)  reasons <- c(reasons, "no_left_crossing")
  if (!right_crosses) reasons <- c(reasons, "no_right_crossing")
  if (!left_mono)     reasons <- c(reasons, "left_not_monotone")
  if (!right_mono)    reasons <- c(reasons, "right_not_monotone")
  if (found_better)   reasons <- c(reasons, "found_better_ll")

  arc_results[[pname]] <- list(pass = pass,
    reason = if (length(reasons) == 0) "pass" else paste(reasons, collapse = ";"))
}

cat(sprintf("\nArc check: %d/%d pass → %s\n",
            sum(sapply(arc_results, `[[`, "pass")), length(arc_results),
            if (all_pass) "ALL PASS" else "SOME FAIL"))

# ─── Save ────────────────────────────────────────────────────────────────────

plots_dir <- file.path(output_dir, "plots")
dir.create(plots_dir, recursive = TRUE, showWarnings = FALSE)

# Profile plot
tryCatch({
  n_plots <- length(free_names)
  pdf(file.path(plots_dir, "profile_likelihood_v7.pdf"),
      width = 4 * min(n_plots, 4), height = 4 * ceiling(n_plots / 4))
  par(mfrow = c(ceiling(n_plots / 4), min(n_plots, 4)))
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
}, error = function(e) cat(sprintf("Plot error: %s\n", e$message)))

# Save final results
best_bio <- tryCatch(math_to_bio(best_full), error = function(e) best_full)

final <- list(
  species     = fit$species,
  model_name  = fit$model_name,
  pBIC        = fit$pBIC,
  loglik      = fit$loglik,
  best_par    = best_full,
  best_bio    = best_bio,
  vars        = fit$vars,
  mask        = best_mask,
  n           = fit$n,
  n_free      = fit$n_free,
  profiles    = profiles,
  arc_results = arc_results,
  all_arcs_pass = all_pass
)

saveRDS(final, file.path(output_dir, "profile_results_v7.rds"))
cat(sprintf("Profile results saved: %s\n", file.path(output_dir, "profile_results_v7.rds")))

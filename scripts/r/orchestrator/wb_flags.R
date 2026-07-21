wb_safe_dist <- function(par1, par2) {
  tryCatch({
    d <- dist_between_params(par1, par2, mask = NULL)
    if (is.list(d)) d$distance else d
  }, error = function(e) NA_real_)
}

wb_compute_result <- function(fit, verbose = TRUE) {
  if (is.null(fit) || is.null(fit$status) || fit$status != "success") {
    stop("wb_compute_result requires a successful fit object", call. = FALSE)
  }

  if (isTRUE(verbose)) {
    cat(sprintf("Checking well-behaved: %s (pBIC=%.1f)\n", fit$model_name, fit$pBIC))
  }

  sols <- fit$solutions
  n_sols <- if (!is.null(nrow(sols))) nrow(sols) else length(sols$loglik)

  n_check <- min(3, n_sols)
  if (n_check > 0) {
    top_ll <- as.numeric(sols$loglik[seq_len(n_check)])
    ll_range <- max(top_ll) - min(top_ll)

    top_pars <- sols$full_par[seq_len(n_check)]
    if (n_check > 1) {
      pdists <- vapply(2:n_check, function(i) {
        wb_safe_dist(top_pars[[1]], top_pars[[i]])
      }, numeric(1))
      max_pdist <- if (all(is.na(pdists))) NA_real_ else max(pdists, na.rm = TRUE)
    } else {
      max_pdist <- 0
    }
  } else {
    ll_range <- NA_real_
    max_pdist <- NA_real_
  }

  flag_a <- isTRUE(!is.na(ll_range) && !is.na(max_pdist) && (ll_range < 0.1) && (max_pdist < 0.05))
  if (isTRUE(verbose)) {
    cat(sprintf("  Flag A: ll_range=%.6f, max_pdist=%.6f → %s\n",
                ll_range, max_pdist, if (flag_a) "PASS" else "FAIL"))
  }

  best_full <- fit$best_par
  if (!is.null(fit$mask)) {
    free_names <- setdiff(names(best_full), names(fit$mask))
    best_free  <- best_full[free_names]
  } else {
    best_free  <- best_full
    free_names <- names(best_full)
  }

  # ─── Boundary-aware Flag B: drop parameters sitting on a bio-boundary ────────
  # `pd` is a probability in biological scale.  When it collapses to 0 or 1,
  # the math-scale Hessian contains a flat/zero-curvature direction that blows
  # up the condition number and fails Flag B, even though the remaining free
  # parameters are well identified.  We therefore recompute Flag B after fixing
  # saturated `pd` at the corresponding bound (Inf / -Inf in math scale).
  PD_BIO_TOL <- 1e-6

  best_bio <- tryCatch(xsdm::math_to_bio(best_full), error = function(e) NULL)
  saturated_params <- character(0)
  if (!is.null(best_bio) && !is.null(best_bio$pd)) {
    if (best_bio$pd <= PD_BIO_TOL) saturated_params <- c(saturated_params, "pd")
    if (best_bio$pd >= 1 - PD_BIO_TOL) saturated_params <- c(saturated_params, "pd")
  }

  mask_reduced <- fit$mask
  if (length(saturated_params) > 0L) {
    if (is.null(mask_reduced)) mask_reduced <- numeric(0)
    if ("pd" %in% saturated_params) {
      pd_bound <- if (best_bio$pd >= 1 - PD_BIO_TOL) Inf else -Inf
      mask_reduced["pd"] <- pd_bound
    }
  }
  free_names_reduced <- setdiff(names(best_full), names(mask_reduced))
  best_free_reduced <- if (length(saturated_params) > 0L) best_full[free_names_reduced] else best_free

  nll_fun <- function(par_free) {
    names(par_free) <- free_names
    loglik_math(
      par_free,
      env_dat = fit$env_dat,
      occ = fit$occ,
      mask = fit$mask,
      negative = TRUE,
      num_threads = 1L
    )
  }

  nll_fun_reduced <- function(par_free) {
    names(par_free) <- free_names_reduced
    loglik_math(
      par_free,
      env_dat = fit$env_dat,
      occ = fit$occ,
      mask = mask_reduced,
      negative = TRUE,
      num_threads = 1L
    )
  }

  EVAL_POS_TOL <- 1e-8
  COND_MAX <- 1e6
  EVAL_POS_TOL_RELAXED <- -1e-6
  COND_MAX_RELAXED <- 1e8

  evaluate_flag_b <- function(hess) {
    if (is.null(hess)) {
      return(list(flag = FALSE, flag_relaxed = FALSE, cond_num = NA_real_,
                  min_eval = NA_real_, max_eval = NA_real_, n_neg = NA_integer_,
                  evals = NULL))
    }
    hess <- (hess + t(hess)) / 2
    evals <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
    min_eval <- min(evals)
    max_eval <- max(evals)
    n_neg <- sum(evals <= 0)
    cond_num <- if (min_eval > 0) max_eval / min_eval else Inf
    flag <- all(evals > EVAL_POS_TOL) && is.finite(cond_num) && (cond_num < COND_MAX)
    flag_relaxed <- all(evals > EVAL_POS_TOL_RELAXED) && is.finite(cond_num) && (cond_num < COND_MAX_RELAXED)
    list(flag = flag, flag_relaxed = flag_relaxed, cond_num = cond_num,
         min_eval = min_eval, max_eval = max_eval, n_neg = n_neg, evals = evals)
  }

  hess <- tryCatch(
    numDeriv::hessian(func = nll_fun, x = best_free),
    error = function(e) NULL
  )

  hess_reduced <- if (length(saturated_params) > 0L) {
    tryCatch(
      numDeriv::hessian(func = nll_fun_reduced, x = best_free_reduced),
      error = function(e) NULL
    )
  } else {
    NULL
  }

  res_full <- evaluate_flag_b(hess)
  res_reduced <- evaluate_flag_b(hess_reduced)

  # If a parameter is saturated on a boundary and the reduced-space Hessian is
  # well-conditioned, trust the reduced-space curvature.
  if (length(saturated_params) > 0L && res_reduced$flag) {
    flag_b_hessian <- res_reduced$flag
    flag_b_hessian_relaxed <- res_reduced$flag_relaxed
    cond_num_hessian <- res_reduced$cond_num
    min_eval_hessian <- res_reduced$min_eval
    max_eval_hessian <- res_reduced$max_eval
    n_neg_hessian <- res_reduced$n_neg
    evals_hessian <- res_reduced$evals
    hess_used <- hess_reduced
  } else {
    flag_b_hessian <- res_full$flag
    flag_b_hessian_relaxed <- res_full$flag_relaxed
    cond_num_hessian <- res_full$cond_num
    min_eval_hessian <- res_full$min_eval
    max_eval_hessian <- res_full$max_eval
    n_neg_hessian <- res_full$n_neg
    evals_hessian <- res_full$evals
    hess_used <- hess
  }

  if (isTRUE(verbose)) {
    cat(sprintf("  Flag B (hessian): cond=%.2e, saturated=%s → %s\n",
                cond_num_hessian,
                if (length(saturated_params) > 0L) paste(saturated_params, collapse = ",") else "none",
                if (flag_b_hessian) "PASS" else "FAIL"))
  }

  J <- tryCatch(
    numDeriv::jacobian(
      func = function(p) numDeriv::grad(func = nll_fun, x = p),
      x = best_free
    ),
    error = function(e) NULL
  )

  hess_jac <- NULL
  flag_b_jac <- FALSE
  flag_b_jac_relaxed <- FALSE
  cond_num_jac <- NA_real_
  min_eval_jac <- NA_real_
  max_eval_jac <- NA_real_
  n_neg_jac <- NA_integer_
  evals_jac <- NULL

  if (!is.null(J)) {
    hess_jac <- (J + t(J)) / 2
    evals_jac <- eigen(hess_jac, symmetric = TRUE, only.values = TRUE)$values
    min_eval_jac <- min(evals_jac)
    max_eval_jac <- max(evals_jac)
    n_neg_jac <- sum(evals_jac <= 0)
    cond_num_jac <- if (min(evals_jac) > 0) max(evals_jac) / min(evals_jac) else Inf
    flag_b_jac <- all(evals_jac > EVAL_POS_TOL) && is.finite(cond_num_jac) && cond_num_jac < COND_MAX
    flag_b_jac_relaxed <- all(evals_jac > EVAL_POS_TOL_RELAXED) && is.finite(cond_num_jac) && cond_num_jac < COND_MAX_RELAXED
  }

  if (isTRUE(verbose)) {
    cat(sprintf("  Flag B (jac): cond=%.2e → %s\n",
                cond_num_jac, if (flag_b_jac) "PASS" else "FAIL"))
  }

  PDIST_THRESH <- 0.05
  n_converged <- NA_integer_
  if (n_sols > 0) {
    best_par_list <- sols$full_par[[1]]
    if (n_sols > 1) {
      all_dists <- vapply(2:n_sols, function(i) wb_safe_dist(best_par_list, sols$full_par[[i]]), numeric(1))
      n_converged <- sum(all_dists < PDIST_THRESH, na.rm = TRUE) + 1L
    } else {
      n_converged <- 1L
    }
  }
  well_behaved <- flag_a && flag_b_hessian

  if (isTRUE(verbose)) {
    cat(sprintf("  VERDICT: %s\n", if (well_behaved) "WELL-BEHAVED" else "BADLY-BEHAVED"))
  }

  list(
    model_name = fit$model_name,
    well_behaved = well_behaved,
    flag_a = flag_a,
    flag_b = flag_b_hessian,
    flag_b_relaxed = flag_b_hessian_relaxed,
    ll_range = ll_range,
    max_pdist = max_pdist,
    cond_num = cond_num_hessian,
    min_eval = min_eval_hessian,
    max_eval = max_eval_hessian,
    n_neg_evals = n_neg_hessian,
    hessian_method = "operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison",
    hessian = hess_used,
    eigenvalues = evals_hessian,
    pBIC = fit$pBIC,
    eigenvalues_hessian = evals_hessian,
    cond_num_hessian = cond_num_hessian,
    min_eval_hessian = min_eval_hessian,
    max_eval_hessian = max_eval_hessian,
    n_neg_hessian = n_neg_hessian,
    flag_b_hessian = flag_b_hessian,
    flag_b_hessian_relaxed = flag_b_hessian_relaxed,
    hessian_jac = hess_jac,
    eigenvalues_jac = evals_jac,
    cond_num_jac = cond_num_jac,
    min_eval_jac = min_eval_jac,
    max_eval_jac = max_eval_jac,
    n_neg_jac = n_neg_jac,
    flag_b_jac = flag_b_jac,
    flag_b_jac_relaxed = flag_b_jac_relaxed,
    n_converged = n_converged,
    saturated_params = saturated_params,
    flag_b_hessian_full = res_full$flag,
    cond_num_hessian_full = res_full$cond_num
  )
}

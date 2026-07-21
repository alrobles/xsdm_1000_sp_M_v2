#!/usr/bin/env Rscript
# generate_report.R — Builds the per-species Algorithm2 selection report.
#
# Consumes the artefacts produced by orchestrate_v7.sh for one species:
#   <species_dir>/models/*.rds           (fit_single_model_v7.R outputs)
#   <species_dir>/wb/*_wb.rds            (check_well_behaved.R outputs)
#   <species_dir>/profile_results_v7.rds  (run_profile.R output)
#   <species_dir>/plots/profile_likelihood_v7.png
#   <species_dir>/plots/habitat_suitability_v7.png
# plus the orchestrator's selection-trail metadata (selection_meta.tsv).
#
# Emits a single Markdown report documenting the literal Algorithm2
# selection rules and the full L1–L4 selection trail.
#
#   --species_dir "/path/to/outputs/<species>"
#   --meta        "/path/to/outputs/<species>/selection_meta.tsv"
#   --output      "/path/to/outputs/<species>/model_selection_report.md"

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_dir <- parse_arg("--species_dir")
meta_file   <- parse_arg("--meta")
output_file <- parse_arg("--output")

if (is.null(species_dir)) stop("--species_dir required", call. = FALSE)
if (is.null(meta_file))   stop("--meta required", call. = FALSE)
if (is.null(output_file)) stop("--output required", call. = FALSE)

`%||%` <- function(a, b) if (is.null(a)) b else a

.lines <- character(0)
rpt <- function(...) .lines[[length(.lines) + 1]] <<- paste0(...)
fmtn <- function(x, d = 1) {
  v <- suppressWarnings(as.numeric(x))
  if (length(v) == 0) return("NA")
  out <- ifelse(is.na(v), "NA", formatC(v, format = "f", digits = d))
  paste(out, collapse = ", ")
}

meta_raw <- readLines(meta_file, warn = FALSE)
scalars  <- list()
L1_meta  <- list()
L2_names <- character(0)
L4_names <- character(0)
scanned_models <- character(0)
for (ln in meta_raw) {
  f <- strsplit(ln, "\t", fixed = TRUE)[[1]]
  if (length(f) < 2) next
  key <- f[1]
  if (key == "L1") {
    L1_meta[[f[2]]] <- as.numeric(f[3])
  } else if (key == "L2_MODEL") {
    L2_names <- c(L2_names, f[2])
  } else if (key == "L4_MODEL") {
    L4_names <- c(L4_names, f[2])
  } else if (key == "SCANNED_MODEL") {
    scanned_models <- c(scanned_models, f[2])
  } else {
    scalars[[key]] <- f[2]
  }
}

species      <- if (is.null(scalars$SPECIES)) basename(species_dir) else scalars$SPECIES
n_data       <- as.numeric(scalars$N_DATA)
max_p        <- as.numeric(scalars$MAX_P %||% "3")
tau          <- as.numeric(scalars$TAU)
best_pBIC_L1 <- as.numeric(scalars$BEST_PBIC_L1)
threshold    <- as.numeric(scalars$THRESHOLD_L2)
Omega        <- as.numeric(scalars$OMEGA)
M_OMEGA      <- scalars$M_OMEGA %||% ""
has_omega    <- !(is.null(M_OMEGA) || is.na(M_OMEGA) || M_OMEGA %in% c("", "NA", "NONE", "none"))
omega_tau    <- as.numeric(scalars$OMEGA_TAU)

models_dir <- file.path(species_dir, "models")
wb_dir     <- file.path(species_dir, "wb")

read_models <- function() {
  files <- list.files(models_dir, pattern = "\\.rds$", full.names = TRUE)
  out <- list()
  for (f in files) {
    x <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.null(x) && !is.null(x$model_name)) out[[x$model_name]] <- x
  }
  out
}

read_wb <- function() {
  files <- list.files(wb_dir, pattern = "_wb\\.rds$", full.names = TRUE)
  out <- list()
  for (f in files) {
    x <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.null(x) && !is.null(x$model_name)) out[[x$model_name]] <- x
  }
  out
}

flatten_restart_rep <- function(rep) {
  p <- length(rep$mu)
  o_vec <- as.numeric(as.vector(rep$o_mat))
  c(
    as.list(stats::setNames(as.numeric(rep$mu), paste0("mu", seq_len(p)))),
    as.list(stats::setNames(as.numeric(rep$sigltil), paste0("sigltil", seq_len(p)))),
    as.list(stats::setNames(as.numeric(rep$sigrtil), paste0("sigrtil", seq_len(p)))),
    list(ctil = as.numeric(rep$ctil), pd = as.numeric(rep$pd)),
    as.list(stats::setNames(o_vec, paste0("o_mat", seq_along(o_vec))))
  )
}

build_restart_table <- function(m, n_show = 10) {
  if (is.null(m) || is.null(m$solutions)) return(NULL)
  sols <- m$solutions
  if (is.null(sols) || is.null(sols$full_par) || length(sols$full_par) == 0) return(NULL)
  n_sols <- if (!is.null(nrow(sols))) nrow(sols) else length(sols$loglik)
  if (n_sols <= 0) return(NULL)
  n_show <- min(n_show, n_sols)
  restart_rows <- vector("list", n_show)
  for (i in seq_len(n_show)) {
    dist_obj <- tryCatch({
      xsdm::dist_between_params(
        sols$full_par[[i]],
        sols$full_par[[1]],
        mask = NULL,
        give_closest_rep = TRUE
      )
    }, error = function(e) NULL)
    if (is.null(dist_obj) || is.null(dist_obj$representative)) {
      next
    }
    restart_rows[[i]] <- c(
      list(rank = i, loglik = as.numeric(sols$loglik[[i]])),
      flatten_restart_rep(dist_obj$representative),
      list(dist_to_best = dist_obj$distance)
    )
  }
  restart_rows <- Filter(Negate(is.null), restart_rows)
  if (length(restart_rows) == 0) return(NULL)
  do.call(rbind, lapply(restart_rows, function(x) {
    as.data.frame(x, stringsAsFactors = FALSE, check.names = FALSE)
  }))
}

MODELS <- read_models()
WB     <- read_wb()

is_boundary <- function(m) !is.null(m$mask)
ok_status <- function(m) !is.null(m$status) && m$status == "success"
L1_models <- Filter(function(m) !is_boundary(m), MODELS)
L1_count <- length(L1_models)

sort_by_pbic <- function(names_vec) {
  if (length(names_vec) == 0) return(names_vec)
  pbic <- vapply(names_vec, function(nm) {
    m <- MODELS[[nm]]
    if (is.null(m) || is.null(m$pBIC) || is.na(m$pBIC)) Inf else as.numeric(m$pBIC)
  }, numeric(1))
  names_vec[order(pbic, names_vec)]
}

render_restart_table <- function(rt) {
  if (is.null(rt) || nrow(rt) == 0) {
    rpt("_restart table not available_")
    rpt("")
    return(invisible())
  }
  param_cols <- setdiff(names(rt), c("rank", "loglik", "dist_to_best"))
  header <- c("rank", "logLik", param_cols, "dist_to_best")
  rpt(paste0("| ", paste(header, collapse = " | "), " |"))
  rpt(paste0("|", paste(rep("---", length(header)), collapse = "|"), "|"))
  for (i in seq_len(nrow(rt))) {
    r <- rt[i, , drop = FALSE]
    vals <- c(
      as.character(r$rank),
      fmtn(r$loglik, 3),
      vapply(param_cols, function(pn) fmtn(r[[pn]], 4), character(1)),
      fmtn(r$dist_to_best, 8)
    )
    rpt(paste0("| ", paste(vals, collapse = " | "), " |"))
  }
  rpt("")
}

render_eigen_compare <- function(ev_h, ev_j) {
  if ((is.null(ev_h) || length(ev_h) == 0) && (is.null(ev_j) || length(ev_j) == 0)) {
    rpt("_Hessian not available_")
    rpt("")
    return(invisible())
  }
  n <- max(length(ev_h %||% numeric(0)), length(ev_j %||% numeric(0)))
  fmt_ev <- function(x) {
    if (is.null(x) || length(x) == 0 || is.na(x)) "—" else formatC(x, format = "e", digits = 3)
  }
  rpt("| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |")
  rpt("|---|---:|---:|")
  for (i in seq_len(n)) {
    rpt(sprintf("| %d | %s | %s |", i, fmt_ev(if (!is.null(ev_h) && length(ev_h) >= i) ev_h[[i]] else NULL), fmt_ev(if (!is.null(ev_j) && length(ev_j) >= i) ev_j[[i]] else NULL)))
  }
  rpt("")
}

fmt_flag <- function(x) {
  if (isTRUE(x)) "PASS" else if (identical(x, FALSE)) "FAIL" else "NA"
}

rpt("# xsdm v6 — Model selection report (Algorithm2)")
rpt("")
rpt(sprintf("**Species:** *%s*", gsub("_", " ", species)))
rpt("")
rpt("This report documents, step by step, the literal Algorithm2 selection rules")
rpt("applied to this species. Each phase (L1–L4) includes the rule itself and")
rpt("the complete list of models with their classification.")
rpt("")
rpt("**Definition of model success:** a model has `status == \"success\"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.")
rpt("")

rpt("## Data and units")
rpt("")
rpt(sprintf("- Species directory: `%s`", species_dir))
rpt(sprintf("- Sample size: %s", fmtn(n_data, 0)))
rpt(sprintf("- Maximum variables per model: %s", fmtn(max_p, 0)))
rpt(sprintf("- Tau (τ): %s", fmtn(tau, 4)))
rpt(sprintf("- L2 threshold: best L1 + τ = %s", fmtn(threshold, 4)))
rpt(sprintf("- Ω threshold: %s", fmtn(omega_tau, 4)))
rpt("- Temperature variables are in degrees Celsius (converted from ERA5Land Kelvin); precipitation variables are in mm.")
rpt("- Each model RDS stores the per-variable `scale_factors` applied during fitting.")
rpt("")

rpt("## IUCN range and presence points")
rpt("")
iucn_png_rel <- file.path("plots", "iucn_range.png")
iucn_png_abs <- file.path(species_dir, iucn_png_rel)
iucn_pdf_rel <- "iucn_range.pdf"
iucn_pdf_abs <- file.path(species_dir, iucn_pdf_rel)
if (file.exists(iucn_png_abs) || file.exists(iucn_pdf_abs)) {
  if (file.exists(iucn_png_abs)) {
    rpt(sprintf("![IUCN range and presence points](%s)", iucn_png_rel))
    rpt("")
  }
  if (file.exists(iucn_pdf_abs)) {
    rpt(sprintf("[Full IUCN range PDF](%s)", iucn_pdf_rel))
    rpt("")
  }
} else {
  rpt("*IUCN range figure not available.*")
  rpt("")
}

rpt("## Literal selection rules (Algorithm2)")
rpt("")
rpt(sprintf("1. Fit all %d non-boundary L1 models and rank them by pBIC.", L1_count))
rpt("2. Expand the L1 models with pBIC ≤ best_L1 + τ to their boundary versions.")
rpt("3. Form L3 = L1 ∪ L2, rank by pBIC, and select the first well-behaved model")
rpt("   (Flags A and B both pass). That model is M_Ω.")
rpt("4. Expand boundary models in the intermediate pBIC band [best_L1 + τ, Ω + τ].")
rpt("")

rpt(sprintf("## Phase L1 — %d non-boundary models", L1_count))
rpt("")
rpt(sprintf("Rule: fit the %d non-boundary models and rank them by ascending pBIC.", L1_count))
rpt("")

l1_tab <- data.frame(model = names(L1_models), stringsAsFactors = FALSE)
if (nrow(l1_tab) > 0) {
  l1_tab$pBIC <- sapply(names(L1_models), function(n) if (ok_status(L1_models[[n]])) L1_models[[n]]$pBIC else NA)
  l1_tab$loglik <- sapply(names(L1_models), function(n) if (ok_status(L1_models[[n]])) L1_models[[n]]$loglik else NA)
  l1_tab$nfree <- sapply(names(L1_models), function(n) if (ok_status(L1_models[[n]])) L1_models[[n]]$n_free else NA)
  l1_tab$vars <- sapply(names(L1_models), function(n) paste(L1_models[[n]]$vars, collapse = "+"))
  l1_tab$status <- sapply(names(L1_models), function(n) L1_models[[n]]$status)
  l1_tab <- l1_tab[order(l1_tab$pBIC, na.last = TRUE), ]
  rpt("| # | Model | Variables | pBIC | logLik | n_free | status |")
  rpt("|---|-------|-----------|------|--------|--------|--------|")
  for (i in seq_len(nrow(l1_tab))) {
    r <- l1_tab[i, ]
    mark <- if (!is.na(r$pBIC) && r$pBIC <= threshold) " ≤τ" else ""
    rpt(sprintf("| %d | %s%s | %s | %s | %s | %s | %s |",
                i, r$model, mark, r$vars, fmtn(r$pBIC), fmtn(r$loglik, 3),
                ifelse(is.na(r$nfree), "—", r$nfree), r$status))
  }
  rpt("")
  rpt("*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*")
  rpt("**Success** here means `status == \"success\"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.")
  rpt("")
}

# ─── BIC vs AIC scatter for the L1 models ───────────────────────────────────
# BIC = -2·logLik + n_free·log(n)  (= pBIC);  AIC = -2·logLik + 2·n_free
l1_ok  <- Filter(ok_status, L1_models)
bicaic_rel <- file.path("plots", "bic_vs_aic_v7.png")
bicaic_abs <- file.path(species_dir, bicaic_rel)
bicaic_ok  <- FALSE
if (length(l1_ok) > 0) {
  lab  <- names(l1_ok)
  bic  <- vapply(l1_ok, function(m) as.numeric(m$pBIC), numeric(1))
  aic  <- vapply(l1_ok, function(m) -2 * as.numeric(m$loglik) + 2 * as.numeric(m$n_free), numeric(1))
  keep <- is.finite(bic) & is.finite(aic)
  lab <- lab[keep]; bic <- bic[keep]; aic <- aic[keep]
  if (length(bic) > 0) {
    bicaic_ok <- tryCatch({
      dir.create(dirname(bicaic_abs), recursive = TRUE, showWarnings = FALSE)
      best_i <- which.min(bic)
      cols <- rep("steelblue", length(bic)); cols[best_i] <- "red"
      grDevices::png(bicaic_abs, width = 760, height = 680, res = 110)
      op <- graphics::par(mar = c(4.5, 4.5, 2.5, 1))
      graphics::plot(aic, bic, pch = 19, col = cols, cex = 1.2,
                     xlab = "AIC", ylab = "BIC (pBIC)",
                     main = sprintf("L1: BIC vs AIC (%d non-boundary models)", L1_count))
      graphics::text(aic, bic, labels = lab, pos = 3, cex = 0.55,
                     col = ifelse(seq_along(bic) == best_i, "red", "gray30"))
      graphics::abline(a = 0, b = 1, col = "gray70", lty = 3)
      graphics::legend("topleft", bty = "n", pch = 19, col = c("red", "steelblue"),
                       legend = c("best pBIC (L1)", "other L1 models"), cex = 0.8)
      graphics::par(op); grDevices::dev.off(); TRUE
    }, error = function(e) { cat(sprintf("BIC/AIC plot error: %s\n", e$message)); FALSE })
  }
}
rpt("### BIC vs AIC (L1)")
rpt("")
if (bicaic_ok && file.exists(bicaic_abs)) {
  rpt(sprintf("![BIC vs AIC for the %d L1 models](%s)", L1_count, bicaic_rel))
  rpt("")
  rpt("*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*")
} else {
  rpt("- _not generated_")
}
rpt("")

# ─── Phase L2 ────────────────────────────────────────────────────────────────

eligible_L2 <- names(L1_models)[sapply(names(L1_models), function(n)
  ok_status(L1_models[[n]]) && !is.na(L1_models[[n]]$pBIC) && L1_models[[n]]$pBIC <= threshold)]

rpt("## Phase L2 — boundary models for eligible L1 fits")
rpt("")
rpt(sprintf("Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = %s**.", fmtn(threshold)))
rpt(sprintf("**Eligible L1 models:** %d (%s)", length(eligible_L2),
            if (length(eligible_L2)) paste(eligible_L2, collapse = ", ") else "none"))
rpt("")
report_boundary_table <- function(names_vec, title_note) {
  if (length(names_vec) == 0) { rpt(paste0("_", title_note, "_")); rpt(""); return(invisible()) }
  names_vec <- sort_by_pbic(names_vec)
  rpt("| Boundary model | pBIC | logLik | n_free | status |")
  rpt("|---------------|------|--------|--------|--------|")
  for (nm in names_vec) {
    m <- MODELS[[nm]]
    if (is.null(m)) { rpt(sprintf("| %s | — | — | — | not fit |", nm)); next }
    status_txt <- if (!is.null(m$status)) m$status else "unknown"
    rpt(sprintf("| %s | %s | %s | %s | %s |",
                nm,
                fmtn(m$pBIC),
                fmtn(m$loglik, 3),
                if (!is.null(m$n_free)) m$n_free else "—",
                status_txt))
  }
  rpt("")
}
report_boundary_table(L2_names, "No boundary models were fit in L2.")

rpt("## Phase L3 — union of L1 ∪ L2 and the well-behaved scan")
rpt("")
rpt("Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**")
rpt("model with both Flag A and Flag B passing. That model is M_Ω.")
rpt("")
all_succ <- Filter(ok_status, MODELS)
if (length(all_succ) > 0) {
  ord <- order(sapply(all_succ, function(m) m$pBIC))
  l3  <- all_succ[ord]
  rpt("| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |")
  rpt("|---|-------|------|--------------|--------|--------|---------|--------|")
  i <- 0
  for (nm in names(l3)) {
    i <- i + 1
    m  <- l3[[nm]]
    wb <- WB[[nm]]
    if (is.null(wb)) {
      rpt(sprintf("| %d | %s | %s | (not scanned) | — | — | — | — |", i, nm, fmtn(m$pBIC)))
    } else {
      rpt(sprintf("| %d | %s | %s | %s | %s | %s | %s | %s |",
                  i, nm, fmtn(m$pBIC),
                  if (isTRUE(wb$well_behaved)) "yes ✓" else "no",
                  if (isTRUE(wb$flag_a)) "✓" else "✗",
                  if (isTRUE(wb$flag_b)) "✓" else "✗",
                  if (is.null(wb$cond_num) || is.na(wb$cond_num)) "—"
                  else formatC(wb$cond_num, format = "e", digits = 2),
                  if (is.null(wb$n_converged) || is.na(wb$n_converged)) "—"
                  else as.character(wb$n_converged)))
    }
  }
  rpt("*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*")
  rpt("")
}
if (has_omega) {
  rpt(sprintf("**M_Ω (L3):** `%s` — **Ω = %s**", M_OMEGA, fmtn(Omega)))
} else {
  rpt("**M_Ω (L3):** none — no model satisfied both Flag A and Flag B under the strict criteria. See the supplementary appendices and the tolerance assessment below.")
}
rpt("")

rpt("## L3 supplementary appendices — per-model diagnostics")
rpt("")
scan_models <- if (length(scanned_models) > 0) scanned_models else names(WB)
scan_models <- scan_models[vapply(scan_models, function(nm) {
  wb <- WB[[nm]]
  !is.null(wb) && (is.null(wb$reason) || !identical(wb$reason, "not_success"))
}, logical(1))]
scan_models <- sort_by_pbic(scan_models)

if (length(scan_models) == 0) {
  rpt("_No scanned model diagnostics available._")
  rpt("")
} else {
  for (nm in scan_models) {
    wb <- WB[[nm]]
    m <- MODELS[[nm]]
    rpt(sprintf("### %s — Appendix A: optimization restarts (Flag A)", nm))
    rpt("")
    render_restart_table(build_restart_table(m))
    rpt(sprintf("Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=%s, max_pdist=%s → %s (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.",
                fmtn(wb$ll_range, 4), fmtn(wb$max_pdist, 4), fmt_flag(wb$flag_a)))
    rpt("")

    rpt(sprintf("### %s — Appendix B: Hessian eigenvalues (Flag B)", nm))
    rpt("")
    render_eigen_compare(wb$eigenvalues_hessian %||% wb$eigenvalues, wb$eigenvalues_jac)
    rpt(sprintf("numDeriv::hessian (operative): cond = %s, n negative = %s, strict Flag B → %s",
                fmtn(wb$cond_num_hessian, 4),
                if (!is.null(wb$n_neg_hessian)) wb$n_neg_hessian else "NA",
                fmt_flag(wb$flag_b_hessian)))
    rpt(sprintf("(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = %s, n negative = %s, strict Flag B → %s, relaxed → %s",
                fmtn(wb$cond_num_jac %||% wb$cond_num, 4),
                if (!is.null(wb$n_neg_jac)) wb$n_neg_jac else if (!is.null(wb$n_neg_evals)) wb$n_neg_evals else "NA",
                fmt_flag(wb$flag_b_jac %||% wb$flag_b),
                fmt_flag(wb$flag_b_jac_relaxed %||% wb$flag_b_relaxed)))
    rpt("A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.")
    rpt(sprintf("Hessian method: %s", wb$hessian_method %||% "numDeriv::hessian (Richardson extrapolation) of negative log-likelihood at the optimum"))
    rpt("")
  }
}

rpt("### Numerical Hessian & tolerance assessment")
rpt("")
rpt("The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.")
rpt("Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.")
relaxed_pass <- scan_models[vapply(scan_models, function(nm) {
  wb <- WB[[nm]]
  isTRUE(wb$flag_b == FALSE) && isTRUE(wb$flag_b_relaxed == TRUE)
}, logical(1))]
rpt(sprintf("Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: %s",
            if (length(relaxed_pass)) paste(relaxed_pass, collapse = ", ") else "none"))
rpt("")
n_scanned  <- length(scan_models)
n_flag_a   <- sum(vapply(scan_models, function(nm) isTRUE(WB[[nm]]$flag_a), logical(1)))
n_flag_b   <- sum(vapply(scan_models, function(nm) isTRUE(WB[[nm]]$flag_b), logical(1)))
n_flag_br  <- sum(vapply(scan_models, function(nm) isTRUE(WB[[nm]]$flag_b_relaxed), logical(1)))
n_wb_str   <- sum(vapply(scan_models, function(nm) isTRUE(WB[[nm]]$flag_a) && isTRUE(WB[[nm]]$flag_b), logical(1)))
n_wb_rel   <- sum(vapply(scan_models, function(nm) isTRUE(WB[[nm]]$flag_a) && isTRUE(WB[[nm]]$flag_b_relaxed), logical(1)))
rpt(sprintf("Across %d scanned models: %d pass Flag A (convergence), %d pass strict Flag B, %d pass relaxed Flag B.",
            n_scanned, n_flag_a, n_flag_b, n_flag_br))
rpt("")
rpt(sprintf("Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **%d**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **%d**.",
            n_wb_str, n_wb_rel))
rpt("")

# ─── Flag A failure decomposition ────────────────────────────────────────────
fa_fail <- scan_models[vapply(scan_models, function(nm) !isTRUE(WB[[nm]]$flag_a), logical(1))]
llr_of  <- function(nm) { v <- WB[[nm]]$ll_range;  if (is.null(v)) NA_real_ else as.numeric(v) }
mpd_of  <- function(nm) { v <- WB[[nm]]$max_pdist; if (is.null(v)) NA_real_ else as.numeric(v) }
n_ll_dis <- sum(vapply(fa_fail, function(nm) { l <- llr_of(nm); !is.na(l) && l >= 0.1 }, logical(1)))
n_pd_na  <- sum(vapply(fa_fail, function(nm) { l <- llr_of(nm); m <- mpd_of(nm); !is.na(l) && l < 0.1 && is.na(m) }, logical(1)))
n_pd_dis <- sum(vapply(fa_fail, function(nm) { l <- llr_of(nm); m <- mpd_of(nm); !is.na(l) && l < 0.1 && !is.na(m) && m >= 0.05 }, logical(1)))
n_pd_na_goodhess <- sum(vapply(fa_fail, function(nm) {
  l <- llr_of(nm); m <- mpd_of(nm)
  (!is.na(l) && l < 0.1 && is.na(m)) && (isTRUE(WB[[nm]]$flag_b) || isTRUE(WB[[nm]]$flag_b_relaxed))
}, logical(1)))
rpt(sprintf("**Why models fail Flag A.** Of the %d models that fail Flag A: **%d** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **%d** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **%d** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).",
            length(fa_fail), n_ll_dis, n_pd_na, n_pd_dis))
rpt("")
rpt(sprintf("Of the %d models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **%d also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.",
            n_pd_na, n_pd_na_goodhess))
rpt("")
if (n_wb_rel <= n_wb_str) {
  rpt("**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.")
} else {
  rpt(sprintf("**Relaxing the Hessian (Flag B) tolerance would additionally qualify %d model(s)** (those combine Flag A convergence with a Hessian that is positive-definite only under the relaxed tolerance).", n_wb_rel - n_wb_str))
}
rpt("")
rpt("This is diagnostic only — M_Ω selection still uses the strict criterion.")
rpt("")

eligible_L4 <- names(L1_models)[sapply(names(L1_models), function(n)
  ok_status(L1_models[[n]]) && !is.na(L1_models[[n]]$pBIC) &&
    L1_models[[n]]$pBIC >= threshold && L1_models[[n]]$pBIC <= (Omega + omega_tau))]

rpt("## Phase L4 — boundary models in the intermediate band")
rpt("")
rpt(sprintf("Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**."))
rpt(sprintf("**Eligible L1 models:** %d (%s)", length(eligible_L4),
            if (length(eligible_L4)) paste(eligible_L4, collapse = ", ") else "none"))
rpt("")
report_boundary_wb_table <- function(names_vec, title_note) {
  if (length(names_vec) == 0) { rpt(paste0("_", title_note, "_")); rpt(""); return(invisible()) }
  names_vec <- sort_by_pbic(names_vec)
  rpt("| # | Boundary model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv | logLik | n_free | status |")
  rpt("|---|----------------|------|--------------|--------|--------|---------|--------|--------|--------|--------|")
  for (i in seq_along(names_vec)) {
    nm <- names_vec[[i]]
    m <- MODELS[[nm]]
    wb <- WB[[nm]]
    if (is.null(m)) {
      rpt(sprintf("| %d | %s | — | (not fit) | — | — | — | — | — | — | — |", i, nm))
      next
    }
    status_txt <- if (!is.null(m$status)) m$status else "unknown"
    if (is.null(wb)) {
      rpt(sprintf("| %d | %s | %s | (not scanned) | — | — | — | — | %s | %s | %s |",
                  i, nm, fmtn(m$pBIC), fmtn(m$loglik, 3),
                  if (!is.null(m$n_free)) m$n_free else "—", status_txt))
      next
    }
    rpt(sprintf("| %d | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |",
                i, nm, fmtn(m$pBIC),
                if (isTRUE(wb$well_behaved)) "yes ✓" else "no",
                if (isTRUE(wb$flag_a)) "✓" else "✗",
                if (isTRUE(wb$flag_b)) "✓" else "✗",
                if (is.null(wb$cond_num) || is.na(wb$cond_num)) "—"
                else formatC(wb$cond_num, format = "e", digits = 2),
                if (is.null(wb$n_converged) || is.na(wb$n_converged)) "—"
                else as.character(wb$n_converged),
                fmtn(m$loglik, 3),
                if (!is.null(m$n_free)) m$n_free else "—",
                status_txt))
  }
  rpt("")
}
report_boundary_wb_table(L4_names, "No boundary models were fit in L4.")
l4_wb_better <- L4_names[vapply(L4_names, function(nm) {
  m <- MODELS[[nm]]
  wb <- WB[[nm]]
  !is.null(m) && !is.null(wb) && isTRUE(wb$well_behaved) &&
    is.finite(m$pBIC) && is.finite(Omega) && m$pBIC < Omega
}, logical(1))]
if (is.finite(Omega)) {
  if (length(l4_wb_better)) {
    rpt(sprintf("**L4 replacement check:** %d well-behaved L4 model(s) have pBIC < Ω and would replace M_Ω under the L4 rule: %s.",
                length(l4_wb_better), paste(l4_wb_better, collapse = ", ")))
  } else {
    rpt("**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.")
  }
} else {
  rpt("**L4 replacement check:** Ω is unavailable, so no L4 replacement comparison was made.")
}
rpt("")

rpt("## Selected model (final M_Ω)")
rpt("")
prof_file <- file.path(species_dir, "profile_results_v7.rds")
final <- if (file.exists(prof_file)) tryCatch(readRDS(prof_file), error = function(e) NULL) else NULL

if (!has_omega) {
  rpt("**No model was selected.** No model in the L1 ∪ L2 (∪ L4) scan satisfied both Flag A (optimisation convergence) and Flag B (Hessian positive-definiteness) under the strict criteria. Consequently no profile-likelihood, TSS, or habitat-suitability artefacts were produced. The per-model diagnostics in the L3 supplementary appendices document why each candidate was rejected.")
  rpt("")
} else {
  rpt(sprintf("- **Model:** `%s`", M_OMEGA))
  rpt(sprintf("- **pBIC (Ω):** %s", fmtn(Omega)))
  sel <- MODELS[[M_OMEGA]]
  if (!is.null(sel) && ok_status(sel)) {
    rpt(sprintf("- **logLik:** %s", fmtn(sel$loglik, 4)))
    rpt(sprintf("- **Variables:** %s", paste(sel$vars, collapse = ", ")))
    rpt(sprintf("- **Free parameters (n_free):** %s", sel$n_free))
    if (!is.null(sel$mask)) {
      rpt(sprintf("- **Boundary mask:** %s",
                  paste(sprintf("%s=%s", names(sel$mask), sel$mask), collapse = ", ")))
    }
  }
  rpt("")
}

# --- TSS --------------------------------------------------------------------

tss_file <- file.path(species_dir, "tss_results_v7.rds")
rpt("## Model fit — True Skill Statistic (TSS)")
rpt("")
if (file.exists(tss_file)) {
  tss <- tryCatch(readRDS(tss_file), error = function(e) NULL)
  if (!is.null(tss)) {
    n_pres_txt <- if (!is.null(tss$n_presences)) tss$n_presences else if (!is.null(tss$n_pres)) tss$n_pres else "?"
    n_abs_txt <- if (!is.null(tss$n_pseudoabsences)) tss$n_pseudoabsences else if (!is.null(tss$n_abs)) tss$n_abs else "?"
    rpt("- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.")
    rpt("- A train/test split or k-fold cross-validation will be added in the next version.")
    rpt(sprintf("- **TSS:** %s", fmtn(tss$tss, 4)))
    rpt(sprintf("- **Threshold:** %s", fmtn(tss$threshold, 4)))
    rpt(sprintf("- **Sensitivity:** %s", fmtn(tss$sensitivity, 4)))
    rpt(sprintf("- **Specificity:** %s", fmtn(tss$specificity, 4)))
    rpt(sprintf("- **Presences / pseudo-absences:** %s / %s", n_pres_txt, n_abs_txt))
    if (!is.null(tss$prevalence)) rpt(sprintf("- **Prevalence:** %s", fmtn(tss$prevalence, 4)))
    if (!is.null(tss$auc) && !is.na(tss$auc)) rpt(sprintf("- **AUC:** %s", fmtn(tss$auc, 4)))
  } else {
    rpt("- _TSS file could not be read_")
  }
} else {
  rpt("- _not generated_")
}
rpt("")

if (!is.null(final)) {
  if (!is.null(final$best_bio)) {
    rpt("### Biological-scale parameters (`best_bio`)")
    rpt("")
    rpt("| Parameter | Value |")
    rpt("|-----------|-------|")
    bb <- final$best_bio
    for (nm in names(bb)) rpt(sprintf("| %s | %s |", nm, fmtn(bb[[nm]], 4)))
    rpt("")
  }

  rpt("### Profile likelihoods and arc check")
  rpt("")
  ar <- final$arc_results
  if (!is.null(ar)) {
    npass <- sum(sapply(ar, function(a) isTRUE(a$pass)))
    rpt(sprintf("- **Arc check:** %d/%d parameters pass → %s",
                npass, length(ar),
                if (isTRUE(final$all_arcs_pass)) "**ALL PASS ✓**" else "**AT LEAST ONE FAILS**"))
    rpt("")
    rpt("| Parameter | arc check | reason |")
    rpt("|-----------|-----------|--------|")
    for (nm in names(ar)) {
      rpt(sprintf("| %s | %s | %s |", nm,
                  if (isTRUE(ar[[nm]]$pass)) "PASS" else "FAIL",
                  ar[[nm]]$reason))
    }
    rpt("")
  }
}

png_rel <- file.path("plots", "profile_likelihood_v7.png")
png_abs <- file.path(species_dir, png_rel)
png_ok  <- FALSE
if (!is.null(final) && !is.null(final$profiles)) {
  prof_ok <- Filter(Negate(is.null), final$profiles)
  if (length(prof_ok) > 0) {
    png_ok <- tryCatch({
      dir.create(dirname(png_abs), recursive = TRUE, showWarnings = FALSE)
      np <- length(prof_ok); nc <- min(np, 3); nr <- ceiling(np / nc)
      grDevices::png(png_abs, width = 360 * nc, height = 300 * nr, res = 110)
      op <- graphics::par(mfrow = c(nr, nc), mar = c(4, 4, 2.5, 1))
      for (pn in names(prof_ok)) {
        pdat   <- prof_ok[[pn]]$profile
        thresh <- prof_ok[[pn]]$threshold
        passed <- isTRUE(final$arc_results[[pn]]$pass)
        xv <- if (!is.null(pdat$value_math)) pdat$value_math else pdat[[pn]]
        graphics::plot(xv, pdat$loglik, type = "l", lwd = 2,
                       xlab = pn, ylab = "log-likelihood",
                       main = paste(pn, if (passed) "(PASS)" else "(FAIL)"))
        graphics::abline(h = thresh, col = "red", lty = 2, lwd = 1.5)
        v <- suppressWarnings(final$best_par[[pn]])
        if (!is.null(v) && is.finite(v)) graphics::abline(v = v, col = "blue", lty = 2)
      }
      graphics::par(op); grDevices::dev.off(); TRUE
    }, error = function(e) { cat(sprintf("Profile PNG error: %s\n", e$message)); FALSE })
  }
}

rpt("## Profile likelihood plots")
rpt("")
if (png_ok && file.exists(png_abs)) {
  rpt(sprintf("![Profile likelihood plots for the best model (%s)](%s)", M_OMEGA, png_rel))
  rpt("")
  rpt("*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*")
  rpt("")
} else {
  rpt("- **Profiles:** _not generated_")
  rpt("")
}

hab_rel <- file.path("plots", "habitat_suitability_v7.png")
hab_abs <- file.path(species_dir, hab_rel)
hab_bin_rel <- file.path("plots", "habitat_suitability_binary_v7.png")
hab_bin_abs <- file.path(species_dir, hab_bin_rel)
rpt("## Habitat suitability prediction")
rpt("")
if (file.exists(hab_abs)) {
  rpt(sprintf("![Habitat suitability prediction](%s)", hab_rel))
  rpt("")
  rpt("*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*")
} else {
  rpt("- _not generated_")
}
rpt("")
if (file.exists(hab_bin_abs)) {
  rpt(sprintf("![Binary habitat suitability](%s)", hab_bin_rel))
  rpt("")
  rpt("*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*")
} else {
  rpt("- _not generated_")
}
rpt("")

rpt("## Summary")
rpt("")
rpt(sprintf("- **Final model:** %s", if (has_omega) sprintf("`%s` (pBIC = %s)", M_OMEGA, fmtn(Omega)) else "none (no model met the strict well-behaved criteria)"))
rpt(sprintf("- **Successful L1 fits:** %s/%d", scalars$N_L1_SUCCESS %||% "?", L1_count))
rpt(sprintf("- **Boundary L2 fits:** %s", scalars$N_L2 %||% "?"))
rpt(sprintf("- **Boundary L4 fits:** %s", scalars$N_L4 %||% "?"))
rpt(sprintf("- **τ:** %s", fmtn(tau, 4)))
rpt("")
rpt(sprintf("_Generated: %s_", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))

dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
writeLines(.lines, output_file)
cat(sprintf("Report written: %s (%d lines)\n", output_file, length(.lines)))

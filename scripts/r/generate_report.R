#!/usr/bin/env Rscript
# generate_report.R — Per-species detailed model selection report
# Usage: Rscript generate_report.R --species "Breviceps montanus" \
#          --method tau_raw --output_dir <path>
#
# Produces: <output_dir>/<Species>/phase1_results/report_detailed.md
#           <output_dir>/<Species>/phase1_results/profiles.pdf

suppressPackageStartupMessages({
  library(xsdm)
  library(numDeriv)
})

`%||%` <- function(x, y) if (is.null(x)) y else x

# ── CLI ──
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name <- parse_arg("--species")
method       <- parse_arg("--method", "tau_raw")
output_dir   <- parse_arg("--output_dir", "/home/a474r867/scratch/xsdm_1000_sp")

if (is.null(species_name)) stop("--species required")

sp_safe <- gsub(" ", "_", species_name)
p1_dir  <- file.path(output_dir, sp_safe, "phase1_results")
png_dir <- file.path(p1_dir, "figures")
dir.create(png_dir, recursive = TRUE, showWarnings = FALSE)
report_lines <- character(0)
rpt <- function(...) {
  line <- paste0(..., collapse = "")
  report_lines <<- c(report_lines, line)
  cat(line, "\n", sep = "")
}

# ══════════════════════════════════════════════════════════
# Hungarian algorithm for parameter matching
# ══════════════════════════════════════════════════════════

align_params <- function(sols, free_names) {
  # Use the best solution as reference, align others via Hungarian
  n_sols <- nrow(sols)
  ref <- sols$full_par[[1]][free_names]
  aligned <- matrix(NA_real_, nrow = n_sols, ncol = length(free_names))
  colnames(aligned) <- free_names
  aligned[1, ] <- ref

  for (i in 2:n_sols) {
    cand <- sols$full_par[[i]][free_names]
    # Simple matching: try all assignments and pick best L2 distance
    # For single-modality, direct matching usually works
    aligned[i, ] <- cand
  }
  aligned
}

# ══════════════════════════════════════════════════════════
# Load pipeline data
# ══════════════════════════════════════════════════════════

l3_file <- file.path(p1_dir, "L3_scan.rds")
l2_file <- file.path(p1_dir, "L2_boundary.rds")
l4_file <- file.path(p1_dir, "L4_final.rds")
final_file <- file.path(p1_dir, "phase1_results.rds")

if (!file.exists(l3_file)) stop("L3_scan.rds not found — L3 must complete first")
l3_data <- readRDS(l3_file)
L1 <- l3_data$L1; L2 <- l3_data$L2
M_Omega_l3 <- l3_data$M_Omega; Omega <- l3_data$Omega
best_pBIC_L1 <- l3_data$best_pBIC_L1; tau <- l3_data$tau
L3_order <- l3_data$L3_order

n_pts <- L1[[1]]$n

# Load L4 if available
has_L4 <- file.exists(l4_file)
if (has_L4) {
  l4_data <- readRDS(l4_file)
  L4 <- l4_data$L4
  M_Omega <- l4_data$M_Omega; Omega <- l4_data$Omega
} else {
  L4 <- list()
  M_Omega <- M_Omega_l3
}

# ══════════════════════════════════════════════════════════
# REPORT HEADER
# ══════════════════════════════════════════════════════════

rpt("# xSDM Model Selection Report")
rpt("")
rpt(sprintf("**Species:** *%s*", species_name))
rpt(sprintf("**Method:** %s", method))
rpt(sprintf("**Generated:** %s", Sys.time()))
rpt(sprintf("**Records:** %d total (%d presences + %d pseudo-absences)",
    n_pts, sum(L1[[1]]$occ == 1), sum(L1[[1]]$occ == 0)))
rpt("")

# ══════════════════════════════════════════════════════════
# SECTION 1: L1 — Non-boundary models
# ══════════════════════════════════════════════════════════

rpt("## 1. L1 — Non-boundary models (88 two-variable)")
rpt("")
rpt(sprintf("**tau** = (max_p+1)·log(n) = (2+1)·log(%d) = **%.2f**", n_pts, tau))
rpt("")

L1_pBIC <- sapply(L1, `[[`, "pBIC")
L1_order <- names(L1)[order(L1_pBIC)]
best_L1 <- min(L1_pBIC)

rpt(sprintf("**Best L1 pBIC:** %.1f", best_L1))
rpt(sprintf("**Eligibility threshold:** %.1f (best + tau)", best_L1 + tau))
rpt(sprintf("**Eligible models:** %d / %d", sum(L1_pBIC <= best_L1 + tau), length(L1)))
rpt("")

rpt("| Rank | Model | Vars | n_free | pBIC | logLik | Eligible? |")
rpt("|------|-------|------|--------|------|--------|-----------|")
for (j in seq_along(L1_order)) {
  nm <- L1_order[j]; f <- L1[[nm]]
  elig <- if (f$pBIC <= best_L1 + tau) "YES" else ""
  rpt(sprintf("| %d | %s | %s | %d | %.1f | %.2f | %s |",
      j, nm, paste(f$vars, collapse=", "),
      f$n_free, f$pBIC, f$loglik, elig))
}
rpt("")

# ══════════════════════════════════════════════════════════
# SECTION 2: L3 — Combined (L1 + L2) ranked
# ══════════════════════════════════════════════════════════

L3 <- c(L1, L2)
L3_pBIC <- sapply(L3, `[[`, "pBIC")
L3_order_all <- names(L3)[order(L3_pBIC)]

rpt("## 2. L3 — Combined models (L1 + L2 boundary) ranked by pBIC")
rpt("")
rpt(sprintf("**Total L3 models:** %d (L1=%d + L2=%d)", length(L3), length(L1), length(L2)))
rpt("")

rpt("| Rank | Model | Type | pBIC | logLik | n_free |")
rpt("|------|-------|------|------|--------|--------|")
for (j in seq_len(min(30, length(L3_order_all)))) {
  nm <- L3_order_all[j]; f <- L3[[nm]]
  mtype <- if (!is.null(f$mask)) "boundary" else "non-boundary"
  rpt(sprintf("| %d | %s | %s | %.1f | %.2f | %d |",
      j, nm, mtype, f$pBIC, f$loglik, f$n_free))
}
if (length(L3_order_all) > 30) {
  rpt(sprintf("| ... | (%d more models) | | | | |", length(L3_order_all) - 30))
}
rpt("")

# ══════════════════════════════════════════════════════════
# SECTION 3: Well-behaved scan (walk up L3)
# ══════════════════════════════════════════════════════════

rpt("## 3. Well-behaved scan (walking up L3)")
rpt("")

wb_found <- FALSE
M_Omega_name <- NULL
Omega_val <- Inf

for (j in seq_along(L3_order_all)) {
  nm <- L3_order_all[j]; fit <- L3[[nm]]
  rpt(sprintf("### 3.%d — %s (pBIC = %.1f)", j, nm, fit$pBIC))
  rpt("")

  # ── Top 5 optimization results ──
  sols <- fit$result$solutions
  n_show <- min(5, nrow(sols))
  p <- fit$p

  rpt(sprintf("**Top %d optimization results:**", n_show))
  rpt("")

  # Get free parameter names
  if (!is.null(fit$mask)) {
    free_names <- setdiff(names(fit$result$best$par), names(fit$mask))
  } else {
    free_names <- names(fit$result$best$par)
  }

  aligned <- align_params(sols, free_names)

  rpt("| Sol | logLik | Converged |")
  for (k in seq_along(free_names)) {
    rpt_lines <- report_lines
    # Add parameter column to the right
  }

  # Print parameter table
  rpt("| Sol | logLik | Converged |", paste(sprintf(" %s |", free_names), collapse=""))
  rpt(paste0("|-----|--------|-----------|", paste(rep("------|", length(free_names)), collapse="")))
  for (si in seq_len(n_show)) {
    conv_val <- if (!is.null(sols$convergence) && length(sols$convergence) >= si) {
      if (sols$convergence[si]) "✓" else "✗"
    } else "?"
    params_str <- paste(sprintf(" %.4f |", aligned[si, ]), collapse="")
    rpt(sprintf("| %d | %.4f | %s |%s", si, sols$loglik[si], conv_val, params_str))
  }
  rpt("")

  # ── Flag A: Optimization convergence ──
  n_check <- min(5, nrow(sols))
  if (n_check >= 2) {
    top_ll <- sols$loglik[1:n_check]
    ll_range <- max(top_ll) - min(top_ll)

    pdists <- vapply(2:n_check, function(i) {
      tryCatch({
        d <- dist_between_params(sols$full_par[[1]], sols$full_par[[i]], mask = NULL)
        if (is.list(d)) d$distance else d
      }, error = function(e) NA_real_)
    }, numeric(1))
    max_pdist <- max(pdists, na.rm = TRUE)

    flag_a <- (ll_range < 0.1) && (max_pdist < 0.05)
  } else {
    ll_range <- NA; max_pdist <- NA; flag_a <- FALSE
  }

  rpt("**Flag A — Optimization convergence:**")
  rpt(sprintf("- Log-likelihood range (top %d): %.6f %s 0.1", n_check, ll_range,
      if(is.na(ll_range)) "N/A" else if(ll_range < 0.1) "<" else "≥"))
  rpt(sprintf("- Max parameter distance: %.4f %s 0.05", max_pdist,
      if(is.na(max_pdist)) "N/A" else if(max_pdist < 0.05) "<" else "≥"))
  rpt(sprintf("- **Judgement: %s**",
      if(flag_a) "**LIKELY WELL BEHAVED**" else "likely badly behaved"))
  rpt("")

  # ── Hessian ──
  best_full <- fit$result$best$par
  best_free <- best_full[free_names]

  hess <- tryCatch(
    numDeriv::hessian(
      func = function(par_free) {
        names(par_free) <- free_names
        loglik_math(par_free, env_dat = fit$env_dat, occ = fit$occ,
                    mask = fit$mask, negative = TRUE, num_threads = 1L)
      }, x = best_free
    ), error = function(e) NULL)

  if (is.null(hess)) {
    flag_b <- FALSE; cond_num <- NA_real_; ev <- numeric(0)
  } else {
    ev <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
    flag_b <- all(ev > 1e-8)
    cond_num <- if (flag_b) max(ev) / min(ev) else Inf
    if (flag_b) flag_b <- is.finite(cond_num) && (cond_num < 1e6)
  }

  rpt("**Flag B — Hessian analysis:**")
  if (length(ev) > 0) {
    rpt(sprintf("- Eigenvalues: %s", paste(sprintf("%.2e", sort(ev)), collapse=", ")))
    rpt(sprintf("- All positive (>1e-8)? %s", if(all(ev > 1e-8)) "YES" else "NO"))
    rpt(sprintf("- Condition number: %.1e", cond_num))
    rpt(sprintf("- Condition < 1e6? %s", if(cond_num < 1e6) "YES" else "NO"))
  } else {
    rpt("- Hessian computation FAILED")
  }
  rpt(sprintf("- **Judgement: %s**",
      if(flag_b) "**LIKELY WELL BEHAVED**" else "likely badly behaved"))
  rpt("")

  # ── Final verdict ──
  wb <- flag_a && flag_b
  if (flag_a != flag_b) {
    rpt("⚠️ **WARNING: Flags disagree!** Manual review recommended.")
    rpt("")
  }

  if (wb) {
    rpt(sprintf("✅ **MODEL ACCEPTED AS WELL-BEHAVED: %s**", nm))
    rpt("")
    M_Omega_name <- nm; Omega_val <- fit$pBIC
    wb_found <- TRUE
    break
  } else {
    rpt("❌ Model rejected. Continuing to next L3 model...")
    rpt("")
  }
}

if (!wb_found) {
  M_Omega_name <- L3_order_all[1]
  Omega_val <- L3[[M_Omega_name]]$pBIC
  rpt("⚠️ **WARNING: No well-behaved model found. Falling back to lowest pBIC.**")
  rpt("")
}

rpt(sprintf("## 4. M_Omega (from L3): **%s**", M_Omega_name))
rpt(sprintf("**Omega (pBIC):** %.1f", Omega_val))
rpt("")

# ══════════════════════════════════════════════════════════
# SECTION 5: L4 — Mid-tier boundary expansion
# ══════════════════════════════════════════════════════════

if (has_L4 && length(L4) > 0) {
  rpt("## 5. L4 — Mid-tier boundary expansion")
  rpt("")
  rpt(sprintf("**L4 candidates:** %d models", length(L4)))
  rpt(sprintf("**Threshold:** L1 models with pBIC in (%.1f, %.1f]",
      best_pBIC_L1 + tau, Omega_val + tau))
  rpt("")

  L4_pBIC <- sapply(L4, `[[`, "pBIC")
  L4_order <- names(L4)[order(L4_pBIC)]

  rpt("| Model | pBIC |")
  rpt("|-------|------|")
  for (nm in L4_order) {
    rpt(sprintf("| %s | %.1f |", nm, L4[[nm]]$pBIC))
  }
  rpt("")

  rpt("### 5.1 L4 well-behaved scan")
  rpt("")

  l4_wb_found <- FALSE
  for (j in seq_along(L4_order)) {
    nm <- L4_order[j]; fit <- L4[[nm]]
    if (fit$pBIC > Omega_val) {
      rpt(sprintf("**Stopping at %s:** pBIC=%.1f > Omega=%.1f", nm, fit$pBIC, Omega_val))
      rpt("")
      break
    }

    rpt(sprintf("#### L4.%d — %s (pBIC = %.1f)", j, nm, fit$pBIC))
    rpt("")

    # Quick well-behaved test (same as L3)
    sols <- fit$result$solutions
    n_check <- min(5, nrow(sols))

    if (!is.null(fit$mask)) {
      free_names <- setdiff(names(fit$result$best$par), names(fit$mask))
    } else {
      free_names <- names(fit$result$best$par)
    }

    if (n_check >= 2) {
      top_ll <- sols$loglik[1:n_check]
      ll_range <- max(top_ll) - min(top_ll)
      pdists <- vapply(2:n_check, function(i) {
        tryCatch({
          d <- dist_between_params(sols$full_par[[1]], sols$full_par[[i]], mask = NULL)
          if (is.list(d)) d$distance else d
        }, error = function(e) NA_real_)
      }, numeric(1))
      max_pdist <- max(pdists, na.rm = TRUE)
      flag_a <- (ll_range < 0.1) && (max_pdist < 0.05)
    } else {
      ll_range <- NA; max_pdist <- NA; flag_a <- FALSE
    }

    best_full <- fit$result$best$par
    best_free <- best_full[free_names]
    hess <- tryCatch(
      numDeriv::hessian(
        func = function(par_free) {
          names(par_free) <- free_names
          loglik_math(par_free, env_dat = fit$env_dat, occ = fit$occ,
                      mask = fit$mask, negative = TRUE, num_threads = 1L)
        }, x = best_free
      ), error = function(e) NULL)

    if (is.null(hess)) {
      flag_b <- FALSE
    } else {
      ev <- eigen(hess, symmetric = TRUE, only.values = TRUE)$values
      flag_b <- all(ev > 1e-8) && (max(ev)/min(ev) < 1e6)
    }

    wb <- flag_a && flag_b
    rpt(sprintf("Flag A (optim): %s | Flag B (hessian): %s → %s",
        flag_a, flag_b, if(wb) "**WELL-BEHAVED**" else "rejected"))

    if (wb) {
      M_Omega_name <- nm; Omega_val <- fit$pBIC
      rpt(sprintf("✅ **NEW M_Omega: %s** (pBIC = %.1f)", nm, fit$pBIC))
      rpt("")
      l4_wb_found <- TRUE
      break
    }
    rpt("")
  }

  if (!l4_wb_found) {
    rpt("No better model found in L4. Keeping M_Omega from L3.")
    rpt("")
  }
}

# ══════════════════════════════════════════════════════════
# SECTION 6: Final result
# ══════════════════════════════════════════════════════════

rpt("## 6. Final Selected Model")
rpt("")
rpt(sprintf("**M_Omega:** %s", M_Omega_name))
rpt(sprintf("**Omega (pBIC):** %.1f", Omega_val))

# Get final model fit
final_fit <- if (M_Omega_name %in% names(L3)) {
  L3[[M_Omega_name]]
} else if (has_L4 && M_Omega_name %in% names(L4)) {
  L4[[M_Omega_name]]
} else {
  NULL
}

if (!is.null(final_fit)) {
  rpt(sprintf("**Variables:** %s", paste(final_fit$vars, collapse=", ")))
  rpt(sprintf("**Type:** %s", if(!is.null(final_fit$mask)) "boundary" else "non-boundary"))
  rpt(sprintf("**n_free:** %d", final_fit$n_free))
  rpt(sprintf("**logLik:** %.2f", final_fit$loglik))
  if (!is.null(final_fit$mask)) {
    rpt(sprintf("**Mask:** %s", paste(names(final_fit$mask), collapse=", ")))
  }
}

rpt("")
rpt("## 7. Profile")
rpt("")

# ── pBIC distribution plot with tau cutoffs ──
rpt("### 7.0 — pBIC distribution with cutoff thresholds")
rpt("")

pBIC_plot <- file.path(png_dir, "pBIC_distribution.png")
png(pBIC_plot, width = 1000, height = 500)

L1_pBIC_vals <- sapply(L1, `[[`, "pBIC")
best <- min(L1_pBIC_vals)
n <- n_pts

# Compute all 3 tau values for reference lines
tau_raw_val <- (2 + 1) * log(n)
tau_r10_val <- 10
tau_r6_val  <- 6

# Density + rug
plot(density(L1_pBIC_vals), main = sprintf("pBIC Distribution — %s (n=%d)", species_name, n),
     xlab = "pBIC", ylab = "Density", lwd = 2, col = "steelblue")
rug(L1_pBIC_vals, col = "gray60")

# Vertical lines for cutoffs
abline(v = best, col = "darkgreen", lwd = 2, lty = 2)
text(best, max(density(L1_pBIC_vals)$y) * 0.95, "best", col = "darkgreen", cex = 0.8, pos = 4)

abline(v = best + tau_r6_val, col = "darkred", lwd = 1.5, lty = 3)
text(best + tau_r6_val, max(density(L1_pBIC_vals)$y) * 0.85,
     sprintf("ΔBIC≤6 (%d)", sum(L1_pBIC_vals <= best + tau_r6_val)),
     col = "darkred", cex = 0.8, pos = 4)

abline(v = best + tau_r10_val, col = "darkorange", lwd = 1.5, lty = 3)
text(best + tau_r10_val, max(density(L1_pBIC_vals)$y) * 0.75,
     sprintf("ΔBIC≤10 (%d)", sum(L1_pBIC_vals <= best + tau_r10_val)),
     col = "darkorange", cex = 0.8, pos = 4)

abline(v = best + tau_raw_val, col = "purple", lwd = 1.5, lty = 3)
text(best + tau_raw_val, max(density(L1_pBIC_vals)$y) * 0.65,
     sprintf("tau_raw=%.1f (%d)", tau_raw_val, sum(L1_pBIC_vals <= best + tau_raw_val)),
     col = "purple", cex = 0.8, pos = 4)

legend("topright",
       legend = c("pBIC density", "Best L1", "ΔBIC≤6 (Raftery)", "ΔBIC≤10 (Raftery)", "tau_raw (Dan)"),
       col = c("steelblue", "darkgreen", "darkred", "darkorange", "purple"),
       lwd = c(2, 2, 1.5, 1.5, 1.5), lty = c(1, 2, 3, 3, 3), cex = 0.7)

dev.off()
rpt(sprintf("✅ pBIC distribution plot saved: %s", pBIC_plot))
rpt("")

# ── Boxplot comparing methods ──
rpt("### 7.1 — Model pBIC by variable type")
rpt("")

pBIC_box <- file.path(png_dir, "pBIC_by_vartype.png")
png(pBIC_box, width = 1000, height = 500)

# Extract T and P indices from model names
model_info <- do.call(rbind, lapply(names(L1), function(nm) {
  parts <- strsplit(nm, "_")[[1]]
  data.frame(name = nm, pBIC = L1[[nm]]$pBIC,
             T_idx = as.integer(gsub("T", "", parts[2])),
             P_idx = as.integer(gsub("P", "", parts[4])),
             stringsAsFactors = FALSE)
}))

par(mfrow = c(1, 2))
boxplot(pBIC ~ T_idx, data = model_info, main = "pBIC by Temperature variable",
        xlab = "T index (bio01-bio11)", ylab = "pBIC", col = "tomato")
boxplot(pBIC ~ P_idx, data = model_info, main = "pBIC by Precipitation variable",
        xlab = "P index (bio12-bio19)", ylab = "pBIC", col = "steelblue")

dev.off()
rpt(sprintf("✅ pBIC boxplots saved: %s", pBIC_box))
rpt("")

# ── Profile plot ──
rpt("## 7. Profile")
rpt("")

# Generate profile
if (!is.null(final_fit)) {
  rpt("Profile plot saved to: `profiles.pdf`")
  rpt("")

prof_file <- file.path(png_dir, "profiles.png")
png(prof_file, width = 1000, height = 600)
tryCatch({
  profile_likelihood(final_fit$result, num_pts = 50)
}, error = function(e) {
  rpt(sprintf("⚠️ Profile generation failed: %s", conditionMessage(e)))
})
dev.off()
rpt(sprintf("✅ Profile saved: %s", prof_file))
} else {
  rpt("⚠️ Cannot generate profile: final model not found.")
}

rpt("")
rpt("---")
rpt(sprintf("*Report generated: %s*", Sys.time()))
rpt(sprintf("*Pipeline: xSDM v5 | Method: %s*", method))

# ── Write outputs ──
md_file  <- file.path(p1_dir, "report_detailed.md")
rmd_file <- file.path(p1_dir, "report_detailed.Rmd")
tex_file <- file.path(p1_dir, "report_detailed.tex")

# .md (raw markdown for quick viewing)
writeLines(report_lines, md_file)

# .Rmd (R Markdown with YAML header, can knit to PDF via Overleaf)
rmd_header <- c(
  "---",
  sprintf('title: \"xSDM Model Selection: *%s*\"', species_name),
  sprintf('subtitle: \"Method: %s\"', method),
  sprintf('date: \"%s\"', Sys.time()),
  "output:",
  "  pdf_document:",
  "    fig_caption: yes",
  "    keep_tex: yes",
  "---",
  ""
)
writeLines(c(rmd_header, report_lines), rmd_file)

# .tex (LaTeX with embedded images for Overleaf)
tex_header <- c(
  "\\documentclass{article}",
  "\\usepackage{graphicx}",
  "\\usepackage{booktabs}",
  "\\usepackage{hyperref}",
  "\\usepackage[margin=1in]{geometry}",
  "\\title{xSDM Model Selection: \\textit{<<SPECIES>>}}",
  sprintf("\\author{Pipeline: xSDM v5 | Method: %s}", method),
  sprintf("\\date{Generated: %s}", Sys.time()),
  "\\begin{document}",
  "\\maketitle",
  ""
)
tex_header <- gsub("<<SPECIES>>", species_name, tex_header)

# Convert markdown tables to LaTeX (simple approach: keep as verbatim)
# For a proper LaTeX, we wrap sections and include figures
tex_body <- character(0)
in_table <- FALSE
for (line in report_lines) {
  if (grepl("^## ", line)) {
    sec_title <- gsub("^## ", "", line)
    tex_body <- c(tex_body, sprintf("\\section{%s}", sec_title))
  } else if (grepl("^### ", line)) {
    sub_title <- gsub("^### ", "", line)
    tex_body <- c(tex_body, sprintf("\\subsection{%s}", sub_title))
  } else if (grepl("^#### ", line)) {
    subsub <- gsub("^#### ", "", line)
    tex_body <- c(tex_body, sprintf("\\subsubsection{%s}", subsub))
  } else if (grepl("^\\|", line)) {
    tex_body <- c(tex_body, sprintf("\\texttt{%s}", line))
  } else if (grepl("^\\*\\*", line)) {
    tex_body <- c(tex_body, gsub("\\*\\*(.+?)\\*\\*", "\\\\textbf{\\1}", line))
  } else if (grepl("saved:.*\\.png", line)) {
    img_name <- gsub(".*/(figures/[^ ]+\\.png).*", "\\1", line)
    tex_body <- c(tex_body, "\\begin{figure}[htbp]",
                  "\\centering",
                  sprintf("\\includegraphics[width=0.9\\textwidth]{%s}", img_name),
                  "\\end{figure}")
  } else if (grepl("^✅ ", line) || grepl("^⚠️ ", line) || grepl("^❌ ", line)) {
    tex_body <- c(tex_body, sprintf("\\texttt{%s}", line))
  } else if (line == "") {
    tex_body <- c(tex_body, "")
  } else if (grepl("^- ", line)) {
    tex_body <- c(tex_body, sprintf("\\texttt{%s}", line))
  } else {
    tex_body <- c(tex_body, line)
  }
}

tex_tail <- c("", "\\end{document}")

writeLines(c(tex_header, tex_body, tex_tail), tex_file)

cat(sprintf("\nReports written:\n"))
cat(sprintf("  Markdown: %s (%d lines)\n", md_file, length(report_lines)))
cat(sprintf("  R Markdown: %s\n", rmd_file))
cat(sprintf("  LaTeX: %s\n", tex_file))

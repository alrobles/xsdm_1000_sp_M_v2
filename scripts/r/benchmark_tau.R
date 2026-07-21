#!/usr/bin/env Rscript
# benchmark_tau.R — Compare 3 tau/cutoff methods for L2 eligibility
# Usage: Rscript benchmark_tau.R --species "Breviceps montanus" \
#          --env_csv_dir <path> --output_dir <path>
# 
# Methods:
#   tau_raw     = (max_p+1)*log(n)           [current, Dan's formula]
#   tau_raftery = ΔBIC ≤ 6                    [Raftery 1995]
#   tau_ebic    = BIC + 2*γ*log(C(P,2))       [Chen & Chen 2008, γ=0.5]
#
# Reports: eligible counts, model lists, pBIC distributions per method

suppressPackageStartupMessages({
  library(xsdm)
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
env_csv_dir  <- parse_arg("--env_csv_dir", "/home/a474r867/scratch/xsdm_env_extraction_19")
output_dir   <- parse_arg("--output_dir", "/home/a474r867/scratch/xsdm_1000_sp")

if (is.null(species_name)) stop("--species required")

sp_safe <- gsub(" ", "_", species_name)
l1_dir  <- file.path(output_dir, sp_safe, "phase1_results", "L1_models")
out_file <- file.path(output_dir, sp_safe, "phase1_results", "benchmark_tau.csv")

# ── Load L1 models ──
model_files <- sort(list.files(l1_dir, pattern = "^model_\\d+\\.rds$", full.names = TRUE))
if (length(model_files) == 0) stop("No L1 models found")

L1 <- list()
for (f in model_files) {
  fit <- readRDS(f)
  idx <- as.integer(gsub("model_|\\.rds", "", basename(f)))
  L1[[idx]] <- fit
}
L1 <- Filter(Negate(is.null), L1)

L1_pBIC <- sapply(L1, `[[`, "pBIC")
L1_names <- names(L1)
n_models <- length(L1)
best_pBIC <- min(L1_pBIC)
n_data <- L1[[1]]$n
max_p <- 2L

cat(sprintf("Loaded %d L1 models | n=%d | best pBIC=%.1f\n", n_models, n_data, best_pBIC))

# ── Method 1: tau_raw = (max_p+1)*log(n) ──
tau_raw <- (max_p + 1) * log(n_data)
eligible_raw <- L1_names[L1_pBIC <= best_pBIC + tau_raw]
cat(sprintf("\n=== Method 1: tau_raw = %.2f ===\n", tau_raw))
cat(sprintf("  Eligible: %d / %d (%.0f%%)\n", length(eligible_raw), n_models,
            100*length(eligible_raw)/n_models))
cat(sprintf("  Models: %s\n", paste(eligible_raw, collapse=", ")))

# ── Method 2: Raftery ΔBIC ≤ 6 ──
tau_raftery <- 6
eligible_raftery <- L1_names[L1_pBIC <= best_pBIC + tau_raftery]
cat(sprintf("\n=== Method 2: Raftery ΔBIC ≤ %.0f ===\n", tau_raftery))
cat(sprintf("  Eligible: %d / %d (%.0f%%)\n", length(eligible_raftery), n_models,
            100*length(eligible_raftery)/n_models))
cat(sprintf("  Models: %s\n", paste(eligible_raftery, collapse=", ")))

# ── Method 3: EBIC γ=0.5 ──
# Total candidate predictors: 19 bioclim, choose 2 → C(19,2)
P <- 19  # total candidate variables
gamma <- 0.5
penalty_ebic <- 2 * gamma * log(choose(P, max_p))
# EBIC adds penalty to each model's BIC
L1_EBIC <- L1_pBIC + penalty_ebic
best_EBIC <- min(L1_EBIC)
# Use same tau_raw as cutoff on EBIC scale
tau_ebic <- tau_raw  # same formula but applied to EBIC
eligible_ebic <- L1_names[L1_EBIC <= best_EBIC + tau_ebic]
cat(sprintf("\n=== Method 3: EBIC γ=%.1f (penalty=%.2f) ===\n", gamma, penalty_ebic))
cat(sprintf("  Best EBIC: %.1f (was pBIC=%.1f)\n", best_EBIC, best_pBIC))
cat(sprintf("  Eligible: %d / %d (%.0f%%)\n", length(eligible_ebic), n_models,
            100*length(eligible_ebic)/n_models))

# ── Write CSV ──
results <- data.frame(
  species = species_name,
  n_data = n_data,
  n_models = n_models,
  max_p = max_p,
  best_pBIC = best_pBIC,
  method = c("tau_raw", "tau_raftery", "tau_ebic"),
  tau_value = c(tau_raw, tau_raftery, tau_ebic),
  n_eligible = c(length(eligible_raw), length(eligible_raftery), length(eligible_ebic)),
  pct_eligible = round(100 * c(length(eligible_raw), length(eligible_raftery), length(eligible_ebic)) / n_models, 1),
  n_boundary_fits = c(length(eligible_raw), length(eligible_raftery), length(eligible_ebic)) * 9,
  eligible_models = c(
    paste(eligible_raw, collapse=";"),
    paste(eligible_raftery, collapse=";"),
    paste(eligible_ebic, collapse=";")
  )
)

write.csv(results, out_file, row.names = FALSE)
cat(sprintf("\nBenchmark written: %s\n", out_file))

# Print summary
cat("\n═══════════════════════════════════════════════════\n")
cat("SUMMARY\n")
cat("═══════════════════════════════════════════════════\n")
for (i in 1:nrow(results)) {
  cat(sprintf("%-15s | tau=%-6.2f | eligible=%-3d (%-4.1f%%) | boundary_fits=%d\n",
      results$method[i], results$tau_value[i], results$n_eligible[i],
      results$pct_eligible[i], results$n_boundary_fits[i]))
}

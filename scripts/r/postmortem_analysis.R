#!/usr/bin/env Rscript
# ══════════════════════════════════════════════════════════════════════
# Post-mortem analysis: predictors of model failure
# ══════════════════════════════════════════════════════════════════════
# Analyzes all completed species to find relationships between:
#   - Number of presences/absences
#   - Latitudinal range
#   - Taxonomic group
#   - Number/type of variables
#   - Geographic range size
# and model outcomes (success/failure, quality level, arc pass rate)
#
# Usage: Rscript postmortem_analysis.R --results_dir /path/to/results
#        Rscript postmortem_analysis.R --results_dir /path --occ_dir /path
# Output: docs/audit/postmortem_report.csv, docs/audit/postmortem_summary.md
# ──────────────────────────────────────────────────────────────────────

suppressPackageStartupMessages({
  library(stats)
})

# ── Argument parsing ─────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) > 0 && idx < length(args)) return(args[idx + 1])
  default
}

results_dir <- parse_arg("--results_dir", "/home/a474r867/scratch/xsdm_results")
occ_dir     <- parse_arg("--occ_dir", "/home/a474r867/scratch/xsdm_occurrences")
output_dir  <- parse_arg("--output_dir", "docs/audit")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# ── Gather all model results ─────────────────────────────────────────
cat("Scanning results directory:", results_dir, "\n")
rds_files <- list.files(results_dir, "model_results.rds",
                        recursive = TRUE, full.names = TRUE)
cat("Found", length(rds_files), "species with results\n")

records <- list()
for (i in seq_along(rds_files)) {
  if (i %% 500 == 0) cat("  Processed", i, "/", length(rds_files), "\n")

  r <- tryCatch(readRDS(rds_files[i]), error = function(e) NULL)
  if (is.null(r)) next

  sp_name <- r$species
  sp_safe <- gsub(" ", "_", sp_name)

  # Basic model info
  rec <- data.frame(
    species       = sp_name,
    status        = r$status,
    model_quality = ifelse(is.null(r$model_quality), NA_character_, r$model_quality),
    selected      = ifelse(is.null(r$selected), NA_character_, r$selected),
    pBIC          = ifelse(is.null(r$pBIC), NA_real_, r$pBIC),
    best_loglik   = ifelse(is.null(r$best_loglik), NA_real_, r$best_loglik),
    n_data        = ifelse(is.null(r$n_data), NA_integer_, r$n_data),
    stringsAsFactors = FALSE
  )

  # Arc check summary
  if (!is.null(r$arc_summary)) {
    rec$arcs_pass  <- r$arc_summary$n_pass
    rec$arcs_total <- r$arc_summary$n_total
    rec$arcs_pct   <- ifelse(r$arc_summary$n_total > 0,
                             r$arc_summary$n_pass / r$arc_summary$n_total, NA_real_)
  } else {
    rec$arcs_pass  <- NA_integer_
    rec$arcs_total <- NA_integer_
    rec$arcs_pct   <- NA_real_
  }

  # Fallback info
  rec$fallback_iters <- ifelse(is.null(r$fallback_iters), 0L, r$fallback_iters)

  # Occurrence data characteristics
  occ_file <- file.path(occ_dir, paste0(sp_safe, ".csv"))
  if (file.exists(occ_file)) {
    occ_data <- tryCatch(read.csv(occ_file), error = function(e) NULL)
    if (!is.null(occ_data)) {
      rec$n_presences <- sum(occ_data$occ == 1, na.rm = TRUE)
      rec$n_absences  <- sum(occ_data$occ == 0, na.rm = TRUE)
      rec$n_total_pts <- nrow(occ_data)
      rec$lat_min     <- min(occ_data$lat, na.rm = TRUE)
      rec$lat_max     <- max(occ_data$lat, na.rm = TRUE)
      rec$lat_range   <- rec$lat_max - rec$lat_min
      rec$lon_min     <- min(occ_data$lon, na.rm = TRUE)
      rec$lon_max     <- max(occ_data$lon, na.rm = TRUE)
      rec$lon_range   <- rec$lon_max - rec$lon_min
      rec$prevalence  <- rec$n_presences / rec$n_total_pts
    }
  }

  # Taxonomy (from species name)
  parts <- strsplit(sp_name, " ")[[1]]
  rec$genus <- parts[1]

  records[[length(records) + 1]] <- rec
}

# ── Combine into data frame ──────────────────────────────────────────
cat("Combining", length(records), "records...\n")
df <- do.call(rbind, records)
rownames(df) <- NULL

# ── Derived features ─────────────────────────────────────────────────
df$success <- as.integer(df$status == "success")
df$log_presences <- log10(pmax(df$n_presences, 1))
df$geo_area <- df$lat_range * df$lon_range  # crude geographic extent

# ── Statistical analysis ─────────────────────────────────────────────
cat("\n=== POST-MORTEM ANALYSIS ===\n\n")

# 1. Success rate by presence count bins
breaks <- c(0, 50, 100, 200, 500, 1000, 2000, 5000, Inf)
df$pres_bin <- cut(df$n_presences, breaks = breaks, right = FALSE,
                   labels = c("<50", "50-99", "100-199", "200-499",
                              "500-999", "1k-2k", "2k-5k", "5k+"))

success_by_pres <- tapply(df$success, df$pres_bin, function(x) {
  c(n = length(x), success = sum(x, na.rm = TRUE),
    rate = round(mean(x, na.rm = TRUE), 3))
})
cat("Success rate by # presences:\n")
print(do.call(rbind, success_by_pres))

# 2. Success rate by latitudinal range
lat_breaks <- c(0, 5, 10, 20, 40, 80, Inf)
df$lat_bin <- cut(df$lat_range, breaks = lat_breaks, right = FALSE,
                  labels = c("<5°", "5-10°", "10-20°", "20-40°", "40-80°", "80°+"))

success_by_lat <- tapply(df$success, df$lat_bin, function(x) {
  c(n = length(x), success = sum(x, na.rm = TRUE),
    rate = round(mean(x, na.rm = TRUE), 3))
})
cat("\nSuccess rate by latitudinal range:\n")
print(do.call(rbind, success_by_lat))

# 3. Success by prevalence (proportion of presences)
prev_breaks <- c(0, 0.1, 0.2, 0.3, 0.5, 0.8, 1.01)
df$prev_bin <- cut(df$prevalence, breaks = prev_breaks, right = FALSE,
                   labels = c("<10%", "10-20%", "20-30%", "30-50%", "50-80%", "80%+"))

success_by_prev <- tapply(df$success, df$prev_bin, function(x) {
  c(n = length(x), success = sum(x, na.rm = TRUE),
    rate = round(mean(x, na.rm = TRUE), 3))
})
cat("\nSuccess rate by prevalence:\n")
print(do.call(rbind, success_by_prev))

# 4. Top genera with highest failure rate (min 5 species)
genus_stats <- tapply(df$success, df$genus, function(x) {
  c(n = length(x), failures = sum(x == 0, na.rm = TRUE),
    fail_rate = round(1 - mean(x, na.rm = TRUE), 3))
})
genus_df <- do.call(rbind, genus_stats)
genus_df <- genus_df[genus_df[, "n"] >= 5, , drop = FALSE]
genus_df <- genus_df[order(-genus_df[, "fail_rate"]), , drop = FALSE]
cat("\nTop 20 genera by failure rate (n >= 5):\n")
print(head(genus_df, 20))

# 5. Logistic regression: predict failure from features
if (sum(!is.na(df$n_presences)) > 50) {
  model_formula <- success ~ log_presences + lat_range + prevalence + geo_area
  fit_glm <- tryCatch(
    glm(model_formula, data = df, family = binomial),
    error = function(e) NULL
  )
  if (!is.null(fit_glm)) {
    cat("\nLogistic regression (predicting success):\n")
    print(summary(fit_glm)$coefficients)
    cat("\nAIC:", AIC(fit_glm), "\n")
  }
}

# 6. Arc pass rate by model quality (for successful species)
if (any(!is.na(df$model_quality))) {
  cat("\nArc pass rate by model quality:\n")
  quality_stats <- tapply(df$arcs_pct[df$status == "success"],
                          df$model_quality[df$status == "success"],
                          function(x) c(n = length(x),
                                        mean_pct = round(mean(x, na.rm = TRUE), 3),
                                        median_pct = round(median(x, na.rm = TRUE), 3)))
  print(do.call(rbind, quality_stats))
}

# ── Save outputs ─────────────────────────────────────────────────────
write.csv(df, file.path(output_dir, "postmortem_report.csv"), row.names = FALSE)
cat("\nFull report saved:", file.path(output_dir, "postmortem_report.csv"), "\n")

# Summary markdown
sink(file.path(output_dir, "postmortem_summary.md"))
cat("# Post-Mortem Analysis: Model Failure Predictors\n\n")
cat(sprintf("**Total species:** %d\n", nrow(df)))
cat(sprintf("**Successful:** %d (%.1f%%)\n", sum(df$success), mean(df$success) * 100))
cat(sprintf("**Failed:** %d (%.1f%%)\n\n", sum(df$success == 0), mean(df$success == 0) * 100))

cat("## Key Findings\n\n")
cat("### 1. Effect of sample size (# presences)\n\n")
cat("| Bin | N | Success Rate |\n|---|---|---|\n")
for (nm in names(success_by_pres)) {
  v <- success_by_pres[[nm]]
  cat(sprintf("| %s | %d | %.1f%% |\n", nm, v["n"], v["rate"] * 100))
}

cat("\n### 2. Effect of geographic range (lat range)\n\n")
cat("| Bin | N | Success Rate |\n|---|---|---|\n")
for (nm in names(success_by_lat)) {
  v <- success_by_lat[[nm]]
  cat(sprintf("| %s | %d | %.1f%% |\n", nm, v["n"], v["rate"] * 100))
}

cat("\n### 3. Effect of prevalence\n\n")
cat("| Bin | N | Success Rate |\n|---|---|---|\n")
for (nm in names(success_by_prev)) {
  v <- success_by_prev[[nm]]
  cat(sprintf("| %s | %d | %.1f%% |\n", nm, v["n"], v["rate"] * 100))
}

cat("\n### 4. Top 10 genera with highest failure rate (n >= 5)\n\n")
cat("| Genus | N | Failures | Fail Rate |\n|---|---|---|---|\n")
for (i in seq_len(min(10, nrow(genus_df)))) {
  cat(sprintf("| %s | %d | %d | %.1f%% |\n",
              rownames(genus_df)[i],
              genus_df[i, "n"], genus_df[i, "failures"],
              genus_df[i, "fail_rate"] * 100))
}

if (!is.null(fit_glm)) {
  cat("\n### 5. Logistic regression coefficients\n\n")
  cat("| Predictor | Estimate | Std.Error | z | p |\n|---|---|---|---|---|\n")
  coefs <- summary(fit_glm)$coefficients
  for (nm in rownames(coefs)) {
    cat(sprintf("| %s | %.4f | %.4f | %.2f | %.4f |\n",
                nm, coefs[nm, 1], coefs[nm, 2], coefs[nm, 3], coefs[nm, 4]))
  }
}

sink()
cat("Summary saved:", file.path(output_dir, "postmortem_summary.md"), "\n")
cat("Done.\n")

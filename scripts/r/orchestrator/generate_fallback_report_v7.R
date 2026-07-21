#!/usr/bin/env Rscript
# generate_fallback_report_v7.R
#
# Fallback report when no model is well-behaved in L3.
# Picks the converged model with the lowest pBIC, runs profile + prediction,
# writes a selection_meta.tsv, and calls generate_report_v7.R.
#
# Usage:
#   Rscript scripts/r/orchestrator/generate_fallback_report_v7.R \
#     --species_dir /path/to/outputs_M/<species> \
#     --bioclim_dir /path/to/bioclim

library(terra)

parse_arg <- function(name, default = NULL) {
  args <- commandArgs(trailingOnly = TRUE)
  idx <- which(args == name)
  if (length(idx) > 0 && idx < length(args)) return(args[idx + 1])
  if (!is.null(default)) return(default)
  stop("Missing argument ", name, call. = FALSE)
}

repo_root   <- parse_arg("--repo_root", "/home/a474r867/work/xsdm_1000_sp_v7")
species_dir <- parse_arg("--species_dir")
bioclim_dir <- parse_arg("--bioclim_dir", "/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim")
num_threads <- as.integer(parse_arg("--num_threads", "2"))

# Disable occurrence prefilter so all pseudo-absences are used in TSS.
Sys.setenv("APPLY_PREFILTER" = "false")
models_dir <- file.path(species_dir, "models")
wb_dir     <- file.path(species_dir, "wb")
occ_csv    <- file.path(species_dir, "occ_v7.csv")
gis_dir    <- file.path(species_dir, "gis")
plots_dir  <- file.path(species_dir, "plots")

if (!dir.exists(models_dir)) stop("No models directory", call. = FALSE)

# Read all well-behaved results (and model RDS as fallback)
wb_files <- list.files(wb_dir, pattern = "_wb\\.rds$", full.names = TRUE)
wb_results <- list()
for (f in wb_files) {
  nm <- sub("_wb\\.rds$", "", basename(f))
  r <- tryCatch(readRDS(f), error = function(e) NULL)
  if (is.null(r)) next
  if (is.finite(r$pBIC)) {
    wb_results[[nm]] <- r
  }
}

if (length(wb_results) == 0) stop("No well-behaved result files found", call. = FALSE)

pbics <- sapply(wb_results, `[[`, "pBIC")
n_conv <- sapply(wb_results, function(x) as.integer(x$n_converged))

# Prefer a model with at least 3 optima reached and distance < threshold (0.05)
cand3 <- names(wb_results)[n_conv >= 3]
if (length(cand3) > 0) {
  best_name <- cand3[which.min(pbics[cand3])]
  best_pBIC <- min(pbics[cand3])
} else {
  best_name <- names(which.min(pbics))
  best_pBIC <- min(pbics)
}

occ <- read.csv(occ_csv, stringsAsFactors = FALSE, check.names = FALSE)
n_data <- nrow(occ)

# Identify L1 / L2 models by name pattern (L2/L4 contain '__')
L1_names <- names(wb_results)[!grepl("__", names(wb_results), fixed = TRUE)]
L2_names <- names(wb_results)[grepl("__", names(wb_results), fixed = TRUE)]

L1_success <- sum(!is.na(pbics[L1_names]))
N_L2 <- length(L2_names)
N_L4 <- 0

best_pBIC_L1 <- min(pbics[L1_names], na.rm = TRUE)
tau <- 4 * log(n_data)
threshold_l2 <- best_pBIC_L1 + tau
omega <- best_pBIC
omega_tau <- omega + tau

# Sort all models by pBIC for the scanned list
all_sorted <- names(sort(pbics))

# Write selection_meta.tsv
meta_file <- file.path(species_dir, "selection_meta.tsv")
meta <- file(meta_file, "w")
writeLines(sprintf("SPECIES\t%s", basename(species_dir)), meta)
writeLines(sprintf("N_DATA\t%d", n_data), meta)
writeLines(sprintf("MAX_P\t3"), meta)
writeLines(sprintf("TAU\t%.20f", tau), meta)
writeLines(sprintf("BEST_PBIC_L1\t%.4f", best_pBIC_L1), meta)
writeLines(sprintf("THRESHOLD_L2\t%.20f", threshold_l2), meta)
writeLines(sprintf("OMEGA\t%.4f", omega), meta)
writeLines(sprintf("M_OMEGA\t%s", best_name), meta)
writeLines(sprintf("OMEGA_TAU\t%.20f", omega_tau), meta)
writeLines(sprintf("N_L1_SUCCESS\t%d", L1_success), meta)
writeLines(sprintf("N_L2\t%d", N_L2), meta)
writeLines(sprintf("N_L4\t%d", N_L4), meta)
for (nm in all_sorted) {
  writeLines(sprintf("SCANNED_MODEL\t%s", nm), meta)
}
for (nm in L1_names) {
  if (is.finite(pbics[[nm]])) {
    writeLines(sprintf("L1\t%s\t%.4f", nm, pbics[[nm]]), meta)
  }
}
for (nm in L2_names) {
  if (is.finite(pbics[[nm]])) {
    writeLines(sprintf("L2_MODEL\t%s", nm), meta)
  }
}
close(meta)

cat(sprintf("Fallback best model: %s (pBIC = %.4f)\n", best_name, best_pBIC))

# Run profile and prediction for the best model
best_rds <- file.path(models_dir, paste0(best_name, ".rds"))

profile_cmd <- c(
  file.path(repo_root, "scripts", "r", "orchestrator", "run_profile_v7.R"),
  "--species_dir", species_dir,
  "--model_rds", best_rds,
  "--output_dir", species_dir,
  "--num_threads", as.character(num_threads)
)
# Use the Rscript in the container path; assume caller sets up Rscript
system2("Rscript", profile_cmd, stdout = TRUE, stderr = TRUE)

predict_cmd <- c(
  file.path(repo_root, "scripts", "r", "orchestrator", "predict_map_v7.R"),
  "--species_dir", species_dir,
  "--model_rds", best_rds,
  "--occ_csv", occ_csv,
  "--bioclim_dir", bioclim_dir,
  "--output_png", file.path(plots_dir, "habitat_suitability_v7.png"),
  "--shapefile_out", file.path(gis_dir, "prediction_extent.shp"),
  "--m_shapefile", file.path(gis_dir, "M_buffer.shp"),
  "--num_threads", as.character(num_threads)
)
system2("Rscript", predict_cmd, stdout = TRUE, stderr = TRUE)

# Now call the standard report generator
report_cmd <- c(
  file.path(repo_root, "scripts", "r", "orchestrator", "generate_report_v7.R"),
  "--species_dir", species_dir,
  "--meta", meta_file,
  "--output", file.path(species_dir, "model_selection_report.md")
)
out <- system2("Rscript", report_cmd, stdout = TRUE, stderr = TRUE)
writeLines(out)

cat("Fallback report written to:", file.path(species_dir, "model_selection_report.md"), "\n")

#!/usr/bin/env Rscript
# extract_model_info.R
# Extracts model metadata (selected model, n_vars, n_free_params)
# for species that have profile likelihood PDFs.
# Output: CSV + markdown table pushed to GitHub via the repo.

args <- commandArgs(trailingOnly = TRUE)
results_dir <- if (length(args) >= 1) args[1] else "/home/a474r867/scratch/xsdm_results"
output_csv  <- if (length(args) >= 2) args[2] else "docs/audit/model_info_100.csv"
output_md   <- if (length(args) >= 3) args[3] else "docs/audit/model_info_100.md"

# Get the 100 species from the profile PDFs directory
pdf_dir <- "docs/profile_pdfs"
pdfs <- list.files(pdf_dir, pattern = "_profile\\.pdf$")
species <- sub("_profile\\.pdf$", "", pdfs)
species <- sort(species)[1:min(100, length(species))]

cat("Processing", length(species), "species...\n")

out <- data.frame(
  species        = character(),
  selected_model = character(),
  n_vars         = integer(),
  n_free_params  = integer(),
  stringsAsFactors = FALSE
)

for (sp in species) {
  rds_path <- file.path(results_dir, sp, "model_results.rds")
  if (file.exists(rds_path)) {
    res <- tryCatch(readRDS(rds_path), error = function(e) NULL)
    if (!is.null(res)) {
      sel <- if (!is.null(res$selected)) res$selected else "none"
      nv  <- if (!is.null(res$model_vars)) length(res$model_vars) else NA
      np  <- if (!is.null(res$profiles)) length(res$profiles) else NA
      out <- rbind(out, data.frame(
        species = sp, selected_model = sel,
        n_vars = nv, n_free_params = np, stringsAsFactors = FALSE
      ))
    } else {
      out <- rbind(out, data.frame(
        species = sp, selected_model = "read_error",
        n_vars = NA, n_free_params = NA, stringsAsFactors = FALSE
      ))
    }
  } else {
    out <- rbind(out, data.frame(
      species = sp, selected_model = "no_rds",
      n_vars = NA, n_free_params = NA, stringsAsFactors = FALSE
    ))
  }
}

# Write CSV
dir.create(dirname(output_csv), recursive = TRUE, showWarnings = FALSE)
write.csv(out, output_csv, row.names = FALSE)
cat("CSV written to", output_csv, "\n")

# Write markdown table
dir.create(dirname(output_md), recursive = TRUE, showWarnings = FALSE)
lines <- c(
  "# Model Info for 100 Profile PDF Species",
  "",
  sprintf("Generated: %s", Sys.time()),
  "",
  "| # | Species | Selected Model | N Vars | N Free Params |",
  "|---|---------|---------------|--------|---------------|"
)
for (i in seq_len(nrow(out))) {
  lines <- c(lines, sprintf("| %d | %s | %s | %s | %s |",
    i, out$species[i], out$selected_model[i],
    ifelse(is.na(out$n_vars[i]), "—", as.character(out$n_vars[i])),
    ifelse(is.na(out$n_free_params[i]), "—", as.character(out$n_free_params[i]))
  ))
}

# Summary stats
lines <- c(lines, "", "## Summary", "")
if (nrow(out) > 0) {
  with_model <- out[out$selected_model != "no_rds" & out$selected_model != "read_error" & out$selected_model != "none", ]
  lines <- c(lines, sprintf("- **Total species:** %d", nrow(out)))
  lines <- c(lines, sprintf("- **With model:** %d (%.1f%%)", nrow(with_model), 100*nrow(with_model)/nrow(out)))
  lines <- c(lines, sprintf("- **No RDS found:** %d", sum(out$selected_model == "no_rds")))
  if (nrow(with_model) > 0) {
    lines <- c(lines, sprintf("- **1-var models:** %d", sum(with_model$n_vars == 1, na.rm = TRUE)))
    lines <- c(lines, sprintf("- **2-var models:** %d", sum(with_model$n_vars == 2, na.rm = TRUE)))
    lines <- c(lines, sprintf("- **3-var models:** %d", sum(with_model$n_vars == 3, na.rm = TRUE)))
    lines <- c(lines, sprintf("- **4-var models:** %d", sum(with_model$n_vars == 4, na.rm = TRUE)))
    lines <- c(lines, sprintf("- **Avg free params:** %.1f", mean(with_model$n_free_params, na.rm = TRUE)))
  }
}

writeLines(lines, output_md)
cat("Markdown written to", output_md, "\n")
cat("Done!\n")

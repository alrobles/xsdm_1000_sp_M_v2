#!/usr/bin/env Rscript
# 01_consolidate_occurrences.R
# ──────────────────────────────────────────────────────────────────────
# Consolidate all species occurrence CSVs into a single Parquet file.
#
# Input:  directory of CSVs (lon, lat, occ) — one per species
# Output: species_occurrences.parquet (species, lon, lat, presence)
#
# Usage:
#   Rscript 01_consolidate_occurrences.R \
#     --occ_dir /home/a474r867/scratch/xsdm_occurrences \
#     --output  /home/a474r867/scratch/xsdm_data/species_occurrences.parquet
# ──────────────────────────────────────────────────────────────────────

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(arrow)
  library(data.table)
})

# ── Parse arguments ──────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

occ_dir <- parse_arg("--occ_dir", "/home/a474r867/scratch/xsdm_occurrences")
output  <- parse_arg("--output",  "/home/a474r867/scratch/xsdm_data/species_occurrences.parquet")

dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)

# ── List CSV files ───────────────────────────────────────────────────
csv_files <- list.files(occ_dir, pattern = "\\.csv$", full.names = TRUE)
cat("Found", length(csv_files), "CSV files in", occ_dir, "\n")

# ── Read and bind all CSVs ───────────────────────────────────────────
t0 <- Sys.time()

read_one <- function(f) {
  tryCatch({
    dt <- fread(f, select = c("lon", "lat", "occ"))
    # Remove rows with invalid coordinates
    dt <- dt[is.finite(lon) & is.finite(lat) & lon >= -180 & lon <= 180 &
             lat >= -90 & lat <= 90]
    dt[, species := tools::file_path_sans_ext(basename(f))]
    dt
  }, error = function(e) {
    cat("  WARNING: skipping", basename(f), "—", e$message, "\n")
    NULL
  })
}

all_list <- lapply(csv_files, read_one)
n_skipped <- sum(vapply(all_list, is.null, logical(1)))
if (n_skipped > 0) cat("Skipped", n_skipped, "unreadable files\n")
all_data <- rbindlist(Filter(Negate(is.null), all_list), use.names = TRUE)

# Rename occ -> presence for xsdm compatibility
setnames(all_data, "occ", "presence")

# Reorder columns
setcolorder(all_data, c("species", "lon", "lat", "presence"))

elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
cat(sprintf("Read %d records from %d species in %.1fs\n",
            nrow(all_data), uniqueN(all_data$species), elapsed))

# ── Summary stats ────────────────────────────────────────────────────
cat("\n=== Summary ===\n")
cat("Total records:", nrow(all_data), "\n")
cat("Total species:", uniqueN(all_data$species), "\n")
cat("Presences:", sum(all_data$presence == 1), "\n")
cat("Unique coordinates:", uniqueN(all_data[, .(lon, lat)]), "\n")

per_species <- all_data[, .N, by = species]
cat("Records per species — min:", min(per_species$N),
    " median:", median(per_species$N),
    " max:", max(per_species$N), "\n")

# ── Write Parquet ────────────────────────────────────────────────────
t0 <- Sys.time()
write_parquet(all_data, output, compression = "zstd")
elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

file_mb <- file.size(output) / 1e6
cat(sprintf("\nWritten: %s (%.1f MB, %.1fs)\n", output, file_mb, elapsed))
cat("Done.\n")

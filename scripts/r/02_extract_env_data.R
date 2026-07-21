#!/usr/bin/env Rscript
# 02_extract_env_data.R
# ──────────────────────────────────────────────────────────────────────
# Extract bioclimatic values at all unique occurrence coordinates.
# One-time job: reads 246 rasters (6 vars × 41 years), extracts at
# all unique (lon, lat) pairs, saves as Parquet.
#
# Input:
#   --occ_parquet   species_occurrences.parquet (from step 01)
#   --bioclim_dir   path to bioclim/{YYYY}/bioNN_{YYYY}.tif
#   --output        path for env_extracted.parquet
#   --years         comma-separated (default: 1980,...,2020)
#
# Output: env_extracted.parquet
#   Columns: lon, lat, year, bio01, bio10, bio11, bio12, bio16, bio17
#   Rows:    unique_coords × n_years
# ──────────────────────────────────────────────────────────────────────

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(arrow)
  library(terra)
  library(data.table)
})

# ── Parse arguments ──────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

occ_parquet <- parse_arg("--occ_parquet",
                         "/home/a474r867/scratch/xsdm_data/species_occurrences.parquet")
bioclim_dir <- parse_arg("--bioclim_dir",
                         "/home/a474r867/scratch/era5-land/era5_bioclim/bioclim")
output      <- parse_arg("--output",
                         "/home/a474r867/scratch/xsdm_data/env_extracted.parquet")
years_str   <- parse_arg("--years", paste(1980:2020, collapse = ","))

years <- as.integer(strsplit(years_str, ",")[[1]])
bio_vars <- c("bio01", "bio10", "bio11", "bio12", "bio16", "bio17")

dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)

# ── Load unique coordinates ──────────────────────────────────────────
cat("Reading occurrences from:", occ_parquet, "\n")
occ <- as.data.table(read_parquet(occ_parquet, col_select = c("lon", "lat")))
coords <- unique(occ[, .(lon, lat)])
cat("Unique coordinates:", nrow(coords), "\n")

# Create SpatVector for extraction
pts <- vect(as.data.frame(coords), geom = c("lon", "lat"),
            crs = "EPSG:4326")

# ── Extract all variables × all years ────────────────────────────────
cat(sprintf("\nExtracting %d variables × %d years at %d coordinates\n",
            length(bio_vars), length(years), nrow(coords)))
cat("Total raster reads:", length(bio_vars) * length(years), "\n\n")

results <- vector("list", length(years))
total_t0 <- Sys.time()

for (yi in seq_along(years)) {
  yr <- years[yi]
  t0 <- Sys.time()

  year_dt <- data.table(lon = coords$lon, lat = coords$lat, year = yr)

  for (var in bio_vars) {
    tif_path <- file.path(bioclim_dir, yr, paste0(var, "_", yr, ".tif"))
    if (!file.exists(tif_path)) {
      warning("Missing: ", tif_path)
      year_dt[[var]] <- NA_real_
      next
    }
    r <- rast(tif_path)
    vals <- extract(r, pts, ID = FALSE)[[1]]
    year_dt[[var]] <- vals
  }

  results[[yi]] <- year_dt
  elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  cat(sprintf("  [%2d/%d] %d  (%.1fs)\n", yi, length(years), yr, elapsed))
}

# ── Combine and write ────────────────────────────────────────────────
all_env <- rbindlist(results)
total_elapsed <- as.numeric(difftime(Sys.time(), total_t0, units = "secs"))

cat(sprintf("\n=== Summary ===\n"))
cat("Rows:", nrow(all_env), "\n")
cat("Columns:", paste(names(all_env), collapse = ", "), "\n")
cat("NAs per variable:\n")
for (v in bio_vars) {
  cat(sprintf("  %s: %d (%.1f%%)\n", v, sum(is.na(all_env[[v]])),
              100 * mean(is.na(all_env[[v]]))))
}

t0 <- Sys.time()
write_parquet(all_env, output, compression = "zstd")
write_elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

file_mb <- file.size(output) / 1e6
cat(sprintf("\nWritten: %s (%.1f MB, %.1fs)\n", output, file_mb, write_elapsed))
cat(sprintf("Total extraction time: %.1f min\n", total_elapsed / 60))
cat("Done.\n")

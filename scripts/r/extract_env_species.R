#!/usr/bin/env Rscript
# extract_env_species.R — Extract bioclim values at occurrence points for one species
#
# Reads a species CSV (lon, lat, occ) and extracts 6 bioclim variables
# across 41 years (1980–2020) from GeoTIFF rasters. Outputs one CSV per
# variable with years as columns, ready for xsdm_model_selection.R.
#
# Usage:
#   Rscript extract_env_species.R \
#     --species "Phrynosoma modestum" \
#     --occ_dir  /home/a474r867/scratch/xsdm_occurrences \
#     --bioclim_dir /home/a474r867/scratch/era5-land/era5_bioclim/bioclim \
#     --output_dir /home/a474r867/scratch/xsdm_env_extraction \
#     --years 1980:2020

suppressPackageStartupMessages(library(terra))

# ── Argument parsing ──────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name <- parse_arg("--species")
occ_dir      <- parse_arg("--occ_dir",
                           "/home/a474r867/scratch/xsdm_occurrences")
bioclim_dir  <- parse_arg("--bioclim_dir",
                           "/home/a474r867/scratch/era5-land/era5_bioclim/bioclim")
output_dir   <- parse_arg("--output_dir",
                           "/home/a474r867/scratch/xsdm_env_extraction")
year_range   <- parse_arg("--years", "1980:2020")

if (is.null(species_name)) stop("--species is required", call. = FALSE)

years <- eval(parse(text = year_range))

# All 19 bioclim variables: T=temperature (bio01-bio11), P=precipitation (bio12-bio19)
# Default: extract all 19; use --vars "bio01,bio10,bio11,bio12,bio16,bio17" for legacy 6
vars_arg <- parse_arg("--vars", NULL)

if (!is.null(vars_arg)) {
  bio_vars <- strsplit(vars_arg, ",")[[1]]
} else {
  bio_vars <- paste0("bio", sprintf("%02d", 1:19))
}

# Label each variable with T (temperature) or P (precipitation) prefix
bio_labels <- vapply(bio_vars, function(v) {
  num <- as.integer(sub("bio", "", v))
  prefix <- if (num <= 11) paste0("T", num) else paste0("P", num)
  paste0(prefix, "_", v)
}, character(1), USE.NAMES = FALSE)

cat("===================================================\n")
cat("Environment Extraction\n")
cat("Species:", species_name, "\n")
cat("Years:  ", min(years), "-", max(years),
    "(", length(years), "years)\n")
cat("Vars:   ", paste(bio_vars, collapse = ", "), "\n")
cat("===================================================\n")

# ── Read occurrence CSV ───────────────────────────────────────────────
occ_file <- file.path(occ_dir, paste0(species_name, ".csv"))
if (!file.exists(occ_file)) {
  stop("Occurrence file not found: ", occ_file, call. = FALSE)
}

occ <- read.csv(occ_file, stringsAsFactors = FALSE)
if ("occ" %in% names(occ) && !"presence" %in% names(occ)) {
  names(occ)[names(occ) == "occ"] <- "presence"
}
n_pts <- nrow(occ)
cat("Points:", n_pts, "(", sum(occ$presence == 1), "presences,",
    sum(occ$presence == 0), "absences)\n")

# ── Create output directory ──────────────────────────────────────────
sp_safe <- gsub(" ", "_", species_name)
sp_out  <- file.path(output_dir, sp_safe)
dir.create(sp_out, recursive = TRUE, showWarnings = FALSE)

# ── Extract from rasters ─────────────────────────────────────────────
# For each variable, create a matrix: n_pts × n_years
pts <- vect(occ, geom = c("lon", "lat"), crs = "EPSG:4326")
t0 <- Sys.time()

for (vi in seq_along(bio_vars)) {
  var_code  <- bio_vars[vi]
  var_label <- bio_labels[vi]
  cat(sprintf("  %s (%d/%d)...", var_label, vi, length(bio_vars)))

  # Pre-allocate matrix
  mat <- matrix(NA_real_, nrow = n_pts, ncol = length(years))
  colnames(mat) <- as.character(years)

  for (ti in seq_along(years)) {
    yr <- years[ti]
    rast_path <- file.path(bioclim_dir, yr,
                           paste0(var_code, "_", yr, ".tif"))
    if (!file.exists(rast_path)) {
      warning("Missing: ", rast_path)
      next
    }
    r <- rast(rast_path)
    vals <- extract(r, pts)[, 2]  # extract returns ID + value columns
    mat[, ti] <- vals
  }

  # Write CSV: lon, lat, presence, 1980, 1981, ..., 2020
  out_df <- data.frame(
    lon = occ$lon,
    lat = occ$lat,
    presence = occ$presence,
    mat,
    check.names = FALSE
  )
  out_file <- file.path(sp_out, paste0(var_label, ".csv"))
  write.csv(out_df, out_file, row.names = FALSE)
  cat(sprintf(" %d pts × %d yrs → %s\n", n_pts, length(years), basename(out_file)))
}

elapsed <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
cat(sprintf("\nDone: %s — %.1f seconds (%.1f min)\n",
            species_name, elapsed, elapsed / 60))

# ── Write a metadata file ────────────────────────────────────────────
meta <- data.frame(
  species = species_name,
  n_points = n_pts,
  n_presences = sum(occ$presence == 1),
  n_absences = sum(occ$presence == 0),
  n_years = length(years),
  year_min = min(years),
  year_max = max(years),
  extraction_time_sec = round(elapsed, 1),
  timestamp = Sys.time()
)
write.csv(meta, file.path(sp_out, "metadata.csv"), row.names = FALSE)

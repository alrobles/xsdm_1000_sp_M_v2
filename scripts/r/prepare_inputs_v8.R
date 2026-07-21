#!/usr/bin/env Rscript
# prepare_inputs_v8.R — Build v8 inputs for one species:
#   1. Load presence points (lon, lat, occ/presence).
#   2. Overlay with Ecoregions2017 and keep ecoregions accounting for >=90% of presences.
#   3. Dissolve selected ecoregions -> M.
#   4. Buffer M by median nearest-neighbour distance of presence points.
#   5. Sample pseudo-absences INSIDE M using one of two strategies:
#        - random: uniform random within M
#        - centroid: probability proportional to distance from the centroid of M
#          (farther from the centroid = higher probability, so edges get more PAs)
#      Number of pseudo-absences = pa_factor * n_presences (pa_factor defaults to 1).
#   6. Extract 6 bioclim variables x 41 years at presences + pseudo-absences.
#   7. Write CSVs per variable (same format as xsdm_model_selection_v6.R),
#      an occ_v7.csv, and M / M_buffer shapefiles.

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

options(error = function() { traceback(2); quit(save = "no", status = 1) })

suppressPackageStartupMessages({
  library(terra)
})

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_name   <- parse_arg("--species")
occ_csv        <- parse_arg("--occ_csv")
ecoregion_shp  <- parse_arg("--ecoregion_shp")
bioclim_dir    <- parse_arg("--bioclim_dir",
                            "/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim")
output_dir     <- parse_arg("--output_dir", "/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_v8")
years_str      <- parse_arg("--years", paste(1980:2020, collapse = ","))
pa_factor      <- as.numeric(parse_arg("--pa_factor", "1"))
seed           <- as.integer(parse_arg("--seed", "42"))
buffer_m_arg   <- parse_arg("--buffer_m", "median")
pa_method      <- tolower(parse_arg("--pa_method", "centroid"))
pa_exp_scale   <- as.numeric(parse_arg("--pa_exp_scale", "3"))
coastline_shp  <- parse_arg("--coastline_shp", "")

if (is.null(species_name)) stop("--species is required", call. = FALSE)
if (is.null(occ_csv))      stop("--occ_csv is required", call. = FALSE)
if (is.null(ecoregion_shp)) stop("--ecoregion_shp is required", call. = FALSE)
if (!pa_method %in% c("random", "centroid", "centroid_exp", "dataset")) {
  stop("--pa_method must be 'random', 'centroid', 'centroid_exp' or 'dataset'", call. = FALSE)
}
if (!is.finite(pa_factor) || pa_factor <= 0) {
  stop("--pa_factor must be a positive number", call. = FALSE)
}

years <- as.integer(strsplit(years_str, ",", fixed = TRUE)[[1]])

bio_vars <- c(
  "bio01" = "T1_bio01",
  "bio10" = "T10_bio10",
  "bio11" = "T11_bio11",
  "bio12" = "P12_bio12",
  "bio16" = "P16_bio16",
  "bio17" = "P17_bio17"
)

sp_safe <- gsub(" ", "_", species_name)
sp_dir  <- file.path(output_dir, sp_safe)
gis_dir <- file.path(sp_dir, "gis")
dir.create(sp_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(gis_dir, recursive = TRUE, showWarnings = FALSE)

# ─────────────────────────────────────────────────────────────────────────────
# 1. Read presences
# ─────────────────────────────────────────────────────────────────────────────
occ <- read.csv(occ_csv, stringsAsFactors = FALSE)
if ("occ" %in% names(occ) && !"presence" %in% names(occ)) {
  names(occ)[names(occ) == "occ"] <- "presence"
}
if (!all(c("lon", "lat", "presence") %in% names(occ))) {
  stop("occurrence CSV must contain lon, lat, and presence/occ columns", call. = FALSE)
}

pres <- occ[as.integer(occ$presence) == 1L, c("lon", "lat", "presence"), drop = FALSE]
pres <- pres[!is.na(pres$lon) & !is.na(pres$lat), , drop = FALSE]
if (nrow(pres) < 3) {
  stop(sprintf("Only %d presences for %s", nrow(pres), species_name), call. = FALSE)
}

pres_vect <- vect(pres, geom = c("lon", "lat"), crs = "EPSG:4326")

# ─────────────────────────────────────────────────────────────────────────────
# 2. Overlay ecoregions
# ─────────────────────────────────────────────────────────────────────────────
eco <- vect(ecoregion_shp)
if (!is.lonlat(eco)) eco <- project(eco, "EPSG:4326")

name_field <- intersect(names(eco), c("ECO_NAME", "ECO_NAME_", "ecoregion", "Ecoregion", "ECO"))
if (length(name_field) == 0) stop("No usable ecoregion name field found", call. = FALSE)
name_field <- name_field[1]

eco_hit <- extract(eco, pres_vect)
# A point exactly on a shared ecoregion boundary can be matched to multiple
# polygons, producing more rows than pres. In that case, fall back to the first
# ecoregion that covers each presence.
if (nrow(eco_hit) != nrow(pres)) {
  rel_mat <- relate(eco, pres_vect, "covers")
  first_idx <- apply(rel_mat, 2, function(x) {
    w <- which(x)
    if (length(w) > 0) as.integer(w[1]) else NA_integer_
  })
  pres$eco_name <- as.character(as.data.frame(eco)[[name_field]])[first_idx]
} else {
  if (!name_field %in% names(eco_hit)) {
    stop("Ecoregion name field ", name_field, " not returned by extract()", call. = FALSE)
  }
  pres$eco_name <- as.character(eco_hit[[name_field]])
}

# Drop points that fall outside ecoregions (ocean, etc.)
pres <- pres[!is.na(pres$eco_name), , drop = FALSE]
n_pres <- nrow(pres)
if (n_pres < 3) stop(sprintf("Only %d presences inside ecoregions", n_pres), call. = FALSE)

# ─────────────────────────────────────────────────────────────────────────────
# 3. Select ecoregions covering >= 90% of presences
# ─────────────────────────────────────────────────────────────────────────────
tab <- sort(table(pres$eco_name), decreasing = TRUE)
cum_tab <- cumsum(tab)
target <- ceiling(0.90 * n_pres)
selected_names <- names(tab)[cum_tab <= target]
if (length(selected_names) == 0) selected_names <- names(tab)[1]
if (sum(tab[selected_names]) < 0.90 * n_pres && length(tab) > length(selected_names)) {
  selected_names <- c(selected_names, names(tab)[length(selected_names) + 1])
}

cat(sprintf("Selected ecoregions (%d of %d) covering %d/%d presences:\n",
            length(selected_names), length(tab), sum(tab[selected_names]), n_pres))
cat(paste(" ", selected_names, collapse = "\n"), "\n")

# Keep only presences inside the selected ecoregions (the accessibility area M)
pres <- pres[pres$eco_name %in% selected_names, , drop = FALSE]
n_pres <- nrow(pres)
if (n_pres < 3) {
  stop(sprintf("Only %d presences remain inside selected ecoregions for %s", n_pres, species_name), call. = FALSE)
}
cat(sprintf("Presences retained inside selected ecoregions: %d\n", n_pres))

eco_names <- as.character(as.data.frame(eco)[[name_field]])
eco_sel <- eco[eco_names %in% selected_names, ]
eco_sel$group <- 1L
M <- aggregate(eco_sel, by = "group", dissolve = TRUE)

# ─────────────────────────────────────────────────────────────────────────────
# 4. Buffer (m): median NND by default, or a fixed value (e.g. 100 km)
# ─────────────────────────────────────────────────────────────────────────────
pres_vect <- vect(pres, geom = c("lon", "lat"), crs = "EPSG:4326")
dist_mat <- as.matrix(terra::distance(pres_vect))
diag(dist_mat) <- Inf
nnd <- apply(dist_mat, 1, min, na.rm = TRUE)
median_nnd <- median(nnd, na.rm = TRUE)

if (buffer_m_arg == "median") {
  buffer_m <- median_nnd
  if (!is.finite(buffer_m) || buffer_m <= 0) buffer_m <- 1000
} else {
  buffer_m <- as.numeric(buffer_m_arg)
  if (is.na(buffer_m) || buffer_m <= 0) {
    stop("--buffer_m must be 'median' or a positive number of meters", call. = FALSE)
  }
}

M_buffer <- buffer(M, width = buffer_m)

# Clip to coastline/land polygon if provided, so M and M_buffer fit coasts and islands
if (nzchar(coastline_shp) && file.exists(coastline_shp)) {
  cat("Clipping M/M_buffer to coastline:", coastline_shp, "\n")
  coast <- vect(coastline_shp)
  if (!is.lonlat(coast)) coast <- project(coast, "EPSG:4326")
  M        <- terra::intersect(M, coast)
  M_buffer <- terra::intersect(M_buffer, coast)
}

cat(sprintf("Median NND = %.1f m -> buffer = %.1f m\n", median_nnd, buffer_m))

# ─────────────────────────────────────────────────────────────────────────────
# 5. Sample pseudo-absences INSIDE M (land only)
# ─────────────────────────────────────────────────────────────────────────────
pa_mask <- M

set.seed(seed + n_pres)
n_pa <- round(pa_factor * n_pres)
if (n_pa < 1) n_pa <- 1L

# Build a land mask that is valid (non-NA) for ALL 6 variables across ALL years
# inside the pseudo-absence mask, so sampled PAs have complete data.
base_tif <- file.path(bioclim_dir, as.character(years[1]),
                      paste0("bio01_", years[1], ".tif"))
if (!file.exists(base_tif)) {
  stop("Cannot build land mask; missing: ", base_tif, call. = FALSE)
}
r_mask <- rast(base_tif)
r_mask <- terra::crop(r_mask, pa_mask, mask = TRUE)
r_mask <- ifel(!is.na(r_mask), 1, NA)

for (bio_code in names(bio_vars)) {
  paths <- file.path(bioclim_dir, as.character(years),
                     paste0(bio_code, "_", years, ".tif"))
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0) {
    stop("Missing rasters for ", bio_code, ": ", missing[1], call. = FALSE)
  }
  r <- rast(paths)
  rc <- terra::crop(r, pa_mask, mask = TRUE)
  count_non_na <- terra::app(!is.na(rc), sum)
  valid <- ifel(count_non_na == length(years), 1, NA)
  r_mask <- r_mask * valid
  cat(sprintf("  mask: %s -> valid cells = %d\n", bio_code,
              as.integer(global(!is.na(r_mask), "sum", na.rm = TRUE))))
}

# Sample according to the chosen method
if (pa_method == "random") {
  cat(sprintf("Sampling %d pseudo-absences uniformly at random inside M\n", n_pa))
  pa_vect <- tryCatch(
    terra::spatSample(r_mask, size = n_pa, method = "random", as.points = TRUE,
                      values = FALSE, na.rm = TRUE, exhaustive = FALSE),
    error = function(e) NULL
  )
} else if (pa_method %in% c("centroid", "centroid_exp")) {
  cat(sprintf("Sampling %d pseudo-absences with probability %s from M centroid\n",
              n_pa, ifelse(pa_method == "centroid_exp", "increasing exponentially", "proportional to distance")))
  # Compute distance from each valid cell to the nearest centroid of M.
  # This gives low probability near the centroid and high probability near edges.
  M_centroids <- centroids(M)
  d_rast <- terra::distance(r_mask, M_centroids)
  d_rast <- terra::mask(d_rast, r_mask)

  if (pa_method == "centroid") {
    # linear distance weighting; small floor to avoid zero-probability cells
    w_rast <- ifel(d_rast < 0.1, 0.1, d_rast)
  } else {
    # exponential increase with distance from centroid: normalize to [0,1] then exp(scale * x)
    d_min <- as.numeric(global(d_rast, "min", na.rm = TRUE))
    d_max <- as.numeric(global(d_rast, "max", na.rm = TRUE))
    d_norm <- if (d_max > d_min) (d_rast - d_min) / (d_max - d_min) else d_rast
    w_rast <- exp(pa_exp_scale * d_norm)
  }

  pa_vect <- tryCatch(
    terra::spatSample(w_rast, size = n_pa, method = "weights", as.points = TRUE,
                      values = FALSE, na.rm = TRUE, exhaustive = FALSE),
    error = function(e) NULL
  )
} else if (pa_method == "dataset") {
  cat(sprintf("Using %d pseudo-absences already sampled in the dataset, filtered to M\n", n_pa))
  if (!"presence" %in% names(occ)) {
    stop("occurrence CSV must have a presence/occ column for pa_method='dataset'", call. = FALSE)
  }
  abs_all <- occ[as.integer(occ$presence) == 0L, c("lon", "lat", "presence"), drop = FALSE]
  abs_all <- abs_all[!is.na(abs_all$lon) & !is.na(abs_all$lat), , drop = FALSE]
  if (nrow(abs_all) == 0) {
    stop("No absence rows (presence=0) found in occurrence CSV", call. = FALSE)
  }
  abs_vect <- vect(abs_all, geom = c("lon", "lat"), crs = "EPSG:4326")
  # Keep only absences whose cell center falls inside M (not just touches boundary)
  inside <- !is.na(terra::extract(M, abs_vect)[[1]])
  abs_all <- abs_all[inside, , drop = FALSE]
  if (nrow(abs_all) == 0) {
    stop("No dataset absences fall inside the accessibility polygon M", call. = FALSE)
  }
  set.seed(seed + n_pres)
  if (nrow(abs_all) > n_pa) {
    sel <- sample.int(nrow(abs_all), n_pa)
    abs_all <- abs_all[sel, , drop = FALSE]
  }
  pa <- abs_all
  pa$presence <- 0L
  # placeholder so code below can build pts
  pa_vect <- vect(pa, geom = c("lon", "lat"), crs = "EPSG:4326")
}

if (pa_method != "dataset") {
  if (is.null(pa_vect) || nrow(pa_vect) == 0) {
    stop("Could not sample any pseudo-absences inside M on land.", call. = FALSE)
  }
  pa <- as.data.frame(crds(pa_vect))
  names(pa) <- c("lon", "lat")
  pa$presence <- 0L
  if (nrow(pa) < n_pa) {
    cat(sprintf("WARNING: only %d/%d pseudo-absences sampled on land (raster cell limitation)\n", nrow(pa), n_pa))
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. Combine presences + pseudo-absences and extract environment
# ─────────────────────────────────────────────────────────────────────────────
occ_v7 <- rbind(
  pres[, c("lon", "lat", "presence"), drop = FALSE],
  pa[, c("lon", "lat", "presence"), drop = FALSE]
)
occ_v7$presence <- as.integer(occ_v7$presence)

pts <- vect(occ_v7, geom = c("lon", "lat"), crs = "EPSG:4326")

env_list <- list()
var_labels <- character()

for (bio_code in names(bio_vars)) {
  var_label <- bio_vars[[bio_code]]
  var_labels <- c(var_labels, var_label)
  cat(sprintf("Extracting %s (%s)... ", bio_code, var_label))

  paths <- file.path(bioclim_dir, as.character(years),
                     paste0(bio_code, "_", years, ".tif"))
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0) {
    cat(sprintf("MISSING %d rasters (e.g. %s)\n", length(missing), missing[1]))
    next
  }

  r <- rast(paths)
  vals <- extract(r, pts)
  # first column is ID; drop it, keep layer value columns
  vals <- vals[, -1, drop = FALSE]
  mat <- as.matrix(vals)
  if (ncol(mat) != length(years)) {
    cat(sprintf("unexpected extract dimensions: %d cols vs %d years\n", ncol(mat), length(years)))
    next
  }
  colnames(mat) <- as.character(years)

  out_df <- data.frame(
    lon      = occ_v7$lon,
    lat      = occ_v7$lat,
    presence = occ_v7$presence,
    mat,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  env_list[[var_label]] <- out_df
  cat(sprintf("%d pts x %d years -> %s\n", nrow(out_df), length(years),
              basename(var_label)))
}

# Remove any occurrence with NAs in any variable/time step
if (length(env_list) > 0) {
  value_cols <- lapply(env_list, function(df) df[, setdiff(names(df), c("lon", "lat", "presence")), drop = FALSE])
  combined <- do.call(cbind, value_cols)
  keep <- complete.cases(combined)
  cat(sprintf("Dropping %d/%d occurrences with NA values\n", sum(!keep), nrow(occ_v7)))
  occ_v7 <- occ_v7[keep, , drop = FALSE]
  for (var_label in names(env_list)) {
    out_df <- env_list[[var_label]][keep, , drop = FALSE]
    out_file <- file.path(sp_dir, paste0(var_label, ".csv"))
    write.csv(out_df, out_file, row.names = FALSE)
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# 7. Save M, M_buffer and occurrence file
# ─────────────────────────────────────────────────────────────────────────────
writeVector(M,       file.path(gis_dir, "M.shp"),       overwrite = TRUE)
writeVector(M_buffer, file.path(gis_dir, "M_buffer.shp"), overwrite = TRUE)
write.csv(occ_v7, file.path(sp_dir, "occ_v7.csv"), row.names = FALSE)

meta <- data.frame(
  species            = species_name,
  n_presences        = n_pres,
  n_pseudoabsences   = nrow(pa),
  pa_factor          = pa_factor,
  pa_method          = pa_method,
  buffer_m           = buffer_m,
  median_nnd_m       = median(nnd, na.rm = TRUE),
  selected_ecoregions = paste(selected_names, collapse = "; "),
  n_ecoregions_total  = length(tab),
  stringsAsFactors   = FALSE
)
write.csv(meta, file.path(sp_dir, "prepare_meta.csv"), row.names = FALSE)

cat(sprintf("\nPrepared v8 inputs for %s in %s\n", species_name, sp_dir))
cat(sprintf("  presences: %d | pseudo-absences: %d | method: %s\n", n_pres, nrow(pa), pa_method))
cat(sprintf("  env/spp dir: %s\n", sp_dir))
cat(sprintf("  M shapefiles: %s\n", gis_dir))

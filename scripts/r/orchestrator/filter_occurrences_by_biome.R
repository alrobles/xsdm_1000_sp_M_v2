#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(terra)
})

script_file <- commandArgs(trailingOnly = FALSE)
script_file <- script_file[grepl("^--file=", script_file)]
script_file <- sub("^--file=", "", script_file)
script_dir <- dirname(normalizePath(script_file))
source(file.path(script_dir, "occ_prefilter.R"))

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

occ_csv <- parse_arg("--occ_csv")
ecoregions <- parse_arg("--ecoregions")
biome_regex <- parse_arg("--biome_regex", "Grassland|Savanna")
eco_name <- parse_arg("--eco_name")
buffer_km <- as.numeric(parse_arg("--buffer_km", "10"))
restrict_background_buffer <- tolower(parse_arg("--restrict_background_buffer", "true")) %in% c("true", "1", "yes", "t")
background_outside_ecoregion <- tolower(parse_arg("--background_outside_ecoregion", "false")) %in% c("true", "1", "yes", "t")
background_eco_name <- parse_arg("--background_eco_name")
background_multiple_arg <- parse_arg("--background_multiple", "")
background_multiple <- if (is.null(background_multiple_arg) || !nzchar(background_multiple_arg)) NA_real_ else as.numeric(background_multiple_arg)
output_csv <- parse_arg("--output_csv")
env_csv_dir <- parse_arg("--env_csv_dir")
output_env_dir <- parse_arg("--output_env_dir")

if (is.null(occ_csv)) stop("--occ_csv required", call. = FALSE)
if (is.null(ecoregions)) stop("--ecoregions required", call. = FALSE)
if (is.null(output_csv)) stop("--output_csv required", call. = FALSE)

occ <- read.csv(occ_csv, stringsAsFactors = FALSE, check.names = FALSE)
req <- c("lon", "lat", "occ")
if (!all(req %in% names(occ))) {
  stop("Occurrence CSV must contain columns: lon, lat, occ", call. = FALSE)
}

pres_idx <- which(occ$occ == 1)
eco <- vect(ecoregions)
pres_pts <- vect(occ[pres_idx, , drop = FALSE], geom = c("lon", "lat"), crs = "EPSG:4326")
if (!same.crs(eco, pres_pts)) pres_pts <- project(pres_pts, crs(eco))

if (!is.null(eco_name) && nzchar(eco_name)) {
  eco_vals <- extract(eco[, "ECO_NAME"], pres_pts)[["ECO_NAME"]]
  keep_pres <- eco_vals == eco_name
} else {
  biome_vals <- extract(eco[, "BIOME_NAME"], pres_pts)[["BIOME_NAME"]]
  keep_pres <- grepl(biome_regex, biome_vals, ignore.case = TRUE)
}

keep <- rep(FALSE, nrow(occ))
bg_keep <- rep(FALSE, nrow(occ))
bg_mode <- "all_non_cerrado"
bg_target_report <- "all"

if (sum(occ$occ == 0, na.rm = TRUE) > 0) {
  bg_idx <- which(occ$occ == 0)

  if (!is.null(eco_name) && nzchar(eco_name) && background_outside_ecoregion) {
    bg_mode <- "outside_ecoregion"
    eco_target <- eco[eco$ECO_NAME == eco_name, , drop = FALSE]
    if (nrow(eco_target) == 0) {
      stop("No ecoregion features matched ECO_NAME = ", eco_name, call. = FALSE)
    }
    bg_pts <- vect(occ[bg_idx, , drop = FALSE], geom = c("lon", "lat"), crs = "EPSG:4326")
    if (!same.crs(eco_target, bg_pts)) bg_pts <- project(bg_pts, crs(eco_target))
    eligible_bg <- is.na(extract(eco_target[, "ECO_NAME"], bg_pts)[["ECO_NAME"]])

    if (!is.null(background_eco_name) && nzchar(background_eco_name)) {
      bg_eco_vals <- extract(eco[, "ECO_NAME"], bg_pts)[["ECO_NAME"]]
      eligible_bg <- eligible_bg & bg_eco_vals == background_eco_name
      bg_mode <- paste0(bg_mode, "+eco_name:", background_eco_name)
    }

    eligible_idx <- bg_idx[eligible_bg]
    eligible_count <- length(eligible_idx)
    target_bg <- if (is.na(background_multiple)) eligible_count else as.integer(round(sum(keep_pres, na.rm = TRUE) * background_multiple))
    bg_target_report <- if (is.na(background_multiple)) "all" else as.character(target_bg)

    if (is.na(target_bg) || target_bg <= 0L) {
      bg_keep[eligible_idx] <- TRUE
    } else if (eligible_count > target_bg) {
      set.seed(1)
      bg_keep[sample(eligible_idx, target_bg)] <- TRUE
    } else {
      bg_keep[eligible_idx] <- TRUE
      if (eligible_count < target_bg) {
        warning(sprintf("Requested %d background points but only %d eligible points are available; keeping all eligible points.", target_bg, eligible_count), call. = FALSE)
      }
    }

  } else if (!is.null(eco_name) && nzchar(eco_name) && restrict_background_buffer) {
    bg_mode <- "buffer"
    eco_target <- eco[eco$ECO_NAME == eco_name, , drop = FALSE]
    if (nrow(eco_target) == 0) {
      stop("No ecoregion features matched ECO_NAME = ", eco_name, call. = FALSE)
    }
    eco_ll <- as.data.frame(crds(centroids(eco_target), df = TRUE))
    lon0 <- mean(eco_ll[, 1], na.rm = TRUE)
    lat0 <- mean(eco_ll[, 2], na.rm = TRUE)
    utm_zone <- floor((lon0 + 180) / 6) + 1
    utm_epsg <- if (lat0 < 0) 32700 + utm_zone else 32600 + utm_zone
    eco_metric <- project(eco_target, paste0("EPSG:", utm_epsg))
    eco_buffer <- buffer(eco_metric, width = buffer_km * 1000)
    bg_pts <- vect(occ[bg_idx, , drop = FALSE], geom = c("lon", "lat"), crs = "EPSG:4326")
    if (!same.crs(eco_buffer, bg_pts)) bg_pts <- project(bg_pts, crs(eco_buffer))
    eligible_bg <- !is.na(extract(eco_buffer[, "ECO_NAME"], bg_pts)[["ECO_NAME"]])

    if (!is.null(background_eco_name) && nzchar(background_eco_name)) {
      bg_eco_vals <- extract(eco[, "ECO_NAME"], bg_pts)[["ECO_NAME"]]
      eligible_bg <- eligible_bg & bg_eco_vals == background_eco_name
      bg_mode <- paste0(bg_mode, "+eco_name:", background_eco_name)
    }

    eligible_idx <- bg_idx[eligible_bg]
    eligible_count <- length(eligible_idx)
    target_bg <- if (is.na(background_multiple)) eligible_count else as.integer(round(sum(keep_pres, na.rm = TRUE) * background_multiple))
    bg_target_report <- if (is.na(background_multiple)) "all" else as.character(target_bg)

    if (is.na(target_bg) || target_bg <= 0L) {
      bg_keep[eligible_idx] <- TRUE
    } else if (eligible_count > target_bg) {
      set.seed(1)
      bg_keep[sample(eligible_idx, target_bg)] <- TRUE
    } else {
      bg_keep[eligible_idx] <- TRUE
      if (eligible_count < target_bg) {
        warning(sprintf("Requested %d background points but only %d eligible points are available; keeping all eligible points.", target_bg, eligible_count), call. = FALSE)
      }
    }

  } else {
    bg_keep[bg_idx] <- TRUE
  }

  keep[bg_keep] <- TRUE
}

keep[pres_idx[keep_pres]] <- TRUE
filtered <- occ[keep, , drop = FALSE]
filtered$row_id <- which(keep)

dir.create(dirname(output_csv), recursive = TRUE, showWarnings = FALSE)
write.csv(filtered, output_csv, row.names = FALSE, quote = FALSE)

q_keep <- occ_prefilter_keep(filtered$lon, filtered$lat, filtered$occ, quantile = 0.95)
filtered_q <- filtered[q_keep, , drop = FALSE]

if (!is.null(eco_name) && nzchar(eco_name)) {
  cat(sprintf("RAW_ROWS=%d RAW_PRES=%d ECO_NAME=%s FILTER_PRES=%d FILTER_BG=%d BG_MODE=%s BG_TARGET=%s FILTER_ROWS=%d BUFFER_KM=%.1f Q095_ROWS=%d Q095_PRES=%d OUT=%s\n",
              nrow(occ),
              sum(occ$occ == 1, na.rm = TRUE),
              eco_name,
              sum(keep_pres, na.rm = TRUE),
              sum(bg_keep, na.rm = TRUE),
              bg_mode,
              bg_target_report,
              nrow(filtered),
              buffer_km,
              nrow(filtered_q),
              sum(filtered_q$occ == 1, na.rm = TRUE),
              output_csv))
} else {
  cat(sprintf("RAW_ROWS=%d RAW_PRES=%d SAVANNA_PRES=%d SAVANNA_ROWS=%d Q095_ROWS=%d Q095_PRES=%d OUT=%s\n",
              nrow(occ),
              sum(occ$occ == 1, na.rm = TRUE),
              sum(keep_pres, na.rm = TRUE),
              nrow(filtered),
              nrow(filtered_q),
              sum(filtered_q$occ == 1, na.rm = TRUE),
              output_csv))
}

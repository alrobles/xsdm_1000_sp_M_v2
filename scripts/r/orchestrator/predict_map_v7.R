#!/usr/bin/env Rscript

user_lib <- Sys.getenv(
  "R_LIBS_USER",
  file.path(Sys.getenv("HOME"), "R/x86_64-pc-linux-gnu-library/4.4")
)
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(terra)
})

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

`%||%` <- function(a, b) if (is.null(a)) b else a

script_file <- commandArgs(trailingOnly = FALSE)
script_file <- script_file[grepl("^--file=", script_file)]
script_file <- sub("^--file=", "", script_file)
script_dir <- dirname(normalizePath(script_file))
source(file.path(script_dir, "compute_tss_v7.R"), local = FALSE)

species_dir   <- parse_arg("--species_dir")
model_rds     <- parse_arg("--model_rds")
occ_csv       <- parse_arg("--occ_csv")
bioclim_dir   <- parse_arg("--bioclim_dir")
output_png    <- parse_arg("--output_png")
shapefile_out <- parse_arg("--shapefile_out")
m_shapefile   <- parse_arg("--m_shapefile", "")
years_str     <- parse_arg("--years", paste(1980:2020, collapse = ","))
num_threads   <- as.integer(parse_arg("--num_threads", "0"))
years         <- as.integer(strsplit(years_str, ",", fixed = TRUE)[[1]])

if (is.null(species_dir))   stop("--species_dir required", call. = FALSE)
if (is.null(model_rds))     stop("--model_rds required", call. = FALSE)
if (is.null(occ_csv))       stop("--occ_csv required", call. = FALSE)
if (is.null(bioclim_dir))   stop("--bioclim_dir required", call. = FALSE)
if (is.null(output_png))    stop("--output_png required", call. = FALSE)
if (is.null(shapefile_out)) stop("--shapefile_out required", call. = FALSE)

fit <- tryCatch(readRDS(model_rds), error = function(e) NULL)
if (is.null(fit) || is.null(fit$status) || fit$status != "success") {
  message("No successful M_omega model available; skipping habitat prediction.")
  quit(save = "no", status = 0)
}

if (is.null(fit$vars) || is.null(fit$best_par)) {
  message("Model RDS is missing vars or best_par; skipping habitat prediction.")
  quit(save = "no", status = 0)
}

occ_all <- read_occurrence_df(occ_csv)
occ_vect <- read_occurrence_vector(occ_csv, occ_all)
pres_vect <- read_presence_vector(occ_csv, occ_all)
abs_vect <- occ_vect[occ_vect$occ == 0, ]

if (nrow(pres_vect) == 0) {
  message("No presences available; skipping habitat prediction.")
  quit(save = "no", status = 0)
}

if (nzchar(m_shapefile) && file.exists(m_shapefile)) {
  polygon_vect <- terra::vect(m_shapefile)
  terra::crs(polygon_vect) <- "EPSG:4326"
} else {
  polygon_vect <- if (nchar(Sys.getenv("FIXED_BBOX",""))>0) {
    b <- as.numeric(strsplit(Sys.getenv("FIXED_BBOX"),",")[[1]]);
    make_bbox_polygon(data.frame(lon=b[1:2],lat=b[3:4]), buffer_km=0)
  } else {
    make_bbox_polygon(occ_vect, buffer_km = 10)
  }
}
dir.create(dirname(shapefile_out), recursive = TRUE, showWarnings = FALSE)
terra::writeVector(polygon_vect, shapefile_out, overwrite = TRUE)

env_list <- build_env_list(
  vars          = fit$vars,
  scale_factors = fit$scale_factors,
  bioclim_dir   = bioclim_dir,
  years         = years,
  polygon_vect  = polygon_vect
)

p <- length(fit$vars)
full_math <- reconstruct_full_math(fit$best_par, fit$mask, p)
param_list <- xsdm::math_to_bio(full_math)

hab <- xsdm::habitat_suitability(
  param_list  = param_list,
  env_list    = env_list,
  return_prob = TRUE,
  threads     = num_threads
)

occ_xy <- terra::crds(occ_vect, df = TRUE)[, c("x", "y"), drop = FALSE]
occ_preds <- extract_raster_values(hab, occ_xy)
occ_labels <- as.integer(as.data.frame(occ_vect)$occ == 1)
keep <- is.finite(occ_preds) & !is.na(occ_labels)
threshold_metrics <- compute_threshold_metrics(occ_preds[keep], occ_labels[keep])
thr <- threshold_metrics$threshold

hab_tif <- sub("\\.png$", ".tif", output_png)
terra::writeRaster(hab, hab_tif, overwrite = TRUE)

hab_bin <- terra::ifel(hab >= thr, 1, 0)
hab_bin_png <- file.path(dirname(output_png), "habitat_suitability_binary_v7.png")
hab_bin_tif <- file.path(dirname(output_png), "habitat_suitability_binary_v7.tif")
terra::writeRaster(hab_bin, hab_bin_tif, overwrite = TRUE)

crs(hab) <- crs(polygon_vect)
crs(pres_vect) <- crs(hab)
crs(abs_vect) <- crs(hab)
crs(polygon_vect) <- crs(hab)

dir.create(dirname(output_png), recursive = TRUE, showWarnings = FALSE)
grDevices::png(output_png, width = 900, height = 720, res = 110)
terra::plot(hab, main = "Habitat suitability (v7)")
terra::lines(polygon_vect, col = "black", lwd = 2)
terra::points(pres_vect, col = "red", pch = 16, cex = 0.65)
terra::points(abs_vect, col = "grey40", pch = 1, cex = 0.5)
grDevices::dev.off()

grDevices::png(hab_bin_png, width = 900, height = 720, res = 110)
terra::plot(hab_bin, col = c("grey80", "darkgreen"), main = sprintf("Binary range v7 (TSS threshold = %.3f)", thr))
terra::lines(polygon_vect, col = "black", lwd = 2)
terra::points(pres_vect, col = "red", pch = 16, cex = 0.65)
terra::points(abs_vect, col = "grey40", pch = 1, cex = 0.5)
grDevices::dev.off()

# Also compute and persist TSS for the report.
tss_out <- file.path(species_dir, "tss_results_v7.rds")
compute_tss(
  model_rds    = model_rds,
  occ_csv      = occ_csv,
  bioclim_dir  = bioclim_dir,
  years        = years,
  output_rds   = tss_out,
  num_threads  = num_threads,
  m_shapefile  = if (nzchar(m_shapefile)) m_shapefile else NULL
)

message("Habitat map written to: ", output_png)
message("Continuous raster written to: ", hab_tif)
message("Binary habitat map written to: ", hab_bin_png)
message("M / accessibility shapefile written to: ", shapefile_out)
message("TSS results written to: ", tss_out)

# Append TSS to the per-species report if present
report_path <- file.path(species_dir, "model_selection_report.md")
if (file.exists(report_path) && file.exists(tss_out)) {
  tss <- readRDS(tss_out)
  tss_lines <- c(
    "",
    "## Model fit — True Skill Statistic (TSS)",
    "",
    "- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.",
    paste0("- **TSS:** ", round(tss$TSS, 4)),
    paste0("- **Threshold:** ", round(tss$threshold, 4)),
    paste0("- **Sensitivity:** ", round(tss$sensitivity, 4)),
    paste0("- **Specificity:** ", round(tss$specificity, 4)),
    paste0("- **Presences / pseudo-absences:** ", tss$n_presence, " / ", tss$n_absence),
    paste0("- **Prevalence:** ", round(tss$prevalence, 4)),
    ""
  )
  writeLines(c(readLines(report_path, warn = FALSE), tss_lines), report_path)
  message("TSS appended to report: ", report_path)
}

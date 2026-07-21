#!/usr/bin/env Rscript
# make_coastline_from_ecoregions.R
#
# Build a single dissolved land polygon (coastline.shp) from the Ecoregions2017
# shapefile. This polygon is used to clip the v7 accessibility/calibration area M
# and its buffer so that they fit coastlines and islands instead of spilling into
# the ocean.
#
# Usage:
#   Rscript scripts/r/make_coastline_from_ecoregions.R \
#     --ecoregion_shp /path/to/Ecoregions2017.shp \
#     --output /path/to/coastline.shp

library(terra)

parse_arg <- function(name, default = NULL) {
  args <- commandArgs(trailingOnly = TRUE)
  idx <- which(args == name)
  if (length(idx) > 0 && idx < length(args)) {
    return(args[idx + 1])
  }
  if (!is.null(default)) return(default)
  stop("Missing argument ", name, call. = FALSE)
}

ecoregion_shp <- parse_arg("--ecoregion_shp")
output_shp    <- parse_arg("--output")

cat("Reading ecoregions:", ecoregion_shp, "\n")
eco <- vect(ecoregion_shp)
if (!is.lonlat(eco)) eco <- project(eco, "EPSG:4326")

cat("Dissolving", nrow(eco), "polygons into a single coastline polygon...\n")
eco$land <- 1L
# aggregate dissolves internal borders and keeps the outer coastline
land <- aggregate(eco, by = "land", dissolve = TRUE)

dir.create(dirname(output_shp), recursive = TRUE, showWarnings = FALSE)
writeVector(land, output_shp, overwrite = TRUE)
cat("Coastline written to:", output_shp, "\n")
cat("Extent:", as.character(ext(land)), "\n")

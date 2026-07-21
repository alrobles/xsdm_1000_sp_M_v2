#!/usr/bin/env Rscript
# Plot bio01 crop over ecoregion-based M_buffer for one species/year.
library(terra)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: plot_M_bio01.R <sp_dir> <year>", call. = FALSE)
}
sp_dir <- args[1]
year <- args[2]

bio_dir <- Sys.getenv("BIOCLIM_DIR", "/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim")
bio_tif <- file.path(bio_dir, year, paste0("bio01_", year, ".tif"))
M_shp <- file.path(sp_dir, "gis", "M_buffer.shp")
occ_csv <- file.path(sp_dir, "occ_v7.csv")
out_png <- file.path(sp_dir, "plots", paste0("bio01_M_crop_", year, ".png"))

if (!file.exists(bio_tif)) stop("Missing: ", bio_tif, call. = FALSE)
if (!file.exists(M_shp)) stop("Missing: ", M_shp, call. = FALSE)
if (!file.exists(occ_csv)) stop("Missing: ", occ_csv, call. = FALSE)

r <- rast(bio_tif)
M <- vect(M_shp)
crs(M) <- "EPSG:4326"

occ <- read.csv(occ_csv, stringsAsFactors = FALSE)
pres <- occ[as.integer(occ$presence) == 1, c("lon", "lat"), drop = FALSE]
pres <- pres[!is.na(pres$lon) & !is.na(pres$lat), , drop = FALSE]
pres_vect <- vect(pres, geom = c("lon", "lat"), crs = "EPSG:4326")

r_crop <- crop(r, M, mask = TRUE)

dir.create(dirname(out_png), recursive = TRUE, showWarnings = FALSE)
png(out_png, width = 900, height = 720, res = 110)
plot(r_crop, main = paste("bio01", year, "M_buffer crop -", basename(sp_dir)))
lines(M, col = "black", lwd = 2)
points(pres_vect, col = "red", pch = 16, cex = 0.65)
dev.off()
cat("PNG written to:", out_png, "\n")

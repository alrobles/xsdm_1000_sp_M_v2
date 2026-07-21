library(terra)
args <- commandArgs(trailingOnly = TRUE)
sp_dir <- args[1]
occ <- read.csv(file.path(sp_dir, "occ_v7.csv"), stringsAsFactors = FALSE, check.names = FALSE)
M <- vect(file.path(sp_dir, "gis/M.shp"))
Mbuf <- vect(file.path(sp_dir, "gis/M_buffer.shp"))
pres <- occ[occ$presence == 1, ]
pabs <- occ[occ$presence == 0, ]
out_png <- file.path(sp_dir, "plots/M_buffer_points_v7.png")
png(out_png, width = 1200, height = 900, res = 120)
plot(Mbuf, col = "lightblue", border = "blue", lwd = 1,
     main = paste(basename(sp_dir), "M (negro), buffer (azul), presencias (rojo), pseudo-ausencias (gris)"))
plot(M, col = NA, border = "black", lwd = 2, add = TRUE)
points(pres$lon, pres$lat, col = "red", pch = 20, cex = 0.6)
points(pabs$lon, pabs$lat, col = "gray50", pch = 20, cex = 0.3)
dev.off()
cat("Saved:", out_png, "\n")

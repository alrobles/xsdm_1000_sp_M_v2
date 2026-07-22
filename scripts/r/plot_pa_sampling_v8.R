#!/usr/bin/env Rscript
# Plot presence (red) and pseudo-absence (blue) points inside M for each v8 method.
# Usage:
#   Rscript scripts/r/plot_pa_sampling_v8.R --repo_root /path/to/xsdm_1000_sp_M_v2 --species "Acris blanchardi"

library(terra)

args <- commandArgs(trailingOnly = TRUE)

parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  if (idx + 1 > length(args)) stop("Missing value for ", flag)
  args[idx + 1]
}

repo_root <- parse_arg("--repo_root", ".")
species   <- parse_arg("--species", "Acris blanchardi")
sp_safe   <- gsub(" ", "_", species)

out_dir <- file.path(repo_root, "reports", "pa_sampling")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

methods <- c(
  random                = "Random uniform inside M",
  centroid_exp          = "Distance to centroid (exponential)",
  dataset               = "Dataset absences inside M",
  inverse_presence_density = "Inverse presence density"
)

method_dirs <- c(
  random                = file.path(repo_root, "outputs"),
  centroid_exp          = file.path(repo_root, "outputs_centroid"),
  dataset               = file.path(repo_root, "outputs_berti_sample"),
  inverse_presence_density = file.path(repo_root, "outputs_inverse_density")
)

for (m in names(methods)) {
  cat("Plotting", m, "\n")
  sp_dir <- file.path(method_dirs[m], sp_safe)
  occ_file <- file.path(sp_dir, "occ_v7.csv")
  m_file   <- file.path(sp_dir, "gis", "M.shp")

  if (!file.exists(occ_file)) {
    cat("  skipping: missing", occ_file, "\n")
    next
  }
  if (!file.exists(m_file)) {
    cat("  skipping: missing", m_file, "\n")
    next
  }

  occ <- read.csv(occ_file, stringsAsFactors = FALSE)
  occ$presence <- as.integer(occ$presence)

  M <- vect(m_file)
  if (crs(M) == "") crs(M) <- "EPSG:4326"
  M <- project(M, "EPSG:4326")

  pts <- vect(occ, geom = c("lon", "lat"), crs = "EPSG:4326")

  pres <- pts[pts$presence == 1, ]
  abs  <- pts[pts$presence == 0, ]

  n_pres <- nrow(pres)
  n_abs  <- nrow(abs)

  png_file <- file.path(out_dir, paste0(sp_safe, "_", m, "_pa_sampling.png"))
  png(png_file, width = 1200, height = 900, res = 120)

  par(mar = c(2, 2, 3, 0.5))
  plot(M, col = "lightyellow", border = "gray50", lwd = 0.5,
       main = paste0(methods[m], "\n(n_pres = ", n_pres, ", n_abs = ", n_abs, ")"),
       axes = FALSE)
  if (n_abs > 0)  points(abs,  col = "blue", cex = 0.35, pch = 16)
  if (n_pres > 0) points(pres, col = "red",  cex = 0.45, pch = 16)

  # small legend
  legend("topright", legend = c("presence", "pseudo-absence"),
         col = c("red", "blue"), pch = 16, cex = 0.9, bg = "white")

  dev.off()
  cat("  wrote", png_file, "\n")
}

cat("Done.\n")

#!/usr/bin/env Rscript
# Scatter plot of bio01 vs bio12 across all years for v7 training points.
library(terra)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: plot_env_scatter_v7.R <sp_dir> [year_range]", call. = FALSE)
}
sp_dir <- args[1]
years <- if (length(args) >= 2) as.integer(strsplit(args[2], ":", fixed = TRUE)[[1]]) else 1980:2020
if (length(years) == 2) years <- seq(years[1], years[2])

bio01_file <- file.path(sp_dir, "T1_bio01.csv")
bio12_file <- file.path(sp_dir, "P12_bio12.csv")
if (!file.exists(bio01_file)) stop("Missing ", bio01_file, call. = FALSE)
if (!file.exists(bio12_file)) stop("Missing ", bio12_file, call. = FALSE)

t1 <- read.csv(bio01_file, stringsAsFactors = FALSE, check.names = FALSE)
p1 <- read.csv(bio12_file, stringsAsFactors = FALSE, check.names = FALSE)

if (!all(c("lon", "lat", "presence") %in% names(t1))) {
  stop("bio01 CSV must contain lon, lat, presence columns", call. = FALSE)
}

year_cols <- as.character(years)
missing_years <- setdiff(year_cols, names(t1))
if (length(missing_years) > 0) stop("Missing years in bio01 CSV: ", paste(missing_years, collapse = ", "), call. = FALSE)
missing_years <- setdiff(year_cols, names(p1))
if (length(missing_years) > 0) stop("Missing years in bio12 CSV: ", paste(missing_years, collapse = ", "), call. = FALSE)

# Stack all year columns into long vectors
bio01_vals <- unlist(t1[, year_cols, drop = FALSE], use.names = FALSE)
bio12_vals <- unlist(p1[, year_cols, drop = FALSE], use.names = FALSE)
presence <- rep(as.integer(t1$presence), each = length(years))

# Convert precip units if needed (CSV stores P12 in original mm? v6 rescales internally)
# If your prepare script does not rescale, bio12 is mm. Plot as-is.
keep <- !is.na(bio01_vals) & !is.na(bio12_vals)
bio01_vals <- bio01_vals[keep]
bio12_vals <- bio12_vals[keep]
presence <- presence[keep]

out_png <- file.path(sp_dir, "plots", "bio01_vs_bio12_all_years.png")
dir.create(dirname(out_png), recursive = TRUE, showWarnings = FALSE)

pres_idx <- presence == 1
abs_idx <- presence == 0

set.seed(42)
# subsample if huge
n_pres <- sum(pres_idx)
n_abs <- sum(abs_idx)
if (n_pres > 5000) pres_samp <- sample(which(pres_idx), 5000) else pres_samp <- which(pres_idx)
if (n_abs > 5000) abs_samp <- sample(which(abs_idx), 5000) else abs_samp <- which(abs_idx)

png(out_png, width = 900, height = 720, res = 110)
plot(bio01_vals[abs_samp], bio12_vals[abs_samp],
     col = adjustcolor("steelblue", alpha.f = 0.3), pch = 16, cex = 0.6,
     xlab = "bio01 (annual mean temperature, K)",
     ylab = "bio12 (annual precipitation, mm)",
     main = paste("bio01 vs bio12", min(years), "-", max(years), "\n", basename(sp_dir)),
     panel.first = grid())
points(bio01_vals[pres_samp], bio12_vals[pres_samp],
       col = adjustcolor("red", alpha.f = 0.5), pch = 16, cex = 0.7)
legend("topright", legend = c(paste0("presence (n=", n_pres, ")"), paste0("pseudo-absence (n=", n_abs, ")")),
       col = c("red", "steelblue"), pch = 16, bty = "n")
dev.off()
cat("PNG written to:", out_png, "\n")

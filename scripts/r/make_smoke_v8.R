#!/usr/bin/env Rscript
# Create a 10% (or specified fraction) smoke-test copy of a prepared v8 species
# by sampling rows from all env CSVs and occ_v7.csv in the same random order.
# Usage:
#   Rscript scripts/r/make_smoke_v8.R --src_dir outputs/Acris_blanchardi \
#                                     --dst_dir outputs_smoke/Acris_blanchardi \
#                                     --frac 0.1 --seed 42

# Base R only

args <- commandArgs(trailingOnly = TRUE)

parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  if (idx + 1 > length(args)) stop("Missing value for ", flag)
  args[idx + 1]
}

src_dir <- parse_arg("--src_dir")
dst_dir <- parse_arg("--dst_dir")
frac    <- as.numeric(parse_arg("--frac", "0.1"))
seed    <- as.integer(parse_arg("--seed", "42"))

if (is.null(src_dir) || !dir.exists(src_dir)) stop("--src_dir must exist")
if (is.null(dst_dir)) stop("--dst_dir required")
if (frac <= 0 || frac > 1) stop("--frac must be in (0,1]")

dir.create(dst_dir, recursive = TRUE, showWarnings = FALSE)
gis_src <- file.path(src_dir, "gis")
gis_dst <- file.path(dst_dir, "gis")
if (dir.exists(gis_src)) {
  dir.create(gis_dst, recursive = TRUE, showWarnings = FALSE)
  for (f in list.files(gis_src, full.names = TRUE)) {
    file.copy(f, gis_dst, overwrite = TRUE)
  }
}

occ_src <- file.path(src_dir, "occ_v7.csv")
occ_dst <- file.path(dst_dir, "occ_v7.csv")
if (!file.exists(occ_src)) stop("missing occ_v7.csv in src_dir")

occ <- read.csv(occ_src, stringsAsFactors = FALSE, check.names = FALSE)
n <- nrow(occ)
n_smoke <- max(1L, as.integer(round(n * frac)))
set.seed(seed)
idx <- sort(sample.int(n, n_smoke))

occ_smoke <- occ[idx, , drop = FALSE]
write.csv(occ_smoke, occ_dst, row.names = FALSE)

csv_files <- list.files(src_dir, pattern = "\\.csv$", full.names = TRUE)
csv_files <- setdiff(csv_files, c(occ_src, file.path(src_dir, "prepare_meta.csv")))

for (csv_src in csv_files) {
  csv_dst <- file.path(dst_dir, basename(csv_src))
  df <- read.csv(csv_src, stringsAsFactors = FALSE, check.names = FALSE)
  if (nrow(df) != n) {
    warning(sprintf("%s has %d rows, expected %d; skipping", basename(csv_src), nrow(df), n))
    next
  }
  write.csv(df[idx, , drop = FALSE], csv_dst, row.names = FALSE)
}

meta_src <- file.path(src_dir, "prepare_meta.csv")
if (file.exists(meta_src)) {
  meta <- read.csv(meta_src, stringsAsFactors = FALSE, check.names = FALSE)
  meta$n_presences <- sum(occ_smoke$presence == 1)
  meta$n_pseudoabsences <- sum(occ_smoke$presence == 0)
  write.csv(meta, file.path(dst_dir, "prepare_meta.csv"), row.names = FALSE)
}

cat(sprintf("Smoke copy created: %d -> %d rows (%.0f%%)\n", n, n_smoke, frac * 100))

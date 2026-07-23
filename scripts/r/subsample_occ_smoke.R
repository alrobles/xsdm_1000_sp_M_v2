#!/usr/bin/env Rscript
# subsample_occ_smoke.R — Subsample a prepared v8 species directory to a smoke-test fraction.
# Usage:
#   Rscript scripts/r/subsample_occ_smoke.R --source_dir outputs_full/Species --target_dir outputs_smoke/Species --pct 0.10

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

source_dir <- parse_arg("--source_dir")
target_dir <- parse_arg("--target_dir")
pct        <- as.numeric(parse_arg("--pct", "0.10"))
seed       <- as.integer(parse_arg("--seed", "42"))

if (is.null(source_dir)) stop("--source_dir required", call. = FALSE)
if (is.null(target_dir)) stop("--target_dir required", call. = FALSE)
if (!is.finite(pct) || pct <= 0 || pct > 1) stop("--pct must be in (0,1]", call. = FALSE)

if (!file.exists(file.path(source_dir, "occ_v7.csv"))) {
  stop("source_dir does not contain occ_v7.csv: ", source_dir, call. = FALSE)
}

set.seed(seed)

in_place <- normalizePath(source_dir, mustWork = FALSE) == normalizePath(target_dir, mustWork = FALSE)

dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
gis_source <- file.path(source_dir, "gis")
gis_target <- file.path(target_dir, "gis")
if (dir.exists(gis_source) && !in_place) {
  dir.create(gis_target, recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(gis_source, full.names = TRUE), gis_target, overwrite = TRUE)
}

occ <- read.csv(file.path(source_dir, "occ_v7.csv"), stringsAsFactors = FALSE)
pres_idx <- which(as.integer(occ$presence) == 1L)
abs_idx  <- which(as.integer(occ$presence) == 0L)

n_pres_target <- max(1L, round(pct * length(pres_idx)))
n_abs_target  <- max(1L, round(pct * length(abs_idx)))

if (n_pres_target > length(pres_idx)) n_pres_target <- length(pres_idx)
if (n_abs_target  > length(abs_idx))  n_abs_target  <- length(abs_idx)

pres_sel <- sample(pres_idx, n_pres_target)
abs_sel  <- sample(abs_idx, n_abs_target)
occ_smoke <- occ[sort(c(pres_sel, abs_sel)), , drop = FALSE]
write.csv(occ_smoke, file.path(target_dir, "occ_v7.csv"), row.names = FALSE)
cat(sprintf("Subsampled occurrences: %d presences + %d pseudo-absences (%.1f%%) -> %s\n",
            n_pres_target, n_abs_target, pct * 100, target_dir))

# Subsample the per-variable env CSVs to the same rows
env_files <- list.files(source_dir, pattern = "^T[0-9]+_bio[0-9]+\\.csv$|^P[0-9]+_bio[0-9]+\\.csv$|^noT_", full.names = FALSE)
if (length(env_files) == 0) {
  env_files <- list.files(source_dir, pattern = "\\.csv$", full.names = FALSE)
  env_files <- setdiff(env_files, c("occ_v7.csv", "prepare_meta.csv"))
}
for (f in env_files) {
  src <- file.path(source_dir, f)
  if (!file.exists(src)) next
  df <- read.csv(src, stringsAsFactors = FALSE, check.names = FALSE)
  df_smoke <- df[sort(c(pres_sel, abs_sel)), , drop = FALSE]
  write.csv(df_smoke, file.path(target_dir, f), row.names = FALSE)
}

# Copy meta file if present (skip when subsampling in place)
meta_src <- file.path(source_dir, "prepare_meta.csv")
if (file.exists(meta_src) && !in_place) file.copy(meta_src, file.path(target_dir, "prepare_meta.csv"), overwrite = TRUE)

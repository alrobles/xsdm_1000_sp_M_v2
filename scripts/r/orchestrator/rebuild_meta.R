#!/usr/bin/env Rscript
# rebuild_meta.R — Reconstruct selection_meta.tsv from on-disk model fits.
#
# Useful when the orchestrator finished without selecting M_Ω (e.g. no model
# passed the well-behaved criteria) and therefore never wrote the metadata that
# generate_report.R consumes. This regenerates the metadata purely from the
# saved <species_dir>/models/*.rds artefacts, so a report (including the L3
# per-model appendices) can be produced without re-running any fitting.
#
#   --species_dir "/path/to/outputs/<species>"
#   [--m_omega "<model>"]   (optional; default NONE = no well-behaved model)
#   [--omega "<pBIC>"]      (optional; default NA)

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

`%||%` <- function(a, b) if (is.null(a)) b else a

species_dir <- parse_arg("--species_dir")
if (is.null(species_dir)) stop("--species_dir required", call. = FALSE)
m_omega <- parse_arg("--m_omega", "NONE")
omega   <- parse_arg("--omega", "NA")

models_dir <- file.path(species_dir, "models")
files <- list.files(models_dir, pattern = "\\.rds$", full.names = TRUE)
if (length(files) == 0) stop("no model RDS files under ", models_dir, call. = FALSE)

ms <- lapply(files, readRDS)
names(ms) <- vapply(ms, function(x) x$model_name %||% NA_character_, character(1))

succ <- Filter(function(x) !is.null(x$status) && x$status == "success", ms)
if (length(succ) == 0) stop("no successful model fits found", call. = FALSE)

n_vals <- vapply(succ, function(x) if (is.null(x$n)) NA_real_ else as.numeric(x$n), numeric(1))
n_data <- n_vals[which(!is.na(n_vals))[1]]

is_l1 <- function(x) is.null(x$mask)
l1 <- Filter(is_l1, succ)
l1_pbic <- vapply(l1, function(x) as.numeric(x$pBIC), numeric(1))
best_pbic <- min(l1_pbic)
tau <- 4 * log(n_data)                 # (max_p + 1) * log(n), max_p = 3
threshold <- best_pbic + tau
l2 <- names(Filter(function(x) !is.null(x$mask), succ))

species <- succ[[1]]$species %||% basename(species_dir)

con <- file(file.path(species_dir, "selection_meta.tsv"), "w")
on.exit(close(con))
w <- function(...) cat(paste0(..., "\n"), file = con)
w("SPECIES\t", species)
w("N_DATA\t", n_data)
w("MAX_P\t3")
w("TAU\t", tau)
w("BEST_PBIC_L1\t", best_pbic)
w("THRESHOLD_L2\t", threshold)
w("OMEGA\t", omega)
w("M_OMEGA\t", m_omega)
w("OMEGA_TAU\tNA")
w("N_L1_SUCCESS\t", length(l1))
w("N_L2\t", length(l2))
w("N_L4\t0")
for (k in names(l1)) w("L1\t", k, "\t", as.numeric(l1[[k]]$pBIC))
for (k in l2) w("L2_MODEL\t", k)

cat(sprintf("META_OK species=%s n_data=%s nL1=%d nL2=%d best_pBIC=%.4f tau=%.4f\n",
            species, n_data, length(l1), length(l2), best_pbic, tau))

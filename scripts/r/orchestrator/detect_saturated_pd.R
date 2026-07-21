#!/usr/bin/env Rscript
# detect_saturated_pd.R — identifies L1 models whose MLE has `pd` saturated
# at the upper bio-boundary (pd -> 1), regardless of pBIC eligibility.
# The orchestrator can then expand these to the __bd_pd1 boundary model.
#
#   --sp_dir "/path/to/outputs_M/<species>"
#
# Prints one L1 model_name per line for which pd is saturated.

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

sp_dir <- parse_arg("--sp_dir")
if (is.null(sp_dir)) stop("--sp_dir required", call. = FALSE)

models_dir <- file.path(sp_dir, "models")
if (!dir.exists(models_dir)) {
  cat("")
  quit(save = "no", status = 0)
}

files <- list.files(models_dir, pattern = "\\.rds$", full.names = TRUE)
PD_BIO_TOL <- 1e-6

for (f in files) {
  x <- tryCatch(readRDS(f), error = function(e) NULL)
  if (is.null(x) || is.null(x$status) || x$status != "success") next
  if (is.null(x$best_par) || is.null(x$model_name)) next
  if (grepl("__bd_pd1$", x$model_name)) next  # already a pd-boundary model

  bio <- tryCatch(xsdm::math_to_bio(x$best_par), error = function(e) NULL)
  if (is.null(bio) || is.null(bio$pd)) next

  if (bio$pd >= 1 - PD_BIO_TOL) {
    cat(x$model_name, "\n", sep = "")
  }
}

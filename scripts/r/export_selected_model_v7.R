#!/usr/bin/env Rscript
# export_selected_model_v7.R — Read model_results_v6.rds produced by
# xsdm_model_selection_v6.R and write a model RDS compatible with
# predict_map.R / compute_tss.R.

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

results_rds <- parse_arg("--results_rds")
out_rds     <- parse_arg("--out_rds")

if (is.null(results_rds)) stop("--results_rds required", call. = FALSE)
if (is.null(out_rds))     stop("--out_rds required", call. = FALSE)

res <- readRDS(results_rds)
if (is.null(res$status) || res$status != "success") {
  stop("results RDS does not contain a successful model", call. = FALSE)
}

model_out <- list(
  model_name    = res$selected,
  species       = res$species,
  status        = "success",
  vars          = res$model_vars,
  best_par      = res$best_math,
  mask          = NULL,
  scale_factors = res$scale_factors,
  n             = res$n_data,
  p             = length(res$model_vars),
  n_free        = res$n_vars,  # approximate; not used by predict_map
  loglik        = res$best_loglik,
  pBIC          = res$pBIC
)

dir.create(dirname(out_rds), recursive = TRUE, showWarnings = FALSE)
saveRDS(model_out, out_rds)
cat("Exported selected model to:", out_rds, "\n")

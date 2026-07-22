#!/usr/bin/env Rscript
# combine_stageB.R — Combine per-task Stage B bootstrap CSVs into a single
# parameter trace and CI file for a method.

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

method_dir <- parse_arg("--method_dir")
combined_dir <- parse_arg("--combined_dir", file.path(method_dir, "bootstrap_stageB_25pct"))
if (is.null(method_dir)) stop("--method_dir required", call. = FALSE)

sp_dir <- file.path(method_dir, "Acris_blanchardi")
models_dir <- file.path(sp_dir, "models")
report_md  <- file.path(sp_dir, "model_selection_report.md")

# Load original final model (same logic as bootstrap_vsp_stageB.R)
model_name <- NULL
if (file.exists(report_md)) {
  lines <- readLines(report_md, warn = FALSE)
  final_line <- grep("^- \\*\\*Final model:\\*\\*", lines, value = TRUE)
  if (length(final_line) > 0) {
    m <- regexpr("`([^`]+)`", final_line[1], perl = TRUE)
    if (m[1] != -1) {
      model_name <- substring(final_line[1], attr(m, "capture.start"),
                             attr(m, "capture.start") + attr(m, "capture.length") - 1)
    }
  }
}

if (!is.null(model_name)) {
  fit <- tryCatch(readRDS(file.path(models_dir, paste0(model_name, ".rds"))),
                  error = function(e) NULL)
}
if (is.null(model_name) || is.null(fit) || is.null(fit$best_par)) {
  # fallback: best pBIC
  model_files <- list.files(models_dir, pattern = "\\.rds$", full.names = TRUE)
  fit <- NULL
  for (f in model_files) {
    tmp <- tryCatch(readRDS(f), error = function(e) NULL)
    if (!is.null(tmp) && !is.null(tmp$status) && tmp$status == "success" &&
        !is.null(tmp$pBIC) && is.finite(tmp$pBIC)) {
      if (is.null(fit) || isTRUE(tmp$pBIC < fit$pBIC)) fit <- tmp
    }
  }
}
if (is.null(fit) || is.null(fit$best_par)) stop("No successful model found in ", models_dir, call. = FALSE)
param_names <- names(fit$best_par)

dir.create(combined_dir, recursive = TRUE, showWarnings = FALSE)

task_dirs <- list.dirs(file.path(method_dir, "bootstrap_stageB_25pct"), recursive = FALSE)
param_files <- file.path(task_dirs, "boostra_params_vsp_stageB.csv")
param_files <- param_files[file.exists(param_files)]
if (length(param_files) == 0) stop("No task CSVs found in ", file.path(method_dir, "bootstrap_stageB_25pct"), call. = FALSE)

param_df <- do.call(rbind, lapply(param_files, read.csv, stringsAsFactors = FALSE))
param_df <- param_df[order(param_df$iteration), , drop = FALSE]

param_mat <- as.matrix(param_df[, param_names, drop = FALSE])
rownames(param_mat) <- NULL

ci_df <- data.frame(
  parameter = param_names,
  original = as.vector(fit$best_par),
  ci_lower = apply(param_mat, 2, function(x) quantile(x, probs = 0.025, na.rm = TRUE)),
  ci_upper = apply(param_mat, 2, function(x) quantile(x, probs = 0.975, na.rm = TRUE)),
  ci_median = apply(param_mat, 2, median, na.rm = TRUE),
  stringsAsFactors = FALSE
)
ci_df$inside_95 <- (ci_df$original >= ci_df$ci_lower) & (ci_df$original <= ci_df$ci_upper)
ci_df$n_success <- sum(param_df$status == "success", na.rm = TRUE)

params_file <- file.path(combined_dir, "boostra_params_vsp_stageB.csv")
ci_file <- file.path(combined_dir, "boostra_CI_vsp_stageB.csv")
write.csv(param_df, params_file, row.names = FALSE)
write.csv(ci_df, ci_file, row.names = FALSE)

message("Combined ", nrow(param_df), " iterations into ", combined_dir)
message("  Success: ", ci_df$n_success[1], "/", nrow(param_df))
print(ci_df)

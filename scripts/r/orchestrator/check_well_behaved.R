#!/usr/bin/env Rscript
# check_well_behaved.R — Checks if a fitted model is well-behaved (Flag A + B)
# Called by orchestrator after each model fit.
#   --model_rds "/path/to/model.rds"
#   --output_file "/path/to/wb_result.rds"

user_lib <- Sys.getenv("R_LIBS_USER",
                       file.path(Sys.getenv("HOME"),
                                 "R/x86_64-pc-linux-gnu-library/4.4"))
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(numDeriv)
})

local({
  this_dir <- tryCatch({
    f <- commandArgs(trailingOnly = FALSE)
    f <- sub("^--file=", "", f[grepl("^--file=", f)])
    if (length(f) == 1) dirname(normalizePath(f)) else NULL
  }, error = function(e) NULL)
  helper <- if (!is.null(this_dir)) file.path(this_dir, "wb_flags.R") else "wb_flags.R"
  if (file.exists(helper)) sys.source(helper, envir = topenv())
})

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

model_rds   <- parse_arg("--model_rds")
output_file <- parse_arg("--output_file")
num_threads <- as.integer(parse_arg("--num_threads", "4"))

if (is.null(model_rds))   stop("--model_rds required", call. = FALSE)
if (is.null(output_file)) stop("--output_file required", call. = FALSE)

fit <- readRDS(model_rds)

if (fit$status != "success") {
  cat(sprintf("Model %s status=%s — skipping\n", fit$model_name, fit$status))
  saveRDS(list(model_name = fit$model_name, well_behaved = FALSE,
               reason = "not_success"), output_file)
  quit(save = "no", status = 0)
}
wb_result <- wb_compute_result(fit, verbose = TRUE)
saveRDS(wb_result, output_file)
cat(sprintf("Saved: %s\n", output_file))

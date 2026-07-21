#!/usr/bin/env Rscript
# xsdm_parallel_wrapper.R
# ────────────────────────────────────────────────────────────────────────────
# Parallel wrapper: processes multiple species concurrently within one Slurm job.
# Uses mclapply to avoid Slurm array overhead. Each species gets its own
# sub-process with controlled threading.
#
# Usage (via sbatch):
#   Rscript xsdm_parallel_wrapper.R \
#     --species_list species_list_pilot10.txt \
#     --num_starts 500 \
#     --species_per_batch 8 \
#     --threads_per_species 3
# ────────────────────────────────────────────────────────────────────────────

suppressPackageStartupMessages({
  library(parallel)
})

# ── CLI parsing ──────────────────────────────────────────────────────────────
args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

species_list_file    <- parse_arg("--species_list", "species_list_pilot10.txt")
num_starts           <- as.integer(parse_arg("--num_starts", "500"))
species_per_batch    <- as.integer(parse_arg("--species_per_batch", "8"))
threads_per_species  <- as.integer(parse_arg("--threads_per_species", "3"))
env_csv_dir          <- parse_arg("--env_csv_dir",
                                  "/home/a474r867/scratch/xsdm_env_extraction_19")
output_dir           <- parse_arg("--output_dir",
                                  "/home/a474r867/scratch/xsdm_results")
occ_dir              <- parse_arg("--occ_dir",
                                  "/home/a474r867/scratch/xsdm_occurrences")
repo_root            <- parse_arg("--repo_root",
                                  "/home/a474r867/work/xsdm_1000_sp")
phase                <- parse_arg("--phase", "2var")
batch_offset         <- as.integer(parse_arg("--batch_offset", "0"))
batch_count          <- parse_arg("--batch_count", NULL)
if (!is.null(batch_count)) batch_count <- as.integer(batch_count)

# ── Load species list ────────────────────────────────────────────────────────
species_list_path <- if (grepl("^/", species_list_file)) {
  species_list_file
} else {
  file.path(repo_root, species_list_file)
}

if (!file.exists(species_list_path)) {
  stop("Species list not found: ", species_list_path)
}

all_species <- readLines(species_list_path)
all_species <- trimws(all_species)
all_species <- all_species[nchar(all_species) > 0]

# Apply batch slicing
if (!is.null(batch_count) && batch_count > 0) {
  start_idx <- batch_offset + 1
  end_idx   <- min(batch_offset + batch_count, length(all_species))
  all_species <- all_species[start_idx:end_idx]
  cat(sprintf("Batch slice: species %d-%d of %d total\n",
              start_idx, end_idx, length(all_species) + batch_offset))
}

total_species <- length(all_species)
cat(sprintf("Total species to process: %d\n", total_species))
cat(sprintf("Parallelism: %d concurrent, %d threads each\n",
            species_per_batch, threads_per_species))
cat(sprintf("Starts per model: %d  |  Phase: %s\n", num_starts, phase))
cat("===========================================================\n\n")

# ── Model selection script path ─────────────────────────────────────────────
model_script <- file.path(repo_root, "scripts", "r", "xsdm_model_selection_v2.R")

# ── Process one species ──────────────────────────────────────────────────────
process_species <- function(sp_name) {
  sp_t0 <- proc.time()[3]
  sp_safe <- gsub(" ", "_", sp_name)

  # Build command: call the existing model selection script directly via Rscript
  # We use system2 for clean subprocess isolation
  cmd_args <- c(
    model_script,
    "--species", sp_name,
    "--env_csv_dir", env_csv_dir,
    "--output_dir", output_dir,
    "--occ_dir", occ_dir,
    "--phase", phase,
    "--num_starts", num_starts,
    "--num_threads", threads_per_species
  )

  # Use env variable to limit OpenMP threads inside Apptainer
  # (Rscript is called inside the Apptainer via the sbatch script,
  #  so here we call it directly — the sbatch wrapper handles Apptainer)
  # Actually this wrapper runs INSIDE the Apptainer, so call Rscript directly

  res <- tryCatch({
    system2("Rscript", cmd_args,
            stdout = TRUE, stderr = TRUE,
            timeout = 3600)  # 1h per species max
  }, error = function(e) {
    return(paste("ERROR:", e$message))
  })

  elapsed <- round(proc.time()[3] - sp_t0, 1)

  # Check for errors
  exit_ok <- attr(res, "status")
  if (is.null(exit_ok)) exit_ok <- 0

  if (exit_ok == 0) {
    cat(sprintf("[OK]  %-35s  %6.1fs\n", sp_name, elapsed))
    return(list(species = sp_name, status = "OK", elapsed = elapsed))
  } else {
    err_msg <- if (is.character(res)) paste(tail(res, 3), collapse = " | ") else "exit code error"
    cat(sprintf("[FAIL] %-35s  %6.1fs  %s\n", sp_name, elapsed, err_msg))
    return(list(species = sp_name, status = "FAIL", elapsed = elapsed, error = err_msg))
  }
}

# ── Run in parallel ──────────────────────────────────────────────────────────
pipeline_t0 <- proc.time()[3]

results <- mclapply(
  all_species,
  process_species,
  mc.cores = species_per_batch,
  mc.preschedule = FALSE  # better load balancing
)

total_elapsed <- round(proc.time()[3] - pipeline_t0, 1)

# ── Summary ──────────────────────────────────────────────────────────────────
cat("\n===========================================================\n")
cat("PARALLEL RUN COMPLETE\n")
cat(sprintf("Total time: %.1fs (%.1f min)\n", total_elapsed, total_elapsed/60))
cat(sprintf("Species processed: %d\n", total_species))

statuses <- sapply(results, `[[`, "status")
n_ok   <- sum(statuses == "OK")
n_fail <- sum(statuses == "FAIL")
cat(sprintf("OK: %d  |  FAIL: %d  |  Success rate: %.1f%%\n",
            n_ok, n_fail, 100 * n_ok / total_species))

if (n_fail > 0) {
  cat("\nFailed species:\n")
  for (r in results) {
    if (r$status == "FAIL") {
      cat(sprintf("  %-35s  %s\n", r$species,
                  if (!is.null(r$error)) r$error else "unknown"))
    }
  }
}

cat("===========================================================\n")

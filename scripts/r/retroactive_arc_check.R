#!/usr/bin/env Rscript
# ─────────────────────────────────────────────────────────────────────
# retroactive_arc_check.R — Check profile arcs for existing results
# ─────────────────────────────────────────────────────────────────────
# Usage:
#   Rscript retroactive_arc_check.R --results_dir /path/to/xsdm_results \
#       --species_list species_list_50.txt --output docs/profile_arc_master.csv
#
# Reads model_results.rds from each species directory, extracts saved
# profiles, runs the arc check, and writes profile_arc_check.csv per
# species + consolidated master CSV.
# ─────────────────────────────────────────────────────────────────────

args <- commandArgs(trailingOnly = TRUE)

# Parse arguments
results_dir   <- NULL
species_list  <- NULL
output_file   <- "profile_arc_master.csv"
noise_tol     <- 0.5

i <- 1
while (i <= length(args)) {
  if (args[i] == "--results_dir") { results_dir  <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--species_list") { species_list <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--output") { output_file <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--noise_tol") { noise_tol <- as.numeric(args[i + 1]); i <- i + 2
  } else { i <- i + 1 }
}

if (is.null(results_dir)) stop("--results_dir is required")

# ── Arc check function (same as in xsdm_model_selection.R) ──────────
check_profile_arc <- function(prof, noise_tol = 0.5) {
  if (is.null(prof)) {
    return(list(is_arc = FALSE, reason = "profile_null",
                details = list()))
  }

  pdat   <- prof$profile
  thresh <- prof$threshold
  ll     <- pdat$loglik
  vals   <- pdat$value_math
  n      <- length(ll)

  if (n < 3) {
    return(list(is_arc = FALSE, reason = "too_few_points",
                details = list(n_points = n)))
  }

  if (isTRUE(prof$found_better)) {
    return(list(is_arc = FALSE, reason = "found_better_ll",
                details = list()))
  }

  idx_max <- which.max(ll)
  ll_max  <- ll[idx_max]

  has_left  <- idx_max > 1
  has_right <- idx_max < n

  left_crosses  <- has_left  && any(ll[1:(idx_max - 1)] <= thresh)
  right_crosses <- has_right && any(ll[(idx_max + 1):n] <= thresh)

  left_mono <- TRUE
  if (has_left && idx_max > 2) {
    left_ll <- ll[1:idx_max]
    for (i in 2:length(left_ll)) {
      if (left_ll[i] < left_ll[i - 1] - noise_tol) {
        left_mono <- FALSE
        break
      }
    }
  }

  right_mono <- TRUE
  if (has_right && idx_max < (n - 1)) {
    right_ll <- ll[idx_max:n]
    for (i in 2:length(right_ll)) {
      if (right_ll[i] > right_ll[i - 1] + noise_tol) {
        right_mono <- FALSE
        break
      }
    }
  }

  mle_at_peak <- (ll_max - ll[idx_max]) <= noise_tol

  is_arc <- left_crosses && right_crosses && left_mono && right_mono && mle_at_peak

  reason <- if (is_arc) {
    "pass"
  } else {
    reasons <- character(0)
    if (!left_crosses)  reasons <- c(reasons, "no_left_crossing")
    if (!right_crosses) reasons <- c(reasons, "no_right_crossing")
    if (!left_mono)     reasons <- c(reasons, "left_not_monotone")
    if (!right_mono)    reasons <- c(reasons, "right_not_monotone")
    if (!mle_at_peak)   reasons <- c(reasons, "mle_not_at_peak")
    paste(reasons, collapse = "+")
  }

  list(is_arc = is_arc, reason = reason,
       details = list(left_crosses = left_crosses, right_crosses = right_crosses,
                      left_mono = left_mono, right_mono = right_mono,
                      mle_at_peak = mle_at_peak, idx_max = idx_max,
                      n_points = n))
}

# ── Find species directories ────────────────────────────────────────
if (!is.null(species_list)) {
  species <- readLines(species_list)
  species <- species[nchar(trimws(species)) > 0]
} else {
  species <- list.dirs(results_dir, full.names = FALSE, recursive = FALSE)
  species <- gsub("_", " ", species)
}

cat(sprintf("Checking %d species in %s\n", length(species), results_dir))

# ── Process each species ────────────────────────────────────────────
all_rows <- list()
n_checked <- 0
n_pass    <- 0

for (sp in species) {
  sp_safe <- gsub(" ", "_", sp)
  sp_dir  <- file.path(results_dir, sp_safe)
  rds_file <- file.path(sp_dir, "model_results.rds")

  if (!file.exists(rds_file)) {
    cat(sprintf("  %-40s SKIP (no model_results.rds)\n", sp))
    next
  }

  res <- tryCatch(readRDS(rds_file), error = function(e) NULL)
  if (is.null(res)) {
    cat(sprintf("  %-40s SKIP (unreadable RDS)\n", sp))
    next
  }

  if (is.null(res$profiles) || length(res$profiles) == 0) {
    cat(sprintf("  %-40s SKIP (no profiles)\n", sp))
    next
  }

  # Run arc check on each profile
  arc_results <- list()
  for (pname in names(res$profiles)) {
    arc_results[[pname]] <- check_profile_arc(res$profiles[[pname]],
                                               noise_tol = noise_tol)
  }

  # Build row
  arc_row <- data.frame(species = sp, stringsAsFactors = FALSE)
  for (pname in names(arc_results)) {
    arc_row[[pname]] <- as.integer(arc_results[[pname]]$is_arc)
  }
  arc_row$all_pass <- as.integer(all(sapply(arc_results, `[[`, "is_arc")))
  arc_row$n_pass   <- sum(sapply(arc_results, `[[`, "is_arc"))
  arc_row$n_total  <- length(arc_results)

  fail_reasons <- sapply(names(arc_results), function(pname) {
    arc_results[[pname]]$reason
  })
  arc_row$fail_reasons <- paste(
    paste0(names(fail_reasons), ":", fail_reasons),
    collapse = "; "
  )

  # Write per-species CSV
  write.csv(arc_row, file.path(sp_dir, "profile_arc_check.csv"),
            row.names = FALSE)

  all_rows[[length(all_rows) + 1]] <- arc_row
  n_checked <- n_checked + 1
  if (arc_row$all_pass == 1) n_pass <- n_pass + 1

  cat(sprintf("  %-40s %d/%d pass  all=%s\n", sp,
              arc_row$n_pass, arc_row$n_total,
              if (arc_row$all_pass == 1) "YES" else "NO"))
}

# ── Write master CSV ────────────────────────────────────────────────
if (length(all_rows) > 0) {
  # rbind all rows, filling missing columns with NA
  all_names <- unique(unlist(lapply(all_rows, names)))
  master_rows <- lapply(all_rows, function(r) {
    missing <- setdiff(all_names, names(r))
    for (m in missing) r[[m]] <- NA
    r[all_names]
  })
  master_df <- do.call(rbind, master_rows)
  write.csv(master_df, output_file, row.names = FALSE)
  cat(sprintf("\n=== Summary ===\n"))
  cat(sprintf("Species checked: %d\n", n_checked))
  cat(sprintf("All arcs pass:   %d (%.0f%%)\n", n_pass,
              100 * n_pass / max(1, n_checked)))
  cat(sprintf("Master CSV:      %s\n", output_file))
} else {
  cat("No species had profiles to check.\n")
}

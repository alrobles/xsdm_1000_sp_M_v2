# ─────────────────────────────────────────────────────────────────────────────
# interactive_single_model.R
# Run ONE model for ONE species interactively in RStudio
# ─────────────────────────────────────────────────────────────────────────────
# Usage: Open in RStudio on the cluster, set parameters below, run line by line
# ─────────────────────────────────────────────────────────────────────────────

library(xsdm)

# ═══════════════════════════════════════════════════════════════════════════════
# PARAMETERS — EDIT THESE
# ═══════════════════════════════════════════════════════════════════════════════

species_name <- "Anaxyrus punctatus"
model_vars   <- c("T1", "P1")          # Variables in this model
num_starts   <- 50                      # Optimizer starting conditions
num_threads  <- 4                       # Parallel threads for optimization
mask         <- NULL                    # NULL for L1 (non-boundary)
                                        # For L2 boundary: c(pd = Inf)
                                        # Or: c(sigltil1 = Inf)

# Paths (adjust if your scratch is different)
scratch      <- "/home/a474r867/scratch"
env_csv_dir  <- file.path(scratch, "xsdm_env_extraction_19")

# ═══════════════════════════════════════════════════════════════════════════════
# VARIABLE MAPPING
# ═══════════════════════════════════════════════════════════════════════════════

var_map <- list(
  T1 = "T1_bio01",    # Annual Mean Temperature
  T2 = "T10_bio10",   # Mean Temperature Warmest Quarter
  T3 = "T11_bio11",   # Mean Temperature Coldest Quarter
  P1 = "P12_bio12",   # Annual Precipitation
  P2 = "P16_bio16",   # Precipitation Wettest Quarter
  P3 = "P17_bio17"    # Precipitation Driest Quarter
)

years <- 1980:2020

# ═══════════════════════════════════════════════════════════════════════════════
# LOAD DATA
# ═══════════════════════════════════════════════════════════════════════════════

sp_safe    <- gsub(" ", "_", species_name)
env_sp_dir <- file.path(env_csv_dir, sp_safe)

cat("Species:", species_name, "\n")
cat("Model:  ", paste(model_vars, collapse = " + "), "\n")
cat("Env dir:", env_sp_dir, "\n")
cat("Exists? ", dir.exists(env_sp_dir), "\n\n")

# Read occurrence from first variable
first_csv <- file.path(env_sp_dir, paste0(var_map[[model_vars[1]]], ".csv"))
occ_raw   <- read.csv(first_csv, stringsAsFactors = FALSE, check.names = FALSE)
occ_vec   <- occ_raw$presence
n_pts     <- nrow(occ_raw)
n_time    <- length(years)

cat("Presences:", sum(occ_vec == 1), "\n")
cat("Absences: ", sum(occ_vec == 0), "\n")
cat("Total pts:", n_pts, "\n")
cat("Time steps:", n_time, "\n\n")

# Load env data for each variable
env_data_list <- list()
for (vname in model_vars) {
  csv_file <- file.path(env_sp_dir, paste0(var_map[[vname]], ".csv"))
  stopifnot(file.exists(csv_file))
  env_df <- read.csv(csv_file, stringsAsFactors = FALSE, check.names = FALSE)
  mat <- matrix(NA_real_, nrow = n_pts, ncol = n_time)
  for (ti in seq_along(years)) {
    ycol <- as.character(years[ti])
    if (ycol %in% names(env_df)) mat[, ti] <- env_df[[ycol]]
  }
  env_data_list[[vname]] <- mat
  cat(sprintf("  %s: range [%.2f, %.2f], IQR=%.2f\n",
              vname, min(mat, na.rm=TRUE), max(mat, na.rm=TRUE), IQR(mat, na.rm=TRUE)))
}

# ═══════════════════════════════════════════════════════════════════════════════
# KELVIN → CELSIUS (temperature variables)
# ═══════════════════════════════════════════════════════════════════════════════
# ERA5Land mean-temperature bioclimatics (bio01/bio10/bio11 → T1/T2/T3) are in
# Kelvin; convert to Celsius. Pure location shift: IQR scaling and pBIC unchanged.

KELVIN_OFFSET <- 273.15
for (vname in intersect(c("T1", "T2", "T3"), model_vars)) {
  env_data_list[[vname]] <- env_data_list[[vname]] - KELVIN_OFFSET
}

# ═══════════════════════════════════════════════════════════════════════════════
# ADAPTIVE RESCALING (IQR-based)
# ═══════════════════════════════════════════════════════════════════════════════
# Compare IQR of each variable. If precipitation IQR is orders of magnitude
# larger than temperature IQR, divide by nearest power of 10.

temp_vars   <- c("T1", "T2", "T3")
precip_vars <- c("P1", "P2", "P3")

iqr_vals <- sapply(model_vars, function(vname) {
  IQR(as.vector(env_data_list[[vname]]), na.rm = TRUE)
})

cat("\nIQR values:\n")
print(iqr_vals)

# Reference = median IQR of temperature vars in this model
temp_in_model <- intersect(temp_vars, model_vars)
if (length(temp_in_model) > 0) {
  ref_iqr <- median(iqr_vals[temp_in_model], na.rm = TRUE)
} else {
  ref_iqr <- median(iqr_vals, na.rm = TRUE)
}
cat("Reference IQR (temp):", ref_iqr, "\n")

# Compute scale factors
scale_factors <- setNames(rep(1, length(model_vars)), model_vars)
for (vname in model_vars) {
  ratio <- iqr_vals[vname] / ref_iqr
  if (ratio > 10) {
    power <- floor(log10(ratio))
    scale_factors[vname] <- 10^power
    env_data_list[[vname]] <- env_data_list[[vname]] / (10^power)
    cat(sprintf("  RESCALED %s: divided by %g (ratio was %.1f)\n",
                vname, 10^power, ratio))
  }
}

cat("\nScale factors:", paste(sprintf("%s=1/%g", model_vars, scale_factors), collapse = ", "), "\n")

# Verify ranges after rescaling
cat("\nAfter rescaling:\n")
for (vname in model_vars) {
  mat <- env_data_list[[vname]]
  cat(sprintf("  %s: range [%.4f, %.4f], IQR=%.4f\n",
              vname, min(mat, na.rm=TRUE), max(mat, na.rm=TRUE), IQR(mat, na.rm=TRUE)))
}

# ═══════════════════════════════════════════════════════════════════════════════
# BUILD ENV ARRAY
# ═══════════════════════════════════════════════════════════════════════════════

p <- length(model_vars)
env_dat <- array(NA_real_, dim = c(n_pts, n_time, p))
for (k in seq_along(model_vars)) {
  env_dat[, , k] <- env_data_list[[model_vars[k]]]
}

# Occurrence vector (binary)
n <- sum(occ_vec == 1)
occ <- occ_vec

cat("\nenv_dat dimensions:", paste(dim(env_dat), collapse=" x "), "\n")
cat("n (presences):", n, "\n")
cat("p (variables):", p, "\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TAU (for reference)
# ═══════════════════════════════════════════════════════════════════════════════

max_p <- 3  # max variables in any model (fixed at 3 for v6)
tau <- (max_p + 1) * log(n)
cat(sprintf("\ntau = (3+1)*log(%d) = %.2f\n", n, tau))

# ═══════════════════════════════════════════════════════════════════════════════
# FIT MODEL
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n══════════════════════════════════════════\n")
cat("FITTING:", paste(model_vars, collapse="_"))
if (!is.null(mask)) cat(" | mask:", paste(names(mask), mask, sep="=", collapse=", "))
cat(sprintf("\nStarts: %d, Threads: %d\n", num_starts, num_threads))
cat("══════════════════════════════════════════\n\n")

t0 <- proc.time()[3]

fit <- optimize_likelihood(
  env_dat     = env_dat,
  occ         = occ,
  mask        = mask,
  num_starts  = num_starts,
  num_threads = num_threads,
  parallel    = FALSE,
  verbose     = TRUE
)

elapsed <- proc.time()[3] - t0

# ═══════════════════════════════════════════════════════════════════════════════
# RESULTS
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n══════════════════════════════════════════\n")
cat("RESULTS\n")
cat("══════════════════════════════════════════\n\n")

cat(sprintf("Time: %.1f seconds\n", elapsed))

if (!is.null(fit) && !is.null(fit$best$par)) {
  n_free <- if (is.null(mask)) num_par(p) else num_par(p) - length(mask)
  pBIC   <- -2 * fit$best$loglik + n_free * log(n)

  cat(sprintf("LogLik:  %.4f\n", fit$best$loglik))
  cat(sprintf("n_free:  %d\n", n_free))
  cat(sprintf("pBIC:    %.2f\n", pBIC))
  cat(sprintf("tau:     %.2f\n", tau))
  cat(sprintf("Within tau of best? (need comparison with other models)\n\n"))

  cat("Best parameters:\n")
  print(fit$best$par)

  # Top 5 solutions
  cat("\nTop 5 solutions (loglik):\n")
  top5 <- head(fit$solutions[order(-sapply(fit$solutions, function(x) x$loglik)), ], 5)
  for (i in seq_along(top5)) {
    cat(sprintf("  #%d: loglik=%.4f\n", i, top5[[i]]$loglik))
  }

  # Convergence check (Flag A)
  logliks <- sapply(head(fit$solutions, 5), function(x) x$loglik)
  ll_range <- max(logliks) - min(logliks)
  cat(sprintf("\nConvergence (top 5): ll_range=%.6f %s\n",
              ll_range, ifelse(ll_range < 0.1, "GOOD", "WARN")))

} else {
  cat("FAILED — no valid solution found\n")
}

cat("\n══════════════════════════════════════════\n")
cat("DONE\n")
cat("══════════════════════════════════════════\n")

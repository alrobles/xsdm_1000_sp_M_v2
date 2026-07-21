#!/usr/bin/env Rscript
# occ_prefilter.R — Geographic outlier prefilter for occurrence points.
#
# Presence records that sit far from the bulk of presences (typically data
# errors, e.g. a Brazilian species with a stray Florida record) distort the
# fitted niche, the prediction bounding box, and TSS. We keep only points whose
# longitude AND latitude fall within the central quantile range of the PRESENCE
# coordinates. Both presences and pseudo-absences are trimmed to the same box so
# the fit, the map extent and the TSS all share one study region.
#
# The bounds are derived from presences only (they define the biological core);
# with the default quantile = 0.95 this keeps the central 95% of presence lon/lat.

prefilter_enabled <- function() {
  tolower(Sys.getenv("APPLY_PREFILTER", "true")) %in% c("true", "1", "yes", "t")
}

prefilter_quantile <- function() {
  q <- suppressWarnings(as.numeric(Sys.getenv("PREFILTER_QUANTILE", "0.95")))
  if (length(q) == 0 || !is.finite(q) || q <= 0 || q >= 1) 0.95 else q
}

prefilter_drop_top_k <- function() {
  k <- suppressWarnings(as.integer(Sys.getenv("DROP_TOP_K", "0")))
  if (length(k) == 0 || is.na(k) || k < 0L) 0L else k
}

occ_prefilter_bounds <- function(lon, lat, presence, quantile = 0.95) {
  alpha <- (1 - quantile) / 2
  is_pres <- as.integer(presence) == 1L
  probs <- c(alpha, 1 - alpha)
  list(
    lon = stats::quantile(lon[is_pres], probs, na.rm = TRUE, names = FALSE),
    lat = stats::quantile(lat[is_pres], probs, na.rm = TRUE, names = FALSE)
  )
}

# Logical keep-vector over ALL points (presences and pseudo-absences), TRUE for
# points inside the central-quantile box of the presences. Returns all TRUE when
# there are too few presences to estimate stable quantiles.
occ_prefilter_keep <- function(lon, lat, presence, quantile = 0.95,
                               min_presences = 10L) {
  n_pres <- sum(as.integer(presence) == 1L, na.rm = TRUE)
  if (n_pres < min_presences) return(rep(TRUE, length(lon)))
  b <- occ_prefilter_bounds(lon, lat, presence, quantile = quantile)
  lon >= b$lon[1] & lon <= b$lon[2] & lat >= b$lat[1] & lat <= b$lat[2]
}

occ_drop_top_k_keep <- function(lon, lat, presence, k) {
  k <- suppressWarnings(as.integer(k))
  n <- length(lon)
  if (n == 0L || is.na(k) || k <= 0L || k >= n) return(rep(TRUE, n))

  is_pres <- as.integer(presence) == 1L
  if (!any(is_pres, na.rm = TRUE)) return(rep(TRUE, n))

  med_lon <- median(lon[is_pres], na.rm = TRUE)
  med_lat <- median(lat[is_pres], na.rm = TRUE)
  dist <- sqrt((lon - med_lon)^2 + (lat - med_lat)^2)
  ord <- order(dist, decreasing = TRUE, na.last = NA)
  if (length(ord) == 0L) return(rep(TRUE, n))

  drop_idx <- ord[seq_len(min(k, length(ord)))]
  keep <- rep(TRUE, n)
  keep[drop_idx] <- FALSE
  keep
}

#!/usr/bin/env Rscript

user_lib <- Sys.getenv(
  "R_LIBS_USER",
  file.path(Sys.getenv("HOME"), "R/x86_64-pc-linux-gnu-library/4.4")
)
if (dir.exists(user_lib)) .libPaths(c(user_lib, .libPaths()))

suppressPackageStartupMessages({
  library(xsdm)
  library(terra)
})

local({
  this_dir <- tryCatch({
    f <- commandArgs(trailingOnly = FALSE)
    f <- sub("^--file=", "", f[grepl("^--file=", f)])
    if (length(f) == 1) dirname(normalizePath(f)) else NULL
  }, error = function(e) NULL)
  helper <- if (!is.null(this_dir)) file.path(this_dir, "occ_prefilter.R") else "occ_prefilter.R"
  if (file.exists(helper)) sys.source(helper, envir = topenv())
})

`%||%` <- function(a, b) if (is.null(a)) b else a

prefilter_enabled <- function() {
  tolower(Sys.getenv("APPLY_PREFILTER", "true")) %in% c("true", "1", "yes", "t")
}

# ERA5Land absolute-temperature bioclimatics are stored in Kelvin. The fit
# converts them to Celsius (see fit_single_model.R); the prediction path must
# apply the identical offset so the model and the rasters share units.
KELVIN_OFFSET <- 273.15
TEMP_BIO_CODES <- c("bio01", "bio05", "bio06", "bio08", "bio09", "bio10", "bio11")

resolve_bioclim_code <- function(var_name) {
  mapping <- c(
    T1 = "bio01",
    T2 = "bio10",
    T3 = "bio11",
    P1 = "bio12",
    P2 = "bio16",
    P3 = "bio17"
  )
  if (var_name %in% names(mapping)) return(unname(mapping[[var_name]]))
  if (grepl("^bio[0-9]{2}$", var_name)) return(var_name)
  stop("Unsupported model variable: ", var_name, call. = FALSE)
}

read_occurrence_df_raw <- function(occ_csv) {
  occ <- read.csv(occ_csv, stringsAsFactors = FALSE, check.names = FALSE)
  if ("presence" %in% names(occ) && !("occ" %in% names(occ))) {
    names(occ)[names(occ) == "presence"] <- "occ"
  }
  req <- c("lon", "lat", "occ")
  if (!all(req %in% names(occ))) {
    stop("Occurrence CSV must contain columns: lon, lat, occ", call. = FALSE)
  }
  occ
}

occ_keep_mask <- function(lon, lat, presence) {
  keep <- rep(TRUE, length(lon))
  if (prefilter_enabled() && exists("occ_prefilter_keep", mode = "function")) {
    q <- prefilter_quantile()
    keep_q <- occ_prefilter_keep(lon, lat, presence, quantile = q)
    keep <- keep & keep_q
    n_drop <- sum(!keep_q)
    if (n_drop > 0) {
      message(sprintf(
        "occ_prefilter: dropped %d/%d occurrence points outside the presence lon/lat central %.1f%% box.",
        n_drop, length(lon), 100 * q))
    }
  } else if (!prefilter_enabled()) {
    message("occ_prefilter: DISABLED (APPLY_PREFILTER=false)")
  }

  if (exists("occ_drop_top_k_keep", mode = "function")) {
    k_drop <- prefilter_drop_top_k()
    keep_k <- occ_drop_top_k_keep(lon, lat, presence, k = k_drop)
    keep <- keep & keep_k
    drop_idx <- which(!keep_k)
    if (length(drop_idx) > 0) {
      message(sprintf("occ_drop_top_k: dropped %d point(s) (k=%d)", length(drop_idx), k_drop))
      for (i in drop_idx) {
        cls <- if (as.integer(presence[i]) == 1L) "presence" else "absence"
        message(sprintf("  drop lon=%.6f lat=%.6f class=%s", lon[i], lat[i], cls))
      }
    } else if (k_drop > 0L) {
      message(sprintf("occ_drop_top_k: no-op (k=%d, n=%d)", k_drop, length(lon)))
    }
  }

  keep
}

read_occurrence_df <- function(occ_csv) {
  occ <- read_occurrence_df_raw(occ_csv)
  keep <- occ_keep_mask(occ$lon, occ$lat, occ$occ)
  occ <- occ[keep, , drop = FALSE]
  occ
}

read_occurrence_vector <- function(occ_csv, occ_df = NULL) {
  occ <- if (is.null(occ_df)) read_occurrence_df(occ_csv) else occ_df
  if (!any(occ$occ == 1)) {
    stop("No presences (occ == 1) found in occurrence CSV.", call. = FALSE)
  }
  if (!any(occ$occ == 0)) {
    stop("No pseudo-absences (occ == 0) found in occurrence CSV.", call. = FALSE)
  }
  terra::vect(occ, geom = c("lon", "lat"), crs = "EPSG:4326")
}

read_presence_vector <- function(occ_csv, occ_df = NULL) {
  occ <- if (is.null(occ_df)) read_occurrence_df(occ_csv) else occ_df
  pres <- occ[occ$occ == 1, , drop = FALSE]
  if (nrow(pres) == 0) {
    stop("No presences (occ == 1) found in occurrence CSV.", call. = FALSE)
  }
  terra::vect(pres, geom = c("lon", "lat"), crs = "EPSG:4326")
}

make_mcp_polygon <- function(points_vect, buffer_km = 10) {
  hull <- terra::convHull(points_vect)
  terra::buffer(hull, width = buffer_km * 1000)
}

make_bbox_polygon <- function(points_vect, buffer_km = 10) {
  e <- terra::ext(points_vect)
  mean_lat <- mean(c(e$ymin, e$ymax))
  dlat <- buffer_km / 111.32
  dlon <- buffer_km / (111.32 * cos(mean_lat * pi / 180))
  bbox_ext <- terra::ext(e$xmin - dlon, e$xmax + dlon, e$ymin - dlat, e$ymax + dlat)
  terra::as.polygons(bbox_ext, crs = terra::crs(points_vect))
}

reconstruct_full_math <- function(best_par, mask, p) {
  best_par
}

build_env_list <- function(vars, scale_factors, bioclim_dir, years, polygon_vect) {
  env_list <- vector("list", length(vars))
  names(env_list) <- vars

  for (var in vars) {
    bio_code <- resolve_bioclim_code(var)
    scale <- suppressWarnings(as.numeric(scale_factors[[var]]))
    if (length(scale) == 0 || is.na(scale) || scale == 0) {
      stop("Missing or invalid scale factor for variable: ", var, call. = FALSE)
    }

    paths <- file.path(
      bioclim_dir,
      as.character(years),
      paste0(bio_code, "_", years, ".tif")
    )
    missing <- paths[!file.exists(paths)]
    if (length(missing) > 0) {
      stop(
        "Missing bioclim files for ", var, " (", bio_code, "): ",
        paste(missing, collapse = ", "),
        call. = FALSE
      )
    }

    r <- terra::rast(paths)
    # ERA5Land bioclim use a custom spherical longlat CRS; relabel the polygon
    # (built in EPSG:4326, identical lon/lat values) to avoid a CRS mismatch.
    terra::crs(polygon_vect) <- terra::crs(r)
    r <- terra::crop(r, polygon_vect)
    r <- terra::mask(r, polygon_vect)
    if (bio_code %in% TEMP_BIO_CODES) {
      r <- r - KELVIN_OFFSET
    }
    r <- r / scale
    names(r) <- as.character(years)
    env_list[[var]] <- r
  }

  env_list
}

extract_raster_values <- function(rast_obj, xy) {
  vals <- terra::extract(rast_obj, xy)
  if (is.data.frame(vals)) {
    if (ncol(vals) < 1) stop("Unexpected extract() output.", call. = FALSE)
    return(vals[[ncol(vals)]])
  }
  as.numeric(vals)
}

compute_threshold_metrics <- function(preds, labels, eval_idx = seq_along(labels)) {
  preds <- preds[eval_idx]
  labels <- labels[eval_idx]
  keep <- is.finite(preds) & !is.na(labels)
  preds <- preds[keep]
  labels <- labels[keep]
  thresholds <- sort(unique(preds), decreasing = TRUE)
  if (length(thresholds) == 0) {
    stop("No predictions available for thresholding.", call. = FALSE)
  }

  sens <- numeric(length(thresholds))
  spec <- numeric(length(thresholds))
  for (i in seq_along(thresholds)) {
    thr <- thresholds[i]
    pred_cls <- ifelse(preds >= thr, 1L, 0L)
    tp <- sum(pred_cls == 1L & labels == 1L)
    fn <- sum(pred_cls == 0L & labels == 1L)
    tn <- sum(pred_cls == 0L & labels == 0L)
    fp <- sum(pred_cls == 1L & labels == 0L)
    sens[i] <- if ((tp + fn) == 0) NA_real_ else tp / (tp + fn)
    spec[i] <- if ((tn + fp) == 0) NA_real_ else tn / (tn + fp)
  }

  score <- sens + spec
  best <- which(score == max(score, na.rm = TRUE))[1]
  list(
    threshold        = thresholds[best],
    sensitivity      = sens[best],
    specificity      = spec[best],
    tss              = score[best] - 1,
    n_total          = length(labels),
    n_presences      = sum(labels == 1L),
    n_pseudoabsences = sum(labels == 0L),
    prevalence       = mean(labels == 1L)
  )
}

get_eval_index <- function(split, labels) {
  if (identical(split, "none")) return(seq_along(labels))
  stop("Split '", split, "' is not implemented yet; use split = 'none'.", call. = FALSE)
}

compute_tss <- function(
    model_rds,
    occ_csv,
    bioclim_dir,
    years = 1980:2020,
    output_rds = "",
    split = "none",
    num_threads = 0L,
    m_shapefile = NULL
) {
  fit <- readRDS(model_rds)
  if (is.null(fit$status) || fit$status != "success") {
    stop("Selected model is not successful.", call. = FALSE)
  }
  if (is.null(fit$vars) || is.null(fit$best_par)) {
    stop("Selected model RDS is missing vars or best_par.", call. = FALSE)
  }

  occ <- read_occurrence_df(occ_csv)
  occ_vect <- terra::vect(occ, geom = c("lon", "lat"), crs = "EPSG:4326")
  p <- length(fit$vars)

  if (!is.null(m_shapefile) && nzchar(m_shapefile) && file.exists(m_shapefile)) {
    polygon_vect <- terra::vect(m_shapefile)
    terra::crs(polygon_vect) <- "EPSG:4326"
  } else {
    polygon_vect <- make_bbox_polygon(occ_vect, buffer_km = 10)
  }

  env_list <- build_env_list(
    vars          = fit$vars,
    scale_factors = fit$scale_factors,
    bioclim_dir   = bioclim_dir,
    years         = years,
    polygon_vect  = polygon_vect
  )

  full_math <- reconstruct_full_math(fit$best_par, fit$mask, length(fit$vars))
  param_list <- xsdm::math_to_bio(full_math)

  hab <- xsdm::habitat_suitability(
    param_list  = param_list,
    env_list    = env_list,
    return_prob = TRUE,
    threads     = num_threads
  )

  occ_xy <- terra::crds(occ_vect, df = TRUE)[, c("x", "y"), drop = FALSE]
  preds <- extract_raster_values(hab, occ_xy)
  labels <- as.integer(as.data.frame(occ_vect)$occ == 1)
  eval_idx <- get_eval_index(split, labels)
  metrics <- compute_threshold_metrics(preds = preds, labels = labels, eval_idx = eval_idx)

  out <- c(
    list(
      species          = fit$species %||% basename(dirname(model_rds)),
      model_name       = fit$model_name %||% basename(model_rds),
      split            = split,
      estimate         = "in-sample (resubstitution)",
      n_total          = length(labels),
      n_presences      = sum(labels == 1L),
      n_pseudoabsences = sum(labels == 0L),
      years            = paste(range(years), collapse = ":"),
      p                = p
    ),
    metrics
  )

  if (nzchar(output_rds)) {
    dir.create(dirname(output_rds), recursive = TRUE, showWarnings = FALSE)
    saveRDS(out, output_rds)
  }

  out
}

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

if (sys.nframe() == 0) {
  model_rds <- parse_arg("--model_rds")
  occ_csv <- parse_arg("--occ_csv")
  bioclim_dir <- parse_arg("--bioclim_dir")
  output_rds <- parse_arg("--output_rds", "")
  years_str <- parse_arg("--years", paste(1980:2020, collapse = ","))
  split <- parse_arg("--split", "none")
  num_threads <- as.integer(parse_arg("--num_threads", "0"))
  m_shapefile <- parse_arg("--m_shapefile", "")
  years <- as.integer(strsplit(years_str, ",", fixed = TRUE)[[1]])

  if (is.null(model_rds)) stop("--model_rds required", call. = FALSE)
  if (is.null(occ_csv)) stop("--occ_csv required", call. = FALSE)
  if (is.null(bioclim_dir)) stop("--bioclim_dir required", call. = FALSE)

  res <- compute_tss(
    model_rds   = model_rds,
    occ_csv     = occ_csv,
    bioclim_dir = bioclim_dir,
    years       = years,
    output_rds  = output_rds,
    split       = split,
    num_threads = num_threads,
    m_shapefile = if (nzchar(m_shapefile)) m_shapefile else NULL
  )
  print(res)
}

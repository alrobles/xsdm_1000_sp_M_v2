#!/usr/bin/env Rscript
# detect_profile_boundary_failures.R — scans profile likelihood arc checks and
# proposes boundary models for parameters whose profile never crosses the
# likelihood threshold on one side.  Such "no_*_crossing" failures usually
# mean the parameter is at a bound (e.g. pd -> 1, or a tolerance -> Inf).
#
#   --model_rds  "/path/to/model.rds"
#   --profile_rds "/path/to/profile_results_v7.rds" (optional, defaults to
#                 dirname(model_rds)/../profile_results_v7.rds)
#   --output_tsv  "/path/to/candidates.tsv" (optional, defaults to stdout)
#
# Output TSV columns: model_name, vars, mask
# One row per candidate boundary model.  Empty output means no refinement needed.
# Suffix convention: __bd_<c1>_<c2>_...  where components are ordered as
#   pd1/pd0, then sigL1/sigR1, sigL2/sigR2, ...

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

model_rds  <- parse_arg("--model_rds")
profile_rds <- parse_arg("--profile_rds")
output_tsv  <- parse_arg("--output_tsv")

if (is.null(model_rds)) stop("--model_rds required", call. = FALSE)
if (is.null(profile_rds)) {
  profile_rds <- file.path(dirname(model_rds), "..", "profile_results_v7.rds")
  profile_rds <- normalizePath(profile_rds, mustWork = FALSE)
}

fit <- tryCatch(readRDS(model_rds), error = function(e) NULL)
if (is.null(fit) || is.null(fit$best_par)) {
  cat("")
  quit(save = "no", status = 0)
}

prof <- tryCatch(readRDS(profile_rds), error = function(e) NULL)
if (is.null(prof) || is.null(prof$arc_results)) {
  cat("")
  quit(save = "no", status = 0)
}

# Extract base model name (strip any existing __bd_* suffix)
model_name <- fit$model_name
base_name <- sub("__bd_.*$", "", model_name)
vars <- fit$vars
p <- length(vars)

# Existing mask (named numeric, e.g. pd=Inf)
existing_mask <- fit$mask
if (is.null(existing_mask)) existing_mask <- numeric(0)

# Helper: parse parameter index from names like mu1, sigltil2, sigrtil2, etc.
parse_idx <- function(nm) {
  m <- regmatches(nm, regexec("^(mu|sigltil|sigrtil|o_par)([0-9]+)$", nm))[[1]]
  if (length(m) == 0) return(NA_integer_)
  as.integer(m[3])
}

# Canonical component name for a mask parameter/value (without the leading "bd_")
mask_component_name <- function(param, value) {
  if (param == "pd") {
    if (value == Inf) return("pd1")
    if (value == -Inf) return("pd0")
    return(NULL)
  }
  idx <- parse_idx(param)
  if (is.na(idx)) return(NULL)
  if (grepl("^sigltil", param)) {
    if (value == Inf) return(sprintf("sigL%d", idx))
    if (value == -Inf) return(sprintf("sigL0%d", idx))
  }
  if (grepl("^sigrtil", param)) {
    if (value == Inf) return(sprintf("sigR%d", idx))
    if (value == -Inf) return(sprintf("sigR0%d", idx))
  }
  NULL
}

# Sort key for canonical ordering of components
component_sort_key <- function(comp) {
  # pd first, then by variable index, left/right, lower/upper
  if (comp == "pd0") return("0_000_0_1")
  if (comp == "pd1") return("0_000_0_0")
  m <- regmatches(comp, regexec("^(sigL|sigR|sigL0|sigR0)([0-9]+)$", comp))[[1]]
  if (length(m) == 0) return("9_999_9_9")
  side <- m[2]
  idx <- as.integer(m[3])
  lower <- if (grepl("0$", side)) "1" else "0"
  side_clean <- sub("0$", "", side)
  side_key <- if (side_clean == "sigL") "1" else "2"
  sprintf("1_%03d_%s_%s", idx, side_key, lower)
}

# Build full model suffix from a character vector of components
build_suffix <- function(components) {
  if (length(components) == 0) return("")
  components <- components[order(vapply(components, component_sort_key, character(1)))]
  paste0("__bd_", paste(components, collapse = "_"))
}

# Build mask string from a list of (param, value) pairs
build_mask_str <- function(pairs) {
  if (length(pairs) == 0) return("")
  paste(vapply(pairs, function(x) paste0(x$param, "=", x$value), character(1)), collapse = ",")
}

# Collect existing mask components as list(param, value, component)
existing_components <- list()
for (nm in names(existing_mask)) {
  comp <- mask_component_name(nm, existing_mask[nm])
  if (!is.null(comp)) {
    existing_components[[length(existing_components) + 1]] <- list(
      param = nm, value = existing_mask[nm], component = comp
    )
  }
}

# New suggestions from profile / bio saturation
new_suggestions <- list()

# Check pd saturation directly from best_bio when pd is free
if (!("pd" %in% names(existing_mask))) {
  bio <- tryCatch(xsdm::math_to_bio(fit$best_par), error = function(e) NULL)
  if (!is.null(bio) && !is.null(bio$pd)) {
    if (bio$pd >= 1 - 1e-6) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = "pd", value = Inf, component = "pd1"
      )
    } else if (bio$pd <= 1e-6) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = "pd", value = -Inf, component = "pd0"
      )
    }
  }
}

# Inspect arc_results
arc <- prof$arc_results
for (param in names(arc)) {
  reason <- arc[[param]]$reason
  if (is.null(reason) || reason == "pass") next
  idx <- parse_idx(param)
  if (is.na(idx)) next

  has_left  <- grepl("no_left_crossing", reason)
  has_right <- grepl("no_right_crossing", reason)

  if (grepl("^sigltil", param)) {
    if (has_right && !(param %in% names(existing_mask))) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = param, value = Inf, component = sprintf("sigL%d", idx)
      )
    }
    if (has_left && !(param %in% names(existing_mask))) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = param, value = -Inf, component = sprintf("sigL0%d", idx)
      )
    }
  } else if (grepl("^sigrtil", param)) {
    if (has_right && !(param %in% names(existing_mask))) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = param, value = Inf, component = sprintf("sigR%d", idx)
      )
    }
    if (has_left && !(param %in% names(existing_mask))) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = param, value = -Inf, component = sprintf("sigR0%d", idx)
      )
    }
  } else if (grepl("^mu", param)) {
    # mu failure on a side indicates the corresponding sigma is unbounded there
    if (has_right && idx <= p) {
      sig_param <- sprintf("sigrtil%d", idx)
      if (!(sig_param %in% names(existing_mask))) {
        new_suggestions[[length(new_suggestions) + 1]] <- list(
          param = sig_param, value = Inf, component = sprintf("sigR%d", idx)
        )
      }
    }
    if (has_left && idx <= p) {
      sig_param <- sprintf("sigltil%d", idx)
      if (!(sig_param %in% names(existing_mask))) {
        new_suggestions[[length(new_suggestions) + 1]] <- list(
          param = sig_param, value = Inf, component = sprintf("sigL%d", idx)
        )
      }
    }
  } else if (param == "pd") {
    if (has_right) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = "pd", value = Inf, component = "pd1"
      )
    }
    if (has_left) {
      new_suggestions[[length(new_suggestions) + 1]] <- list(
        param = "pd", value = -Inf, component = "pd0"
      )
    }
  }
}

# Remove duplicate new suggestions (same param)
uniq <- function(sugs) {
  seen <- character(0)
  out <- list()
  for (s in sugs) {
    if (!(s$param %in% seen)) {
      out[[length(out) + 1]] <- s
      seen <- c(seen, s$param)
    }
  }
  out
}
new_suggestions <- uniq(new_suggestions)

if (length(new_suggestions) == 0) {
  cat("")
  quit(save = "no", status = 0)
}

# Build candidates: all non-empty subsets of new suggestions added to existing mask.
# This ensures combinations like pd1+sigR2 are tested, not just singles and the full set.
build_candidate <- function(sugs_to_add) {
  comps <- c(
    vapply(existing_components, function(c) c$component, character(1)),
    vapply(sugs_to_add, function(s) s$component, character(1))
  )
  pairs <- c(existing_components, sugs_to_add)
  list(
    model_name = paste0(base_name, build_suffix(comps)),
    vars = paste(vars, collapse = ","),
    mask = build_mask_str(pairs)
  )
}

candidates <- list()

k <- length(new_suggestions)
if (k <= 5) {
  for (r in seq_len(k)) {
    idx <- combn(k, r, simplify = FALSE)
    for (i in idx) {
      candidates[[length(candidates) + 1]] <- build_candidate(new_suggestions[i])
    }
  }
} else {
  # Heuristic for many failures: singles, all pairs, and the full set
  for (s in new_suggestions) {
    candidates[[length(candidates) + 1]] <- build_candidate(list(s))
  }
  for (i in seq_len(k - 1)) {
    for (j in (i + 1):k) {
      candidates[[length(candidates) + 1]] <- build_candidate(new_suggestions[c(i, j)])
    }
  }
  candidates[[length(candidates) + 1]] <- build_candidate(new_suggestions)
}

# Convert to data frame and remove duplicates (same model_name)
df <- do.call(rbind, lapply(candidates, as.data.frame, stringsAsFactors = FALSE))
df <- df[!duplicated(df$model_name), ]

out <- if (!is.null(output_tsv)) file(output_tsv, "w") else stdout()
write.table(df, file = out, sep = "\t", row.names = FALSE, quote = FALSE)
if (!is.null(output_tsv)) close(out)

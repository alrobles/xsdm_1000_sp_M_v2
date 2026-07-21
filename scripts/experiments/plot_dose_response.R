#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
parse_arg <- function(flag, default = NULL) {
  idx <- which(args == flag)
  if (length(idx) == 0) return(default)
  args[idx + 1]
}

`%||%` <- function(a, b) if (is.null(a)) b else a

fmtn <- function(x, digits = 3) {
  if (length(x) == 0 || is.na(x)) return("NA")
  formatC(x, format = "f", digits = digits)
}

fmt_sci <- function(x, digits = 3) {
  if (length(x) == 0 || is.na(x)) return("NA")
  formatC(x, format = "e", digits = digits)
}

fmt_int <- function(x) {
  if (length(x) == 0 || is.na(x)) return("NA")
  as.character(as.integer(x))
}

out_root <- parse_arg("--out")
species <- parse_arg("--species", "Amazona aestiva")
model_name <- parse_arg("--model_name", "T3_noP__bd_pd1_sigL1")
ks_str <- parse_arg("--ks", "0,1,2,3,5,10")

if (is.null(out_root) || !nzchar(out_root)) {
  stop("--out required", call. = FALSE)
}

species_safe <- gsub(" ", "_", species)
ks <- as.integer(strsplit(gsub("[[:space:]]+", "", ks_str), ",", fixed = TRUE)[[1]])
ks <- ks[!is.na(ks)]
if (length(ks) == 0) stop("No valid ks provided.", call. = FALSE)

read_result <- function(path) {
  if (!file.exists(path)) return(NULL)
  tryCatch(readRDS(path), error = function(e) NULL)
}

collect_rows <- list()
curve_rows <- list()
free_names <- NULL

for (k in ks) {
  sp_dir <- file.path(out_root, paste0("k", k), species_safe)
  fit_rds <- file.path(sp_dir, "models", paste0(model_name, ".rds"))
  wb_rds <- file.path(sp_dir, "wb", paste0(model_name, "_wb.rds"))
  prof_rds <- file.path(sp_dir, "profile_results_v6.rds")

  fit <- read_result(fit_rds)
  wb <- read_result(wb_rds)
  prof <- read_result(prof_rds)

  n_points <- if (!is.null(fit$n)) fit$n else if (!is.null(fit$occ)) length(fit$occ) else NA_integer_
  n_pres <- if (!is.null(fit$occ)) sum(fit$occ == 1L, na.rm = TRUE) else NA_integer_
  loglik <- if (!is.null(fit$loglik)) fit$loglik else NA_real_
  flagA_max_pdist <- if (!is.null(wb$max_pdist)) wb$max_pdist else NA_real_
  flagB_min_eval <- if (!is.null(wb$min_eval)) wb$min_eval else NA_real_
  flagB_cond <- if (!is.null(wb$cond_num)) wb$cond_num else NA_real_

  arc_pass <- NA_integer_
  arc_total <- NA_integer_
  if (!is.null(prof$arc_results)) {
    arc_total <- length(prof$arc_results)
    arc_pass <- sum(vapply(prof$arc_results, function(a) isTRUE(a$pass), logical(1)))
  }

  collect_rows[[length(collect_rows) + 1L]] <- data.frame(
    k = k,
    N_points = n_points,
    n_presences = n_pres,
    logLik = loglik,
    flagA_max_pdist = flagA_max_pdist,
    flagB_min_eval = flagB_min_eval,
    flagB_cond = flagB_cond,
    `arc_pass / arc_total` = if (is.na(arc_pass) || is.na(arc_total)) "NA" else sprintf("%d/%d", arc_pass, arc_total),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  if (!is.null(prof$profiles)) {
    profs <- Filter(Negate(is.null), prof$profiles)
    if (length(profs) > 0 && is.null(free_names)) {
      free_names <- names(profs)
    }
    for (pn in names(profs)) {
      pdat <- profs[[pn]]$profile
      if (is.null(pdat) || !nrow(pdat)) next
      xv <- if ("value_math" %in% names(pdat)) pdat$value_math else pdat[[pn]]
      if (is.null(xv)) next
      optimum <- if (!is.null(fit$best_par) && pn %in% names(fit$best_par)) fit$best_par[[pn]] else NA_real_
      curve_rows[[length(curve_rows) + 1L]] <- data.frame(
        k = k,
        param = pn,
        value_math = as.numeric(xv),
        loglik = as.numeric(pdat$loglik),
        threshold = if (!is.null(profs[[pn]]$threshold)) profs[[pn]]$threshold else NA_real_,
        optimum = optimum,
        stringsAsFactors = FALSE
      )
    }
  }
}

if (length(collect_rows) == 0) {
  stop("No results found under ", out_root, call. = FALSE)
}

summary_df <- do.call(rbind, collect_rows)
summary_df <- summary_df[order(summary_df$k), , drop = FALSE]

csv_path <- file.path(out_root, "dose_response_summary.csv")
md_path <- file.path(out_root, "dose_response_summary.md")
png_path <- file.path(out_root, "dose_response_profiles.png")

dir.create(out_root, recursive = TRUE, showWarnings = FALSE)
write.csv(summary_df, csv_path, row.names = FALSE, na = "")

md_lines <- c(
  sprintf("# Dose-response summary for %s", species),
  "",
  sprintf("- Fixed model: `%s`", model_name),
  sprintf("- Sweep: %s", paste(ks, collapse = ", ")),
  "",
  "| k | N_points | n_presences | logLik | flagA_max_pdist | flagB_min_eval | flagB_cond | arc_pass / arc_total |",
  "|---:|---:|---:|---:|---:|---:|---:|:---|"
)
for (i in seq_len(nrow(summary_df))) {
  row <- summary_df[i, ]
  md_lines <- c(md_lines, sprintf(
    "| %s | %s | %s | %s | %s | %s | %s | %s |",
    fmt_int(row$k),
    fmt_int(row$N_points),
    fmt_int(row$n_presences),
    fmtn(row$logLik, 3),
    fmtn(row$flagA_max_pdist, 4),
    fmt_sci(row$flagB_min_eval, 3),
    fmt_sci(row$flagB_cond, 3),
    row[["arc_pass / arc_total"]]
  ))
}
writeLines(md_lines, md_path)

curve_df <- if (length(curve_rows) > 0) do.call(rbind, curve_rows) else NULL
if (!is.null(curve_df) && nrow(curve_df) > 0) {
  params <- if (!is.null(free_names)) free_names else unique(curve_df$param)
  params <- params[params %in% unique(curve_df$param)]
  cols <- grDevices::hcl.colors(length(ks), "Dark 3")
  names(cols) <- paste0("k=", ks)

  n_panels <- length(params)
  nc <- min(2L, n_panels)
  nr <- ceiling(n_panels / nc)
  grDevices::png(png_path, width = 520 * nc, height = 340 * nr, res = 110)
  op <- graphics::par(mfrow = c(nr, nc), mar = c(4, 4, 3, 1), oma = c(0, 0, 2, 0))
  ok <- tryCatch({
    for (j in seq_along(params)) {
      pn <- params[j]
      subp <- curve_df[curve_df$param == pn, , drop = FALSE]
      if (!nrow(subp)) next
      xvals <- subp$value_math[is.finite(subp$value_math)]
      yvals <- c(subp$loglik, subp$threshold)
      yvals <- yvals[is.finite(yvals)]
      if (!length(xvals) || !length(yvals)) next
      xlim <- range(xvals)
      ylim <- range(yvals)
      graphics::plot(NA, xlim = xlim, ylim = ylim,
                     xlab = "value_math", ylab = "profile log-likelihood",
                     main = pn)
      for (i in seq_along(ks)) {
        kk <- ks[i]
        subk <- subp[subp$k == kk, , drop = FALSE]
        if (!nrow(subk)) next
        ord <- order(subk$value_math)
        graphics::lines(subk$value_math[ord], subk$loglik[ord], col = cols[i], lwd = 2)
        thr <- subk$threshold[is.finite(subk$threshold)]
        if (length(thr) > 0) {
          graphics::abline(h = thr[1], col = cols[i], lty = 2)
        }
        opt <- subk$optimum[is.finite(subk$optimum)]
        if (length(opt) > 0) {
          graphics::abline(v = opt[1], col = cols[i], lty = 3)
        }
      }
      if (j == 1L) {
        graphics::legend("topright", legend = paste0("k=", ks), col = cols, lwd = 2, bty = "n", cex = 0.75)
      }
    }
    graphics::mtext(sprintf("%s — profile overlays by outlier dose", species), outer = TRUE, cex = 1.1)
    TRUE
  }, error = function(e) {
    message("Profile overlay PNG error: ", e$message)
    FALSE
  })
  graphics::par(op)
  if (grDevices::dev.cur() > 1L) grDevices::dev.off()
  if (!isTRUE(ok)) warning("No profile curves available or PNG generation failed.")
} else {
  warning("No profile curves available; skipping PNG generation.")
}

message("Wrote: ", csv_path)
message("Wrote: ", md_path)
if (file.exists(png_path)) {
  message("Wrote: ", png_path)
}

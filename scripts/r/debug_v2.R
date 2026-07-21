library(xsdm)
sp <- "Acanthisitta chloris"
env_csv_dir <- "/home/a474r867/scratch/xsdm_env_extraction_19"
years <- 1980:2020

sp_safe <- gsub(" ", "_", sp)
env_sp_dir <- file.path(env_csv_dir, sp_safe)
cat("Dir exists:", dir.exists(env_sp_dir), "\n")

# Labels
temp_labels <- paste0("T", 1:11, "_bio", sprintf("%02d", 1:11))
precip_labels <- paste0("P", 12:19, "_bio", sprintf("%02d", 12:19))
all_labels <- c(temp_labels, precip_labels)

# Read first CSV for occ
first_csv <- file.path(env_sp_dir, paste0(all_labels[1], ".csv"))
cat("First CSV:", first_csv, "\n")
cat("Exists:", file.exists(first_csv), "\n")
occ_raw <- read.csv(first_csv, stringsAsFactors=FALSE, check.names=FALSE)
cat("Dims:", dim(occ_raw), "\n")
cat("Colnames:", paste(head(names(occ_raw),6), collapse=", "), "\n")
occ_vec <- occ_raw$presence
cat("occ_vec length:", length(occ_vec), "presences:", sum(occ_vec==1), "\n")

# Load 2 vars
env_data_list <- list()
for (vl in all_labels[c(1,12)]) {
  csv <- file.path(env_sp_dir, paste0(vl, ".csv"))
  if (!file.exists(csv)) { cat("MISSING:", csv, "\n"); next }
  df <- read.csv(csv, stringsAsFactors=FALSE, check.names=FALSE)
  year_cols <- as.character(years)
  mat <- matrix(NA_real_, nrow=nrow(df), ncol=length(years))
  for (ti in seq_along(years)) {
    if (year_cols[ti] %in% names(df)) mat[,ti] <- df[[year_cols[ti]]]
  }
  env_data_list[[vl]] <- mat
  cat("Loaded:", vl, "NAs:", sum(is.na(mat)), "/", length(mat), "\n")
}

# Build array
var_labels <- all_labels[c(1,12)]
p <- 2
arr <- array(NA_real_, dim=c(nrow(occ_raw), length(years), p))
arr[,,1] <- env_data_list[[var_labels[1]]]
arr[,,2] <- env_data_list[[var_labels[2]]]
good <- apply(arr, 1, function(x) !any(is.na(x)))
cat("Good rows:", sum(good), "/", nrow(arr), "\n")
arr <- arr[good,,, drop=FALSE]
occ <- occ_vec[good]
cat("After filter: dim=", paste(dim(arr), collapse="x"), "pres:", sum(occ==1), "\n")

# Try optimize_likelihood
cat("\nTrying optimize_likelihood with num_starts=5...\n")
result <- tryCatch(
  optimize_likelihood(env_dat=arr, occ=occ, mask=NULL, num_starts=5, num_threads=1, parallel=FALSE, verbose=TRUE),
  error = function(e) { cat("ERROR:", conditionMessage(e), "\n"); NULL }
)
if (!is.null(result)) cat("SUCCESS: loglik=", result$best$loglik, "\n")

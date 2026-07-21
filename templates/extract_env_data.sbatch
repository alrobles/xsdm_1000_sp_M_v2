#!/bin/bash
#SBATCH --job-name=xsdm_extract
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=04:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/extract_%j.out
#SBATCH --error=logs/extract_%j.err

# ──────────────────────────────────────────────────────────────────────
# Two-phase data pre-extraction:
#   Phase 1: Consolidate all CSVs → species_occurrences.parquet
#   Phase 2: Extract 6 bioclim vars × 41 years → env_extracted.parquet
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
OCC_DIR="${HOME}/scratch/xsdm_occurrences"
BIOCLIM_DIR="${HOME}/scratch/era5-land/era5_bioclim/bioclim"
DATA_DIR="${HOME}/scratch/xsdm_data"

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}
export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"

mkdir -p "${DATA_DIR}" logs

echo "=== Phase 1: Consolidate occurrences ==="
echo "Start: $(date)"

apptainer exec --cleanenv \
    --bind "${HOME}/scratch:${HOME}/scratch" \
    "${SIF}" \
    Rscript "${REPO_ROOT}/scripts/r/01_consolidate_occurrences.R" \
      --occ_dir "${OCC_DIR}" \
      --output  "${DATA_DIR}/species_occurrences.parquet"

echo ""
echo "=== Phase 2: Extract environmental data ==="
echo "Start: $(date)"

apptainer exec --cleanenv \
    --bind "${HOME}/scratch:${HOME}/scratch" \
    "${SIF}" \
    Rscript "${REPO_ROOT}/scripts/r/02_extract_env_data.R" \
      --occ_parquet "${DATA_DIR}/species_occurrences.parquet" \
      --bioclim_dir "${BIOCLIM_DIR}" \
      --output      "${DATA_DIR}/env_extracted.parquet"

echo ""
echo "=== Done ==="
echo "End: $(date)"
ls -lh "${DATA_DIR}"/*.parquet

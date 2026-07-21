#!/bin/bash
# submit_pilot.sh — Install xsdm + submit pilot run for N species
#
# Usage (from repo root on HPC):
#   bash templates/submit_pilot.sh [--n 20] [--dry-run]
#
# Steps:
#   1. Select first N species from occurrence directory
#   2. Install xsdm from GitHub if not present
#   3. Create output/log directories
#   4. Submit Slurm array job (max 3 concurrent)

set -euo pipefail

N=20
DRY_RUN=false
OCC_DIR=/home/a474r867/scratch/xsdm_occurrences
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIF="${HOME}/geospatial-rserver/geospatial_latest.sif"
R_LIB="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"

while [[ $# -gt 0 ]]; do
  case $1 in
    --n) N="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "==================================================="
echo "xsdm Pilot Submission (${N} species)"
echo "Repo: ${REPO_DIR}"
echo "==================================================="

# ── 1. Species list ──
SPECIES_LIST="${REPO_DIR}/species_list.txt"
ls "${OCC_DIR}"/*.csv 2>/dev/null | head -"${N}" | while read -r f; do
  basename "$f" .csv
done > "${SPECIES_LIST}"

ACTUAL_N=$(wc -l < "${SPECIES_LIST}")
echo "Species list: ${ACTUAL_N} species"
cat -n "${SPECIES_LIST}"
echo ""

if [ "${ACTUAL_N}" -eq 0 ]; then
  echo "ERROR: No species CSVs found in ${OCC_DIR}"
  exit 1
fi

# ── 2. Install xsdm ──
echo "Checking xsdm installation..."
export APPTAINERENV_R_LIBS_USER="${R_LIB}"

XSDM_OK=$(apptainer exec --cleanenv \
  --bind /home/a474r867:/home/a474r867 \
  "${SIF}" \
  Rscript -e 'cat(requireNamespace("xsdm", quietly=TRUE))' 2>/dev/null || echo "FALSE")

if [ "$XSDM_OK" != "TRUE" ]; then
  echo "Installing xsdm from GitHub (xsdm-project/xsdm-devel)..."
  apptainer exec --cleanenv \
    --bind /home/a474r867:/home/a474r867 \
    "${SIF}" \
    Rscript -e "remotes::install_github('xsdm-project/xsdm-devel', upgrade='never', lib='${R_LIB}')"
  echo "xsdm installed."
else
  echo "xsdm already installed."
fi

# Also check numDeriv
NUMDERIV_OK=$(apptainer exec --cleanenv \
  --bind /home/a474r867:/home/a474r867 \
  "${SIF}" \
  Rscript -e 'cat(requireNamespace("numDeriv", quietly=TRUE))' 2>/dev/null || echo "FALSE")

if [ "$NUMDERIV_OK" != "TRUE" ]; then
  echo "Installing numDeriv..."
  apptainer exec --cleanenv \
    --bind /home/a474r867:/home/a474r867 \
    "${SIF}" \
    Rscript -e "install.packages('numDeriv', repos='https://cloud.r-project.org', lib='${R_LIB}')"
fi

# ── 3. Directories ──
mkdir -p /home/a474r867/scratch/xsdm_results
mkdir -p "${REPO_DIR}/logs"

# ── 4. Submit ──
echo ""
SBATCH_SCRIPT="${REPO_DIR}/templates/xsdm_species.sbatch"

if [ "$DRY_RUN" = true ]; then
  echo "[DRY RUN] Would submit:"
  echo "  cd ${REPO_DIR} && sbatch --array=1-${ACTUAL_N}%3 ${SBATCH_SCRIPT} ${SPECIES_LIST}"
else
  cd "${REPO_DIR}"
  JOB_ID=$(sbatch --array=1-${ACTUAL_N}%3 \
    "${SBATCH_SCRIPT}" \
    "${SPECIES_LIST}" 2>&1 | grep -oP '\d+')
  echo "Submitted job array: ${JOB_ID} (${ACTUAL_N} tasks, max 3 concurrent)"
  echo ""
  echo "Monitor:  squeue -j ${JOB_ID}"
  echo "Results:  ls /home/a474r867/scratch/xsdm_results/"
  echo "Logs:     ls ${REPO_DIR}/logs/xsdm_${JOB_ID}_*.out"
fi
echo "==================================================="

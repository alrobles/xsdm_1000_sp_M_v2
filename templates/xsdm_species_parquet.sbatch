#!/bin/bash
#SBATCH --job-name=xsdm_pq
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=06:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/xsdm_%A_%a.out
#SBATCH --error=logs/xsdm_%A_%a.err
# Parquet-mode species modeling: zero raster I/O per species
# Usage: sbatch --array=1-N%M xsdm_species_parquet.sbatch species_list.txt

set -euo pipefail

SPECIES_LIST="${1:?Usage: sbatch --array=1-N xsdm_species_parquet.sbatch species_list.txt}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

SPECIES_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SPECIES_LIST")
if [ -z "$SPECIES_NAME" ]; then
  echo "ERROR: No species at line ${SLURM_ARRAY_TASK_ID} in ${SPECIES_LIST}"
  exit 1
fi

echo "==================================================="
echo "Job ID:    ${SLURM_JOB_ID} (array ${SLURM_ARRAY_TASK_ID})"
echo "Species:   ${SPECIES_NAME}"
echo "Node:      $(hostname)"
echo "CPUs:      ${SLURM_CPUS_PER_TASK:-4}"
echo "Mode:      Parquet (pre-extracted)"
echo "Start:     $(date)"
echo "==================================================="

# ── Paths ──
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection.R"
DATA_DIR="${SCRATCH}/xsdm_data"

# ── Mitigation: copy script to tmp so git checkout cannot corrupt running jobs ──
SCRIPT_COPY=$(mktemp /tmp/xsdm_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

# ── Apptainer env vars ──
export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

# ── Run inside container (Parquet mode) ──
apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --occ_parquet "${DATA_DIR}/species_occurrences.parquet" \
      --env_parquet "${DATA_DIR}/env_extracted.parquet" \
      --output_dir "${SCRATCH}/xsdm_results" \
      --num_starts 25 \
      --num_threads "${SLURM_CPUS_PER_TASK:-4}"

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

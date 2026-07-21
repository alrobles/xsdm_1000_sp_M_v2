#!/bin/bash
#SBATCH --job-name=xsdm_v2_2var
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=06:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/v2_2var_%A_%a.out
#SBATCH --error=logs/v2_2var_%A_%a.err
# ──────────────────────────────────────────────────────────────────────
# Phase 2var: Fit 88 two-var L1 + boundary (one job per species)
# Usage: sbatch --array=1-N%M xsdm_v2_2var.sbatch species_list.txt
# ──────────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_LIST="${1:?Usage: sbatch --array=1-N xsdm_v2_2var.sbatch species_list.txt}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

SPECIES_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID:-}p" "$SPECIES_LIST")
if [ -z "$SPECIES_NAME" ]; then
  echo "ERROR: No species at line ${SLURM_ARRAY_TASK_ID:-} in ${SPECIES_LIST}"
  exit 1
fi

echo "==================================================="
echo "Pipeline v2 — Phase 2var"
echo "Job ID:    ${SLURM_JOB_ID} (array ${SLURM_ARRAY_TASK_ID:-})"
echo "Species:   ${SPECIES_NAME}"
echo "Node:      $(hostname)"
echo "CPUs:      ${SLURM_CPUS_PER_TASK:-4}"
echo "Start:     $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v2.R"

SCRIPT_COPY=$(mktemp /tmp/xsdm_v2_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
      --output_dir "${SCRATCH}/xsdm_results" \
      --phase 2var \
      --num_starts ${NUM_STARTS:-25} \
      --num_threads "${SLURM_CPUS_PER_TASK:-4}"

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

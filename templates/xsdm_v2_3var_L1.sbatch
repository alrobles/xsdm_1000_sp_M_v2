#!/bin/bash
#SBATCH --job-name=xsdm_v2_3var
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/v2_3var_%A_%a.out
#SBATCH --error=logs/v2_3var_%A_%a.err
# ──────────────────────────────────────────────────────────────────────
# Phase 3var_L1: Fit one three-var model (split mode)
# Usage: sbatch --array=1-N%M xsdm_v2_3var_L1.sbatch species_name
# ──────────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: sbatch --array=1-N xsdm_v2_3var_L1.sbatch 'Species name'}"
MODEL_INDEX="${SLURM_ARRAY_TASK_ID}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

echo "==================================================="
echo "Pipeline v2 — Phase 3var_L1"
echo "Job ID:    ${SLURM_JOB_ID} (array ${MODEL_INDEX})"
echo "Species:   ${SPECIES_NAME}"
echo "Model idx: ${MODEL_INDEX}"
echo "Node:      $(hostname)"
echo "Start:     $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v2.R"

SCRIPT_COPY=$(mktemp /tmp/xsdm_v2_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
      --output_dir "${SCRATCH}/xsdm_results" \
      --phase 3var_L1 \
      --model_index "${MODEL_INDEX}" \
      --num_starts 1500 \
      --num_threads "${SLURM_CPUS_PER_TASK:-4}"

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

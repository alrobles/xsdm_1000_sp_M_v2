#!/bin/bash
#SBATCH --job-name=xsdm_L1
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/L1_%A_%a.out
#SBATCH --error=logs/L1_%A_%a.err
# ─────────────────────────────────────────────────────────────────────
# Split mode Phase A: fit ONE L1 model for one mega-species.
# Array index = model index (1..23).
# Usage: sbatch --array=1-23 xsdm_L1_single.sbatch "Genus species"
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: sbatch --array=1-23 xsdm_L1_single.sbatch 'Genus species'}"
MODEL_INDEX="${SLURM_ARRAY_TASK_ID}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

echo "==================================================="
echo "Job ID:    ${SLURM_JOB_ID} (model ${MODEL_INDEX}/23)"
echo "Species:   ${SPECIES_NAME}"
echo "Node:      $(hostname)"
echo "Phase:     L1 (single model)"
echo "Start:     $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection.R"

SCRIPT_COPY=$(mktemp /tmp/xsdm_L1_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction" \
      --output_dir "${SCRATCH}/xsdm_results" \
      --phase L1 \
      --model_index "${MODEL_INDEX}" \
      --num_starts 25 \
      --num_threads "${SLURM_CPUS_PER_TASK:-4}"

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

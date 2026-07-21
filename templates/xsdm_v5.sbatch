#!/bin/bash
#SBATCH --job-name=xsdm_v5
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --output=/home/a474r867/scratch/logs/xsdm_v5_%A_%a.out
#SBATCH --error=/home/a474r867/scratch/logs/xsdm_v5_%A_%a.err
# ──────────────────────────────────────────────────────────────────
# xSDM v5 — Job array + absolute paths (no SLURM_SUBMIT_DIR)
#
# Usage:
#   L1: sbatch --array=1-88 xsdm_v5.sbatch "Species" L1_model
#   L2: sbatch xsdm_v5.sbatch "Species" L2
#   L3: sbatch xsdm_v5.sbatch "Species" L3
#   L4: sbatch xsdm_v5.sbatch "Species" L4
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: sbatch xsdm_v5.sbatch <species> <stage> [tau_method] [output_dir]}"
STAGE="${2:?Usage: sbatch xsdm_v5.sbatch <species> <stage> [tau_method] [output_dir]}"
TAU_METHOD="${3:-tau_raw}"

# ── FIX 1: Absolute paths (no SLURM_SUBMIT_DIR dependency) ──
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v5.R"

OUTPUT_DIR="${4:-${SCRATCH}/xsdm_1000_sp}"

# ── Job array: SLURM_ARRAY_TASK_ID becomes model_index ──
MODEL_INDEX=""
if [ -n "${SLURM_ARRAY_TASK_ID:-}" ] && [ "${SLURM_ARRAY_TASK_ID}" -gt 0 ] 2>/dev/null; then
    MODEL_INDEX="${SLURM_ARRAY_TASK_ID}"
fi

echo "==================================================="
echo "xSDM v5 | ${SPECIES_NAME} | stage=${STAGE}"
[ -n "$MODEL_INDEX" ] && echo "Array task: ${SLURM_ARRAY_TASK_ID} / ${SLURM_ARRAY_TASK_MAX:-?}"
echo "Node: $(hostname) | CPUs: ${SLURM_CPUS_PER_TASK:-8}"
echo "Start: $(date)"
echo "==================================================="

mkdir -p "${SCRATCH}/logs"

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-8}
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

MODEL_IDX_ARG=""
[ -n "$MODEL_INDEX" ] && MODEL_IDX_ARG="--model_index ${MODEL_INDEX}"

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "${REPO_ROOT}:${REPO_ROOT}:ro" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
      --output_dir "${OUTPUT_DIR}" \
      --stage "${STAGE}" \
      --num_starts 40 \
      --num_threads "${SLURM_CPUS_PER_TASK:-8}" \
      --tau_method "${TAU_METHOD}" \
      ${MODEL_IDX_ARG}

EXIT_CODE=$?
echo "==================================================="
echo "Finished: $(date) | Exit: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

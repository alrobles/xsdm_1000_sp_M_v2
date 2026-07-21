#!/bin/bash
#SBATCH --job-name=xsdm_v4
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --output=/home/a474r867/scratch/logs/xsdm_v4_%j.out
#SBATCH --error=/home/a474r867/scratch/logs/xsdm_v4_%j.err
# ──────────────────────────────────────────────────────────────────────
# xSDM v4 — Single job (model or stage)
# Usage:
#   sbatch xsdm_v4.sbatch "Species name" L1_model 42
#   sbatch xsdm_v4.sbatch "Species name" L2
#   sbatch xsdm_v4.sbatch "Species name" L3
#   sbatch xsdm_v4.sbatch "Species name" L4
# ──────────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: sbatch xsdm_v4.sbatch <species> <stage> [model_index]}"
STAGE="${2:?Usage: sbatch xsdm_v4.sbatch <species> <stage> [model_index]}"
MODEL_INDEX="${3:-}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

echo "==================================================="
echo "xSDM v4 | ${SPECIES_NAME} | stage=${STAGE}"
[ -n "$MODEL_INDEX" ] && echo "Model index: ${MODEL_INDEX}"
echo "Node: $(hostname) | CPUs: ${SLURM_CPUS_PER_TASK:-8}"
echo "Start: $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v4.R"

SCRIPT_COPY=$(mktemp /tmp/xsdm_v4_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

mkdir -p "${SCRATCH}/logs"

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-8}
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

MODEL_IDX_ARG=""
[ -n "$MODEL_INDEX" ] && MODEL_IDX_ARG="--model_index ${MODEL_INDEX}"

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
      --output_dir "${SCRATCH}/xsdm_1000_sp" \
      --stage "${STAGE}" \
      --num_starts 40 \
      --num_threads "${SLURM_CPUS_PER_TASK:-8}" \
      ${MODEL_IDX_ARG}

EXIT_CODE=$?
echo "==================================================="
echo "Finished: $(date) | Exit: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

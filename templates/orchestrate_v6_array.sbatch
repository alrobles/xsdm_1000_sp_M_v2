#!/bin/bash
#SBATCH --job-name=v6_orch_arr
#SBATCH --partition=kbs
#SBATCH --time=7-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --account=kbs
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v6_array_%A_%a.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v6_array_%A_%a.err

# xsdm v6 array launcher — one species per array task
#
# Usage:
#   sbatch --array=1-1%1 templates/orchestrate_v6_array.sbatch
#   sbatch --array=1-100%10 templates/orchestrate_v6_array.sbatch
#
# Optional env overrides:
#   SPECIES_LIST=/path/to/species_list.txt   # default: repo/species_list.txt
#   MODEL_SET=algorithm2_6var                # default no-filter 23-model set
#   APPLY_PREFILTER=false
#   DROP_TOP_K=0
#   NUM_STARTS=50
#
# Each task reads line SLURM_ARRAY_TASK_ID from the species list and launches
# the standard per-species orchestrator.

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
ORCHESTRATOR="${REPO_ROOT}/scripts/orchestrate_v6.sh"
SPECIES_LIST="${SPECIES_LIST:-${REPO_ROOT}/species_list.txt}"

export MODEL_SET="${MODEL_SET:-algorithm2_6var}"
export APPLY_PREFILTER="${APPLY_PREFILTER:-false}"
export DROP_TOP_K="${DROP_TOP_K:-0}"
export NUM_STARTS="${NUM_STARTS:-50}"
export APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER}"
export APPTAINERENV_DROP_TOP_K="${DROP_TOP_K}"
export APPTAINERENV_MODEL_SET="${MODEL_SET}"

chmod +x "${ORCHESTRATOR}"
mkdir -p "${REPO_ROOT}/logs"

if [[ -z "${SLURM_ARRAY_TASK_ID:-}" ]]; then
  echo "ERROR: SLURM_ARRAY_TASK_ID is not set" >&2
  exit 1
fi

species="$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SPECIES_LIST}" | tr -d '\r')"
species="$(printf '%s' "${species}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

if [[ -z "${species}" || "${species}" == \#* ]]; then
  echo "INFO: empty/blank species at line ${SLURM_ARRAY_TASK_ID}; skipping"
  exit 0
fi

echo "Array task ${SLURM_ARRAY_TASK_ID}/${SLURM_ARRAY_TASK_MAX}: ${species}"
echo "SPECIES_LIST=${SPECIES_LIST}"
echo "MODEL_SET=${MODEL_SET} APPLY_PREFILTER=${APPLY_PREFILTER} DROP_TOP_K=${DROP_TOP_K} NUM_STARTS=${NUM_STARTS}"

bash "${ORCHESTRATOR}" --species "${species}"

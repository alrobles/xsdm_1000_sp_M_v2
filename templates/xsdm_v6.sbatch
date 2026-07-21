#!/bin/bash
# xSDM v6 — DEFINITIVE pipeline (Algorithm2 aligned)
# 6 variables, 23 models, tau = (max_p+1)*log(n), 1500 starts
#
# Single-species mode:
#   sbatch xsdm_v6.sbatch "Oryctolagus cuniculus"
#
# Array mode (all species):
#   sbatch --array=1-1749%200 xsdm_v6.sbatch
#
#SBATCH --job-name=xsdm_v6
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --account=kbs
#SBATCH --output=/home/a474r867/scratch/logs/xsdm_v6_%A_%a.out
#SBATCH --error=/home/a474r867/scratch/logs/xsdm_v6_%A_%a.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
V6_SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v6.R"
SPECIES_LIST="${REPO_ROOT}/species_list_v2.txt"

NUM_STARTS="${NUM_STARTS:-1500}"
NUM_THREADS="${NUM_THREADS:-${SLURM_CPUS_PER_TASK:-4}}"

# Determine species: CLI arg (single) or array index
if [ -n "${1:-}" ]; then
    SPECIES="$1"
elif [ -n "${SLURM_ARRAY_TASK_ID:-}" ]; then
    SPECIES=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SPECIES_LIST}")
    if [ -z "${SPECIES}" ]; then
        echo "ERROR: No species at line ${SLURM_ARRAY_TASK_ID}" >&2
        exit 1
    fi
else
    echo "ERROR: Provide species name as argument or use --array" >&2
    exit 1
fi

echo "==========================================================="
echo "xSDM v6 — Algorithm2 aligned (6 vars, 23 models, tau corrected)"
echo "==========================================================="
echo "Job ID:      ${SLURM_JOB_ID:-local}"
echo "Array task:  ${SLURM_ARRAY_TASK_ID:-N/A}"
echo "Node:        $(hostname)"
echo "CPUs:        ${NUM_THREADS}"
echo "Memory:      ${SLURM_MEM_PER_NODE:-32G}"
echo "Species:     ${SPECIES}"
echo "Starts:      ${NUM_STARTS}"
echo "Start:       $(date)"
echo "==========================================================="

export APPTAINERENV_OMP_NUM_THREADS=${NUM_THREADS}
export APPTAINERENV_MC_CORES=1
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

mkdir -p "${SCRATCH}/logs"
mkdir -p "${SCRATCH}/xsdm_results_v6"

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript "${V6_SCRIPT}" \
        --species "${SPECIES}" \
        --num_starts "${NUM_STARTS}" \
        --num_threads "${NUM_THREADS}" \
        --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
        --output_dir "${SCRATCH}/xsdm_results_v6"

EXIT_CODE=$?
echo "==========================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==========================================================="
exit ${EXIT_CODE}

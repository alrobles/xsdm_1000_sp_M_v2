#!/bin/bash
# Single-species xSDM v3 run on the sixhour partition (6h wall, starts quickly).
# Used for the corrected-tau example (default species has ~1000 presences).
#   Usage: NUM_STARTS=25 NUM_THREADS=48 sbatch xsdm_v3_single_sixhour.sbatch "Petaurus australis"
#SBATCH --job-name=xsdm_v3_single
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=128G
#SBATCH --cpus-per-task=48
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/scratch/logs/xsdm_v3_single_%j.out
#SBATCH --error=/home/a474r867/scratch/logs/xsdm_v3_single_%j.err

set -euo pipefail

SPECIES="${1:-Petaurus australis}"
NUM_STARTS="${NUM_STARTS:-25}"
NUM_THREADS="${NUM_THREADS:-48}"

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
V3_SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v3.R"

echo "==========================================================="
echo "xSDM v3 — Single Species (sixhour)"
echo "==========================================================="
echo "Job ID:      ${SLURM_JOB_ID}"
echo "Node:        $(hostname)"
echo "CPUs:        ${SLURM_CPUS_PER_TASK}"
echo "Memory:      128G"
echo "Species:     ${SPECIES}"
echo "Starts:      ${NUM_STARTS}"
echo "Threads:     ${NUM_THREADS}"
echo "Start:       $(date)"
echo "==========================================================="

export APPTAINERENV_OMP_NUM_THREADS=${NUM_THREADS}
export APPTAINERENV_MC_CORES=1
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

mkdir -p "${SCRATCH}/logs"
mkdir -p "${SCRATCH}/xsdm_results_v3"

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript "${V3_SCRIPT}" \
        --species "${SPECIES}" \
        --num_starts "${NUM_STARTS}" \
        --num_threads "${NUM_THREADS}" \
        --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
        --output_dir "${SCRATCH}/xsdm_results_v3"

EXIT_CODE=$?
echo "==========================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==========================================================="
exit ${EXIT_CODE}

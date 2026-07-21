#!/bin/bash
#SBATCH --job-name=xsdm_parallel
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=12:00:00
#SBATCH --mem=128G
#SBATCH --cpus-per-task=40
#SBATCH --nodes=1
#SBATCH --output=logs/xsdm_parallel_%j.out
#SBATCH --error=logs/xsdm_parallel_%j.err
# ────────────────────────────────────────────────────────────────────────────
# xSDM v2 Parallel — single-node multi-species execution
# Replaces the 1100+ array-job approach. Runs N species concurrently
# inside one Slurm allocation using R's mclapply.
#
# Usage:
#   sbatch xsdm_parallel.sbatch species_list_pilot10.txt
#   sbatch xsdm_parallel.sbatch species_list_v2.txt
#
#   export NUM_STARTS=500 SPECIES_PER_BATCH=10 THREADS_PER_SPECIES=3
#   sbatch xsdm_parallel.sbatch species_list.txt
#
#   # Slice mode: process species 101-200
#   export BATCH_OFFSET=100 BATCH_COUNT=100
#   sbatch xsdm_parallel.sbatch species_list_v2.txt
# ────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_LIST="${1:?Usage: sbatch xsdm_parallel.sbatch <species_list.txt>}"

# ── Configurable parameters (via env vars, with defaults) ──────────────────
NUM_STARTS="${NUM_STARTS:-500}"
SPECIES_PER_BATCH="${SPECIES_PER_BATCH:-8}"
THREADS_PER_SPECIES="${THREADS_PER_SPECIES:-3}"
PHASE="${PHASE:-2var}"
BATCH_OFFSET="${BATCH_OFFSET:-0}"
BATCH_COUNT="${BATCH_COUNT:-}"

# ── Paths ───────────────────────────────────────────────────────────────────
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
WRAPPER_SCRIPT="${REPO_ROOT}/scripts/r/xsdm_parallel_wrapper.R"

echo "==========================================================="
echo "xSDM v2 — Parallel Single-Node Execution"
echo "==========================================================="
echo "Job ID:      ${SLURM_JOB_ID}"
echo "Node:        $(hostname)"
echo "CPUs:        ${SLURM_CPUS_PER_TASK}"
echo "Memory:      128G"
echo "Species list: ${SPECIES_LIST}"
echo "Starts/model: ${NUM_STARTS}"
echo "Concurrent:   ${SPECIES_PER_BATCH} species × ${THREADS_PER_SPECIES} threads"
echo "Phase:        ${PHASE}"
if [ -n "${BATCH_COUNT}" ]; then
  echo "Batch slice:  offset=${BATCH_OFFSET} count=${BATCH_COUNT}"
fi
echo "Start:       $(date)"
echo "==========================================================="

# ── Verify inputs ───────────────────────────────────────────────────────────
if [ ! -f "${REPO_ROOT}/${SPECIES_LIST}" ] && [ ! -f "${SPECIES_LIST}" ]; then
  echo "ERROR: Species list not found: ${SPECIES_LIST}"
  exit 1
fi

if [ ! -f "${WRAPPER_SCRIPT}" ]; then
  echo "ERROR: Wrapper script not found: ${WRAPPER_SCRIPT}"
  exit 1
fi

# ── Apptainer env ───────────────────────────────────────────────────────────
export APPTAINERENV_OMP_NUM_THREADS=${THREADS_PER_SPECIES}
export APPTAINERENV_MC_CORES=${SPECIES_PER_BATCH}
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

# ── Build Rscript args ──────────────────────────────────────────────────────
R_ARGS=(
  "--species_list" "${SPECIES_LIST}"
  "--num_starts" "${NUM_STARTS}"
  "--species_per_batch" "${SPECIES_PER_BATCH}"
  "--threads_per_species" "${THREADS_PER_SPECIES}"
  "--phase" "${PHASE}"
  "--repo_root" "${REPO_ROOT}"
  "--env_csv_dir" "${SCRATCH}/xsdm_env_extraction_19"
  "--output_dir" "${SCRATCH}/xsdm_results"
  "--occ_dir" "${SCRATCH}/xsdm_occurrences"
)

if [ -n "${BATCH_COUNT}" ]; then
  R_ARGS+=("--batch_offset" "${BATCH_OFFSET}" "--batch_count" "${BATCH_COUNT}")
fi

# ── Execute ─────────────────────────────────────────────────────────────────
apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript "${WRAPPER_SCRIPT}" "${R_ARGS[@]}"

EXIT_CODE=$?
echo "==========================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==========================================================="
exit ${EXIT_CODE}

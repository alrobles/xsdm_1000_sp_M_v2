#!/bin/bash
# ──────────────────────────────────────────────────────────────────
# xSDM v6 — Local runner for reumanlab flotilla (Apptainer SIF, no Slurm)
#
# Runs the full v6 pipeline (L1 → L2 → L3 → well-behaved → L4 → re-scan
# → profile) for ONE species in a single R process, using the
# self-contained scripts/r/xsdm_model_selection_v6.R.
#
# Uses xsdm_latest.sif for reproducibility (same image as KU HPC).
# Replaces the abandoned v5 88-model pipeline.
#
# Usage:
#   ./run_xsdm_v6_local.sh "Breviceps montanus"
#   ./run_xsdm_v6_local.sh "Breviceps montanus" 1500 8
#                           <species>            <starts> <threads>
#
# Env overrides (optional):
#   SIF, SCRATCH, ENV_CSV_DIR, OUTPUT_DIR, NUM_STARTS, NUM_THREADS
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: $0 <species> [num_starts] [num_threads]}"
NUM_STARTS="${2:-${NUM_STARTS:-1500}}"

# ── Paths ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v6.R"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
SCRATCH="${SCRATCH:-${HOME}/scratch}"
ENV_CSV_DIR="${ENV_CSV_DIR:-${SCRATCH}/xsdm_env_extraction_19}"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRATCH}/xsdm_results_v6}"

# ── Threads: default = all cores − 1 (single species uses the whole box) ──
NPROC=$(nproc)
NUM_THREADS="${3:-${NUM_THREADS:-$(( NPROC > 4 ? NPROC - 1 : NPROC ))}}"

# ── Validate ──
if [ ! -f "${SIF}" ]; then
    echo "ERROR: SIF not found at ${SIF}" >&2
    exit 1
fi
if [ ! -f "${SCRIPT}" ]; then
    echo "ERROR: v6 R script not found at ${SCRIPT}" >&2
    exit 1
fi

SP_SAFE="${SPECIES_NAME// /_}"
if [ ! -d "${ENV_CSV_DIR}/${SP_SAFE}" ]; then
    echo "ERROR: env CSV dir not found: ${ENV_CSV_DIR}/${SP_SAFE}" >&2
    exit 1
fi

mkdir -p "${OUTPUT_DIR}" "${SCRATCH}/logs" /tmp/xsdm

echo "==================================================="
echo "xSDM v6 LOCAL | ${SPECIES_NAME}"
echo "Starts: ${NUM_STARTS} | Threads: ${NUM_THREADS}"
echo "Node: $(hostname) | Cores: ${NPROC}"
echo "SIF: ${SIF}"
echo "Env CSV: ${ENV_CSV_DIR}/${SP_SAFE}"
echo "Output: ${OUTPUT_DIR}/${SP_SAFE}"
echo "Start: $(date)"
echo "==================================================="

export APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}"
export APPTAINERENV_MC_CORES=1
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "${REPO_ROOT}:${REPO_ROOT}:ro" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT}" \
        --species "${SPECIES_NAME}" \
        --env_csv_dir "${ENV_CSV_DIR}" \
        --output_dir "${OUTPUT_DIR}" \
        --num_starts "${NUM_STARTS}" \
        --num_threads "${NUM_THREADS}"

EXIT_CODE=$?
echo "==================================================="
echo "Finished: $(date) | Exit: ${EXIT_CODE}"
echo "Report: ${OUTPUT_DIR}/${SP_SAFE}/model_selection_report.md"
echo "==================================================="
exit ${EXIT_CODE}

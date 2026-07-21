#!/bin/bash
# ──────────────────────────────────────────────────────────────────
# xSDM v5 — Local runner for reumanlab flotilla (Apptainer SIF, no Slurm)
#
# Uses xsdm_latest.sif for reproducibility (same image as KU HPC).
#
# Usage:
#   L1 parallel: ./run_xsdm_v5_local.sh "Species" L1_model tau_raw all
#   L1 single:   ./run_xsdm_v5_local.sh "Species" L1_model tau_raw 42
#   L2:          ./run_xsdm_v5_local.sh "Species" L2 [tau_method]
#   L3:          ./run_xsdm_v5_local.sh "Species" L3 [tau_method]
#   L4:          ./run_xsdm_v5_local.sh "Species" L4 [tau_method]
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: $0 <species> <stage> [tau_method] [model_index|all]}"
STAGE="${2:?Usage: $0 <species> <stage> [tau_method] [model_index|all]}"
TAU_METHOD="${3:-tau_raw}"
MODEL_INDEX="${4:-}"

# ── Paths ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection_v5.R"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="${HOME}/scratch"

# ── Validate SIF ──
if [ ! -f "${SIF}" ]; then
    echo "ERROR: SIF not found at ${SIF}"
    exit 1
fi

# ── Create dirs ──
mkdir -p "${SCRATCH}/logs" "${SCRATCH}/xsdm_1000_sp" /tmp/xsdm

# ── CPUs ──
NPROC=$(nproc)
MAX_JOBS=$((NPROC > 4 ? NPROC - 1 : NPROC))

run_single() {
    local idx="$1"
    local threads="$2"
    local idx_arg=""
    [ -n "$idx" ] && idx_arg="--model_index $idx"

    export APPTAINERENV_OMP_NUM_THREADS=${threads}

    apptainer exec --cleanenv \
        --bind "${SCRATCH}:${SCRATCH}" \
        --bind "${REPO_ROOT}:${REPO_ROOT}:ro" \
        --bind "/tmp:/tmp" \
        "${SIF}" \
        Rscript "${SCRIPT}" \
            --species "${SPECIES_NAME}" \
            --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
            --output_dir "${SCRATCH}/xsdm_1000_sp" \
            --stage "${STAGE}" \
            --num_starts 40 \
            --num_threads "${threads}" \
            --tau_method "${TAU_METHOD}" \
            ${idx_arg}
}

echo "==================================================="
echo "xSDM v5 LOCAL | ${SPECIES_NAME} | stage=${STAGE}"
echo "tau_method=${TAU_METHOD} | model_index=${MODEL_INDEX:-none}"
echo "Node: $(hostname) | Max jobs: ${MAX_JOBS}"
echo "SIF: ${SIF}"
echo "Start: $(date)"
echo "==================================================="

if [ "${MODEL_INDEX}" = "all" ] && [ "${STAGE}" = "L1_model" ]; then
    # ── Parallel L1: N jobs × 1 thread each ──
    echo "Running L1 models 1-88, ${MAX_JOBS} parallel × 1 thread each..."
    export -f run_single
    export SIF SCRIPT SCRATCH REPO_ROOT SPECIES_NAME STAGE TAU_METHOD
    seq 1 88 | parallel -j "${MAX_JOBS}" run_single {} 1
elif [ "${STAGE}" = "L1_model" ] && [ -n "${MODEL_INDEX}" ]; then
    run_single "${MODEL_INDEX}" "${MAX_JOBS}"
elif [ "${STAGE}" = "L1_model" ]; then
    echo "Running L1 models 1-88 sequentially..."
    for i in $(seq 1 88); do
        echo "--- Model ${i}/88 ---"
        run_single "${i}" "${MAX_JOBS}"
    done
else
    # ── L2/L3/L4: single job, all CPUs ──
    run_single "" "${MAX_JOBS}"
fi

EXIT_CODE=$?
echo "==================================================="
echo "Finished: $(date) | Exit: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

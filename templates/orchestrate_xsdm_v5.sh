#!/bin/bash
# ──────────────────────────────────────────────────────────────────
# xSDM v5 — Multi-species orchestrator for reumanlab flotilla
#
# Usage:
#   ./orchestrate_xsdm_v5.sh species_list.txt [tau_method] [max_parallel]
#
# Runs the full L1→L2→L3→L4 pipeline for each species.
# Species run in parallel, stages are sequential per species.
# Uses GNU parallel for concurrency control.
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_FILE="${1:?Usage: $0 <species_list.txt> [tau_method] [max_parallel]}"
TAU_METHOD="${2:-tau_raw}"
MAX_PARALLEL="${3:-4}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUNNER="${SCRIPT_DIR}/run_xsdm_v5_local.sh"
SCRATCH="${HOME}/scratch"
LOG_DIR="${SCRATCH}/logs/xsdm_v5"
mkdir -p "${LOG_DIR}"

# Count species
TOTAL=$(wc -l < "${SPECIES_FILE}")
echo "==================================================="
echo "xSDM v5 Orchestrator"
echo "Species file: ${SPECIES_FILE} (${TOTAL} species)"
echo "Tau method: ${TAU_METHOD}"
echo "Max parallel: ${MAX_PARALLEL}"
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "==================================================="

run_species() {
    local sp="$1"
    local sp_safe="${sp// /_}"
    local log="${LOG_DIR}/${sp_safe}_${TAU_METHOD}.log"
    local start_time=$(date +%s)

    echo "[START] ${sp} | $(date)" | tee -a "${log}"

    # L1: all 88 models
    echo "  [L1] ${sp}" | tee -a "${log}"
    if ! bash "${RUNNER}" "${sp}" L1_model "${TAU_METHOD}" all >> "${log}" 2>&1; then
        echo "  [FAIL] L1 failed for ${sp}" | tee -a "${log}"
        return 1
    fi
    touch "${SCRATCH}/xsdm_1000_sp/${sp_safe}/phase1_results/.L1_done"

    # L2: boundary expansion
    echo "  [L2] ${sp}" | tee -a "${log}"
    if ! bash "${RUNNER}" "${sp}" L2 "${TAU_METHOD}" >> "${log}" 2>&1; then
        echo "  [FAIL] L2 failed for ${sp}" | tee -a "${log}"
        return 1
    fi
    touch "${SCRATCH}/xsdm_1000_sp/${sp_safe}/phase1_results/.L2_done"

    # L3: well-behaved scan
    echo "  [L3] ${sp}" | tee -a "${log}"
    if ! bash "${RUNNER}" "${sp}" L3 "${TAU_METHOD}" >> "${log}" 2>&1; then
        echo "  [FAIL] L3 failed for ${sp}" | tee -a "${log}"
        return 1
    fi
    touch "${SCRATCH}/xsdm_1000_sp/${sp_safe}/phase1_results/.L3_done"

    # L4: final
    echo "  [L4] ${sp}" | tee -a "${log}"
    if ! bash "${RUNNER}" "${sp}" L4 "${TAU_METHOD}" >> "${log}" 2>&1; then
        echo "  [FAIL] L4 failed for ${sp}" | tee -a "${log}"
        return 1
    fi
    touch "${SCRATCH}/xsdm_1000_sp/${sp_safe}/phase1_results/.L4_done"

    local elapsed=$(( $(date +%s) - start_time ))
    echo "[DONE] ${sp} | ${elapsed}s | $(date)" | tee -a "${log}"
}

export -f run_species
export RUNNER TAU_METHOD SCRATCH LOG_DIR

cat "${SPECIES_FILE}" | parallel -j "${MAX_PARALLEL}" run_species

echo "==================================================="
echo "All ${TOTAL} species complete | $(date)"
echo "==================================================="

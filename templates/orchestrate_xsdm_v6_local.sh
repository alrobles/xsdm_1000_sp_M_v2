#!/bin/bash
# ──────────────────────────────────────────────────────────────────
# xSDM v6 — Multi-species orchestrator for reumanlab flotilla (no Slurm)
#
# Runs the full v6 pipeline for each species. Species run in parallel
# via GNU parallel; each species' pipeline runs in a single R process
# (L1 → L2 → L3 → L4 → profile) inside the Apptainer SIF.
#
# Replaces the abandoned v5 88-model orchestrator.
#
# Usage:
#   ./orchestrate_xsdm_v6_local.sh species_list.txt [max_parallel] [num_starts]
#
# By default threads-per-species = floor(nproc / max_parallel) so the
# box is not over-subscribed (max_parallel × threads ≈ nproc).
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_FILE="${1:?Usage: $0 <species_list.txt> [max_parallel] [num_starts]}"
MAX_PARALLEL="${2:-4}"
NUM_STARTS="${3:-1500}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="${SCRIPT_DIR}/run_xsdm_v6_local.sh"
SCRATCH="${SCRATCH:-${HOME}/scratch}"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRATCH}/xsdm_results_v6}"
LOG_DIR="${SCRATCH}/logs/xsdm_v6"
mkdir -p "${LOG_DIR}" "${OUTPUT_DIR}"

if [ ! -f "${SPECIES_FILE}" ]; then
    echo "ERROR: species list not found: ${SPECIES_FILE}" >&2
    exit 1
fi

# ── Divide cores across concurrent species ──
NPROC=$(nproc)
THREADS_PER_SP=$(( NPROC / MAX_PARALLEL ))
[ "${THREADS_PER_SP}" -lt 1 ] && THREADS_PER_SP=1

TOTAL=$(grep -cve '^[[:space:]]*$' "${SPECIES_FILE}")
echo "==================================================="
echo "xSDM v6 LOCAL Orchestrator"
echo "Species file: ${SPECIES_FILE} (${TOTAL} species)"
echo "Max parallel: ${MAX_PARALLEL} | Threads/species: ${THREADS_PER_SP}"
echo "Starts: ${NUM_STARTS}"
echo "Node: $(hostname) | Cores: ${NPROC}"
echo "Output: ${OUTPUT_DIR}"
echo "Start: $(date)"
echo "==================================================="

run_species() {
    local sp="$1"
    [ -z "${sp// /}" ] && return 0
    local sp_safe="${sp// /_}"
    local log="${LOG_DIR}/${sp_safe}.log"
    local start_time
    start_time=$(date +%s)

    echo "[START] ${sp} | $(date)"
    if NUM_THREADS="${THREADS_PER_SP}" bash "${RUNNER}" "${sp}" "${NUM_STARTS}" "${THREADS_PER_SP}" > "${log}" 2>&1; then
        local elapsed=$(( $(date +%s) - start_time ))
        echo "[DONE] ${sp} | ${elapsed}s"
    else
        echo "[FAIL] ${sp} — see ${log}"
        return 1
    fi
}

export -f run_species
export RUNNER NUM_STARTS THREADS_PER_SP LOG_DIR

# --keep-order off; report failures but don't abort the whole batch
grep -ve '^[[:space:]]*$' "${SPECIES_FILE}" \
  | parallel --will-cite -j "${MAX_PARALLEL}" run_species {} || true

echo "==================================================="
echo "All ${TOTAL} species processed | $(date)"
echo "Results in: ${OUTPUT_DIR}"
echo "==================================================="

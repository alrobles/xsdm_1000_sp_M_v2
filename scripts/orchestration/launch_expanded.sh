#!/bin/bash
# launch_expanded.sh — Two-phase pipeline for 767 failed species
#
# Phase 1: Extract 19 bioclim variables for all failed species
# Phase 2: Run expanded model selection (1-4 var models)
#
# Usage:
#   bash scripts/orchestration/launch_expanded.sh [--extract-only|--model-only|--both]
#   bash scripts/orchestration/launch_expanded.sh --generate-list

set -euo pipefail

SCRATCH="/home/a474r867/scratch"
REPO_ROOT="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
RESULTS_DIR="${SCRATCH}/xsdm_results"
EXPANDED_DIR="${SCRATCH}/xsdm_results_expanded"
ENV19_DIR="${SCRATCH}/xsdm_env_extraction_19"
LOGS_DIR="${SCRATCH}/xsdm_results/logs"
FAILED_LIST="${REPO_ROOT}/species_failed_767.txt"
MAX_EXTRACT=200  # concurrent extraction tasks
MAX_MODEL=50     # concurrent model tasks

mkdir -p "${LOGS_DIR}" "${EXPANDED_DIR}"

MODE="${1:---both}"

# ── Generate list of failed species ──────────────────────────────────
generate_failed_list() {
    echo "Generating list of failed species (no_well_behaved_model)..."
    > "${FAILED_LIST}"

    for rds in "${RESULTS_DIR}"/*/model_results.rds; do
        sp_dir=$(dirname "$rds")
        sp_name=$(basename "$sp_dir" | tr '_' ' ')

        status=$(Rscript -e "
            r <- readRDS('${rds}')
            cat(r\$status)
        " 2>/dev/null)

        if [ "$status" = "no_well_behaved_model" ]; then
            echo "$sp_name" >> "${FAILED_LIST}"
        fi
    done

    n=$(wc -l < "${FAILED_LIST}")
    echo "Found ${n} failed species → ${FAILED_LIST}"
}

# ── Phase 1: Extract 19 bioclim vars ────────────────────────────────
phase_extract() {
    local n=$(wc -l < "${FAILED_LIST}")
    echo "Phase 1: Extracting 19 bioclim vars for ${n} species (max ${MAX_EXTRACT} concurrent)"

    # Filter out species that already have extraction done
    EXTRACT_LIST=$(mktemp /tmp/extract_needed_XXXXXX.txt)
    while IFS= read -r sp; do
        sp_safe=$(echo "$sp" | tr ' ' '_')
        if [ ! -f "${ENV19_DIR}/${sp_safe}/P19_bio19.csv" ]; then
            echo "$sp" >> "${EXTRACT_LIST}"
        fi
    done < "${FAILED_LIST}"

    n_needed=$(wc -l < "${EXTRACT_LIST}")
    echo "  ${n_needed} need extraction ($(( n - n_needed )) already done)"

    if [ "$n_needed" -gt 0 ]; then
        cd "${REPO_ROOT}"
        JOB_ID=$(sbatch --parsable \
            --array="1-${n_needed}%${MAX_EXTRACT}" \
            templates/extract_env_19var.sbatch "${EXTRACT_LIST}")
        echo "  Submitted extraction: job ${JOB_ID}"
        echo "  Monitor: squeue -j ${JOB_ID}"
    else
        echo "  All extractions complete!"
    fi
    rm -f "${EXTRACT_LIST}"
}

# ── Phase 2: Expanded model selection ────────────────────────────────
phase_model() {
    local n=$(wc -l < "${FAILED_LIST}")
    echo "Phase 2: Expanded model selection for ${n} species (max ${MAX_MODEL} concurrent)"

    # Filter out already-completed
    MODEL_LIST=$(mktemp /tmp/model_needed_XXXXXX.txt)
    while IFS= read -r sp; do
        sp_safe=$(echo "$sp" | tr ' ' '_')
        if [ ! -f "${EXPANDED_DIR}/${sp_safe}/model_results.rds" ]; then
            # Check extraction is done
            if [ -f "${ENV19_DIR}/${sp_safe}/P19_bio19.csv" ]; then
                echo "$sp" >> "${MODEL_LIST}"
            fi
        fi
    done < "${FAILED_LIST}"

    n_needed=$(wc -l < "${MODEL_LIST}")
    echo "  ${n_needed} ready for modeling"

    if [ "$n_needed" -gt 0 ]; then
        cd "${REPO_ROOT}"
        JOB_ID=$(sbatch --parsable \
            --array="1-${n_needed}%${MAX_MODEL}" \
            templates/xsdm_expanded.sbatch "${MODEL_LIST}")
        echo "  Submitted modeling: job ${JOB_ID}"
        echo "  Monitor: squeue -j ${JOB_ID}"
    else
        echo "  All models complete (or waiting for extraction)!"
    fi
    rm -f "${MODEL_LIST}"
}

# ── Main ─────────────────────────────────────────────────────────────
case "$MODE" in
    --generate-list)
        generate_failed_list
        ;;
    --extract-only)
        if [ ! -f "${FAILED_LIST}" ]; then generate_failed_list; fi
        phase_extract
        ;;
    --model-only)
        if [ ! -f "${FAILED_LIST}" ]; then generate_failed_list; fi
        phase_model
        ;;
    --both|*)
        if [ ! -f "${FAILED_LIST}" ]; then generate_failed_list; fi
        phase_extract
        echo ""
        echo "After extraction completes, re-run with --model-only:"
        echo "  bash scripts/orchestration/launch_expanded.sh --model-only"
        ;;
esac

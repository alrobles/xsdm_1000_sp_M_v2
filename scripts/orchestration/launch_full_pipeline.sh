#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# launch_full_pipeline.sh — Launch extraction + modeling for ALL species
# ─────────────────────────────────────────────────────────────────────
# Phase 1: Extract env data for species not yet extracted
# Phase 2: Run modeling (adaptive) for species not yet modeled
#
# Usage: bash launch_full_pipeline.sh [--dry-run] [--extract-only] [--model-only]
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

DRY_RUN=false
EXTRACT_ONLY=false
MODEL_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)       DRY_RUN=true; shift ;;
    --extract-only)  EXTRACT_ONLY=true; shift ;;
    --model-only)    MODEL_ONLY=true; shift ;;
    *) shift ;;
  esac
done

OCC_DIR="/home/a474r867/scratch/xsdm_occurrences"
EXTRACT_DIR="${ENV_CSV_DIR:-/home/a474r867/scratch/xsdm_env_extraction}"

log "═══════════════════════════════════════════════════"
log "FULL PIPELINE LAUNCH"
log "═══════════════════════════════════════════════════"

# ══════════════════════════════════════════════════════════════════════
# Phase 1: Environment Extraction
# ══════════════════════════════════════════════════════════════════════
if ! $MODEL_ONLY; then
  log ""
  log "── Phase 1: Environment Extraction ──"

  # Generate list of species needing extraction
  EXTRACT_LIST=$(mktemp /tmp/xsdm_extract_XXXXXX.txt)
  EXTRACT_COUNT=0
  ALREADY_EXTRACTED=0

  for csv in "${OCC_DIR}"/*.csv; do
    sp_name=$(basename "$csv" .csv)
    sp_safe=$(echo "$sp_name" | tr ' ' '_')
    if [ -d "${EXTRACT_DIR}/${sp_safe}" ] && \
       [ -f "${EXTRACT_DIR}/${sp_safe}/metadata.csv" ]; then
      ALREADY_EXTRACTED=$((ALREADY_EXTRACTED + 1))
    else
      echo "$sp_name" >> "$EXTRACT_LIST"
      EXTRACT_COUNT=$((EXTRACT_COUNT + 1))
    fi
  done

  log "  Already extracted: ${ALREADY_EXTRACTED}"
  log "  Need extraction:   ${EXTRACT_COUNT}"

  if [ "$EXTRACT_COUNT" -gt 0 ]; then
    # Submit in batches of 500 (extraction is lightweight: 8G, ~2 min each)
    BATCH=500
    TOTAL_BATCHES=$(( (EXTRACT_COUNT + BATCH - 1) / BATCH ))
    SUBMITTED=0

    for b in $(seq 1 "$TOTAL_BATCHES"); do
      START=$(( (b - 1) * BATCH + 1 ))
      END=$((b * BATCH))
      [ "$END" -gt "$EXTRACT_COUNT" ] && END="$EXTRACT_COUNT"
      BATCH_SIZE_ACTUAL=$((END - START + 1))

      # Wait for headroom
      while true; do
        ROOM=$(headroom)
        if [ "$ROOM" -ge "$BATCH_SIZE_ACTUAL" ]; then break; fi
        log "  Waiting for headroom ($ROOM < $BATCH_SIZE_ACTUAL)..."
        sleep "$RETRY_INTERVAL"
      done

      log "  Extraction batch ${b}/${TOTAL_BATCHES}: species ${START}-${END} (${BATCH_SIZE_ACTUAL} tasks)"

      if $DRY_RUN; then
        log "    [DRY RUN] sbatch --array=${START}-${END}%200 templates/extract_env.sbatch $EXTRACT_LIST"
      else
        cd "${PROJECT_ROOT}"
        mkdir -p logs
        JOBID=$(sbatch --parsable --array="${START}-${END}%200" \
          templates/extract_env.sbatch "$EXTRACT_LIST")
        log "    Submitted: job ${JOBID}"
      fi

      SUBMITTED=$((SUBMITTED + BATCH_SIZE_ACTUAL))
      sleep 2
    done

    log "  Extraction: ${SUBMITTED} tasks submitted"

    if ! $EXTRACT_ONLY; then
      log ""
      log "  NOTE: Modeling will start after extraction completes."
      log "  Monitor extraction with: squeue -u \$(whoami) --name=xsdm_env"
      log "  Then run: bash scripts/orchestration/launch_full_pipeline.sh --model-only"
    fi
  else
    log "  All species already extracted!"
  fi

  rm -f "$EXTRACT_LIST"
fi

# ══════════════════════════════════════════════════════════════════════
# Phase 2: Modeling (adaptive)
# ══════════════════════════════════════════════════════════════════════
if ! $EXTRACT_ONLY; then
  log ""
  log "── Phase 2: Adaptive Modeling ──"

  # Generate list of species needing modeling (have extraction, no results)
  MODEL_LIST=$(mktemp /tmp/xsdm_model_XXXXXX.txt)
  MODEL_COUNT=0
  ALREADY_MODELED=0

  for sp_dir in "${EXTRACT_DIR}"/*/; do
    sp_safe=$(basename "$sp_dir")
    sp_name=$(echo "$sp_safe" | tr '_' ' ')

    if species_done "$sp_name"; then
      ALREADY_MODELED=$((ALREADY_MODELED + 1))
    elif [ -f "${sp_dir}/metadata.csv" ]; then
      echo "$sp_name" >> "$MODEL_LIST"
      MODEL_COUNT=$((MODEL_COUNT + 1))
    fi
  done

  log "  Already modeled:   ${ALREADY_MODELED}"
  log "  Need modeling:     ${MODEL_COUNT}"

  if [ "$MODEL_COUNT" -gt 0 ]; then
    if $DRY_RUN; then
      log "  [DRY RUN] Would submit ${MODEL_COUNT} species via submit_adaptive.sh"
      log "  [DRY RUN] bash scripts/orchestration/submit_adaptive.sh $MODEL_LIST"
    else
      bash "${SCRIPT_DIR}/submit_adaptive.sh" "$MODEL_LIST"
    fi
  else
    log "  All extracted species already modeled!"
  fi

  rm -f "$MODEL_LIST"
fi

log ""
log "═══════════════════════════════════════════════════"
log "Full pipeline launch complete."
log "═══════════════════════════════════════════════════"

#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# submit_adaptive.sh — Smart submission: normal vs split by species size
# ─────────────────────────────────────────────────────────────────────
# Reads species_presence_counts.csv and routes each species to either:
#   - Normal mode (single task, full pipeline) for species ≤ SPLIT_THRESHOLD
#   - Split mode (23 L1 tasks + 1 collector) for species > SPLIT_THRESHOLD
#
# Usage:
#   bash submit_adaptive.sh species_list.txt [--dry-run]
#   bash submit_adaptive.sh species_list.txt --split-only    # only mega-species
#   bash submit_adaptive.sh species_list.txt --normal-only   # only small species
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LIST="${1:?Usage: bash submit_adaptive.sh species_list.txt [--dry-run]}"
shift || true

DRY_RUN=false
SPLIT_ONLY=false
NORMAL_ONLY=false
SKIP_EXISTING=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)      DRY_RUN=true; shift ;;
    --split-only)   SPLIT_ONLY=true; shift ;;
    --normal-only)  NORMAL_ONLY=true; shift ;;
    --no-skip)      SKIP_EXISTING=false; shift ;;
    *) shift ;;
  esac
done

# ── Configurable threshold (default: 2000 presences) ──
SPLIT_THRESHOLD="${SPLIT_THRESHOLD:-2000}"

# ── Presence counts file ──
COUNTS_FILE="${PROJECT_ROOT}/docs/species_presence_counts.csv"
if [ ! -f "$COUNTS_FILE" ]; then
  log "ERROR: ${COUNTS_FILE} not found. Run generate_species_list.sh first."
  exit 1
fi

log "═══════════════════════════════════════════════════"
log "xsdm ADAPTIVE submission"
log "Species list: $LIST"
log "Split threshold: ${SPLIT_THRESHOLD} presences"
log "Dry run: $DRY_RUN"
log "═══════════════════════════════════════════════════"

# ── Build lookup: species → presence count ──
declare -A PRES_MAP
while IFS=, read -r sp pres; do
  sp=$(echo "$sp" | sed 's/^"//;s/"$//')
  PRES_MAP["$sp"]="$pres"
done < <(tail -n +2 "$COUNTS_FILE")

# ── Classify species ──
NORMAL_LIST=()      # line numbers for normal-mode species
SPLIT_SPECIES=()    # species names for split-mode
SKIPPED=0

TOTAL=$(wc -l < "$LIST" | tr -d ' ')
for i in $(seq 1 "$TOTAL"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue

  if $SKIP_EXISTING && species_done "$sp"; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  pres="${PRES_MAP[$sp]:-0}"
  if [ "$pres" -gt "$SPLIT_THRESHOLD" ]; then
    SPLIT_SPECIES+=("$sp")
  else
    NORMAL_LIST+=("$i")
  fi
done

log "Classification:"
log "  Normal (≤${SPLIT_THRESHOLD}):  ${#NORMAL_LIST[@]} species"
log "  Split  (>${SPLIT_THRESHOLD}):  ${#SPLIT_SPECIES[@]} species"
log "  Skipped (done):    ${SKIPPED} species"

# ── Task budget estimate ──
NORMAL_TASKS=${#NORMAL_LIST[@]}
SPLIT_A_TASKS=$(( ${#SPLIT_SPECIES[@]} * 23 ))
SPLIT_B_TASKS=${#SPLIT_SPECIES[@]}
TOTAL_TASKS=$((NORMAL_TASKS + SPLIT_A_TASKS + SPLIT_B_TASKS))
log "  Task budget: ${NORMAL_TASKS} normal + ${SPLIT_A_TASKS} L1 + ${SPLIT_B_TASKS} L2+ = ${TOTAL_TASKS} total"

if [ "$TOTAL_TASKS" -gt 5000 ]; then
  log "WARNING: Total tasks ($TOTAL_TASKS) exceeds 5000 submission limit!"
  log "  Consider raising SPLIT_THRESHOLD or submitting in batches."
fi

# ══════════════════════════════════════════════════════════════════════
# Submit normal-mode species
# ══════════════════════════════════════════════════════════════════════
if ! $SPLIT_ONLY && [ ${#NORMAL_LIST[@]} -gt 0 ]; then
  log ""
  log "── Submitting ${#NORMAL_LIST[@]} normal-mode species ──"

  # Submit in batches of BATCH_SIZE
  BATCH_START=0
  SUBMITTED_NORMAL=0
  while [ $BATCH_START -lt ${#NORMAL_LIST[@]} ]; do
    BATCH_END=$((BATCH_START + BATCH_SIZE - 1))
    [ $BATCH_END -ge ${#NORMAL_LIST[@]} ] && BATCH_END=$(( ${#NORMAL_LIST[@]} - 1 ))
    BATCH_COUNT=$((BATCH_END - BATCH_START + 1))

    # Wait for headroom
    while true; do
      ROOM=$(headroom)
      if [ "$ROOM" -ge "$BATCH_COUNT" ]; then break; fi
      log "  Waiting for headroom ($ROOM < $BATCH_COUNT)..."
      sleep "$RETRY_INTERVAL"
    done

    ARRAY_ITEMS=()
    for idx in $(seq $BATCH_START $BATCH_END); do
      ARRAY_ITEMS+=("${NORMAL_LIST[$idx]}")
    done
    ARRAY_SPEC=$(echo "${ARRAY_ITEMS[@]}" | tr ' ' ',')

    log "  Normal batch: ${BATCH_COUNT} species (array: ${ARRAY_SPEC}%${MAX_CONCURRENT})"

    if $DRY_RUN; then
      log "    [DRY RUN] sbatch --array=${ARRAY_SPEC}%${MAX_CONCURRENT} templates/xsdm_species_csv.sbatch $LIST"
    else
      cd "${PROJECT_ROOT}"
      mkdir -p logs
      JOBID=$(sbatch --parsable --array="${ARRAY_SPEC}%${MAX_CONCURRENT}" \
        templates/xsdm_species_csv.sbatch "$LIST")
      log "    Submitted: job $JOBID (${BATCH_COUNT} tasks)"
    fi

    SUBMITTED_NORMAL=$((SUBMITTED_NORMAL + BATCH_COUNT))
    BATCH_START=$((BATCH_END + 1))
    [ $BATCH_START -lt ${#NORMAL_LIST[@]} ] && sleep 2
  done

  log "  Normal total: ${SUBMITTED_NORMAL} tasks submitted"
fi

# ══════════════════════════════════════════════════════════════════════
# Submit split-mode species (Phase A: 23 L1 models each)
# ══════════════════════════════════════════════════════════════════════
if ! $NORMAL_ONLY && [ ${#SPLIT_SPECIES[@]} -gt 0 ]; then
  log ""
  log "── Submitting ${#SPLIT_SPECIES[@]} split-mode species (Phase A: 23 tasks each) ──"

  SUBMITTED_SPLIT=0
  for sp in "${SPLIT_SPECIES[@]}"; do
    pres="${PRES_MAP[$sp]:-?}"
    log "  Species: ${sp} (${pres} presences)"

    # Check if L1 already complete
    SP_SAFE=$(echo "$sp" | tr ' ' '_')
    L1_DIR="${RESULTS_DIR}/${SP_SAFE}/L1"
    DONE_COUNT=$(ls "${L1_DIR}"/.model_*.done 2>/dev/null | wc -l)
    if [ "$DONE_COUNT" -ge 23 ]; then
      log "    L1 already complete (${DONE_COUNT}/23). Skipping Phase A."
      # Check if L2+ already done
      if [ -f "${RESULTS_DIR}/${SP_SAFE}/model_results.rds" ]; then
        log "    L2+ already complete. Skipping entirely."
        continue
      fi
      # Submit Phase B directly
      if $DRY_RUN; then
        log "    [DRY RUN] sbatch templates/xsdm_L2_collector.sbatch '${sp}'"
      else
        JOBID=$(sbatch --parsable templates/xsdm_L2_collector.sbatch "$sp")
        log "    Phase B submitted: job ${JOBID}"
      fi
      continue
    fi

    # Wait for headroom (need 23 slots)
    while true; do
      ROOM=$(headroom)
      if [ "$ROOM" -ge 23 ]; then break; fi
      log "    Waiting for headroom ($ROOM < 23)..."
      sleep "$RETRY_INTERVAL"
    done

    if $DRY_RUN; then
      log "    [DRY RUN] sbatch --array=1-23 templates/xsdm_L1_single.sbatch '${sp}'"
    else
      cd "${PROJECT_ROOT}"
      mkdir -p logs
      JOBID=$(sbatch --parsable --array=1-23 \
        templates/xsdm_L1_single.sbatch "$sp")
      log "    Phase A submitted: job ${JOBID} (23 L1 models)"
    fi

    SUBMITTED_SPLIT=$((SUBMITTED_SPLIT + 1))
    sleep 1
  done

  log "  Split total: ${SUBMITTED_SPLIT} species submitted (Phase A)"
  log ""
  log "  NOTE: Phase B (collector) must be submitted after Phase A completes."
  log "  Run: bash scripts/orchestration/check_split.sh"
fi

log ""
log "═══════════════════════════════════════════════════"
log "Adaptive submission complete."
log "═══════════════════════════════════════════════════"

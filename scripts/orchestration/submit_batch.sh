#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# submit_batch.sh — Submit a batch of species respecting safety ceiling
# ─────────────────────────────────────────────────────────────────────
# Usage: bash submit_batch.sh [species_list.txt] [--from N] [--to M] [--dry-run]
#
# Submits species in batches (BATCH_SIZE from config.env), checking
# headroom before each submission. Skips already-completed species.
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# ── Parse args ──
LIST="${1:-$SPECIES_LIST}"
FROM=1
TO=""
DRY_RUN=false
SKIP_EXISTING=true

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --to)   TO="$2";   shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --no-skip) SKIP_EXISTING=false; shift ;;
    *) shift ;;
  esac
done

TOTAL=$(wc -l < "$LIST" | tr -d ' ')
TO="${TO:-$TOTAL}"

log "═══════════════════════════════════════════════════"
log "xsdm batch submission"
log "Species list: $LIST ($TOTAL species)"
log "Range: $FROM — $TO"
log "Batch size: $BATCH_SIZE"
log "Safety ceiling: $SAFETY_CEILING"
log "Max concurrent per array: $MAX_CONCURRENT"
log "Dry run: $DRY_RUN"
log "Skip existing: $SKIP_EXISTING"
log "═══════════════════════════════════════════════════"

# ── Build list of species to submit (skip completed) ──
PENDING_LINES=()
for i in $(seq "$FROM" "$TO"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue
  if $SKIP_EXISTING && species_done "$sp"; then
    continue
  fi
  PENDING_LINES+=("$i")
done

log "Pending species: ${#PENDING_LINES[@]} / $((TO - FROM + 1))"

if [ ${#PENDING_LINES[@]} -eq 0 ]; then
  log "All species in range already completed. Nothing to submit."
  exit 0
fi

# ── Submit in batches ──
SUBMITTED=0
BATCH_START=0

while [ $BATCH_START -lt ${#PENDING_LINES[@]} ]; do
  BATCH_END=$((BATCH_START + BATCH_SIZE - 1))
  [ $BATCH_END -ge ${#PENDING_LINES[@]} ] && BATCH_END=$(( ${#PENDING_LINES[@]} - 1 ))
  BATCH_COUNT=$((BATCH_END - BATCH_START + 1))

  # ── Wait for headroom ──
  WAITED=0
  while true; do
    ROOM=$(headroom)
    if [ "$ROOM" -ge "$BATCH_COUNT" ]; then
      break
    fi
    if [ "$WAITED" -ge "$RETRY_BUDGET" ]; then
      log "WARNING: headroom insufficient ($ROOM < $BATCH_COUNT) after ${WAITED}s. Waiting more..."
      WAITED=0
    fi
    sleep "$RETRY_INTERVAL"
    WAITED=$((WAITED + RETRY_INTERVAL))
  done

  # ── Build array spec from pending lines ──
  # Group consecutive line numbers into ranges for --array
  ARRAY_ITEMS=()
  for idx in $(seq $BATCH_START $BATCH_END); do
    ARRAY_ITEMS+=("${PENDING_LINES[$idx]}")
  done

  # Convert to comma-separated or range format
  ARRAY_SPEC=$(echo "${ARRAY_ITEMS[@]}" | tr ' ' ',')

  log "Submitting batch: ${BATCH_COUNT} species (lines: ${ARRAY_ITEMS[0]}..${ARRAY_ITEMS[-1]})"
  log "  Headroom: $ROOM | Array spec: ${ARRAY_SPEC}%${MAX_CONCURRENT}"

  if $DRY_RUN; then
    log "  [DRY RUN] sbatch --array=${ARRAY_SPEC}%${MAX_CONCURRENT} templates/xsdm_species_parquet.sbatch $LIST"
  else
    cd "${PROJECT_ROOT}"
    mkdir -p logs
    JOBID=$(sbatch --parsable --array="${ARRAY_SPEC}%${MAX_CONCURRENT}" \
      templates/xsdm_species_parquet.sbatch "$LIST")
    log "  Submitted: job $JOBID (${BATCH_COUNT} tasks)"
  fi

  SUBMITTED=$((SUBMITTED + BATCH_COUNT))
  BATCH_START=$((BATCH_END + 1))

  # Brief pause between batches to let Slurm settle
  [ $BATCH_START -lt ${#PENDING_LINES[@]} ] && sleep 2
done

log "═══════════════════════════════════════════════════"
log "Done. Submitted $SUBMITTED species in $((SUBMITTED / BATCH_SIZE + 1)) batch(es)."
log "═══════════════════════════════════════════════════"

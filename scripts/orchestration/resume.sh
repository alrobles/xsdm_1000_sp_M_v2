#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# resume.sh — Resume pipeline: find incomplete species and resubmit
# ─────────────────────────────────────────────────────────────────────
# Usage: bash resume.sh [species_list.txt] [--dry-run]
#
# Scans the results directory and resubmits any species that:
#   - Has no results directory at all
#   - Has a results directory but no model_results.rds (incomplete)
#
# Respects the safety ceiling via submit_batch.sh
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LIST="${1:-$SPECIES_LIST}"
DRY_RUN=false

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) shift ;;
  esac
done

TOTAL=$(wc -l < "$LIST" | tr -d ' ')

log "═══════════════════════════════════════════════════"
log "Scanning for incomplete species..."
log "═══════════════════════════════════════════════════"

# ── Find incomplete species ──
INCOMPLETE=()
COMPLETE=0

for i in $(seq 1 "$TOTAL"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue

  if species_done "$sp"; then
    COMPLETE=$((COMPLETE + 1))
  else
    INCOMPLETE+=("$i")
  fi
done

log "Complete:   $COMPLETE / $TOTAL"
log "Incomplete: ${#INCOMPLETE[@]} / $TOTAL"

if [ ${#INCOMPLETE[@]} -eq 0 ]; then
  log "All species complete! Nothing to resume."
  exit 0
fi

# ── Show what will be resubmitted ──
log ""
log "Species to resubmit:"
for idx in "${INCOMPLETE[@]:0:20}"; do
  sp=$(sed -n "${idx}p" "$LIST")
  sp_dir="${RESULTS_DIR}/${sp// /_}"
  if [ -d "$sp_dir" ]; then
    status="partial (dir exists, no model_results.rds)"
  else
    status="not started"
  fi
  log "  Line $idx: $sp — $status"
done
[ ${#INCOMPLETE[@]} -gt 20 ] && log "  ... and $((${#INCOMPLETE[@]} - 20)) more"

# ── Build temp species list with only incomplete ──
RESUME_LIST=$(mktemp /tmp/xsdm_resume_XXXXXX.txt)
trap "rm -f $RESUME_LIST" EXIT

for idx in "${INCOMPLETE[@]}"; do
  sed -n "${idx}p" "$LIST" >> "$RESUME_LIST"
done

RESUME_TOTAL=$(wc -l < "$RESUME_LIST" | tr -d ' ')
log ""
log "Resume list: $RESUME_LIST ($RESUME_TOTAL species)"

if $DRY_RUN; then
  log "[DRY RUN] Would submit $RESUME_TOTAL species"
  log "[DRY RUN] Command: bash scripts/orchestration/submit_batch.sh $RESUME_LIST"
else
  # ── Submit via submit_batch.sh ──
  log "Submitting..."
  bash "${SCRIPT_DIR}/submit_batch.sh" "$RESUME_LIST"
fi

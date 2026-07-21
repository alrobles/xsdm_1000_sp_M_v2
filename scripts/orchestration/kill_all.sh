#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# kill_all.sh — Cancel all running/pending xsdm jobs
# ─────────────────────────────────────────────────────────────────────
# Usage: bash kill_all.sh [--confirm]
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

CONFIRM=false
[[ "${1:-}" == "--confirm" ]] && CONFIRM=true

# ── Count current jobs ──
JOBS=$(squeue -u "$(whoami)" --name="xsdm_pq" --noheader --format="%.18i" 2>/dev/null | wc -l)

if [ "$JOBS" -eq 0 ]; then
  log "No xsdm jobs running or pending."
  exit 0
fi

log "Found $JOBS xsdm job entries in queue."

if ! $CONFIRM; then
  echo ""
  echo "This will cancel ALL xsdm_pq jobs. Run with --confirm to proceed."
  echo ""
  squeue -u "$(whoami)" --name="xsdm_pq" --format="%.18i %.8T %.10M %.10j" | head -20
  exit 1
fi

# ── Cancel all ──
scancel --name="xsdm_pq"
log "All xsdm_pq jobs cancelled."

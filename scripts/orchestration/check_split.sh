#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# check_split.sh — Check Phase A completion, submit Phase B collectors
# ─────────────────────────────────────────────────────────────────────
# Scans all species with L1/ subdirectories, checks if all 23 models
# are done, and submits Phase B (L2+ collector) if ready.
#
# Usage:
#   bash check_split.sh              # check and submit
#   bash check_split.sh --dry-run    # check only
#   bash check_split.sh --loop       # poll every 60s until all done
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

DRY_RUN=false
LOOP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --loop)    LOOP=true; shift ;;
    *) shift ;;
  esac
done

check_and_submit() {
  local ready=0
  local waiting=0
  local done=0
  local submitted=0

  for sp_dir in "${RESULTS_DIR}"/*/; do
    [ -d "${sp_dir}/L1" ] || continue
    sp_name=$(basename "$sp_dir")

    # Count sentinel files
    local n_done
    n_done=$(ls "${sp_dir}/L1/"/.model_*.done 2>/dev/null | wc -l)

    if [ -f "${sp_dir}/model_results.rds" ]; then
      done=$((done + 1))
      continue
    fi

    if [ "$n_done" -ge 23 ]; then
      # Phase A complete — check if Phase B already running
      local running
      running=$(squeue -u "$(whoami)" --name="xsdm_L2" --noheader 2>/dev/null | \
        grep -c "${sp_name}" || true)
      if [ "$running" -gt 0 ]; then
        log "  ▶ ${sp_name}: Phase B running"
        continue
      fi

      ready=$((ready + 1))
      log "  ✓ ${sp_name}: 23/23 L1 done → submitting Phase B"

      if $DRY_RUN; then
        log "    [DRY RUN] sbatch templates/xsdm_L2_collector.sbatch '${sp_name//_/ }'"
      else
        # Wait for headroom
        while true; do
          local room
          room=$(headroom)
          if [ "$room" -ge 1 ]; then break; fi
          sleep 10
        done

        cd "${PROJECT_ROOT}"
        local jobid
        jobid=$(sbatch --parsable templates/xsdm_L2_collector.sbatch "${sp_name//_/ }")
        log "    Phase B submitted: job ${jobid}"
        submitted=$((submitted + 1))
      fi
    else
      waiting=$((waiting + 1))
      log "  ⏳ ${sp_name}: ${n_done}/23 L1 done"
    fi
  done

  log ""
  log "Summary: ${done} complete, ${ready} ready for L2+, ${waiting} waiting for L1"
  if ! $DRY_RUN; then
    log "Submitted ${submitted} Phase B collectors"
  fi

  # Return 0 if nothing left to wait for
  [ "$waiting" -eq 0 ]
}

log "═══════════════════════════════════════════════════"
log "Split mode checker"
log "═══════════════════════════════════════════════════"

if $LOOP; then
  while true; do
    if check_and_submit; then
      log "All split species complete or submitted. Exiting loop."
      break
    fi
    log "Sleeping ${RETRY_INTERVAL}s..."
    sleep "${RETRY_INTERVAL}"
    log ""
  done
else
  check_and_submit
fi

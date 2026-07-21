#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# status.sh — Quick one-shot status report (no loop, for Hermes)
# ─────────────────────────────────────────────────────────────────────
# Usage: bash status.sh [species_list.txt]
#
# Prints a concise status suitable for GitHub push or Hermes response.
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LIST="${1:-$SPECIES_LIST}"
TOTAL=$(wc -l < "$LIST" | tr -d ' ')

# ── Count by status ──
COMPLETED=0
HAS_MODEL=0
NO_MODEL=0

for i in $(seq 1 "$TOTAL"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue
  sp_dir="${RESULTS_DIR}/${sp// /_}"

  if [ -f "${sp_dir}/model_results.rds" ]; then
    COMPLETED=$((COMPLETED + 1))
    if [ -f "${sp_dir}/best_model.rds" ]; then
      HAS_MODEL=$((HAS_MODEL + 1))
    else
      NO_MODEL=$((NO_MODEL + 1))
    fi
  fi
done

# ── Slurm queue ──
RUNNING=$(squeue -u "$(whoami)" --name="xsdm_pq" --states=RUNNING --noheader 2>/dev/null | wc -l)
PENDING=$(squeue -u "$(whoami)" --name="xsdm_pq" --states=PENDING --noheader 2>/dev/null | wc -l)

# ── Output ──
echo "xsdm Status @ $(ts)"
echo "────────────────────────────"
echo "Total species:  $TOTAL"
echo "Completed:      $COMPLETED ($HAS_MODEL with model, $NO_MODEL without)"
echo "Running:        $RUNNING"
echo "Pending:        $PENDING"
echo "Not started:    $((TOTAL - COMPLETED - RUNNING - PENDING))"
echo ""
echo "Cluster usage:  $(count_xsdm_tasks) / $SAFETY_CEILING tasks"
echo "Disk:           $(du -sh "${RESULTS_DIR}" 2>/dev/null | awk '{print $1}')"

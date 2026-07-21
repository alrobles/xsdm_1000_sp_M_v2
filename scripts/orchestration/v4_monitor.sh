#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# v4_monitor.sh — Dashboard for v4 pipeline progress
# ─────────────────────────────────────────────────────────────────────
# Usage: bash v4_monitor.sh [--loop] [--interval 60]
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

RESULTS_DIR="/home/a474r867/scratch/xsdm_1000_sp"
ENV19_DIR="/home/a474r867/scratch/xsdm_env_extraction_19"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SPECIES_LIST="${REPO_ROOT}/species_list_v2.txt"

LOOP=false
INTERVAL=60

while [[ $# -gt 0 ]]; do
  case "$1" in
    --loop) LOOP=true; shift ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    *) shift ;;
  esac
done

ts() { date '+%Y-%m-%d %H:%M:%S'; }

monitor_once() {
  echo "════════════════════════════════════════════════"
  echo "  xSDM v4 Pipeline Monitor — $(ts)"
  echo "════════════════════════════════════════════════"

  TOTAL_SPECIES=$(wc -l < "$SPECIES_LIST" 2>/dev/null || echo 0)
  echo "Target species: $TOTAL_SPECIES"
  echo ""

  # ── Env19 extraction status ──
  N_ENV19=0
  while IFS= read -r sp; do
    sp_safe="${sp// /_}"
    [ -d "${ENV19_DIR}/${sp_safe}" ] && N_ENV19=$((N_ENV19 + 1))
  done < "$SPECIES_LIST"
  echo "─── ENV19 ───"
  echo "  Extracted: $N_ENV19 / $TOTAL_SPECIES"
  echo ""

  # ── Stage counts ──
  N_L1=0; N_L2=0; N_L3=0; N_L4=0; N_DONE=0; N_NONE=0

  while IFS= read -r sp; do
    [ -z "$sp" ] && continue
    sp_safe="${sp// /_}"
    p1_dir="${RESULTS_DIR}/${sp_safe}/phase1_results"

    if [ -f "${p1_dir}/.L4_done" ]; then
      N_DONE=$((N_DONE + 1))
    elif [ -f "${p1_dir}/.L3_done" ]; then
      N_L3=$((N_L3 + 1))
    elif [ -f "${p1_dir}/.L2_done" ]; then
      N_L2=$((N_L2 + 1))
    elif [ -f "${p1_dir}/.L1_done" ]; then
      N_L1=$((N_L1 + 1))
    else
      N_NONE=$((N_NONE + 1))
    fi
  done < "$SPECIES_LIST"

  TOTAL_DONE=$((N_DONE))
  echo "─── STAGES ───"
  echo "  None:      $N_NONE"
  echo "  L1 done:   $N_L1"
  echo "  L2 done:   $N_L2"
  echo "  L3 done:   $N_L3"
  echo "  L4/FINAL:  $N_DONE"
  echo ""
  printf "  Progress:  %d / %d (%.1f%%)\n" "$TOTAL_DONE" "$TOTAL_SPECIES" \
    "$(echo "scale=1; $TOTAL_DONE * 100 / $TOTAL_SPECIES" | bc 2>/dev/null || echo 0)"

  # ── Active Slurm jobs ──
  echo ""
  echo "─── SLURM JOBS ───"
  N_JOBS=$(squeue -u "$USER" --noheader --format="%j" 2>/dev/null | grep -cE '^xsdm_v4_L[1-4]$' 2>/dev/null || echo 0)
  echo "  xSDM v4 jobs: $N_JOBS"
  squeue -u "$USER" --format="%.10i %.20j %.8T %.10M %.6C" 2>/dev/null | grep -E 'JOBID|xsdm_v4' | head -20
  echo ""
  echo "════════════════════════════════════════════════"
}

if $LOOP; then
  while true; do
    clear 2>/dev/null || true
    monitor_once
    echo "Next check in ${INTERVAL}s (Ctrl+C to stop)"
    sleep "$INTERVAL"
  done
else
  monitor_once
fi

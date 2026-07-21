#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# monitor_v2.sh — Monitor the v2 pipeline phases
# ─────────────────────────────────────────────────────────────────────
# Usage:
#   bash monitor_v2.sh [--loop] [--interval 60]
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRATCH="/home/a474r867/scratch"
RESULTS_DIR="${SCRATCH}/xsdm_results"
ENV19_DIR="${SCRATCH}/xsdm_env_extraction_19"
OCC_DIR="${SCRATCH}/xsdm_occurrences"
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
  echo "  v2 Pipeline Monitor — $(ts)"
  echo "════════════════════════════════════════════════"

  TOTAL_SPECIES=$(wc -l < "$SPECIES_LIST" 2>/dev/null || echo 0)
  echo "Target species: $TOTAL_SPECIES"
  echo ""

  # ── Env19 extraction status ──
  echo "─── ENV19 EXTRACTION ───"
  N_ENV19=$(find "$ENV19_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  echo "  Extracted: $N_ENV19"

  # Count species from v2 list that have env19
  N_V2_WITH_ENV19=0
  if [ -f "$SPECIES_LIST" ]; then
    while IFS= read -r sp; do
      sp_safe="$(echo "$sp" | tr ' ' '_')"
      if [ -d "${ENV19_DIR}/${sp_safe}" ]; then
        N_V2_WITH_ENV19=$((N_V2_WITH_ENV19 + 1))
      fi
    done < "$SPECIES_LIST"
  fi
  echo "  v2 species with env19: $N_V2_WITH_ENV19 / $TOTAL_SPECIES"
  echo ""

  # ── Phase 2var status ──
  echo "─── PHASE 2VAR (two-var models) ───"
  N_P1_DONE=0
  N_P1_DIR=0
  if [ -d "$RESULTS_DIR" ]; then
    while IFS= read -r sp; do
      sp_safe="$(echo "$sp" | tr ' ' '_')"
      sp_dir="${RESULTS_DIR}/${sp_safe}"
      if [ -d "${sp_dir}/phase1_results" ]; then
        N_P1_DIR=$((N_P1_DIR + 1))
        if [ -f "${sp_dir}/phase1_results/phase1_results.rds" ]; then
          N_P1_DONE=$((N_P1_DONE + 1))
        fi
      fi
    done < "$SPECIES_LIST"
  fi
  echo "  Phase 2var started: $N_P1_DIR"
  echo "  Phase 2var complete: $N_P1_DONE / $TOTAL_SPECIES"
  echo ""

  # ── Phase 3var_L1 status ──
  echo "─── PHASE 3VAR_L1 (three-var split) ───"
  N_3VAR_LISTS=0
  N_3VAR_DONE=0
  if [ -d "$RESULTS_DIR" ]; then
    while IFS= read -r sp; do
      sp_safe="$(echo "$sp" | tr ' ' '_')"
      sp_dir="${RESULTS_DIR}/${sp_safe}"
      if [ -f "${sp_dir}/3var_model_list.csv" ]; then
        N_3VAR_LISTS=$((N_3VAR_LISTS + 1))
      fi
      if [ -d "${sp_dir}/phase2_results" ]; then
        N_3VAR_DONE=$((N_3VAR_DONE + 1))
      fi
    done < "$SPECIES_LIST"
  fi
  echo "  Species with 3var expansion list: $N_3VAR_LISTS"
  echo "  Species with phase2 results dir: $N_3VAR_DONE"
  echo ""

  # ── Phase collect status ──
  echo "─── PHASE COLLECT (final results) ───"
  N_FINAL=0
  if [ -d "$RESULTS_DIR" ]; then
    N_FINAL=$(find "$RESULTS_DIR" -name "model_results_v2.rds" 2>/dev/null | wc -l)
  fi
  echo "  Final results: $N_FINAL / $TOTAL_SPECIES"
  echo ""

  # ── Active Slurm jobs ──
  echo "─── SLURM JOBS ───"
  squeue -u "$USER" --format="%.10i %.30j %.8T %.10M %.6C %.8m" 2>/dev/null | head -20
  echo ""
  echo "════════════════════════════════════════════════"
}

if $LOOP; then
  while true; do
    clear
    monitor_once
    echo "Next check in ${INTERVAL}s (Ctrl+C to stop)"
    sleep "$INTERVAL"
  done
else
  monitor_once
fi

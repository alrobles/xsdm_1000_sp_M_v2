#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# collect_results.sh — Collect timing and model selection results
# ─────────────────────────────────────────────────────────────────────
# Usage: bash collect_results.sh [species_list.txt] [--output results.csv]
#
# Generates a CSV with per-species results:
#   species, presences, has_model, status, elapsed_slurm, max_rss
#
# Useful for timing analysis and scaling estimates.
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LIST="${1:-$SPECIES_LIST}"
OUTPUT="${PROJECT_ROOT}/docs/results_summary.csv"

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

TOTAL=$(wc -l < "$LIST" | tr -d ' ')

echo "species,line,presences,has_model,status" > "$OUTPUT"

# ── Get presence counts if CSV exists ──
COUNTS_CSV="${PROJECT_ROOT}/docs/species_presence_counts.csv"

for i in $(seq 1 "$TOTAL"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue
  sp_dir="${RESULTS_DIR}/${sp// /_}"

  # Get presence count from CSV
  presences="?"
  if [ -f "$COUNTS_CSV" ]; then
    presences=$(grep "^\"${sp}\"," "$COUNTS_CSV" 2>/dev/null | head -1 | cut -d',' -f2 || echo "?")
    [ -z "$presences" ] && presences="?"
  fi

  # Determine status
  if [ -f "${sp_dir}/best_model.rds" ]; then
    status="completed_model"
    has_model="yes"
  elif [ -f "${sp_dir}/model_results.rds" ]; then
    status="completed_no_model"
    has_model="no"
  elif [ -d "${sp_dir}" ]; then
    status="incomplete"
    has_model="no"
  else
    status="not_started"
    has_model="no"
  fi

  echo "\"${sp}\",${i},${presences},${has_model},${status}" >> "$OUTPUT"
done

log "Results written to: $OUTPUT"
log "Summary:"
echo "  $(grep 'completed_model' "$OUTPUT" | wc -l) with model"
echo "  $(grep 'completed_no_model' "$OUTPUT" | wc -l) without model (expected)"
echo "  $(grep 'incomplete' "$OUTPUT" | wc -l) incomplete"
echo "  $(grep 'not_started' "$OUTPUT" | wc -l) not started"

# ── Collect profile_likelihood PDFs into centralized folder ──
PROFILE_DIR="${PROJECT_ROOT}/docs/profile_pdfs"
DIAG_DIR="${PROJECT_ROOT}/docs/diagnostics"
mkdir -p "$PROFILE_DIR" "$DIAG_DIR"

log "Collecting profile_likelihood PDFs and diagnostics..."
n_profiles=0
n_diag=0
for i in $(seq 1 "$TOTAL"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue
  sp_dir="${RESULTS_DIR}/${sp// /_}"
  sp_safe="${sp// /_}"

  # Copy profile likelihood PDF
  if [ -f "${sp_dir}/plots/05_profile_likelihood.pdf" ]; then
    cp "${sp_dir}/plots/05_profile_likelihood.pdf" \
       "${PROFILE_DIR}/${sp_safe}_profile.pdf"
    n_profiles=$((n_profiles + 1))
  fi

  # Copy diagnostics CSV
  if [ -f "${sp_dir}/diagnostics.csv" ]; then
    cp "${sp_dir}/diagnostics.csv" \
       "${DIAG_DIR}/${sp_safe}_diagnostics.csv"
    n_diag=$((n_diag + 1))
  fi

  # Copy all plots for species with models
  if [ -d "${sp_dir}/plots" ] && [ -f "${sp_dir}/best_model.rds" ]; then
    SP_PLOTS="${PROJECT_ROOT}/docs/species_plots/${sp_safe}"
    mkdir -p "$SP_PLOTS"
    cp "${sp_dir}/plots/"*.pdf "$SP_PLOTS/" 2>/dev/null || true
  fi
done

log "Collected: ${n_profiles} profile PDFs, ${n_diag} diagnostics CSVs"
log "Profile PDFs:  ${PROFILE_DIR}/"
log "Diagnostics:   ${DIAG_DIR}/"

# ── Consolidate profile arc check CSVs into master table ──
ARC_DIR="${PROJECT_ROOT}/docs/arc_checks"
ARC_MASTER="${PROJECT_ROOT}/docs/profile_arc_master.csv"
mkdir -p "$ARC_DIR"

log "Consolidating profile arc check results..."
n_arc=0
header_written=0
for i in $(seq 1 "$TOTAL"); do
  sp=$(sed -n "${i}p" "$LIST")
  [ -z "$sp" ] && continue
  sp_dir="${RESULTS_DIR}/${sp// /_}"
  sp_safe="${sp// /_}"

  if [ -f "${sp_dir}/profile_arc_check.csv" ]; then
    cp "${sp_dir}/profile_arc_check.csv" \
       "${ARC_DIR}/${sp_safe}_arc.csv"

    # Write header only once, then data rows
    if [ $header_written -eq 0 ]; then
      head -1 "${sp_dir}/profile_arc_check.csv" > "$ARC_MASTER"
      header_written=1
    fi
    tail -1 "${sp_dir}/profile_arc_check.csv" >> "$ARC_MASTER"
    n_arc=$((n_arc + 1))
  fi
done

if [ $n_arc -gt 0 ]; then
  n_pass=$(tail -n +2 "$ARC_MASTER" | awk -F',' '{print $(NF-3)}' | grep -c '^1$' || true)
  log "Arc checks: ${n_arc} species, ${n_pass} all-pass"
  log "Master table: ${ARC_MASTER}"
else
  log "No arc check CSVs found (run with updated xsdm_model_selection.R)"
fi

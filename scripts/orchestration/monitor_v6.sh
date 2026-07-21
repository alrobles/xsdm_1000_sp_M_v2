#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# monitor_v6.sh — Monitor the v6 orchestrated pipeline
# ─────────────────────────────────────────────────────────────────────
# Usage:
#   bash monitor_v6.sh                    # single snapshot
#   bash monitor_v6.sh --loop             # refresh every 60s
#   bash monitor_v6.sh --loop --interval 30
#   bash monitor_v6.sh --species "Oryctolagus cuniculus"  # single species detail
# ─────────────────────────────────────────────────────────────────────
set -uo pipefail

SCRATCH="/home/a474r867/scratch"
RESULTS_DIR="${SCRATCH}/xsdm_results_v6"
LOGS_DIR="${SCRATCH}/logs/orchestrator_v6"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd || echo /kuhpc/work/kbs/a474r867/xsdm_1000_sp)"
SPECIES_LIST="${REPO_ROOT}/species_list_v2.txt"

LOOP=false
INTERVAL=60
SPECIES_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --loop) LOOP=true; shift ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --species) SPECIES_FILTER="$2"; shift 2 ;;
    *) shift ;;
  esac
done

ts() { date '+%Y-%m-%d %H:%M:%S'; }

# ─── Single species detail view ──────────────────────────────────────────────

monitor_species() {
  local species="$1"
  local sp_safe=$(echo "${species}" | tr ' ' '_')
  local sp_dir="${RESULTS_DIR}/${sp_safe}"

  echo "═══════════════════════════════════════════════════════════════"
  echo "  Species: ${species}"
  echo "  Directory: ${sp_dir}"
  echo "═══════════════════════════════════════════════════════════════"

  if [[ ! -d "${sp_dir}" ]]; then
    echo "  [!] No results directory yet"
    return
  fi

  # L1 models
  local n_models=0
  local n_success=0
  local n_failed=0
  local best_model=""
  local best_pbic=999999

  if [[ -d "${sp_dir}/models" ]]; then
    n_models=$(ls "${sp_dir}/models/"*.rds 2>/dev/null | wc -l)

    for rds in "${sp_dir}/models/"*.rds; do
      [[ ! -f "$rds" ]] && continue
      local model_name=$(basename "$rds" .rds)
      # Quick check: file size > 1KB means likely success
      local fsize=$(stat -c%s "$rds" 2>/dev/null || echo 0)
      if [[ $fsize -gt 1000 ]]; then
        ((n_success++)) || true
      else
        ((n_failed++)) || true
      fi
    done
  fi

  echo ""
  echo "  ─── MODELS ───"
  echo "  Total RDS files: ${n_models}"
  echo "  Likely success:  ${n_success}"
  echo "  Likely failed:   ${n_failed}"

  # Boundary models (contain __)
  local n_boundary=$(ls "${sp_dir}/models/"*__*.rds 2>/dev/null | wc -l)
  local n_l1=$((n_models - n_boundary))
  echo "  L1 (non-boundary): ${n_l1}/23"
  echo "  L2/L4 (boundary):  ${n_boundary}"

  # Well-behaved checks
  if [[ -d "${sp_dir}/wb" ]]; then
    local n_wb=$(ls "${sp_dir}/wb/"*.rds 2>/dev/null | wc -l)
    echo ""
    echo "  ─── WELL-BEHAVED CHECKS ───"
    echo "  Checked: ${n_wb}"
  fi

  # Profile
  if [[ -f "${sp_dir}/profile_results_v6.rds" ]]; then
    echo ""
    echo "  ─── PROFILE ───"
    echo "  ✓ Profile completed!"
    if [[ -f "${sp_dir}/plots/profile_likelihood_v6.pdf" ]]; then
      echo "  ✓ PDF generated"
    fi
  fi

  # Summary
  if [[ -f "${sp_dir}/orchestrator_summary.txt" ]]; then
    echo ""
    echo "  ─── SUMMARY ───"
    cat "${sp_dir}/orchestrator_summary.txt"
  fi

  echo ""
}

# ─── Overview ────────────────────────────────────────────────────────────────

monitor_overview() {
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  xsdm v6 Pipeline Monitor — $(ts)          ║"
  echo "╠══════════════════════════════════════════════════════════════╣"

  # Orchestrator job
  echo "║"
  echo "║  ─── ORCHESTRATOR JOBS ───"
  local orch_jobs=$(squeue -u a474r867 -n v6_orchestrator --format="%i %T %M %N" --noheader 2>/dev/null)
  if [[ -n "${orch_jobs}" ]]; then
    echo "${orch_jobs}" | while read line; do
      echo "║    ${line}"
    done
  else
    echo "║    (none running)"
  fi

  # Worker jobs
  echo "║"
  echo "║  ─── WORKER JOBS ───"
  local n_running=0
  n_running=$(squeue -u a474r867 --format="%j" --noheader 2>/dev/null | grep "^v6_" | grep -v orchestrator | grep -c "." 2>/dev/null) || true
  n_running=${n_running:-0}
  local n_pending=0
  n_pending=$(squeue -u a474r867 -t PENDING --format="%j" --noheader 2>/dev/null | grep "^v6_" | grep -c "." 2>/dev/null) || true
  n_pending=${n_pending:-0}
  echo "║    Running: ${n_running}"
  echo "║    Pending: ${n_pending}"

  # Show breakdown by type
  local n_l1=0 n_l2=0 n_wb=0 n_prof=0
  n_l1=$(squeue -u a474r867 --format="%j" --noheader 2>/dev/null | grep "^v6_" | grep -v "orchestrator\|__\|wb_\|prof_" | wc -l) || true
  n_l1=${n_l1:-0}
  n_l2=$(squeue -u a474r867 --format="%j" --noheader 2>/dev/null | grep -c "^v6_.*__" 2>/dev/null) || true
  n_l2=${n_l2:-0}
  n_wb=$(squeue -u a474r867 --format="%j" --noheader 2>/dev/null | grep -c "^v6_wb_" 2>/dev/null) || true
  n_wb=${n_wb:-0}
  n_prof=$(squeue -u a474r867 --format="%j" --noheader 2>/dev/null | grep -c "^v6_prof_" 2>/dev/null) || true
  n_prof=${n_prof:-0}
  echo "║    L1 workers:   ${n_l1}"
  echo "║    L2 boundary:  ${n_l2}"
  echo "║    WB checks:    ${n_wb}"
  echo "║    Profile:      ${n_prof}"

  # Active workers detail (top 10 by elapsed time)
  echo "║"
  echo "║  ─── ACTIVE WORKERS (top 10) ───"
  squeue -u a474r867 --format="%-12i %-10T %-35j %-10M" --noheader 2>/dev/null \
    | grep "v6_" | grep -v orchestrator | sort -k4 -r | head -10 \
    | while read line; do echo "║    ${line}"; done

  # Results summary
  echo "║"
  echo "║  ─── RESULTS ───"
  local n_species_dirs=$(find "${RESULTS_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  local n_completed=0
  local n_in_progress=0

  for sp_dir in "${RESULTS_DIR}"/*/; do
    [[ ! -d "$sp_dir" ]] && continue
    if [[ -f "${sp_dir}orchestrator_summary.txt" ]]; then
      ((n_completed++)) || true
    else
      ((n_in_progress++)) || true
    fi
  done

  local total_species=0
  if [[ -f "${SPECIES_LIST}" ]]; then
    total_species=$(wc -l < "${SPECIES_LIST}")
  fi

  echo "║    Species with results: ${n_species_dirs}"
  echo "║    Completed (summary):  ${n_completed}"
  echo "║    In progress:          ${n_in_progress}"
  echo "║    Total target:         ${total_species}"

  # Recent completions
  if [[ ${n_completed} -gt 0 ]]; then
    echo "║"
    echo "║  ─── RECENT COMPLETIONS ───"
    for sp_dir in "${RESULTS_DIR}"/*/; do
      [[ ! -d "$sp_dir" ]] && continue
      local summary="${sp_dir}orchestrator_summary.txt"
      if [[ -f "${summary}" ]]; then
        local sp_name=$(basename "$sp_dir")
        local result=$(cat "${summary}")
        echo "║    ${sp_name}: ${result}"
      fi
    done | tail -10
  fi

  # Errors from orchestrator log
  local orch_log=""
  orch_log=$(ls -t "${SCRATCH}/logs/orchestrator_v6_"*.out 2>/dev/null | head -1) || true
  if [[ -n "${orch_log}" && -f "${orch_log}" ]]; then
    local n_errors=0
    n_errors=$(grep -c "ERROR\|FAILED" "${orch_log}" 2>/dev/null) || true
    n_errors=${n_errors:-0}
    if [[ ${n_errors} -gt 0 ]]; then
      echo "║"
      echo "║  ─── ERRORS (${n_errors}) ───"
      grep "ERROR\|FAILED" "${orch_log}" 2>/dev/null | tail -5 | while read line; do
        echo "║    ${line}"
      done
    fi
  fi

  echo "║"
  echo "╚══════════════════════════════════════════════════════════════╝"
}

# ─── Main ────────────────────────────────────────────────────────────────────

if [[ -n "${SPECIES_FILTER}" ]]; then
  monitor_species "${SPECIES_FILTER}"
elif ${LOOP}; then
  while true; do
    clear
    monitor_overview
    echo ""
    echo "Refreshing in ${INTERVAL}s... (Ctrl+C to stop)"
    sleep "${INTERVAL}"
  done
else
  monitor_overview
fi

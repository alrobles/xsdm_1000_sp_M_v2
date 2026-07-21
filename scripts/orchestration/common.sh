#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# common.sh — Shared functions for orchestration scripts
# ─────────────────────────────────────────────────────────────────────

# Source config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../config.env"

# ── Count submitted+running tasks for xsdm jobs ──
count_xsdm_tasks() {
  local total=0
  # Count individual array tasks (PENDING + RUNNING) across all xsdm job names
  while IFS= read -r line; do
    local state=$(echo "$line" | awk '{print $2}')
    local array_spec=$(echo "$line" | awk '{print $4}')
    if [[ "$state" == "PENDING" || "$state" == "RUNNING" ]]; then
      if [[ "$array_spec" == *"_"* ]]; then
        total=$((total + 1))
      elif [[ "$array_spec" == *"-"* ]]; then
        local range="${array_spec%%\%*}"
        local lo="${range%-*}"
        local hi="${range#*-}"
        total=$((total + hi - lo + 1))
      else
        total=$((total + 1))
      fi
    fi
  done < <(squeue -u "$(whoami)" --name="xsdm_pq,xsdm_csv,xsdm_L1,xsdm_L2,xsdm_env,xsdm_kbs,xsdm_v2" \
    --noheader --format="%.18i %.8T %.10M %j" 2>/dev/null)
  echo "$total"
}

# ── Get presence count for a species (from counts CSV) ──
species_presences() {
  local sp_name="$1"
  local counts_file="${PROJECT_ROOT}/docs/species_presence_counts.csv"
  if [ ! -f "$counts_file" ]; then echo "0"; return; fi
  grep -m1 "^\"${sp_name}\"," "$counts_file" 2>/dev/null | cut -d, -f2 || echo "0"
}

# ── Check headroom ──
headroom() {
  local used
  used=$(count_xsdm_tasks)
  echo $((SAFETY_CEILING - used))
}

# ── List completed species ──
completed_species() {
  local count=0
  if [ -d "${RESULTS_DIR}" ]; then
    for d in "${RESULTS_DIR}"/*/; do
      [ -d "$d" ] || continue
      if [ -f "${d}model_results.rds" ]; then
        count=$((count + 1))
      fi
    done
  fi
  echo "$count"
}

# ── Check if a species is done (has model_results.rds) ──
species_done() {
  local sp_name="$1"
  local sp_dir="${RESULTS_DIR}/${sp_name// /_}"
  [ -f "${sp_dir}/model_results.rds" ]
}

# ── Get species name from list by line number ──
get_species() {
  local list="$1"
  local line="$2"
  sed -n "${line}p" "$list"
}

# ── Count total species in list ──
total_species() {
  local list="${1:-$SPECIES_LIST}"
  wc -l < "$list" | tr -d ' '
}

# ── Timestamp for logs ──
ts() {
  date '+%Y-%m-%d %H:%M:%S'
}

# ── Log with timestamp ──
log() {
  echo "[$(ts)] $*"
}

#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# monitor.sh — Real-time progress monitor for xsdm pipeline
# ─────────────────────────────────────────────────────────────────────
# Usage: bash monitor.sh [species_list.txt] [--once] [--interval N]
#
# Shows a live dashboard with:
#   - Overall progress bar
#   - Per-status counts (completed, running, failed, pending)
#   - Throughput (species/hour)
#   - ETA to completion
#   - Recent completions (last 5)
#   - Currently running jobs
#   - Failed species list
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LIST="${1:-$SPECIES_LIST}"
ONCE=false
INTERVAL="${MONITOR_INTERVAL}"

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --once) ONCE=true; shift ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    *) shift ;;
  esac
done

TOTAL=$(wc -l < "$LIST" | tr -d ' ')
START_TIME=$(date +%s)

# ── Progress bar function ──
progress_bar() {
  local current=$1 total=$2 width=40
  local pct=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))
  printf "\r  ["
  printf '%0.s█' $(seq 1 $filled 2>/dev/null) || true
  printf '%0.s░' $(seq 1 $empty 2>/dev/null) || true
  printf "] %3d%% (%d/%d)" "$pct" "$current" "$total"
}

# ── Main loop ──
while true; do
  clear 2>/dev/null || true

  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║              xsdm Pipeline Monitor — $(date '+%H:%M:%S')              ║"
  echo "╠══════════════════════════════════════════════════════════════╣"

  # ── Count species by status ──
  COMPLETED=0
  COMPLETED_MODEL=0
  NO_MODEL=0
  FAILED_LIST=()
  RECENT=()

  for i in $(seq 1 "$TOTAL"); do
    sp=$(sed -n "${i}p" "$LIST")
    [ -z "$sp" ] && continue
    sp_dir="${RESULTS_DIR}/${sp// /_}"

    if [ -d "$sp_dir" ]; then
      if [ -f "${sp_dir}/model_results.rds" ]; then
        COMPLETED=$((COMPLETED + 1))
        if [ -f "${sp_dir}/best_model.rds" ]; then
          COMPLETED_MODEL=$((COMPLETED_MODEL + 1))
        else
          NO_MODEL=$((NO_MODEL + 1))
        fi
        # Track modification time for recent completions
        mtime=$(stat -c %Y "${sp_dir}/model_results.rds" 2>/dev/null || echo 0)
        RECENT+=("${mtime}:${sp}")
      fi
    fi
  done

  # ── Count running/pending from Slurm ──
  RUNNING=0
  PENDING_SLURM=0
  RUNNING_SPECIES=()

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    state=$(echo "$line" | awk '{print $1}')
    taskid=$(echo "$line" | awk '{print $2}')
    elapsed=$(echo "$line" | awk '{print $3}')

    if [[ "$state" == "RUNNING" ]]; then
      RUNNING=$((RUNNING + 1))
      # Get species name from task ID
      if [[ "$taskid" =~ _([0-9]+)$ ]]; then
        task_num="${BASH_REMATCH[1]}"
        sp_name=$(sed -n "${task_num}p" "$LIST" 2>/dev/null)
        [ -n "$sp_name" ] && RUNNING_SPECIES+=("${sp_name} (${elapsed})")
      fi
    elif [[ "$state" == "PENDING" ]]; then
      PENDING_SLURM=$((PENDING_SLURM + 1))
    fi
  done < <(squeue -u "$(whoami)" --name="xsdm_pq" --noheader --format="%.8T %.18i %.10M" 2>/dev/null)

  # ── Check for failed jobs (sacct, last 24h) ──
  FAILED=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    jobid=$(echo "$line" | awk '{print $1}')
    state=$(echo "$line" | awk '{print $2}')
    if [[ "$state" == "FAILED" || "$state" == "OUT_OF_ME+" || "$state" == "TIMEOUT" ]]; then
      FAILED=$((FAILED + 1))
      if [[ "$jobid" =~ _([0-9]+)$ ]]; then
        task_num="${BASH_REMATCH[1]}"
        sp_name=$(sed -n "${task_num}p" "$LIST" 2>/dev/null)
        [ -n "$sp_name" ] && FAILED_LIST+=("$sp_name ($state)")
      fi
    fi
  done < <(sacct --starttime="$(date -d '24 hours ago' '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -v-24H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || echo '2026-01-01')" --name="xsdm_pq" --format="JobID%20,State%12" --noheader 2>/dev/null | grep -v "\.batch" | grep -v "\.extern" | grep "_")

  NOT_STARTED=$((TOTAL - COMPLETED - RUNNING - PENDING_SLURM))
  [ $NOT_STARTED -lt 0 ] && NOT_STARTED=0

  # ── Display progress ──
  echo "║"
  printf "║  Overall: "
  progress_bar "$COMPLETED" "$TOTAL"
  echo ""
  echo "║"
  printf "║  ✓ Completed (model found):   %5d\n" "$COMPLETED_MODEL"
  printf "║  ○ Completed (no model):      %5d\n" "$NO_MODEL"
  printf "║  ▶ Running:                   %5d\n" "$RUNNING"
  printf "║  ⏳ Pending (Slurm queue):     %5d\n" "$PENDING_SLURM"
  printf "║  ✗ Failed (last 24h):         %5d\n" "$FAILED"
  printf "║  · Not submitted:             %5d\n" "$NOT_STARTED"

  # ── Throughput & ETA ──
  NOW=$(date +%s)
  ELAPSED_SEC=$((NOW - START_TIME))
  if [ $ELAPSED_SEC -gt 0 ] && [ $COMPLETED -gt 0 ]; then
    # Use file timestamps for better throughput estimate
    OLDEST_COMPLETED=$(find "${RESULTS_DIR}" -name "model_results.rds" -printf '%T@\n' 2>/dev/null | sort -n | head -1 | cut -d. -f1)
    NEWEST_COMPLETED=$(find "${RESULTS_DIR}" -name "model_results.rds" -printf '%T@\n' 2>/dev/null | sort -rn | head -1 | cut -d. -f1)
    if [ -n "$OLDEST_COMPLETED" ] && [ -n "$NEWEST_COMPLETED" ] && [ "$NEWEST_COMPLETED" -gt "$OLDEST_COMPLETED" ]; then
      SPAN=$((NEWEST_COMPLETED - OLDEST_COMPLETED))
      if [ $SPAN -gt 0 ]; then
        TPH=$(echo "scale=1; $COMPLETED * 3600 / $SPAN" | bc 2>/dev/null || echo "?")
        REMAINING=$((TOTAL - COMPLETED))
        if [ "$TPH" != "?" ] && [ "$TPH" != "0" ] && [ "$TPH" != "0.0" ]; then
          ETA_SEC=$(echo "scale=0; $REMAINING * 3600 / $TPH" | bc 2>/dev/null || echo "?")
          if [ "$ETA_SEC" != "?" ]; then
            ETA_H=$((ETA_SEC / 3600))
            ETA_M=$(( (ETA_SEC % 3600) / 60 ))
            ETA_STR="${ETA_H}h ${ETA_M}m"
          else
            ETA_STR="?"
          fi
        else
          TPH="?"
          ETA_STR="?"
        fi
      else
        TPH="?"
        ETA_STR="?"
      fi
    else
      TPH="?"
      ETA_STR="calculating..."
    fi
  else
    TPH="?"
    ETA_STR="calculating..."
  fi

  echo "║"
  printf "║  Throughput: %s species/hour\n" "$TPH"
  printf "║  ETA:        %s\n" "$ETA_STR"

  # ── Cluster headroom ──
  USED=$(count_xsdm_tasks)
  ROOM=$((SAFETY_CEILING - USED))
  echo "║"
  printf "║  Cluster: %d/%d tasks used (%d headroom)\n" "$USED" "$SAFETY_CEILING" "$ROOM"

  # ── Disk usage ──
  if [ -d "${RESULTS_DIR}" ]; then
    DISK=$(du -sh "${RESULTS_DIR}" 2>/dev/null | awk '{print $1}')
    printf "║  Disk:    %s in %s\n" "$DISK" "${RESULTS_DIR}"
  fi

  # ── Running species ──
  if [ ${#RUNNING_SPECIES[@]} -gt 0 ]; then
    echo "║"
    echo "║  Currently running:"
    for rs in "${RUNNING_SPECIES[@]:0:10}"; do
      printf "║    ▶ %s\n" "$rs"
    done
    [ ${#RUNNING_SPECIES[@]} -gt 10 ] && printf "║    ... and %d more\n" "$((${#RUNNING_SPECIES[@]} - 10))"
  fi

  # ── Recent completions ──
  if [ ${#RECENT[@]} -gt 0 ]; then
    echo "║"
    echo "║  Recent completions:"
    IFS=$'\n' SORTED=($(printf '%s\n' "${RECENT[@]}" | sort -rn | head -5))
    for entry in "${SORTED[@]}"; do
      sp_name="${entry#*:}"
      sp_dir="${RESULTS_DIR}/${sp_name// /_}"
      has_best="✓"
      [ ! -f "${sp_dir}/best_model.rds" ] && has_best="○"
      printf "║    %s %s\n" "$has_best" "$sp_name"
    done
  fi

  # ── Failed species ──
  if [ ${#FAILED_LIST[@]} -gt 0 ]; then
    echo "║"
    echo "║  Failed species:"
    for fs in "${FAILED_LIST[@]:0:10}"; do
      printf "║    ✗ %s\n" "$fs"
    done
    [ ${#FAILED_LIST[@]} -gt 10 ] && printf "║    ... and %d more\n" "$((${#FAILED_LIST[@]} - 10))"
  fi

  echo "║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "  Press Ctrl+C to exit. Refreshing every ${INTERVAL}s..."

  $ONCE && exit 0
  sleep "$INTERVAL"
done

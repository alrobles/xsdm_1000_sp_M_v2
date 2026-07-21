#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# submit_v2.sh — Orchestrate the v2 multi-phase pipeline
# ─────────────────────────────────────────────────────────────────────
# Usage:
#   bash submit_v2.sh species_list.txt [--phase 2var|3var|collect|all] [--dry-run]
#
# Phases:
#   2var    — Submit Phase 1: fit 88 two-var L1 + boundary
#   3var    — Submit Phase 2: fit three-var models (split mode per species)
#   collect — Submit Phase 3: final assembly + profiling
#   all     — Run all phases sequentially (waits between phases)
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Defaults
SCRATCH="/home/a474r867/scratch"
RESULTS_DIR="${SCRATCH}/xsdm_results"
MAX_CONCURRENT=100
SAFETY_CEILING=4000
BATCH_SIZE=500

LIST="${1:?Usage: bash submit_v2.sh species_list.txt [--phase 2var|3var|collect|all]}"
shift
PHASE="all"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)  PHASE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --max-concurrent) MAX_CONCURRENT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

TOTAL=$(wc -l < "$LIST" | tr -d ' ')
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] $*"; }

log "═══════════════════════════════════════════════════"
log "xsdm Pipeline v2 Orchestrator"
log "Species list: $LIST ($TOTAL species)"
log "Phase: $PHASE"
log "Max concurrent: $MAX_CONCURRENT"
log "Dry run: $DRY_RUN"
log "═══════════════════════════════════════════════════"

# ── Phase 2var ──
submit_2var() {
  log "=== Phase 2var: Submitting two-var fitting ==="

  # Skip species that already have phase1_results.rds
  PENDING=()
  while IFS= read -r sp; do
    sp_dir="${RESULTS_DIR}/$(echo "$sp" | tr ' ' '_')"
    if [ -f "${sp_dir}/phase1_results/phase1_results.rds" ]; then
      continue
    fi
    PENDING+=("$sp")
  done < "$LIST"

  N_PENDING=${#PENDING[@]}
  log "Pending: $N_PENDING / $TOTAL (skipping already completed)"

  if [ "$N_PENDING" -eq 0 ]; then
    log "All species have Phase 2var results. Skipping."
    return
  fi

  # Create temp species list with only pending
  PENDING_LIST=$(mktemp /tmp/v2_pending_2var_XXXXXX.txt)
  printf '%s\n' "${PENDING[@]}" > "$PENDING_LIST"
  N_PENDING=$(wc -l < "$PENDING_LIST" | tr -d ' ')

  # Submit in chunks
  FROM=1
  while [ "$FROM" -le "$N_PENDING" ]; do
    TO=$((FROM + BATCH_SIZE - 1))
    [ "$TO" -gt "$N_PENDING" ] && TO="$N_PENDING"
    ARRAY_SPEC="${FROM}-${TO}%${MAX_CONCURRENT}"

    if $DRY_RUN; then
      log "[DRY RUN] sbatch --array=${ARRAY_SPEC} templates/xsdm_v2_2var.sbatch ${PENDING_LIST}"
    else
      cd "$PROJECT_ROOT"
      mkdir -p logs
      JOBID=$(sbatch --parsable --array="${ARRAY_SPEC}" \
        templates/xsdm_v2_2var.sbatch "$PENDING_LIST")
      log "Submitted: job $JOBID (lines ${FROM}-${TO}, ${MAX_CONCURRENT} concurrent)"
    fi

    FROM=$((TO + 1))
    sleep 1
  done

  rm -f "$PENDING_LIST"
  log "Phase 2var submission complete"
}

# ── Phase 3var ──
submit_3var() {
  log "=== Phase 3var: Submitting three-var split fitting ==="

  SUBMITTED=0
  while IFS= read -r sp; do
    sp_safe="$(echo "$sp" | tr ' ' '_')"
    sp_dir="${RESULTS_DIR}/${sp_safe}"
    model_list="${sp_dir}/3var_model_list.csv"

    # Skip if no model list (Phase 2var didn't generate one)
    if [ ! -f "$model_list" ]; then continue; fi

    # Skip if collector already ran
    if [ -f "${sp_dir}/model_results_v2.rds" ]; then continue; fi

    # Count models (subtract header)
    N_MODELS=$(( $(wc -l < "$model_list") - 1 ))
    if [ "$N_MODELS" -le 0 ]; then continue; fi

    # Check how many already done
    N_DONE=$(ls "${sp_dir}/phase2_results/"*.done 2>/dev/null | wc -l || echo 0)
    if [ "$N_DONE" -ge "$N_MODELS" ]; then
      log "  $sp: all $N_MODELS 3-var models done. Skip."
      continue
    fi

    ARRAY_SPEC="1-${N_MODELS}%${MAX_CONCURRENT}"

    if $DRY_RUN; then
      log "[DRY RUN] sbatch --array=${ARRAY_SPEC} templates/xsdm_v2_3var_L1.sbatch '${sp}'"
    else
      cd "$PROJECT_ROOT"
      mkdir -p logs
      JOBID=$(sbatch --parsable --array="${ARRAY_SPEC}" \
        templates/xsdm_v2_3var_L1.sbatch "$sp")
      log "  $sp: job $JOBID ($N_MODELS models, ${MAX_CONCURRENT} concurrent)"
      SUBMITTED=$((SUBMITTED + 1))
    fi

    # Brief pause every 20 species to not flood Slurm
    if [ $((SUBMITTED % 20)) -eq 0 ]; then sleep 2; fi
  done < "$LIST"

  log "Phase 3var submission complete ($SUBMITTED species submitted)"
}

# ── Phase collect ──
submit_collect() {
  log "=== Phase collect: Submitting final assembly ==="

  PENDING=()
  while IFS= read -r sp; do
    sp_safe="$(echo "$sp" | tr ' ' '_')"
    sp_dir="${RESULTS_DIR}/${sp_safe}"

    # Need phase1_results to exist
    if [ ! -f "${sp_dir}/phase1_results/phase1_results.rds" ]; then continue; fi
    # Skip if already has final results
    if [ -f "${sp_dir}/model_results_v2.rds" ]; then continue; fi

    PENDING+=("$sp")
  done < "$LIST"

  N_PENDING=${#PENDING[@]}
  log "Pending collectors: $N_PENDING"

  if [ "$N_PENDING" -eq 0 ]; then
    log "All species have final results or aren't ready. Skipping."
    return
  fi

  PENDING_LIST=$(mktemp /tmp/v2_pending_collect_XXXXXX.txt)
  printf '%s\n' "${PENDING[@]}" > "$PENDING_LIST"
  N_PENDING=$(wc -l < "$PENDING_LIST" | tr -d ' ')

  FROM=1
  while [ "$FROM" -le "$N_PENDING" ]; do
    TO=$((FROM + BATCH_SIZE - 1))
    [ "$TO" -gt "$N_PENDING" ] && TO="$N_PENDING"
    ARRAY_SPEC="${FROM}-${TO}%${MAX_CONCURRENT}"

    if $DRY_RUN; then
      log "[DRY RUN] sbatch --array=${ARRAY_SPEC} templates/xsdm_v2_collect.sbatch ${PENDING_LIST}"
    else
      cd "$PROJECT_ROOT"
      mkdir -p logs
      JOBID=$(sbatch --parsable --array="${ARRAY_SPEC}" \
        templates/xsdm_v2_collect.sbatch "$PENDING_LIST")
      log "Submitted: job $JOBID (${N_PENDING} species)"
    fi

    FROM=$((TO + 1))
    sleep 1
  done

  rm -f "$PENDING_LIST"
  log "Phase collect submission complete"
}

# ── Dispatch ──
case "$PHASE" in
  2var)    submit_2var ;;
  3var)    submit_3var ;;
  collect) submit_collect ;;
  all)
    submit_2var
    log "Phase 2var submitted. Run --phase 3var after Phase 2var completes."
    log "Then --phase collect after Phase 3var completes."
    ;;
  *) echo "Unknown phase: $PHASE"; exit 1 ;;
esac

log "═══════════════════════════════════════════════════"
log "Done."
log "═══════════════════════════════════════════════════"

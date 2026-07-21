#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# v2_orchestrator.sh — Persistent self-queuing orchestrator for v2 pipeline
# ─────────────────────────────────────────────────────────────────────
# Runs on kbs partition. Manages 3 phases: 2var → 3var → collect.
# Can be killed and restarted — auto-detects completed species.
#
# Usage: sbatch scripts/orchestration/v2_launcher.sh
#    or: bash scripts/orchestration/v2_orchestrator.sh
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# ── Configuration ───────────────────────────────────────────────────
SPECIES_LIST="${REPO_ROOT}/species_list_v2.txt"
RESULTS_DIR="/home/a474r867/scratch/xsdm_results"
TEMPLATE_2VAR="${REPO_ROOT}/templates/xsdm_v2_2var.sbatch"
TEMPLATE_3VAR="${REPO_ROOT}/templates/xsdm_v2_3var_L1.sbatch"
TEMPLATE_COLLECT="${REPO_ROOT}/templates/xsdm_v2_collect.sbatch"

SAFETY_CEILING=2000         # max concurrent xsdm tasks
BATCH_SIZE=200              # species per submission wave
SLEEP_INTERVAL=120          # seconds between submission cycles
PARTITION="sixhour"
WALLTIME="06:00:00"
MEM="16G"
CPUS=4

DRY_RUN=false

# ── Parse args ──────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --ceiling) SAFETY_CEILING="$2"; shift 2 ;;
        --batch) BATCH_SIZE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] $*"; }

# ── Count all xsdm tasks (any job name starting with xsdm) ──────────
count_xsdm_tasks() {
    local c
    c=$(squeue -u "$(whoami)" --noheader --format="%j" 2>/dev/null | grep -c '^xsdm' 2>/dev/null || true)
    echo "${c:-0}"
}

headroom() {
    local used
    used=$(count_xsdm_tasks | head -1)
    echo $((SAFETY_CEILING - used))
}

# ── Build list of pending species for a phase ───────────────────────
# Phase 2var: check phase1_results.rds
# Phase 3var: check phase2_results/ complete
# Phase collect: check model_results_v2.rds
get_pending() {
    local phase="$1"
    local pending_list="$2"
    > "$pending_list"

    while IFS= read -r sp; do
        [ -z "$sp" ] && continue
        local sp_safe="${sp// /_}"
        local sp_dir="${RESULTS_DIR}/${sp_safe}"

        case "$phase" in
            2var)
                # Skip if phase1_results.rds exists
                if [ -f "${sp_dir}/phase1_results/phase1_results.rds" ]; then
                    continue
                fi
                ;;
            3var)
                # Need phase1 done AND not yet collected
                if [ ! -f "${sp_dir}/phase1_results/phase1_results.rds" ]; then
                    continue  # 2var not done yet
                fi
                # Check if 3var model list exists
                if [ ! -f "${sp_dir}/3var_model_list.csv" ]; then
                    continue  # no 3var models to fit
                fi
                # Check if collector already ran
                if [ -f "${sp_dir}/model_results_v2.rds" ]; then
                    continue
                fi
                # Count done vs total 3var models
                local n_models=$(tail -n +2 "${sp_dir}/3var_model_list.csv" 2>/dev/null | wc -l)
                local n_done=$(ls "${sp_dir}/phase2_results/"*.done 2>/dev/null | wc -l)
                if [ "$n_done" -ge "$n_models" ] && [ "$n_models" -gt 0 ]; then
                    continue  # all 3var done
                fi
                ;;
            collect)
                if [ -f "${sp_dir}/model_results_v2.rds" ]; then
                    continue  # already done
                fi
                if [ ! -f "${sp_dir}/phase1_results/phase1_results.rds" ]; then
                    continue  # 2var not done
                fi
                ;;
        esac
        echo "$sp" >> "$pending_list"
    done < "$SPECIES_LIST"
}

# ── Submit phase ─────────────────────────────────────────────────────
submit_phase() {
    local phase="$1"
    local template="$2"
    local job_name="$3"

    local pending_list
    pending_list=$(mktemp /tmp/v2_pending_${phase}_XXXXXX.txt)
    get_pending "$phase" "$pending_list"
    local n_pending
    n_pending=$(wc -l < "$pending_list" | tr -d ' ')

    log "Phase ${phase}: ${n_pending} species pending"

    if [ "$n_pending" -eq 0 ]; then
        log "Phase ${phase}: all complete!"
        rm -f "$pending_list"
        return 0
    fi

    local submitted=0
    local idx=1

    while [ "$idx" -le "$n_pending" ]; do
        # Check headroom
        local room
        room=$(headroom)
        while [ "$room" -lt 1 ]; do
            log "Phase ${phase}: no headroom (${room}), waiting ${SLEEP_INTERVAL}s..."
            sleep "$SLEEP_INTERVAL"
            room=$(headroom)
        done

        # Submit one species as an individual job
        local sp
        sp=$(sed -n "${idx}p" "$pending_list")
        local sp_safe="${sp// /_}"

        if $DRY_RUN; then
            log "[DRY RUN] ${phase}: would submit ${sp} (${idx}/${n_pending}, room=${room})"
        else
            # Create temp single-species list (process substitution won't survive to compute node)
            local tmp_spfile
            tmp_spfile="/home/a474r867/scratch/tmp/xsdm_sp_${sp_safe}_$$.txt"
            mkdir -p "$(dirname "$tmp_spfile")"
            echo "$sp" > "$tmp_spfile"
            local job_id
            job_id=$(sbatch --parsable \
                --job-name="${job_name}" \
                --partition="${PARTITION}" \
                --time="${WALLTIME}" \
                --mem="${MEM}" \
                --cpus-per-task="${CPUS}" \
                --output="${REPO_ROOT}/logs/${job_name}_%j.out" \
                --error="${REPO_ROOT}/logs/${job_name}_%j.err" \
                "$template" \
                "$tmp_spfile" 2>/dev/null)
            log "Phase ${phase}: ${sp_safe} → job ${job_id} (${idx}/${n_pending}, room=${room})"
            # Schedule cleanup after job starts (2 min delay)
            (sleep 120 && rm -f "$tmp_spfile") &
        fi

        submitted=$((submitted + 1))
        idx=$((idx + 1))

        # Brief pause every 50 submissions
        if [ $((submitted % 50)) -eq 0 ] && [ "$idx" -le "$n_pending" ]; then
            sleep 2
        fi
    done

    rm -f "$pending_list"
    log "Phase ${phase}: submitted ${submitted} species"
    return 1  # signal that work was done (need to wait)
}

# ── Wait for phase completion ────────────────────────────────────────
wait_for_phase() {
    local phase="$1"
    local pending_list
    pending_list=$(mktemp /tmp/v2_wait_${phase}_XXXXXX.txt)

    while true; do
        get_pending "$phase" "$pending_list"
        local n_pending
        n_pending=$(wc -l < "$pending_list" | tr -d ' ')
        local n_running
        n_running=$(count_xsdm_tasks)

        if [ "$n_pending" -eq 0 ]; then
            log "Phase ${phase}: ALL DONE!"
            rm -f "$pending_list"
            return 0
        fi

        log "Phase ${phase}: ${n_pending} remaining, ${n_running} running — waiting ${SLEEP_INTERVAL}s..."
        sleep "$SLEEP_INTERVAL"
    done
}

# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

log "═══════════════════════════════════════════════════"
log "xsdm Pipeline v2 — Self-Queuing Orchestrator"
log "Species: $(wc -l < "$SPECIES_LIST" | tr -d ' ')"
log "Safety ceiling: ${SAFETY_CEILING}"
log "Batch size: ${BATCH_SIZE}"
log "Dry run: ${DRY_RUN}"
log "═══════════════════════════════════════════════════"

# ── PHASE 1: 2-var fitting ──────────────────────────────────────────
log ""
log ">>> PHASE 1: Two-variable fitting <<<"

PENDING_2VAR=$(mktemp /tmp/v2_pending_2var_main_XXXXXX.txt)
get_pending "2var" "$PENDING_2VAR"
N_2VAR=$(wc -l < "$PENDING_2VAR" | tr -d ' ')
rm -f "$PENDING_2VAR"

if [ "$N_2VAR" -gt 0 ]; then
    log "Phase 2var: ${N_2VAR} species need fitting"
    submit_phase "2var" "$TEMPLATE_2VAR" "xsdm_v2_2var"
    wait_for_phase "2var"
else
    log "Phase 2var: all species already have phase1_results.rds. Skipping."
fi

# ── PHASE 2: 3-var fitting ──────────────────────────────────────────
log ""
log ">>> PHASE 2: Three-variable fitting <<<"

PENDING_3VAR=$(mktemp /tmp/v2_pending_3var_main_XXXXXX.txt)
get_pending "3var" "$PENDING_3VAR"
N_3VAR=$(wc -l < "$PENDING_3VAR" | tr -d ' ')
rm -f "$PENDING_3VAR"

if [ "$N_3VAR" -gt 0 ]; then
    log "Phase 3var: ${N_3VAR} species need 3-var fitting"
    # For 3var, each species gets an array job (one task per model)
    # We submit these one species at a time, respecting ceiling
    submit_phase "3var" "$TEMPLATE_3VAR" "xsdm_v2_3var"
    wait_for_phase "3var"
else
    log "Phase 3var: all species complete or have no 3-var models. Skipping."
fi

# ── PHASE 3: Final collect ──────────────────────────────────────────
log ""
log ">>> PHASE 3: Final collection <<<"

PENDING_COLLECT=$(mktemp /tmp/v2_pending_collect_main_XXXXXX.txt)
get_pending "collect" "$PENDING_COLLECT"
N_COLLECT=$(wc -l < "$PENDING_COLLECT" | tr -d ' ')
rm -f "$PENDING_COLLECT"

if [ "$N_COLLECT" -gt 0 ]; then
    log "Phase collect: ${N_COLLECT} species need final assembly"
    submit_phase "collect" "$TEMPLATE_COLLECT" "xsdm_v2_collect"
    wait_for_phase "collect"
else
    log "Phase collect: all species complete. Skipping."
fi

log ""
log "═══════════════════════════════════════════════════"
log "ALL PHASES COMPLETE!"
log "═══════════════════════════════════════════════════"

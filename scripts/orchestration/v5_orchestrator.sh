#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
# v5_orchestrator.sh — job arrays + submission tracking + 4000 concurrent
#
# FIX 3: Submission tracking — .model_NN_submitted markers prevent re-submit
# FIX 4: Job arrays — single sbatch --array=1-88 per species instead of 88 calls
#
# L1: 1 job array (88 tasks) per species
# L2/L3/L4: 1 single job per species
#
# Ceiling: 4000 concurrent xsdm_v5 jobs
# ──────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SPECIES_LIST="${REPO_ROOT}/species_list_v2.txt"
RESULTS_DIR="/home/a474r867/scratch/xsdm_1000_sp"
TEMPLATE="${REPO_ROOT}/templates/xsdm_v5.sbatch"

SAFETY_CEILING=4000
N_MODELS=88
SLEEP_INTERVAL=15
PARTITION="sixhour"
WALLTIME="02:00:00"
MEM="16G"
CPUS=8

DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --ceiling) SAFETY_CEILING="$2"; shift 2 ;;
        --sleep) SLEEP_INTERVAL="$2"; shift 2 ;;
        *) shift ;;
    esac
done

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] $*"; }

count_jobs() {
    local c
    c=$(squeue -u "$(whoami)" --noheader --format="%j" 2>/dev/null | grep -cE '^xsdm_v5' 2>/dev/null || true)
    echo "${c:-0}"
}

headroom() {
    local used; used=$(count_jobs)
    echo $((SAFETY_CEILING - used))
}

# Count completed L1 model markers for a species
count_l1_models() {
    local sp_safe="$1"
    local mdir="${RESULTS_DIR}/${sp_safe}/phase1_results/L1_models"
    if [ ! -d "$mdir" ]; then echo 0; return; fi
    ls "$mdir"/.model_*_done 2>/dev/null | wc -l
}

# Count submitted-but-not-done L1 models (submitted marker exists, done doesn't)
count_l1_pending() {
    local sp_safe="$1"
    local mdir="${RESULTS_DIR}/${sp_safe}/phase1_results/L1_models"
    if [ ! -d "$mdir" ]; then echo 0; return; fi
    local pending=0
    for mi in $(seq 1 $N_MODELS); do
        local sub_marker="${mdir}/.model_$(printf '%02d' $mi)_submitted"
        local done_marker="${mdir}/.model_$(printf '%02d' $mi)_done"
        if [ -f "$sub_marker" ] && [ ! -f "$done_marker" ]; then
            pending=$((pending + 1))
        fi
    done
    echo $pending
}

# Determine next stage
get_next_stage() {
    local sp_safe="$1"
    local p1_dir="${RESULTS_DIR}/${sp_safe}/phase1_results"
    local n_models=$(count_l1_models "$sp_safe")
    local n_pending=$(count_l1_pending "$sp_safe")

    # L1: need all N_MODELS done AND no pending submissions
    if [ "$n_pending" -gt 0 ]; then
        echo "L1_PENDING"   # submitted but not done yet — wait
    elif [ "$n_models" -lt "$N_MODELS" ]; then
        echo "L1"
    elif [ ! -f "${p1_dir}/.L2_done" ]; then
        echo "L2"
    elif [ ! -f "${p1_dir}/.L3_done" ]; then
        echo "L3"
    elif [ ! -f "${p1_dir}/.L4_done" ]; then
        echo "L4"
    else
        echo "DONE"
    fi
}

# Submit L1 as a job array
submit_l1_array() {
    local sp="$1"
    local sp_safe="${sp// /_}"

    if $DRY_RUN; then
        log "[DRY] ${sp_safe} L1 array (88 tasks)"
        return 0
    fi

    sbatch --parsable \
        --job-name="xsdm_v5_L1" \
        --partition="${PARTITION}" \
        --time="${WALLTIME}" \
        --mem="${MEM}" \
        --cpus-per-task="${CPUS}" \
        --array="1-${N_MODELS}" \
        --output="/home/a474r867/scratch/logs/xsdm_v5_%A_%a.out" \
        --error="/home/a474r867/scratch/logs/xsdm_v5_%A_%a.err" \
        "$TEMPLATE" "$sp" "L1_model" 2>/dev/null
}

# Submit a single job (L2/L3/L4)
submit_job() {
    local sp="$1"; local stage="$2"
    local sp_safe="${sp// /_}"

    if $DRY_RUN; then
        log "[DRY] ${sp_safe} stage=${stage}"
        return 0
    fi

    sbatch --parsable \
        --job-name="xsdm_v5_${stage}" \
        --partition="${PARTITION}" \
        --time="${WALLTIME}" \
        --mem="${MEM}" \
        --cpus-per-task="${CPUS}" \
        --output="/home/a474r867/scratch/logs/xsdm_v5_%j.out" \
        --error="/home/a474r867/scratch/logs/xsdm_v5_%j.err" \
        "$TEMPLATE" "$sp" "$stage" 2>/dev/null
}

# Write submitted markers for ALL L1 models (FIX 3)
mark_all_submitted() {
    local sp="$1"
    local sp_safe="${sp// /_}"   # BUGFIX: underscores (was "${sp// /}" stripping spaces)
    local mdir="${RESULTS_DIR}/${sp_safe}/phase1_results/L1_models"
    mkdir -p "$mdir"
    for mi in $(seq 1 $N_MODELS); do
        local marker="${mdir}/.model_$(printf '%02d' $mi)_submitted"
        [ ! -f "$marker" ] && touch "$marker"
    done
}

# Check if any previously submitted L1 array is still alive
l1_array_alive() {
    local sp="$1"
    local sp_safe="${sp// /_}"   # BUGFIX: underscores (was "${sp// /}" stripping spaces)
    # Check if there are any pending/running xsdm_v5 jobs for this species
    # with L1 in the name (array jobs show as xsdm_v5_L1)
    squeue -u "$(whoami)" --noheader --format="%j %Z" 2>/dev/null | \
        grep "xsdm_v5_L1" | grep -q "${sp_safe}" 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

log "========================================="
log "xsdm v5 Orchestrator — arrays + tracking"
log "Species: $(wc -l < "$SPECIES_LIST" | tr -d ' ')"
log "Models/species: ${N_MODELS} (1 array)"
log "========================================="

CYCLE=0

while true; do
    CYCLE=$((CYCLE + 1))
    room=$(headroom)

    if [ "$room" -le 0 ]; then
        log "Cycle ${CYCLE}: FULL (${room}), sleeping ${SLEEP_INTERVAL}s"
        sleep "$SLEEP_INTERVAL"
        continue
    fi

    declare -A COUNTS
    COUNTS[L1]=0; COUNTS[L1_PENDING]=0; COUNTS[L2]=0; COUNTS[L3]=0; COUNTS[L4]=0
    COUNTS[DONE]=0; COUNTS[ERROR]=0
    SUBMITTED=0

    while IFS= read -r sp; do
        [ -z "$sp" ] && continue
        sp_safe="${sp// /_}"

        # Check env data
        if [ ! -d "/home/a474r867/scratch/xsdm_env_extraction_19/${sp_safe}" ]; then
            COUNTS[ERROR]=$((COUNTS[ERROR] + 1))
            continue
        fi

        next_stage=$(get_next_stage "$sp_safe")
        COUNTS[$next_stage]=$((COUNTS[$next_stage] + 1))

        case "$next_stage" in
            DONE|ERROR)
                continue
                ;;
            L1_PENDING)
                # BUGFIX: check if array still alive; if not, clear markers and retry
                if ! l1_array_alive "$sp"; then
                    log "  ${sp_safe}: L1 array dead, clearing submitted markers for retry"
                    local mdir="${RESULTS_DIR}/${sp_safe}/phase1_results/L1_models"
                    rm -f "${mdir}"/.model_*_submitted
                    next_stage="L1"
                    COUNTS[L1]=$((COUNTS[L1] + 1))
                    COUNTS[L1_PENDING]=$((COUNTS[L1_PENDING] - 1))
                else
                    continue
                fi
                ;;&  # fall through to L1 handling below
            L1)
                # FIX 3+4: Submit as a single job array, mark all as submitted
                room=$(headroom)
                if [ "$room" -le $N_MODELS ]; then
                    log "  L1 headroom exhausted (need ${N_MODELS}, have ${room})"
                    break
                fi
                mdir="${RESULTS_DIR}/${sp_safe}/phase1_results/L1_models"
                mkdir -p "$mdir"
                mark_all_submitted "$sp"
                jid=$(submit_l1_array "$sp")
                if [ -n "$jid" ]; then
                    SUBMITTED=$((SUBMITTED + N_MODELS))
                    log "  ${sp_safe}: L1 array submitted (jid=${jid})"
                fi
                ;;
            L2|L3|L4)
                room=$(headroom)
                if [ "$room" -le 1 ]; then break; fi
                jid=$(submit_job "$sp" "$next_stage")
                if [ -n "$jid" ]; then
                    SUBMITTED=$((SUBMITTED + 1))
                fi
                ;;
        esac

    done < "$SPECIES_LIST"

    RUNNING=$(count_jobs)
    TOTAL=$((COUNTS[L1] + COUNTS[L1_PENDING] + COUNTS[L2] + COUNTS[L3] + COUNTS[L4] + COUNTS[DONE] + COUNTS[ERROR]))
    PCT=$(echo "scale=1; ${COUNTS[DONE]} * 100 / ${TOTAL}" | bc 2>/dev/null || echo 0)

    log "Cycle ${CYCLE}: L1=${COUNTS[L1]} L1_PEND=${COUNTS[L1_PENDING]} L2=${COUNTS[L2]} L3=${COUNTS[L3]} L4=${COUNTS[L4]} DONE=${COUNTS[DONE]} ERR=${COUNTS[ERROR]} | running=${RUNNING} submitted=${SUBMITTED} room=${room} | ${PCT}%"

    if [ "${COUNTS[DONE]}" -gt 0 ] && [ "${COUNTS[DONE]}" -eq "$TOTAL" ]; then
        log "ALL ${COUNTS[DONE]} SPECIES COMPLETE!"
        exit 0
    fi

    sleep "$SLEEP_INTERVAL"
done

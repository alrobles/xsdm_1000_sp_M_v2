#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# v4_orchestrator.sh — 4000 concurrent jobs, 1 job/model at L1
#
# L1: 88 model jobs per species (1 per 2-var combination)
# L2/L3/L4: 1 aggregation job per species
#
# Ceiling: 4000 concurrent xsdm_v4 jobs
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SPECIES_LIST="${REPO_ROOT}/species_list_v2.txt"
RESULTS_DIR="/home/a474r867/scratch/xsdm_1000_sp"
TEMPLATE="${REPO_ROOT}/templates/xsdm_v4.sbatch"

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
    c=$(squeue -u "$(whoami)" --noheader --format="%j" 2>/dev/null | grep -cE '^xsdm_v4' 2>/dev/null || true)
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

# Determine next stage
get_next_stage() {
    local sp_safe="$1"
    local p1_dir="${RESULTS_DIR}/${sp_safe}/phase1_results"
    local n_models=$(count_l1_models "$sp_safe")

    # L1: need all N_MODELS model markers
    if [ "$n_models" -lt "$N_MODELS" ]; then
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

# Submit a single job
submit_job() {
    local sp="$1"; local stage="$2"; local model_idx="${3:-}"
    local sp_safe="${sp// /_}"

    if $DRY_RUN; then
        log "[DRY] ${sp_safe} stage=${stage}${model_idx:+ model=$model_idx}"
        return 0
    fi

    local job_name="xsdm_v4_${stage}"
    local extra_args=""
    [ -n "$model_idx" ] && extra_args="$model_idx"

    sbatch --parsable \
        --job-name="${job_name}" \
        --partition="${PARTITION}" \
        --time="${WALLTIME}" \
        --mem="${MEM}" \
        --cpus-per-task="${CPUS}" \
        --output="/home/a474r867/scratch/logs/xsdm_v4_%j.out" \
        --error="/home/a474r867/scratch/logs/xsdm_v4_%j.err" \
        "$TEMPLATE" "$sp" "$stage" $extra_args 2>/dev/null
}

# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

log "========================================="
log "xsdm v4 Orchestrator — 4000 concurrent"
log "Species: $(wc -l < "$SPECIES_LIST" | tr -d ' ')"
log "Models/species: ${N_MODELS}"
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
    COUNTS[L1]=0; COUNTS[L2]=0; COUNTS[L3]=0; COUNTS[L4]=0
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

        if [ "$next_stage" = "DONE" ] || [ "$next_stage" = "ERROR" ]; then
            continue
        fi

        # L1: submit missing model jobs
        if [ "$next_stage" = "L1" ]; then
            mdir="${RESULTS_DIR}/${sp_safe}/phase1_results/L1_models"
            for mi in $(seq 1 $N_MODELS); do
                room=$(headroom)
                if [ "$room" -le 1 ]; then
                    log "  L1 headroom exhausted at model $((mi-1))"
                    break 2  # break out of species loop
                fi
                marker="${mdir}/.model_$(printf '%02d' $mi)_done"
                if [ ! -f "$marker" ]; then
                    jid=$(submit_job "$sp" "L1_model" "$mi")
                    if [ -n "$jid" ]; then
                        SUBMITTED=$((SUBMITTED + 1))
                    fi
                    # Small pause every 200 submissions
                    if [ $((SUBMITTED % 200)) -eq 0 ]; then
                        sleep 0.5
                    fi
                fi
            done
        else
            # L2/L3/L4: single job
            room=$(headroom)
            if [ "$room" -le 1 ]; then break; fi
            jid=$(submit_job "$sp" "$next_stage")
            if [ -n "$jid" ]; then
                SUBMITTED=$((SUBMITTED + 1))
            fi
        fi

        [ $((SUBMITTED % 50)) -eq 0 ] && sleep 0.2

    done < "$SPECIES_LIST"

    RUNNING=$(count_jobs)
    TOTAL=$((COUNTS[L1] + COUNTS[L2] + COUNTS[L3] + COUNTS[L4] + COUNTS[DONE] + COUNTS[ERROR]))
    PCT=$(echo "scale=1; ${COUNTS[DONE]} * 100 / ${TOTAL}" | bc 2>/dev/null || echo 0)

    log "Cycle ${CYCLE}: L1=${COUNTS[L1]} L2=${COUNTS[L2]} L3=${COUNTS[L3]} L4=${COUNTS[L4]} DONE=${COUNTS[DONE]} ERR=${COUNTS[ERROR]} | running=${RUNNING} submitted=${SUBMITTED} room=${room} | ${PCT}%"

    if [ "${COUNTS[DONE]}" -gt 0 ] && [ "${COUNTS[DONE]}" -eq "$TOTAL" ]; then
        log "ALL ${COUNTS[DONE]} SPECIES COMPLETE!"
        exit 0
    fi

    sleep "$SLEEP_INTERVAL"
done

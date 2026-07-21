#!/bin/bash
# benchmark_orchestrator.sh — Persistent kbs orchestrator for 10sp × 3 methods
# Monitors each species independently, chains L1→L2→L3→L4 per method
# Submit as: sbatch --partition=kbs --time=24:00:00 --mem=4G --cpus-per-task=2 \
#             --output=... benchmark_orchestrator.sh
set -euo pipefail

SPECIES_LIST="/home/a474r867/work/xsdm_1000_sp/species_list_benchmark10.txt"
TEMPLATE="/home/a474r867/work/xsdm_1000_sp/templates/xsdm_v5.sbatch"
SCRATCH="/home/a474r867/scratch"
LOG_DIR="${SCRATCH}/logs"
RESULTS_BASE="${SCRATCH}/xsdm_benchmark_results"
L1_SOURCE="${SCRATCH}/xsdm_1000_sp"

METHODS=("tau_raw" "raftery_10" "raftery_6")
STAGES=("L2" "L3" "L4")
N_MODELS=88
SLEEP=15

mkdir -p "${LOG_DIR}" "${RESULTS_BASE}"

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(ts)] $*"; }

# ── Helpers ──
count_l1_done() { ls "$1"/.model_*_done 2>/dev/null | wc -l; }
stage_done()  { test -f "$1/.${2}_done" && echo 1 || echo 0; }

submit_job() {
    local sp="$1" sp_safe="$2" stage="$3" method="$4" out_dir="$5"
    sbatch --parsable \
        --job-name="bm_${method}_${stage}" \
        --partition=sixhour --account=kbs \
        --time=02:00:00 --mem=16G --cpus-per-task=8 \
        --output="${LOG_DIR}/bm_${method}_${sp_safe}_${stage}_%j.out" \
        --error="${LOG_DIR}/bm_${method}_${sp_safe}_${stage}_%j.err" \
        "$TEMPLATE" "$sp" "$stage" "$method" "$out_dir" 2>/dev/null
}

# ── Load species ──
mapfile -t SPECIES < "$SPECIES_LIST"

# ── Track state per species+method ──
# sp_state[sp_safe] = L1|L1_PENDING|L2|L2_PENDING|L3|L3_PENDING|L4|L4_PENDING|DONE
declare -A SP_STATE

# ── Init: detect current state ──
for sp in "${SPECIES[@]}"; do
    [ -z "$sp" ] && continue
    sp_safe="${sp// /_}"
    l1_dir="${L1_SOURCE}/${sp_safe}/phase1_results/L1_models"

    # Ensure L1 submitted markers exist
    if [ ! -d "$l1_dir" ]; then
        mkdir -p "$l1_dir"
        for mi in $(seq 1 $N_MODELS); do
            touch "${l1_dir}/.model_$(printf '%02d' $mi)_submitted"
        done
    fi

    n_done=$(count_l1_done "$l1_dir")
    if [ "$n_done" -ge "$N_MODELS" ]; then
        SP_STATE["${sp_safe}"]="L2"
    elif squeue -u "$(whoami)" --noheader --format="%j" 2>/dev/null | grep -q "xsdm_v5_L1"; then
        SP_STATE["${sp_safe}"]="L1_PENDING"
    else
        SP_STATE["${sp_safe}"]="L1"
    fi
done

log "=== Benchmark Orchestrator ==="
log "Species: ${#SPECIES[@]} | Methods: ${METHODS[*]}"
log ""

# ── Init summaries ──
for method in "${METHODS[@]}"; do
    echo "species,method,M_Omega,Omega,well_behaved" > "${RESULTS_BASE}/summary_${method}.csv"
done

# ════════════════════════════════════════════════════════════════
# MAIN LOOP
# ════════════════════════════════════════════════════════════════
CYCLE=0
while true; do
    CYCLE=$((CYCLE + 1))
    all_done=true
    submitted=0

    for sp in "${SPECIES[@]}"; do
        [ -z "$sp" ] && continue
        sp_safe="${sp// /_}"
        state="${SP_STATE[${sp_safe}]:-L1}"
        l1_dir="${L1_SOURCE}/${sp_safe}/phase1_results/L1_models"

        # ── L1 handling ──
        if [ "$state" = "L1" ]; then
            all_done=false
            n_done=$(count_l1_done "$l1_dir")
            if [ "$n_done" -ge "$N_MODELS" ]; then
                SP_STATE["${sp_safe}"]="L2"
                log "${sp_safe}: L1 complete → L2"
            fi
            continue
        fi

        if [ "$state" = "L1_PENDING" ]; then
            all_done=false
            n_done=$(count_l1_done "$l1_dir")
            if [ "$n_done" -ge "$N_MODELS" ]; then
                SP_STATE["${sp_safe}"]="L2"
                log "${sp_safe}: L1 complete → L2"
            fi
            continue
        fi

        # ── Per-method L2→L3→L4 ──
        for method in "${METHODS[@]}"; do
            OUT_BASE="${SCRATCH}/xsdm_1000_sp_${method}"
            p1="${OUT_BASE}/${sp_safe}/phase1_results"

            # Copy L1 if needed
            if [ ! -d "${p1}/L1_models" ] || [ "$(ls ${p1}/L1_models/*.rds 2>/dev/null | wc -l)" -lt "$N_MODELS" ]; then
                mkdir -p "${p1}/L1_models"
                cp -n "${l1_dir}/"*.rds "${p1}/L1_models/" 2>/dev/null || true
            fi

            # Determine stage for this species+method
            mstate="L2"  # default after L1
            for stage in L2 L3 L4; do
                if [ "$(stage_done "$p1" "$stage")" = "0" ]; then
                    mstate="$stage"
                    break
                fi
                mstate="DONE"
            done

            if [ "$mstate" = "DONE" ]; then
                continue  # this method done for this species
            fi

            all_done=false

            # Check if already submitted (job running)
            if squeue -u "$(whoami)" --noheader --format="%j" 2>/dev/null | grep -q "bm_${method}_${mstate}"; then
                continue  # still running
            fi

            # Submit next stage
            jid=$(submit_job "$sp" "$sp_safe" "$mstate" "$method" "$OUT_BASE")
            if [ -n "$jid" ]; then
                submitted=$((submitted + 1))
                log "  ${sp_safe}/${method}: ${mstate} (jid=${jid})"
            fi
        done
    done

    # ── Cycle summary ──
    if $all_done; then
        log ""
        log "=== ALL SPECIES × METHODS COMPLETE ==="
        break
    fi

    if [ "$submitted" -gt 0 ]; then
        log "Cycle ${CYCLE}: submitted ${submitted} jobs | $(date +%H:%M:%S)"
    fi

    sleep "$SLEEP"
done

# ════════════════════════════════════════════════════════════════
# COLLECT RESULTS
# ════════════════════════════════════════════════════════════════
log "=== Collecting results ==="
for method in "${METHODS[@]}"; do
    OUT_BASE="${SCRATCH}/xsdm_1000_sp_${method}"
    summary="${RESULTS_BASE}/summary_${method}.csv"
    echo "species,method,M_Omega,Omega,well_behaved" > "$summary"

    for sp in "${SPECIES[@]}"; do
        [ -z "$sp" ] && continue
        sp_safe="${sp// /_}"
        p1="${OUT_BASE}/${sp_safe}/phase1_results"

        if [ -f "${p1}/.L4_done" ]; then
            result=$(apptainer exec --cleanenv --bind "${SCRATCH}:${SCRATCH}" \
                /home/a474r867/geospatial-rserver/xsdm_latest.sif \
                Rscript -e '
                  x <- readRDS("'${p1}/phase1_results.rds'")
                  mo <- x$M_Omega
                  om <- x$Omega
                  wb <- if (!is.null(x$all_models) && mo %in% names(x$all_models)) {
                    fm <- x$all_models[[mo]]
                    if (!is.null(fm$well_behaved)) fm$well_behaved else "NA"
                  } else "NA"
                  cat(sprintf("%s,%.1f,%s", mo, om, wb))
                ' 2>/dev/null || echo "?,?,?")
            echo "${sp_safe},${method},${result}" >> "$summary"
        else
            echo "${sp_safe},${method},FAILED,," >> "$summary"
        fi
    done
done

log "=== Results ==="
for method in "${METHODS[@]}"; do
    f="${RESULTS_BASE}/summary_${method}.csv"
    n_ok=$(tail -n +2 "$f" 2>/dev/null | grep -cv FAILED || echo 0)
    echo "${method}: ${n_ok}/10 species complete"
done
log "Detailed: ${RESULTS_BASE}/summary_*.csv"

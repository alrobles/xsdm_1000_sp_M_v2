#!/bin/bash
# monitor_species.sh — single-species xsdm v5 progress monitor
# Usage: ./monitor_species.sh "Breviceps montanus" [interval_seconds]
set -euo pipefail

SP="${1:?Usage: monitor_species.sh <Species Name> [interval]}"
INTERVAL="${2:-15}"
SP_SAFE="${SP// /_}"
RESULTS="/home/a474r867/scratch/xsdm_1000_sp/${SP_SAFE}"
L1_DIR="${RESULTS}/phase1_results/L1_models"
P1_DIR="${RESULTS}/phase1_results"

N_MODELS=88

ts() { date '+%H:%M:%S'; }

while true; do
    clear 2>/dev/null || true
    echo "═══════════════════════════════════════════════════════"
    echo " xSDM v5 Monitor — ${SP}"
    echo " $(ts) | refresh: ${INTERVAL}s"
    echo "═══════════════════════════════════════════════════════"

    # ── L1 progress ──
    n_done=$(ls "${L1_DIR}"/.model_*_done 2>/dev/null | wc -l)
    n_sub=$(ls "${L1_DIR}"/.model_*_submitted 2>/dev/null | wc -l)
    n_rds=$(ls "${L1_DIR}"/model_*.rds 2>/dev/null | wc -l)

    echo ""
    echo "── L1 (2-var models) ──"
    printf "  Done:       %3d / %d\n" "$n_done" "$N_MODELS"
    printf "  Submitted:  %3d / %d\n" "$n_sub" "$N_MODELS"
    printf "  RDS files:  %3d / %d\n" "$n_rds" "$N_MODELS"

    # ── Check for failed tasks (submitted but no done marker) ──
    n_stuck=0
    for mi in $(seq 1 $N_MODELS); do
        sub="${L1_DIR}/.model_$(printf '%02d' $mi)_submitted"
        done_m="${L1_DIR}/.model_$(printf '%02d' $mi)_done"
        if [ -f "$sub" ] && [ ! -f "$done_m" ]; then
            n_stuck=$((n_stuck + 1))
        fi
    done
    if [ "$n_stuck" -gt 0 ]; then
        echo "  ⚠ Stuck (submitted, no done): ${n_stuck}"
    fi

    # ── Stage markers ──
    echo ""
    echo "── Pipeline Stages ──"
    for stage in L1 L2 L3 L4; do
        if [ -f "${P1_DIR}/.${stage}_done" ]; then
            echo "  ✅ ${stage}  COMPLETE"
        else
            echo "  ⬜ ${stage}  pending"
        fi
    done

    # ── Any xsdm jobs for this species ──
    echo ""
    echo "── Running Jobs ──"
    squeue -u "$(whoami)" --noheader --format="%i %j %T %M" 2>/dev/null | grep -i xsdm | head -5 || echo "  (none)"

    # ── Recent failures ──
    echo ""
    echo "── Recent Failures (last 10) ──"
    sacct -u "$(whoami)" --noheader --format="JobID,State,ExitCode" -X -S "$(date -d '2 hours ago' '+%Y-%m-%dT%H:%M')" 2>/dev/null | grep -i xsdm | grep -v "COMPLETED\|RUNNING\|PENDING" | head -10 || echo "  (none)"

    # ── Check completion ──
    if [ "$n_done" -ge "$N_MODELS" ]; then
        echo ""
        echo "═══════════════════════════════════════════════════════"
        echo " ✅ L1 COMPLETE — ${n_done}/${N_MODELS} models done"
        echo "    Ready for: sbatch xsdm_v5.sbatch \"${SP}\" L2"
        echo "═══════════════════════════════════════════════════════"
    fi

    sleep "$INTERVAL"
done

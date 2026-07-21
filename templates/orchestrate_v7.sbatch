#!/bin/bash
#SBATCH --job-name=v7_orchestrator
#SBATCH --partition=kbs
#SBATCH --time=7-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --account=kbs
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/orchestrator_v7_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/orchestrator_v7_%j.err
#
# xsdm v7 Orchestrator launcher — runs on kbs (unlimited time).
# Launches per-model worker jobs on sixhour for L1, L2, L4, profile and map.
#
# Usage:
#   sbatch orchestrate_v7.sbatch --species "Pheugopedius maculipectus"
#   sbatch orchestrate_v7.sbatch --species_list species_list_v7.txt
#   sbatch orchestrate_v7.sbatch --species_list species_list_v7.txt --max_concurrent 50

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
ORCHESTRATOR="${REPO_ROOT}/scripts/orchestrate_v7.sh"
export APPTAINERENV_APPLY_PREFILTER="false"

chmod +x "${ORCHESTRATOR}"
bash "${ORCHESTRATOR}" "$@"

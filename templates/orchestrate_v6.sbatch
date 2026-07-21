#!/bin/bash
#SBATCH --job-name=v6_orchestrator
#SBATCH --partition=kbs
#SBATCH --time=7-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --account=kbs
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v6_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v6_%j.err
#
# xsdm v6 Orchestrator launcher — runs on kbs (unlimited time, never preempted)
#
# Usage:
#   sbatch orchestrate_v6.sbatch --species "Oryctolagus cuniculus"
#   sbatch orchestrate_v6.sbatch --species_list species_list_v2.txt
#   sbatch orchestrate_v6.sbatch --species_list species_list_v2.txt --max_concurrent 200
#
# The orchestrator itself is lightweight (1 CPU, 4GB). It launches heavy worker
# jobs on sixhour partition as separate sbatch submissions.

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
ORCHESTRATOR="${REPO_ROOT}/scripts/orchestrate_v6.sh"
export APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER:-true}"

chmod +x "${ORCHESTRATOR}"
bash "${ORCHESTRATOR}" "$@"

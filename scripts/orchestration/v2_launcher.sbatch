#!/bin/bash
#SBATCH --job-name=xsdm_v2_orch
#SBATCH --partition=kbs
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator/orch_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator/orch_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
mkdir -p "${REPO_ROOT}/logs/orchestrator"

exec bash "${REPO_ROOT}/scripts/orchestration/v2_orchestrator.sh" "$@"

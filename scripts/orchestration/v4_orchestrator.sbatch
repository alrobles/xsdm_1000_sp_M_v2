#!/bin/bash
#SBATCH --job-name=xsdm_v4_orch
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=7-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=/home/a474r867/scratch/logs/xsdm_v4_orch_%j.out
#SBATCH --error=/home/a474r867/scratch/logs/xsdm_v4_orch_%j.err
# ─────────────────────────────────────────────────────────────────────
# Launch v4 orchestrator on kbs (7-day walltime)
# Ceiling: 4000 concurrent jobs, 88 model jobs/species at L1
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p /home/a474r867/scratch/logs

exec bash "${REPO_ROOT}/scripts/orchestration/v4_orchestrator.sh" "$@"

#!/bin/bash
#SBATCH --job-name=submit_v8_Acris_blanchardi
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=00:05:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/submit_v8_Acris_blanchardi_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/submit_v8_Acris_blanchardi_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"

PREP_ID=$(sbatch "${REPO_ROOT}/templates/prepare_v8_Acris_blanchardi.sbatch" | awk '{print $NF}')
echo "PREP_ID=${PREP_ID}"

ORCH_ID=$(sbatch --dependency=afterok:"${PREP_ID}" \
  "${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch" | awk '{print $NF}')
echo "ORCH_ID=${ORCH_ID}"

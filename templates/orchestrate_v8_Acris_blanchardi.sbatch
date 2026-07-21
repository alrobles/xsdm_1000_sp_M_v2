#!/bin/bash
#SBATCH --job-name=orch_v8_Acris_blanchardi
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=2-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/orch_v8_Acris_blanchardi_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/orch_v8_Acris_blanchardi_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SPECIES="Acris blanchardi"

"${REPO_ROOT}/scripts/orchestrate_v8.sh" \
  --species "${SPECIES}" \
  --num_starts 100 \
  --max_concurrent 50

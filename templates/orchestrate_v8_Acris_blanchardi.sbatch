#!/bin/bash
#SBATCH --job-name=orch_v8_Acris
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=2-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/orch_v8_Acris_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/orch_v8_Acris_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SPECIES="Acris blanchardi"
OUTPUT_DIR="${OUTPUT_DIR:-${REPO_ROOT}/outputs}"
NUM_STARTS="${NUM_STARTS:-100}"
MAX_CONCURRENT="${MAX_CONCURRENT:-50}"

export RESULTS_DIR="${OUTPUT_DIR}"
export ENV_CSV_DIR="${OUTPUT_DIR}"

"${REPO_ROOT}/scripts/orchestrate_v8.sh" \
  --species "${SPECIES}" \
  --num_starts "${NUM_STARTS}" \
  --max_concurrent "${MAX_CONCURRENT}"

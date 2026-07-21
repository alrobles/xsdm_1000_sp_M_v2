#!/bin/bash
#SBATCH --job-name=submit_v8_Acris_experiments
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=00:05:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/submit_v8_Acris_experiments_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/submit_v8_Acris_experiments_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"

echo "Submitting three v8 Acris blanchardi experiments"

PREP_CENTROID=$(sbatch "${REPO_ROOT}/templates/prepare_v8_Acris_blanchardi_centroid.sbatch" | awk '{print $NF}')
echo "PREP_CENTROID=${PREP_CENTROID}"
ORCH_CENTROID=$(sbatch --dependency=afterok:"${PREP_CENTROID}" --export=OUTPUT_DIR="${REPO_ROOT}/outputs_centroid" \
  "${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch" | awk '{print $NF}')
echo "ORCH_CENTROID=${ORCH_CENTROID}"

PREP_RANDOM=$(sbatch "${REPO_ROOT}/templates/prepare_v8_Acris_blanchardi_random.sbatch" | awk '{print $NF}')
echo "PREP_RANDOM=${PREP_RANDOM}"
ORCH_RANDOM=$(sbatch --dependency=afterok:"${PREP_RANDOM}" --export=OUTPUT_DIR="${REPO_ROOT}/outputs" \
  "${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch" | awk '{print $NF}')
echo "ORCH_RANDOM=${ORCH_RANDOM}"

PREP_BERTI=$(sbatch "${REPO_ROOT}/templates/prepare_v8_Acris_blanchardi_berti.sbatch" | awk '{print $NF}')
echo "PREP_BERTI=${PREP_BERTI}"
ORCH_BERTI=$(sbatch --dependency=afterok:"${PREP_BERTI}" --export=OUTPUT_DIR="${REPO_ROOT}/outputs_berti_sample" \
  "${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch" | awk '{print $NF}')
echo "ORCH_BERTI=${ORCH_BERTI}"

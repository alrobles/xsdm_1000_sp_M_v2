#!/bin/bash
#SBATCH --job-name=v7_orch_per_sp_M
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=2-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M/logs/orchestrator_v7/orch_per_sp_M_%A_%a.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M/logs/orchestrator_v7/orch_per_sp_M_%A_%a.err
set -euo pipefail
SPECIES_LIST="${1:?Usage: sbatch --array=1-N orchestrate_200_v7_M.sbatch species_list.txt}"
SPECIES_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SPECIES_LIST}")
if [ -z "${SPECIES_NAME}" ]; then
  echo "ERROR: No species at line ${SLURM_ARRAY_TASK_ID} in ${SPECIES_LIST}" >&2
  exit 1
fi
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M"
export REPO_ROOT
export NUM_STARTS=100
export NUM_THREADS=2
export WORKER_CPUS=2
export REUSE_EXISTING_FITS=1
export APPLY_PREFILTER=false
export SKIP_L2=1
export SKIP_L4=1
export MAX_CONCURRENT=200
export WORKER_TIME=5:55:00
export WORKER_PARTITION=sixhour
cd "${REPO_ROOT}"
bash "${REPO_ROOT}/scripts/orchestrate_v7.sh" \
  --species "${SPECIES_NAME}" \
  --num_starts 100 \
  --num_threads 2 \
  --worker_partition sixhour
EXIT_CODE=$?
echo "Finished: $(date) exit=${EXIT_CODE}"
exit ${EXIT_CODE}

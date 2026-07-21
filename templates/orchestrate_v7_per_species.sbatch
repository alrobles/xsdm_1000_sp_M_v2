#!/bin/bash
#SBATCH --job-name=v7_orch_per_sp
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=2-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/orchestrator_v7/orch_per_sp_%A_%a.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/orchestrator_v7/orch_per_sp_%A_%a.err
# One orchestrator per species, on kbs. Each orchestrator launches model jobs
# on sixhour. Use as: sbatch --array=1-100%152 orchestrate_v7_per_species.sbatch species_list.txt

set -euo pipefail

SPECIES_LIST="${1:?Usage: sbatch --array=1-N orchestrate_v7_per_species.sbatch species_list.txt}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
fi

SPECIES_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SPECIES_LIST}")
if [ -z "${SPECIES_NAME}" ]; then
  echo "ERROR: No species at line ${SLURM_ARRAY_TASK_ID} in ${SPECIES_LIST}"
  exit 1
fi

echo "==================================================="
echo "Array task: ${SLURM_ARRAY_TASK_ID}"
echo "Species:    ${SPECIES_NAME}"
echo "Node:       $(hostname)"
echo "Start:      $(date)"
echo "==================================================="

export NUM_STARTS=100
export NUM_THREADS=2
export WORKER_CPUS=2
export REUSE_EXISTING_FITS=1
export APPLY_PREFILTER=false
export SKIP_L2=1
export SKIP_L4=1
export MAX_CONCURRENT=200
# Give sixhour enough time for the slow 3-var 100-start fits.
export WORKER_TIME=5:55:00
export WORKER_PARTITION=sixhour

cd "${REPO_ROOT}"
bash "${REPO_ROOT}/scripts/orchestrate_v7.sh" \
  --species "${SPECIES_NAME}" \
  --num_starts 100 \
  --num_threads 2 \
  --worker_partition sixhour

EXIT_CODE=$?
echo "==================================================="
echo "Finished:   $(date)"
echo "Exit code:  ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

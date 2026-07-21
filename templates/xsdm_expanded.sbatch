#!/bin/bash
#SBATCH --job-name=xsdm_exp
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=06:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/exp_%A_%a.out
#SBATCH --error=logs/exp_%A_%a.err
# Expanded model selection (19 bioclim vars, 1-4 variable models)
# for species that FAILED with the original 6-var pipeline.
# Usage: sbatch --array=1-N%50 xsdm_expanded.sbatch failed_species.txt
#
# Output: /home/a474r867/scratch/xsdm_results_expanded/<Species_name>/

set -euo pipefail

SPECIES_LIST="${1:?Usage: sbatch --array=1-N xsdm_expanded.sbatch failed_species.txt}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

SPECIES_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SPECIES_LIST")
if [ -z "$SPECIES_NAME" ]; then
  echo "ERROR: No species at line ${SLURM_ARRAY_TASK_ID} in ${SPECIES_LIST}"
  exit 1
fi

echo "==================================================="
echo "Job ID:    ${SLURM_JOB_ID} (array ${SLURM_ARRAY_TASK_ID})"
echo "Species:   ${SPECIES_NAME}"
echo "Node:      $(hostname)"
echo "Task:      Expanded model selection (19 vars, 1-4 var models)"
echo "Start:     $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_expanded_models.R"

# Copy script to /tmp
SCRIPT_COPY=$(mktemp /tmp/xsdm_exp_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction_19" \
      --occ_dir "${SCRATCH}/xsdm_occurrences" \
      --output_dir "${SCRATCH}/xsdm_results_expanded" \
      --num_starts 25 \
      --num_threads ${SLURM_CPUS_PER_TASK:-4} \
      --top_k2 15 \
      --top_k3 10

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

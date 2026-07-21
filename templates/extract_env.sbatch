#!/bin/bash
#SBATCH --job-name=xsdm_env
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=01:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/env_%A_%a.out
#SBATCH --error=logs/env_%A_%a.err
# Extract bioclim environment at occurrence points for one species.
# Usage: sbatch --array=1-N%100 extract_env.sbatch species_list.txt
#
# Output: /home/a474r867/scratch/xsdm_env_extraction/<Species_name>/
#   T1_bio01.csv, T2_bio10.csv, T3_bio11.csv,
#   P1_bio12.csv, P2_bio16.csv, P3_bio17.csv, metadata.csv

set -euo pipefail

SPECIES_LIST="${1:?Usage: sbatch --array=1-N extract_env.sbatch species_list.txt}"

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
echo "Task:      Environment extraction"
echo "Start:     $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/extract_env_species.R"

# Copy script to /tmp to prevent git-checkout corruption
SCRIPT_COPY=$(mktemp /tmp/xsdm_env_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

export APPTAINERENV_OMP_NUM_THREADS=1

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --occ_dir "${SCRATCH}/xsdm_occurrences" \
      --bioclim_dir "${SCRATCH}/era5-land/era5_bioclim/bioclim" \
      --output_dir "${SCRATCH}/xsdm_env_extraction"

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

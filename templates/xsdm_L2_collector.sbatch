#!/bin/bash
#SBATCH --job-name=xsdm_L2
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/L2_%j.out
#SBATCH --error=logs/L2_%j.err
# ─────────────────────────────────────────────────────────────────────
# Split mode Phase B: collect L1 results → L2 boundary → L3 ranking →
# well-behavedness → L4 → profile likelihood → plots.
# Runs AFTER all 23 L1 tasks complete for a species.
# Usage: sbatch xsdm_L2_collector.sbatch "Genus species"
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SPECIES_NAME="${1:?Usage: sbatch xsdm_L2_collector.sbatch 'Genus species'}"

if [ -n "${SLURM_SUBMIT_DIR:-}" ]; then
    REPO_ROOT="${SLURM_SUBMIT_DIR}"
else
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

echo "==================================================="
echo "Job ID:    ${SLURM_JOB_ID}"
echo "Species:   ${SPECIES_NAME}"
echo "Node:      $(hostname)"
echo "Phase:     L2+ (collector)"
echo "Start:     $(date)"
echo "==================================================="

SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
SCRIPT="${REPO_ROOT}/scripts/r/xsdm_model_selection.R"

# Verify all 23 L1 models completed
SP_SAFE=$(echo "${SPECIES_NAME}" | tr ' ' '_')
L1_DIR="${SCRATCH}/xsdm_results/${SP_SAFE}/L1"
DONE_COUNT=$(ls "${L1_DIR}"/.model_*.done 2>/dev/null | wc -l)
if [ "${DONE_COUNT}" -lt 23 ]; then
    echo "ERROR: Only ${DONE_COUNT}/23 L1 models completed. Cannot collect."
    echo "Missing sentinels:"
    for i in $(seq 1 23); do
        [ ! -f "${L1_DIR}/.model_$(printf '%02d' $i).done" ] && \
            echo "  model_$(printf '%02d' $i)"
    done
    exit 1
fi

SCRIPT_COPY=$(mktemp /tmp/xsdm_L2_XXXXXX.R)
cp "${SCRIPT}" "${SCRIPT_COPY}"
trap "rm -f ${SCRIPT_COPY}" EXIT

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${SCRIPT_COPY}" \
      --species "${SPECIES_NAME}" \
      --env_csv_dir "${SCRATCH}/xsdm_env_extraction" \
      --output_dir "${SCRATCH}/xsdm_results" \
      --phase "L2+" \
      --num_starts 25 \
      --num_threads "${SLURM_CPUS_PER_TASK:-4}"

EXIT_CODE=$?
echo "==================================================="
echo "Finished:  $(date)"
echo "Exit code: ${EXIT_CODE}"
echo "==================================================="
exit ${EXIT_CODE}

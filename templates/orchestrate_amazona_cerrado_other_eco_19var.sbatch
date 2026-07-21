#!/bin/bash
#SBATCH --job-name=v19_amazona_cerrado_othereco
#SBATCH --partition=kbs
#SBATCH --time=7-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --account=kbs
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v19_amazona_cerrado_othereco_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v19_amazona_cerrado_othereco_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/geospatial_latest.sif"
RAW_OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences"
FILTERED_OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences_cerrado_other_eco"
ECOREGIONS="/home/a474r867/work/ecoregions/Ecoregions2017.shp"
SPECIES="Amazona aestiva"
FILTER_SCRIPT="${REPO_ROOT}/scripts/r/orchestrator/filter_occurrences_by_biome.R"
ORCHESTRATOR="${REPO_ROOT}/scripts/orchestrate_v6.sh"

export APPTAINERENV_OMP_NUM_THREADS=1
export APPTAINERENV_R_LIBS_USER="${HOME}/R/rocker-rstudio/4.2"
export MODEL_LABELS_OVERRIDE="T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,P1,P2,P3,P4,P5,P6,P7,P8"
# Disable the presence-box coordinate prefilter: presences are already bounded to
# the Cerrado polygon, and this run's background is deliberately in OTHER ecoregions
# (far from the presence box). The prefilter would trim nearly all that background.
export APPLY_PREFILTER=false

# Optional edit points: leave empty to keep all non-Cerrado background.
BACKGROUND_ECO_NAME=""
BACKGROUND_MULTIPLE=""

RAW_OCC_CSV="${RAW_OCC_DIR}/${SPECIES}.csv"
FILTERED_OCC_CSV="${FILTERED_OCC_DIR}/${SPECIES}.csv"

mkdir -p "${FILTERED_OCC_DIR}"

background_args=()
if [[ -n "${BACKGROUND_ECO_NAME}" ]]; then
  background_args+=(--background_eco_name "${BACKGROUND_ECO_NAME}")
fi
if [[ -n "${BACKGROUND_MULTIPLE}" ]]; then
  background_args+=(--background_multiple "${BACKGROUND_MULTIPLE}")
fi

apptainer exec --cleanenv \
  --bind "${RAW_OCC_DIR}:${RAW_OCC_DIR}:ro" \
  --bind "${FILTERED_OCC_DIR}:${FILTERED_OCC_DIR}" \
  --bind "${ECOREGIONS%/*}:${ECOREGIONS%/*}:ro" \
  --bind "${REPO_ROOT}:${REPO_ROOT}" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${FILTER_SCRIPT}" \
    --occ_csv "${RAW_OCC_CSV}" \
    --ecoregions "${ECOREGIONS}" \
    --eco_name 'Cerrado' \
    --background_outside_ecoregion true \
    ${background_args[@]+"${background_args[@]}"} \
    --output_csv "${FILTERED_OCC_CSV}"

export RESULTS_DIR="${REPO_ROOT}/output_19var_cerrado_othereco"
export OCC_DIR="${FILTERED_OCC_DIR}"
export OCC_CSV="${FILTERED_OCC_CSV}"
export REUSE_EXISTING_FITS=

chmod +x "${ORCHESTRATOR}"
bash "${ORCHESTRATOR}" --species "${SPECIES}"

#!/bin/bash
#SBATCH --job-name=v6_amazona_savanna
#SBATCH --partition=kbs
#SBATCH --time=7-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --account=kbs
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v6_amazona_savanna_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp/logs/orchestrator_v6_amazona_savanna_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/geospatial_latest.sif"
RAW_OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences"
FILTERED_OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences_grassland_savanna"
ECOREGIONS="/home/a474r867/work/ecoregions/Ecoregions2017.shp"
SPECIES="Amazona aestiva"
FILTER_SCRIPT="${REPO_ROOT}/scripts/r/orchestrator/filter_occurrences_by_biome.R"
ORCHESTRATOR="${REPO_ROOT}/scripts/orchestrate_v6.sh"

export APPTAINERENV_OMP_NUM_THREADS=1
export APPTAINERENV_R_LIBS_USER="${HOME}/R/rocker-rstudio/4.2"

RAW_OCC_CSV="${RAW_OCC_DIR}/${SPECIES}.csv"
FILTERED_OCC_CSV="${FILTERED_OCC_DIR}/${SPECIES}.csv"

mkdir -p "${FILTERED_OCC_DIR}"

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
    --biome_regex 'Grassland|Savanna' \
    --output_csv "${FILTERED_OCC_CSV}"

export RESULTS_DIR="${REPO_ROOT}/output_19var_savanna"
export OCC_DIR="${FILTERED_OCC_DIR}"
export OCC_CSV="${FILTERED_OCC_CSV}"
export REUSE_EXISTING_FITS=

chmod +x "${ORCHESTRATOR}"
bash "${ORCHESTRATOR}" --species "${SPECIES}"

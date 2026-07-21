#!/usr/bin/env bash
# run_v7_one_species.sh — Run the v7 ecoregion-based pipeline for one species.
# Usage: run_v7_one_species.sh "Species name"
set -euo pipefail

SPECIES="${1:-}"
if [ -z "$SPECIES" ]; then
  echo "Usage: $0 \"Species name\"" >&2
  exit 1
fi

SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
REPO_ROOT="${REPO_ROOT:-/home/a474r867/work/xsdm_1000_sp}"
OUTPUT_DIR="${REPO_ROOT}/outputs_M"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
BIOCLIM_DIR="${BIOCLIM_DIR:-/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim}"
ECO_SHP="${ECO_SHP:-/home/a474r867/work/ecoregions/Ecoregions2017.shp}"
OCC_DIR="${OCC_DIR:-${REPO_ROOT}/data/occurrences}"
OLD_OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences"
OCC_CSV="${OCC_DIR}/${SPECIES}.csv"
if [ ! -f "$OCC_CSV" ]; then
  OCC_CSV="${OCC_DIR}/${SP_SAFE}.csv"
fi
if [ ! -f "$OCC_CSV" ]; then
  OCC_CSV="${OLD_OCC_DIR}/${SPECIES}.csv"
fi
if [ ! -f "$OCC_CSV" ]; then
  OCC_CSV="${OLD_OCC_DIR}/${SP_SAFE}.csv"
fi
if [ ! -f "$OCC_CSV" ]; then
  echo "ERROR: occurrence CSV not found: $OCC_CSV" >&2
  exit 1
fi

NUM_STARTS="${NUM_STARTS:-40}"
NUM_THREADS="${NUM_THREADS:-8}"
PA_FACTOR="${PA_FACTOR:-1}"

mkdir -p "$OUTPUT_DIR"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"
export APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}"
export APPTAINERENV_OPENBLAS_NUM_THREADS="${NUM_THREADS}"

run_r() {
  apptainer exec --cleanenv \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    --bind "/home/a474r867/scratch:/home/a474r867/scratch" \
    --bind "/tmp:/tmp" \
    "$SIF" \
    Rscript "$@"
}

echo "==================================================="
echo "v7 pipeline: $SPECIES"
echo "==================================================="

# 1. Prepare inputs: ecoregion M, buffer, pseudo-absences, env CSVs
echo "[1/4] Preparing inputs..."
run_r "${REPO_ROOT}/scripts/r/prepare_inputs_v7.R" \
  --species "$SPECIES" \
  --occ_csv "$OCC_CSV" \
  --ecoregion_shp "$ECO_SHP" \
  --bioclim_dir "$BIOCLIM_DIR" \
  --output_dir "$OUTPUT_DIR" \
  --pa_factor "$PA_FACTOR"

# 2. Fit model selection (v6 algorithm) on v7 inputs
echo "[2/4] Fitting models..."
run_r "${REPO_ROOT}/scripts/r/xsdm_model_selection_v6.R" \
  --species "$SPECIES" \
  --env_csv_dir "$OUTPUT_DIR" \
  --output_dir "$OUTPUT_DIR" \
  --num_starts "$NUM_STARTS" \
  --num_threads "$NUM_THREADS"

# 3. Export selected model in predict_map-compatible format
echo "[3/4] Exporting selected model..."
run_r "${REPO_ROOT}/scripts/r/export_selected_model_v7.R" \
  --results_rds "${OUTPUT_DIR}/${SP_SAFE}/model_results_v6.rds" \
  --out_rds "${OUTPUT_DIR}/${SP_SAFE}/models/selected.rds"

# 4. Habitat suitability map + TSS inside M
echo "[4/4] Habitat suitability map and TSS..."
run_r "${REPO_ROOT}/scripts/r/orchestrator/predict_map_v7.R" \
  --species_dir "${OUTPUT_DIR}/${SP_SAFE}" \
  --model_rds "${OUTPUT_DIR}/${SP_SAFE}/models/selected.rds" \
  --occ_csv "${OUTPUT_DIR}/${SP_SAFE}/occ_v7.csv" \
  --bioclim_dir "$BIOCLIM_DIR" \
  --output_png "${OUTPUT_DIR}/${SP_SAFE}/plots/habitat_suitability_v7.png" \
  --shapefile_out "${OUTPUT_DIR}/${SP_SAFE}/gis/M_buffer.shp" \
  --m_shapefile "${OUTPUT_DIR}/${SP_SAFE}/gis/M_buffer.shp" \
  --num_threads "$NUM_THREADS"

echo "Done: $SPECIES -> ${OUTPUT_DIR}/${SP_SAFE}"

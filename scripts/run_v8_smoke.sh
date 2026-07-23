#!/usr/bin/env bash
# run_v8_smoke.sh — Run a v8 smoke test for one species with subsampled data.
# Usage:
#   ./scripts/run_v8_smoke.sh "Acris blanchardi" [pa_method] [buffer_m] [pct] [num_starts]
#
# Defaults: pa_method=centroid, buffer_m=2x_median, pct=0.10, num_starts=50
set -euo pipefail

SPECIES="${1:-}"
if [ -z "$SPECIES" ]; then
  echo "Usage: $0 \"Species name\" [pa_method] [buffer_m] [pct] [num_starts]" >&2
  exit 1
fi

SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
PA_METHOD="${2:-centroid}"
BUFFER_M="${3:-2x_median}"
PCT="${4:-0.10}"
NUM_STARTS="${5:-50}"

REPO_ROOT="${REPO_ROOT:-/home/a474r867/work/xsdm_1000_sp_M_v2}"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
BIOCLIM_DIR="${BIOCLIM_DIR:-/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim}"
ECO_SHP="${ECO_SHP:-/home/a474r867/work/ecoregions/Ecoregions2017.shp}"
OCC_DIR="${OCC_DIR:-${REPO_ROOT}/data/occurrences}"
OLD_OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences"

OCC_CSV="${OCC_DIR}/${SPECIES}.csv"
if [ ! -f "$OCC_CSV" ]; then OCC_CSV="${OCC_DIR}/${SP_SAFE}.csv"; fi
if [ ! -f "$OCC_CSV" ]; then OCC_CSV="${OLD_OCC_DIR}/${SPECIES}.csv"; fi
if [ ! -f "$OCC_CSV" ]; then OCC_CSV="${OLD_OCC_DIR}/${SP_SAFE}.csv"; fi
if [ ! -f "$OCC_CSV" ]; then
  echo "ERROR: occurrence CSV not found: $OCC_CSV" >&2
  exit 1
fi

# Look for a pre-computed accessibility polygon M to avoid re-running ecoregion overlay.
M_SHP="${M_SHP:-}"
if [ -z "$M_SHP" ]; then
  for cand in \
    "${REPO_ROOT}/outputs_centroid/${SP_SAFE}/gis/M.shp" \
    "${REPO_ROOT}/outputs_M/${SP_SAFE}/gis/M.shp" \
    "/home/a474r867/work/xsdm_1000_sp_M/outputs_M/${SP_SAFE}/gis/M.shp" \
    "/home/a474r867/work/xsdm_1000_sp/outputs/${SP_SAFE}/gis/M.shp"; do
    if [ -f "$cand" ]; then M_SHP="$cand"; break; fi
  done
fi

# Derive a clean output dir name from method and buffer
METHOD_DIR="$(echo "${PA_METHOD}_${BUFFER_M}" | tr ' ' '_' | tr '/' '_' | sed 's/__*/_/g; s/^_//; s/_$//')"
OUTPUT_DIR="${REPO_ROOT}/outputs_${METHOD_DIR}"
SP_DIR="${OUTPUT_DIR}/${SP_SAFE}"

mkdir -p "$OUTPUT_DIR"

NUM_THREADS="${NUM_THREADS:-8}"
PA_FACTOR="${PA_FACTOR:-1}"
LAND_MASK_MODE="${LAND_MASK_MODE:-first_year}"

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
echo "v8 smoke test: $SPECIES"
echo "pa_method=$PA_METHOD | buffer_m=$BUFFER_M | pct=$PCT | starts=$NUM_STARTS"
echo "==================================================="

# 1. Prepare full v8 inputs (M + M_buffer + pseudo-absences)
echo "[1/5] Preparing v8 inputs..."
PREPARE_ARGS=(
  --species "$SPECIES"
  --occ_csv "$OCC_CSV"
  --bioclim_dir "$BIOCLIM_DIR"
  --output_dir "$OUTPUT_DIR"
  --pa_factor "$PA_FACTOR"
  --pa_method "$PA_METHOD"
  --pa_in_buffer "false"
  --buffer_m "$BUFFER_M"
  --land_mask_mode "$LAND_MASK_MODE"
)
if [ -n "$M_SHP" ] && [ -f "$M_SHP" ]; then
  echo "Using pre-computed M: $M_SHP"
  PREPARE_ARGS+=(--m_shp "$M_SHP")
else
  echo "No pre-computed M found; building M from ecoregions (slower)."
  PREPARE_ARGS+=(--ecoregion_shp "$ECO_SHP")
fi
run_r "${REPO_ROOT}/scripts/r/prepare_inputs_v8.R" "${PREPARE_ARGS[@]}"

# 2. Subsample to smoke-test fraction in place
echo "[2/5] Subsampling to ${PCT} of prepared occurrences..."
run_r "${REPO_ROOT}/scripts/r/subsample_occ_smoke.R" \
  --source_dir "$SP_DIR" \
  --target_dir "$SP_DIR" \
  --pct "$PCT"

# 3. Model selection on the smoke subset
echo "[3/5] Fitting models (smoke subset)..."
run_r "${REPO_ROOT}/scripts/r/xsdm_model_selection_v6.R" \
  --species "$SPECIES" \
  --env_csv_dir "$OUTPUT_DIR" \
  --output_dir "$OUTPUT_DIR" \
  --num_starts "$NUM_STARTS" \
  --num_threads "$NUM_THREADS"

# 4. Export selected model
echo "[4/5] Exporting selected model..."
run_r "${REPO_ROOT}/scripts/r/export_selected_model_v7.R" \
  --results_rds "${SP_DIR}/model_results_v6.rds" \
  --out_rds "${SP_DIR}/models/selected.rds"

# 5. Habitat suitability map + TSS
echo "[5/5] Habitat suitability map and TSS..."
run_r "${REPO_ROOT}/scripts/r/orchestrator/predict_map_v7.R" \
  --species_dir "$SP_DIR" \
  --model_rds "${SP_DIR}/models/selected.rds" \
  --occ_csv "${SP_DIR}/occ_v7.csv" \
  --bioclim_dir "$BIOCLIM_DIR" \
  --output_png "${SP_DIR}/plots/habitat_suitability_v7.png" \
  --shapefile_out "${SP_DIR}/gis/prediction_extent.shp" \
  --m_shapefile "${SP_DIR}/gis/M_buffer.shp" \
  --num_threads "$NUM_THREADS"

echo "Done: $SPECIES -> $SP_DIR"

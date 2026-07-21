#!/bin/bash
#SBATCH --job-name=xsdm_v7_stage
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/xsdm_v7_stage_%j_%x.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/xsdm_v7_stage_%j_%x.err

set -euo pipefail

SPECIES="${SPECIES:-Pheugopedius maculipectus}"
SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
WORK_SP_DIR="${REPO_ROOT}/outputs_M/${SP_SAFE}"
TMP_ROOT="/tmp/xsdm_v7_${SLURM_JOB_ID}"
TMP_SP_DIR="${TMP_ROOT}/${SP_SAFE}"

SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
BIOCLIM_DIR="${BIOCLIM_DIR:-/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim}"
PA_FACTOR="${PA_FACTOR:-1}"
NUM_STARTS="${NUM_STARTS:-10}"
NUM_THREADS="${SLURM_CPUS_PER_TASK:-8}"
OCC_DIR="${OCC_DIR:-${REPO_ROOT}/data/occurrences}"
ECO_SHP="${ECO_SHP:-/home/a474r867/work/ecoregions/Ecoregions2017.shp}"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"
export APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}"
export APPTAINERENV_OPENBLAS_NUM_THREADS="${NUM_THREADS}"

echo "Job ${SLURM_JOB_ID} on $(hostname)"

# Resolve occurrence CSV
OCC_CSV="${OCC_DIR}/${SPECIES}.csv"
if [ ! -f "$OCC_CSV" ]; then OCC_CSV="${OCC_DIR}/${SP_SAFE}.csv"; fi
if [ ! -f "$OCC_CSV" ]; then OCC_CSV="/home/a474r867/scratch/xsdm/xsdm_occurrences/${SPECIES}.csv"; fi
if [ ! -f "$OCC_CSV" ]; then OCC_CSV="/home/a474r867/scratch/xsdm/xsdm_occurrences/${SP_SAFE}.csv"; fi
if [ ! -f "$OCC_CSV" ]; then
  echo "ERROR: occurrence CSV not found for ${SPECIES}" >&2
  exit 1
fi

run_r() {
  apptainer exec --cleanenv \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    --bind "/home/a474r867/scratch:/home/a474r867/scratch" \
    --bind "/tmp:/tmp" \
    --bind "${WORK_SP_DIR}:${WORK_SP_DIR}" \
    "${SIF}" \
    Rscript "$@"
}

echo "[0/3] Prepare inputs (PA_FACTOR=${PA_FACTOR})"
run_r "${REPO_ROOT}/scripts/r/prepare_inputs_v7.R" \
  --species "${SPECIES}" \
  --occ_csv "${OCC_CSV}" \
  --ecoregion_shp "${ECO_SHP}" \
  --bioclim_dir "${BIOCLIM_DIR}" \
  --output_dir "${REPO_ROOT}/outputs_M" \
  --pa_factor "${PA_FACTOR}"

echo "Staging from ${WORK_SP_DIR} to ${TMP_SP_DIR}"
mkdir -p "${TMP_SP_DIR}/gis" "${TMP_SP_DIR}/models" "${TMP_SP_DIR}/plots"
shopt -s nullglob
for f in "${WORK_SP_DIR}"/*.csv; do cp -v "$f" "${TMP_SP_DIR}/"; done
for f in "${WORK_SP_DIR}/gis/"*; do cp -v "$f" "${TMP_SP_DIR}/gis/"; done
shopt -u nullglob

echo "[1/3] Model selection (NUM_STARTS=${NUM_STARTS})"
run_r "${REPO_ROOT}/scripts/r/xsdm_model_selection_v6.R" \
  --species "${SPECIES}" \
  --env_csv_dir "${TMP_ROOT}" \
  --output_dir "${TMP_ROOT}" \
  --num_starts "${NUM_STARTS}" \
  --num_threads "${NUM_THREADS}"

echo "[2/3] Export selected model"
run_r "${REPO_ROOT}/scripts/r/export_selected_model_v7.R" \
  --results_rds "${TMP_SP_DIR}/model_results_v6.rds" \
  --out_rds "${TMP_SP_DIR}/models/selected.rds"

echo "[3/3] Predict map + TSS"
run_r "${REPO_ROOT}/scripts/r/orchestrator/predict_map_v7.R" \
  --species_dir "${TMP_SP_DIR}" \
  --model_rds "${TMP_SP_DIR}/models/selected.rds" \
  --occ_csv "${TMP_SP_DIR}/occ_v7.csv" \
  --bioclim_dir "${BIOCLIM_DIR}" \
  --output_png "${TMP_SP_DIR}/plots/habitat_suitability_v7.png" \
  --shapefile_out "${TMP_SP_DIR}/gis/M_buffer.shp" \
  --m_shapefile "${TMP_SP_DIR}/gis/M_buffer.shp" \
  --num_threads "${NUM_THREADS}"

echo "Copying outputs back to ${WORK_SP_DIR}"
mkdir -p "${WORK_SP_DIR}/models" "${WORK_SP_DIR}/plots"
shopt -s nullglob
cp -v "${TMP_SP_DIR}/model_results_v6.rds" "${WORK_SP_DIR}/" || true
cp -v "${TMP_SP_DIR}/model_selection_report.md" "${WORK_SP_DIR}/" || true
cp -v "${TMP_SP_DIR}/tss_results_v7.rds" "${WORK_SP_DIR}/" || true
cp -v "${TMP_SP_DIR}/models/"* "${WORK_SP_DIR}/models/" || true
cp -v "${TMP_SP_DIR}/plots/"* "${WORK_SP_DIR}/plots/" || true
cp -v "${TMP_SP_DIR}/"*.tif "${WORK_SP_DIR}/" || true
shopt -u nullglob

echo "Done"

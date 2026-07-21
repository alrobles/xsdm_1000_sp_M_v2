#!/bin/bash
#SBATCH --job-name=v7_extract_plot
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/v7_extract_plot_%j_%x.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/v7_extract_plot_%j_%x.err

set -euo pipefail

SPECIES="${SPECIES:-Pheugopedius maculipectus}"
SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
SP_DIR="${REPO_ROOT}/outputs_M/${SP_SAFE}"
YEAR="${YEAR:-2020}"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
BIOCLIM_DIR="${BIOCLIM_DIR:-/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim}"
PA_FACTOR="${PA_FACTOR:-1}"
BUFFER_M="${BUFFER_M:-median}"
PA_IN_BUFFER="${PA_IN_BUFFER:-false}"
COASTLINE_SHP="${COASTLINE_SHP:-${REPO_ROOT}/data/coastline.shp}"
OCC_DIR="${OCC_DIR:-${REPO_ROOT}/data/occurrences}"
ECO_SHP="${ECO_SHP:-/home/a474r867/work/ecoregions/Ecoregions2017.shp}"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"

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
    --bind "${SP_DIR}:${SP_DIR}" \
    "${SIF}" \
    Rscript "$@"
}

echo "[1/2] Prepare inputs for ${SPECIES} (PA_FACTOR=${PA_FACTOR}, BUFFER_M=${BUFFER_M}, PA_IN_BUFFER=${PA_IN_BUFFER})"
run_r "${REPO_ROOT}/scripts/r/prepare_inputs_v7.R" \
  --species "${SPECIES}" \
  --occ_csv "${OCC_CSV}" \
  --ecoregion_shp "${ECO_SHP}" \
  --bioclim_dir "${BIOCLIM_DIR}" \
  --output_dir "${REPO_ROOT}/outputs_M" \
  --pa_factor "${PA_FACTOR}" \
  --buffer_m "${BUFFER_M}" \
  --pa_in_buffer "${PA_IN_BUFFER}" \
  --coastline_shp "${COASTLINE_SHP}"

echo "[2/2] Plot bio01 crop for ${YEAR}"
mkdir -p "${SP_DIR}/plots"
run_r "${REPO_ROOT}/scripts/r/plot_M_bio01.R" \
  "${SP_DIR}" \
  "${YEAR}"

cd "${REPO_ROOT}"
git add -f "outputs_M/${SP_SAFE}/prepare_meta.csv" || true
git add "outputs_M/${SP_SAFE}/plots/bio01_M_crop_${YEAR}.png"
git commit -m "v7 extract+plot: ${SP_SAFE} PA_FACTOR=${PA_FACTOR} BUFFER_M=${BUFFER_M} PA_IN_BUFFER=${PA_IN_BUFFER}" || true
git push origin devin/v7-ecoregion || true

echo "Done"

#!/bin/bash
#SBATCH --job-name=v7_prepare_200_M
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --array=1-200%20
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M/logs/prepare_200_M_%A_%a.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M/logs/prepare_200_M_%A_%a.err
set -euo pipefail
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SP_LIST="${SP_LIST:-${REPO_ROOT}/species_200_v7_M.txt}"
OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences"
ECO="/home/a474r867/work/ecoregions/Ecoregions2017.shp"
COAST="${REPO_ROOT}/data/coastline.shp"
mkdir -p "${REPO_ROOT}/logs"
SPECIES=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${SP_LIST}")
SP_SAFE=$(echo "${SPECIES}" | tr ' ' '_')
OCC_CSV="${OCC_DIR}/${SPECIES}.csv"
if [[ ! -f "${OCC_CSV}" ]]; then OCC_CSV="${OCC_DIR}/${SP_SAFE}.csv"; fi
if [[ ! -f "${OCC_CSV}" ]]; then
  echo "ERROR: missing ${OCC_CSV}" >&2
  exit 1
fi
export APPTAINERENV_OMP_NUM_THREADS=8
apptainer exec --cleanenv \
  --bind "/home/a474r867:/home/a474r867" \
  --bind "/tmp:/tmp" \
  "$SIF" \
  Rscript "${REPO_ROOT}/scripts/r/prepare_inputs_v7.R" \
    --species "${SPECIES}" \
    --occ_csv "${OCC_CSV}" \
    --ecoregion_shp "${ECO}" \
    --coastline_shp "${COAST}" \
    --output_dir "${REPO_ROOT}/outputs_M" \
    --pa_factor 2 \
    --buffer_m 100000 \
    --pa_in_buffer true \
    --years 1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020 \
    --seed ${SLURM_ARRAY_TASK_ID}

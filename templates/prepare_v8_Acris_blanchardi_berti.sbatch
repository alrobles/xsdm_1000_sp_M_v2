#!/bin/bash
#SBATCH --job-name=prep_v8_Acris_berti
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/prep_v8_Acris_berti_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/prep_v8_Acris_berti_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SPECIES="Acris blanchardi"
SP_SAFE=$(echo "${SPECIES}" | tr ' ' '_')
OCC_DIR="/home/a474r867/scratch/xsdm/xsdm_occurrences"
M_SHP="/home/a474r867/work/xsdm_1000_sp_M/outputs_M/Acris_blanchardi/gis/M.shp"
M_BUFFER_SHP="/home/a474r867/work/xsdm_1000_sp_M/outputs_M/Acris_blanchardi/gis/M_buffer.shp"
PA_IN_BUFFER="true"
PA_FACTOR="1"
OUTPUT_DIR="${REPO_ROOT}/outputs_berti_sample"

mkdir -p "${REPO_ROOT}/logs"

OCC_CSV="${OCC_DIR}/${SPECIES}.csv"
if [[ ! -f "${OCC_CSV}" ]]; then OCC_CSV="${OCC_DIR}/${SP_SAFE}.csv"; fi
if [[ ! -f "${OCC_CSV}" ]]; then
  echo "ERROR: missing occurrence CSV for ${SPECIES}" >&2
  exit 1
fi

export APPTAINERENV_OMP_NUM_THREADS=8
apptainer exec --cleanenv \
  --bind "/home/a474r867:/home/a474r867" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/prepare_inputs_v8.R" \
    --species "${SPECIES}" \
    --occ_csv "${OCC_CSV}" \
    --m_shp "${M_SHP}" \
    --m_buffer_shp "${M_BUFFER_SHP}" \
    --output_dir "${OUTPUT_DIR}" \
    --pa_factor "${PA_FACTOR}" \
    --pa_in_buffer "${PA_IN_BUFFER}" \
    --pa_method dataset \
    --land_mask_mode first_year \
    --buffer_m 0 \
    --years 1980,1981,1982,1983,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020 \
    --seed 42

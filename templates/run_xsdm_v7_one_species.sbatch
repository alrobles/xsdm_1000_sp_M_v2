#!/bin/bash
#SBATCH --job-name=xsdm_v7
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/xsdm_v7_%j_%x.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/xsdm_v7_%j_%x.err

set -euo pipefail

SPECIES="${SPECIES:-}"
if [ -z "$SPECIES" ]; then
  echo "ERROR: set SPECIES env var, e.g. --export=ALL,SPECIES=\"Hypopachus variolosus\"" >&2
  exit 1
fi

REPO_ROOT="${REPO_ROOT:-/home/a474r867/work/xsdm_1000_sp_v7}"
export REPO_ROOT
cd "$REPO_ROOT"

export NUM_STARTS="${NUM_STARTS:-40}"
export NUM_THREADS="${NUM_THREADS:-8}"
export PA_FACTOR="${PA_FACTOR:-1}"
export SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
export BIOCLIM_DIR="${BIOCLIM_DIR:-/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim}"
export ECO_SHP="${ECO_SHP:-/home/a474r867/work/ecoregions/Ecoregions2017.shp}"
export OCC_DIR="${OCC_DIR:-/home/a474r867/work/xsdm_1000_sp/data/occurrences}"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"
export APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}"
export APPTAINERENV_OPENBLAS_NUM_THREADS="${NUM_THREADS}"

mkdir -p logs
"${REPO_ROOT}/scripts/run_v7_one_species.sh" "$SPECIES"

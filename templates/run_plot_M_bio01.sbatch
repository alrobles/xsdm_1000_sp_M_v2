#!/bin/bash
#SBATCH --job-name=v7_plot_bio01
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=0:30:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=2
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/plot_bio01_%j_%x.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/plot_bio01_%j_%x.err

set -euo pipefail

SPECIES="${SPECIES:-Pheugopedius maculipectus}"
SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
SP_DIR="${REPO_ROOT}/outputs_M/${SP_SAFE}"
YEAR="${YEAR:-2020}"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"

mkdir -p "${SP_DIR}/plots"

apptainer exec --cleanenv \
  --bind "${REPO_ROOT}:${REPO_ROOT}" \
  --bind "/home/a474r867/scratch:/home/a474r867/scratch" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/plot_M_bio01.R" "${SP_DIR}" "${YEAR}"

cd "${REPO_ROOT}"
git add "outputs_M/${SP_SAFE}/plots/bio01_M_crop_${YEAR}.png"
git commit -m "Add bio01 M crop plot for ${SP_SAFE} (${YEAR})"
git push origin devin/v7-ecoregion

#!/bin/bash
#SBATCH --job-name=v7_scatter
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=0:30:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/v7_scatter_%j_%x.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/v7_scatter_%j_%x.err

set -euo pipefail

SPECIES="${SPECIES:-Pheugopedius maculipectus}"
SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
SP_DIR="${REPO_ROOT}/outputs_M/${SP_SAFE}"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"

# Sync scripts
cd "${REPO_ROOT}"
git pull origin devin/v7-ecoregion

apptainer exec --cleanenv \
  --bind "${REPO_ROOT}:${REPO_ROOT}" \
  --bind "${SP_DIR}:${SP_DIR}" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/plot_env_scatter_v7.R" \
    "${SP_DIR}"

cd "${REPO_ROOT}"
git add -f "outputs_M/${SP_SAFE}/prepare_meta.csv" || true
git add "outputs_M/${SP_SAFE}/plots/bio01_M_crop_2020.png" || true
git add "outputs_M/${SP_SAFE}/plots/bio01_vs_bio12_all_years.png"
git commit -m "v7 scatter: ${SP_SAFE} bio01 vs bio12" || true
git push origin devin/v7-ecoregion || true

echo "Done"

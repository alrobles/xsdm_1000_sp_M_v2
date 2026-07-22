#!/bin/bash
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --job-name=plot_pa_v8
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SPECIES="Acris blanchardi"

mkdir -p "${REPO_ROOT}/reports/pa_sampling"

cd "${REPO_ROOT}"

export APPTAINERENV_OMP_NUM_THREADS=4
apptainer exec --cleanenv \
  --bind "/home/a474r867:/home/a474r867" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/plot_pa_sampling_v8.R" \
    --repo_root "${REPO_ROOT}" \
    --species "${SPECIES}"

# Commit and push the generated PNGs
git pull origin master
git add -f "${REPO_ROOT}/reports/pa_sampling"/*.png
git commit -m "Add pseudo-absence sampling visual check for ${SPECIES} v8" || true
git push origin master

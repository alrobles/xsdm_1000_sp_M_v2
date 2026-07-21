#!/bin/bash
#SBATCH --job-name=extract_model_info
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=00:30:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=/home/a474r867/scratch/xsdm_results/extract_model_info_%j.log

set -euo pipefail

REPO_DIR="/home/a474r867/work/xsdm_1000_sp"
SIF="${HOME}/geospatial-rserver/geospatial_latest.sif"
RESULTS_DIR="/home/a474r867/scratch/xsdm_results"

cd "${REPO_DIR}"

echo "=== Extracting model info for 100 profile PDF species ==="
echo "Start: $(date)"

apptainer exec --cleanenv \
    --bind "${RESULTS_DIR}:${RESULTS_DIR}" \
    --bind "${REPO_DIR}:${REPO_DIR}" \
    "${SIF}" \
    Rscript scripts/r/extract_model_info.R "${RESULTS_DIR}" docs/audit/model_info_100.csv docs/audit/model_info_100.md

echo "=== R script done, pushing to GitHub ==="

git add docs/audit/model_info_100.csv docs/audit/model_info_100.md
git commit -m "docs: model info table for 100 profile PDF species" || echo "Nothing to commit"
git push origin main

echo "=== Done: $(date) ==="

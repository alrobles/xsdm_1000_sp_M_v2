#!/bin/bash
#SBATCH --job-name=build_xsdm_sif
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=01:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/build_container_%j.out
#SBATCH --error=logs/build_container_%j.err
# ──────────────────────────────────────────────────────────────────────
# Build xsdm_latest_v2.sif from containers/xsdm.def
# ──────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "${REPO_ROOT}"

echo "=== Building xsdm container ==="
echo "Node: $(hostname)"
echo "Start: $(date)"
echo "Def file: containers/xsdm.def"

apptainer build --fakeroot --force \
    "${HOME}/geospatial-rserver/xsdm_latest_v2.sif" \
    containers/xsdm.def

echo "=== Build complete ==="
echo "End: $(date)"
ls -lh "${HOME}/geospatial-rserver/xsdm_latest_v2.sif"

# Quick validation
echo "=== Validation ==="
apptainer exec --cleanenv "${HOME}/geospatial-rserver/xsdm_latest_v2.sif" \
    Rscript -e "library(xsdm); cat('xsdm OK:', as.character(packageVersion('xsdm')), '\n')"
apptainer exec --cleanenv "${HOME}/geospatial-rserver/xsdm_latest_v2.sif" \
    Rscript -e "library(Matrix); cat('Matrix OK:', as.character(packageVersion('Matrix')), '\n')"
apptainer exec --cleanenv "${HOME}/geospatial-rserver/xsdm_latest_v2.sif" \
    Rscript -e "cat('libRlapack check:'); cat(file.exists('/usr/local/lib/R/lib/libRlapack.so'), '\n')"

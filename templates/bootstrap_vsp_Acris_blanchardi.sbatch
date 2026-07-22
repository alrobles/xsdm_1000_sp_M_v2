#!/bin/bash
#SBATCH --job-name=boot_vsp_Acris
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/bootstrap_vsp_Acris_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/bootstrap_vsp_Acris_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
BIOCIM_DIR="/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim"

mkdir -p "${REPO_ROOT}/logs"

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}

# v7ring
apptainer exec --cleanenv \
  --bind "/home/a474r867:/home/a474r867" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/bootstrap_vsp.R" \
    --method_dir "${REPO_ROOT}/outputs_v7ring_smoke" \
    --B 10 \
    --num_starts 50 \
    --num_threads 4 \
    --bioclim_dir "${BIOCIM_DIR}" \
    --output_dir "${REPO_ROOT}/outputs_v7ring_smoke/bootstrap_vsp"

# centroid_exp
apptainer exec --cleanenv \
  --bind "/home/a474r867:/home/a474r867" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/bootstrap_vsp.R" \
    --method_dir "${REPO_ROOT}/outputs_centroid_smoke" \
    --B 10 \
    --num_starts 50 \
    --num_threads 4 \
    --bioclim_dir "${BIOCIM_DIR}" \
    --output_dir "${REPO_ROOT}/outputs_centroid_smoke/bootstrap_vsp"

echo "=== Bootstrap complete ==="

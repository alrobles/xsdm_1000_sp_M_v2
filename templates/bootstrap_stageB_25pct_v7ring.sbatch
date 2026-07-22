#!/bin/bash
#SBATCH --job-name=boot_stageB_v7ring_25pct
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --array=1-10
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/bootstrap_stageB_v7ring_25pct_%A_%a.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/bootstrap_stageB_v7ring_25pct_%A_%a.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
BIOCIM_DIR="/home/a474r867/scratch/era5/era5-land/era5_bioclim/bioclim"
METHOD_DIR="${REPO_ROOT}/outputs_v7ring_25pct_50st"
TASK_OUT="${METHOD_DIR}/bootstrap_stageB_25pct/task_${SLURM_ARRAY_TASK_ID}"
mkdir -p "${TASK_OUT}"

START_ITER=$(( (${SLURM_ARRAY_TASK_ID} - 1) * 10 + 1 ))

export APPTAINERENV_OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-4}
export APPTAINERENV_REPO_ROOT="${REPO_ROOT}"

apptainer exec --cleanenv \
  --bind "/home/a474r867:/home/a474r867" \
  --bind "/tmp:/tmp" \
  "${SIF}" \
  Rscript "${REPO_ROOT}/scripts/r/bootstrap_vsp_stageB.R" \
    --method_dir "${METHOD_DIR}" \
    --B 10 \
    --start_iter "${START_ITER}" \
    --num_starts 50 \
    --num_threads 4 \
    --bioclim_dir "${BIOCIM_DIR}" \
    --pa_method random \
    --pa_factor 2 \
    --pa_in_buffer true \
    --output_dir "${TASK_OUT}"

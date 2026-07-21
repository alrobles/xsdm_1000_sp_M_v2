#!/bin/bash
#SBATCH --job-name=xsdm_v7_modelsel
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=5:55:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/xsdm_v7_modelsel_%j_%x.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/xsdm_v7_modelsel_%j_%x.err

set -euo pipefail

SPECIES="${SPECIES:-Pheugopedius maculipectus}"
SP_SAFE=$(echo "$SPECIES" | tr ' ' '_')
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
WORK_SP_DIR="${REPO_ROOT}/outputs_M/${SP_SAFE}"
TMP_ROOT="/tmp/xsdm_v7_${SLURM_JOB_ID}"
TMP_SP_DIR="${TMP_ROOT}/${SP_SAFE}"

SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
NUM_STARTS="${NUM_STARTS:-10}"
NUM_THREADS="${SLURM_CPUS_PER_TASK:-8}"

export APPTAINERENV_R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/4.4"
export APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}"
export APPTAINERENV_OPENBLAS_NUM_THREADS="${NUM_THREADS}"

echo "Job ${SLURM_JOB_ID} on $(hostname)"
echo "Staging from ${WORK_SP_DIR} to ${TMP_SP_DIR}"

mkdir -p "${TMP_SP_DIR}/gis"
shopt -s nullglob
for f in "${WORK_SP_DIR}"/*.csv; do cp -v "$f" "${TMP_SP_DIR}/"; done
for f in "${WORK_SP_DIR}/gis/"*; do cp -v "$f" "${TMP_SP_DIR}/gis/"; done
shopt -u nullglob

run_r() {
  apptainer exec --cleanenv \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    --bind "/home/a474r867/scratch:/home/a474r867/scratch" \
    --bind "/tmp:/tmp" \
    --bind "${WORK_SP_DIR}:${WORK_SP_DIR}" \
    "${SIF}" \
    Rscript "$@"
}

echo "[1/1] Model selection (NUM_STARTS=${NUM_STARTS})"
run_r "${REPO_ROOT}/scripts/r/xsdm_model_selection_v6.R" \
  --species "${SPECIES}" \
  --env_csv_dir "${TMP_ROOT}" \
  --output_dir "${TMP_ROOT}" \
  --num_starts "${NUM_STARTS}" \
  --num_threads "${NUM_THREADS}"

echo "Copying outputs back to ${WORK_SP_DIR}"
cp -v "${TMP_SP_DIR}/model_results_v6.rds" "${WORK_SP_DIR}/" || true
cp -v "${TMP_SP_DIR}/model_selection_report.md" "${WORK_SP_DIR}/" || true

cd "${REPO_ROOT}"
git add -f "outputs_M/${SP_SAFE}/model_results_v6.rds" || true
git add "outputs_M/${SP_SAFE}/model_selection_report.md"
git commit -m "v7 model selection: ${SP_SAFE} NUM_STARTS=${NUM_STARTS}" || true
git push origin devin/v7-ecoregion || true

echo "Done"

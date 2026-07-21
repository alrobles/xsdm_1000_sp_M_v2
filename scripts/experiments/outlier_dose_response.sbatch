#!/bin/bash
#SBATCH --job-name=xsdm_dose
#SBATCH --partition=kbs
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --account=kbs
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-/home/a474r867/work/xsdm_1000_sp}"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
SCRATCH="${SCRATCH:-/home/a474r867/scratch}"
ENV_CSV_DIR="${ENV_CSV_DIR:-/home/a474r867/scratch/xsdm_env_extraction_19}"
OUT="${OUT:-${REPO_ROOT}/outputs/outlier_dose_response}"
SPECIES="${SPECIES:-Amazona aestiva}"
MODEL_NAME="${MODEL_NAME:-T3_noP__bd_pd1_sigL1}"
VARS="${VARS:-T3}"
MASK="${MASK:-pd=Inf,sigltil1=Inf}"
NUM_STARTS="${NUM_STARTS:-100}"
NUM_THREADS="${NUM_THREADS:-2}"
APPLY_PREFILTER="${APPLY_PREFILTER:-false}"
PREFILTER_QUANTILE="${PREFILTER_QUANTILE:-0.95}"
KS="${KS:-0,1,2,3,5,10}"

LOG_DIR="${OUT}/logs"
species_safe="${SPECIES// /_}"

mkdir -p "${OUT}" "${LOG_DIR}"

run_container_rscript() {
  local log_file="$1"
  local script_path="$2"
  local drop_top_k="$3"
  shift 3

  mkdir -p "$(dirname "${log_file}")"

  APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}" \
  APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER}" \
  APPTAINERENV_PREFILTER_QUANTILE="${PREFILTER_QUANTILE}" \
  APPTAINERENV_DROP_TOP_K="${drop_top_k}" \
  APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu \
  apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind /tmp:/tmp \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript "${script_path}" "$@" >> "${log_file}" 2>&1
}

run_fit_one_k() {
  local k="$1"
  local run_root="${OUT}/k${k}"
  local species_dir="${run_root}/${species_safe}"
  local model_rds="${species_dir}/models/${MODEL_NAME}.rds"
  local wb_rds="${species_dir}/wb/${MODEL_NAME}_wb.rds"
  local fit_log="${LOG_DIR}/k${k}_fit.log"
  local wb_log="${LOG_DIR}/k${k}_wb.log"
  local profile_log="${LOG_DIR}/k${k}_profile.log"

  mkdir -p "${species_dir}/plots" "${species_dir}/gis" "${species_dir}/wb"

  echo "== k=${k} =="
  echo "   output: ${run_root}"

  run_container_rscript "${fit_log}" "${REPO_ROOT}/scripts/r/orchestrator/fit_single_model.R" "${k}" \
    --species "${SPECIES}" \
    --model_name "${MODEL_NAME}" \
    --vars "${VARS}" \
    --mask "${MASK}" \
    --num_starts "${NUM_STARTS}" \
    --num_threads "${NUM_THREADS}" \
    --env_csv_dir "${ENV_CSV_DIR}" \
    --output_dir "${run_root}" || {
      echo "WARNING: fit failed for k=${k} (see ${fit_log})"
      return 0
    }

  if [[ -f "${model_rds}" ]]; then
    run_container_rscript "${wb_log}" "${REPO_ROOT}/scripts/r/orchestrator/check_well_behaved.R" "${k}" \
      --model_rds "${model_rds}" \
      --output_file "${wb_rds}" \
      --num_threads "${NUM_THREADS}" || {
        echo "WARNING: check_well_behaved failed for k=${k} (see ${wb_log})"
      }

    fit_status=$(APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}" \
      APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER}" \
      APPTAINERENV_PREFILTER_QUANTILE="${PREFILTER_QUANTILE}" \
      APPTAINERENV_DROP_TOP_K="${k}" \
      APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu \
      apptainer exec --cleanenv \
        --bind "${SCRATCH}:${SCRATCH}" \
        --bind /tmp:/tmp \
        --bind "${REPO_ROOT}:${REPO_ROOT}" \
        "${SIF}" \
        Rscript -e "x<-readRDS('${model_rds}'); cat(x\$status)" 2>/dev/null || true)

    if [[ "${fit_status}" == "success" ]]; then
      run_container_rscript "${profile_log}" "${REPO_ROOT}/scripts/r/orchestrator/run_profile.R" "${k}" \
        --model_rds "${model_rds}" \
        --output_dir "${species_dir}" \
        --num_threads "${NUM_THREADS}" || {
          echo "WARNING: run_profile failed for k=${k} (see ${profile_log})"
        }
    else
      echo "WARNING: skipping profile for k=${k} (status=${fit_status:-missing})"
    fi
  else
    echo "WARNING: missing model RDS for k=${k}: ${model_rds}"
  fi
}

IFS=',' read -r -a KS_LIST <<< "${KS}"
for k in "${KS_LIST[@]}"; do
  k="${k// /}"
  [[ -z "${k}" ]] && continue
  run_fit_one_k "${k}"
done

run_container_rscript "${LOG_DIR}/dose_response_plot.log" "${REPO_ROOT}/scripts/experiments/plot_dose_response.R" "0" \
  --out "${OUT}" \
  --species "${SPECIES}" \
  --model_name "${MODEL_NAME}" \
  --ks "${KS}"

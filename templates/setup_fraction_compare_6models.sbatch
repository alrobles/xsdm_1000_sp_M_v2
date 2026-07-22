#!/bin/bash
#SBATCH --job-name=setup_frac_compare
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=1:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/setup_fraction_compare_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/setup_fraction_compare_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"

FRAC="${FRAC:-0.5}"
OUTPUT_SUFFIX="${OUTPUT_SUFFIX:-_50pct}"
NUM_STARTS="${NUM_STARTS:-50}"
MAX_CONCURRENT="${MAX_CONCURRENT:-25}"

cd "${REPO_ROOT}"

echo "=== Creating ${FRAC} (${OUTPUT_SUFFIX}) smoke copies for 6 methods ==="

for base in outputs outputs_centroid outputs_berti_sample outputs_inverse_density outputs_v7ring outputs_v6bbox; do
  src_dir="${base}"
  dst_dir="${base}${OUTPUT_SUFFIX}"
  src_path="${REPO_ROOT}/${src_dir}/Acris_blanchardi"
  dst_path="${REPO_ROOT}/${dst_dir}/Acris_blanchardi"

  if [[ ! -d "${src_path}" ]]; then
    echo "WARNING: ${src_path} not found, skipping ${base}"
    continue
  fi

  rm -rf "${dst_path}"

  apptainer exec --cleanenv \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${REPO_ROOT}/scripts/r/make_smoke_v8.R" \
      --src_dir "${src_path}" \
      --dst_dir "${dst_path}" \
      --frac "${FRAC}" \
      --seed 42
  echo "Smoke copy ready: ${dst_dir}"
done

echo "=== Submitting 6 orchestrators with NUM_STARTS=${NUM_STARTS}, MAX_CONCURRENT=${MAX_CONCURRENT} ==="

ORCH_TEMPLATE="${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch"

for base in outputs outputs_centroid outputs_berti_sample outputs_inverse_density outputs_v7ring outputs_v6bbox; do
  dst_dir="${base}${OUTPUT_SUFFIX}"
  joblabel="orch_v8_Acris_50pct_${base}"
  sbatch --job-name="${joblabel}" \
    --export=ALL,NUM_STARTS="${NUM_STARTS}",MAX_CONCURRENT="${MAX_CONCURRENT}",OUTPUT_DIR="${REPO_ROOT}/${dst_dir}" \
    "${ORCH_TEMPLATE}"
done

echo "=== Setup complete (${FRAC}, ${OUTPUT_SUFFIX}) ==="

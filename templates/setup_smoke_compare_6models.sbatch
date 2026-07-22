#!/bin/bash
#SBATCH --job-name=setup_smoke_compare
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=1:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/setup_smoke_compare_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/setup_smoke_compare_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"

cd "${REPO_ROOT}"

echo "=== Creating 10% smoke copies for all six methods ==="

for src_dir in outputs outputs_centroid outputs_berti_sample outputs_inverse_density outputs_v7ring outputs_v6bbox; do
  dst_dir="${src_dir}_smoke"
  src_path="${REPO_ROOT}/${src_dir}/Acris_blanchardi"
  dst_path="${REPO_ROOT}/${dst_dir}/Acris_blanchardi"

  # If source doesn't exist, skip (v7ring/v6bbox just created; v8 four already exist)
  if [[ ! -d "${src_path}" ]]; then
    echo "WARNING: ${src_path} not found, skipping ${src_dir}"
    continue
  fi

  # Clean old smoke dir to avoid stale fits/plots
  rm -rf "${dst_path}"

  apptainer exec --cleanenv \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    --bind "/tmp:/tmp" \
    "${SIF}" \
    Rscript "${REPO_ROOT}/scripts/r/make_smoke_v8.R" \
      --src_dir "${src_path}" \
      --dst_dir "${dst_path}" \
      --frac 0.1 \
      --seed 42
  echo "Smoke copy ready: ${dst_dir}"
done

echo "=== Submitting 6 orchestrators with NUM_STARTS=50, MAX_CONCURRENT=25 ==="

ORCH_TEMPLATE="${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch"

sbatch --job-name=orch_v8_Acris_smoke_random --export=ALL,NUM_STARTS=50,MAX_CONCURRENT=25,OUTPUT_DIR="${REPO_ROOT}/outputs_smoke" "${ORCH_TEMPLATE}"
sbatch --job-name=orch_v8_Acris_smoke_centroid --export=ALL,NUM_STARTS=50,MAX_CONCURRENT=25,OUTPUT_DIR="${REPO_ROOT}/outputs_centroid_smoke" "${ORCH_TEMPLATE}"
sbatch --job-name=orch_v8_Acris_smoke_berti --export=ALL,NUM_STARTS=50,MAX_CONCURRENT=25,OUTPUT_DIR="${REPO_ROOT}/outputs_berti_sample_smoke" "${ORCH_TEMPLATE}"
sbatch --job-name=orch_v8_Acris_smoke_invden --export=ALL,NUM_STARTS=50,MAX_CONCURRENT=25,OUTPUT_DIR="${REPO_ROOT}/outputs_inverse_density_smoke" "${ORCH_TEMPLATE}"
sbatch --job-name=orch_v8_Acris_smoke_v7ring --export=ALL,NUM_STARTS=50,MAX_CONCURRENT=25,OUTPUT_DIR="${REPO_ROOT}/outputs_v7ring_smoke" "${ORCH_TEMPLATE}"
sbatch --job-name=orch_v8_Acris_smoke_v6bbox --export=ALL,NUM_STARTS=50,MAX_CONCURRENT=25,OUTPUT_DIR="${REPO_ROOT}/outputs_v6bbox_smoke" "${ORCH_TEMPLATE}"

echo "=== Setup complete ==="

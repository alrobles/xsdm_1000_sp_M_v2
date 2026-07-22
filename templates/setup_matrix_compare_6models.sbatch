#!/bin/bash
#SBATCH --job-name=setup_matrix_compare
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/setup_matrix_compare_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M_v2/logs/setup_matrix_compare_%j.err

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"

MAX_CONCURRENT="${MAX_CONCURRENT:-25}"

cd "${REPO_ROOT}"

frac_to_suffix() {
  local f="$1"
  if [[ "$f" == "0.25" || "$f" == ".25" ]]; then echo "25pct";
  elif [[ "$f" == "0.5" || "$f" == ".5" ]]; then echo "50pct";
  elif [[ "$f" == "0.75" || "$f" == ".75" ]]; then echo "75pct";
  elif [[ "$f" == "1.0" || "$f" == "1" ]]; then echo "100pct";
  else echo "frac${f}"; fi
}

echo "=== Creating matrix smoke copies (25/50/75/100% x 50/100 starts) for 6 methods ==="

for FRAC in 0.25 0.5 0.75 1.0; do
  SUFFIX=$(frac_to_suffix "${FRAC}")
  for STARTS in 50 100; do
    for base in outputs outputs_centroid outputs_berti_sample outputs_inverse_density outputs_v7ring outputs_v6bbox; do
      src_dir="${base}"
      dst_dir="${base}_${SUFFIX}_${STARTS}st"
      src_path="${REPO_ROOT}/${src_dir}/Acris_blanchardi"
      dst_path="${REPO_ROOT}/${dst_dir}/Acris_blanchardi"

      if [[ ! -d "${src_path}" ]]; then
        echo "WARNING: ${src_path} not found, skipping ${base} ${SUFFIX} ${STARTS}"
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
      echo "Copy ready: ${dst_dir}"
    done
  done
done

echo "=== Submitting 48 orchestrators ==="

ORCH_TEMPLATE="${REPO_ROOT}/templates/orchestrate_v8_Acris_blanchardi.sbatch"

for FRAC in 0.25 0.5 0.75 1.0; do
  SUFFIX=$(frac_to_suffix "${FRAC}")
  for STARTS in 50 100; do
    for base in outputs outputs_centroid outputs_berti_sample outputs_inverse_density outputs_v7ring outputs_v6bbox; do
      dst_dir="${base}_${SUFFIX}_${STARTS}st"
      joblabel="orch_v8_Acris_${SUFFIX}_${STARTS}st_${base}"
      sbatch --job-name="${joblabel}" \
        --export=ALL,NUM_STARTS="${STARTS}",MAX_CONCURRENT="${MAX_CONCURRENT}",OUTPUT_DIR="${REPO_ROOT}/${dst_dir}" \
        "${ORCH_TEMPLATE}"
    done
  done
done

echo "=== Matrix setup complete ==="

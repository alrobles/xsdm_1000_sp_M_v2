#!/bin/bash
# submit_stageB_25pct.sh — Submit v7ring + centroid 25% Stage B bootstrap arrays
set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
cd "${REPO_ROOT}"

mkdir -p "${REPO_ROOT}/logs"

V7_ID=$(sbatch --parsable "${REPO_ROOT}/templates/bootstrap_stageB_25pct_v7ring.sbatch")
CENT_ID=$(sbatch --parsable "${REPO_ROOT}/templates/bootstrap_stageB_25pct_centroid.sbatch")

echo "Submitted v7ring array: ${V7_ID}"
echo "Submitted centroid array: ${CENT_ID}"

COMBINE_ID=$(sbatch --parsable \
  --dependency=afterok:${V7_ID},afterok:${CENT_ID} \
  --job-name=boot_stageB_25pct_combine \
  --partition=sixhour \
  --account=kbs \
  --time=00:30:00 \
  --mem=16G \
  --cpus-per-task=2 \
  --wrap="
set -euo pipefail
REPO_ROOT=${REPO_ROOT}
SIF=\${HOME}/geospatial-rserver/xsdm_latest.sif
apptainer exec --cleanenv --bind /home/a474r867:/home/a474r867 --bind /tmp:/tmp \${SIF} Rscript \${REPO_ROOT}/scripts/r/combine_stageB.R --method_dir \${REPO_ROOT}/outputs_v7ring_25pct_50st --combined_dir \${REPO_ROOT}/outputs_v7ring_25pct_50st/bootstrap_stageB_25pct
apptainer exec --cleanenv --bind /home/a474r867:/home/a474r867 --bind /tmp:/tmp \${SIF} Rscript \${REPO_ROOT}/scripts/r/combine_stageB.R --method_dir \${REPO_ROOT}/outputs_centroid_25pct_50st --combined_dir \${REPO_ROOT}/outputs_centroid_25pct_50st/bootstrap_stageB_25pct
")

echo "Submitted combine job: ${COMBINE_ID}"

#!/bin/bash
set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_v7"
SP_LIST="${REPO_ROOT}/tmp/species_100_v7_nodup.txt"

cd "${REPO_ROOT}"

N=$(wc -l < "${SP_LIST}")
echo "Submitting ${N} species as separate orchestrators on kbs"

ORCH_JOB=$(sbatch --parsable \
  --array="1-${N}%152" \
  --partition=kbs \
  --account=kbs \
  --time=2-00:00:00 \
  --mem=8G \
  --cpus-per-task=2 \
  --nodes=1 \
  --output="${REPO_ROOT}/logs/orchestrator_v7/orch_per_sp_%A_%a.out" \
  --error="${REPO_ROOT}/logs/orchestrator_v7/orch_per_sp_%A_%a.err" \
  "${REPO_ROOT}/templates/orchestrate_v7_per_species.sbatch" \
  "${SP_LIST}")

echo "Orchestrator array job: ${ORCH_JOB}"

# Post-commit job: collect reports after all array tasks finish
COMMIT_JOB=$(sbatch --parsable \
  --dependency="afterany:${ORCH_JOB}" \
  --partition=sixhour \
  --account=kbs \
  --time=2:00:00 \
  --mem=4G \
  --cpus-per-task=2 \
  --output="${REPO_ROOT}/logs/commit_100_v7_per_species_%j.out" \
  --error="${REPO_ROOT}/logs/commit_100_v7_per_species_%j.err" \
  "${REPO_ROOT}/templates/commit_100_v7_outputs.sbatch")

echo "Post-commit job: ${COMMIT_JOB}"

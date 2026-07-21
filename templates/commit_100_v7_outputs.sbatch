#!/bin/bash
#SBATCH --job-name=v7_commit_100
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=2:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/commit_100_v7_outputs_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/commit_100_v7_outputs_%j.err

set -euo pipefail

REPO="/home/a474r867/work/xsdm_1000_sp_v7"
mkdir -p "${REPO}/logs"

cd "${REPO}"

git fetch origin devin/v7-ecoregion || true
git merge --ff-only origin/devin/v7-ecoregion || true

find outputs_M -maxdepth 3 -type f \( \
  -name 'model_selection_report.md' -o \
  -name 'selection_meta.tsv' -o \
  -name 'orchestrator_summary.txt' -o \
  -name 'pd_saturated_models.txt' -o \
  -name 'profile_boundary_candidates.tsv' -o \
  -name 'profile_likelihood_v7.png' -o \
  -name 'habitat_suitability_v7.png' -o \
  -name 'habitat_suitability_binary_v7.png' -o \
  -name 'bic_vs_aic_v7.png' \
\) -print0 | xargs -0 -r git add -f

if ! git diff --cached --quiet; then
  git commit -m "Auto-commit v7 reports from 100-species per-species batch"
  git push origin devin/v7-ecoregion
fi

echo "Commit/push complete"

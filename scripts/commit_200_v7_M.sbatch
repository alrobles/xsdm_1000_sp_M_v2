#!/bin/bash
#SBATCH --job-name=commit_200_v7_M
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=4:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M/logs/commit_200_v7_M_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M/logs/commit_200_v7_M_%j.err
set -euo pipefail
REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M"
cd "${REPO_ROOT}"
SP_LIST="${REPO_ROOT}/species_200_v7_M.txt"
git fetch origin master || true
git merge --ff-only origin/master || true
ADDED=0
while IFS= read -r species; do
  [[ -z "$species" ]] && continue
  sp_safe=$(echo "$species" | tr ' ' '_')
  report="outputs_M/${sp_safe}/model_selection_report.md"
  if [[ -f "$report" ]]; then
    git add -f "$report"
    ADDED=$((ADDED+1))
  fi
done < "$SP_LIST"
if ! git diff --cached --quiet; then
  git commit -m "Add completed v7 M-accessibility reports for batch of $ADDED species"
  git push origin master
  echo "Pushed $ADDED reports"
else
  echo "No new reports to commit"
fi

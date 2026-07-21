#!/bin/bash
#SBATCH --job-name=v7_commit_completed
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --time=4:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=2
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_v7/logs/commit_completed_to_M_v7_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_v7/logs/commit_completed_to_M_v7_%j.err
set -euo pipefail

V7_REPO="/home/a474r867/work/xsdm_1000_sp_v7"
M_REPO="/home/a474r867/work/xsdm_1000_sp_M"
mkdir -p "${V7_REPO}/logs" "${M_REPO}/logs"

echo "Syncing completed species (those with model_selection_report.md) to M repo..."
cd "${V7_REPO}/outputs_M"

for d in */; do
  if [[ -f "${d}model_selection_report.md" ]]; then
    rsync -a "${d}" "${M_REPO}/outputs_M/${d}"
  fi
done

cd "${M_REPO}"
git fetch origin master || true
git merge --ff-only origin/master || true

git add -A outputs_M
if ! git diff --cached --quiet; then
  git commit -m "Add completed v7 M-accessibility outputs"
  git push origin master
  echo "Pushed."
else
  echo "No changes to commit."
fi

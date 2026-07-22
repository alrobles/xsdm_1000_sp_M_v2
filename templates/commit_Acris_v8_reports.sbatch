#!/bin/bash
#SBATCH --partition=kbs
#SBATCH --account=kbs
#SBATCH --job-name=commit_v8_Acris
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

set -euo pipefail

REPO_ROOT="/home/a474r867/work/xsdm_1000_sp_M_v2"
cd "${REPO_ROOT}"

git pull origin master

# Add reports and plots from all four experiments
for d in outputs outputs_centroid outputs_berti_sample outputs_inverse_density; do
  sp_dir="${REPO_ROOT}/${d}/Acris_blanchardi"
  if [[ -d "${sp_dir}" ]]; then
    report="${sp_dir}/model_selection_report.md"
    if [[ -f "${report}" ]]; then
      git add -f "${report}"
    fi
    if [[ -d "${sp_dir}/plots" ]]; then
      for png in "${sp_dir}/plots"/*.png; do
        if [[ -f "${png}" ]]; then
          git add -f "${png}"
        fi
      done
    fi
  fi
done

if git diff --cached --quiet; then
  echo "No new reports/plots to commit"
else
  git commit -m "Add v8 model selection reports and plots for Acris blanchardi"
  git push origin master
fi

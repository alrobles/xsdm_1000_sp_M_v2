#!/bin/bash
#SBATCH --job-name=v7_commit_to_M
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=2:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=2
#SBATCH --output=/home/a474r867/work/xsdm_1000_sp_M/logs/commit_to_M_v7_%j.out
#SBATCH --error=/home/a474r867/work/xsdm_1000_sp_M/logs/commit_to_M_v7_%j.err

set -euo pipefail

V7_REPO="/home/a474r867/work/xsdm_1000_sp_v7"
M_REPO="/home/a474r867/work/xsdm_1000_sp_M"
LOGS="${M_REPO}/logs"
mkdir -p "${LOGS}"

cd "${M_REPO}"

# Keep up to date in case something was pushed from another session
git fetch origin master || true
git merge --ff-only origin/master || true

# Mirror outputs_M from the v7 working directory into the M project
rsync -av --delete "${V7_REPO}/outputs_M/" "${M_REPO}/outputs_M/"

# Stage all changes: new species, updates, and removals
git add -A outputs_M

if ! git diff --cached --quiet; then
  git commit -m "Add v7 M-accessibility outputs from 100-species batch"
  git push origin master
  echo "Committed and pushed to xsdm_1000_sp_M master"
else
  echo "No changes to commit"
fi

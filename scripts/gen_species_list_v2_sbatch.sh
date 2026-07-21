#!/bin/bash
#SBATCH --job-name=genlist_v2
#SBATCH --partition=sixhour
#SBATCH --account=kbs
#SBATCH --time=00:30:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/genlist_v2_%j.out
#SBATCH --error=logs/genlist_v2_%j.err
set -euo pipefail

OCC_DIR="/home/a474r867/scratch/xsdm_occurrences"
REPO="/home/a474r867/work/xsdm_1000_sp"
OUT_FILE="${REPO}/species_list_v2.txt"
ENV19_DIR="/home/a474r867/scratch/xsdm_env_extraction_19"

echo "=== Generating v2 species list ==="
echo "Start: $(date)"

# Count lines per CSV and filter <=1000 records (1001 including header)
cd "$OCC_DIR"
> /tmp/sp_v2_counts.txt
for f in *.csv; do
  n=$(wc -l < "$f")
  echo "${n} ${f%.csv}" >> /tmp/sp_v2_counts.txt
done

awk '$1 <= 1001 {$1=""; sub(/^ /, ""); print}' /tmp/sp_v2_counts.txt | sort > "$OUT_FILE"

TOTAL=$(wc -l < "$OUT_FILE")
echo "Species with <=1000 records: $TOTAL"
echo "First 5:"
head -5 "$OUT_FILE"
echo "Last 5:"
tail -5 "$OUT_FILE"

# Identify species needing env19 extraction
if [ -d "$ENV19_DIR" ]; then
  ls -d "$ENV19_DIR"/*/ 2>/dev/null | while read d; do basename "$d"; done | sort > /tmp/env19_done.txt
  TOTAL_ENV19=$(wc -l < /tmp/env19_done.txt)

  # Create list of species needing extraction (convert spaces to _ for comparison)
  cat "$OUT_FILE" | tr ' ' '_' | sort > /tmp/sp_v2_underscore.txt
  comm -23 /tmp/sp_v2_underscore.txt /tmp/env19_done.txt | tr '_' ' ' > "${REPO}/species_list_v2_need_env19.txt"
  NEED_ENV19=$(wc -l < "${REPO}/species_list_v2_need_env19.txt")

  echo "Already have env19: $TOTAL_ENV19"
  echo "Need env19 extraction: $NEED_ENV19"
fi

# Push both lists to GitHub
cd "$REPO"
git add species_list_v2.txt species_list_v2_need_env19.txt 2>/dev/null || true
git commit -m "data: species_list_v2.txt (<=1000 records) + need_env19 list" 2>/dev/null || true
git push origin HEAD 2>/dev/null || true

echo "=== DONE ==="
echo "End: $(date)"

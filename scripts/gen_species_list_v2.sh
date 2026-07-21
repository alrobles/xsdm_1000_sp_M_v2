#!/bin/bash
# Generate species_list_v2.txt: species with <=1000 records
# Fast: uses find+xargs+awk instead of per-file loop
set -euo pipefail

OCC_DIR="/home/a474r867/scratch/xsdm_occurrences"
OUT_FILE="/home/a474r867/work/xsdm_1000_sp/species_list_v2.txt"
ENV19_DIR="/home/a474r867/scratch/xsdm_env_extraction_19"

echo "Counting lines in all CSVs..."
find "$OCC_DIR" -name '*.csv' -print0 | xargs -0 wc -l | \
  awk '$1 <= 1001 && $2 != "total" {
    n = split($2, a, "/");
    gsub(/\.csv$/, "", a[n]);
    print a[n]
  }' | sort > "$OUT_FILE"

echo "Species with <=1000 records: $(wc -l < "$OUT_FILE")"
echo "First 5:"
head -5 "$OUT_FILE"
echo "Last 5:"
tail -5 "$OUT_FILE"

# Check which need env19 extraction
if [ -d "$ENV19_DIR" ]; then
  HAVE_ENV19=$(ls -d "$ENV19_DIR"/*/ 2>/dev/null | while read d; do basename "$d"; done | sort)
  NEED_ENV19=$(comm -23 <(cat "$OUT_FILE" | tr ' ' '_' | sort) <(echo "$HAVE_ENV19") | wc -l)
  TOTAL_ENV19=$(echo "$HAVE_ENV19" | wc -l)
  echo "Already have env19: $TOTAL_ENV19"
  echo "Need env19 extraction: $NEED_ENV19"

  # Generate list of species needing extraction
  comm -23 <(cat "$OUT_FILE" | tr ' ' '_' | sort) <(echo "$HAVE_ENV19") | \
    tr '_' ' ' > "${OUT_FILE%.txt}_need_env19.txt"
  echo "Saved: ${OUT_FILE%.txt}_need_env19.txt"
fi

echo "DONE"

#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# generate_species_list.sh — Generate species list from Parquet
# ─────────────────────────────────────────────────────────────────────
# Usage: bash generate_species_list.sh [--output species_list_all.txt]
#                                      [--min-presences 50]
#                                      [--sample N]
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

OUTPUT="${PROJECT_ROOT}/species_list_all.txt"
MIN_PRES=50
SAMPLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT="$2"; shift 2 ;;
    --min-presences) MIN_PRES="$2"; shift 2 ;;
    --sample) SAMPLE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

log "Generating species list from: $OCC_PARQUET"
log "Min presences: $MIN_PRES"

RCODE="
library(arrow)
occ <- read_parquet('${OCC_PARQUET}')
counts <- as.data.frame(table(occ[occ\$occ == 1, 'species']))
colnames(counts) <- c('species', 'n')
counts <- counts[counts\$n >= ${MIN_PRES}, ]
counts <- counts[order(counts\$n), ]
cat('Species with >=', ${MIN_PRES}, 'presences:', nrow(counts), '\n')
"

if [ -n "$SAMPLE" ]; then
  RCODE="${RCODE}
set.seed(42)
counts <- counts[sample(nrow(counts), min(${SAMPLE}, nrow(counts))), ]
counts <- counts[order(counts\$n), ]
cat('Sampled:', nrow(counts), 'species\n')
"
fi

RCODE="${RCODE}
writeLines(as.character(counts\$species), '${OUTPUT}')
cat('Written to: ${OUTPUT}\n')
"

apptainer exec --cleanenv \
  --bind "${SCRATCH}:${SCRATCH}" \
  "${SIF}" \
  Rscript -e "$RCODE"

TOTAL=$(wc -l < "$OUTPUT" | tr -d ' ')
log "Species list: $OUTPUT ($TOTAL species)"

#!/bin/bash
# regenerate_report_v6.sh — Rebuild per-species English reports after cluster runs.
#
# Usage:
#   ./regenerate_report_v6.sh --species "Genus species"
#   ./regenerate_report_v6.sh --species_list /path/to/species_list.txt
#   ./regenerate_report_v6.sh --species "Crithagra leucopygia" --dry_run
#
# Defaults:
#   REPO_ROOT=/home/a474r867/work/xsdm_1000_sp
#   RESULTS_DIR=${REPO_ROOT}/outputs
#   BIOCLIM_DIR=/home/a474r867/scratch/era5-land/era5_bioclim/bioclim
#   OCC_DIR=/home/a474r867/scratch/xsdm_occurrences
#   SIF=${HOME}/geospatial-rserver/xsdm_latest.sif

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-/home/a474r867/work/xsdm_1000_sp}"
RESULTS_DIR="${RESULTS_DIR:-${REPO_ROOT}/outputs}"
BIOCLIM_DIR="${BIOCLIM_DIR:-/home/a474r867/scratch/era5-land/era5_bioclim/bioclim}"
OCC_DIR="${OCC_DIR:-/home/a474r867/scratch/xsdm_occurrences}"
SCRATCH="${SCRATCH:-/home/a474r867/scratch}"
SIF="${SIF:-${HOME}/geospatial-rserver/xsdm_latest.sif}"
NUM_THREADS="${NUM_THREADS:-2}"
DRY_RUN=0
SPECIES=""
SPECIES_LIST=""

usage() {
  cat <<USAGE
Usage:
  $0 --species "Genus species"
  $0 --species_list /path/to/species_list.txt [--dry_run]

Options:
  --species        Single species name in "Genus species" form.
  --species_list   File with one species per line.
  --bioclim_dir    Override bioclim directory.
  --occ_dir        Override occurrences directory.
  --repo_root      Override repository root.
  --results_dir    Override outputs directory.
  --sif            Override apptainer image path.
  --num_threads    OpenMP threads inside the container (default: ${NUM_THREADS}).
  --dry_run        Print commands without running them.
  --help           Show this help message.
USAGE
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

shell_quote() {
  printf '%q' "$1"
}

extract_meta_value() {
  local meta_file="$1"
  local key="$2"
  awk -F '\t' -v key="$key" '$1 == key { print $2; exit }' "$meta_file"
}

build_container_cmd() {
  local species="$1"
  local species_dir="$2"
  local model_rds="$3"
  local occ_csv="$4"
  local hab_png="$5"
  local shapefile_out="$6"
  local report_md="$7"

  printf 'export APPTAINERENV_OMP_NUM_THREADS=%s\n' "${NUM_THREADS}"
  printf 'export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu\n'
  printf 'apptainer exec --cleanenv \\\n'
  printf '  --bind %q \\\n' "${SCRATCH}:${SCRATCH}"
  printf '  --bind %q \\\n' "/tmp:/tmp"
  printf '  --bind %q \\\n' "${REPO_ROOT}:${REPO_ROOT}"
  printf '  %q \\\n' "${SIF}"
  printf '  bash -lc %q\n' "Rscript \"${REPO_ROOT}/scripts/r/orchestrator/predict_map.R\" --species_dir \"${species_dir}\" --model_rds \"${model_rds}\" --occ_csv \"${occ_csv}\" --bioclim_dir \"${BIOCLIM_DIR}\" --output_png \"${hab_png}\" --shapefile_out \"${shapefile_out}\" --num_threads \"${NUM_THREADS}\" && R_LIBS_USER=\"${HOME}/R/x86_64-pc-linux-gnu-library/4.4\" Rscript \"${REPO_ROOT}/scripts/r/orchestrator/generate_report.R\" --species_dir \"${species_dir}\" --meta \"${species_dir}/selection_meta.tsv\" --output \"${report_md}\""
}

run_species() {
  local species="$1"
  local sp_safe
  sp_safe=$(echo "$species" | tr ' ' '_')
  local species_dir="${RESULTS_DIR}/${sp_safe}"
  local meta_file="${species_dir}/selection_meta.tsv"
  local model_name=""
  local model_rds="${species_dir}/models/"
  local occ_csv="${OCC_DIR}/${species}.csv"
  local hab_png="${species_dir}/plots/habitat_suitability_v6.png"
  local shapefile_out="${species_dir}/gis/mcp_buffer10km.shp"
  local report_md="${species_dir}/model_selection_report.md"

  log "== ${species} =="

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    model_name="$(extract_meta_value "${meta_file}" "M_OMEGA" 2>/dev/null || true)"
    if [[ -z "${model_name}" ]]; then
      model_name="<M_OMEGA>"
    fi
    model_rds+="${model_name}.rds"
    log "Would run inside container:"
    build_container_cmd "${species}" "${species_dir}" "${model_rds}" "${occ_csv}" "${hab_png}" "${shapefile_out}" "${report_md}"
    return 0
  fi

  if [[ ! -d "${species_dir}" ]]; then
    warn "skipping: missing species directory ${species_dir}"
    return 0
  fi

  if [[ ! -f "${meta_file}" ]]; then
    warn "skipping: missing selection_meta.tsv"
    return 0
  fi

  model_name=$(extract_meta_value "${meta_file}" "M_OMEGA" || true)
  if [[ -z "${model_name}" ]]; then
    warn "skipping: no M_Ω"
    return 0
  fi

  model_rds+="${model_name}.rds"
  if [[ ! -f "${model_rds}" ]]; then
    warn "skipping: missing model RDS ${model_rds}"
    return 0
  fi

  if [[ ! -f "${occ_csv}" ]]; then
    warn "skipping: missing occurrence CSV ${occ_csv}"
    return 0
  fi

  mkdir -p "${species_dir}/plots" "${species_dir}/gis"

  (
    set -euo pipefail
    export APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}"
    export APPTAINERENV_LD_LIBRARY_PATH="/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu"
    apptainer exec --cleanenv \
      --bind "${SCRATCH}:${SCRATCH}" \
      --bind "/tmp:/tmp" \
      --bind "${REPO_ROOT}:${REPO_ROOT}" \
      "${SIF}" \
      bash -lc "Rscript \"${REPO_ROOT}/scripts/r/orchestrator/predict_map.R\" --species_dir \"${species_dir}\" --model_rds \"${model_rds}\" --occ_csv \"${occ_csv}\" --bioclim_dir \"${BIOCLIM_DIR}\" --output_png \"${hab_png}\" --shapefile_out \"${shapefile_out}\" --num_threads \"${NUM_THREADS}\" && R_LIBS_USER=\"${HOME}/R/x86_64-pc-linux-gnu-library/4.4\" Rscript \"${REPO_ROOT}/scripts/r/orchestrator/generate_report.R\" --species_dir \"${species_dir}\" --meta \"${meta_file}\" --output \"${report_md}\""
  ) && log "done: ${species}" || warn "failed: ${species}"
}

SPECIES_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --species)
      SPECIES="$2"
      shift 2
      ;;
    --species_list)
      SPECIES_LIST="$2"
      shift 2
      ;;
    --bioclim_dir)
      BIOCLIM_DIR="$2"
      shift 2
      ;;
    --occ_dir)
      OCC_DIR="$2"
      shift 2
      ;;
    --repo_root)
      REPO_ROOT="$2"
      shift 2
      ;;
    --results_dir)
      RESULTS_DIR="$2"
      shift 2
      ;;
    --sif)
      SIF="$2"
      shift 2
      ;;
    --num_threads)
      NUM_THREADS="$2"
      shift 2
      ;;
    --dry_run)
      DRY_RUN=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown arg: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${SPECIES}" && -z "${SPECIES_LIST}" ]]; then
  printf 'ERROR: --species or --species_list required\n' >&2
  usage >&2
  exit 1
fi

if [[ -n "${SPECIES}" && -n "${SPECIES_LIST}" ]]; then
  printf 'ERROR: use only one of --species or --species_list\n' >&2
  exit 1
fi

if [[ -n "${SPECIES}" ]]; then
  SPECIES_ARGS+=("${SPECIES}")
else
  if [[ ! -f "${SPECIES_LIST}" ]]; then
    printf 'ERROR: species_list not found: %s\n' "${SPECIES_LIST}" >&2
    exit 1
  fi
  mapfile -t SPECIES_ARGS < <(grep -vE '^[[:space:]]*(#|$)' "${SPECIES_LIST}")
fi

if [[ "${DRY_RUN}" -eq 0 && ! -x "${SIF}" && ! -f "${SIF}" ]]; then
  warn "SIF path does not exist yet: ${SIF}"
fi

for species in "${SPECIES_ARGS[@]}"; do
  run_species "${species}"
done

#!/bin/bash
# orchestrate_v6.sh — Intelligent multi-phase orchestrator for xsdm v6
# Runs on kbs partition (no time limit). Manages parallel jobs for each phase.
#
# Usage:
#   ./orchestrate_v6.sh --species "Oryctolagus cuniculus"              # single
#   ./orchestrate_v6.sh --species_list /path/to/species_list.txt      # batch
#   ./orchestrate_v6.sh --species_list species_list_v2.txt --max_concurrent 200
#
# Phases per species:
#   L1: all 1-3 variable models in the chosen family
#   L2: N parallel jobs (boundary models of tau-eligible L1)
#   L3: well-behaved scan (sequential over eager wb outputs)
#   L4: boundary of mid-tier (parallel)
#   Profile: 1 job for final model
#
# The orchestrator itself runs on kbs (unlimited time).
# Worker jobs run on sixhour (6h max, fast queue).

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

REPO_ROOT="${REPO_ROOT:-/home/a474r867/work/xsdm_1000_sp}"
SIF="${HOME}/geospatial-rserver/xsdm_latest.sif"
SCRATCH="/home/a474r867/scratch"
# Workflow inputs and outputs live next to the repository (under work/) so they
# survive scratch purges and can be read directly (e.g. from a live RStudio
# session opened on the repo). DATA_DIR holds the migrated inputs.
# Each species gets its own directory under outputs/: outputs/<species>/
DATA_DIR="${DATA_DIR:-${REPO_ROOT}/data}"
RESULTS_DIR="${RESULTS_DIR:-${REPO_ROOT}/outputs}"
ENV_CSV_DIR="${ENV_CSV_DIR:-${DATA_DIR}/env_extraction_19}"
LOGS_DIR="${LOGS_DIR:-${REPO_ROOT}/logs/orchestrator_v6}"

WORKER_SCRIPT="${REPO_ROOT}/scripts/r/orchestrator/fit_single_model.R"
PROFILE_SCRIPT="${REPO_ROOT}/scripts/r/orchestrator/run_profile.R"
PREDICT_MAP_SCRIPT="${REPO_ROOT}/scripts/r/orchestrator/predict_map.R"
REPORT_SCRIPT="${REPO_ROOT}/scripts/r/orchestrator/generate_report.R"

NUM_STARTS="${NUM_STARTS:-100}"
NUM_THREADS="${NUM_THREADS:-2}"   # OMP threads per fit; keep == WORKER_CPUS (see docs/runbook_hpc_performance_worker_cpus.md)
MAX_CONCURRENT="${MAX_CONCURRENT:-200}"
POLL_INTERVAL="${POLL_INTERVAL:-30}"
WORKER_PARTITION="${WORKER_PARTITION:-sixhour}"
WORKER_TIME="${WORKER_TIME:-2:00:00}"
WORKER_MEM="${WORKER_MEM:-8G}"
WORKER_CPUS="${WORKER_CPUS:-2}"    # a fit is a small memory-bound reduction; more cores don't help and hurt scheduling (see docs/runbook_hpc_performance_worker_cpus.md)
APPLY_PREFILTER="${APPLY_PREFILTER:-true}"
PREFILTER_QUANTILE="${PREFILTER_QUANTILE:-0.95}"
DROP_TOP_K="${DROP_TOP_K:-0}"
BIOCLIM_DIR="${BIOCLIM_DIR:-${DATA_DIR}/bioclim}"
OCC_DIR="${OCC_DIR:-${DATA_DIR}/occurrences}"
MODEL_LABELS_OVERRIDE="${MODEL_LABELS_OVERRIDE:-}"
MODEL_SET="${MODEL_SET:-}"
# When truthy, workers skip re-fitting models whose output already exists and
# converged (fits are independent of the L3 well-behaved scan).
REUSE_EXISTING_FITS="${REUSE_EXISTING_FITS:-}"

export APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER}"
export APPTAINERENV_PREFILTER_QUANTILE="${PREFILTER_QUANTILE}"
export APPTAINERENV_DROP_TOP_K="${DROP_TOP_K}"

# ─── Model family definition (default 19 vars: T1..T11,P1..P8) ─────────────

declare -A MODELS=()
declare -a MODEL_NAMES=()

MODEL_LABELS=(T1 T2 T3 T4 T5 T6 T7 T8 T9 T10 T11 P1 P2 P3 P4 P5 P6 P7 P8)

join_by_underscore() {
  local IFS=_
  echo "$*"
}

add_model() {
  local -a vars=("$@")
  local -a temps=()
  local -a precs=()
  local v
  for v in "${vars[@]}"; do
    if [[ "${v}" == T* ]]; then
      temps+=("${v}")
    else
      precs+=("${v}")
    fi
  done

  local name=""
  if [[ ${#temps[@]} -gt 0 ]]; then
    name="$(join_by_underscore "${temps[@]}")"
  else
    name="noT"
  fi
  name+="_"
  if [[ ${#precs[@]} -gt 0 ]]; then
    name+="$(join_by_underscore "${precs[@]}")"
  else
    name+="noP"
  fi

  MODELS["${name}"]="$(IFS=,; echo "${vars[*]}")"
  MODEL_NAMES+=("${name}")
}

generate_models() {
  if [[ -n "${MODEL_LABELS_OVERRIDE}" ]]; then
    IFS=, read -r -a MODEL_LABELS <<< "${MODEL_LABELS_OVERRIDE}"
  else
    MODEL_LABELS=(T1 T2 T3 T4 T5 T6 T7 T8 T9 T10 T11 P1 P2 P3 P4 P5 P6 P7 P8)
  fi

  MODELS=()
  MODEL_NAMES=()

  if [[ "${MODEL_SET}" == "algorithm2_6var" ]]; then
    MODEL_LABELS=(T1 T2 T3 P1 P2 P3)

    add_model T1
    add_model T2
    add_model T3
    add_model T2 T3

    add_model P1
    add_model P2
    add_model P3
    add_model P2 P3

    add_model T1 P1
    add_model T1 P2
    add_model T1 P3
    add_model T1 P2 P3

    add_model T2 P1
    add_model T2 P2
    add_model T2 P3
    add_model T2 P2 P3

    add_model T3 P1
    add_model T3 P2
    add_model T3 P3
    add_model T3 P2 P3

    add_model T2 T3 P1
    add_model T2 T3 P2
    add_model T2 T3 P3
    return 0
  fi

  local n=${#MODEL_LABELS[@]}
  local i j k

  for ((i=0; i<n; i++)); do
    add_model "${MODEL_LABELS[i]}"
  done
  for ((i=0; i<n; i++)); do
    for ((j=i+1; j<n; j++)); do
      add_model "${MODEL_LABELS[i]}" "${MODEL_LABELS[j]}"
    done
  done
  for ((i=0; i<n; i++)); do
    for ((j=i+1; j<n; j++)); do
      for ((k=j+1; k<n; k++)); do
        add_model "${MODEL_LABELS[i]}" "${MODEL_LABELS[j]}" "${MODEL_LABELS[k]}"
      done
    done
  done
}

generate_models
MODEL_COUNT=${#MODEL_NAMES[@]}
if [[ "${MODEL_SET}" == "algorithm2_6var" ]]; then
  EXPECTED_MODEL_COUNT=23
  MODEL_COUNT_LABEL="Algorithm2 6-var subsets"
else
  EXPECTED_MODEL_COUNT=$(( ${#MODEL_LABELS[@]} + (${#MODEL_LABELS[@]} * (${#MODEL_LABELS[@]} - 1) / 2) + (${#MODEL_LABELS[@]} * (${#MODEL_LABELS[@]} - 1) * (${#MODEL_LABELS[@]} - 2) / 6) ))
  MODEL_COUNT_LABEL="19 vars, 1-3 variable combos"
fi
if [[ "${MODEL_COUNT}" -ne "${EXPECTED_MODEL_COUNT}" ]]; then
  echo "WARNING: expected ${EXPECTED_MODEL_COUNT} models, got ${MODEL_COUNT}" >&2
fi

# ─── CLI parsing ─────────────────────────────────────────────────────────────

SPECIES=""
SPECIES_LIST=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --species) SPECIES="$2"; shift 2;;
    --species_list) SPECIES_LIST="$2"; shift 2;;
    --max_concurrent) MAX_CONCURRENT="$2"; shift 2;;
    --num_starts) NUM_STARTS="$2"; shift 2;;
    --num_threads) NUM_THREADS="$2"; shift 2;;
    --worker_partition) WORKER_PARTITION="$2"; shift 2;;
    --poll_interval) POLL_INTERVAL="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

if [[ -z "${SPECIES}" && -z "${SPECIES_LIST}" ]]; then
  echo "ERROR: --species or --species_list required" >&2
  exit 1
fi

# Build species array
declare -a ALL_SPECIES
if [[ -n "${SPECIES}" ]]; then
  ALL_SPECIES=("${SPECIES}")
elif [[ -n "${SPECIES_LIST}" ]]; then
  mapfile -t ALL_SPECIES < "${SPECIES_LIST}"
fi

N_SPECIES=${#ALL_SPECIES[@]}

mkdir -p "${LOGS_DIR}" "${RESULTS_DIR}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  xsdm v6 Orchestrator — Algorithm2 aligned                 ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Species:        ${N_SPECIES}"
echo "║  Models/species: ${MODEL_COUNT} (${MODEL_COUNT_LABEL})"
echo "║  Starts:         ${NUM_STARTS}"
echo "║  Threads/worker: ${NUM_THREADS}"
echo "║  Max concurrent: ${MAX_CONCURRENT}"
echo "║  Worker queue:   ${WORKER_PARTITION} (${WORKER_TIME})"
echo "║  tau formula:    (3+1)*log(n) [corrected]"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Start: $(date)"
echo ""

# ─── Helper functions ────────────────────────────────────────────────────────

submit_worker() {
  local species="$1"
  local model_name="$2"
  local vars="$3"
  local mask="${4:-}"
  local sp_safe=$(echo "${species}" | tr ' ' '_')
  local job_name="v6_${sp_safe}_${model_name}"
  local log_prefix="${LOGS_DIR}/${sp_safe}_${model_name}"

  local mask_arg=""
  if [[ -n "${mask}" ]]; then
    mask_arg="--mask \"${mask}\""
  fi
  local occ_csv_arg=""
  if [[ -n "${OCC_CSV:-}" ]]; then
    occ_csv_arg="--occ_csv \"${OCC_CSV}\""
  fi

  local job_id=$(sbatch \
    --job-name="${job_name}" \
    --partition="${WORKER_PARTITION}" \
    --time="${WORKER_TIME}" \
    --mem="${WORKER_MEM}" \
    --cpus-per-task="${WORKER_CPUS}" \
    --nodes=1 \
    --account=kbs \
    --output="${log_prefix}_%j.out" \
    --error="${log_prefix}_%j.err" \
    --parsable \
    --wrap="
export APPTAINERENV_OMP_NUM_THREADS=${NUM_THREADS}
export APPTAINERENV_APPLY_PREFILTER=${APPLY_PREFILTER}
export APPTAINERENV_PREFILTER_QUANTILE=${PREFILTER_QUANTILE}
export APPTAINERENV_DROP_TOP_K=${DROP_TOP_K}
export APPTAINERENV_MC_CORES=${WORKER_CPUS}
export APPTAINERENV_REUSE_EXISTING_FITS=${REUSE_EXISTING_FITS}
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu
apptainer exec --cleanenv \
  --bind \"${SCRATCH}:${SCRATCH}\" \
  --bind \"/tmp:/tmp\" \
  --bind \"${REPO_ROOT}:${REPO_ROOT}\" \
  \"${SIF}\" \
  Rscript \"${WORKER_SCRIPT}\" \
    --species \"${species}\" \
    --model_name \"${model_name}\" \
    --vars \"${vars}\" \
    --num_starts \"${NUM_STARTS}\" \
    --num_threads \"${NUM_THREADS}\" \
    --env_csv_dir \"${ENV_CSV_DIR}\" \
    ${occ_csv_arg} \
    --output_dir \"${RESULTS_DIR}\" \
    ${mask_arg}
" 2>&1 | head -1)

  echo "${job_id}"
}

read_wb_summary() {
  local wb_rds="$1"
  apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript -e "x <- readRDS('${wb_rds}'); cat(ifelse(isTRUE(x\$well_behaved), 'TRUE', 'FALSE'), as.numeric(x\$pBIC), sep = '\t')" 2>/dev/null
}

list_wb_models_sorted() {
  local sp_dir="$1"
  apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript -e "
wb_dir <- '${sp_dir}/wb'
files <- list.files(wb_dir, pattern = '_wb\\\\.rds\$', full.names = TRUE)
entries <- lapply(files, function(f) {
  x <- tryCatch(readRDS(f), error = function(e) NULL)
  if (is.null(x) || is.null(x\$model_name)) return(NULL)
  pBIC <- suppressWarnings(as.numeric(x\$pBIC))
  if (!is.finite(pBIC)) return(NULL)
  data.frame(name = x\$model_name, pBIC = pBIC, stringsAsFactors = FALSE)
})
df <- do.call(rbind, Filter(Negate(is.null), entries))
if (is.null(df) || nrow(df) == 0) quit(status = 0)
df <- df[order(df\$pBIC, df\$name), ]
cat(paste(df\$name, collapse = '\n'))
" 2>/dev/null
}

submit_profile() {
  local species="$1"
  local model_name="$2"
  local sp_safe=$(echo "${species}" | tr ' ' '_')
  local model_rds="${RESULTS_DIR}/${sp_safe}/models/${model_name}.rds"
  local sp_out="${RESULTS_DIR}/${sp_safe}"
  local log_prefix="${LOGS_DIR}/${sp_safe}_profile"

  local job_id=$(sbatch \
    --job-name="v6_prof_${sp_safe}" \
    --partition="${WORKER_PARTITION}" \
    --time="2:00:00" \
    --mem="16G" \
    --cpus-per-task="${WORKER_CPUS}" \
    --nodes=1 \
    --account=kbs \
    --output="${log_prefix}_%j.out" \
    --error="${log_prefix}_%j.err" \
    --parsable \
    --wrap="
export APPTAINERENV_OMP_NUM_THREADS=${NUM_THREADS}
export APPTAINERENV_APPLY_PREFILTER=${APPLY_PREFILTER}
export APPTAINERENV_PREFILTER_QUANTILE=${PREFILTER_QUANTILE}
export APPTAINERENV_DROP_TOP_K=${DROP_TOP_K}
export APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu
apptainer exec --cleanenv \
  --bind \"${SCRATCH}:${SCRATCH}\" \
  --bind \"${REPO_ROOT}:${REPO_ROOT}\" \
  \"${SIF}\" \
  Rscript \"${PROFILE_SCRIPT}\" \
    --model_rds \"${model_rds}\" \
    --output_dir \"${sp_out}\" \
    --num_threads ${NUM_THREADS}
" 2>&1 | head -1)

  echo "${job_id}"
}

render_iucn_range_preview() {
  local species="$1"
  local sp_safe=$(echo "${species}" | tr ' ' '_')
  local sp_dir="${RESULTS_DIR}/${sp_safe}"
  local pdf_src="${OCC_DIR}/${species}.pdf"
  local pdf_dst="${sp_dir}/iucn_range.pdf"
  local png_dst="${sp_dir}/plots/iucn_range.png"
  local prefix="${sp_dir}/plots/iucn_range"
  local log_prefix="${LOGS_DIR}/${sp_safe}_iucn"

  if [[ ! -f "${pdf_src}" ]]; then
    echo "    WARNING: missing IUCN PDF ${pdf_src}; skipping preview"
    return 0
  fi

  mkdir -p "${sp_dir}/plots"
  cp "${pdf_src}" "${pdf_dst}" || {
    echo "    WARNING: could not copy IUCN PDF to ${pdf_dst}"
    return 0
  }

  if apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    bash -lc "PDF_IN='${pdf_dst}' PNG_OUT='${png_dst}' Rscript -e 'pdf_in <- Sys.getenv(\"PDF_IN\"); png_out <- Sys.getenv(\"PNG_OUT\"); if (requireNamespace(\"pdftools\", quietly = TRUE)) { pdftools::pdf_convert(pdf_in, format = \"png\", pages = 1, dpi = 150, filenames = png_out); } else quit(status = 1)' >/dev/null 2>&1 || { command -v pdftoppm >/dev/null 2>&1 && pdftoppm -png -r 150 -f 1 -l 1 '${pdf_dst}' '${prefix}' && mv '${prefix}-1.png' '${png_dst}'; } || { command -v convert >/dev/null 2>&1 && convert '${pdf_dst}[0]' '${png_dst}'; }" >> "${log_prefix}.log" 2>&1; then
    return 0
  fi

  echo "    WARNING: IUCN preview conversion failed (see ${log_prefix}.log)"
  return 0
}

wait_for_jobs() {
  local -n job_ids_ref=$1
  local desc="$2"
  local n_jobs=${#job_ids_ref[@]}
  local start_time=$(date +%s)

  echo "  Waiting for ${n_jobs} ${desc} jobs..."

  while true; do
    local n_done=0
    for jid in "${job_ids_ref[@]}"; do
      local state=$(sacct -j "${jid}" --format=State --noheader -P 2>/dev/null | head -1 | tr -d ' ')
      case "${state}" in
        COMPLETED|FAILED|CANCELLED|TIMEOUT|NODE_FAIL|OUT_OF_MEMORY)
          ((n_done++));;
      esac
    done

    if [[ ${n_done} -ge ${n_jobs} ]]; then
      local elapsed=$(( $(date +%s) - start_time ))
      echo "  All ${n_jobs} ${desc} jobs done (${elapsed}s)"
      return 0
    fi

    sleep "${POLL_INTERVAL}"
  done
}

# ─── Boundary masks ──────────────────────────────────────────────────────────

generate_boundary_masks() {
  local p=$1
  local -n masks_ref=$2

  masks_ref=()
  # pd=Inf
  masks_ref+=("bd_pd1:pd=Inf")
  # sigL_i=Inf for each var
  for ((i=1; i<=p; i++)); do
    masks_ref+=("bd_sigL${i}:sigltil${i}=Inf")
    masks_ref+=("bd_sigR${i}:sigrtil${i}=Inf")
  done
  # pd=Inf + sigL_i=Inf
  for ((i=1; i<=p; i++)); do
    masks_ref+=("bd_pd1_sigL${i}:pd=Inf,sigltil${i}=Inf")
    masks_ref+=("bd_pd1_sigR${i}:pd=Inf,sigrtil${i}=Inf")
  done
}

# ─── Process one species ─────────────────────────────────────────────────────

process_species() {
  local species="$1"
  local sp_safe=$(echo "${species}" | tr ' ' '_')
  local sp_dir="${RESULTS_DIR}/${sp_safe}"
  local summary_file="${sp_dir}/orchestrator_summary.txt"

  mkdir -p "${sp_dir}/models" "${sp_dir}/wb"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "SPECIES: ${species}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # ── PHASE L1: Submit all non-boundary models in parallel ──
  echo ""
  echo "  ▶ PHASE L1: Submitting ${MODEL_COUNT} non-boundary models..."

  declare -a L1_JOBS=()
  declare -a L1_MODELS=()

  for model_name in "${MODEL_NAMES[@]}"; do
    local vars="${MODELS[$model_name]}"
    local jid=$(submit_worker "${species}" "${model_name}" "${vars}")
    L1_JOBS+=("${jid}")
    L1_MODELS+=("${model_name}")
    echo "    [L1] ${model_name} (${vars}) → job ${jid}"
  done

  wait_for_jobs L1_JOBS "L1"

  # ── Read L1 results, compute tau, find eligible ──
  echo ""
  echo "  ▶ Analyzing L1 results..."

  local best_pBIC=999999
  declare -A L1_PBIC=()
  local n_data=0

  for model_name in "${L1_MODELS[@]}"; do
    local rds="${sp_dir}/models/${model_name}.rds"
    if [[ -f "${rds}" ]]; then
      # Extract pBIC from RDS using R
      local pbic=$(apptainer exec --cleanenv --bind "${SCRATCH}:${SCRATCH}" --bind "${REPO_ROOT}:${REPO_ROOT}" "${SIF}" \
        Rscript -e "x<-readRDS('${rds}'); if(x\$status=='success') cat(x\$pBIC) else cat('NA')" 2>/dev/null)
      if [[ "${pbic}" != "NA" && -n "${pbic}" ]]; then
        L1_PBIC["${model_name}"]="${pbic}"
        if (( $(echo "${pbic} < ${best_pBIC}" | bc -l) )); then
          best_pBIC="${pbic}"
        fi
        # Get n_data from first successful model
        if [[ ${n_data} -eq 0 ]]; then
          n_data=$(apptainer exec --cleanenv --bind "${SCRATCH}:${SCRATCH}" --bind "${REPO_ROOT}:${REPO_ROOT}" "${SIF}" \
            Rscript -e "x<-readRDS('${rds}'); cat(x\$n)" 2>/dev/null)
        fi
      fi
    fi
  done

  local n_success=${#L1_PBIC[@]}
  echo "    L1 success: ${n_success}/${MODEL_COUNT} | best pBIC: ${best_pBIC} | n_data: ${n_data}"

  if [[ ${n_success} -eq 0 ]]; then
    echo "    ERROR: All L1 models failed for ${species}" | tee "${summary_file}"
    return 1
  fi

  # tau = (3+1)*log(n_data)
  local tau=$(echo "4 * l(${n_data})" | bc -l)
  local threshold=$(echo "${best_pBIC} + ${tau}" | bc -l)
  echo "    tau = 4*log(${n_data}) = ${tau}"
  echo "    threshold = ${best_pBIC} + ${tau} = ${threshold}"

  # ── PHASE L2: Boundary models of eligible L1 ──
  echo ""
  echo "  ▶ PHASE L2: Boundary expansion..."

  declare -a L2_JOBS=()
  declare -a L2_MODELS=()

  for model_name in "${!L1_PBIC[@]}"; do
    local pbic="${L1_PBIC[$model_name]}"
    if (( $(echo "${pbic} <= ${threshold}" | bc -l) )); then
      local vars="${MODELS[$model_name]}"
      local n_vars=$(echo "${vars}" | tr ',' '\n' | wc -l)

      # Generate boundary masks for this model
      declare -a bmasks=()
      generate_boundary_masks "${n_vars}" bmasks

      for mask_entry in "${bmasks[@]}"; do
        local bname="${mask_entry%%:*}"
        local mask_val="${mask_entry#*:}"
        local full_name="${model_name}__${bname}"

        local jid=$(submit_worker "${species}" "${full_name}" "${vars}" "${mask_val}")
        L2_JOBS+=("${jid}")
        L2_MODELS+=("${full_name}")
        echo "    [L2] ${full_name} → job ${jid}"
      done
    fi
  done

  local n_l2=${#L2_JOBS[@]}
  echo "    L2 jobs submitted: ${n_l2}"

  if [[ ${n_l2} -gt 0 ]]; then
    wait_for_jobs L2_JOBS "L2"
  fi

  # ── PHASE L3: Combine L1+L2, rank by pBIC, well-behaved scan ──
  echo ""
  echo "  ▶ PHASE L3: Well-behaved scan..."

  # Get all model pBICs (L1 + L2) and sort
  local all_models_sorted=$(list_wb_models_sorted "${sp_dir}")

  echo "    L3 models ranked by pBIC (top 5):"
  echo "${all_models_sorted}" | head -5 | while read m; do echo "      ${m}"; done

  # Well-behaved scan: check models in pBIC order
  local M_OMEGA=""
  local OMEGA=""
  declare -a SCANNED_MODELS=()

  while IFS= read -r model_name; do
    [[ -z "${model_name}" ]] && continue
    SCANNED_MODELS+=("${model_name}")

    local wb_rds="${sp_dir}/wb/${model_name}_wb.rds"
    if [[ -f "${wb_rds}" ]]; then
      echo "    Checking well-behaved: ${model_name}"
      local wb_info=$(read_wb_summary "${wb_rds}")
      local is_wb="${wb_info%%$'\t'*}"
      local wb_pbic="${wb_info#*$'\t'}"

      if [[ "${is_wb}" == "TRUE" ]]; then
        M_OMEGA="${model_name}"
        OMEGA="${wb_pbic}"
        echo "    >>> WELL-BEHAVED FOUND: ${M_OMEGA} (pBIC=${OMEGA})"
        break
      else
        echo "    × ${model_name} — not well-behaved"
      fi
    else
      echo "    × ${model_name} — wb artifact missing"
    fi
  done <<< "${all_models_sorted}"

  if [[ -z "${M_OMEGA}" ]]; then
    echo "    WARNING: No well-behaved model found in L3"
    echo "NO_WELL_BEHAVED" > "${summary_file}"
    return 1
  fi

  # ── PHASE L4: Boundary models of mid-tier L1 ──
  echo ""
  echo "  ▶ PHASE L4: Mid-tier boundary check..."

  local omega_tau=$(echo "${OMEGA} + ${tau}" | bc -l)
  declare -a L4_JOBS=()
  declare -a L4_MODELS=()

  for model_name in "${!L1_PBIC[@]}"; do
    local pbic="${L1_PBIC[$model_name]}"
    # In range [best + tau, Omega + tau] (literal Algorithm2: lower bound inclusive)
    if (( $(echo "${pbic} >= ${threshold} && ${pbic} <= ${omega_tau}" | bc -l) )); then
      local vars="${MODELS[$model_name]}"
      local n_vars=$(echo "${vars}" | tr ',' '\n' | wc -l)

      declare -a bmasks=()
      generate_boundary_masks "${n_vars}" bmasks

      for mask_entry in "${bmasks[@]}"; do
        local bname="${mask_entry%%:*}"
        local mask_val="${mask_entry#*:}"
        local full_name="${model_name}__${bname}"

        local jid=$(submit_worker "${species}" "${full_name}" "${vars}" "${mask_val}")
        L4_JOBS+=("${jid}")
        L4_MODELS+=("${full_name}")
        echo "    [L4] ${full_name} → job ${jid}"
      done
    fi
  done

  if [[ ${#L4_JOBS[@]} -gt 0 ]]; then
    wait_for_jobs L4_JOBS "L4"

    # Check L4 models with pBIC < Omega for well-behaved
    echo "    Scanning L4 for better model..."
    local best_l4_model=""
    local best_l4_pbic=""
    for l4_model in "${L4_MODELS[@]}"; do
      local wb_rds="${sp_dir}/wb/${l4_model}_wb.rds"
      [[ ! -f "${wb_rds}" ]] && continue
      local wb_info=$(read_wb_summary "${wb_rds}")
      local is_wb="${wb_info%%$'\t'*}"
      local l4_pbic="${wb_info#*$'\t'}"

      local l4_better=""
      if [[ "${is_wb}" == "TRUE" &&
            -n "${l4_pbic}" &&
            "${l4_pbic}" != "NA" &&
            "${l4_pbic}" != "NaN" &&
            "${l4_pbic}" != "Inf" &&
            "${l4_pbic}" != "-Inf" ]]; then
        l4_better=$(echo "${l4_pbic} < ${OMEGA}" | bc -l 2>/dev/null) || l4_better=""
      fi
      if [[ "${l4_better}" == "1" ]]; then
        if [[ -z "${best_l4_pbic}" ]]; then
          best_l4_model="${l4_model}"
          best_l4_pbic="${l4_pbic}"
        else
          local l4_lower=""
          l4_lower=$(echo "${l4_pbic} < ${best_l4_pbic}" | bc -l 2>/dev/null) || l4_lower=""
          if [[ "${l4_lower}" == "1" ]]; then
            best_l4_model="${l4_model}"
            best_l4_pbic="${l4_pbic}"
          fi
        fi
      fi
    done
    if [[ -n "${best_l4_model}" ]]; then
      M_OMEGA="${best_l4_model}"
      OMEGA="${best_l4_pbic}"
      echo "    >>> NEW M_OMEGA from L4: ${M_OMEGA} (pBIC=${OMEGA})"
    fi
  else
    echo "    No models eligible for L4"
  fi

  # ── PHASE Profile: Run profile likelihood on M_Omega ──
  echo ""
  echo "  ▶ PHASE Profile: ${M_OMEGA}"

  local prof_jid=$(submit_profile "${species}" "${M_OMEGA}")
  local prof_arr=("${prof_jid}")
  wait_for_jobs prof_arr "profile"

  # ── PHASE Map: Habitat suitability + TSS for M_Omega ──
  echo ""
  echo "  ▶ PHASE Map: ${M_OMEGA}"
  local occ_csv="${OCC_DIR}/${species}.csv"
  if [[ -f "${occ_csv}" ]]; then
    local map_log="${LOGS_DIR}/${sp_safe}_map.log"
    mkdir -p "${sp_dir}/plots" "${sp_dir}/gis"
    if ! APPTAINERENV_OMP_NUM_THREADS="${NUM_THREADS}" \
      APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER}" \
      APPTAINERENV_PREFILTER_QUANTILE="${PREFILTER_QUANTILE}" \
      APPTAINERENV_DROP_TOP_K="${DROP_TOP_K}" \
      APPTAINERENV_LD_LIBRARY_PATH=/usr/local/lib/R/lib:/usr/local/lib/R/modules:/usr/lib/x86_64-linux-gnu \
      apptainer exec --cleanenv \
        --bind "${SCRATCH}:${SCRATCH}" \
        --bind /tmp:/tmp \
        --bind "${REPO_ROOT}:${REPO_ROOT}" \
        "${SIF}" \
        Rscript "${PREDICT_MAP_SCRIPT}" \
          --species_dir "${sp_dir}" \
          --model_rds "${sp_dir}/models/${M_OMEGA}.rds" \
          --occ_csv "${occ_csv}" \
          --bioclim_dir "${BIOCLIM_DIR}" \
          --output_png "${sp_dir}/plots/habitat_suitability_v6.png" \
          --shapefile_out "${sp_dir}/gis/bbox_buffer10km.shp" \
          --num_threads "${NUM_THREADS}" \
        >> "${map_log}" 2>&1; then
      echo "    WARNING: map generation failed (see ${map_log})"
    fi

    render_iucn_range_preview "${species}"
  else
    echo "    WARNING: missing occurrence CSV ${occ_csv}; skipping map phase"
  fi

  # ── Write selection trail metadata (consumed by generate_report.R) ──
  local meta="${sp_dir}/selection_meta.tsv"
  {
    printf 'SPECIES\t%s\n' "${species}"
    printf 'N_DATA\t%s\n' "${n_data}"
    printf 'MAX_P\t3\n'
    printf 'TAU\t%s\n' "${tau}"
    printf 'BEST_PBIC_L1\t%s\n' "${best_pBIC}"
    printf 'THRESHOLD_L2\t%s\n' "${threshold}"
    printf 'OMEGA\t%s\n' "${OMEGA}"
    printf 'M_OMEGA\t%s\n' "${M_OMEGA}"
    printf 'OMEGA_TAU\t%s\n' "${omega_tau}"
    printf 'N_L1_SUCCESS\t%s\n' "${n_success}"
    printf 'N_L2\t%s\n' "${n_l2}"
    printf 'N_L4\t%s\n' "${#L4_JOBS[@]}"
    for m in "${SCANNED_MODELS[@]}"; do printf 'SCANNED_MODEL\t%s\n' "${m}"; done
    for m in "${!L1_PBIC[@]}"; do printf 'L1\t%s\t%s\n' "${m}" "${L1_PBIC[$m]}"; done
    for m in "${L2_MODELS[@]}"; do printf 'L2_MODEL\t%s\n' "${m}"; done
    for m in "${L4_MODELS[@]}"; do printf 'L4_MODEL\t%s\n' "${m}"; done
  } > "${meta}"

  # ── Generate per-species selection report (L1–L4 rules + lists + profiles) ──
  echo "  ▶ Generating report: ${sp_dir}/model_selection_report.md"
  APPTAINERENV_APPLY_PREFILTER="${APPLY_PREFILTER}" \
  APPTAINERENV_PREFILTER_QUANTILE="${PREFILTER_QUANTILE}" \
  APPTAINERENV_DROP_TOP_K="${DROP_TOP_K}" \
  apptainer exec --cleanenv \
    --bind "${SCRATCH}:${SCRATCH}" \
    --bind "${REPO_ROOT}:${REPO_ROOT}" \
    "${SIF}" \
    Rscript "${REPORT_SCRIPT}" \
      --species_dir "${sp_dir}" \
      --meta "${meta}" \
      --output "${sp_dir}/model_selection_report.md" \
    >> "${LOGS_DIR}/${sp_safe}_report.log" 2>&1 || \
    echo "    WARNING: report generation failed (see ${LOGS_DIR}/${sp_safe}_report.log)"

  # ── Summary ──
  echo ""
  echo "  ═══════════════════════════════════════════════════════"
  echo "  RESULT: ${species}"
  echo "    Selected model: ${M_OMEGA}"
  echo "    pBIC (Omega):   ${OMEGA}"
  echo "    L1 models:      ${n_success}/${MODEL_COUNT}"
  echo "    L2 boundary:    ${n_l2}"
  echo "    L4 boundary:    ${#L4_JOBS[@]}"
  echo "    tau:            ${tau}"
  echo "  ═══════════════════════════════════════════════════════"

  echo "DONE|${M_OMEGA}|${OMEGA}|${n_success}|${n_l2}|${#L4_JOBS[@]}" > "${summary_file}"
}

# ─── Main loop: process all species ─────────────────────────────────────────

TOTAL_START=$(date +%s)

for ((si=0; si<N_SPECIES; si++)); do
  species="${ALL_SPECIES[$si]}"
  echo ""
  echo "[$((si+1))/${N_SPECIES}] Processing: ${species}"
  process_species "${species}" || true
done

TOTAL_ELAPSED=$(( $(date +%s) - TOTAL_START ))
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ORCHESTRATOR COMPLETE                                     ║"
echo "║  Species processed: ${N_SPECIES}"
echo "║  Total elapsed:     $((TOTAL_ELAPSED/3600))h $((TOTAL_ELAPSED%3600/60))m"
echo "╚══════════════════════════════════════════════════════════════╝"

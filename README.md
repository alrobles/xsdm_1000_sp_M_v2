# xSDM Model Selection Pipeline — Batch 1000 Species

Pipeline de selección de modelos xSDM para ~3,000 especies con ≤1001 ocurrencias GBIF.
Corre en dos entornos: el cluster **KU HPC** (partición `sixhour`/`kbs`) vía Slurm,
y la **flotilla reumanlab** (workstations locales) vía Apptainer + GNU parallel.

## Pipeline v6 (activo)

**Script principal:** `scripts/r/xsdm_model_selection_v6.R` — self-contained, corre el
pipeline completo (L1→L2→L3→L4→profile) para una especie en un solo proceso R.

Alineado con `Algorithm2.docx` (Daniel Reuman, 2026).

### Variables (6)
| Label | BIOCLIM | Descripción |
|-------|---------|-------------|
| T1    | bio01   | Annual mean temperature |
| T2    | bio10   | Mean temp of warmest quarter |
| T3    | bio11   | Mean temp of coldest quarter |
| P1    | bio12   | Annual precipitation |
| P2    | bio16   | Precip of wettest quarter |
| P3    | bio17   | Precip of driest quarter |

Las variables de precipitación (P1, P2, P3) se reescalan dividiendo entre 100
(mm → unidades comparables a temperatura) para evitar Hessianos mal condicionados.

### Subsets y modelos (23 fijos)
- **T subsets (5):** none, T1, T2, T3, T2+T3
- **P subsets (5):** none, P1, P2, P3, P2+P3
- **Total:** 5×5 − 2 combinaciones excluidas (none×none, T2T3×P2P3) = **23 modelos**
- **max_p = 3** (máximo de variables en un solo modelo)

### Algoritmo
```
L1 → L2 (boundary-eligible) → L3 → well-behaved scan → M_Omega
   → L4 (boundary mid-tier) → re-scan → final M_Omega → profile
```

- **L1:** 23 modelos sin boundary, pBIC ranking
- **L2:** Solo modelos con pBIC ≤ best + tau → expansión a máscaras boundary
- **L3:** Scan de modelos well-behaved (L1+L2 ordenados por pBIC) → M_Omega
- **L4:** Boundary mid-tier models, re-scan completo
- **Profile:** Verificación final de likelihood profiles + arc check

### tau (corregido)
```
tau = (max_p + 1) × log(n_data) = 4 × log(n_data)
```
**Corrección 2026:** antes era `2 × (max_p+1) × log(n)`; el factor de 2 era erróneo.
Un modelo boundary tiene a lo sumo `(N+1)` parámetros menos que su contraparte
no-boundary, así que su ΔBIC es `-(N+1)·log(n)`.

### Output por especie
```
<output_dir>/<Species>/
├── model_selection_report.md   # Reporte markdown completo (L1…profile + arc check)
├── model_results_v6.rds        # Resultados completos (modelo seleccionado, L1–L4, profiles)
└── plots/
    └── profile_likelihood_v6.pdf
```

## Infraestructura

### Modo A — KU HPC (Slurm)

| Componente | Archivo |
|------------|---------|
| Launcher orquestador | `templates/orchestrate_v6.sbatch` (corre en `kbs`, sin límite de tiempo) |
| Orquestador | `scripts/orchestrate_v6.sh` (lanza jobs worker en `sixhour`) |
| Worker: fit 1 modelo | `scripts/r/orchestrator/fit_single_model.R` |
| Worker: well-behaved | `scripts/r/orchestrator/check_well_behaved.R` |
| Worker: profile | `scripts/r/orchestrator/run_profile.R` |

```bash
# Una especie
sbatch templates/orchestrate_v6.sbatch --species "Oryctolagus cuniculus"
# Batch
sbatch templates/orchestrate_v6.sbatch --species_list species_list_v2.txt --max_concurrent 200
```

El orquestador lanza los 23 modelos L1 en paralelo (jobs `sixhour`), espera, computa
tau, expande boundary (L2), hace el scan well-behaved (L3), L4 y profile.

- **HPC user:** `a474r867` · **Container:** `~/geospatial-rserver/xsdm_latest.sif`
- **Datos ambientales:** `~/scratch/xsdm_env_extraction_19/<Species>/` (CSVs por variable)

### Modo B — reumanlab flotilla (local, sin Slurm)

Para correr v6 en las workstations reumanlab (vía hermes.ecoseek.org) sin Slurm.
Cada especie corre el pipeline completo en un proceso R dentro del SIF; las especies
se paralelizan con GNU parallel.

| Script | Uso |
|--------|-----|
| `templates/run_xsdm_v6_local.sh` | Una especie, usa (casi) todos los cores |
| `templates/orchestrate_xsdm_v6_local.sh` | Batch multi-especie vía GNU parallel |

```bash
# Una especie
./templates/run_xsdm_v6_local.sh "Breviceps montanus"               # starts=1500, threads=nproc-1
./templates/run_xsdm_v6_local.sh "Breviceps montanus" 25 8          # starts=25, threads=8

# Batch (4 especies en paralelo, threads = nproc/4 c/u)
./templates/orchestrate_xsdm_v6_local.sh species_list_20.txt 4
```

Rutas por defecto (overrideables vía env `SIF`, `SCRATCH`, `ENV_CSV_DIR`, `OUTPUT_DIR`):
- **Container:** `$HOME/geospatial-rserver/xsdm_latest.sif`
- **Datos ambientales:** `$HOME/scratch/xsdm_env_extraction_19/<Species>/`
- **Output:** `$HOME/scratch/xsdm_results_v6/<Species>/`

> Mismo `xsdm_latest.sif` que en KU HPC → resultados reproducibles entre ambos modos.

## Historial de versiones

| Versión | Script | Modelos | Estado |
|---------|--------|---------|--------|
| v2 | `xsdm_model_selection_v2.R` | 23 | Archivado (2,980 especies en `xsdm_1000_sp_results_v2/`) |
| v3 | `xsdm_model_selection_v3.R` | 23 | Archivado |
| v4 | `xsdm_model_selection_v4.R` | 23 | Archivado (corrección de tau) |
| v5 | `xsdm_model_selection_v5.R` | 88 (19 vars) | **Abandonado** — se descartó la expansión a 88 modelos |
| **v6** | `xsdm_model_selection_v6.R` | **23** | **Activo** — Algorithm2 aligned, tau corregido, KU HPC + reumanlab |

Ver [`docs/v3_migration.md`](docs/v3_migration.md) y [`docs/tau_correction.md`](docs/tau_correction.md)
para el registro histórico.

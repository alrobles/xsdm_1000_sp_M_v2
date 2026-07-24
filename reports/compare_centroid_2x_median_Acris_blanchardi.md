# v8 smoke comparison: centroid / 2x_median buffer

Species: *Acris blanchardi*  
Config: `pa_method=centroid`, `buffer_m=2x_median`, `pa_in_buffer=false`, 10 % of occurrences, 50 starts, `--skip_profile`.

## Selected model
- Model: `T2_T3_P3__bd_pd1_sigR2`
- pBIC: 808.4
- logLik: -365.3022
- n: 654 (pres + pseudo-abs)

## TSS (in-sample, after occ_prefilter)
- **centroid 2x_median (this run): 0.2497**
  - Threshold: 0.5695
  - Sensitivity: 0.7882
  - Specificity: 0.4615
  - Presences / pseudo-absences: 291 / 195

## Comparable TSS values

| Method | Dataset | TSS | Notes |
|---|---|---|---|
| v7 ring (`outputs_M`) | full | **0.7932** | anillo periférico (M_buffer \ M) |
| v7 random `M+buffer` | Acris gryllus smoke | 0.3595 | única especie pareja disponible; muestreo uniforme dentro de todo M_buffer |
| v7 random `M+buffer` | promedio parcial (n=248) | 0.463 | reporte parcial `tss_outputs_M_random_partial.csv` |
| v8 `centroid_exp` | 10 % smoke | **0.5074** | peso exponencial con la distancia al centroide dentro de M_buffer |
| v8 `centroid` (2x_median) | 10 % smoke | **0.2497** | peso lineal con la distancia al centroide dentro de M_buffer |
| v8 `random` | 25-100 % matrix | 0.41-0.45 | muestreo uniforme dentro de M_buffer |
| v8 `inverse_density` | 25-100 % matrix | 0.48-0.52 | peso inverso a densidad de presencias |

## Interpretation

- El anillo periférico (`v7ring`) sigue dando el TSS más alto (0.79), pero el bootstrap paramétrico sugiere que ese diseño sesga la inferencia de parámetros.
- Muestrear dentro de todo `M_buffer` con `centroid` lineal produce un TSS muy bajo (0.25), incluso por debajo del muestreo uniforme aleatorio (`random` ~0.41-0.45). Esto indica que, con el buffer `2x_median`, el peso lineal por distancia al centroide no coloca las pseudo-ausencias en ambientes lo suficientemente distintos de las presencias.
- El método `centroid_exp` (peso exponencial) obtuvo 0.5074, notablemente mayor que el lineal, y dentro del rango de `inverse_density`.
- En la matriz 25/50/75/100 %, `centroid` con `pa_factor` y `buffer_m` usados por defecto dio ~0.52, mucho más alto que este smoke. La diferencia clave aquí es el buffer `2x_median` (más pequeño?) y el submuestreo al 10 %.

## Próximos pasos sugeridos
- Revisar si `2x_median` produce un buffer demasiado pequeño para *Acris blanchardi*; comparar con `4x_median` o un buffer fijo mayor.
- Probar `centroid_exp` con `2x_median` en el mismo smoke 10 % para aislar el efecto del peso exponencial vs lineal.

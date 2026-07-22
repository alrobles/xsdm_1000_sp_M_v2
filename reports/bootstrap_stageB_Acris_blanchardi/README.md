# Stage B virtual species parametric bootstrap (Acris blanchardi)

Se generaron presencias virtuales con el modelo final y se volvieron a muestrear pseudo-ausencias con la misma regla original.

- `v7ring`: pseudo-ausencias uniformes en el anillo `M_buffer \ M` (pa_factor=2)
- `centroid_exp`: pseudo-ausencias dentro de `M_buffer` con peso exponencial creciente hacia el borde

TSS de los modelos originales (smoke 10 %, 50 starts):
- v7ring: 0.7816 (`T3_P3`)
- centroid_exp: 0.4835 (`T2_P1__bd_pd1_sigL1`)

## Resultados B=10

| Método | n_success | Parámetros fuera del IC 95 % surrogate |
|---|---|---|
| v7ring | 10/10 | `ctil`, `pd` |
| centroid_exp | 10/10 | `ctil` (marginal), `pd` es `Inf` en ambos |

Los intervalos son amplios, lo que indica alta varianza con el 10 % de los datos, pero la desviación de `ctil` y `pd` apunta a que el anillo periférico introduce un sesgo en la estimación de los parámetros de detección/centro.

Archivos:
- `v7ring_params.csv`, `v7ring_CI.csv`
- `centroid_params.csv`, `centroid_CI.csv`

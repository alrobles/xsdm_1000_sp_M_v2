# Stage B virtual species parametric bootstrap — 25 % data, B=100

Modelos finales (25 % datos, 50 starts):
- **v7ring** TSS 0.7656, modelo `T3_P3`
- **centroid_exp** TSS 0.5227, modelo `T2_T3_P3__bd_pd1_sigL1`

Se generaron presencias virtuales con el modelo final y se re-muestrearon pseudo-ausencias con la misma regla original.

## Resultados B=100

| Método | n_success | Parámetros fuera del IC 95 % surrogate |
|---|---|---|
| **v7ring** (anillo `M_buffer \\ M`, factor 2) | 100/100 | `mu2`, `ctil`, `pd`, `o_par1` |
| **centroid_exp** (dentro de `M_buffer`, peso exponencial hacia el borde) | 100/100 | ninguno (`sigltil1` y `pd` son `Inf` por máscara) |

Conclusión: el anillo periférico introduce un sesgo sistemático en la estimación del nicho (centro, detección y rotación), mientras que el muestreo dentro de `M_buffer` con peso de centroide es estadísticamente auto-consistente.

Archivos:
- `v7ring_params.csv`, `v7ring_CI.csv`
- `centroid_params.csv`, `centroid_CI.csv`

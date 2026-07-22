# xsdm v6 — Model selection report (Algorithm2)

**Species:** *Acris blanchardi*

This report documents, step by step, the literal Algorithm2 selection rules
applied to this species. Each phase (L1–L4) includes the rule itself and
the complete list of models with their classification.

**Definition of model success:** a model has `status == "success"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.

## Data and units

- Species directory: `/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_v6bbox_smoke/Acris_blanchardi`
- Sample size: 1637
- Maximum variables per model: 3
- Tau (τ): 29.6025
- L2 threshold: best L1 + τ = 1575.4895
- Ω threshold: 1573.6565
- Temperature variables are in degrees Celsius (converted from ERA5Land Kelvin); precipitation variables are in mm.
- Each model RDS stores the per-variable `scale_factors` applied during fitting.

## IUCN range and presence points

*IUCN range figure not available.*

## Literal selection rules (Algorithm2)

1. Fit all 23 non-boundary L1 models and rank them by pBIC.
2. Expand the L1 models with pBIC ≤ best_L1 + τ to their boundary versions.
3. Form L3 = L1 ∪ L2, rank by pBIC, and select the first well-behaved model
   (Flags A and B both pass). That model is M_Ω.
4. Expand boundary models in the intermediate pBIC band [best_L1 + τ, Ω + τ].

## Phase L1 — 23 non-boundary models

Rule: fit the 23 non-boundary models and rank them by ascending pBIC.

| # | Model | Variables | pBIC | logLik | n_free | status |
|---|-------|-----------|------|--------|--------|--------|
| 1 | T2_T3_P3 ≤τ | T2+T3+P3 | 1545.9 | -721.139 | 14 | success |
| 2 | T1_P3 ≤τ | T1+P3 | 1548.1 | -740.731 | 9 | success |
| 3 | T1_P1 ≤τ | T1+P1 | 1556.3 | -744.843 | 9 | success |
| 4 | T2_P3 ≤τ | T2+P3 | 1556.4 | -744.875 | 9 | success |
| 5 | T2_P1 ≤τ | T2+P1 | 1558.5 | -745.960 | 9 | success |
| 6 | T2_T3_P1 ≤τ | T2+T3+P1 | 1560.0 | -728.188 | 14 | success |
| 7 | T1_P2 ≤τ | T1+P2 | 1561.3 | -747.326 | 9 | success |
| 8 | T3_P3 ≤τ | T3+P3 | 1562.0 | -747.677 | 9 | success |
| 9 | T3_P2 ≤τ | T3+P2 | 1562.7 | -748.039 | 9 | success |
| 10 | T2_T3_P2 ≤τ | T2+T3+P2 | 1568.6 | -732.508 | 14 | success |
| 11 | T2_P2 ≤τ | T2+P2 | 1574.3 | -753.825 | 9 | success |
| 12 | T3_P1 | T3+P1 | 1576.4 | -754.914 | 9 | success |
| 13 | T3_P2_P3 | T3+P2+P3 | 1579.9 | -738.136 | 14 | success |
| 14 | T1_P2_P3 | T1+P2+P3 | 1580.8 | -738.590 | 14 | success |
| 15 | T2_T3_noP | T2+T3 | 1589.1 | -761.243 | 9 | success |
| 16 | T2_P2_P3 | T2+P2+P3 | 1591.2 | -743.803 | 14 | success |
| 17 | T1_noP | T1 | 1592.2 | -777.587 | 5 | success |
| 18 | T2_noP | T2 | 1595.5 | -779.242 | 5 | success |
| 19 | T3_noP | T3 | 1617.9 | -790.458 | 5 | success |
| 20 | noT_P2 | P2 | 1665.4 | -814.207 | 5 | success |
| 21 | noT_P2_P3 | P2+P3 | 1670.6 | -802.013 | 9 | success |
| 22 | noT_P3 | P3 | 1674.9 | -818.926 | 5 | success |
| 23 | noT_P1 | P1 | 1676.4 | -819.693 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 1575.5**.
**Eligible L1 models:** 11 (T1_P1, T1_P2, T1_P3, T2_P1, T2_P2, T2_P3, T2_T3_P1, T2_T3_P2, T2_T3_P3, T3_P2, T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_T3_P3__bd_pd1_sigR1 | 1531.1 | -721.139 | 12 | success |
| T2_T3_P3__bd_pd1_sigL1 | 1531.1 | -721.139 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 1531.1 | -721.139 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 1531.1 | -721.139 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 1531.1 | -721.139 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 1531.1 | -721.139 | 12 | success |
| T2_T3_P3__bd_pd1 | 1538.5 | -721.139 | 13 | success |
| T2_T3_P3__bd_sigR3 | 1538.5 | -721.139 | 13 | success |
| T2_T3_P3__bd_sigL1 | 1538.5 | -721.139 | 13 | success |
| T2_T3_P3__bd_sigR2 | 1538.5 | -721.139 | 13 | success |
| T2_T3_P3__bd_sigL3 | 1538.5 | -721.139 | 13 | success |
| T2_T3_P3__bd_sigL2 | 1538.5 | -721.139 | 13 | success |
| T2_T3_P3__bd_sigR1 | 1538.5 | -721.139 | 13 | success |
| T1_P3__bd_sigR1 | 1541.8 | -741.278 | 8 | success |
| T1_P3__bd_sigL1 | 1541.8 | -741.278 | 8 | success |
| T1_P3__bd_sigR2 | 1541.8 | -741.278 | 8 | success |
| T1_P3__bd_sigL2 | 1541.8 | -741.278 | 8 | success |
| T1_P3__bd_pd1_sigL1 | 1544.1 | -746.125 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 1544.1 | -746.125 | 7 | success |
| T1_P3__bd_pd1_sigR1 | 1544.1 | -746.125 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 1544.1 | -746.125 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 1544.2 | -746.176 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 1544.2 | -746.176 | 7 | success |
| T2_P1__bd_pd1_sigR1 | 1544.2 | -746.176 | 7 | success |
| T2_P1__bd_pd1_sigR2 | 1544.2 | -746.176 | 7 | success |
| T2_T3_P1__bd_pd1_sigL3 | 1545.4 | -728.295 | 12 | success |
| T2_T3_P1__bd_pd1_sigL1 | 1545.5 | -728.362 | 12 | success |
| T2_P3__bd_sigL1 | 1549.1 | -744.939 | 8 | success |
| T2_P3__bd_sigL2 | 1549.1 | -744.939 | 8 | success |
| T2_P3__bd_sigR1 | 1549.3 | -745.046 | 8 | success |
| T2_P3__bd_sigR2 | 1549.3 | -745.047 | 8 | success |
| T1_P1__bd_pd1 | 1549.4 | -745.096 | 8 | success |
| T2_T3_P1__bd_pd1_sigR1 | 1550.7 | -730.968 | 12 | success |
| T2_T3_P1__bd_pd1_sigR2 | 1550.7 | -730.968 | 12 | success |
| T2_T3_P1__bd_pd1_sigR3 | 1550.7 | -730.968 | 12 | success |
| T2_T3_P1__bd_pd1_sigL2 | 1550.7 | -730.968 | 12 | success |
| T2_P1__bd_sigR1 | 1551.1 | -745.960 | 8 | success |
| T2_P1__bd_sigR2 | 1551.1 | -745.960 | 8 | success |
| T2_P1__bd_sigL1 | 1551.1 | -745.960 | 8 | success |
| T2_P1__bd_sigL2 | 1551.1 | -745.960 | 8 | success |
| T1_P3__bd_pd1 | 1551.2 | -745.993 | 8 | success |
| T2_P1__bd_pd1 | 1551.6 | -746.176 | 8 | success |
| T2_T3_P1__bd_pd1 | 1552.6 | -728.211 | 13 | success |
| T2_T3_P1__bd_sigL2 | 1552.7 | -728.269 | 13 | success |
| T1_P2__bd_sigR2 | 1553.9 | -747.326 | 8 | success |
| T1_P2__bd_sigL1 | 1553.9 | -747.326 | 8 | success |
| T1_P2__bd_sigR1 | 1553.9 | -747.326 | 8 | success |
| T1_P2__bd_sigL2 | 1553.9 | -747.326 | 8 | success |
| T3_P2__bd_sigR2 | 1555.3 | -748.035 | 8 | success |
| T3_P2__bd_sigR1 | 1555.3 | -748.042 | 8 | success |
| T3_P2__bd_sigL2 | 1555.3 | -748.043 | 8 | success |
| T3_P2__bd_sigL1 | 1555.3 | -748.050 | 8 | success |
| T3_P3__bd_pd1 | 1555.9 | -748.341 | 8 | success |
| T2_T3_P1__bd_sigR3 | 1556.2 | -730.001 | 13 | success |
| T2_T3_P1__bd_sigR1 | 1556.2 | -730.001 | 13 | success |
| T1_P2__bd_pd1_sigL2 | 1556.8 | -752.519 | 7 | success |
| T1_P2__bd_pd1_sigR2 | 1556.8 | -752.519 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 1556.8 | -752.519 | 7 | success |
| T1_P2__bd_pd1_sigL1 | 1556.8 | -752.519 | 7 | success |
| T2_P3__bd_pd1_sigL2 | 1557.1 | -752.625 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 1557.1 | -752.625 | 7 | success |
| T2_P3__bd_pd1_sigR1 | 1557.1 | -752.625 | 7 | success |
| T2_P3__bd_pd1_sigR2 | 1557.1 | -752.625 | 7 | success |
| T2_T3_P1__bd_sigL1 | 1558.1 | -730.957 | 13 | success |
| T2_T3_P1__bd_sigR2 | 1558.1 | -730.957 | 13 | success |
| T2_T3_P1__bd_sigL3 | 1558.1 | -730.968 | 13 | success |
| T1_P1__bd_pd1_sigR1 | 1558.4 | -753.275 | 7 | success |
| T1_P1__bd_pd1_sigL1 | 1558.4 | -753.275 | 7 | success |
| T1_P1__bd_pd1_sigL2 | 1558.4 | -753.275 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 1558.4 | -753.275 | 7 | success |
| T2_P2__bd_pd1_sigR1 | 1561.2 | -754.681 | 7 | success |
| T2_P2__bd_pd1_sigL1 | 1561.2 | -754.681 | 7 | success |
| T2_P2__bd_pd1_sigR2 | 1561.2 | -754.681 | 7 | success |
| T2_P2__bd_pd1_sigL2 | 1561.2 | -754.681 | 7 | success |
| T2_T3_P2__bd_sigR3 | 1561.2 | -732.507 | 13 | success |
| T2_T3_P2__bd_sigL1 | 1561.2 | -732.509 | 13 | success |
| T2_T3_P2__bd_sigL3 | 1561.2 | -732.512 | 13 | success |
| T2_T3_P2__bd_sigL2 | 1561.3 | -732.522 | 13 | success |
| T3_P3__bd_sigR1 | 1562.1 | -751.444 | 8 | success |
| T3_P3__bd_sigL1 | 1562.1 | -751.444 | 8 | success |
| T3_P3__bd_sigL2 | 1562.1 | -751.444 | 8 | success |
| T3_P3__bd_sigR2 | 1562.1 | -751.444 | 8 | success |
| T3_P2__bd_pd1_sigR2 | 1563.2 | -755.706 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 1563.2 | -755.706 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 1563.2 | -755.706 | 7 | success |
| T3_P2__bd_pd1_sigL2 | 1563.2 | -755.706 | 7 | success |
| T1_P2__bd_pd1 | 1563.8 | -752.312 | 8 | success |
| T2_P3__bd_pd1 | 1564.5 | -752.625 | 8 | success |
| T1_P1__bd_sigR2 | 1565.7 | -753.232 | 8 | success |
| T1_P1__bd_sigR1 | 1565.7 | -753.232 | 8 | success |
| T1_P1__bd_sigL1 | 1565.7 | -753.232 | 8 | success |
| T1_P1__bd_sigL2 | 1565.7 | -753.232 | 8 | success |
| T2_P2__bd_sigR1 | 1566.9 | -753.825 | 8 | success |
| T2_P2__bd_sigR2 | 1566.9 | -753.825 | 8 | success |
| T2_P2__bd_sigL1 | 1566.9 | -753.825 | 8 | success |
| T2_P2__bd_sigL2 | 1566.9 | -753.825 | 8 | success |
| T3_P3__bd_pd1_sigR2 | 1567.1 | -757.644 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 1567.1 | -757.644 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 1567.1 | -757.644 | 7 | success |
| T3_P3__bd_pd1_sigR1 | 1567.1 | -757.644 | 7 | success |
| T2_T3_P2__bd_pd1_sigR3 | 1568.2 | -739.688 | 12 | success |
| T2_T3_P2__bd_pd1_sigL1 | 1568.2 | -739.688 | 12 | success |
| T2_T3_P2__bd_pd1_sigL3 | 1568.2 | -739.688 | 12 | success |
| T2_T3_P2__bd_pd1_sigL2 | 1568.2 | -739.688 | 12 | success |
| T2_T3_P2__bd_pd1_sigR1 | 1568.2 | -739.688 | 12 | success |
| T2_T3_P2__bd_pd1_sigR2 | 1568.2 | -739.688 | 12 | success |
| T2_P2__bd_pd1 | 1568.6 | -754.681 | 8 | success |
| T3_P1__bd_pd1 | 1569.0 | -754.914 | 8 | success |
| T3_P2__bd_pd1 | 1570.6 | -755.706 | 8 | success |
| T2_T3_P2__bd_sigR2 | 1572.0 | -737.888 | 13 | success |
| T2_T3_P2__bd_sigR1 | 1572.0 | -737.888 | 13 | success |
| T2_T3_P2__bd_pd1 | 1575.6 | -739.688 | 13 | success |
| T2_T3_noP__bd_pd1 | 1581.7 | -761.243 | 8 | success |
| T2_noP__bd_pd1 | 1588.1 | -779.242 | 4 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_pd1_sigR1 | 1531.1 | no | ✓ | ✗ | Inf | 32 |
| 2 | T2_T3_P3__bd_pd1_sigL1 | 1531.1 | no | ✓ | ✗ | Inf | 18 |
| 3 | T2_T3_P3__bd_pd1_sigR3 | 1531.1 | no | ✓ | ✗ | Inf | 25 |
| 4 | T2_T3_P3__bd_pd1_sigL2 | 1531.1 | no | ✓ | ✗ | 2.18e+07 | 26 |
| 5 | T2_T3_P3__bd_pd1_sigR2 | 1531.1 | no | ✓ | ✗ | 1.23e+06 | 21 |
| 6 | T2_T3_P3__bd_pd1_sigL3 | 1531.1 | no | ✓ | ✗ | 1.51e+06 | 16 |
| 7 | T2_T3_P3__bd_pd1 | 1538.5 | no | ✓ | ✗ | 3.10e+18 | 47 |
| 8 | T2_T3_P3__bd_sigR3 | 1538.5 | no | ✓ | ✗ | Inf | 14 |
| 9 | T2_T3_P3__bd_sigL1 | 1538.5 | no | ✓ | ✗ | Inf | 16 |
| 10 | T2_T3_P3__bd_sigR2 | 1538.5 | no | ✓ | ✗ | 5.77e+13 | 22 |
| 11 | T2_T3_P3__bd_sigL3 | 1538.5 | no | ✓ | ✗ | 2.10e+19 | 22 |
| 12 | T2_T3_P3__bd_sigL2 | 1538.5 | no | ✓ | ✗ | Inf | 21 |
| 13 | T2_T3_P3__bd_sigR1 | 1538.5 | no | ✓ | ✗ | Inf | 21 |
| 14 | T1_P3__bd_sigR1 | 1541.8 | no | ✓ | ✗ | Inf | 22 |
| 15 | T1_P3__bd_sigL1 | 1541.8 | no | ✓ | ✗ | Inf | 25 |
| 16 | T1_P3__bd_sigR2 | 1541.8 | no | ✓ | ✗ | Inf | 25 |
| 17 | T1_P3__bd_sigL2 | 1541.8 | no | ✓ | ✗ | Inf | 17 |
| 18 | T1_P3__bd_pd1_sigL1 | 1544.1 | yes ✓ | ✓ | ✓ | 6.48e+04 | 14 |
| 19 | T1_P3__bd_pd1_sigL2 | 1544.1 | yes ✓ | ✓ | ✓ | 6.48e+04 | 18 |
| 20 | T1_P3__bd_pd1_sigR1 | 1544.1 | yes ✓ | ✓ | ✓ | 6.49e+04 | 18 |
| 21 | T1_P3__bd_pd1_sigR2 | 1544.1 | yes ✓ | ✓ | ✓ | 6.47e+04 | 19 |
| 22 | T2_P1__bd_pd1_sigL2 | 1544.2 | no | ✓ | ✗ | Inf | 9 |
| 23 | T2_P1__bd_pd1_sigL1 | 1544.2 | no | ✓ | ✗ | Inf | 11 |
| 24 | T2_P1__bd_pd1_sigR1 | 1544.2 | yes ✓ | ✓ | ✓ | 8.07e+05 | 14 |
| 25 | T2_P1__bd_pd1_sigR2 | 1544.2 | no | ✓ | ✗ | Inf | 8 |
| 26 | T2_T3_P1__bd_pd1_sigL3 | 1545.4 | no | ✗ | ✗ | Inf | 1 |
| 27 | T2_T3_P1__bd_pd1_sigL1 | 1545.5 | no | ✗ | ✗ | Inf | 1 |
| 28 | T2_T3_P3 | 1545.9 | no | ✓ | ✗ | Inf | 38 |
| 29 | T1_P3 | 1548.1 | no | ✓ | ✗ | Inf | 8 |
| 30 | T2_P3__bd_sigL1 | 1549.1 | no | ✗ | ✗ | Inf | 1 |
| 31 | T2_P3__bd_sigL2 | 1549.1 | no | ✗ | ✗ | Inf | 1 |
| 32 | T2_P3__bd_sigR1 | 1549.3 | no | ✗ | ✗ | Inf | 1 |
| 33 | T2_P3__bd_sigR2 | 1549.3 | no | ✗ | ✗ | Inf | 1 |
| 34 | T1_P1__bd_pd1 | 1549.4 | no | ✓ | ✗ | 2.70e+06 | 44 |
| 35 | T2_T3_P1__bd_pd1_sigR1 | 1550.7 | no | ✓ | ✗ | 8.47e+06 | 9 |
| 36 | T2_T3_P1__bd_pd1_sigR2 | 1550.7 | no | ✗ | ✗ | 5.34e+06 | 1 |
| 37 | T2_T3_P1__bd_pd1_sigR3 | 1550.7 | no | ✗ | ✗ | Inf | 2 |
| 38 | T2_T3_P1__bd_pd1_sigL2 | 1550.7 | no | ✗ | ✗ | Inf | 1 |
| 39 | T2_P1__bd_sigR1 | 1551.1 | no | ✓ | ✗ | 2.79e+06 | 9 |
| 40 | T2_P1__bd_sigR2 | 1551.1 | no | ✓ | ✗ | Inf | 4 |
| 41 | T2_P1__bd_sigL1 | 1551.1 | no | ✓ | ✗ | Inf | 8 |
| 42 | T2_P1__bd_sigL2 | 1551.1 | no | ✓ | ✗ | 2.72e+06 | 5 |
| 43 | T1_P3__bd_pd1 | 1551.2 | yes ✓ | ✓ | ✓ | 5.24e+04 | 26 |
| 44 | T2_P1__bd_pd1 | 1551.6 | no | ✓ | ✗ | Inf | 41 |
| 45 | T2_T3_P1__bd_pd1 | 1552.6 | no | ✗ | ✗ | Inf | 1 |
| 46 | T2_T3_P1__bd_sigL2 | 1552.7 | no | ✗ | ✗ | Inf | 1 |
| 47 | T1_P2__bd_sigR2 | 1553.9 | no | ✓ | ✗ | Inf | 18 |
| 48 | T1_P2__bd_sigL1 | 1553.9 | no | ✓ | ✗ | Inf | 15 |
| 49 | T1_P2__bd_sigR1 | 1553.9 | no | ✓ | ✗ | Inf | 10 |
| 50 | T1_P2__bd_sigL2 | 1553.9 | no | ✓ | ✗ | Inf | 12 |
| 51 | T3_P2__bd_sigR2 | 1555.3 | no | ✗ | ✗ | Inf | 1 |
| 52 | T3_P2__bd_sigR1 | 1555.3 | no | ✗ | ✗ | Inf | 1 |
| 53 | T3_P2__bd_sigL2 | 1555.3 | no | ✗ | ✗ | Inf | 1 |
| 54 | T3_P2__bd_sigL1 | 1555.3 | no | ✗ | ✗ | Inf | 1 |
| 55 | T3_P3__bd_pd1 | 1555.9 | yes ✓ | ✓ | ✓ | 9.32e+03 | 50 |
| 56 | T2_T3_P1__bd_sigR3 | 1556.2 | no | ✗ | ✗ | Inf | 1 |
| 57 | T2_T3_P1__bd_sigR1 | 1556.2 | no | ✗ | ✗ | Inf | 1 |
| 58 | T1_P1 | 1556.3 | no | ✓ | ✗ | Inf | 33 |
| 59 | T2_P3 | 1556.4 | no | ✓ | ✗ | Inf | 4 |
| 60 | T1_P2__bd_pd1_sigL2 | 1556.8 | yes ✓ | ✓ | ✓ | 8.45e+04 | 16 |
| 61 | T1_P2__bd_pd1_sigR2 | 1556.8 | yes ✓ | ✓ | ✓ | 8.54e+04 | 18 |
| 62 | T1_P2__bd_pd1_sigR1 | 1556.8 | yes ✓ | ✓ | ✓ | 8.47e+04 | 21 |
| 63 | T1_P2__bd_pd1_sigL1 | 1556.8 | yes ✓ | ✓ | ✓ | 8.53e+04 | 19 |
| 64 | T2_P3__bd_pd1_sigL2 | 1557.1 | yes ✓ | ✓ | ✓ | 4.89e+04 | 17 |
| 65 | T2_P3__bd_pd1_sigL1 | 1557.1 | yes ✓ | ✓ | ✓ | 4.94e+04 | 11 |
| 66 | T2_P3__bd_pd1_sigR1 | 1557.1 | yes ✓ | ✓ | ✓ | 1.29e+05 | 16 |
| 67 | T2_P3__bd_pd1_sigR2 | 1557.1 | yes ✓ | ✓ | ✓ | 5.64e+04 | 17 |
| 68 | T2_T3_P1__bd_sigL1 | 1558.1 | no | ✓ | ✗ | Inf | 3 |
| 69 | T2_T3_P1__bd_sigR2 | 1558.1 | no | ✗ | ✗ | Inf | 1 |
| 70 | T2_T3_P1__bd_sigL3 | 1558.1 | no | ✗ | ✗ | Inf | 2 |
| 71 | T1_P1__bd_pd1_sigR1 | 1558.4 | yes ✓ | ✓ | ✓ | 4.34e+05 | 13 |
| 72 | T1_P1__bd_pd1_sigL1 | 1558.4 | no | ✓ | ✗ | Inf | 12 |
| 73 | T1_P1__bd_pd1_sigL2 | 1558.4 | yes ✓ | ✓ | ✓ | 4.39e+05 | 12 |
| 74 | T1_P1__bd_pd1_sigR2 | 1558.4 | no | ✓ | ✗ | Inf | 6 |
| 75 | T2_P1 | 1558.5 | no | ✓ | ✗ | Inf | 28 |
| 76 | T2_T3_P1 | 1560.0 | no | ✗ | ✗ | Inf | 1 |
| 77 | T2_P2__bd_pd1_sigR1 | 1561.2 | yes ✓ | ✓ | ✓ | 6.51e+04 | 10 |
| 78 | T2_P2__bd_pd1_sigL1 | 1561.2 | no | ✓ | ✗ | Inf | 8 |
| 79 | T2_P2__bd_pd1_sigR2 | 1561.2 | yes ✓ | ✓ | ✓ | 6.33e+04 | 7 |
| 80 | T2_P2__bd_pd1_sigL2 | 1561.2 | yes ✓ | ✓ | ✓ | 6.34e+04 | 11 |
| 81 | T2_T3_P2__bd_sigR3 | 1561.2 | no | ✗ | ✗ | Inf | 1 |
| 82 | T2_T3_P2__bd_sigL1 | 1561.2 | no | ✗ | ✗ | Inf | 1 |
| 83 | T2_T3_P2__bd_sigL3 | 1561.2 | no | ✗ | ✗ | Inf | 1 |
| 84 | T2_T3_P2__bd_sigL2 | 1561.3 | no | ✗ | ✗ | Inf | 1 |
| 85 | T1_P2 | 1561.3 | no | ✓ | ✗ | Inf | 37 |
| 86 | T3_P3 | 1562.0 | yes ✓ | ✓ | ✓ | 1.76e+04 | 39 |
| 87 | T3_P3__bd_sigR1 | 1562.1 | no | ✓ | ✗ | Inf | 21 |
| 88 | T3_P3__bd_sigL1 | 1562.1 | no | ✓ | ✗ | Inf | 19 |
| 89 | T3_P3__bd_sigL2 | 1562.1 | no | ✓ | ✗ | Inf | 23 |
| 90 | T3_P3__bd_sigR2 | 1562.1 | no | ✓ | ✗ | Inf | 24 |
| 91 | T3_P2 | 1562.7 | no | ✗ | ✗ | Inf | 1 |
| 92 | T3_P2__bd_pd1_sigR2 | 1563.2 | yes ✓ | ✓ | ✓ | 1.41e+05 | 21 |
| 93 | T3_P2__bd_pd1_sigL1 | 1563.2 | yes ✓ | ✓ | ✓ | 1.41e+05 | 21 |
| 94 | T3_P2__bd_pd1_sigR1 | 1563.2 | yes ✓ | ✓ | ✓ | 1.40e+05 | 17 |
| 95 | T3_P2__bd_pd1_sigL2 | 1563.2 | yes ✓ | ✓ | ✓ | 1.40e+05 | 20 |
| 96 | T1_P2__bd_pd1 | 1563.8 | yes ✓ | ✓ | ✓ | 1.23e+05 | 43 |
| 97 | T2_P3__bd_pd1 | 1564.5 | no | ✓ | ✗ | 6.16e+18 | 34 |
| 98 | T1_P1__bd_sigR2 | 1565.7 | no | ✓ | ✗ | Inf | 6 |
| 99 | T1_P1__bd_sigR1 | 1565.7 | yes ✓ | ✓ | ✓ | 6.37e+05 | 12 |
| 100 | T1_P1__bd_sigL1 | 1565.7 | yes ✓ | ✓ | ✓ | 6.21e+05 | 9 |
| 101 | T1_P1__bd_sigL2 | 1565.7 | no | ✓ | ✗ | Inf | 5 |
| 102 | T2_P2__bd_sigR1 | 1566.9 | no | ✓ | ✗ | Inf | 7 |
| 103 | T2_P2__bd_sigR2 | 1566.9 | no | ✓ | ✗ | Inf | 14 |
| 104 | T2_P2__bd_sigL1 | 1566.9 | no | ✓ | ✗ | Inf | 12 |
| 105 | T2_P2__bd_sigL2 | 1566.9 | no | ✓ | ✗ | Inf | 8 |
| 106 | T3_P3__bd_pd1_sigR2 | 1567.1 | yes ✓ | ✓ | ✓ | 6.01e+03 | 29 |
| 107 | T3_P3__bd_pd1_sigL1 | 1567.1 | yes ✓ | ✓ | ✓ | 6.58e+03 | 26 |
| 108 | T3_P3__bd_pd1_sigL2 | 1567.1 | yes ✓ | ✓ | ✓ | 6.06e+03 | 25 |
| 109 | T3_P3__bd_pd1_sigR1 | 1567.1 | yes ✓ | ✓ | ✓ | 6.17e+03 | 27 |
| 110 | T2_T3_P2__bd_pd1_sigR3 | 1568.2 | no | ✗ | ✓ | 8.84e+04 | 1 |
| 111 | T2_T3_P2__bd_pd1_sigL1 | 1568.2 | no | ✗ | ✗ | Inf | 2 |
| 112 | T2_T3_P2__bd_pd1_sigL3 | 1568.2 | no | ✓ | ✗ | Inf | 5 |
| 113 | T2_T3_P2__bd_pd1_sigL2 | 1568.2 | yes ✓ | ✓ | ✓ | 1.19e+05 | 3 |
| 114 | T2_T3_P2__bd_pd1_sigR1 | 1568.2 | no | ✗ | ✗ | Inf | 2 |
| 115 | T2_T3_P2__bd_pd1_sigR2 | 1568.2 | no | ✗ | ✗ | 1.75e+06 | 1 |
| 116 | T2_P2__bd_pd1 | 1568.6 | no | ✓ | ✗ | Inf | 47 |
| 117 | T2_T3_P2 | 1568.6 | no | ✗ | ✗ | Inf | 1 |
| 118 | T3_P1__bd_pd1 | 1569.0 | yes ✓ | ✓ | ✓ | 8.43e+05 | 47 |
| 119 | T3_P2__bd_pd1 | 1570.6 | no | ✓ | ✗ | Inf | 48 |
| 120 | T2_T3_P2__bd_sigR2 | 1572.0 | no | ✓ | ✗ | Inf | 3 |
| 121 | T2_T3_P2__bd_sigR1 | 1572.0 | no | ✓ | ✗ | Inf | 7 |
| 122 | T2_P2 | 1574.3 | no | ✓ | ✗ | Inf | 11 |
| 123 | T2_T3_P2__bd_pd1 | 1575.6 | no | ✓ | ✗ | Inf | 11 |
| 124 | T3_P1 | 1576.4 | yes ✓ | ✓ | ✓ | 8.76e+05 | 41 |
| 125 | T3_P2_P3 | 1579.9 | no | ✓ | ✗ | Inf | 8 |
| 126 | T1_P2_P3 | 1580.8 | no | ✗ | ✗ | Inf | 1 |
| 127 | T2_T3_noP__bd_pd1 | 1581.7 | no | ✓ | ✗ | Inf | 18 |
| 128 | T2_noP__bd_pd1 | 1588.1 | no | ✓ | ✗ | Inf | 50 |
| 129 | T2_T3_noP | 1589.1 | no | ✓ | ✗ | 3.66e+19 | 10 |
| 130 | T2_P2_P3 | 1591.2 | no | ✗ | ✗ | Inf | 1 |
| 131 | T1_noP | 1592.2 | yes ✓ | ✓ | ✓ | 2.11e+03 | 42 |
| 132 | T2_noP | 1595.5 | no | ✓ | ✗ | Inf | 48 |
| 133 | T3_noP | 1617.9 | yes ✓ | ✓ | ✓ | 4.18e+03 | 49 |
| 134 | noT_P2 | 1665.4 | no | ✗ | ✗ | 1.77e+19 | 1 |
| 135 | noT_P2_P3 | 1670.6 | no | ✗ | ✗ | Inf | 1 |
| 136 | noT_P3 | 1674.9 | (not scanned) | — | — | — | — |
| 137 | noT_P1 | 1676.4 | no | ✗ | ✗ | Inf | 1 |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T1_P3__bd_pd1_sigL1` — **Ω = 1544.1**

## L3 supplementary appendices — per-model diagnostics

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4148 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4101 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000127 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4116 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000109 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4142 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000223 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4141 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000233 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4117 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000123 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4115 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000087 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4108 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000192 |
| 9 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4136 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000135 |
| 10 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 7.4109 | 0.2709 |   Inf | 1.9376 | 101.4120 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.00000084 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.829e+03 | 1.853e+03 |
| 2 | 1.645e+03 | 1.647e+03 |
| 3 | 6.613e+02 | 6.616e+02 |
| 4 | 4.533e+02 | 4.545e+02 |
| 5 | 7.320e+01 | 7.321e+01 |
| 6 | 2.693e+01 | 2.696e+01 |
| 7 | 8.951e+00 | 1.467e+01 |
| 8 | 4.759e+00 | 8.275e+00 |
| 9 | 7.537e-01 | 9.136e-01 |
| 10 | 5.229e-01 | 7.073e-01 |
| 11 | 2.138e-03 | 1.881e-01 |
| 12 | -4.300e+00 | 1.314e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1410972.3833, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4119 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4155 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000157 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4128 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000064 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4086 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000124 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4118 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000117 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4184 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000251 |
| 7 | -721.139 | 17.0745 | 8.2422 | 9.5970 |   Inf | 7.4182 | 1661.2581 | 1.6318 | 1.9375 | 0.2703 | -0.1151 | 1.0000 | -0.2294 | 0.9308 | -0.2844 | -0.1051 | -0.3142 | -0.9435 | -0.9676 | -0.1866 | 0.1699 | 0.01682227 |
| 8 | -721.139 | 17.0745 | 8.2423 | 9.5970 |   Inf | 7.4182 | 3124.6137 | 1.6318 | 1.9375 | 0.2703 | -0.1151 | 1.0000 | -0.2294 | 0.9308 | -0.2844 | -0.1051 | -0.3142 | -0.9435 | -0.9676 | -0.1866 | 0.1699 | 0.01701270 |
| 9 | -721.139 | 17.0745 | 8.2423 | 9.5970 |   Inf | 7.4182 | 254981.2458 | 1.6318 | 1.9375 | 0.2703 | -0.1151 | 1.0000 | -0.2294 | 0.9308 | -0.2844 | -0.1051 | -0.3142 | -0.9435 | -0.9676 | -0.1866 | 0.1699 | 0.01720049 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 |   Inf | 7.4182 | 207210271623690747904.0000 | 1.6318 | 1.9375 | 0.2703 | -0.1151 | 1.0000 | -0.2294 | 0.9308 | -0.2844 | -0.1051 | -0.3142 | -0.9435 | -0.9676 | -0.1866 | 0.1699 | 0.01720267 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.220e+03 | 5.209e+03 |
| 2 | 2.001e+03 | 2.027e+03 |
| 3 | 6.741e+02 | 6.745e+02 |
| 4 | 1.661e+02 | 1.680e+02 |
| 5 | 6.941e+01 | 6.863e+01 |
| 6 | 3.487e+01 | 2.738e+01 |
| 7 | 2.652e+01 | 2.572e+01 |
| 8 | 8.470e+00 | 8.130e+00 |
| 9 | 7.454e-01 | 9.109e-01 |
| 10 | 5.956e-01 | 7.047e-01 |
| 11 | 2.154e-03 | 1.862e-01 |
| 12 | -1.410e+00 | 1.820e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 2861407.3291, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4109 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4112 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000186 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4120 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000367 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4151 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000197 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4146 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000400 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4110 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000204 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4155 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000273 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4164 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000115 |
| 9 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4171 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000360 |
| 10 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 7.4109 | 0.2709 | 1.6278 | 1.9376 | 101.4175 |   Inf | -0.1194 | 1.0000 | -0.1051 | -0.3145 | -0.9434 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | 0.00000274 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.658e+03 | 4.652e+03 |
| 2 | 2.041e+03 | 2.056e+03 |
| 3 | 6.666e+02 | 6.676e+02 |
| 4 | 1.837e+02 | 1.863e+02 |
| 5 | 6.909e+01 | 6.933e+01 |
| 6 | 2.662e+01 | 2.740e+01 |
| 7 | 1.092e+01 | 2.072e+01 |
| 8 | 2.737e+00 | 8.008e+00 |
| 9 | 7.283e-01 | 9.127e-01 |
| 10 | 4.984e-01 | 7.128e-01 |
| 11 | 2.030e-03 | 1.857e-01 |
| 12 | -2.593e+01 | 1.551e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 2998748.0470, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4131 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4118 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000147 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4145 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000478 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4114 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000171 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4105 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000427 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4108 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000465 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4158 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00001033 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4093 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000252 |
| 9 | -721.139 | 17.0745 | 8.2422 | 9.5970 | 0.2703 |   Inf | 1.9375 | 2141.2811 | 1.6318 | 7.4182 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.2294 | 0.9308 | -0.2844 | 0.1051 | 0.3142 | 0.9435 | 0.01688353 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 |   Inf | 1.9375 | 2843.1536 | 1.6318 | 7.4182 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.2294 | 0.9308 | -0.2844 | 0.1051 | 0.3142 | 0.9435 | 0.01699292 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.423e+04 | 4.428e+04 |
| 2 | 4.585e+03 | 4.590e+03 |
| 3 | 1.032e+03 | 1.032e+03 |
| 4 | 6.877e+02 | 6.877e+02 |
| 5 | 1.003e+02 | 1.004e+02 |
| 6 | 6.085e+01 | 6.065e+01 |
| 7 | 2.665e+01 | 2.628e+01 |
| 8 | 8.561e+00 | 8.901e+00 |
| 9 | 1.293e+00 | 9.504e-01 |
| 10 | 7.101e-01 | 7.084e-01 |
| 11 | 2.443e-01 | 1.930e-01 |
| 12 | 2.025e-03 | 1.750e-03 |

numDeriv::hessian (operative): cond = 21838655.2775, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 25302811.9059, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.4156 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.4124 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00000365 |
| 3 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.6318 | 7.4182 | 26805.0663 |   Inf | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01718076 |
| 4 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 589708254.8882 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01720171 |
| 5 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 4136771.1931 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01720128 |
| 6 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 826693.0982 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01720117 |
| 7 | -721.139 | 17.0745 | 8.2422 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 471162.5769 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01719056 |
| 8 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 263083.7444 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01720266 |
| 9 | -721.139 | 17.0745 | 8.2422 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 228694.4316 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01719732 |
| 10 | -721.139 | 17.0745 | 8.2422 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 228592.6058 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01720189 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0002, max_pdist=0.0172 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.437e+03 | 2.439e+03 |
| 2 | 1.836e+03 | 1.840e+03 |
| 3 | 6.722e+02 | 6.727e+02 |
| 4 | 1.640e+02 | 1.680e+02 |
| 5 | 8.788e+01 | 8.820e+01 |
| 6 | 5.266e+01 | 5.247e+01 |
| 7 | 2.627e+01 | 2.574e+01 |
| 8 | 7.822e+00 | 8.271e+00 |
| 9 | 1.364e+00 | 9.197e-01 |
| 10 | 7.042e-01 | 7.063e-01 |
| 11 | 2.841e-01 | 1.863e-01 |
| 12 | 1.976e-03 | 2.238e-03 |

numDeriv::hessian (operative): cond = 1233609.3113, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1089923.1672, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4133 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4190 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000131 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4138 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000125 |
| 4 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 |   Inf | 15719.1687 | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01716542 |
| 5 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 |   Inf | 26781.0471 | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01718012 |
| 6 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 | 4670736694466752.0000 |   Inf | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01720070 |
| 7 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 |   Inf | 21244977464635098521277562880.0000 | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01720153 |
| 8 | -721.139 | 17.0746 | 8.2423 | 9.5970 | 0.2703 | 7.4182 | 1267995.0956 |   Inf | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01722996 |
| 9 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 | 400615.8820 |   Inf | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01720211 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 | 400152.7245 |   Inf | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01720109 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.974e+03 | 2.995e+03 |
| 2 | 1.392e+03 | 1.386e+03 |
| 3 | 6.745e+02 | 6.747e+02 |
| 4 | 1.406e+02 | 1.443e+02 |
| 5 | 8.606e+01 | 8.621e+01 |
| 6 | 4.990e+01 | 4.940e+01 |
| 7 | 2.614e+01 | 2.581e+01 |
| 8 | 8.193e+00 | 8.110e+00 |
| 9 | 1.598e+00 | 9.044e-01 |
| 10 | 7.034e-01 | 7.090e-01 |
| 11 | 4.081e-01 | 1.873e-01 |
| 12 | 1.971e-03 | 1.163e-03 |

numDeriv::hessian (operative): cond = 1508941.2254, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 2574759.3009, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 26917452610801426432.0000 | 1.9376 | 101.4169 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 8874718555.6065 | 1.9376 | 101.4151 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000151 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 65834365632133327254322938509477495969939456.0000 | 1.9376 | 101.4091 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000235 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 12271179806591799296.0000 | 1.9376 | 101.4087 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000239 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7345437279879271664439831560192.0000 | 1.9376 | 101.4170 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000367 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 317584976925293.2500 | 1.9376 | 101.4241 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000352 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 4909652.6359 | 1.9376 | 101.4093 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000251 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1667163.3243 | 1.9376 | 101.4076 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000439 |
| 9 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1585645.4630 | 1.9376 | 101.4067 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000567 |
| 10 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1469261.2208 | 1.9376 | 101.4107 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000209 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.423e+04 | 4.428e+04 |
| 2 | 4.585e+03 | 4.590e+03 |
| 3 | 1.032e+03 | 1.032e+03 |
| 4 | 6.877e+02 | 6.877e+02 |
| 5 | 1.003e+02 | 1.004e+02 |
| 6 | 6.085e+01 | 6.075e+01 |
| 7 | 2.665e+01 | 2.660e+01 |
| 8 | 8.561e+00 | 8.907e+00 |
| 9 | 1.293e+00 | 9.563e-01 |
| 10 | 7.101e-01 | 7.098e-01 |
| 11 | 2.443e-01 | 1.938e-01 |
| 12 | 2.025e-03 | 9.741e-04 |
| 13 | 1.428e-14 | 3.303e-14 |

numDeriv::hessian (operative): cond = 3097722674133337600.0000, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1340466773606698496.0000, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.4143 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.4130 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00000163 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.3599 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00003972 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.4552 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00006968 |
| 5 | -721.139 | 17.0636 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6279 | 101.6009 | 7.4110 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00006271 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.4046 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00003375 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.5717 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00003304 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.3899 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00004363 |
| 9 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.9376 | 1.6278 | 101.3769 | 7.4109 |   Inf | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.2302 | -0.9306 | 0.2846 | 0.00001113 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.9375 | 1.6318 |   Inf | 7.4182 | 1984792.5839 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.2294 | -0.9308 | 0.2844 | 0.01720320 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.470e+03 | 3.475e+03 |
| 2 | 9.231e+02 | 9.233e+02 |
| 3 | 6.204e+02 | 6.207e+02 |
| 4 | 1.152e+02 | 1.143e+02 |
| 5 | 7.852e+01 | 7.863e+01 |
| 6 | 4.115e+01 | 4.222e+01 |
| 7 | 2.546e+01 | 2.537e+01 |
| 8 | 7.662e+00 | 7.887e+00 |
| 9 | 1.331e+00 | 9.035e-01 |
| 10 | 7.145e-01 | 7.097e-01 |
| 11 | 3.821e-01 | 1.803e-01 |
| 12 | 2.044e-03 | 2.857e-03 |
| 13 | -2.345e-12 | -4.026e-11 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4151 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4175 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000191 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4142 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000087 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.5025 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00002643 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.2456 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00002919 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4631 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00001233 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4394 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00001050 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4046 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00004793 |
| 9 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.3942 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000607 |
| 10 | -721.139 | 17.0635 | 8.2420 | 9.5981 |   Inf | 7.4109 | 101.4128 | 1.6278 | 1.9376 | 0.2709 | -0.1194 | 1.0000 | -0.2302 | 0.9306 | -0.2846 | -0.1051 | -0.3145 | -0.9434 | -0.9674 | -0.1873 | 0.1702 | 0.00000256 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.110e+03 | 5.089e+03 |
| 2 | 1.556e+03 | 1.571e+03 |
| 3 | 6.666e+02 | 6.670e+02 |
| 4 | 1.573e+02 | 1.599e+02 |
| 5 | 6.675e+01 | 6.714e+01 |
| 6 | 2.664e+01 | 2.630e+01 |
| 7 | 2.001e+01 | 2.073e+01 |
| 8 | 8.061e+00 | 7.784e+00 |
| 9 | 9.770e-01 | 8.978e-01 |
| 10 | 7.129e-01 | 7.091e-01 |
| 11 | 2.399e-03 | 1.841e-01 |
| 12 | -2.363e-11 | 1.158e-03 |
| 13 | -2.281e-02 | -7.760e-07 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.4164 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.4259 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00000242 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.4188 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00000299 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.3053 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00005086 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.3493 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00001951 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.3800 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00002185 |
| 7 | -721.139 | 17.0635 | 8.2419 | 9.5981 | 0.2709 | 1.6278 | 7.4109 | 101.3226 |   Inf | 1.9376 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00007525 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5980 | 0.2709 | 1.6278 | 7.4110 | 101.6006 |   Inf | 1.9375 | -0.1194 | 1.0000 | 0.9675 | 0.1873 | -0.1702 | 0.2302 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00013609 |
| 9 | -721.139 | 17.0630 | 8.2420 | 9.5982 | 0.2709 | 1.6277 | 7.4106 | 99.0965 |   Inf | 1.9376 | -0.1196 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | 0.2303 | -0.9306 | 0.2846 | -0.1051 | -0.3145 | -0.9434 | 0.00071138 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 1.6318 | 7.4182 |   Inf | 3821000913814342336512.0000 | 1.9375 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | 0.2294 | -0.9308 | 0.2844 | -0.1051 | -0.3142 | -0.9435 | 0.01720300 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.201e+03 | 2.201e+03 |
| 2 | 1.814e+03 | 1.818e+03 |
| 3 | 6.696e+02 | 6.698e+02 |
| 4 | 1.567e+02 | 1.574e+02 |
| 5 | 8.564e+01 | 8.624e+01 |
| 6 | 4.979e+01 | 5.092e+01 |
| 7 | 2.621e+01 | 2.614e+01 |
| 8 | 7.960e+00 | 8.189e+00 |
| 9 | 1.302e+00 | 9.107e-01 |
| 10 | 7.028e-01 | 7.077e-01 |
| 11 | 2.558e-01 | 1.846e-01 |
| 12 | 2.013e-03 | 2.206e-03 |
| 13 | 3.812e-11 | -1.008e-05 |

numDeriv::hessian (operative): cond = 57731638091469.8047, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4221 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4613 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00001135 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4059 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000519 |
| 4 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.3771 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00002563 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4363 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00001987 |
| 6 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4174 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000702 |
| 7 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.4056 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000413 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 | 7.4109 |   Inf | 101.3971 | 1.9376 | 1.6278 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.1051 | -0.3145 | -0.9434 | -0.2302 | 0.9306 | -0.2846 | 0.00000815 |
| 9 | -721.139 | 17.0745 | 8.2422 | 9.5970 | 0.2703 | 7.4182 | 693362685.2211 |   Inf | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01720092 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 | 7.4182 |   Inf | 36598402667406543928590073856.0000 | 1.9375 | 1.6318 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.1051 | -0.3142 | -0.9435 | -0.2294 | 0.9308 | -0.2844 | 0.01719971 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.572e+03 | 2.581e+03 |
| 2 | 1.081e+03 | 1.084e+03 |
| 3 | 6.571e+02 | 6.579e+02 |
| 4 | 1.138e+02 | 1.205e+02 |
| 5 | 7.720e+01 | 7.753e+01 |
| 6 | 3.957e+01 | 4.009e+01 |
| 7 | 2.540e+01 | 2.550e+01 |
| 8 | 7.436e+00 | 7.663e+00 |
| 9 | 1.199e+00 | 8.811e-01 |
| 10 | 6.960e-01 | 7.086e-01 |
| 11 | 3.224e-01 | 1.794e-01 |
| 12 | 1.973e-03 | 1.265e-03 |
| 13 | 1.226e-16 | -2.783e-16 |

numDeriv::hessian (operative): cond = 20986606421467602944.0000, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4442 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4093 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00001232 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.4149 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00001024 |
| 4 | -721.139 | 17.0635 | 8.2419 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.2362 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00009780 |
| 5 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.3979 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00001329 |
| 6 | -721.139 | 17.0634 | 8.2419 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.1820 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00014852 |
| 7 | -721.139 | 17.0634 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.0325 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00013167 |
| 8 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.3672 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00003454 |
| 9 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 0.2709 |   Inf | 1.9376 | 101.3130 | 1.6278 | 7.4109 | -0.1194 | 1.0000 | 0.9674 | 0.1873 | -0.1702 | -0.2302 | 0.9306 | -0.2846 | 0.1051 | 0.3145 | 0.9434 | 0.00010770 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 0.2703 |   Inf | 1.9375 | 2234.0711 | 1.6318 | 7.4182 | -0.1151 | 1.0000 | 0.9676 | 0.1866 | -0.1699 | -0.2294 | 0.9308 | -0.2844 | 0.1051 | 0.3142 | 0.9435 | 0.01692055 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.916e+04 | 1.924e+04 |
| 2 | 6.888e+02 | 6.891e+02 |
| 3 | 4.786e+02 | 4.790e+02 |
| 4 | 7.641e+01 | 7.634e+01 |
| 5 | 2.922e+01 | 2.916e+01 |
| 6 | 1.988e+01 | 1.985e+01 |
| 7 | 1.201e+01 | 6.722e+00 |
| 8 | 1.776e+00 | 4.404e+00 |
| 9 | 7.189e-01 | 7.346e-01 |
| 10 | 5.412e-01 | 6.733e-01 |
| 11 | 1.874e-03 | 1.168e-01 |
| 12 | 2.887e-09 | 2.443e-03 |
| 13 | -2.430e+01 | 1.759e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1093875306.0793, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -721.139 | 17.0636 | 8.2420 | 9.5981 | 1.6279 | 0.2709 | 1.9376 |   Inf | 101.7835 | 7.4110 | -0.1193 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | 0.9675 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.00000000 |
| 2 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 0.2709 | 1.9376 |   Inf | 101.4031 | 7.4109 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.00010201 |
| 3 | -721.139 | 17.0635 | 8.2420 | 9.5981 | 1.6278 | 0.2709 | 1.9376 |   Inf | 101.4094 | 7.4109 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.00010027 |
| 4 | -721.139 | 17.0635 | 8.2419 | 9.5982 | 1.6279 | 0.2709 | 1.9376 |   Inf | 101.5800 | 7.4109 | -0.1194 | 1.0000 | 0.2302 | -0.9306 | 0.2846 | 0.9674 | 0.1873 | -0.1702 | 0.1051 | 0.3145 | 0.9434 | 0.00020225 |
| 5 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 1.6318 | 0.2703 | 1.9375 | 5571602551369783974412030086031112161766741454618624.0000 |   Inf | 7.4182 | -0.1151 | 1.0000 | 0.2294 | -0.9308 | 0.2844 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.01710994 |
| 6 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 1.6318 | 0.2703 | 1.9375 | 8942362304.8632 |   Inf | 7.4182 | -0.1151 | 1.0000 | 0.2294 | -0.9308 | 0.2844 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.01710555 |
| 7 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 1.6318 | 0.2703 | 1.9375 | 390447.5108 |   Inf | 7.4182 | -0.1151 | 1.0000 | 0.2294 | -0.9308 | 0.2844 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.01710659 |
| 8 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 1.6318 | 0.2703 | 1.9375 | 1391013490297010525610703779846048492463010207287383433206188686331615379456.0000 |   Inf | 7.4182 | -0.1151 | 1.0000 | 0.2294 | -0.9308 | 0.2844 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.01711676 |
| 9 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 1.6318 | 0.2703 | 1.9375 | 934327333572177345658071943088501492243888307563406898801715108326053924426308124142840691936450811494214314530042223112647841379178752386096819284597082181604095514469952533959856268624576752123904.0000 |   Inf | 7.4182 | -0.1151 | 1.0000 | 0.2294 | -0.9308 | 0.2844 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.01710842 |
| 10 | -721.139 | 17.0745 | 8.2423 | 9.5970 | 1.6318 | 0.2703 | 1.9375 |   Inf | 15620111.3611 | 7.4182 | -0.1151 | 1.0000 | 0.2294 | -0.9308 | 0.2844 | 0.9676 | 0.1866 | -0.1699 | 0.1051 | 0.3142 | 0.9435 | 0.01711418 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0001 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.836e+04 | 2.277e+04 |
| 2 | 7.156e+02 | 6.878e+02 |
| 3 | 5.009e+02 | 4.916e+02 |
| 4 | 3.877e+02 | 8.155e+01 |
| 5 | 8.055e+01 | 3.560e+01 |
| 6 | 3.428e+01 | 2.308e+01 |
| 7 | 2.279e+01 | 8.970e+00 |
| 8 | 3.191e+00 | 3.509e+00 |
| 9 | 1.152e+00 | 9.164e-01 |
| 10 | 7.093e-01 | 7.019e-01 |
| 11 | 2.518e-03 | 1.964e-01 |
| 12 | 2.117e-08 | 1.493e-03 |
| 13 | -2.779e+00 | -2.935e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -741.278 | 32.2493 | 50.0874 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00000000 |
| 2 | -741.278 | 32.2494 | 50.0875 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00011126 |
| 3 | -741.278 | 32.2494 | 50.0875 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00010218 |
| 4 | -741.278 | 32.2494 | 50.0874 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00002706 |
| 5 | -741.278 | 32.2494 | 50.0874 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00005865 |
| 6 | -741.278 | 32.2493 | 50.0873 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3220 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00013729 |
| 7 | -741.278 | 32.2494 | 50.0874 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00004531 |
| 8 | -741.278 | 32.2494 | 50.0874 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00009541 |
| 9 | -741.278 | 32.2494 | 50.0874 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00007710 |
| 10 | -741.278 | 32.2493 | 50.0873 | 6.4181 | 4.3744 |   Inf | 1.1053 | -26.3221 | 0.3139 | 0.4929 | 0.8701 | -0.8701 | 0.4929 | 0.00005852 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0001 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.121e+05 | 1.116e+05 |
| 2 | 2.467e+04 | 2.464e+04 |
| 3 | 2.019e+02 | 2.183e+02 |
| 4 | 1.660e+02 | 1.772e+02 |
| 5 | 3.641e+01 | 5.339e+01 |
| 6 | 1.260e-01 | 8.336e-02 |
| 7 | -5.265e-02 | 2.983e-02 |
| 8 | -1.540e+00 | 3.909e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 2854534572.9157, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -741.278 | 32.2494 | 50.0874 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3221 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00000000 |
| 2 | -741.278 | 32.2494 | 50.0875 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3221 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00004837 |
| 3 | -741.278 | 32.2494 | 50.0875 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3222 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00008587 |
| 4 | -741.278 | 32.2495 | 50.0876 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3222 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00018006 |
| 5 | -741.278 | 32.2493 | 50.0874 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3221 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00006220 |
| 6 | -741.278 | 32.2494 | 50.0874 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3221 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00000499 |
| 7 | -741.278 | 32.2493 | 50.0873 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3221 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00013581 |
| 8 | -741.278 | 32.2493 | 50.0873 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3220 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00021831 |
| 9 | -741.278 | 32.2494 | 50.0874 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3221 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00001353 |
| 10 | -741.278 | 32.2494 | 50.0875 |   Inf | 1.1053 | 6.4181 | 4.3744 | -26.3222 | 0.3139 | -0.4929 | -0.8701 | 0.8701 | -0.4929 | 0.00006166 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0001 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.117e+05 | 1.116e+05 |
| 2 | 2.489e+04 | 2.464e+04 |
| 3 | 1.988e+02 | 2.194e+02 |
| 4 | 1.650e+02 | 1.776e+02 |
| 5 | 4.608e+01 | 5.389e+01 |
| 6 | 3.098e-01 | 8.821e-02 |
| 7 | -1.115e-01 | 3.588e-02 |
| 8 | -5.246e+00 | 6.449e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1730148820.5142, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -741.278 | 32.2493 | 50.0873 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00000000 |
| 2 | -741.278 | 32.2494 | 50.0875 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3222 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00028408 |
| 3 | -741.278 | 32.2493 | 50.0874 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00007606 |
| 4 | -741.278 | 32.2494 | 50.0874 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00012714 |
| 5 | -741.278 | 32.2494 | 50.0874 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00010567 |
| 6 | -741.278 | 32.2494 | 50.0874 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00008787 |
| 7 | -741.278 | 32.2493 | 50.0873 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3220 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00004354 |
| 8 | -741.278 | 32.2494 | 50.0875 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00017203 |
| 9 | -741.278 | 32.2495 | 50.0876 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3222 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00032867 |
| 10 | -741.278 | 32.2494 | 50.0875 | 1.1053 | 6.4181 | 4.3744 |   Inf | -26.3221 | 0.3139 | 0.8701 | -0.4929 | 0.4929 | 0.8701 | 0.00016157 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0003 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 8.597e+04 | 1.116e+05 |
| 2 | 3.068e+04 | 2.464e+04 |
| 3 | 7.868e+02 | 2.191e+02 |
| 4 | 1.883e+02 | 1.775e+02 |
| 5 | 1.086e+02 | 5.385e+01 |
| 6 | 2.337e-01 | 8.737e-02 |
| 7 | -3.061e-01 | 3.719e-02 |
| 8 | -8.951e-01 | 4.368e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 2554279438.5245, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -741.278 | 32.2494 | 50.0874 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3221 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00000000 |
| 2 | -741.278 | 32.2493 | 50.0874 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3221 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00012569 |
| 3 | -741.278 | 32.2493 | 50.0874 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3221 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00009163 |
| 4 | -741.278 | 32.2494 | 50.0875 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3222 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00005143 |
| 5 | -741.278 | 32.2493 | 50.0873 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3221 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00015595 |
| 6 | -741.278 | 32.2493 | 50.0873 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3220 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00019905 |
| 7 | -741.278 | 32.2494 | 50.0875 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3222 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00012557 |
| 8 | -741.278 | 32.2494 | 50.0875 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3221 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00002246 |
| 9 | -741.278 | 32.2493 | 50.0873 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3220 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00024648 |
| 10 | -741.278 | 32.2494 | 50.0874 | 4.3744 |   Inf | 1.1053 | 6.4181 | -26.3221 | 0.3139 | -0.8701 | 0.4929 | -0.4929 | -0.8701 | 0.00005655 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0001 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.099e+05 | 1.116e+05 |
| 2 | 2.549e+04 | 2.464e+04 |
| 3 | 2.020e+02 | 2.186e+02 |
| 4 | 1.730e+02 | 1.772e+02 |
| 5 | 7.051e+01 | 5.344e+01 |
| 6 | 2.676e-01 | 8.326e-02 |
| 7 | -1.297e-01 | 2.985e-02 |
| 8 | -9.593e+00 | 6.409e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1740939728.7975, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000000 |
| 2 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000142 |
| 3 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000061 |
| 4 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000166 |
| 5 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000047 |
| 6 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000059 |
| 7 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000044 |
| 8 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000074 |
| 9 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000072 |
| 10 | -746.125 | 7.9963 | 11.0563 |   Inf | 9.5586 | 0.4416 | 1.8781 | 0.2016 | 1.0000 | -0.9786 | 0.2057 | -0.2057 | -0.9786 | 0.00000101 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.786e+04 | 1.791e+04 |
| 2 | 5.883e+02 | 5.883e+02 |
| 3 | 2.606e+02 | 2.604e+02 |
| 4 | 4.855e+01 | 5.066e+01 |
| 5 | 2.320e+01 | 2.340e+01 |
| 6 | 2.528e+00 | 2.503e+00 |
| 7 | 2.756e-01 | 2.424e-01 |

numDeriv::hessian (operative): cond = 64801.3765, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 73895.7050, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: T2_T3_P3__bd_pd1_sigL2, T2_T3_P3__bd_pd1_sigR2, T2_T3_P3__bd_pd1_sigL3

Across 18 scanned models: 18 pass Flag A (convergence), 1 pass strict Flag B, 4 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **4**.

**Why models fail Flag A.** Of the 0 models that fail Flag A: **0** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **0** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance would additionally qualify 3 model(s)** (those combine Flag A convergence with a Hessian that is positive-definite only under the relaxed tolerance).

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 12 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T1_P2_P3, T2_noP, T2_P2_P3, T2_T3_noP, T3_noP, T3_P1, T3_P2_P3)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T1_P3__bd_pd1_sigL1`
- **pBIC (Ω):** 1544.1
- **logLik:** -746.1247
- **Variables:** T1, P3
- **Free parameters (n_free):** 7
- **Boundary mask:** pd=Inf, sigltil1=Inf

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.3471
- **Threshold:** 0.2070
- **Sensitivity:** 0.8688
- **Specificity:** 0.4783
- **Presences / pseudo-absences:** 343 / 1294
- **Prevalence:** 0.2103

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | 7.9963, 11.0563 |
| sigltil |   Inf, 9.5586 |
| sigrtil | 0.4416, 1.8781 |
| ctil | 0.2016 |
| pd | 1.0000 |
| o_mat | -0.9786, 0.2057, -0.2057, -0.9786 |

### Profile likelihoods and arc check

- **Arc check:** 7/7 parameters pass → **ALL PASS ✓**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | PASS | pass |
| mu2 | PASS | pass |
| sigltil2 | PASS | pass |
| sigrtil1 | PASS | pass |
| sigrtil2 | PASS | pass |
| ctil | PASS | pass |
| o_par1 | PASS | pass |

## Profile likelihood plots

![Profile likelihood plots for the best model (T1_P3__bd_pd1_sigL1)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T1_P3__bd_pd1_sigL1` (pBIC = 1544.1)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 114
- **Boundary L4 fits:** 0
- **τ:** 29.6025

_Generated: 2026-07-22 04:04:23_

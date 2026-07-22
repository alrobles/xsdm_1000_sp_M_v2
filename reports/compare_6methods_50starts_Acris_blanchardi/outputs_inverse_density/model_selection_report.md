# xsdm v6 — Model selection report (Algorithm2)

**Species:** *Acris blanchardi*

This report documents, step by step, the literal Algorithm2 selection rules
applied to this species. Each phase (L1–L4) includes the rule itself and
the complete list of models with their classification.

**Definition of model success:** a model has `status == "success"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.

## Data and units

- Species directory: `/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_inverse_density_smoke/Acris_blanchardi`
- Sample size: 655
- Maximum variables per model: 3
- Tau (τ): 25.9385
- L2 threshold: best L1 + τ = 773.4823
- Ω threshold: 773.8278
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
| 1 | T1_P3 ≤τ | T1+P3 | 747.5 | -344.591 | 9 | success |
| 2 | T2_P3 ≤τ | T2+P3 | 750.3 | -345.950 | 9 | success |
| 3 | T2_T3_P3 ≤τ | T2+T3+P3 | 755.2 | -332.212 | 14 | success |
| 4 | T3_P3 ≤τ | T3+P3 | 758.2 | -349.944 | 9 | success |
| 5 | T2_P1 ≤τ | T2+P1 | 761.3 | -351.457 | 9 | success |
| 6 | T1_P1 ≤τ | T1+P1 | 762.1 | -351.857 | 9 | success |
| 7 | T1_P2 ≤τ | T1+P2 | 767.0 | -354.298 | 9 | success |
| 8 | T3_P2 ≤τ | T3+P2 | 767.1 | -354.383 | 9 | success |
| 9 | T2_T3_P1 ≤τ | T2+T3+P1 | 772.7 | -340.949 | 14 | success |
| 10 | T1_P2_P3 | T1+P2+P3 | 774.9 | -342.055 | 14 | success |
| 11 | T3_P2_P3 | T3+P2+P3 | 774.9 | -342.066 | 14 | success |
| 12 | T2_P2_P3 | T2+P2+P3 | 775.4 | -342.314 | 14 | success |
| 13 | T3_P1 | T3+P1 | 779.3 | -360.480 | 9 | success |
| 14 | T2_T3_P2 | T2+T3+P2 | 782.1 | -345.651 | 14 | success |
| 15 | T1_noP | T1 | 791.5 | -379.561 | 5 | success |
| 16 | T2_P2 | T2+P2 | 791.6 | -366.610 | 9 | success |
| 17 | T2_T3_noP | T2+T3 | 796.4 | -369.014 | 9 | success |
| 18 | T2_noP | T2 | 801.6 | -384.590 | 5 | success |
| 19 | T3_noP | T3 | 807.1 | -387.346 | 5 | success |
| 20 | noT_P2_P3 | P2+P3 | 884.8 | -413.220 | 9 | success |
| 21 | noT_P3 | P3 | 892.9 | -430.218 | 5 | success |
| 22 | noT_P2 | P2 | 899.6 | -433.570 | 5 | success |
| 23 | noT_P1 | P1 | 908.9 | -438.244 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 773.5**.
**Eligible L1 models:** 9 (T1_P1, T1_P2, T1_P3, T2_P1, T2_P3, T2_T3_P1, T2_T3_P3, T3_P2, T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_P3__bd_sigL2 | 745.8 | -346.943 | 8 | success |
| T2_P3__bd_sigL1 | 745.8 | -346.943 | 8 | success |
| T2_P3__bd_sigR2 | 745.8 | -346.943 | 8 | success |
| T2_P3__bd_sigR1 | 745.8 | -346.943 | 8 | success |
| T2_T3_P3__bd_pd1_sigR3 | 746.4 | -334.303 | 12 | success |
| T1_P3__bd_sigL1 | 746.8 | -347.448 | 8 | success |
| T1_P3__bd_sigR1 | 746.8 | -347.448 | 8 | success |
| T1_P3__bd_sigL2 | 746.8 | -347.448 | 8 | success |
| T2_T3_P3__bd_pd1_sigL2 | 747.8 | -334.987 | 12 | success |
| T2_T3_P3__bd_pd1_sigR1 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigL1 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_sigL3 | 748.7 | -332.214 | 13 | success |
| T2_T3_P3__bd_sigL2 | 748.7 | -332.215 | 13 | success |
| T2_T3_P3__bd_sigR2 | 749.3 | -332.488 | 13 | success |
| T2_T3_P3__bd_sigR3 | 749.5 | -332.578 | 13 | success |
| T2_T3_P3__bd_sigR1 | 750.5 | -333.098 | 13 | success |
| T2_T3_P3__bd_sigL1 | 750.5 | -333.098 | 13 | success |
| T2_T3_P3__bd_pd1 | 752.9 | -334.280 | 13 | success |
| T1_P3__bd_sigR2 | 753.8 | -350.962 | 8 | success |
| T1_P3__bd_pd1_sigR1 | 755.3 | -354.947 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 755.3 | -354.947 | 7 | success |
| T1_P3__bd_pd1_sigL1 | 755.3 | -354.947 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 755.3 | -354.947 | 7 | success |
| T2_P1__bd_pd1_sigR1 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_pd1_sigR2 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_sigL2 | 758.2 | -353.162 | 8 | success |
| T2_P1__bd_sigR1 | 758.2 | -353.162 | 8 | success |
| T2_P1__bd_sigL1 | 758.2 | -353.162 | 8 | success |
| T2_P1__bd_sigR2 | 758.2 | -353.162 | 8 | success |
| T2_P3__bd_pd1_sigR2 | 758.4 | -356.528 | 7 | success |
| T2_P3__bd_pd1_sigL2 | 758.4 | -356.528 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 758.4 | -356.528 | 7 | success |
| T2_P3__bd_pd1_sigR1 | 758.4 | -356.528 | 7 | success |
| T3_P3__bd_sigR1 | 758.7 | -353.393 | 8 | success |
| T3_P3__bd_sigL1 | 758.7 | -353.393 | 8 | success |
| T3_P3__bd_sigR2 | 758.7 | -353.393 | 8 | success |
| T3_P3__bd_sigL2 | 758.7 | -353.393 | 8 | success |
| T2_P3__bd_pd1 | 758.7 | -353.394 | 8 | success |
| T1_P1__bd_pd1_sigL1 | 758.8 | -356.685 | 7 | success |
| T1_P1__bd_pd1_sigR1 | 758.8 | -356.685 | 7 | success |
| T1_P1__bd_pd1_sigL2 | 758.8 | -356.685 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 758.8 | -356.685 | 7 | success |
| T1_P2__bd_sigL1 | 760.3 | -354.236 | 8 | success |
| T1_P2__bd_sigR2 | 760.4 | -354.267 | 8 | success |
| T1_P2__bd_sigR1 | 760.4 | -354.281 | 8 | success |
| T1_P2__bd_sigL2 | 760.5 | -354.310 | 8 | success |
| T3_P2__bd_sigL1 | 760.7 | -354.398 | 8 | success |
| T3_P2__bd_sigR1 | 760.8 | -354.468 | 8 | success |
| T3_P2__bd_sigL2 | 760.8 | -354.481 | 8 | success |
| T3_P2__bd_sigR2 | 760.9 | -354.499 | 8 | success |
| T1_P3__bd_pd1 | 761.8 | -354.947 | 8 | success |
| T2_P1__bd_pd1 | 762.0 | -355.072 | 8 | success |
| T1_P1__bd_sigR2 | 762.3 | -355.235 | 8 | success |
| T1_P1__bd_sigL1 | 762.3 | -355.235 | 8 | success |
| T1_P1__bd_sigR1 | 762.3 | -355.235 | 8 | success |
| T1_P1__bd_sigL2 | 762.3 | -355.235 | 8 | success |
| T3_P3__bd_pd1 | 763.0 | -355.547 | 8 | success |
| T3_P3__bd_pd1_sigR1 | 763.5 | -359.030 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 763.5 | -359.030 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 763.5 | -359.030 | 7 | success |
| T3_P3__bd_pd1_sigR2 | 763.5 | -359.030 | 7 | success |
| T2_T3_P1__bd_pd1_sigL1 | 764.8 | -343.496 | 12 | success |
| T2_T3_P1__bd_pd1_sigR2 | 764.8 | -343.496 | 12 | success |
| T2_T3_P1__bd_pd1_sigR1 | 764.8 | -343.496 | 12 | success |
| T1_P1__bd_pd1 | 764.9 | -356.525 | 8 | success |
| T2_T3_P1__bd_sigL3 | 766.2 | -340.959 | 13 | success |
| T2_T3_P1__bd_sigR3 | 766.5 | -341.089 | 13 | success |
| T2_T3_P1__bd_pd1_sigL3 | 766.5 | -344.336 | 12 | success |
| T2_T3_P1__bd_sigR1 | 767.1 | -341.423 | 13 | success |
| T2_T3_P1__bd_pd1_sigL2 | 767.9 | -345.052 | 12 | success |
| T2_T3_P1__bd_sigL2 | 768.0 | -341.866 | 13 | success |
| T2_T3_P1__bd_sigL1 | 768.1 | -341.885 | 13 | success |
| T2_T3_P1__bd_sigR2 | 768.1 | -341.905 | 13 | success |
| T1_P2__bd_pd1_sigL2 | 768.5 | -361.576 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 768.5 | -361.576 | 7 | success |
| T1_P2__bd_pd1_sigL1 | 768.5 | -361.576 | 7 | success |
| T1_P2__bd_pd1_sigR2 | 768.5 | -361.576 | 7 | success |
| T2_T3_P1__bd_pd1_sigR3 | 769.0 | -345.578 | 12 | success |
| T2_T3_P1__bd_pd1 | 770.7 | -343.215 | 13 | success |
| T3_P2__bd_pd1_sigR2 | 774.8 | -364.696 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 774.8 | -364.696 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 774.8 | -364.696 | 7 | success |
| T3_P2__bd_pd1_sigL2 | 774.8 | -364.696 | 7 | success |
| T1_P2__bd_pd1 | 775.0 | -361.576 | 8 | success |
| T3_P2__bd_pd1 | 781.2 | -364.666 | 8 | success |
| T2_P2__bd_pd1 | 785.1 | -366.610 | 8 | success |
| T2_T3_noP__bd_pd1 | 789.9 | -369.007 | 8 | success |
| T2_noP__bd_pd1 | 795.1 | -384.590 | 4 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_pd1_sigR1_sigL2 | 741.4 | yes ✓ | ✓ | ✓ | 5.25e+04 | 15 |
| 2 | T2_T3_P3__bd_pd1_sigR1_sigR3 | 741.4 | yes ✓ | ✓ | ✓ | 8.55e+03 | 6 |
| 3 | T2_P3__bd_sigL2 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 4 | T2_P3__bd_sigL1 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 5 | T2_P3__bd_sigR2 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 6 | T2_P3__bd_sigR1 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 7 | T2_T3_P3__bd_pd1_sigR3 | 746.4 | no | ✗ | ✗ | Inf | 1 |
| 8 | T1_P3__bd_sigL1 | 746.8 | no | ✗ | ✗ | Inf | 1 |
| 9 | T1_P3__bd_sigR1 | 746.8 | no | ✗ | ✗ | Inf | 1 |
| 10 | T1_P3__bd_sigL2 | 746.8 | no | ✗ | ✗ | Inf | 1 |
| 11 | T1_P3 | 747.5 | no | ✗ | ✗ | Inf | 1 |
| 12 | T2_T3_P3__bd_pd1_sigL2 | 747.8 | no | ✗ | ✗ | Inf | 1 |
| 13 | T2_T3_P3__bd_pd1_sigR1 | 747.9 | yes ✓ | ✓ | ✓ | 1.38e+04 | 9 |
| 14 | T2_T3_P3__bd_pd1_sigL1 | 747.9 | no | ✓ | ✗ | Inf | 7 |
| 15 | T2_T3_P3__bd_pd1_sigL3 | 747.9 | no | ✓ | ✗ | 3.02e+06 | 4 |
| 16 | T2_T3_P3__bd_pd1_sigR2 | 747.9 | yes ✓ | ✓ | ✓ | 2.56e+05 | 3 |
| 17 | T2_T3_P3__bd_sigL3 | 748.7 | no | ✗ | ✗ | Inf | 1 |
| 18 | T2_T3_P3__bd_sigL2 | 748.7 | no | ✗ | ✗ | Inf | 1 |
| 19 | T2_T3_P3__bd_sigR2 | 749.3 | no | ✗ | ✗ | Inf | 1 |
| 20 | T2_T3_P3__bd_sigR3 | 749.5 | no | ✗ | ✗ | Inf | 1 |
| 21 | T2_P3 | 750.3 | no | ✗ | ✗ | Inf | 1 |
| 22 | T2_T3_P3__bd_sigR1 | 750.5 | no | ✗ | ✗ | Inf | 1 |
| 23 | T2_T3_P3__bd_sigL1 | 750.5 | no | ✗ | ✗ | Inf | 1 |
| 24 | T2_T3_P3__bd_pd1_sigR1_sigL2_sigR3 | 751.8 | no | ✗ | ✗ | Inf | 1 |
| 25 | T2_T3_P3__bd_pd1 | 752.9 | no | ✗ | ✗ | Inf | 1 |
| 26 | T1_P3__bd_sigR2 | 753.8 | yes ✓ | ✓ | ✓ | 1.04e+05 | 22 |
| 27 | T2_T3_P3 | 755.2 | no | ✗ | ✗ | Inf | 1 |
| 28 | T1_P3__bd_pd1_sigR1 | 755.3 | yes ✓ | ✓ | ✓ | 2.42e+04 | 9 |
| 29 | T1_P3__bd_pd1_sigR2 | 755.3 | yes ✓ | ✓ | ✓ | 2.42e+04 | 9 |
| 30 | T1_P3__bd_pd1_sigL1 | 755.3 | no | ✓ | ✗ | Inf | 11 |
| 31 | T1_P3__bd_pd1_sigL2 | 755.3 | yes ✓ | ✓ | ✓ | 2.51e+04 | 18 |
| 32 | T2_P1__bd_pd1_sigR1 | 756.8 | yes ✓ | ✓ | ✓ | 9.98e+02 | 13 |
| 33 | T2_P1__bd_pd1_sigR2 | 756.8 | yes ✓ | ✓ | ✓ | 1.03e+03 | 13 |
| 34 | T2_P1__bd_pd1_sigL1 | 756.8 | yes ✓ | ✓ | ✓ | 9.94e+02 | 9 |
| 35 | T2_P1__bd_pd1_sigL2 | 756.8 | yes ✓ | ✓ | ✓ | 9.95e+02 | 14 |
| 36 | T2_P1__bd_sigL2 | 758.2 | yes ✓ | ✓ | ✓ | 5.14e+04 | 9 |
| 37 | T2_P1__bd_sigR1 | 758.2 | yes ✓ | ✓ | ✓ | 2.05e+04 | 17 |
| 38 | T2_P1__bd_sigL1 | 758.2 | no | ✓ | ✗ | Inf | 14 |
| 39 | T2_P1__bd_sigR2 | 758.2 | yes ✓ | ✓ | ✓ | 2.72e+04 | 7 |
| 40 | T3_P3 | 758.2 | no | ✗ | ✗ | Inf | 1 |
| 41 | T2_P3__bd_pd1_sigR2 | 758.4 | yes ✓ | ✓ | ✓ | 4.79e+03 | 11 |
| 42 | T2_P3__bd_pd1_sigL2 | 758.4 | yes ✓ | ✓ | ✓ | 4.92e+03 | 12 |
| 43 | T2_P3__bd_pd1_sigL1 | 758.4 | yes ✓ | ✓ | ✓ | 4.86e+03 | 11 |
| 44 | T2_P3__bd_pd1_sigR1 | 758.4 | yes ✓ | ✓ | ✓ | 4.94e+03 | 13 |
| 45 | T3_P3__bd_sigR1 | 758.7 | yes ✓ | ✓ | ✓ | 2.89e+05 | 24 |
| 46 | T3_P3__bd_sigL1 | 758.7 | no | ✓ | ✗ | Inf | 9 |
| 47 | T3_P3__bd_sigR2 | 758.7 | no | ✓ | ✗ | 3.15e+06 | 21 |
| 48 | T3_P3__bd_sigL2 | 758.7 | yes ✓ | ✓ | ✓ | 7.58e+04 | 16 |
| 49 | T2_P3__bd_pd1 | 758.7 | yes ✓ | ✓ | ✓ | 5.65e+03 | 35 |
| 50 | T1_P1__bd_pd1_sigL1 | 758.8 | yes ✓ | ✓ | ✓ | 7.88e+05 | 10 |
| 51 | T1_P1__bd_pd1_sigR1 | 758.8 | yes ✓ | ✓ | ✓ | 7.64e+05 | 11 |
| 52 | T1_P1__bd_pd1_sigL2 | 758.8 | yes ✓ | ✓ | ✓ | 7.61e+05 | 12 |
| 53 | T1_P1__bd_pd1_sigR2 | 758.8 | yes ✓ | ✓ | ✓ | 7.62e+05 | 11 |
| 54 | T1_P2__bd_sigL1 | 760.3 | no | ✗ | ✗ | Inf | 1 |
| 55 | T1_P2__bd_sigR2 | 760.4 | no | ✗ | ✗ | Inf | 1 |
| 56 | T1_P2__bd_sigR1 | 760.4 | no | ✗ | ✗ | Inf | 1 |
| 57 | T1_P2__bd_sigL2 | 760.5 | no | ✗ | ✗ | Inf | 1 |
| 58 | T3_P2__bd_sigL1 | 760.7 | no | ✗ | ✗ | Inf | 1 |
| 59 | T3_P2__bd_sigR1 | 760.8 | no | ✗ | ✗ | Inf | 1 |
| 60 | T3_P2__bd_sigL2 | 760.8 | no | ✗ | ✗ | Inf | 1 |
| 61 | T3_P2__bd_sigR2 | 760.9 | no | ✗ | ✗ | Inf | 1 |
| 62 | T2_P1 | 761.3 | no | ✓ | ✗ | Inf | 3 |
| 63 | T1_P3__bd_pd1 | 761.8 | no | ✓ | ✗ | 1.56e+18 | 23 |
| 64 | T2_P1__bd_pd1 | 762.0 | yes ✓ | ✓ | ✓ | 1.55e+03 | 48 |
| 65 | T1_P1 | 762.1 | no | ✓ | ✗ | 4.40e+06 | 29 |
| 66 | T1_P1__bd_sigR2 | 762.3 | no | ✓ | ✗ | 3.25e+06 | 4 |
| 67 | T1_P1__bd_sigL1 | 762.3 | no | ✓ | ✗ | Inf | 4 |
| 68 | T1_P1__bd_sigR1 | 762.3 | no | ✓ | ✗ | 2.26e+06 | 7 |
| 69 | T1_P1__bd_sigL2 | 762.3 | no | ✓ | ✗ | 5.31e+06 | 4 |
| 70 | T3_P3__bd_pd1 | 763.0 | yes ✓ | ✓ | ✓ | 2.39e+04 | 47 |
| 71 | T3_P3__bd_pd1_sigR1 | 763.5 | yes ✓ | ✓ | ✓ | 1.17e+04 | 19 |
| 72 | T3_P3__bd_pd1_sigL2 | 763.5 | yes ✓ | ✓ | ✓ | 1.17e+04 | 24 |
| 73 | T3_P3__bd_pd1_sigL1 | 763.5 | yes ✓ | ✓ | ✓ | 1.17e+04 | 23 |
| 74 | T3_P3__bd_pd1_sigR2 | 763.5 | yes ✓ | ✓ | ✓ | 1.17e+04 | 18 |
| 75 | T2_T3_P1__bd_pd1_sigL1 | 764.8 | yes ✓ | ✓ | ✓ | 9.27e+05 | 3 |
| 76 | T2_T3_P1__bd_pd1_sigR2 | 764.8 | no | ✓ | ✗ | Inf | 5 |
| 77 | T2_T3_P1__bd_pd1_sigR1 | 764.8 | no | ✗ | ✗ | Inf | 1 |
| 78 | T1_P1__bd_pd1 | 764.9 | no | ✓ | ✗ | Inf | 43 |
| 79 | T2_T3_P1__bd_sigL3 | 766.2 | no | ✗ | ✗ | Inf | 1 |
| 80 | T2_T3_P1__bd_sigR3 | 766.5 | no | ✗ | ✗ | Inf | 1 |
| 81 | T2_T3_P1__bd_pd1_sigL3 | 766.5 | no | ✗ | ✗ | Inf | 1 |
| 82 | T1_P2 | 767.0 | no | ✗ | ✗ | Inf | 1 |
| 83 | T3_P2 | 767.1 | no | ✗ | ✗ | Inf | 1 |
| 84 | T2_T3_P1__bd_sigR1 | 767.1 | no | ✗ | ✗ | Inf | 1 |
| 85 | T2_T3_P1__bd_pd1_sigL2 | 767.9 | no | ✗ | ✗ | Inf | 1 |
| 86 | T2_T3_P1__bd_sigL2 | 768.0 | no | ✗ | ✗ | Inf | 1 |
| 87 | T2_T3_P1__bd_sigL1 | 768.1 | no | ✗ | ✗ | Inf | 1 |
| 88 | T2_T3_P1__bd_sigR2 | 768.1 | no | ✗ | ✗ | Inf | 2 |
| 89 | T1_P2__bd_pd1_sigL2 | 768.5 | yes ✓ | ✓ | ✓ | 4.69e+04 | 13 |
| 90 | T1_P2__bd_pd1_sigR1 | 768.5 | yes ✓ | ✓ | ✓ | 4.60e+04 | 11 |
| 91 | T1_P2__bd_pd1_sigL1 | 768.5 | yes ✓ | ✓ | ✓ | 4.70e+04 | 7 |
| 92 | T1_P2__bd_pd1_sigR2 | 768.5 | yes ✓ | ✓ | ✓ | 4.70e+04 | 7 |
| 93 | T2_T3_P1__bd_pd1_sigR3 | 769.0 | no | ✗ | ✗ | Inf | 1 |
| 94 | T2_T3_P1__bd_pd1 | 770.7 | no | ✓ | ✗ | Inf | 6 |
| 95 | T2_T3_P1 | 772.7 | no | ✗ | ✗ | Inf | 1 |
| 96 | T3_P2__bd_pd1_sigR2 | 774.8 | yes ✓ | ✓ | ✓ | 1.02e+05 | 13 |
| 97 | T3_P2__bd_pd1_sigR1 | 774.8 | yes ✓ | ✓ | ✓ | 1.09e+05 | 6 |
| 98 | T3_P2__bd_pd1_sigL1 | 774.8 | yes ✓ | ✓ | ✓ | 1.04e+05 | 5 |
| 99 | T3_P2__bd_pd1_sigL2 | 774.8 | yes ✓ | ✓ | ✓ | 1.12e+05 | 6 |
| 100 | T1_P2_P3 | 774.9 | no | ✗ | ✗ | Inf | 1 |
| 101 | T3_P2_P3 | 774.9 | no | ✗ | ✗ | Inf | 1 |
| 102 | T1_P2__bd_pd1 | 775.0 | no | ✓ | ✗ | Inf | 44 |
| 103 | T2_P2_P3 | 775.4 | no | ✗ | ✗ | Inf | 1 |
| 104 | T3_P1 | 779.3 | no | ✗ | ✗ | Inf | 1 |
| 105 | T3_P2__bd_pd1 | 781.2 | yes ✓ | ✓ | ✓ | 7.86e+05 | 30 |
| 106 | T2_T3_P2 | 782.1 | no | ✗ | ✗ | Inf | 1 |
| 107 | T2_P2__bd_pd1 | 785.1 | no | ✓ | ✗ | 5.07e+16 | 42 |
| 108 | T2_T3_noP__bd_pd1 | 789.9 | no | ✗ | ✗ | Inf | 1 |
| 109 | T1_noP | 791.5 | yes ✓ | ✓ | ✓ | 7.88e+03 | 45 |
| 110 | T2_P2 | 791.6 | no | ✓ | ✗ | Inf | 32 |
| 111 | T2_noP__bd_pd1 | 795.1 | no | ✓ | ✗ | Inf | 50 |
| 112 | T2_T3_noP | 796.4 | no | ✗ | ✗ | Inf | 1 |
| 113 | T2_noP | 801.6 | no | ✓ | ✗ | 7.05e+12 | 50 |
| 114 | T3_noP | 807.1 | no | ✓ | ✗ | Inf | 41 |
| 115 | noT_P2_P3 | 884.8 | no | ✗ | ✗ | Inf | 1 |
| 116 | noT_P3 | 892.9 | no | ✓ | ✗ | 3.47e+07 | 3 |
| 117 | noT_P2 | 899.6 | no | ✗ | ✗ | Inf | 1 |
| 118 | noT_P1 | 908.9 | no | ✗ | ✗ | Inf | 1 |
| 119 | T2_T3_P3__bd_pd1_sigL01_sigR1_sigL2_sigR3 | NA | (not scanned) | — | — | — | — |
| 120 | T2_T3_P3__bd_pd1_sigL01_sigR1_sigL2 | NA | (not scanned) | — | — | — | — |
| 121 | T2_T3_P3__bd_pd1_sigL01_sigR1_sigR3 | NA | (not scanned) | — | — | — | — |
| 122 | T2_T3_P3__bd_pd1_sigL01_sigR1 | NA | (not scanned) | — | — | — | — |
| 123 | T2_T3_P3__bd_pd1_sigR1_sigL2_sigR02 | NA | (not scanned) | — | — | — | — |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T2_T3_P3__bd_pd1_sigR1_sigL2` — **Ω = 741.4**

## L3 supplementary appendices — per-model diagnostics

### T2_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -346.943 | 35.9311 | 40.0238 | 5.2677 |   Inf | 0.0000 | 1.6251 | -21.4349 | 0.6938 | 0.2908 | 0.9568 | -0.9568 | 0.2908 | 0.00000000 |
| 2 | -346.943 | 35.9129 | 40.0334 | 5.2702 |   Inf | 0.0001 | 1.6237 | -21.4211 | 0.6938 | 0.2903 | 0.9569 | -0.9569 | 0.2903 | 18109.55503606 |
| 3 | -346.943 | 35.9179 | 40.0296 | 5.2693 |   Inf | 0.0001 | 1.6240 | -21.4244 | 0.6938 | 0.2905 | 0.9569 | -0.9569 | 0.2905 | 19686.24237685 |
| 4 | -348.942 | 37.2974 | 39.4641 | 6.1264 |   Inf | 0.0001 | 2.1681 | -15.8263 | 0.7034 | 0.3018 | 0.9534 | -0.9534 | 0.3018 | 24548.33478649 |
| 5 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377243 |
| 6 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377242 |
| 7 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377239 |
| 8 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377239 |
| 9 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377242 |
| 10 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377243 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0001, max_pdist=19686.2424 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.304e+06 | 1.587e+08 |
| 2 | 4.212e+05 | 9.267e+05 |
| 3 | 2.005e+04 | 2.006e+04 |
| 4 | 1.808e+03 | 1.808e+03 |
| 5 | 8.422e+01 | 8.371e+01 |
| 6 | 7.395e-02 | 6.793e-02 |
| 7 | -4.943e+05 | -2.468e+00 |
| 8 | -2.497e+08 | -1.110e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -346.943 | 35.9284 | 40.0241 |   Inf | 0.0000 | 1.6249 | 5.2687 | -21.4257 | 0.6938 | -0.9568 | 0.2908 | -0.2908 | -0.9568 | 0.00000000 |
| 2 | -346.943 | 35.9493 | 40.0106 |   Inf | 0.0000 | 1.6263 | 5.2652 | -21.4444 | 0.6938 | -0.9566 | 0.2915 | -0.2915 | -0.9566 | 1360.65913704 |
| 3 | -346.943 | 35.9546 | 40.0074 |   Inf | 0.0000 | 1.6267 | 5.2645 | -21.4481 | 0.6938 | -0.9565 | 0.2916 | -0.2916 | -0.9565 | 4443.20715317 |
| 4 | -346.943 | 35.9450 | 40.0134 |   Inf | 0.0000 | 1.6259 | 5.2653 | -21.4455 | 0.6938 | -0.9566 | 0.2913 | -0.2913 | -0.9566 | 869.94470499 |
| 5 | -346.943 | 35.9481 | 40.0111 |   Inf | 0.0001 | 1.6263 | 5.2653 | -21.4437 | 0.6938 | -0.9566 | 0.2914 | -0.2914 | -0.9566 | 3523.13738367 |
| 6 | -346.943 | 35.9518 | 40.0091 |   Inf | 0.0000 | 1.6266 | 5.2648 | -21.4466 | 0.6938 | -0.9566 | 0.2915 | -0.2915 | -0.9566 | 1700.12338582 |
| 7 | -346.943 | 35.9522 | 40.0086 |   Inf | 0.0000 | 1.6266 | 5.2649 | -21.4451 | 0.6938 | -0.9566 | 0.2916 | -0.2916 | -0.9566 | 2604.72838223 |
| 8 | -346.943 | 35.9461 | 40.0121 |   Inf | 0.0001 | 1.6261 | 5.2656 | -21.4417 | 0.6938 | -0.9566 | 0.2914 | -0.2914 | -0.9566 | 5042.66842194 |
| 9 | -346.943 | 35.9465 | 40.0123 |   Inf | 0.0001 | 1.6261 | 5.2652 | -21.4455 | 0.6938 | -0.9566 | 0.2914 | -0.2914 | -0.9566 | 4904.60525409 |
| 10 | -346.943 | 35.9164 | 40.0299 |   Inf | 0.0001 | 1.6237 | 5.2686 | -21.4306 | 0.6938 | -0.9569 | 0.2905 | -0.2905 | -0.9569 | 12091.77215047 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=4443.2072 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.596e+08 | 4.299e+07 |
| 2 | 1.733e+05 | 1.419e+06 |
| 3 | 2.005e+04 | 2.006e+04 |
| 4 | 1.807e+03 | 1.816e+03 |
| 5 | 8.422e+01 | 8.395e+01 |
| 6 | 7.425e-02 | 1.261e-01 |
| 7 | -9.657e+04 | 6.838e-02 |
| 8 | -5.290e+06 | -3.163e+03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -346.943 | 35.9212 | 40.0277 | 0.0001 | 1.6238 | 5.2677 |   Inf | -21.4357 | 0.6938 | -0.2906 | -0.9568 | 0.9568 | -0.2906 | 0.00000000 |
| 2 | -346.943 | 35.9482 | 40.0102 | 0.0001 | 1.6262 | 5.2652 |   Inf | -21.4435 | 0.6938 | -0.2915 | -0.9566 | 0.9566 | -0.2915 | 981.88412719 |
| 3 | -346.943 | 35.9461 | 40.0113 | 0.0001 | 1.6261 | 5.2653 |   Inf | -21.4429 | 0.6938 | -0.2914 | -0.9566 | 0.9566 | -0.2914 | 1961.15328161 |
| 4 | -346.943 | 35.9483 | 40.0100 | 0.0001 | 1.6264 | 5.2655 |   Inf | -21.4408 | 0.6938 | -0.2915 | -0.9566 | 0.9566 | -0.2915 | 2221.01968375 |
| 5 | -350.000 | 41.2798 | 33.5072 | 0.0000 | 2.3925 | 5.0112 |   Inf | -17.8142 | 0.7046 | -0.5296 | -0.8482 | 0.8482 | -0.5296 | 87543.63368285 |
| 6 | -350.888 | 25.7537 | 17.5473 | 1.2701 | 2.8357 |   Inf | 3.4234 | -6.2343 | 0.7160 | 0.9893 | 0.1461 | 0.1461 | -0.9893 | 15549.30988980 |
| 7 | -350.888 | 25.7537 | 17.5473 | 1.2701 | 2.8357 |   Inf | 3.4234 | -6.2343 | 0.7160 | 0.9893 | 0.1461 | 0.1461 | -0.9893 | 15549.30988978 |
| 8 | -350.888 | 25.7537 | 17.5473 | 1.2701 | 2.8357 |   Inf | 3.4234 | -6.2343 | 0.7160 | 0.9893 | 0.1461 | 0.1461 | -0.9893 | 15549.30988976 |
| 9 | -350.888 | 25.7537 | 17.5473 | 1.2701 | 2.8357 |   Inf | 3.4234 | -6.2343 | 0.7160 | 0.9893 | 0.1461 | 0.1461 | -0.9893 | 15549.30988982 |
| 10 | -350.888 | 25.7537 | 17.5473 | 1.2701 | 2.8357 |   Inf | 3.4234 | -6.2343 | 0.7160 | 0.9893 | 0.1461 | 0.1461 | -0.9893 | 15549.30988975 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=1961.1533 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.781e+07 | 5.409e+07 |
| 2 | 8.715e+04 | 1.424e+05 |
| 3 | 2.005e+04 | 2.007e+04 |
| 4 | 1.807e+03 | 1.809e+03 |
| 5 | 8.424e+01 | 8.424e+01 |
| 6 | 7.424e-02 | 6.832e-02 |
| 7 | -2.566e+00 | -1.566e-02 |
| 8 | -1.357e+06 | -2.320e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -346.943 | 35.9150 | 40.0326 | 1.6239 | 5.2700 |   Inf | 0.0001 | -21.4221 | 0.6938 | 0.9569 | -0.2904 | 0.2904 | 0.9569 | 0.00000000 |
| 2 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556905 |
| 3 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556906 |
| 4 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556910 |
| 5 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556911 |
| 6 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556906 |
| 7 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556904 |
| 8 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556911 |
| 9 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556905 |
| 10 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 16482.17556907 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.9446, max_pdist=16482.1756 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.568e+06 | 7.281e+07 |
| 2 | 1.133e+05 | 2.242e+05 |
| 3 | 2.003e+04 | 2.005e+04 |
| 4 | 1.806e+03 | 1.807e+03 |
| 5 | 8.422e+01 | 8.423e+01 |
| 6 | 7.411e-02 | 6.813e-02 |
| 7 | -1.669e+05 | -8.726e-03 |
| 8 | -1.437e+07 | -2.148e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -334.303 | 13.4555 | 10.7043 | 10.0468 | 6.0268 | 0.5778 | 0.0001 | 2.2319 | 56078.2225 |   Inf | -1.9095 | 1.0000 | -0.0493 | -0.3290 | -0.9431 | 0.8921 | 0.4100 | -0.1896 | 0.4491 | -0.8507 | 0.2733 | 0.00000000 |
| 2 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774854 |
| 3 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774831 |
| 4 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774844 |
| 5 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774826 |
| 6 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774851 |
| 7 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774841 |
| 8 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774862 |
| 9 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774845 |
| 10 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 6.0157 | 0.5432 | 0.4646 | 2.2399 |   Inf | 33.2463 | -1.9107 | 1.0000 | -0.0453 | -0.3500 | -0.9357 | 0.2922 | -0.9003 | 0.3226 | 0.9553 | 0.2588 | -0.1430 | 8692.14774846 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.7343, max_pdist=8692.1477 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.982e+07 | 4.254e+06 |
| 2 | 1.258e+05 | 4.033e+04 |
| 3 | 4.595e+04 | 1.645e+04 |
| 4 | 9.914e+03 | 1.155e+04 |
| 5 | 6.019e+02 | 3.448e+03 |
| 6 | 4.123e+02 | 1.868e+03 |
| 7 | 1.236e+02 | 5.609e+02 |
| 8 | 1.642e+01 | 3.339e+02 |
| 9 | -9.127e-08 | 1.220e+02 |
| 10 | -5.950e+04 | 1.641e+01 |
| 11 | -2.131e+05 | -1.565e-06 |
| 12 | -1.193e+06 | -3.058e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -347.448 | 21.4297 | 40.3864 |   Inf | 0.0000 | 0.8626 | 5.6869 | -16.5935 | 0.6922 | -0.9260 | 0.3776 | -0.3776 | -0.9260 | 0.00000000 |
| 2 | -347.448 | 21.4350 | 40.3827 |   Inf | 0.0000 | 0.8632 | 5.6860 | -16.5964 | 0.6922 | -0.9259 | 0.3777 | -0.3777 | -0.9259 | 4924.81281029 |
| 3 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391294 |
| 4 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391294 |
| 5 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391294 |
| 6 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391293 |
| 7 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391294 |
| 8 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391295 |
| 9 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391294 |
| 10 | -350.962 | 20.4794 | 20.0971 |   Inf | 2.1628 | 3.1337 | 2.9527 | -11.0574 | 0.6979 | -0.6102 | -0.7922 | 0.7922 | -0.6102 | 26624.51391292 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.5145, max_pdist=26624.5139 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.928e+06 | 4.269e+07 |
| 2 | 1.294e+04 | 2.270e+05 |
| 3 | 6.676e+02 | 1.293e+04 |
| 4 | 2.052e+02 | 6.301e+02 |
| 5 | 8.340e+01 | 8.329e+01 |
| 6 | 1.200e-01 | 1.184e-01 |
| 7 | -6.119e+04 | -1.393e-01 |
| 8 | -8.491e+07 | -4.525e+05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -347.448 | 21.4317 | 40.3853 | 0.8628 | 5.6866 |   Inf | 0.0000 | -16.5950 | 0.6922 | 0.9260 | -0.3776 | 0.3776 | 0.9260 | 0.00000000 |
| 2 | -347.878 | 21.6928 | 40.2725 | 0.9905 | 6.1479 |   Inf | 0.0000 | -14.1731 | 0.6988 | 0.9256 | -0.3784 | 0.3784 | 0.9256 | 2894.00303486 |
| 3 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 4 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 5 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437251 |
| 6 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 7 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 8 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437251 |
| 9 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437251 |
| 10 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0575 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437251 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.5145, max_pdist=27886.0244 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.309e+06 | 8.133e+07 |
| 2 | 2.412e+04 | 1.034e+05 |
| 3 | 1.291e+04 | 1.290e+04 |
| 4 | 6.284e+02 | 6.282e+02 |
| 5 | 8.347e+01 | 8.318e+01 |
| 6 | 1.200e-01 | 1.137e-01 |
| 7 | -8.892e+04 | -7.745e-03 |
| 8 | -5.464e+07 | -2.852e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -347.448 | 21.4374 | 40.3818 | 5.6859 |   Inf | 0.0000 | 0.8635 | -16.5973 | 0.6922 | 0.3778 | 0.9259 | -0.9259 | 0.3778 | 0.00000000 |
| 2 | -347.448 | 21.4373 | 40.3819 | 5.6859 |   Inf | 0.0000 | 0.8635 | -16.5973 | 0.6922 | 0.3778 | 0.9259 | -0.9259 | 0.3778 | 187.19642795 |
| 3 | -347.448 | 21.4357 | 40.3827 | 5.6860 |   Inf | 0.0000 | 0.8633 | -16.5967 | 0.6922 | 0.3777 | 0.9259 | -0.9259 | 0.3777 | 2763.92539321 |
| 4 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154645 |
| 5 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154644 |
| 6 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0575 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154643 |
| 7 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154646 |
| 8 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154645 |
| 9 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154645 |
| 10 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154646 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=2763.9254 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.998e+05 | 1.079e+08 |
| 2 | 1.363e+05 | 1.337e+05 |
| 3 | 1.292e+04 | 1.291e+04 |
| 4 | 6.293e+02 | 6.289e+02 |
| 5 | 8.348e+01 | 8.346e+01 |
| 6 | 1.200e-01 | 1.182e-01 |
| 7 | -1.031e+05 | -3.864e-03 |
| 8 | -7.894e+06 | -4.583e+05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -344.591 | 26.4576 | 35.0368 | 4.9843 | 3.9387 | 0.0000 | 1.6062 | -18.7752 | 0.6975 | 0.5094 | 0.8605 | -0.8605 | 0.5094 | 0.00000000 |
| 2 | -347.448 | 21.4347 | 40.3839 | 5.6865 | 246000809530.3289 | 0.0000 | 0.8632 | -16.5951 | 0.6922 | 0.3777 | 0.9259 | -0.9259 | 0.3777 | 10392.13334724 |
| 3 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831014 |
| 4 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831030 |
| 5 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831017 |
| 6 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831003 |
| 7 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831060 |
| 8 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831013 |
| 9 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831018 |
| 10 | -349.545 | 18.5866 | 15.8821 | 2.5150 | 2.7758 | 1.1958 | 3.1153 | -7.7460 | 0.7135 | 0.9653 | 0.2610 | -0.2610 | 0.9653 | 23649.20831008 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=4.9541, max_pdist=23649.2083 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.496e+08 | 1.251e+08 |
| 2 | 1.035e+06 | 1.080e+06 |
| 3 | 1.475e+04 | 1.476e+04 |
| 4 | 1.171e+03 | 1.171e+03 |
| 5 | 1.099e+02 | 1.097e+02 |
| 6 | 8.301e+01 | 8.301e+01 |
| 7 | 8.472e-02 | 8.516e-02 |
| 8 | -1.346e+04 | -1.178e-01 |
| 9 | -4.872e+06 | -5.040e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -334.987 | 17.2859 | 16.5843 | 7.9060 | 0.4207 |   Inf | 2.4302 | 19.5944 | 0.0050 | 5.7848 | -1.9286 | 1.0000 | 0.9808 | 0.1601 | -0.1113 | -0.1890 | 0.9207 | -0.3414 | 0.0479 | 0.3559 | 0.9333 | 0.00000000 |
| 2 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857212 |
| 3 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857237 |
| 4 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857214 |
| 5 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857200 |
| 6 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857185 |
| 7 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857215 |
| 8 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857208 |
| 9 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857252 |
| 10 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 33.2463 | 2.2399 |   Inf | 0.4646 | 6.0157 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.9553 | -0.2588 | 0.1430 | 0.0453 | 0.3500 | 0.9357 | 198.49857146 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0503, max_pdist=198.4986 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.063e+04 | 1.005e+04 |
| 2 | 5.191e+02 | 5.137e+02 |
| 3 | 4.356e+02 | 4.350e+02 |
| 4 | 5.830e+01 | 1.873e+01 |
| 5 | 2.192e+01 | 1.502e+01 |
| 6 | 1.733e+01 | 4.887e+00 |
| 7 | 6.378e+00 | 2.368e+00 |
| 8 | 1.655e+00 | 5.225e-01 |
| 9 | 9.399e-01 | 1.579e-01 |
| 10 | 5.204e-01 | 6.660e-04 |
| 11 | -3.697e+01 | 2.029e-15 |
| 12 | -1.357e+02 | -2.831e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000000 |
| 2 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000030 |
| 3 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000043 |
| 4 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000139 |
| 5 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000061 |
| 6 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000099 |
| 7 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000122 |
| 8 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000056 |
| 9 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5433 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2464 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00001408 |
| 10 | -335.051 | 16.4345 | 11.1460 | 9.4920 | 0.5406 | 6.0875 | 0.4660 |   Inf | 2.2311 | 12639.9084 | -1.8673 | 1.0000 | 0.2904 | -0.9020 | 0.3195 | -0.0444 | -0.3463 | -0.9371 | 0.9559 | 0.2580 | -0.1406 | 0.06879815 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.544e+03 | 1.585e+03 |
| 2 | 6.211e+02 | 6.218e+02 |
| 3 | 4.610e+02 | 4.649e+02 |
| 4 | 3.574e+02 | 3.473e+02 |
| 5 | 3.587e+01 | 3.042e+01 |
| 6 | 1.650e+01 | 1.584e+01 |
| 7 | 1.224e+01 | 9.667e+00 |
| 8 | 6.852e+00 | 4.176e+00 |
| 9 | 1.804e+00 | 7.123e-01 |
| 10 | 4.433e-01 | 1.569e-01 |
| 11 | 1.657e-01 | 1.353e-01 |
| 12 | 1.116e-01 | 1.089e-01 |

numDeriv::hessian (operative): cond = 13835.8281, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 14555.1364, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: none

Across 11 scanned models: 1 pass Flag A (convergence), 1 pass strict Flag B, 1 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 10 models that fail Flag A: **5** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **5** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 14 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T1_P2_P3, T2_noP, T2_P2_P3, T2_P2, T2_T3_noP, T2_T3_P2, T3_noP, T3_P1, T3_P2_P3)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T2_T3_P3__bd_pd1_sigR1_sigL2`
- **pBIC (Ω):** 741.4
- **logLik:** -335.0511
- **Variables:** T2, T3, P3
- **Free parameters (n_free):** 11
- **Boundary mask:** pd=Inf, sigrtil1=Inf, sigltil2=Inf

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.5005
- **Threshold:** 0.5322
- **Sensitivity:** 0.8955
- **Specificity:** 0.6050
- **Presences / pseudo-absences:** 336 / 319
- **Prevalence:** 0.5122

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | 16.4345, 11.1460, 9.4920 |
| sigltil | 0.4660,   Inf, 2.2311 |
| sigrtil |   Inf, 0.5406, 6.0875 |
| ctil | -1.8673 |
| pd | 1.0000 |
| o_mat | 0.9559, 0.2580, -0.1406, -0.2904, 0.9020, -0.3195, 0.0444, 0.3463, 0.9371 |

### Profile likelihoods and arc check

- **Arc check:** 5/11 parameters pass → **AT LEAST ONE FAILS**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | FAIL | no_right_crossing |
| mu2 | FAIL | no_left_crossing;right_not_monotone |
| mu3 | PASS | pass |
| sigltil1 | PASS | pass |
| sigltil3 | PASS | pass |
| sigrtil2 | FAIL | no_left_crossing |
| sigrtil3 | PASS | pass |
| ctil | PASS | pass |
| o_par1 | FAIL | no_left_crossing;no_right_crossing |
| o_par2 | FAIL | no_right_crossing |
| o_par3 | FAIL | no_left_crossing;no_right_crossing |

## Profile likelihood plots

![Profile likelihood plots for the best model (T2_T3_P3__bd_pd1_sigR1_sigL2)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T2_T3_P3__bd_pd1_sigR1_sigL2` (pBIC = 741.4)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 92
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 03:17:22_

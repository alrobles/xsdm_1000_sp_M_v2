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
- L2 threshold: best L1 + τ = 778.1864
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
| 1 | T2_P3 ≤τ | T2+P3 | 752.2 | -346.943 | 9 | success |
| 2 | T2_T3_P3 ≤τ | T2+T3+P3 | 755.2 | -332.212 | 14 | success |
| 3 | T1_P3 ≤τ | T1+P3 | 757.5 | -349.545 | 9 | success |
| 4 | T2_P1 ≤τ | T2+P1 | 761.3 | -351.457 | 9 | success |
| 5 | T1_P1 ≤τ | T1+P1 | 762.1 | -351.857 | 9 | success |
| 6 | T3_P3 ≤τ | T3+P3 | 763.4 | -352.534 | 9 | success |
| 7 | T1_P2 ≤τ | T1+P2 | 766.8 | -354.224 | 9 | success |
| 8 | T3_P2 ≤τ | T3+P2 | 767.0 | -354.336 | 9 | success |
| 9 | T2_T3_P1 ≤τ | T2+T3+P1 | 774.6 | -341.896 | 14 | success |
| 10 | T3_P2_P3 ≤τ | T3+P2+P3 | 775.9 | -342.557 | 14 | success |
| 11 | T1_P2_P3 ≤τ | T1+P2+P3 | 777.6 | -343.428 | 14 | success |
| 12 | T2_P2_P3 | T2+P2+P3 | 779.2 | -344.203 | 14 | success |
| 13 | T3_P1 | T3+P1 | 779.3 | -360.480 | 9 | success |
| 14 | T2_T3_P2 | T2+T3+P2 | 782.1 | -345.651 | 14 | success |
| 15 | T1_noP | T1 | 791.5 | -379.561 | 5 | success |
| 16 | T2_P2 | T2+P2 | 791.6 | -366.610 | 9 | success |
| 17 | T2_T3_noP | T2+T3 | 796.4 | -369.014 | 9 | success |
| 18 | T2_noP | T2 | 801.6 | -384.590 | 5 | success |
| 19 | T3_noP | T3 | 807.1 | -387.346 | 5 | success |
| 20 | noT_P2_P3 | P2+P3 | 884.8 | -413.223 | 9 | success |
| 21 | noT_P3 | P3 | 892.9 | -430.218 | 5 | success |
| 22 | noT_P2 | P2 | 899.6 | -433.566 | 5 | success |
| 23 | noT_P1 | P1 | 908.9 | -438.250 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 778.2**.
**Eligible L1 models:** 11 (T1_P1, T1_P2_P3, T1_P2, T1_P3, T2_P1, T2_P3, T2_T3_P1, T2_T3_P3, T3_P2_P3, T3_P2, T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_P3__bd_sigL2 | 745.8 | -346.943 | 8 | success |
| T2_P3__bd_sigL1 | 745.8 | -346.943 | 8 | success |
| T2_P3__bd_sigR1 | 745.8 | -346.943 | 8 | success |
| T1_P3__bd_sigR1 | 746.8 | -347.448 | 8 | success |
| T1_P3__bd_sigL2 | 746.8 | -347.448 | 8 | success |
| T2_T3_P3__bd_sigR2 | 747.3 | -331.523 | 13 | success |
| T2_T3_P3__bd_pd1_sigR1 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigL1 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 747.9 | -335.037 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 747.9 | -335.051 | 12 | success |
| T2_T3_P3__bd_sigR3 | 748.7 | -332.213 | 13 | success |
| T2_T3_P3__bd_sigL2 | 749.4 | -332.552 | 13 | success |
| T2_T3_P3__bd_sigR1 | 750.4 | -333.037 | 13 | success |
| T2_T3_P3__bd_sigL1 | 750.5 | -333.098 | 13 | success |
| T2_T3_P3__bd_sigL3 | 750.5 | -333.098 | 13 | success |
| T1_P3__bd_sigL1 | 751.2 | -349.681 | 8 | success |
| T2_P3__bd_sigR2 | 751.9 | -350.000 | 8 | success |
| T2_T3_P3__bd_pd1 | 752.9 | -334.296 | 13 | success |
| T1_P3__bd_sigR2 | 753.8 | -350.962 | 8 | success |
| T1_P3__bd_pd1_sigR1 | 755.3 | -354.947 | 7 | success |
| T1_P3__bd_pd1_sigL1 | 755.3 | -354.947 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 755.3 | -354.947 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 755.3 | -354.947 | 7 | success |
| T2_P1__bd_pd1_sigR1 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_pd1_sigR2 | 756.8 | -355.720 | 7 | success |
| T2_P1__bd_sigL2 | 758.2 | -353.162 | 8 | success |
| T2_P1__bd_sigR2 | 758.2 | -353.162 | 8 | success |
| T2_P1__bd_sigR1 | 758.2 | -353.162 | 8 | success |
| T2_P1__bd_sigL1 | 758.2 | -353.162 | 8 | success |
| T2_P3__bd_pd1_sigR2 | 758.4 | -356.528 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 758.4 | -356.528 | 7 | success |
| T2_P3__bd_pd1_sigL2 | 758.4 | -356.528 | 7 | success |
| T2_P3__bd_pd1_sigR1 | 758.4 | -356.528 | 7 | success |
| T3_P3__bd_sigL2 | 758.7 | -353.393 | 8 | success |
| T3_P3__bd_sigL1 | 758.7 | -353.393 | 8 | success |
| T3_P3__bd_sigR1 | 758.7 | -353.393 | 8 | success |
| T3_P3__bd_sigR2 | 758.7 | -353.393 | 8 | success |
| T2_P3__bd_pd1 | 758.7 | -353.394 | 8 | success |
| T1_P1__bd_pd1_sigR1 | 758.8 | -356.685 | 7 | success |
| T1_P1__bd_pd1_sigL2 | 758.8 | -356.685 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 758.8 | -356.685 | 7 | success |
| T1_P1__bd_pd1_sigL1 | 758.8 | -356.685 | 7 | success |
| T1_P2__bd_sigR1 | 760.4 | -354.281 | 8 | success |
| T1_P2__bd_sigR2 | 760.5 | -354.321 | 8 | success |
| T3_P2__bd_sigR2 | 760.7 | -354.411 | 8 | success |
| T3_P2__bd_sigL1 | 760.7 | -354.414 | 8 | success |
| T3_P2__bd_sigL2 | 760.8 | -354.481 | 8 | success |
| T3_P2__bd_sigR1 | 761.3 | -354.731 | 8 | success |
| T1_P3__bd_pd1 | 761.8 | -354.947 | 8 | success |
| T1_P2_P3__bd_sigL2 | 762.0 | -338.849 | 13 | success |
| T2_P1__bd_pd1 | 762.0 | -355.072 | 8 | success |
| T1_P1__bd_sigR1 | 762.3 | -355.235 | 8 | success |
| T1_P1__bd_sigL1 | 762.3 | -355.235 | 8 | success |
| T1_P1__bd_sigL2 | 762.3 | -355.235 | 8 | success |
| T1_P1__bd_sigR2 | 762.3 | -355.235 | 8 | success |
| T3_P3__bd_pd1 | 763.0 | -355.547 | 8 | success |
| T3_P3__bd_pd1_sigR1 | 763.5 | -359.030 | 7 | success |
| T3_P3__bd_pd1_sigR2 | 763.5 | -359.030 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 763.5 | -359.030 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 763.5 | -359.030 | 7 | success |
| T1_P2_P3__bd_sigR3 | 764.6 | -340.159 | 13 | success |
| T2_T3_P1__bd_pd1_sigR2 | 764.8 | -343.496 | 12 | success |
| T2_T3_P1__bd_pd1_sigL1 | 764.8 | -343.496 | 12 | success |
| T1_P1__bd_pd1 | 764.9 | -356.525 | 8 | success |
| T1_P2__bd_sigL1 | 766.0 | -357.036 | 8 | success |
| T1_P2__bd_sigL2 | 766.0 | -357.036 | 8 | success |
| T2_T3_P1__bd_sigL3 | 766.2 | -340.959 | 13 | success |
| T2_T3_P1__bd_pd1_sigL3 | 766.7 | -344.433 | 12 | success |
| T2_T3_P1__bd_sigR3 | 767.6 | -341.627 | 13 | success |
| T2_T3_P1__bd_pd1_sigL2 | 767.9 | -345.052 | 12 | success |
| T2_T3_P1__bd_pd1_sigR1 | 767.9 | -345.052 | 12 | success |
| T2_T3_P1__bd_sigL2 | 768.1 | -341.905 | 13 | success |
| T2_T3_P1__bd_sigR2 | 768.1 | -341.905 | 13 | success |
| T2_T3_P1__bd_sigL1 | 768.1 | -341.905 | 13 | success |
| T3_P2_P3__bd_sigL1 | 768.4 | -342.073 | 13 | success |
| T1_P2__bd_pd1_sigR2 | 768.5 | -361.576 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 768.5 | -361.576 | 7 | success |
| T1_P2__bd_pd1_sigL1 | 768.5 | -361.576 | 7 | success |
| T1_P2__bd_pd1_sigL2 | 768.5 | -361.576 | 7 | success |
| T3_P2_P3__bd_sigR2 | 769.5 | -342.621 | 13 | success |
| T2_T3_P1__bd_pd1 | 770.7 | -343.215 | 13 | success |
| T2_T3_P1__bd_sigR1 | 771.0 | -343.352 | 13 | success |
| T3_P2_P3__bd_sigL3 | 771.2 | -343.472 | 13 | success |
| T3_P2_P3__bd_sigR1 | 771.3 | -343.476 | 13 | success |
| T3_P2_P3__bd_sigR3 | 771.3 | -343.476 | 13 | success |
| T3_P2_P3__bd_sigL2 | 771.4 | -343.528 | 13 | success |
| T1_P2_P3__bd_sigL1 | 771.5 | -343.593 | 13 | success |
| T1_P2_P3__bd_sigR1 | 771.5 | -343.593 | 13 | success |
| T1_P2_P3__bd_sigR2 | 771.7 | -343.717 | 13 | success |
| T1_P2_P3__bd_sigL3 | 772.2 | -343.956 | 13 | success |
| T2_T3_P1__bd_pd1_sigR3 | 772.3 | -347.258 | 12 | success |
| T3_P2_P3__bd_pd1_sigR3 | 772.4 | -347.291 | 12 | success |
| T3_P2_P3__bd_pd1_sigL3 | 772.4 | -347.291 | 12 | success |
| T3_P2_P3__bd_pd1_sigR2 | 772.4 | -347.291 | 12 | success |
| T3_P2_P3__bd_pd1_sigL1 | 772.4 | -347.291 | 12 | success |
| T3_P2_P3__bd_pd1_sigR1 | 772.4 | -347.291 | 12 | success |
| T3_P2_P3__bd_pd1_sigL2 | 772.4 | -347.291 | 12 | success |
| T1_P2_P3__bd_pd1_sigL2 | 772.6 | -347.384 | 12 | success |
| T1_P2_P3__bd_pd1_sigR3 | 772.6 | -347.385 | 12 | success |
| T1_P2_P3__bd_pd1_sigR1 | 772.6 | -347.385 | 12 | success |
| T1_P2_P3__bd_pd1_sigL1 | 772.6 | -347.385 | 12 | success |
| T1_P2_P3__bd_pd1_sigR2 | 772.6 | -347.388 | 12 | success |
| T1_P2_P3__bd_pd1_sigL3 | 774.1 | -348.133 | 12 | success |
| T3_P2__bd_pd1_sigR2 | 774.8 | -364.696 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 774.8 | -364.696 | 7 | success |
| T3_P2__bd_pd1_sigL2 | 774.8 | -364.696 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 774.8 | -364.696 | 7 | success |
| T1_P2__bd_pd1 | 775.0 | -361.576 | 8 | success |
| T3_P2_P3__bd_pd1 | 778.7 | -347.205 | 13 | success |
| T1_P2_P3__bd_pd1 | 779.1 | -347.385 | 13 | success |
| T3_P2__bd_pd1 | 781.2 | -364.666 | 8 | success |
| T2_P2__bd_pd1 | 785.1 | -366.610 | 8 | success |
| T2_T3_noP__bd_pd1 | 789.9 | -369.021 | 8 | success |
| T2_noP__bd_pd1 | 795.1 | -384.590 | 4 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_pd1_sigR1_sigR3 | 741.4 | yes ✓ | ✓ | ✓ | 1.06e+04 | 3 |
| 2 | T2_T3_P3__bd_pd1_sigR1_sigL2 | 741.4 | yes ✓ | ✓ | ✓ | 5.25e+04 | 5 |
| 3 | T2_P3__bd_sigL2 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 4 | T2_P3__bd_sigL1 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 5 | T2_P3__bd_sigR1 | 745.8 | no | ✗ | ✗ | Inf | 1 |
| 6 | T1_P3__bd_sigR1 | 746.8 | no | ✗ | ✗ | Inf | 1 |
| 7 | T1_P3__bd_sigL2 | 746.8 | no | ✗ | ✗ | Inf | 1 |
| 8 | T2_T3_P3__bd_sigR2 | 747.3 | no | ✗ | ✗ | Inf | 1 |
| 9 | T2_T3_P3__bd_pd1_sigR1 | 747.9 | yes ✓ | ✓ | ✓ | 1.38e+04 | 8 |
| 10 | T2_T3_P3__bd_pd1_sigL1 | 747.9 | no | ✓ | ✗ | Inf | 3 |
| 11 | T2_T3_P3__bd_pd1_sigL3 | 747.9 | no | ✗ | ✓ | 1.37e+05 | 1 |
| 12 | T2_T3_P3__bd_pd1_sigL2 | 747.9 | yes ✓ | ✓ | ✓ | 9.62e+04 | 3 |
| 13 | T2_T3_P3__bd_pd1_sigR3 | 747.9 | no | ✓ | ✗ | Inf | 4 |
| 14 | T2_T3_P3__bd_pd1_sigR2 | 747.9 | no | ✓ | ✗ | Inf | 5 |
| 15 | T2_T3_P3__bd_sigR3 | 748.7 | no | ✗ | ✗ | Inf | 1 |
| 16 | T2_T3_P3__bd_sigL2 | 749.4 | no | ✗ | ✗ | Inf | 1 |
| 17 | T2_T3_P3__bd_sigR1 | 750.4 | no | ✗ | ✗ | Inf | 1 |
| 18 | T2_T3_P3__bd_sigL1 | 750.5 | no | ✗ | ✗ | Inf | 1 |
| 19 | T2_T3_P3__bd_sigL3 | 750.5 | no | ✗ | ✗ | Inf | 1 |
| 20 | T1_P3__bd_sigL1 | 751.2 | no | ✗ | ✗ | Inf | 1 |
| 21 | T2_T3_P3__bd_pd1_sigR1_sigL2_sigR3 | 751.8 | no | ✗ | ✗ | Inf | 1 |
| 22 | T2_P3__bd_sigR2 | 751.9 | no | ✗ | ✗ | Inf | 1 |
| 23 | T2_P3 | 752.2 | no | ✗ | ✗ | Inf | 1 |
| 24 | T2_T3_P3__bd_pd1 | 752.9 | no | ✗ | ✗ | Inf | 1 |
| 25 | T1_P3__bd_sigR2 | 753.8 | yes ✓ | ✓ | ✓ | 1.04e+05 | 11 |
| 26 | T2_T3_P3 | 755.2 | no | ✗ | ✗ | Inf | 1 |
| 27 | T1_P3__bd_pd1_sigR1 | 755.3 | yes ✓ | ✓ | ✓ | 2.77e+04 | 4 |
| 28 | T1_P3__bd_pd1_sigL1 | 755.3 | yes ✓ | ✓ | ✓ | 2.43e+04 | 6 |
| 29 | T1_P3__bd_pd1_sigL2 | 755.3 | yes ✓ | ✓ | ✓ | 3.39e+04 | 11 |
| 30 | T1_P3__bd_pd1_sigR2 | 755.3 | yes ✓ | ✓ | ✓ | 3.84e+04 | 6 |
| 31 | T2_P1__bd_pd1_sigR1 | 756.8 | yes ✓ | ✓ | ✓ | 1.02e+03 | 6 |
| 32 | T2_P1__bd_pd1_sigL1 | 756.8 | yes ✓ | ✓ | ✓ | 9.94e+02 | 6 |
| 33 | T2_P1__bd_pd1_sigL2 | 756.8 | yes ✓ | ✓ | ✓ | 9.99e+02 | 8 |
| 34 | T2_P1__bd_pd1_sigR2 | 756.8 | yes ✓ | ✓ | ✓ | 9.97e+02 | 5 |
| 35 | T1_P3 | 757.5 | yes ✓ | ✓ | ✓ | 2.86e+04 | 3 |
| 36 | T2_P1__bd_sigL2 | 758.2 | yes ✓ | ✓ | ✓ | 5.14e+04 | 6 |
| 37 | T2_P1__bd_sigR2 | 758.2 | yes ✓ | ✓ | ✓ | 2.72e+04 | 4 |
| 38 | T2_P1__bd_sigR1 | 758.2 | yes ✓ | ✓ | ✓ | 1.70e+04 | 6 |
| 39 | T2_P1__bd_sigL1 | 758.2 | no | ✗ | ✓ | 1.43e+04 | 2 |
| 40 | T2_P3__bd_pd1_sigR2 | 758.4 | yes ✓ | ✓ | ✓ | 4.87e+03 | 7 |
| 41 | T2_P3__bd_pd1_sigL1 | 758.4 | yes ✓ | ✓ | ✓ | 4.85e+03 | 8 |
| 42 | T2_P3__bd_pd1_sigL2 | 758.4 | yes ✓ | ✓ | ✓ | 4.79e+03 | 6 |
| 43 | T2_P3__bd_pd1_sigR1 | 758.4 | yes ✓ | ✓ | ✓ | 4.85e+03 | 8 |
| 44 | T3_P3__bd_sigL2 | 758.7 | yes ✓ | ✓ | ✓ | 7.58e+04 | 7 |
| 45 | T3_P3__bd_sigL1 | 758.7 | no | ✓ | ✗ | Inf | 11 |
| 46 | T3_P3__bd_sigR1 | 758.7 | yes ✓ | ✓ | ✓ | 5.50e+04 | 10 |
| 47 | T3_P3__bd_sigR2 | 758.7 | no | ✓ | ✗ | 3.15e+06 | 11 |
| 48 | T2_P3__bd_pd1 | 758.7 | yes ✓ | ✓ | ✓ | 5.65e+03 | 15 |
| 49 | T1_P1__bd_pd1_sigR1 | 758.8 | yes ✓ | ✓ | ✓ | 7.64e+05 | 4 |
| 50 | T1_P1__bd_pd1_sigL2 | 758.8 | yes ✓ | ✓ | ✓ | 7.61e+05 | 6 |
| 51 | T1_P1__bd_pd1_sigR2 | 758.8 | yes ✓ | ✓ | ✓ | 7.59e+05 | 6 |
| 52 | T1_P1__bd_pd1_sigL1 | 758.8 | yes ✓ | ✓ | ✓ | 7.90e+05 | 4 |
| 53 | T1_P2__bd_sigR1 | 760.4 | no | ✗ | ✗ | Inf | 1 |
| 54 | T1_P2__bd_sigR2 | 760.5 | no | ✗ | ✗ | Inf | 1 |
| 55 | T3_P2__bd_sigR2 | 760.7 | no | ✗ | ✗ | Inf | 1 |
| 56 | T3_P2__bd_sigL1 | 760.7 | no | ✗ | ✗ | Inf | 1 |
| 57 | T3_P2__bd_sigL2 | 760.8 | no | ✗ | ✗ | Inf | 1 |
| 58 | T2_P1 | 761.3 | no | ✗ | ✗ | Inf | 2 |
| 59 | T3_P2__bd_sigR1 | 761.3 | no | ✗ | ✗ | Inf | 1 |
| 60 | T1_P3__bd_pd1 | 761.8 | no | ✓ | ✗ | Inf | 13 |
| 61 | T1_P2_P3__bd_sigL2 | 762.0 | no | ✗ | ✗ | Inf | 1 |
| 62 | T2_P1__bd_pd1 | 762.0 | yes ✓ | ✓ | ✓ | 1.56e+03 | 25 |
| 63 | T1_P1 | 762.1 | no | ✓ | ✗ | 4.25e+06 | 13 |
| 64 | T1_P1__bd_sigR1 | 762.3 | no | ✓ | ✗ | 2.26e+06 | 7 |
| 65 | T1_P1__bd_sigL1 | 762.3 | no | ✗ | ✗ | 4.75e+06 | 2 |
| 66 | T1_P1__bd_sigL2 | 762.3 | no | ✗ | ✗ | Inf | 1 |
| 67 | T1_P1__bd_sigR2 | 762.3 | no | ✓ | ✗ | Inf | 3 |
| 68 | T3_P3__bd_pd1 | 763.0 | yes ✓ | ✓ | ✓ | 2.40e+04 | 25 |
| 69 | T3_P3 | 763.4 | yes ✓ | ✓ | ✓ | 1.26e+05 | 20 |
| 70 | T3_P3__bd_pd1_sigR1 | 763.5 | yes ✓ | ✓ | ✓ | 1.19e+04 | 14 |
| 71 | T3_P3__bd_pd1_sigR2 | 763.5 | yes ✓ | ✓ | ✓ | 1.17e+04 | 10 |
| 72 | T3_P3__bd_pd1_sigL2 | 763.5 | yes ✓ | ✓ | ✓ | 1.21e+04 | 12 |
| 73 | T3_P3__bd_pd1_sigL1 | 763.5 | yes ✓ | ✓ | ✓ | 1.17e+04 | 13 |
| 74 | T1_P2_P3__bd_sigR3 | 764.6 | no | ✗ | ✗ | Inf | 1 |
| 75 | T2_T3_P1__bd_pd1_sigR2 | 764.8 | no | ✓ | ✗ | Inf | 3 |
| 76 | T2_T3_P1__bd_pd1_sigL1 | 764.8 | no | ✗ | ✗ | Inf | 1 |
| 77 | T1_P1__bd_pd1 | 764.9 | yes ✓ | ✓ | ✓ | 8.14e+05 | 14 |
| 78 | T1_P2__bd_sigL1 | 766.0 | no | ✓ | ✗ | Inf | 4 |
| 79 | T1_P2__bd_sigL2 | 766.0 | no | ✗ | ✗ | Inf | 2 |
| 80 | T2_T3_P1__bd_sigL3 | 766.2 | no | ✗ | ✗ | Inf | 1 |
| 81 | T2_T3_P1__bd_pd1_sigL3 | 766.7 | no | ✗ | ✗ | Inf | 1 |
| 82 | T1_P2 | 766.8 | no | ✗ | ✗ | Inf | 1 |
| 83 | T3_P2 | 767.0 | no | ✗ | ✗ | Inf | 1 |
| 84 | T2_T3_P1__bd_sigR3 | 767.6 | no | ✗ | ✗ | Inf | 1 |
| 85 | T2_T3_P1__bd_pd1_sigL2 | 767.9 | no | ✗ | ✗ | Inf | 1 |
| 86 | T2_T3_P1__bd_pd1_sigR1 | 767.9 | no | ✗ | ✗ | Inf | 1 |
| 87 | T2_T3_P1__bd_sigL2 | 768.1 | no | ✓ | ✗ | Inf | 3 |
| 88 | T2_T3_P1__bd_sigR2 | 768.1 | no | ✗ | ✗ | Inf | 2 |
| 89 | T2_T3_P1__bd_sigL1 | 768.1 | no | ✗ | ✗ | Inf | 1 |
| 90 | T3_P2_P3__bd_sigL1 | 768.4 | no | ✗ | ✗ | Inf | 1 |
| 91 | T1_P2__bd_pd1_sigR2 | 768.5 | yes ✓ | ✓ | ✓ | 4.42e+04 | 4 |
| 92 | T1_P2__bd_pd1_sigR1 | 768.5 | yes ✓ | ✓ | ✓ | 4.70e+04 | 4 |
| 93 | T1_P2__bd_pd1_sigL1 | 768.5 | yes ✓ | ✓ | ✓ | 4.70e+04 | 5 |
| 94 | T1_P2__bd_pd1_sigL2 | 768.5 | no | ✓ | ✗ | Inf | 5 |
| 95 | T3_P2_P3__bd_sigR2 | 769.5 | no | ✗ | ✗ | Inf | 1 |
| 96 | T2_T3_P1__bd_pd1 | 770.7 | no | ✓ | ✗ | Inf | 5 |
| 97 | T2_T3_P1__bd_sigR1 | 771.0 | no | ✗ | ✗ | Inf | 2 |
| 98 | T3_P2_P3__bd_sigL3 | 771.2 | no | ✗ | ✗ | Inf | 1 |
| 99 | T3_P2_P3__bd_sigR1 | 771.3 | no | ✓ | ✗ | Inf | 3 |
| 100 | T3_P2_P3__bd_sigR3 | 771.3 | no | ✗ | ✗ | Inf | 1 |
| 101 | T3_P2_P3__bd_sigL2 | 771.4 | no | ✗ | ✗ | Inf | 1 |
| 102 | T1_P2_P3__bd_sigL1 | 771.5 | no | ✗ | ✗ | Inf | 2 |
| 103 | T1_P2_P3__bd_sigR1 | 771.5 | no | ✗ | ✗ | 2.40e+06 | 1 |
| 104 | T1_P2_P3__bd_sigR2 | 771.7 | no | ✗ | ✗ | Inf | 1 |
| 105 | T1_P2_P3__bd_sigL3 | 772.2 | no | ✗ | ✗ | Inf | 1 |
| 106 | T2_T3_P1__bd_pd1_sigR3 | 772.3 | no | ✗ | ✗ | Inf | 2 |
| 107 | T3_P2_P3__bd_pd1_sigR3 | 772.4 | no | ✗ | ✗ | Inf | 2 |
| 108 | T3_P2_P3__bd_pd1_sigL3 | 772.4 | no | ✓ | ✗ | Inf | 7 |
| 109 | T3_P2_P3__bd_pd1_sigR2 | 772.4 | yes ✓ | ✓ | ✓ | 7.52e+04 | 7 |
| 110 | T3_P2_P3__bd_pd1_sigL1 | 772.4 | yes ✓ | ✓ | ✓ | 6.52e+04 | 7 |
| 111 | T3_P2_P3__bd_pd1_sigR1 | 772.4 | no | ✗ | ✗ | Inf | 1 |
| 112 | T3_P2_P3__bd_pd1_sigL2 | 772.4 | no | ✗ | ✓ | 9.79e+04 | 2 |
| 113 | T1_P2_P3__bd_pd1_sigL2 | 772.6 | no | ✗ | ✗ | Inf | 1 |
| 114 | T1_P2_P3__bd_pd1_sigR3 | 772.6 | no | ✗ | ✗ | Inf | 1 |
| 115 | T1_P2_P3__bd_pd1_sigR1 | 772.6 | no | ✗ | ✗ | Inf | 1 |
| 116 | T1_P2_P3__bd_pd1_sigL1 | 772.6 | no | ✗ | ✗ | Inf | 1 |
| 117 | T1_P2_P3__bd_pd1_sigR2 | 772.6 | no | ✗ | ✗ | Inf | 1 |
| 118 | T1_P2_P3__bd_pd1_sigL3 | 774.1 | no | ✓ | ✗ | Inf | 3 |
| 119 | T2_T3_P1 | 774.6 | no | ✗ | ✗ | Inf | 1 |
| 120 | T3_P2__bd_pd1_sigR2 | 774.8 | yes ✓ | ✓ | ✓ | 1.02e+05 | 6 |
| 121 | T3_P2__bd_pd1_sigR1 | 774.8 | yes ✓ | ✓ | ✓ | 1.09e+05 | 3 |
| 122 | T3_P2__bd_pd1_sigL2 | 774.8 | yes ✓ | ✓ | ✓ | 1.19e+05 | 3 |
| 123 | T3_P2__bd_pd1_sigL1 | 774.8 | no | ✗ | ✓ | 1.04e+05 | 1 |
| 124 | T1_P2__bd_pd1 | 775.0 | no | ✓ | ✗ | 1.57e+12 | 22 |
| 125 | T3_P2_P3 | 775.9 | no | ✗ | ✗ | Inf | 1 |
| 126 | T1_P2_P3 | 777.6 | no | ✗ | ✗ | Inf | 1 |
| 127 | T3_P2_P3__bd_pd1 | 778.7 | no | ✓ | ✗ | Inf | 9 |
| 128 | T1_P2_P3__bd_pd1 | 779.1 | no | ✗ | ✗ | Inf | 1 |
| 129 | T2_P2_P3 | 779.2 | no | ✗ | ✗ | Inf | 1 |
| 130 | T3_P1 | 779.3 | no | ✗ | ✗ | Inf | 1 |
| 131 | T3_P2__bd_pd1 | 781.2 | yes ✓ | ✓ | ✓ | 9.61e+05 | 11 |
| 132 | T2_T3_P2 | 782.1 | no | ✗ | ✗ | Inf | 1 |
| 133 | T2_P2__bd_pd1 | 785.1 | no | ✓ | ✗ | 5.07e+16 | 23 |
| 134 | T2_T3_noP__bd_pd1 | 789.9 | no | ✗ | ✗ | Inf | 1 |
| 135 | T1_noP | 791.5 | yes ✓ | ✓ | ✓ | 7.88e+03 | 23 |
| 136 | T2_P2 | 791.6 | no | ✓ | ✗ | Inf | 14 |
| 137 | T2_noP__bd_pd1 | 795.1 | no | ✓ | ✗ | 1.47e+12 | 25 |
| 138 | T2_T3_noP | 796.4 | no | ✗ | ✗ | Inf | 1 |
| 139 | T2_noP | 801.6 | no | ✓ | ✗ | Inf | 25 |
| 140 | T3_noP | 807.1 | no | ✓ | ✗ | Inf | 20 |
| 141 | noT_P2_P3 | 884.8 | no | ✗ | ✗ | Inf | 1 |
| 142 | noT_P3 | 892.9 | no | ✗ | ✗ | 3.47e+07 | 1 |
| 143 | noT_P2 | 899.6 | no | ✗ | ✗ | 1.08e+20 | 1 |
| 144 | noT_P1 | 908.9 | no | ✗ | ✗ | Inf | 1 |
| 145 | T2_T3_P3__bd_pd1_sigL01_sigR1_sigL2_sigR3 | NA | (not scanned) | — | — | — | — |
| 146 | T2_T3_P3__bd_pd1_sigL01_sigR1_sigL2 | NA | (not scanned) | — | — | — | — |
| 147 | T2_T3_P3__bd_pd1_sigL01_sigR1_sigR3 | NA | (not scanned) | — | — | — | — |
| 148 | T2_T3_P3__bd_pd1_sigL01_sigR1 | NA | (not scanned) | — | — | — | — |
| 149 | T2_T3_P3__bd_pd1_sigR1_sigL2_sigR02 | NA | (not scanned) | — | — | — | — |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T2_T3_P3__bd_pd1_sigR1_sigL2` — **Ω = 741.4**

## L3 supplementary appendices — per-model diagnostics

### T2_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -346.943 | 35.9311 | 40.0238 | 5.2677 |   Inf | 0.0000 | 1.6251 | -21.4349 | 0.6938 | 0.2908 | 0.9568 | -0.9568 | 0.2908 | 0.00000000 |
| 2 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377239 |
| 3 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377240 |
| 4 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377235 |
| 5 | -350.888 | 25.7537 | 17.5473 |   Inf | 3.4234 | 1.2701 | 2.8357 | -6.2343 | 0.7160 | -0.9893 | -0.1461 | -0.1461 | 0.9893 | 32126.10377234 |
| 6 | -352.717 | 420.4826 | 818.7214 |   Inf |   Inf | 1.6212 | 26.1439 | -595.1694 | 0.6851 | -0.8986 | 0.4387 | -0.4387 | -0.8986 | 32143.11868395 |
| 7 | -352.721 | 367.9259 | 710.0622 |   Inf | 2293939720156351430310804939784706578781560448908097377326747342602240.0000 | 1.6235 | 24.3246 | -515.8343 | 0.6851 | -0.8984 | 0.4392 | -0.4392 | -0.8984 | 32138.76656273 |
| 8 | -352.731 | 285.8626 | 547.9229 | 2675850566968660119538297811474154111720439540087708900507520132195309915780814531373911950952455840267083214160396288.0000 |   Inf | 1.6186 | 21.3297 | -395.1279 | 0.6851 | -0.9002 | 0.4354 | -0.4354 | -0.9002 | 32133.41981158 |
| 9 | -352.732 | 286.7270 | 525.4510 | 9656269865975630141930982372725478634978604320192274453652017346167387667453000257913639159594809892290283138721221600795253896988709551012118252551667712.0000 |   Inf | 1.6477 | 20.8312 | -387.3372 | 0.6854 | -0.8921 | 0.4518 | -0.4518 | -0.8921 | 32133.00047329 |
| 10 | -352.733 | 274.8477 | 505.1279 | 42453134031355532828347097614704015261369549451032460324110545279496109845458512734141664896156944039936.0000 |   Inf | 1.6442 | 20.4231 | -370.9841 | 0.6854 | -0.8933 | 0.4495 | -0.4495 | -0.8933 | 32132.42600177 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.9447, max_pdist=32126.1038 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

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
| 1 | -346.943 | 35.9459 | 40.0133 |   Inf | 0.0000 | 1.6260 | 5.2656 | -21.4429 | 0.6938 | -0.9566 | 0.2914 | -0.2914 | -0.9566 | 0.00000000 |
| 2 | -346.943 | 35.9546 | 40.0074 |   Inf | 0.0000 | 1.6267 | 5.2645 | -21.4481 | 0.6938 | -0.9565 | 0.2916 | -0.2916 | -0.9565 | 4895.40612136 |
| 3 | -346.943 | 35.9496 | 40.0102 |   Inf | 0.0001 | 1.6263 | 5.2650 | -21.4455 | 0.6938 | -0.9566 | 0.2915 | -0.2915 | -0.9566 | 12238.03900292 |
| 4 | -346.943 | 35.9465 | 40.0123 |   Inf | 0.0001 | 1.6261 | 5.2652 | -21.4455 | 0.6938 | -0.9566 | 0.2914 | -0.2914 | -0.9566 | 14243.21852836 |
| 5 | -346.943 | 35.9292 | 40.0172 |   Inf | 0.0002 | 1.6250 | 5.2673 | -21.4290 | 0.6938 | -0.9567 | 0.2909 | -0.2909 | -0.9567 | 26657.98221735 |
| 6 | -347.584 | 38.2796 | 37.9928 |   Inf | 0.0000 | 1.9538 | 5.3294 | -19.3128 | 0.7003 | -0.9283 | 0.3718 | -0.3718 | -0.9283 | 11620.84031632 |
| 7 | -350.888 | 25.7537 | 17.5473 | 3.4234 | 1.2701 | 2.8357 |   Inf | -6.2343 | 0.7160 | -0.1461 | 0.9893 | 0.9893 | 0.1461 | 32026.10893501 |
| 8 | -350.888 | 25.7537 | 17.5473 | 3.4234 | 1.2701 | 2.8357 |   Inf | -6.2343 | 0.7160 | -0.1461 | 0.9893 | 0.9893 | 0.1461 | 32026.10893503 |
| 9 | -352.717 | 418.0743 | 785.9240 |   Inf | 1.6440 | 25.5707 | 4476604327376415797636264441986785533505317407612281124908940065072766771422149507222009807182882305257655837952606396681938838675312687890389424329155710979880736284794801561134380090163251705903316992.0000 | -580.8019 | 0.6854 | -0.4513 | -0.8924 | 0.8924 | -0.4513 | 32042.12179205 |
| 10 | -352.722 | 360.4091 | 696.1259 | 152023951407237897587885481243057624554328788094137656315308296177623217447950616283587956000954357700126921012048665405070493897672123559186326926367572973884828773515264.0000 | 1.6216 | 24.0759 |   Inf | -505.4403 | 0.6851 | -0.4385 | -0.8988 | 0.8988 | -0.4385 | 32038.28580956 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=12238.0390 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.644e+05 | 3.361e+08 |
| 2 | 4.220e+04 | 4.771e+05 |
| 3 | 2.005e+04 | 2.008e+04 |
| 4 | 1.809e+03 | 1.809e+03 |
| 5 | 8.422e+01 | 8.420e+01 |
| 6 | 7.397e-02 | 6.822e-02 |
| 7 | -3.765e+05 | -2.167e+00 |
| 8 | -3.049e+07 | -1.234e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -346.943 | 35.9190 | 40.0305 | 1.6242 | 5.2694 |   Inf | 0.0001 | -21.4257 | 0.6938 | 0.9569 | -0.2905 | 0.2905 | 0.9569 | 0.00000000 |
| 2 | -346.943 | 35.9516 | 40.0080 | 1.6264 | 5.2645 |   Inf | 0.0001 | -21.4474 | 0.6938 | 0.9566 | -0.2916 | 0.2916 | 0.9566 | 4984.94423604 |
| 3 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 18934.47017443 |
| 4 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 18934.47017448 |
| 5 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 18934.47017444 |
| 6 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 18934.47017441 |
| 7 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 18934.47017439 |
| 8 | -350.888 | 25.7537 | 17.5473 | 2.8357 |   Inf | 3.4234 | 1.2701 | -6.2343 | 0.7160 | 0.1461 | -0.9893 | -0.9893 | -0.1461 | 18934.47017445 |
| 9 | -352.729 | 298.3174 | 568.1574 | 21.7133 | 11694397830528774804014927288924087480161373779055017636652286849263336865126420199679250370148053136651342364455105818210308626761876614411812196449214640961870997644539562088154158703609795210938704747190746622617192547483648.0000 |   Inf | 1.6242 | -411.9345 | 0.6851 | 0.4389 | 0.8985 | -0.8985 | 0.4389 | 18947.82545006 |
| 10 | -352.729 | 298.2589 | 569.7268 | 21.7498 |   Inf | 435270451960324469219157998426341877778318530445312.0000 | 1.6225 | -412.3873 | 0.6851 | 0.4378 | 0.8991 | -0.8991 | 0.4378 | 18947.87710820 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.9446, max_pdist=18934.4702 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.830e+06 | 9.276e+07 |
| 2 | 1.405e+05 | 4.924e+05 |
| 3 | 2.004e+04 | 2.005e+04 |
| 4 | 1.806e+03 | 1.808e+03 |
| 5 | 8.422e+01 | 8.423e+01 |
| 6 | 7.408e-02 | 6.812e-02 |
| 7 | -2.181e+05 | -4.409e-02 |
| 8 | -5.115e+07 | -1.997e+06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -347.448 | 21.4317 | 40.3853 | 0.8628 | 5.6866 |   Inf | 0.0000 | -16.5950 | 0.6922 | 0.9260 | -0.3776 | 0.3776 | 0.9260 | 0.00000000 |
| 2 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 3 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 4 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 5 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437251 |
| 6 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 7 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437253 |
| 8 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |
| 9 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437251 |
| 10 | -350.962 | 20.4794 | 20.0971 | 3.1337 | 2.9527 |   Inf | 2.1628 | -11.0574 | 0.6979 | 0.6102 | 0.7922 | -0.7922 | 0.6102 | 27886.02437252 |

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
| 2 | -347.448 | 21.4360 | 40.3822 | 5.6859 |   Inf | 0.0000 | 0.8633 | -16.5969 | 0.6922 | 0.3777 | 0.9259 | -0.9259 | 0.3777 | 5740.54429661 |
| 3 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154644 |
| 4 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154645 |
| 5 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0575 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154643 |
| 6 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154646 |
| 7 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154644 |
| 8 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154644 |
| 9 | -350.962 | 20.4794 | 20.0971 | 2.9527 |   Inf | 2.1628 | 3.1337 | -11.0574 | 0.6979 | -0.7922 | 0.6102 | -0.6102 | -0.7922 | 28637.27154644 |
| 10 | -351.841 | 11.4503 | 19.7006 |   Inf | 3.5935 | 0.7015 | 2.5841 | -5.1286 | 0.7401 | -0.9808 | 0.1948 | 0.1948 | 0.9808 | 28636.31209454 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.5145, max_pdist=28637.2715 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

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

### T2_T3_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -331.523 | 27.9935 | 15.0441 | 37.9311 | 852.3405 | 1.0019 | 0.0000 | 0.0226 |   Inf | 4.9764 | -18.0793 | 0.7029 | -0.4141 | 0.9100 | 0.0186 | 0.8019 | 0.3744 | -0.4656 | -0.4306 | -0.1779 | -0.8848 | 0.00000000 |
| 2 | -333.037 | 17.7426 | 18.0605 | 12.8508 | 12.1797 | 2.4659 | 0.0020 | 0.4537 | 3.1056 |   Inf | -5.2691 | 0.7579 | -0.9757 | -0.1665 | 0.1427 | -0.0746 | -0.3597 | -0.9301 | 0.2062 | -0.9181 | 0.3385 | 83984.28363544 |
| 3 | -333.344 | 15.6145 | 11.4830 | 15.0995 | 181.6466 | 2.6842 | 0.2666 | 0.4808 | 2.9128 |   Inf | -5.1134 | 0.7587 | -0.9157 | -0.3448 | 0.2065 | -0.0856 | -0.3348 | -0.9384 | 0.3927 | -0.8769 | 0.2770 | 84473.03291113 |
| 4 | -333.344 | 15.6150 | 11.4832 | 15.0996 |   Inf | 2.6848 | 0.2665 | 0.4808 | 2.9126 | 358050.5198 | -5.1120 | 0.7587 | -0.9157 | -0.3448 | 0.2065 | -0.0856 | -0.3346 | -0.9384 | 0.3927 | -0.8770 | 0.2769 | 84473.03093137 |
| 5 | -333.344 | 15.6150 | 11.4832 | 15.0997 |   Inf | 2.6848 | 0.2665 | 0.4808 | 2.9126 | 148075.0731 | -5.1120 | 0.7587 | -0.9157 | -0.3448 | 0.2065 | -0.0856 | -0.3346 | -0.9384 | 0.3927 | -0.8770 | 0.2769 | 84473.03090959 |
| 6 | -333.344 | 15.6150 | 11.4832 | 15.0997 |   Inf | 2.6848 | 0.2665 | 0.4808 | 2.9126 | 37530.4428 | -5.1120 | 0.7587 | -0.9157 | -0.3448 | 0.2065 | -0.0856 | -0.3346 | -0.9384 | 0.3927 | -0.8770 | 0.2769 | 84473.03090837 |
| 7 | -341.056 | 34.5133 | 17.3025 | 36.5950 |   Inf | 4.6656 | 0.0000 | 1.3870 | 1122203.3428 | 1564686.5370 | -21.2778 | 0.6946 | -0.8115 | -0.2036 | 0.5478 | 0.5375 | 0.1079 | 0.8363 | 0.2294 | -0.9731 | -0.0219 | 10706.71315022 |
| 8 | -341.163 | 21.9350 | -4.0949 | 20.8268 |   Inf | 2.2934 | 0.3814 | 0.5705 | 3.0442 | 1.0730 | -7.4619 | 0.7341 | -0.3217 | -0.8896 | 0.3241 | -0.0568 | -0.3236 | -0.9445 | 0.9451 | -0.3223 | 0.0536 | 84474.16133698 |
| 9 | -341.163 | 21.9350 | -4.0949 | 20.8268 |   Inf | 2.2934 | 0.3814 | 0.5705 | 3.0442 | 1.0730 | -7.4619 | 0.7341 | -0.3217 | -0.8896 | 0.3241 | -0.0568 | -0.3236 | -0.9445 | 0.9451 | -0.3223 | 0.0536 | 84474.16133763 |
| 10 | -341.171 | 23.6350 | 16.7829 | 22.3180 | 51.6635 | 3.3946 | 0.0001 | 1.3111 |   Inf | 934.5936 | -9.7362 | 0.6995 | -0.8738 | -0.2021 | 0.4423 | 0.4087 | 0.1877 | 0.8932 | 0.2635 | -0.9612 | 0.0814 | 76000.16426181 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.8207, max_pdist=84473.0329 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.067e+09 | 1.088e+09 |
| 2 | 1.014e+08 | 8.782e+06 |
| 3 | 1.677e+07 | 1.282e+04 |
| 4 | 4.535e+06 | 8.662e+01 |
| 5 | 1.280e+04 | 2.108e+01 |
| 6 | 6.883e+02 | 1.858e+01 |
| 7 | 8.479e+01 | 4.732e+00 |
| 8 | 1.993e+01 | 2.848e-04 |
| 9 | 8.994e-02 | -1.929e+01 |
| 10 | 3.179e-04 | -4.101e+04 |
| 11 | -7.779e+05 | -2.284e+05 |
| 12 | -2.862e+07 | -2.001e+07 |
| 13 | -3.624e+07 | -3.202e+08 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 5, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000000 |
| 2 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000128 |
| 3 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000088 |
| 4 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000030 |
| 5 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000160 |
| 6 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000123 |
| 7 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000030 |
| 8 | -335.037 | 16.4022 | 11.1371 | 9.5177 | 0.5432 | 6.0157 | 0.4646 |   Inf | 2.2399 | 33.2463 | -1.9107 | 1.0000 | 0.2922 | -0.9003 | 0.3226 | -0.0453 | -0.3500 | -0.9357 | 0.9553 | 0.2588 | -0.1430 | 0.00000122 |
| 9 | -335.051 | 16.4345 | 11.1460 | 9.4920 | 0.5406 | 6.0875 | 0.4660 |   Inf | 2.2311 | 1156484.1729 | -1.8673 | 1.0000 | 0.2904 | -0.9020 | 0.3195 | -0.0444 | -0.3463 | -0.9371 | 0.9559 | 0.2580 | -0.1406 | 0.06883290 |
| 10 | -335.051 | 16.4345 | 11.1460 | 9.4920 | 0.5406 | 6.0875 | 0.4660 | 1119282178.9692 | 2.2311 |   Inf | -1.8673 | 1.0000 | 0.2904 | -0.9020 | 0.3195 | -0.0444 | -0.3463 | -0.9371 | 0.9559 | 0.2580 | -0.1406 | 0.06883289 |

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

Across 7 scanned models: 1 pass Flag A (convergence), 1 pass strict Flag B, 1 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 6 models that fail Flag A: **5** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **1** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 12 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T2_noP, T2_P2_P3, T2_P2, T2_T3_noP, T2_T3_P2, T3_noP, T3_P1)

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
- **Boundary L2 fits:** 118
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 02:10:53_

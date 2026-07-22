# xsdm v6 — Model selection report (Algorithm2)

**Species:** *Acris blanchardi*

This report documents, step by step, the literal Algorithm2 selection rules
applied to this species. Each phase (L1–L4) includes the rule itself and
the complete list of models with their classification.

**Definition of model success:** a model has `status == "success"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.

## Data and units

- Species directory: `/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_smoke/Acris_blanchardi`
- Sample size: 655
- Maximum variables per model: 3
- Tau (τ): 25.9385
- L2 threshold: best L1 + τ = 793.9797
- Ω threshold: 793.4740
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
| 1 | T1_P1 ≤τ | T1+P1 | 768.0 | -354.840 | 9 | success |
| 2 | T2_T3_P3 ≤τ | T2+T3+P3 | 768.6 | -338.888 | 14 | success |
| 3 | T1_P3 ≤τ | T1+P3 | 769.1 | -355.391 | 9 | success |
| 4 | T2_T3_P1 ≤τ | T2+T3+P1 | 774.3 | -341.760 | 14 | success |
| 5 | T3_P3 ≤τ | T3+P3 | 776.4 | -359.033 | 9 | success |
| 6 | T2_P3 ≤τ | T2+P3 | 777.7 | -359.684 | 9 | success |
| 7 | T2_P1 ≤τ | T2+P1 | 780.8 | -361.213 | 9 | success |
| 8 | T3_P1 ≤τ | T3+P1 | 783.4 | -362.512 | 9 | success |
| 9 | T1_P2 ≤τ | T1+P2 | 787.6 | -364.614 | 9 | success |
| 10 | T2_T3_P2 ≤τ | T2+T3+P2 | 789.3 | -349.247 | 14 | success |
| 11 | T3_P2 ≤τ | T3+P2 | 790.8 | -366.225 | 9 | success |
| 12 | T1_noP ≤τ | T1 | 790.9 | -379.259 | 5 | success |
| 13 | T3_P2_P3 ≤τ | T3+P2+P3 | 793.6 | -351.431 | 14 | success |
| 14 | T1_P2_P3 | T1+P2+P3 | 795.4 | -352.292 | 14 | success |
| 15 | T2_T3_noP | T2+T3 | 803.7 | -372.686 | 9 | success |
| 16 | T3_noP | T3 | 807.1 | -387.320 | 5 | success |
| 17 | T2_P2 | T2+P2 | 807.5 | -374.580 | 9 | success |
| 18 | T2_P2_P3 | T2+P2+P3 | 809.3 | -359.236 | 14 | success |
| 19 | T2_noP | T2 | 812.9 | -390.262 | 5 | success |
| 20 | noT_P2_P3 | P2+P3 | 898.5 | -420.063 | 9 | success |
| 21 | noT_P3 | P3 | 899.0 | -433.277 | 5 | success |
| 22 | noT_P2 | P2 | 918.6 | -443.070 | 5 | success |
| 23 | noT_P1 | P1 | 919.4 | -443.492 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 794.0**.
**Eligible L1 models:** 13 (T1_noP, T1_P1, T1_P2, T1_P3, T2_P1, T2_P3, T2_T3_P1, T2_T3_P2, T2_T3_P3, T3_P1, T3_P2_P3, T3_P2, T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_T3_P3__bd_pd1_sigL1 | 756.9 | -339.522 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 756.9 | -339.522 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 756.9 | -339.522 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 756.9 | -339.522 | 12 | success |
| T2_T3_P3__bd_pd1_sigR1 | 756.9 | -339.522 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 756.9 | -339.528 | 12 | success |
| T2_T3_P3__bd_sigL2 | 762.1 | -338.888 | 13 | success |
| T2_T3_P3__bd_sigR1 | 762.1 | -338.888 | 13 | success |
| T2_T3_P3__bd_sigR3 | 762.1 | -338.888 | 13 | success |
| T2_T3_P3__bd_sigL1 | 762.1 | -338.888 | 13 | success |
| T2_T3_P3__bd_sigL3 | 762.1 | -338.888 | 13 | success |
| T2_T3_P3__bd_sigR2 | 762.1 | -338.888 | 13 | success |
| T2_T3_P1__bd_pd1_sigR2 | 762.3 | -342.262 | 12 | success |
| T2_T3_P1__bd_pd1_sigL1 | 762.3 | -342.262 | 12 | success |
| T2_T3_P3__bd_pd1 | 763.3 | -339.522 | 13 | success |
| T1_P1__bd_pd1 | 766.2 | -357.152 | 8 | success |
| T1_P1__bd_pd1_sigL2 | 767.5 | -361.072 | 7 | success |
| T1_P1__bd_pd1_sigR1 | 767.5 | -361.072 | 7 | success |
| T1_P1__bd_pd1_sigL1 | 767.5 | -361.072 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 767.5 | -361.072 | 7 | success |
| T2_T3_P1__bd_sigR3 | 768.4 | -342.034 | 13 | success |
| T2_T3_P1__bd_sigL2 | 768.4 | -342.034 | 13 | success |
| T2_T3_P1__bd_pd1 | 768.4 | -342.049 | 13 | success |
| T2_T3_P1__bd_sigR2 | 768.8 | -342.262 | 13 | success |
| T2_T3_P1__bd_sigL1 | 768.8 | -342.262 | 13 | success |
| T2_P1__bd_pd1_sigR2 | 769.8 | -362.225 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 769.8 | -362.225 | 7 | success |
| T2_P1__bd_pd1_sigR1 | 769.8 | -362.225 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 769.8 | -362.225 | 7 | success |
| T2_T3_P1__bd_pd1_sigL3 | 772.1 | -347.163 | 12 | success |
| T1_P3__bd_pd1 | 772.5 | -360.333 | 8 | success |
| T1_P1__bd_sigR1 | 772.7 | -360.420 | 8 | success |
| T1_P1__bd_sigL1 | 772.7 | -360.420 | 8 | success |
| T1_P1__bd_sigR2 | 772.7 | -360.420 | 8 | success |
| T1_P1__bd_sigL2 | 772.7 | -360.420 | 8 | success |
| T2_T3_P1__bd_pd1_sigL2 | 773.0 | -347.614 | 12 | success |
| T2_T3_P1__bd_pd1_sigR1 | 773.0 | -347.614 | 12 | success |
| T3_P3__bd_sigR2 | 773.4 | -360.738 | 8 | success |
| T3_P3__bd_sigR1 | 773.6 | -360.871 | 8 | success |
| T1_P3__bd_sigR1 | 774.3 | -361.221 | 8 | success |
| T1_P3__bd_sigL2 | 774.3 | -361.221 | 8 | success |
| T1_P3__bd_sigL1 | 774.3 | -361.221 | 8 | success |
| T1_P3__bd_sigR2 | 774.3 | -361.221 | 8 | success |
| T2_P1__bd_sigL1 | 774.3 | -361.226 | 8 | success |
| T2_P1__bd_sigL2 | 774.3 | -361.226 | 8 | success |
| T2_P1__bd_sigR2 | 774.3 | -361.226 | 8 | success |
| T2_P1__bd_sigR1 | 774.3 | -361.226 | 8 | success |
| T3_P3__bd_sigL1 | 774.7 | -361.387 | 8 | success |
| T3_P3__bd_sigL2 | 774.7 | -361.387 | 8 | success |
| T2_T3_P1__bd_pd1_sigR3 | 774.9 | -348.545 | 12 | success |
| T2_P3__bd_sigL2 | 776.2 | -362.137 | 8 | success |
| T2_P3__bd_sigR2 | 776.2 | -362.137 | 8 | success |
| T2_P3__bd_sigL1 | 776.2 | -362.137 | 8 | success |
| T2_P3__bd_sigR1 | 776.2 | -362.137 | 8 | success |
| T2_T3_P2__bd_pd1_sigR2 | 776.3 | -349.247 | 12 | success |
| T2_T3_P2__bd_pd1_sigL1 | 776.3 | -349.247 | 12 | success |
| T2_T3_P2__bd_pd1_sigR1 | 776.3 | -349.247 | 12 | success |
| T2_T3_P2__bd_pd1_sigL3 | 776.3 | -349.247 | 12 | success |
| T2_P1__bd_pd1 | 776.3 | -362.225 | 8 | success |
| T2_P3__bd_pd1_sigR1 | 776.9 | -365.773 | 7 | success |
| T2_P3__bd_pd1_sigL2 | 776.9 | -365.773 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 776.9 | -365.773 | 7 | success |
| T2_P3__bd_pd1_sigR2 | 776.9 | -365.773 | 7 | success |
| T3_P1__bd_pd1 | 778.4 | -363.280 | 8 | success |
| T3_P3__bd_pd1 | 778.6 | -363.351 | 8 | success |
| T2_P3__bd_pd1 | 778.7 | -363.402 | 8 | success |
| T2_T3_P1__bd_sigR1 | 779.2 | -347.441 | 13 | success |
| T2_T3_P1__bd_sigL3 | 779.2 | -347.441 | 13 | success |
| T1_P3__bd_pd1_sigR2 | 779.9 | -367.231 | 7 | success |
| T1_P3__bd_pd1_sigL1 | 779.9 | -367.231 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 779.9 | -367.231 | 7 | success |
| T1_P3__bd_pd1_sigR1 | 779.9 | -367.231 | 7 | success |
| T2_T3_P2__bd_pd1_sigR3 | 780.3 | -351.238 | 12 | success |
| T2_T3_P2__bd_pd1_sigL2 | 780.3 | -351.238 | 12 | success |
| T1_P2__bd_sigL2 | 781.1 | -364.614 | 8 | success |
| T1_P2__bd_sigL1 | 781.1 | -364.614 | 8 | success |
| T1_P2__bd_sigR2 | 781.1 | -364.614 | 8 | success |
| T1_P2__bd_sigR1 | 781.1 | -364.614 | 8 | success |
| T3_P2_P3__bd_sigL1 | 781.2 | -348.458 | 13 | success |
| T2_T3_P2__bd_sigL2 | 782.8 | -349.247 | 13 | success |
| T2_T3_P2__bd_pd1 | 782.8 | -349.247 | 13 | success |
| T2_T3_P2__bd_sigR1 | 782.8 | -349.247 | 13 | success |
| T3_P2_P3__bd_pd1_sigR2 | 784.2 | -353.185 | 12 | success |
| T3_P1__bd_pd1_sigL2 | 784.7 | -369.642 | 7 | success |
| T3_P1__bd_pd1_sigR2 | 784.7 | -369.642 | 7 | success |
| T3_P1__bd_pd1_sigR1 | 784.7 | -369.642 | 7 | success |
| T3_P1__bd_pd1_sigL1 | 784.7 | -369.642 | 7 | success |
| T3_P2__bd_sigL1 | 785.0 | -366.561 | 8 | success |
| T3_P2__bd_sigR2 | 785.0 | -366.561 | 8 | success |
| T3_P2__bd_sigR1 | 785.0 | -366.561 | 8 | success |
| T3_P2__bd_sigL2 | 785.0 | -366.561 | 8 | success |
| T1_P2__bd_pd1_sigL1 | 786.0 | -370.305 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 786.0 | -370.305 | 7 | success |
| T1_P2__bd_pd1_sigL2 | 786.0 | -370.305 | 7 | success |
| T1_P2__bd_pd1_sigR2 | 786.0 | -370.305 | 7 | success |
| T2_T3_P2__bd_sigR3 | 786.4 | -351.035 | 13 | success |
| T3_P2_P3__bd_sigL3 | 786.4 | -351.048 | 13 | success |
| T3_P2_P3__bd_pd1_sigL1 | 786.7 | -354.465 | 12 | success |
| T3_P2_P3__bd_pd1_sigR3 | 786.7 | -354.465 | 12 | success |
| T2_T3_P2__bd_sigL3 | 786.8 | -351.238 | 13 | success |
| T3_P2_P3__bd_sigR2 | 787.2 | -351.431 | 13 | success |
| T3_P2_P3__bd_sigL2 | 787.2 | -351.431 | 13 | success |
| T3_P2_P3__bd_sigR1 | 787.2 | -351.431 | 13 | success |
| T3_P2_P3__bd_sigR3 | 787.3 | -351.488 | 13 | success |
| T3_P3__bd_pd1_sigL2 | 788.1 | -371.376 | 7 | success |
| T3_P3__bd_pd1_sigR1 | 788.1 | -371.376 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 788.1 | -371.376 | 7 | success |
| T3_P3__bd_pd1_sigR2 | 788.1 | -371.376 | 7 | success |
| T2_T3_P2__bd_sigL1 | 788.3 | -351.996 | 13 | success |
| T3_P2_P3__bd_pd1_sigR1 | 789.3 | -355.727 | 12 | success |
| T3_P2_P3__bd_pd1_sigL2 | 789.3 | -355.727 | 12 | success |
| T3_P2_P3__bd_pd1_sigL3 | 789.3 | -355.727 | 12 | success |
| T1_P2__bd_pd1 | 790.5 | -369.318 | 8 | success |
| T3_P1__bd_sigR1 | 790.9 | -369.498 | 8 | success |
| T3_P1__bd_sigL1 | 790.9 | -369.498 | 8 | success |
| T3_P1__bd_sigR2 | 790.9 | -369.498 | 8 | success |
| T3_P1__bd_sigL2 | 790.9 | -369.498 | 8 | success |
| T3_P2__bd_pd1_sigL2 | 791.1 | -372.860 | 7 | success |
| T3_P2__bd_pd1_sigR2 | 791.1 | -372.860 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 791.1 | -372.860 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 791.1 | -372.860 | 7 | success |
| T2_T3_P2__bd_sigR2 | 792.1 | -353.878 | 13 | success |
| T3_P2_P3__bd_pd1 | 795.8 | -355.727 | 13 | success |
| T3_P2__bd_pd1 | 796.5 | -372.297 | 8 | success |
| T1_noP__bd_pd1_sigR1 | 797.3 | -388.922 | 3 | success |
| T1_noP__bd_pd1 | 799.8 | -386.937 | 4 | success |
| T1_noP__bd_sigR1 | 803.4 | -388.722 | 4 | success |
| T2_noP__bd_pd1 | 806.5 | -390.262 | 4 | success |
| T1_noP__bd_pd1_sigL1 | 915.0 | -447.794 | 3 | success |
| T1_noP__bd_sigL1 | 919.0 | -446.515 | 4 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_pd1_sigL1 | 756.9 | no | ✓ | ✗ | Inf | 5 |
| 2 | T2_T3_P3__bd_pd1_sigR3 | 756.9 | no | ✓ | ✗ | Inf | 16 |
| 3 | T2_T3_P3__bd_pd1_sigL2 | 756.9 | no | ✓ | ✗ | Inf | 14 |
| 4 | T2_T3_P3__bd_pd1_sigR2 | 756.9 | no | ✓ | ✗ | Inf | 5 |
| 5 | T2_T3_P3__bd_pd1_sigR1 | 756.9 | no | ✓ | ✗ | Inf | 14 |
| 6 | T2_T3_P3__bd_pd1_sigL3 | 756.9 | no | ✓ | ✗ | 3.47e+12 | 12 |
| 7 | T2_T3_P3__bd_sigL2 | 762.1 | no | ✓ | ✗ | Inf | 5 |
| 8 | T2_T3_P3__bd_sigR1 | 762.1 | no | ✓ | ✗ | Inf | 6 |
| 9 | T2_T3_P3__bd_sigR3 | 762.1 | no | ✓ | ✗ | Inf | 10 |
| 10 | T2_T3_P3__bd_sigL1 | 762.1 | no | ✓ | ✗ | Inf | 5 |
| 11 | T2_T3_P3__bd_sigL3 | 762.1 | no | ✓ | ✗ | Inf | 3 |
| 12 | T2_T3_P3__bd_sigR2 | 762.1 | no | ✗ | ✗ | Inf | 2 |
| 13 | T2_T3_P1__bd_pd1_sigR2 | 762.3 | no | ✗ | ✗ | Inf | 2 |
| 14 | T2_T3_P1__bd_pd1_sigL1 | 762.3 | no | ✗ | ✗ | Inf | 1 |
| 15 | T2_T3_P3__bd_pd1 | 763.3 | no | ✓ | ✗ | Inf | 19 |
| 16 | T1_P1__bd_pd1 | 766.2 | no | ✓ | ✗ | 1.37e+06 | 19 |
| 17 | T1_P1__bd_pd1_sigL2 | 767.5 | yes ✓ | ✓ | ✓ | 4.10e+05 | 4 |
| 18 | T1_P1__bd_pd1_sigR1 | 767.5 | no | ✓ | ✗ | 1.03e+06 | 5 |
| 19 | T1_P1__bd_pd1_sigL1 | 767.5 | yes ✓ | ✓ | ✓ | 3.90e+05 | 4 |
| 20 | T1_P1__bd_pd1_sigR2 | 767.5 | no | ✓ | ✗ | Inf | 5 |
| 21 | T1_P1 | 768.0 | no | ✓ | ✗ | 1.69e+06 | 18 |
| 22 | T2_T3_P1__bd_sigR3 | 768.4 | no | ✗ | ✗ | 5.03e+06 | 1 |
| 23 | T2_T3_P1__bd_sigL2 | 768.4 | no | ✗ | ✗ | Inf | 1 |
| 24 | T2_T3_P1__bd_pd1 | 768.4 | no | ✓ | ✗ | 1.09e+06 | 6 |
| 25 | T2_T3_P3 | 768.6 | no | ✓ | ✗ | Inf | 12 |
| 26 | T2_T3_P1__bd_sigR2 | 768.8 | no | ✗ | ✗ | Inf | 1 |
| 27 | T2_T3_P1__bd_sigL1 | 768.8 | no | ✗ | ✗ | Inf | 1 |
| 28 | T1_P3 | 769.1 | yes ✓ | ✓ | ✓ | 3.60e+03 | 24 |
| 29 | T2_P1__bd_pd1_sigR2 | 769.8 | yes ✓ | ✓ | ✓ | 1.40e+03 | 6 |
| 30 | T2_P1__bd_pd1_sigL2 | 769.8 | yes ✓ | ✓ | ✓ | 1.42e+03 | 9 |
| 31 | T2_P1__bd_pd1_sigR1 | 769.8 | yes ✓ | ✓ | ✓ | 1.41e+03 | 9 |
| 32 | T2_P1__bd_pd1_sigL1 | 769.8 | yes ✓ | ✓ | ✓ | 1.42e+03 | 6 |
| 33 | T2_T3_P1__bd_pd1_sigL3 | 772.1 | no | ✗ | ✗ | Inf | 1 |
| 34 | T1_P3__bd_pd1 | 772.5 | yes ✓ | ✓ | ✓ | 3.43e+03 | 11 |
| 35 | T1_P1__bd_sigR1 | 772.7 | no | ✓ | ✗ | 1.34e+06 | 7 |
| 36 | T1_P1__bd_sigL1 | 772.7 | yes ✓ | ✓ | ✓ | 6.34e+05 | 5 |
| 37 | T1_P1__bd_sigR2 | 772.7 | no | ✓ | ✗ | Inf | 3 |
| 38 | T1_P1__bd_sigL2 | 772.7 | no | ✓ | ✗ | Inf | 4 |
| 39 | T2_T3_P1__bd_pd1_sigL2 | 773.0 | no | ✗ | ✗ | Inf | 1 |
| 40 | T2_T3_P1__bd_pd1_sigR1 | 773.0 | no | ✓ | ✗ | 1.69e+07 | 3 |
| 41 | T3_P3__bd_sigR2 | 773.4 | no | ✗ | ✗ | Inf | 1 |
| 42 | T3_P3__bd_sigR1 | 773.6 | no | ✗ | ✗ | Inf | 1 |
| 43 | T2_T3_P1 | 774.3 | no | ✓ | ✗ | Inf | 3 |
| 44 | T1_P3__bd_sigR1 | 774.3 | yes ✓ | ✓ | ✓ | 8.20e+04 | 8 |
| 45 | T1_P3__bd_sigL2 | 774.3 | yes ✓ | ✓ | ✓ | 5.16e+04 | 9 |
| 46 | T1_P3__bd_sigL1 | 774.3 | yes ✓ | ✓ | ✓ | 5.31e+04 | 8 |
| 47 | T1_P3__bd_sigR2 | 774.3 | yes ✓ | ✓ | ✓ | 5.35e+04 | 11 |
| 48 | T2_P1__bd_sigL1 | 774.3 | yes ✓ | ✓ | ✓ | 2.39e+03 | 3 |
| 49 | T2_P1__bd_sigL2 | 774.3 | yes ✓ | ✓ | ✓ | 2.43e+03 | 5 |
| 50 | T2_P1__bd_sigR2 | 774.3 | yes ✓ | ✓ | ✓ | 2.45e+03 | 5 |
| 51 | T2_P1__bd_sigR1 | 774.3 | yes ✓ | ✓ | ✓ | 2.43e+03 | 4 |
| 52 | T3_P3__bd_sigL1 | 774.7 | no | ✗ | ✗ | Inf | 2 |
| 53 | T3_P3__bd_sigL2 | 774.7 | no | ✓ | ✗ | Inf | 3 |
| 54 | T2_T3_P1__bd_pd1_sigR3 | 774.9 | no | ✗ | ✗ | Inf | 1 |
| 55 | T2_P3__bd_sigL2 | 776.2 | yes ✓ | ✓ | ✓ | 1.05e+04 | 10 |
| 56 | T2_P3__bd_sigR2 | 776.2 | yes ✓ | ✓ | ✓ | 1.03e+04 | 7 |
| 57 | T2_P3__bd_sigL1 | 776.2 | no | ✗ | ✓ | 1.03e+04 | 2 |
| 58 | T2_P3__bd_sigR1 | 776.2 | yes ✓ | ✓ | ✓ | 1.01e+04 | 6 |
| 59 | T2_T3_P2__bd_pd1_sigR2 | 776.3 | no | ✗ | ✗ | 1.41e+06 | 1 |
| 60 | T2_T3_P2__bd_pd1_sigL1 | 776.3 | no | ✗ | ✗ | Inf | 1 |
| 61 | T2_T3_P2__bd_pd1_sigR1 | 776.3 | no | ✗ | ✓ | 2.12e+05 | 1 |
| 62 | T2_T3_P2__bd_pd1_sigL3 | 776.3 | no | ✗ | ✗ | Inf | 1 |
| 63 | T2_P1__bd_pd1 | 776.3 | no | ✓ | ✗ | 6.06e+11 | 20 |
| 64 | T3_P3 | 776.4 | no | ✓ | ✗ | 1.18e+07 | 7 |
| 65 | T2_P3__bd_pd1_sigR1 | 776.9 | yes ✓ | ✓ | ✓ | 4.57e+03 | 8 |
| 66 | T2_P3__bd_pd1_sigL2 | 776.9 | yes ✓ | ✓ | ✓ | 4.64e+03 | 6 |
| 67 | T2_P3__bd_pd1_sigL1 | 776.9 | yes ✓ | ✓ | ✓ | 4.18e+03 | 8 |
| 68 | T2_P3__bd_pd1_sigR2 | 776.9 | yes ✓ | ✓ | ✓ | 4.66e+03 | 6 |
| 69 | T2_P3 | 777.7 | yes ✓ | ✓ | ✓ | 7.06e+03 | 15 |
| 70 | T3_P1__bd_pd1 | 778.4 | no | ✓ | ✗ | Inf | 22 |
| 71 | T3_P3__bd_pd1 | 778.6 | no | ✓ | ✗ | Inf | 17 |
| 72 | T2_P3__bd_pd1 | 778.7 | yes ✓ | ✓ | ✓ | 5.40e+03 | 22 |
| 73 | T2_T3_P1__bd_sigR1 | 779.2 | no | ✗ | ✗ | Inf | 1 |
| 74 | T2_T3_P1__bd_sigL3 | 779.2 | no | ✗ | ✗ | Inf | 1 |
| 75 | T1_P3__bd_pd1_sigR2 | 779.9 | yes ✓ | ✓ | ✓ | 1.38e+04 | 4 |
| 76 | T1_P3__bd_pd1_sigL1 | 779.9 | yes ✓ | ✓ | ✓ | 1.35e+04 | 8 |
| 77 | T1_P3__bd_pd1_sigL2 | 779.9 | yes ✓ | ✓ | ✓ | 1.38e+04 | 9 |
| 78 | T1_P3__bd_pd1_sigR1 | 779.9 | yes ✓ | ✓ | ✓ | 1.29e+04 | 7 |
| 79 | T2_T3_P2__bd_pd1_sigR3 | 780.3 | no | ✓ | ✗ | Inf | 5 |
| 80 | T2_T3_P2__bd_pd1_sigL2 | 780.3 | no | ✓ | ✗ | Inf | 4 |
| 81 | T2_P1 | 780.8 | yes ✓ | ✓ | ✓ | 9.30e+03 | 13 |
| 82 | T1_P2__bd_sigL2 | 781.1 | yes ✓ | ✓ | ✓ | 4.22e+05 | 4 |
| 83 | T1_P2__bd_sigL1 | 781.1 | yes ✓ | ✓ | ✓ | 3.57e+05 | 9 |
| 84 | T1_P2__bd_sigR2 | 781.1 | yes ✓ | ✓ | ✓ | 4.75e+05 | 8 |
| 85 | T1_P2__bd_sigR1 | 781.1 | no | ✓ | ✗ | Inf | 8 |
| 86 | T3_P2_P3__bd_sigL1 | 781.2 | no | ✗ | ✗ | Inf | 1 |
| 87 | T2_T3_P2__bd_sigL2 | 782.8 | no | ✗ | ✗ | Inf | 2 |
| 88 | T2_T3_P2__bd_pd1 | 782.8 | no | ✓ | ✗ | 1.36e+15 | 8 |
| 89 | T2_T3_P2__bd_sigR1 | 782.8 | no | ✗ | ✗ | Inf | 1 |
| 90 | T3_P1 | 783.4 | yes ✓ | ✓ | ✓ | 6.80e+05 | 22 |
| 91 | T3_P2_P3__bd_pd1_sigR2 | 784.2 | no | ✗ | ✗ | Inf | 1 |
| 92 | T3_P1__bd_pd1_sigL2 | 784.7 | yes ✓ | ✓ | ✓ | 1.87e+05 | 4 |
| 93 | T3_P1__bd_pd1_sigR2 | 784.7 | yes ✓ | ✓ | ✓ | 1.78e+05 | 8 |
| 94 | T3_P1__bd_pd1_sigR1 | 784.7 | yes ✓ | ✓ | ✓ | 1.84e+05 | 5 |
| 95 | T3_P1__bd_pd1_sigL1 | 784.7 | yes ✓ | ✓ | ✓ | 1.88e+05 | 4 |
| 96 | T3_P2__bd_sigL1 | 785.0 | no | ✓ | ✗ | Inf | 12 |
| 97 | T3_P2__bd_sigR2 | 785.0 | no | ✓ | ✗ | 1.39e+09 | 7 |
| 98 | T3_P2__bd_sigR1 | 785.0 | no | ✓ | ✗ | Inf | 9 |
| 99 | T3_P2__bd_sigL2 | 785.0 | no | ✗ | ✗ | Inf | 2 |
| 100 | T1_P2__bd_pd1_sigL1 | 786.0 | yes ✓ | ✓ | ✓ | 2.94e+04 | 5 |
| 101 | T1_P2__bd_pd1_sigR1 | 786.0 | yes ✓ | ✓ | ✓ | 2.76e+04 | 6 |
| 102 | T1_P2__bd_pd1_sigL2 | 786.0 | yes ✓ | ✓ | ✓ | 2.69e+04 | 8 |
| 103 | T1_P2__bd_pd1_sigR2 | 786.0 | yes ✓ | ✓ | ✓ | 2.88e+04 | 4 |
| 104 | T2_T3_P2__bd_sigR3 | 786.4 | no | ✗ | ✗ | Inf | 1 |
| 105 | T3_P2_P3__bd_sigL3 | 786.4 | no | ✗ | ✗ | Inf | 1 |
| 106 | T3_P2_P3__bd_pd1_sigL1 | 786.7 | no | ✗ | ✗ | Inf | 1 |
| 107 | T3_P2_P3__bd_pd1_sigR3 | 786.7 | no | ✗ | ✗ | Inf | 1 |
| 108 | T2_T3_P2__bd_sigL3 | 786.8 | no | ✗ | ✗ | Inf | 1 |
| 109 | T3_P2_P3__bd_sigR2 | 787.2 | no | ✗ | ✗ | Inf | 2 |
| 110 | T3_P2_P3__bd_sigL2 | 787.2 | no | ✓ | ✗ | Inf | 3 |
| 111 | T3_P2_P3__bd_sigR1 | 787.2 | no | ✗ | ✗ | Inf | 1 |
| 112 | T3_P2_P3__bd_sigR3 | 787.3 | no | ✗ | ✗ | Inf | 1 |
| 113 | T1_P2 | 787.6 | no | ✓ | ✗ | Inf | 18 |
| 114 | T3_P3__bd_pd1_sigL2 | 788.1 | no | ✓ | ✗ | 1.73e+07 | 5 |
| 115 | T3_P3__bd_pd1_sigR1 | 788.1 | no | ✓ | ✗ | 1.07e+07 | 3 |
| 116 | T3_P3__bd_pd1_sigL1 | 788.1 | no | ✗ | ✗ | Inf | 2 |
| 117 | T3_P3__bd_pd1_sigR2 | 788.1 | no | ✓ | ✗ | 1.68e+07 | 5 |
| 118 | T2_T3_P2__bd_sigL1 | 788.3 | no | ✗ | ✗ | Inf | 1 |
| 119 | T3_P2_P3__bd_pd1_sigR1 | 789.3 | no | ✓ | ✗ | Inf | 5 |
| 120 | T3_P2_P3__bd_pd1_sigL2 | 789.3 | no | ✓ | ✗ | Inf | 6 |
| 121 | T3_P2_P3__bd_pd1_sigL3 | 789.3 | no | ✗ | ✗ | Inf | 1 |
| 122 | T2_T3_P2 | 789.3 | no | ✓ | ✗ | Inf | 4 |
| 123 | T1_P2__bd_pd1 | 790.5 | yes ✓ | ✓ | ✓ | 3.98e+04 | 22 |
| 124 | T3_P2 | 790.8 | no | ✗ | ✗ | Inf | 1 |
| 125 | T3_P1__bd_sigR1 | 790.9 | yes ✓ | ✓ | ✓ | 2.13e+05 | 5 |
| 126 | T3_P1__bd_sigL1 | 790.9 | no | ✗ | ✓ | 2.31e+05 | 2 |
| 127 | T3_P1__bd_sigR2 | 790.9 | no | ✓ | ✗ | Inf | 6 |
| 128 | T3_P1__bd_sigL2 | 790.9 | yes ✓ | ✓ | ✓ | 1.99e+05 | 7 |
| 129 | T1_noP | 790.9 | yes ✓ | ✓ | ✓ | 2.64e+04 | 5 |
| 130 | T3_P2__bd_pd1_sigL2 | 791.1 | yes ✓ | ✓ | ✓ | 1.63e+05 | 7 |
| 131 | T3_P2__bd_pd1_sigR2 | 791.1 | yes ✓ | ✓ | ✓ | 1.59e+05 | 14 |
| 132 | T3_P2__bd_pd1_sigL1 | 791.1 | yes ✓ | ✓ | ✓ | 1.66e+05 | 10 |
| 133 | T3_P2__bd_pd1_sigR1 | 791.1 | yes ✓ | ✓ | ✓ | 1.58e+05 | 10 |
| 134 | T2_T3_P2__bd_sigR2 | 792.1 | no | ✗ | ✗ | Inf | 1 |
| 135 | T3_P2_P3 | 793.6 | no | ✓ | ✗ | Inf | 5 |
| 136 | T1_P2_P3 | 795.4 | no | ✗ | ✗ | Inf | 1 |
| 137 | T3_P2_P3__bd_pd1 | 795.8 | no | ✓ | ✗ | 8.78e+13 | 8 |
| 138 | T3_P2__bd_pd1 | 796.5 | yes ✓ | ✓ | ✓ | 9.94e+04 | 22 |
| 139 | T1_noP__bd_pd1_sigR1 | 797.3 | yes ✓ | ✓ | ✓ | 2.01e+02 | 25 |
| 140 | T1_noP__bd_pd1 | 799.8 | yes ✓ | ✓ | ✓ | 5.41e+02 | 24 |
| 141 | T1_noP__bd_sigR1 | 803.4 | yes ✓ | ✓ | ✓ | 1.93e+04 | 25 |
| 142 | T2_T3_noP | 803.7 | no | ✗ | ✗ | Inf | 1 |
| 143 | T2_noP__bd_pd1 | 806.5 | no | ✓ | ✗ | 3.57e+12 | 25 |
| 144 | T3_noP | 807.1 | no | ✗ | ✗ | Inf | 1 |
| 145 | T2_P2 | 807.5 | no | ✓ | ✗ | 6.92e+17 | 14 |
| 146 | T2_P2_P3 | 809.3 | no | ✗ | ✗ | Inf | 1 |
| 147 | T2_noP | 812.9 | no | ✓ | ✗ | 9.06e+12 | 23 |
| 148 | noT_P2_P3 | 898.5 | no | ✗ | ✗ | Inf | 1 |
| 149 | noT_P3 | 899.0 | no | ✓ | ✗ | 7.32e+07 | 13 |
| 150 | T1_noP__bd_pd1_sigL1 | 915.0 | yes ✓ | ✓ | ✓ | 8.80e+02 | 24 |
| 151 | noT_P2 | 918.6 | no | ✗ | ✗ | 3.08e+21 | 1 |
| 152 | T1_noP__bd_sigL1 | 919.0 | no | ✗ | ✗ | Inf | 1 |
| 153 | noT_P1 | 919.4 | no | ✗ | ✗ | Inf | 1 |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T1_P1__bd_pd1_sigL2` — **Ω = 767.5**

## L3 supplementary appendices — per-model diagnostics

### T2_T3_P3__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.522 | 14.4311 | 2.0641 | 13.3569 |   Inf | 60.4542 | 3.0771 | 0.2286 | 0.7180 | 4.3178 | -2.0535 | 1.0000 | -0.6977 | 0.5459 | -0.4639 | -0.6987 | -0.6615 | 0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.00000000 |
| 2 | -339.522 | 14.4311 | 2.0641 | 13.3569 |   Inf | 60.4542 | 3.0771 | 0.2286 | 0.7180 | 4.3178 | -2.0535 | 1.0000 | -0.6977 | 0.5459 | -0.4639 | -0.6987 | -0.6615 | 0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.00000035 |
| 3 | -339.522 | 14.4311 | 2.0641 | 13.3569 |   Inf | 60.4542 | 3.0771 | 0.2286 | 0.7180 | 4.3178 | -2.0535 | 1.0000 | -0.6977 | 0.5459 | -0.4639 | -0.6987 | -0.6615 | 0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.00000053 |
| 4 | -339.522 | 14.4311 | 2.0641 | 13.3569 |   Inf | 60.4542 | 3.0771 | 0.2286 | 0.7180 | 4.3178 | -2.0535 | 1.0000 | -0.6977 | 0.5459 | -0.4639 | -0.6987 | -0.6615 | 0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.00000126 |
| 5 | -339.528 | 14.4362 | 2.0656 | 13.3200 | 201985.3531 |   Inf | 3.0782 | 0.2286 | 0.7213 | 4.3308 | -2.0300 | 1.0000 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | -0.1598 | 0.5137 | 0.8429 | 0.04760180 |
| 6 | -349.236 | 15.7517 | -0.8203 | 8.9919 | 5.4999 | 9.2923 | 1.6404 | 0.2031 | 0.8313 |   Inf | -3.3683 | 1.0000 | -0.6830 | 0.4146 | -0.6013 | -0.6426 | -0.7324 | 0.2249 | -0.3472 | 0.5401 | 0.7667 | 5.60793426 |
| 7 | -350.038 | 17.1766 | -1.5582 | 12.8316 | 5.1437 | 7.7341 | 2.4143 | 1.5431 | 0.8738 |   Inf | -4.2489 | 1.0000 | -0.3800 | -0.0910 | -0.9205 | -0.5876 | -0.7448 | 0.3162 | -0.7144 | 0.6610 | 0.2296 | 6.42301054 |
| 8 | -350.038 | 17.1766 | -1.5582 | 12.8316 | 5.1437 | 7.7341 | 2.4143 | 1.5431 | 0.8738 |   Inf | -4.2489 | 1.0000 | -0.3800 | -0.0910 | -0.9205 | -0.5876 | -0.7448 | 0.3162 | -0.7144 | 0.6610 | 0.2296 | 6.42301094 |
| 9 | -352.020 | 16.9745 | -1.0797 | 7.4529 | 8.5564 | 38395.7609 | 1.2967 | 0.1630 | 1.1722 |   Inf | -1.4507 | 1.0000 | -0.7099 | 0.4550 | -0.5376 | -0.6326 | -0.7475 | 0.2026 | -0.3097 | 0.4839 | 0.8185 | 7.43511508 |
| 10 | -352.773 | 14.1388 | 3.3558 | 13.2898 | 7.4218 |   Inf | 2.6470 | 0.6756 | 5.9853 | 4.8915 | -4.1256 | 1.0000 | -0.7486 | -0.5961 | 0.2901 | 0.6619 | -0.6469 | 0.3788 | -0.0381 | 0.4756 | 0.8788 | 4.43912134 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.311e+04 | 1.227e+04 |
| 2 | 1.800e+03 | 1.865e+03 |
| 3 | 6.685e+02 | 6.676e+02 |
| 4 | 3.804e+02 | 4.218e+02 |
| 5 | 9.745e+01 | 1.108e+02 |
| 6 | 2.886e+01 | 2.931e+01 |
| 7 | 1.537e+01 | 1.559e+01 |
| 8 | 2.097e+00 | 3.585e+00 |
| 9 | 1.154e+00 | 1.430e+00 |
| 10 | 6.736e-02 | 2.974e-01 |
| 11 | 4.227e-02 | 1.151e-01 |
| 12 | -8.289e+00 | 4.862e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 252323.9657, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3.0771 | 0.2286 | 60.4542 | 4.3178 |   Inf | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.6977 | -0.5459 | 0.4639 | 0.00000000 |
| 2 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3.0771 | 0.2286 | 60.4542 | 4.3178 |   Inf | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.6977 | -0.5459 | 0.4639 | 0.00000076 |
| 3 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3.0771 | 0.2286 | 60.4543 | 4.3178 |   Inf | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.6977 | -0.5459 | 0.4639 | 0.00000253 |
| 4 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3.0771 | 0.2286 | 60.4543 | 4.3178 |   Inf | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.6977 | -0.5459 | 0.4639 | 0.00000142 |
| 5 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3.0771 | 0.2286 | 60.4542 | 4.3178 |   Inf | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.6977 | -0.5459 | 0.4639 | 0.00000171 |
| 6 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3.0771 | 0.2286 | 60.4542 | 4.3178 |   Inf | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.1581 | 0.5142 | 0.8430 | 0.6977 | -0.5459 | 0.4639 | 0.00000145 |
| 7 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.7213 | 3.0782 | 0.2286 | 4680.1343 | 4.3309 |   Inf | -2.0300 | 1.0000 | 0.6991 | 0.6617 | -0.2707 | -0.1598 | 0.5137 | 0.8429 | 0.6969 | -0.5460 | 0.4649 | 0.04753956 |
| 8 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.7213 | 3.0782 | 0.2286 | 16882.4788 | 4.3309 |   Inf | -2.0300 | 1.0000 | 0.6991 | 0.6617 | -0.2707 | -0.1598 | 0.5137 | 0.8429 | 0.6969 | -0.5460 | 0.4649 | 0.04759520 |
| 9 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.7213 | 3.0782 | 0.2286 | 175091.6546 | 4.3309 |   Inf | -2.0300 | 1.0000 | 0.6991 | 0.6617 | -0.2707 | -0.1598 | 0.5137 | 0.8429 | 0.6969 | -0.5460 | 0.4649 | 0.04761376 |
| 10 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.7213 | 3.0782 | 0.2286 |   Inf | 4.3309 | 576751.5346 | -2.0300 | 1.0000 | 0.6991 | 0.6617 | -0.2707 | -0.1598 | 0.5137 | 0.8429 | 0.6969 | -0.5460 | 0.4649 | 0.04761570 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.257e+03 | 5.058e+03 |
| 2 | 6.935e+02 | 6.935e+02 |
| 3 | 5.059e+02 | 5.059e+02 |
| 4 | 1.553e+02 | 1.545e+02 |
| 5 | 4.040e+01 | 3.405e+01 |
| 6 | 1.537e+01 | 1.445e+01 |
| 7 | 4.587e+00 | 5.803e+00 |
| 8 | 1.230e+00 | 2.832e+00 |
| 9 | 9.629e-02 | 1.436e+00 |
| 10 | 5.420e-02 | 2.897e-01 |
| 11 | -2.661e+00 | 1.125e-01 |
| 12 | -1.349e+01 | 4.871e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 103832.1946, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4542 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000000 |
| 2 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4542 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000167 |
| 3 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4543 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000048 |
| 4 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4542 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000120 |
| 5 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4542 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000097 |
| 6 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4542 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000042 |
| 7 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 60.4543 |   Inf | 4.3178 | 0.7180 | 0.2286 | 3.0771 | -2.0535 | 1.0000 | -0.6987 | -0.6615 | 0.2725 | -0.6977 | 0.5459 | -0.4639 | 0.1581 | -0.5142 | -0.8430 | 0.00000182 |
| 8 | -339.528 | 14.4362 | 2.0656 | 13.3200 | 9676.9291 |   Inf | 4.3309 | 0.7213 | 0.2286 | 3.0782 | -2.0300 | 1.0000 | -0.6991 | -0.6617 | 0.2707 | -0.6969 | 0.5460 | -0.4649 | 0.1598 | -0.5137 | -0.8429 | 0.04757779 |
| 9 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 22230.2649 |   Inf | 4.3309 | 0.7213 | 0.2286 | 3.0782 | -2.0300 | 1.0000 | -0.6991 | -0.6617 | 0.2707 | -0.6969 | 0.5460 | -0.4649 | 0.1598 | -0.5137 | -0.8429 | 0.04759922 |
| 10 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 32748.1590 |   Inf | 4.3309 | 0.7213 | 0.2286 | 3.0782 | -2.0300 | 1.0000 | -0.6991 | -0.6617 | 0.2707 | -0.6969 | 0.5460 | -0.4649 | 0.1598 | -0.5137 | -0.8429 | 0.04760443 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.477e+03 | 5.435e+03 |
| 2 | 7.097e+02 | 7.111e+02 |
| 3 | 5.089e+02 | 5.048e+02 |
| 4 | 1.348e+02 | 1.329e+02 |
| 5 | 7.294e+01 | 7.906e+01 |
| 6 | 1.538e+01 | 1.563e+01 |
| 7 | 4.715e+00 | 6.913e+00 |
| 8 | 1.555e+00 | 3.265e+00 |
| 9 | 1.004e+00 | 1.400e+00 |
| 10 | 5.820e-02 | 2.867e-01 |
| 11 | 4.166e-02 | 1.116e-01 |
| 12 | -1.023e+01 | 4.839e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 112326.3262, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 4.3178 | 0.2286 | 60.4542 | 3.0771 |   Inf | 0.7180 | -2.0535 | 1.0000 | 0.1581 | -0.5142 | -0.8430 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.00000000 |
| 2 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 4.3309 | 0.2286 |   Inf | 3.0782 | 30277184.3305 | 0.7213 | -2.0300 | 1.0000 | 0.1598 | -0.5137 | -0.8429 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.04761619 |
| 3 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 4.3309 | 0.2286 |   Inf | 3.0782 | 213975.3997 | 0.7213 | -2.0300 | 1.0000 | 0.1598 | -0.5137 | -0.8429 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.04760694 |
| 4 | -339.528 | 14.4362 | 2.0656 | 13.3200 | 4.3309 | 0.2286 |   Inf | 3.0782 | 113744.4476 | 0.7213 | -2.0300 | 1.0000 | 0.1598 | -0.5137 | -0.8429 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.04760388 |
| 5 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 4.3309 | 0.2286 |   Inf | 3.0782 | 88762.6839 | 0.7213 | -2.0300 | 1.0000 | 0.1598 | -0.5137 | -0.8429 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.04761563 |
| 6 | -349.236 | 15.7517 | -0.8203 | 8.9919 |   Inf | 0.2031 | 9.2923 | 1.6404 | 5.4999 | 0.8313 | -3.3683 | 1.0000 | 0.3472 | -0.5401 | -0.7667 | 0.6830 | -0.4146 | 0.6013 | -0.6426 | -0.7324 | 0.2249 | 5.60793493 |
| 7 | -349.236 | 15.7517 | -0.8203 | 8.9919 |   Inf | 0.2031 | 9.2923 | 1.6404 | 5.4999 | 0.8313 | -3.3683 | 1.0000 | 0.3472 | -0.5401 | -0.7667 | 0.6830 | -0.4146 | 0.6013 | -0.6426 | -0.7324 | 0.2249 | 5.60793491 |
| 8 | -351.288 | 19.3777 | -3.3242 | 18.2497 | 4.5165 | 0.0983 |   Inf | 3.5401 | 8.5864 | 0.7745 | -2.0858 | 1.0000 | -0.1069 | -0.2851 | -0.9525 | 0.9177 | -0.3970 | 0.0158 | -0.3827 | -0.8724 | 0.3041 | 10.56405747 |
| 9 | -352.773 | 14.1388 | 3.3558 | 13.2898 | 4.8915 | 0.6756 |   Inf | 2.6470 | 7.4218 | 5.9853 | -4.1256 | 1.0000 | 0.0381 | -0.4756 | -0.8788 | 0.7486 | 0.5961 | -0.2901 | 0.6619 | -0.6469 | 0.3788 | 4.43911995 |
| 10 | -352.773 | 14.1388 | 3.3558 | 13.2898 | 4.8915 | 0.6756 |   Inf | 2.6470 | 7.4218 | 5.9853 | -4.1256 | 1.0000 | 0.0381 | -0.4756 | -0.8788 | 0.7486 | 0.5961 | -0.2901 | 0.6619 | -0.6469 | 0.3788 | 4.43912079 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0061, max_pdist=0.0476 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.077e+04 | 1.053e+04 |
| 2 | 2.021e+03 | 2.030e+03 |
| 3 | 6.702e+02 | 6.713e+02 |
| 4 | 4.157e+02 | 5.178e+02 |
| 5 | 1.050e+02 | 1.115e+02 |
| 6 | 2.893e+01 | 3.163e+01 |
| 7 | 1.519e+01 | 1.559e+01 |
| 8 | 4.031e+00 | 3.609e+00 |
| 9 | 9.826e-01 | 1.418e+00 |
| 10 | 1.284e-01 | 2.841e-01 |
| 11 | 5.026e-02 | 1.100e-01 |
| 12 | -2.691e-02 | 4.843e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 217502.6473, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4542 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000000 |
| 2 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4542 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000135 |
| 3 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4543 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000049 |
| 4 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4543 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000099 |
| 5 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4542 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000021 |
| 6 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4543 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000035 |
| 7 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.2286 | 60.4542 | 4.3178 |   Inf | 0.7180 | 3.0771 | -2.0535 | 1.0000 | 0.6977 | -0.5459 | 0.4639 | -0.6987 | -0.6615 | 0.2725 | 0.1581 | -0.5142 | -0.8430 | 0.00000036 |
| 8 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.2286 | 937384.6457 | 4.3309 |   Inf | 0.7213 | 3.0782 | -2.0300 | 1.0000 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.1598 | -0.5137 | -0.8429 | 0.04761528 |
| 9 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.2286 |   Inf | 4.3309 | 259770721019170175977455855075328.0000 | 0.7213 | 3.0782 | -2.0300 | 1.0000 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.1598 | -0.5137 | -0.8429 | 0.04761600 |
| 10 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 0.2286 | 435465810.5468 | 4.3309 |   Inf | 0.7213 | 3.0782 | -2.0300 | 1.0000 | 0.6969 | -0.5460 | 0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.1598 | -0.5137 | -0.8429 | 0.04761566 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.381e+03 | 2.413e+03 |
| 2 | 7.156e+02 | 7.147e+02 |
| 3 | 5.206e+02 | 5.135e+02 |
| 4 | 2.536e+02 | 2.527e+02 |
| 5 | 1.077e+02 | 1.093e+02 |
| 6 | 1.554e+01 | 1.561e+01 |
| 7 | 5.925e+00 | 6.447e+00 |
| 8 | 1.913e+00 | 3.174e+00 |
| 9 | 1.335e+00 | 1.397e+00 |
| 10 | 6.170e-02 | 2.738e-01 |
| 11 | 3.210e-02 | 1.083e-01 |
| 12 | -5.541e-01 | 4.849e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 49769.2543, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.528 | 14.4362 | 2.0656 | 13.3200 | 3.0782 | 659057.7738 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00000000 |
| 2 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 314260.4125 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00000931 |
| 3 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 309710.1839 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00002631 |
| 4 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 291176.5719 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00000823 |
| 5 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 264830.7387 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00002578 |
| 6 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 237226.9451 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00001283 |
| 7 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 205133.7792 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00002027 |
| 8 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 186398.1161 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00003704 |
| 9 | -339.528 | 14.4362 | 2.0655 | 13.3200 | 3.0782 | 175617.5531 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00000988 |
| 10 | -339.528 | 14.4362 | 2.0656 | 13.3200 | 3.0782 | 168501.9773 |   Inf | 4.3309 | 0.2286 | 0.7213 | -2.0300 | 1.0000 | -0.1598 | 0.5137 | 0.8429 | -0.6969 | 0.5460 | -0.4649 | -0.6991 | -0.6617 | 0.2707 | 0.00001961 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.847e+03 | 2.870e+03 |
| 2 | 6.806e+02 | 6.805e+02 |
| 3 | 3.427e+02 | 3.340e+02 |
| 4 | 1.244e+02 | 1.240e+02 |
| 5 | 7.727e+01 | 8.095e+01 |
| 6 | 1.574e+01 | 1.578e+01 |
| 7 | 1.201e+01 | 5.264e+00 |
| 8 | 4.215e+00 | 3.029e+00 |
| 9 | 1.090e+00 | 1.299e+00 |
| 10 | 2.077e-01 | 2.653e-01 |
| 11 | 1.958e-02 | 1.099e-01 |
| 12 | 8.196e-10 | 1.564e-06 |

numDeriv::hessian (operative): cond = 3473521701217.1860, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1835631157.0237, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 2.7855 |   Inf | 0.5929 | 3.1723 | 0.2038 | 23.5462 | -3.9901 | 0.8160 | 0.1124 | -0.4965 | -0.8607 | -0.7211 | 0.5552 | -0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000000 |
| 2 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 2.7855 |   Inf | 0.5929 | 3.1723 | 0.2038 | 23.5462 | -3.9901 | 0.8160 | 0.1124 | -0.4965 | -0.8607 | -0.7211 | 0.5552 | -0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000122 |
| 3 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 2.7855 |   Inf | 0.5929 | 3.1723 | 0.2038 | 23.5462 | -3.9901 | 0.8160 | 0.1124 | -0.4965 | -0.8607 | -0.7211 | 0.5552 | -0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000089 |
| 4 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 2.7855 |   Inf | 0.5929 | 3.1723 | 0.2038 | 23.5462 | -3.9901 | 0.8160 | 0.1124 | -0.4965 | -0.8607 | -0.7211 | 0.5552 | -0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000167 |
| 5 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 2.7855 |   Inf | 0.5929 | 3.1723 | 0.2038 | 23.5462 | -3.9901 | 0.8160 | 0.1124 | -0.4965 | -0.8607 | -0.7211 | 0.5552 | -0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000214 |
| 6 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 2.9169 |   Inf | 0.6116 | 3.1777 | 0.1996 | 52268.8985 | -3.6771 | 0.8243 | 0.1243 | -0.4976 | -0.8585 | -0.7171 | 0.5529 | -0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49718580 |
| 7 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 2.9169 | 131527803023155591725075922944.0000 | 0.6116 | 3.1777 | 0.1996 |   Inf | -3.6771 | 0.8243 | 0.1243 | -0.4976 | -0.8585 | -0.7171 | 0.5529 | -0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49718759 |
| 8 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 2.9169 | 198669840.2507 | 0.6116 | 3.1777 | 0.1996 |   Inf | -3.6771 | 0.8243 | 0.1243 | -0.4976 | -0.8585 | -0.7171 | 0.5529 | -0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49718754 |
| 9 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 2.9169 | 283510.0598 | 0.6116 | 3.1777 | 0.1996 |   Inf | -3.6770 | 0.8243 | 0.1243 | -0.4976 | -0.8585 | -0.7171 | 0.5529 | -0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49719098 |
| 10 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 2.9169 | 112889.6710 | 0.6116 | 3.1777 | 0.1996 |   Inf | -3.6771 | 0.8243 | 0.1243 | -0.4976 | -0.8585 | -0.7171 | 0.5529 | -0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49718766 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 9.561e+03 | 8.637e+03 |
| 2 | 1.123e+03 | 1.119e+03 |
| 3 | 7.914e+02 | 7.818e+02 |
| 4 | 1.780e+02 | 1.964e+02 |
| 5 | 1.408e+02 | 1.463e+02 |
| 6 | 2.662e+01 | 2.658e+01 |
| 7 | 4.637e+00 | 1.796e+01 |
| 8 | 1.609e+00 | 3.043e+00 |
| 9 | 1.131e+00 | 1.369e+00 |
| 10 | 6.174e-01 | 1.155e+00 |
| 11 | 1.841e-01 | 5.897e-01 |
| 12 | 4.786e-02 | 1.800e-01 |
| 13 | -2.532e+02 | 8.367e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 103229.2788, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.2038 | 23.5462 | 2.7855 |   Inf | 0.5929 | 3.1723 | -3.9901 | 0.8160 | 0.7211 | -0.5552 | 0.4144 | -0.6837 | -0.6673 | 0.2956 | 0.1124 | -0.4965 | -0.8607 | 0.00000000 |
| 2 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.2038 | 23.5462 | 2.7855 |   Inf | 0.5929 | 3.1723 | -3.9901 | 0.8160 | 0.7211 | -0.5552 | 0.4144 | -0.6837 | -0.6673 | 0.2956 | 0.1124 | -0.4965 | -0.8607 | 0.00000097 |
| 3 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.2038 | 23.5462 | 2.7855 |   Inf | 0.5929 | 3.1723 | -3.9901 | 0.8160 | 0.7211 | -0.5552 | 0.4144 | -0.6837 | -0.6673 | 0.2956 | 0.1124 | -0.4965 | -0.8607 | 0.00000151 |
| 4 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.2038 | 23.5462 | 2.7855 |   Inf | 0.5929 | 3.1723 | -3.9901 | 0.8160 | 0.7211 | -0.5552 | 0.4144 | -0.6837 | -0.6673 | 0.2956 | 0.1124 | -0.4965 | -0.8607 | 0.00000225 |
| 5 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.2038 | 23.5462 | 2.7855 |   Inf | 0.5929 | 3.1723 | -3.9901 | 0.8160 | 0.7211 | -0.5552 | 0.4144 | -0.6837 | -0.6673 | 0.2956 | 0.1124 | -0.4965 | -0.8607 | 0.00000166 |
| 6 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.2038 | 23.5462 | 2.7855 |   Inf | 0.5929 | 3.1723 | -3.9901 | 0.8160 | 0.7211 | -0.5552 | 0.4144 | -0.6837 | -0.6673 | 0.2956 | 0.1124 | -0.4965 | -0.8607 | 0.00000205 |
| 7 | -338.975 | 14.5792 | 1.6958 | 16.0819 | 0.1289 | 22.3914 | 2.8387 |   Inf | 0.5988 | 3.0474 | -4.1083 | 0.8111 | 0.7598 | -0.5176 | 0.3934 | -0.6393 | -0.7049 | 0.3072 | 0.1183 | -0.4850 | -0.8665 | 3.02864698 |
| 8 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 0.1996 | 17520.3696 | 2.9169 |   Inf | 0.6116 | 3.1777 | -3.6771 | 0.8243 | 0.7171 | -0.5529 | 0.4243 | -0.6858 | -0.6683 | 0.2881 | 0.1243 | -0.4976 | -0.8585 | 0.49718151 |
| 9 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 0.1996 |   Inf | 2.9169 | 11079655803.4473 | 0.6116 | 3.1777 | -3.6771 | 0.8243 | 0.7171 | -0.5529 | 0.4243 | -0.6858 | -0.6683 | 0.2881 | 0.1243 | -0.4976 | -0.8585 | 0.49718599 |
| 10 | -344.537 | 27.9741 | 12.5604 | 14.8100 | 0.5203 | 2.0787 | 1.7132 | 0.9090 |   Inf | 3.5455 | -7.2670 | 0.7471 | 0.9593 | -0.2792 | 0.0431 | -0.2640 | -0.8316 | 0.4886 | -0.1006 | -0.4801 | -0.8714 | 17.54951196 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.130e+03 | 2.106e+03 |
| 2 | 9.610e+02 | 9.614e+02 |
| 3 | 6.131e+02 | 6.135e+02 |
| 4 | 3.117e+02 | 3.203e+02 |
| 5 | 1.577e+02 | 1.567e+02 |
| 6 | 2.667e+01 | 2.664e+01 |
| 7 | 7.035e+00 | 8.572e+00 |
| 8 | 2.253e+00 | 2.800e+00 |
| 9 | 1.465e+00 | 1.351e+00 |
| 10 | 1.147e+00 | 1.143e+00 |
| 11 | 5.234e-01 | 5.869e-01 |
| 12 | 1.427e-01 | 1.747e-01 |
| 13 | -6.563e-01 | 8.367e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 25165.3297, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000000 |
| 2 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000059 |
| 3 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000090 |
| 4 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000085 |
| 5 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000091 |
| 6 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000146 |
| 7 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000121 |
| 8 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000076 |
| 9 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000082 |
| 10 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 0.5929 | 3.1723 | 0.2038 | 23.5462 | 2.7855 |   Inf | -3.9901 | 0.8160 | 0.6837 | 0.6673 | -0.2956 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.00000113 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.301e+04 | 1.307e+04 |
| 2 | 2.782e+03 | 2.775e+03 |
| 3 | 8.705e+02 | 8.705e+02 |
| 4 | 6.733e+02 | 6.778e+02 |
| 5 | 1.818e+02 | 1.801e+02 |
| 6 | 3.816e+01 | 3.923e+01 |
| 7 | 2.665e+01 | 2.662e+01 |
| 8 | 3.089e+00 | 3.127e+00 |
| 9 | 1.414e+00 | 1.378e+00 |
| 10 | 1.070e+00 | 1.158e+00 |
| 11 | 5.757e-01 | 5.905e-01 |
| 12 | 1.175e-01 | 1.811e-01 |
| 13 | -9.577e-02 | 8.381e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 155987.0959, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -338.888 | 14.3886 | 2.6775 | 15.9236 |   Inf | 2.7855 | 23.5462 | 0.2038 | 3.1723 | 0.5929 | -3.9901 | 0.8160 | -0.7211 | 0.5552 | -0.4144 | 0.1124 | -0.4965 | -0.8607 | -0.6837 | -0.6673 | 0.2956 | 0.00000000 |
| 2 | -338.888 | 14.3886 | 2.6775 | 15.9236 |   Inf | 2.7855 | 23.5462 | 0.2038 | 3.1723 | 0.5929 | -3.9901 | 0.8160 | -0.7211 | 0.5552 | -0.4144 | 0.1124 | -0.4965 | -0.8607 | -0.6837 | -0.6673 | 0.2956 | 0.00000104 |
| 3 | -338.888 | 14.3886 | 2.6775 | 15.9236 |   Inf | 2.7855 | 23.5462 | 0.2038 | 3.1723 | 0.5929 | -3.9901 | 0.8160 | -0.7211 | 0.5552 | -0.4144 | 0.1124 | -0.4965 | -0.8607 | -0.6837 | -0.6673 | 0.2956 | 0.00000127 |
| 4 | -338.888 | 14.3886 | 2.6775 | 15.9236 |   Inf | 2.7855 | 23.5462 | 0.2038 | 3.1723 | 0.5929 | -3.9901 | 0.8160 | -0.7211 | 0.5552 | -0.4144 | 0.1124 | -0.4965 | -0.8607 | -0.6837 | -0.6673 | 0.2956 | 0.00000210 |
| 5 | -338.888 | 14.3886 | 2.6775 | 15.9236 |   Inf | 2.7855 | 23.5462 | 0.2038 | 3.1723 | 0.5929 | -3.9901 | 0.8160 | -0.7211 | 0.5552 | -0.4144 | 0.1124 | -0.4965 | -0.8607 | -0.6837 | -0.6673 | 0.2956 | 0.00000129 |
| 6 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 416146.9232 | 2.9169 |   Inf | 0.1996 | 3.1777 | 0.6116 | -3.6771 | 0.8243 | -0.7171 | 0.5529 | -0.4243 | 0.1243 | -0.4976 | -0.8585 | -0.6858 | -0.6683 | 0.2881 | 0.49718880 |
| 7 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 367381.9139 | 2.9169 |   Inf | 0.1996 | 3.1777 | 0.6116 | -3.6770 | 0.8243 | -0.7171 | 0.5529 | -0.4243 | 0.1243 | -0.4976 | -0.8585 | -0.6858 | -0.6683 | 0.2881 | 0.49718672 |
| 8 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 226662.8959 | 2.9169 |   Inf | 0.1996 | 3.1777 | 0.6116 | -3.6771 | 0.8243 | -0.7171 | 0.5529 | -0.4243 | 0.1243 | -0.4976 | -0.8585 | -0.6858 | -0.6683 | 0.2881 | 0.49718514 |
| 9 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 135353.0574 | 2.9169 |   Inf | 0.1996 | 3.1777 | 0.6116 | -3.6771 | 0.8243 | -0.7171 | 0.5529 | -0.4243 | 0.1243 | -0.4976 | -0.8585 | -0.6858 | -0.6683 | 0.2881 | 0.49718485 |
| 10 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 126643.1560 | 2.9169 |   Inf | 0.1996 | 3.1777 | 0.6116 | -3.6771 | 0.8243 | -0.7171 | 0.5529 | -0.4243 | 0.1243 | -0.4976 | -0.8585 | -0.6858 | -0.6683 | 0.2881 | 0.49718711 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.139e+03 | 3.104e+03 |
| 2 | 8.762e+02 | 8.746e+02 |
| 3 | 8.288e+02 | 8.299e+02 |
| 4 | 1.747e+02 | 1.713e+02 |
| 5 | 4.465e+01 | 4.254e+01 |
| 6 | 2.761e+01 | 2.747e+01 |
| 7 | 3.660e+00 | 2.205e+01 |
| 8 | 1.723e+00 | 3.055e+00 |
| 9 | 1.472e+00 | 1.366e+00 |
| 10 | 6.019e-01 | 1.149e+00 |
| 11 | 4.132e-01 | 5.892e-01 |
| 12 | -2.167e+00 | 1.746e-01 |
| 13 | -1.397e+01 | 8.362e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 37115.9562, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 3.1723 | 0.5929 |   Inf | 2.7855 | 23.5462 | 0.2038 | -3.9901 | 0.8160 | -0.1124 | 0.4965 | 0.8607 | 0.6837 | 0.6673 | -0.2956 | -0.7211 | 0.5552 | -0.4144 | 0.00000000 |
| 2 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 3.1723 | 0.5929 |   Inf | 2.7855 | 23.5462 | 0.2038 | -3.9901 | 0.8160 | -0.1124 | 0.4965 | 0.8607 | 0.6837 | 0.6673 | -0.2956 | -0.7211 | 0.5552 | -0.4144 | 0.00000076 |
| 3 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 3.1723 | 0.5929 |   Inf | 2.7855 | 23.5462 | 0.2038 | -3.9901 | 0.8160 | -0.1124 | 0.4965 | 0.8607 | 0.6837 | 0.6673 | -0.2956 | -0.7211 | 0.5552 | -0.4144 | 0.00000080 |
| 4 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 31653862.1243 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718763 |
| 5 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 563432725.2307 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718706 |
| 6 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 1161464.8459 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718817 |
| 7 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 653681.9755 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718521 |
| 8 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 325876.4396 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718978 |
| 9 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 273182.9779 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718754 |
| 10 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.6116 | 257722.0551 | 2.9169 |   Inf | 0.1996 | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.6858 | 0.6683 | -0.2881 | -0.7171 | 0.5529 | -0.4243 | 0.49718598 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 9.255e+03 | 8.559e+03 |
| 2 | 1.196e+03 | 1.166e+03 |
| 3 | 8.160e+02 | 7.999e+02 |
| 4 | 2.184e+02 | 2.370e+02 |
| 5 | 5.174e+01 | 1.017e+02 |
| 6 | 2.712e+01 | 2.670e+01 |
| 7 | 9.968e+00 | 2.628e+01 |
| 8 | 2.433e+00 | 3.045e+00 |
| 9 | 1.320e+00 | 1.373e+00 |
| 10 | 1.150e+00 | 1.157e+00 |
| 11 | 5.959e-01 | 5.889e-01 |
| 12 | 1.179e-01 | 1.736e-01 |
| 13 | -2.283e+01 | 8.333e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 102711.6815, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 3.1723 | 0.2038 | 0.5929 | 2.7855 |   Inf | 23.5462 | -3.9901 | 0.8160 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000000 |
| 2 | -338.888 | 14.3886 | 2.6775 | 15.9236 | 3.1723 | 0.2038 | 0.5929 | 2.7855 |   Inf | 23.5462 | -3.9901 | 0.8160 | -0.1124 | 0.4965 | 0.8607 | 0.7211 | -0.5552 | 0.4144 | 0.6837 | 0.6673 | -0.2956 | 0.00000048 |
| 3 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.1996 | 0.6116 | 2.9169 | 179139.6781 |   Inf | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.7171 | -0.5529 | 0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49718714 |
| 4 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.1996 | 0.6116 | 2.9169 | 123501.3494 |   Inf | -3.6770 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.7171 | -0.5529 | 0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49719342 |
| 5 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.1996 | 0.6116 | 2.9169 | 17624.9928 |   Inf | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.7171 | -0.5529 | 0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49719039 |
| 6 | -338.979 | 14.3670 | 2.6072 | 15.5654 | 3.1777 | 0.1996 | 0.6116 | 2.9169 | 7187.4750 |   Inf | -3.6771 | 0.8243 | -0.1243 | 0.4976 | 0.8585 | 0.7171 | -0.5529 | 0.4243 | 0.6858 | 0.6683 | -0.2881 | 0.49719343 |
| 7 | -347.287 | 20.8270 | -3.7973 | 20.9818 | 3.1536 | 0.1983 | 0.4970 | 2.2770 |   Inf | 9.3564 | -6.4096 | 0.7575 | 0.0740 | 0.3527 | 0.9328 | 0.9491 | -0.3120 | 0.0427 | 0.3061 | 0.8822 | -0.3578 | 10.74504479 |
| 8 | -347.899 | 21.7884 | -4.2284 | 20.7504 | 2.9364 | 0.3952 | 0.4657 | 2.2050 | 0.9933 |   Inf | -7.8087 | 0.7348 | 0.0804 | 0.3312 | 0.9401 | 0.9393 | -0.3408 | 0.0397 | 0.3335 | 0.8799 | -0.3385 | 12.15296659 |
| 9 | -349.236 | 15.7517 | -0.8202 | 8.9919 | 1.6404 | 0.2031 | 0.8313 |   Inf | 5.4999 | 9.2923 | -3.3683 | 1.0000 | -0.3472 | 0.5401 | 0.7667 | 0.6830 | -0.4146 | 0.6013 | 0.6426 | 0.7324 | -0.2249 | 7.94871718 |
| 10 | -349.386 | 14.2737 | 4.2542 | 16.7370 | 2.7513 | 0.5153 | 4.2339 | 2.4809 | 5.3060 |   Inf | -9.1457 | 0.7662 | 0.0107 | 0.4671 | 0.8841 | 0.7290 | 0.6016 | -0.3266 | -0.6845 | 0.6480 | -0.3341 | 6.66833160 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0902, max_pdist=0.4972 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.155e+04 | 1.044e+04 |
| 2 | 1.505e+03 | 1.806e+03 |
| 3 | 8.493e+02 | 8.583e+02 |
| 4 | 3.501e+02 | 4.640e+02 |
| 5 | 8.672e+01 | 1.676e+02 |
| 6 | 2.689e+01 | 3.300e+01 |
| 7 | 4.405e+00 | 2.659e+01 |
| 8 | 1.881e+00 | 3.111e+00 |
| 9 | 1.338e+00 | 1.377e+00 |
| 10 | 6.311e-01 | 1.157e+00 |
| 11 | 4.931e-01 | 5.904e-01 |
| 12 | -9.197e-03 | 1.814e-01 |
| 13 | -3.348e+02 | 8.372e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 124723.9388, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -342.262 | 28.4287 | 4.5996 | 120.0096 | 1.8568 | 4.0939 | 22.5566 | 0.4114 |   Inf | 21.4964 | -3.6623 | 1.0000 | 0.9111 | -0.4121 | -0.0112 | 0.4115 | 0.9076 | 0.0829 | -0.0240 | -0.0801 | 0.9965 | 0.00000000 |
| 2 | -342.262 | 28.4287 | 4.5996 | 120.0096 | 1.8568 | 4.0939 | 22.5566 | 0.4114 |   Inf | 21.4964 | -3.6623 | 1.0000 | 0.9111 | -0.4121 | -0.0112 | 0.4115 | 0.9076 | 0.0829 | -0.0240 | -0.0801 | 0.9965 | 0.00000031 |
| 3 | -349.449 | 31.7303 | 5.3712 | 141.7284 | 3.4239 | 4.9883 |   Inf | 0.5736 | 3.7675 | 20.0481 | -3.1159 | 1.0000 | 0.8604 | -0.5060 | -0.0612 | 0.5045 | 0.8626 | -0.0385 | 0.0722 | 0.0022 | 0.9974 | 22.00373733 |
| 4 | -350.324 | 31.9674 | 9.1228 | 142.0009 | 2.4835 | 6.6779 |   Inf | 1.7065 | 1.8543 | 300369.1860 | -2.9603 | 1.0000 | 0.8642 | -0.4947 | -0.0919 | 0.4964 | 0.8681 | -0.0056 | 0.0826 | -0.0408 | 0.9957 | 22.82243908 |
| 5 | -350.324 | 5.8992 | 21.9953 | -172.3388 | 2.4835 | 6.6779 |   Inf | 1.7065 | 1.8544 | 6927441677.2815 | -2.9603 | 1.0000 | 0.8642 | -0.4947 | -0.0919 | 0.4964 | 0.8681 | -0.0056 | 0.0826 | -0.0408 | 0.9958 | 293.73804859 |
| 6 | -350.324 | 115.3015 | -32.0206 | 1146.8194 |   Inf | 6.6778 | 1.7063 | 0.0000 | 1.8545 | 2.4837 | -2.9603 | 1.0000 | 0.0826 | -0.0408 | 0.9957 | 0.4964 | 0.8681 | -0.0056 | -0.8642 | 0.4948 | 0.0919 | 2046175.93619198 |
| 7 | -351.063 | 25.1803 | 2.5985 | 135.3995 | 1.2670 | 4.0787 | 43.5142 | 3.2660 | 8.0252 |   Inf | -2.3335 | 1.0000 | 0.9541 | -0.2918 | -0.0669 | 0.2979 | 0.9475 | 0.1164 | 0.0294 | -0.1310 | 0.9909 | 16.05638359 |
| 8 | -351.260 | 26.2919 | 7.3428 | 132.6775 | 1.3485 | 5.0253 |   Inf | 2.3277 | 3.3652 | 25.6548 | -3.0151 | 1.0000 | 0.9433 | -0.3246 | -0.0692 | 0.3282 | 0.9433 | 0.0499 | 0.0491 | -0.0698 | 0.9964 | 13.30982938 |
| 9 | -353.718 | 66.8437 | -132.3430 | 999.5336 | 1.5558 | 4.1285 | 151.2158 | 55589217591516328.0000 |   Inf | 82576047393.8943 | -18.9905 | 1.0000 | 0.9357 | -0.3391 | -0.0976 | 0.3496 | 0.9282 | 0.1274 | 0.0473 | -0.1533 | 0.9870 | 891.08496273 |
| 10 | -354.330 | 22.1031 | 2.3842 | 125.4916 | 17.5607 | 4.0279 | 28.7654 | 0.2714 |   Inf | 22.6295 | -1.6980 | 1.0000 | -0.9823 | 0.1862 | 0.0197 | 0.1870 | 0.9709 | 0.1498 | -0.0088 | -0.1509 | 0.9885 | 9.20025039 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=7.1874, max_pdist=22.0037 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.854e+03 | 3.816e+03 |
| 2 | 1.238e+03 | 1.252e+03 |
| 3 | 6.131e+02 | 6.157e+02 |
| 4 | 5.916e+02 | 5.914e+02 |
| 5 | 3.068e+02 | 3.045e+02 |
| 6 | 1.214e+02 | 1.213e+02 |
| 7 | 5.483e+01 | 5.396e+01 |
| 8 | 5.678e+00 | 5.816e+00 |
| 9 | 3.359e+00 | 4.832e+00 |
| 10 | 7.287e-01 | 1.974e+00 |
| 11 | 7.626e-03 | 3.085e-01 |
| 12 | -4.096e+00 | 6.825e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 559014.9466, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -342.262 | 28.4287 | 4.5996 | 120.0096 |   Inf | 21.4964 | 1.8568 | 4.0939 | 22.5566 | 0.4114 | -3.6623 | 1.0000 | -0.4115 | -0.9076 | -0.0829 | 0.0240 | 0.0801 | -0.9965 | 0.9111 | -0.4121 | -0.0112 | 0.00000000 |
| 2 | -346.936 | 31.2057 | 4.5402 | 116.5424 | 3.6007 | 21.2596 |   Inf | 4.3564 | 21.5470 | 0.1591 | -2.9823 | 1.0000 | -0.5012 | -0.8641 | -0.0458 | 0.0124 | 0.0458 | -0.9989 | 0.8653 | -0.5012 | -0.0122 | 5.95342274 |
| 3 | -348.521 | 29.6054 | 5.1522 | 111.7927 | 3.6368 | 22.2333 |   Inf | 4.2587 | 22.1028 | 0.4035 | -3.1709 | 1.0000 | -0.4616 | -0.8866 | -0.0301 | -0.0152 | 0.0418 | -0.9990 | 0.8870 | -0.4607 | -0.0328 | 8.35641093 |
| 4 | -350.324 | 30.4934 | 9.8507 | 124.2274 | 1.8543 | 192902094.6988 | 2.4835 | 6.6779 |   Inf | 1.7065 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9957 | 0.8642 | -0.4947 | -0.0919 | 7.34095790 |
| 5 | -350.324 | 36.5171 | 6.8761 | 196.8624 | 1.8543 | 249453.9296 | 2.4835 | 6.6779 |   Inf | 1.7065 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9957 | 0.8642 | -0.4947 | -0.0919 | 77.33835284 |
| 6 | -350.324 | 39.6694 | 5.3195 | 234.8732 | 1.8543 | 23684.4366 | 2.4835 | 6.6779 |   Inf | 1.7065 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9957 | 0.8642 | -0.4947 | -0.0919 | 115.43302477 |
| 7 | -350.324 | 30.9675 | 9.6166 | 129.9434 | 1.8543 | 440808.4438 | 2.4835 | 6.6779 |   Inf | 1.7065 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9957 | 0.8642 | -0.4947 | -0.0919 | 11.59992425 |
| 8 | -350.324 | 33.8342 | 8.2010 | 164.5108 | 1.8543 | 116187.7060 | 2.4835 | 6.6779 |   Inf | 1.7065 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9957 | 0.8642 | -0.4947 | -0.0919 | 45.02007386 |
| 9 | -350.324 | 52.7784 | -1.1538 | 392.9503 | 1.8543 | 1390.0788 | 2.4834 | 6.6779 |   Inf | 1.7065 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9958 | 0.8642 | -0.4947 | -0.0919 | 274.09286999 |
| 10 | -350.324 | 62.3282 | -5.8695 | 508.0917 | 1.8543 | 532037.1160 | 2.4836 | 6.6779 |   Inf | 1.7064 | -2.9603 | 1.0000 | -0.4964 | -0.8681 | 0.0056 | -0.0826 | 0.0408 | -0.9957 | 0.8642 | -0.4947 | -0.0919 | 389.70597380 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.2587, max_pdist=8.3564 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.247e+04 | 2.942e+04 |
| 2 | 5.208e+03 | 9.342e+02 |
| 3 | 1.343e+03 | 6.198e+02 |
| 4 | 8.445e+02 | 3.511e+02 |
| 5 | 5.937e+02 | 1.422e+02 |
| 6 | 3.366e+02 | 8.308e+01 |
| 7 | 1.263e+02 | 6.469e+01 |
| 8 | 9.231e+00 | 3.079e+01 |
| 9 | 1.877e+00 | 5.371e+00 |
| 10 | 3.623e-01 | 2.041e+00 |
| 11 | -3.478e-02 | 3.100e-01 |
| 12 | -8.166e+02 | 6.838e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 4302099.3557, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 6131811014.4251 | 3.0771 | 60.4542 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000000 |
| 2 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 80618573794748848.0000 | 3.0771 | 60.4542 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000074 |
| 3 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 3456494.0955 | 3.0771 | 60.4543 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000058 |
| 4 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 1096817.8624 | 3.0771 | 60.4542 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000169 |
| 5 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 709413.4235 | 3.0771 | 60.4542 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000149 |
| 6 | -339.522 | 14.4311 | 2.0642 | 13.3569 | 0.7180 | 240551.3780 | 3.0771 | 60.4558 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000791 |
| 7 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 176392.7444 | 3.0771 | 60.4524 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00001732 |
| 8 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 136965.2202 | 3.0771 | 60.4542 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000734 |
| 9 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 125866.8133 | 3.0771 | 60.4542 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00000811 |
| 10 | -339.522 | 14.4311 | 2.0641 | 13.3569 | 0.7180 | 123115.7945 | 3.0771 | 60.4544 | 0.2286 | 4.3178 | -2.0535 | 1.0000 | 0.6987 | 0.6615 | -0.2725 | -0.6977 | 0.5459 | -0.4639 | -0.1581 | 0.5142 | 0.8430 | 0.00001106 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 7.834e+03 | 7.168e+03 |
| 2 | 6.855e+02 | 6.846e+02 |
| 3 | 5.316e+02 | 5.326e+02 |
| 4 | 1.283e+02 | 1.259e+02 |
| 5 | 1.721e+01 | 1.942e+01 |
| 6 | 6.562e+00 | 1.170e+01 |
| 7 | 3.460e+00 | 4.793e+00 |
| 8 | 8.736e-01 | 3.423e+00 |
| 9 | 8.554e-02 | 1.395e+00 |
| 10 | 5.854e-02 | 3.317e-01 |
| 11 | -1.982e-14 | 1.261e-01 |
| 12 | -6.626e-01 | 4.871e-02 |
| 13 | -8.395e+01 | 3.730e-14 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 192151468277119680.0000, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P1__bd_pd1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000000 |
| 2 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000055 |
| 3 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000128 |
| 4 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000078 |
| 5 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000052 |
| 6 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000040 |
| 7 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000086 |
| 8 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000121 |
| 9 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000231 |
| 10 | -357.152 | 17.4533 | 131.2669 | 2.2896 | 19.0851 | 3.2811 | 27.9962 | -2.3044 | 1.0000 | -0.9991 | -0.0420 | 0.0420 | -0.9991 | 0.00000017 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P1__bd_pd1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.063e+04 | 1.084e+04 |
| 2 | 9.155e+02 | 9.205e+02 |
| 3 | 3.710e+02 | 3.728e+02 |
| 4 | 3.047e+02 | 3.033e+02 |
| 5 | 5.648e+01 | 5.644e+01 |
| 6 | 1.354e+01 | 1.357e+01 |
| 7 | 9.625e-01 | 9.576e-01 |
| 8 | 7.768e-03 | 7.756e-03 |

numDeriv::hessian (operative): cond = 1368179.4582, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1397078.1229, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P1__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -361.072 | 15.0208 | 125.8600 | 26.5302 |   Inf | 21.9160 | 2.4095 | -1.7770 | 1.0000 | -0.0425 | 0.9991 | -0.9991 | -0.0425 | 0.00000000 |
| 2 | -361.072 | 15.0208 | 125.8600 | 26.5302 |   Inf | 21.9160 | 2.4095 | -1.7770 | 1.0000 | -0.0425 | 0.9991 | -0.9991 | -0.0425 | 0.00000079 |
| 3 | -361.072 | 15.0208 | 125.8600 | 26.5302 |   Inf | 21.9160 | 2.4095 | -1.7770 | 1.0000 | -0.0425 | 0.9991 | -0.9991 | -0.0425 | 0.00000190 |
| 4 | -361.072 | 15.0208 | 125.8600 | 26.5302 |   Inf | 21.9160 | 2.4095 | -1.7770 | 1.0000 | -0.0425 | 0.9991 | -0.9991 | -0.0425 | 0.00000213 |
| 5 | -370.063 | 18.2256 | 106.3039 | 24.4310 | 2.8039 |   Inf | 3.3274 | -1.2971 | 1.0000 | -0.0613 | 0.9981 | -0.9981 | -0.0613 | 19.82641520 |
| 6 | -370.063 | 18.2256 | 106.3039 | 24.4310 | 2.8039 |   Inf | 3.3274 | -1.2971 | 1.0000 | -0.0613 | 0.9981 | -0.9981 | -0.0613 | 19.82641612 |
| 7 | -370.063 | 18.2256 | 106.3039 | 24.4310 | 2.8039 |   Inf | 3.3274 | -1.2971 | 1.0000 | -0.0613 | 0.9981 | -0.9981 | -0.0613 | 19.82641523 |
| 8 | -370.063 | 18.2256 | 106.3039 | 24.4310 | 2.8039 |   Inf | 3.3274 | -1.2971 | 1.0000 | -0.0613 | 0.9981 | -0.9981 | -0.0613 | 19.82641613 |
| 9 | -370.063 | 18.2256 | 106.3039 | 24.4310 | 2.8039 |   Inf | 3.3274 | -1.2971 | 1.0000 | -0.0613 | 0.9981 | -0.9981 | -0.0613 | 19.82641475 |
| 10 | -370.063 | 18.2256 | 106.3039 | 24.4310 | 2.8039 |   Inf | 3.3274 | -1.2971 | 1.0000 | -0.0613 | 0.9981 | -0.9981 | -0.0613 | 19.82641592 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P1__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.265e+03 | 3.175e+03 |
| 2 | 5.901e+02 | 5.889e+02 |
| 3 | 3.152e+02 | 3.148e+02 |
| 4 | 2.414e+02 | 2.399e+02 |
| 5 | 1.763e+01 | 1.763e+01 |
| 6 | 6.478e-01 | 6.448e-01 |
| 7 | 7.966e-03 | 7.899e-03 |

numDeriv::hessian (operative): cond = 409797.3234, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 401913.3329, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: T1_P1__bd_pd1

Across 17 scanned models: 14 pass Flag A (convergence), 1 pass strict Flag B, 2 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **2**.

**Why models fail Flag A.** Of the 3 models that fail Flag A: **2** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **1** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance would additionally qualify 1 model(s)** (those combine Flag A convergence with a Hessian that is positive-definite only under the relaxed tolerance).

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 10 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_P2_P3, T2_noP, T2_P2_P3, T2_P2, T2_T3_noP, T3_noP)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T1_P1__bd_pd1_sigL2`
- **pBIC (Ω):** 767.5
- **logLik:** -361.0715
- **Variables:** T1, P1
- **Free parameters (n_free):** 7
- **Boundary mask:** pd=Inf, sigltil2=Inf

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.4264
- **Threshold:** 0.5366
- **Sensitivity:** 0.8119
- **Specificity:** 0.6144
- **Presences / pseudo-absences:** 336 / 319
- **Prevalence:** 0.5122

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | 15.0208, 125.8600 |
| sigltil | 26.5302,   Inf |
| sigrtil | 21.9160, 2.4095 |
| ctil | -1.7770 |
| pd | 1.0000 |
| o_mat | -0.0425, 0.9991, -0.9991, -0.0425 |

### Profile likelihoods and arc check

- **Arc check:** 7/7 parameters pass → **ALL PASS ✓**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | PASS | pass |
| mu2 | PASS | pass |
| sigltil1 | PASS | pass |
| sigrtil1 | PASS | pass |
| sigrtil2 | PASS | pass |
| ctil | PASS | pass |
| o_par1 | PASS | pass |

## Profile likelihood plots

![Profile likelihood plots for the best model (T1_P1__bd_pd1_sigL2)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T1_P1__bd_pd1_sigL2` (pBIC = 767.5)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 130
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 01:58:20_

# xsdm v6 — Model selection report (Algorithm2)

**Species:** *Acris blanchardi*

This report documents, step by step, the literal Algorithm2 selection rules
applied to this species. Each phase (L1–L4) includes the rule itself and
the complete list of models with their classification.

**Definition of model success:** a model has `status == "success"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.

## Data and units

- Species directory: `/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_berti_sample_smoke/Acris_blanchardi`
- Sample size: 655
- Maximum variables per model: 3
- Tau (τ): 25.9385
- L2 threshold: best L1 + τ = 844.7766
- Ω threshold: 838.2938
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
| 1 | T3_P3 ≤τ | T3+P3 | 818.8 | -380.238 | 9 | success |
| 2 | T2_P3 ≤τ | T2+P3 | 819.8 | -380.711 | 9 | success |
| 3 | T2_P1 ≤τ | T2+P1 | 823.2 | -382.435 | 9 | success |
| 4 | T1_P3 ≤τ | T1+P3 | 823.9 | -382.768 | 9 | success |
| 5 | T3_P2 ≤τ | T3+P2 | 825.1 | -383.383 | 9 | success |
| 6 | T2_T3_P3 ≤τ | T2+T3+P3 | 826.7 | -367.934 | 14 | success |
| 7 | T1_P2 ≤τ | T1+P2 | 827.1 | -384.367 | 9 | success |
| 8 | T1_P1 ≤τ | T1+P1 | 830.4 | -386.000 | 9 | success |
| 9 | T2_T3_P1 ≤τ | T2+T3+P1 | 831.8 | -370.527 | 14 | success |
| 10 | T2_P2 ≤τ | T2+P2 | 838.9 | -390.286 | 9 | success |
| 11 | T2_T3_noP ≤τ | T2+T3 | 840.1 | -390.885 | 9 | success |
| 12 | T3_P2_P3 ≤τ | T3+P2+P3 | 840.5 | -374.849 | 14 | success |
| 13 | T1_P2_P3 ≤τ | T1+P2+P3 | 840.8 | -375.006 | 14 | success |
| 14 | T2_T3_P2 ≤τ | T2+T3+P2 | 841.8 | -375.497 | 14 | success |
| 15 | T3_P1 ≤τ | T3+P1 | 843.1 | -392.370 | 9 | success |
| 16 | T1_noP | T1 | 846.9 | -407.242 | 5 | success |
| 17 | T2_noP | T2 | 848.2 | -407.876 | 5 | success |
| 18 | T2_P2_P3 | T2+P2+P3 | 854.5 | -381.848 | 14 | success |
| 19 | T3_noP | T3 | 861.1 | -414.361 | 5 | success |
| 20 | noT_P2 | P2 | 899.2 | -433.410 | 5 | success |
| 21 | noT_P2_P3 | P2+P3 | 902.3 | -421.973 | 9 | success |
| 22 | noT_P3 | P3 | 905.4 | -436.502 | 5 | success |
| 23 | noT_P1 | P1 | 907.9 | -437.738 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 844.8**.
**Eligible L1 models:** 15 (T1_P1, T1_P2_P3, T1_P2, T1_P3, T2_P1, T2_P2, T2_P3, T2_T3_noP, T2_T3_P1, T2_T3_P2, T2_T3_P3, T3_P1, T3_P2_P3, T3_P2, T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_P1__bd_pd1_sigR1 | 812.4 | -383.481 | 7 | success |
| T2_P1__bd_pd1_sigR2 | 812.4 | -383.481 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 812.4 | -383.481 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 812.4 | -383.481 | 7 | success |
| T2_P3__bd_sigR2 | 813.3 | -380.708 | 8 | success |
| T2_P3__bd_sigR1 | 813.4 | -380.744 | 8 | success |
| T2_T3_P3__bd_pd1_sigR1 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigL1 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 814.5 | -368.354 | 12 | success |
| T2_P3__bd_sigL1 | 815.1 | -381.614 | 8 | success |
| T1_P3__bd_pd1_sigL1 | 815.9 | -385.261 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 815.9 | -385.261 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 815.9 | -385.261 | 7 | success |
| T1_P3__bd_pd1_sigR1 | 815.9 | -385.261 | 7 | success |
| T2_T3_P3__bd_sigR3 | 816.3 | -366.014 | 13 | success |
| T2_P1__bd_sigL2 | 816.7 | -382.435 | 8 | success |
| T2_P1__bd_sigR1 | 816.7 | -382.435 | 8 | success |
| T2_P1__bd_sigR2 | 816.7 | -382.435 | 8 | success |
| T2_P1__bd_sigL1 | 816.7 | -382.435 | 8 | success |
| T1_P3__bd_sigR1 | 817.7 | -382.889 | 8 | success |
| T1_P3__bd_sigR2 | 817.7 | -382.889 | 8 | success |
| T1_P3__bd_sigL1 | 817.7 | -382.889 | 8 | success |
| T1_P3__bd_sigL2 | 817.7 | -382.889 | 8 | success |
| T2_T3_P3__bd_sigL3 | 818.5 | -367.120 | 13 | success |
| T3_P2__bd_sigL1 | 818.6 | -383.377 | 8 | success |
| T3_P2__bd_sigR2 | 818.6 | -383.379 | 8 | success |
| T3_P2__bd_sigL2 | 818.6 | -383.382 | 8 | success |
| T3_P2__bd_sigR1 | 818.7 | -383.393 | 8 | success |
| T2_P1__bd_pd1 | 818.8 | -383.481 | 8 | success |
| T2_P3__bd_sigL2 | 819.5 | -383.799 | 8 | success |
| T2_T3_P3__bd_sigR2 | 820.2 | -367.934 | 13 | success |
| T2_T3_P3__bd_sigL1 | 820.2 | -367.934 | 13 | success |
| T2_T3_P3__bd_sigL2 | 820.2 | -367.934 | 13 | success |
| T2_T3_P3__bd_sigR1 | 820.2 | -367.934 | 13 | success |
| T1_P2__bd_sigL1 | 820.6 | -384.367 | 8 | success |
| T1_P2__bd_sigL2 | 820.6 | -384.367 | 8 | success |
| T1_P2__bd_sigR1 | 820.6 | -384.367 | 8 | success |
| T1_P2__bd_sigR2 | 820.6 | -384.367 | 8 | success |
| T2_T3_P3__bd_pd1 | 821.0 | -368.354 | 13 | success |
| T3_P3__bd_sigL1 | 821.5 | -384.803 | 8 | success |
| T3_P3__bd_sigR1 | 821.5 | -384.803 | 8 | success |
| T3_P3__bd_sigR2 | 821.5 | -384.803 | 8 | success |
| T3_P3__bd_sigL2 | 821.5 | -384.803 | 8 | success |
| T2_P3__bd_pd1_sigR1 | 821.9 | -388.234 | 7 | success |
| T2_P3__bd_pd1_sigL2 | 821.9 | -388.234 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 821.9 | -388.234 | 7 | success |
| T2_P3__bd_pd1_sigR2 | 821.9 | -388.234 | 7 | success |
| T1_P3__bd_pd1 | 822.4 | -385.261 | 8 | success |
| T1_P2__bd_pd1_sigR2 | 822.6 | -388.611 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 822.6 | -388.611 | 7 | success |
| T1_P2__bd_pd1_sigL1 | 822.6 | -388.611 | 7 | success |
| T1_P2__bd_pd1_sigL2 | 822.6 | -388.611 | 7 | success |
| T2_T3_P1__bd_pd1_sigR2 | 824.0 | -373.115 | 12 | success |
| T2_T3_P1__bd_pd1_sigL1 | 824.0 | -373.115 | 12 | success |
| T3_P3__bd_pd1 | 824.5 | -386.290 | 8 | success |
| T1_P1__bd_pd1_sigL1 | 826.3 | -390.435 | 7 | success |
| T1_P1__bd_pd1_sigR1 | 826.3 | -390.435 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 826.3 | -390.435 | 7 | success |
| T1_P1__bd_pd1_sigL2 | 826.3 | -390.435 | 7 | success |
| T3_P3__bd_pd1_sigR1 | 826.8 | -390.723 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 826.8 | -390.723 | 7 | success |
| T3_P3__bd_pd1_sigR2 | 826.8 | -390.723 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 826.8 | -390.723 | 7 | success |
| T2_P2__bd_pd1_sigL2 | 827.2 | -390.903 | 7 | success |
| T2_P2__bd_pd1_sigL1 | 827.2 | -390.903 | 7 | success |
| T2_P2__bd_pd1_sigR1 | 827.2 | -390.903 | 7 | success |
| T2_P2__bd_pd1_sigR2 | 827.2 | -390.903 | 7 | success |
| T1_P1__bd_sigR1 | 827.2 | -387.678 | 8 | success |
| T1_P1__bd_sigR2 | 827.2 | -387.678 | 8 | success |
| T1_P1__bd_sigL2 | 827.2 | -387.678 | 8 | success |
| T1_P1__bd_sigL1 | 827.2 | -387.678 | 8 | success |
| T2_T3_P1__bd_sigR2 | 828.0 | -371.830 | 13 | success |
| T2_P3__bd_pd1 | 828.3 | -388.234 | 8 | success |
| T2_T3_P1__bd_sigL1 | 828.4 | -372.031 | 13 | success |
| T2_T3_P1__bd_sigL2 | 828.4 | -372.031 | 13 | success |
| T1_P2__bd_pd1 | 829.1 | -388.611 | 8 | success |
| T3_P2__bd_pd1_sigL1 | 829.5 | -392.054 | 7 | success |
| T1_P1__bd_pd1 | 830.3 | -389.233 | 8 | success |
| T2_T3_P1__bd_pd1 | 830.5 | -373.115 | 13 | success |
| T2_T3_P1__bd_sigL3 | 830.9 | -373.280 | 13 | success |
| T2_T3_P1__bd_sigR1 | 831.2 | -373.460 | 13 | success |
| T3_P2__bd_pd1_sigL2 | 831.3 | -392.945 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 831.3 | -392.945 | 7 | success |
| T3_P2__bd_pd1_sigR2 | 831.3 | -392.945 | 7 | success |
| T2_T3_P1__bd_sigR3 | 831.4 | -373.534 | 13 | success |
| T2_T3_P2__bd_pd1_sigL3 | 831.4 | -376.792 | 12 | success |
| T2_T3_P2__bd_pd1_sigL2 | 831.4 | -376.792 | 12 | success |
| T2_T3_P2__bd_pd1_sigL1 | 831.6 | -376.875 | 12 | success |
| T2_T3_P2__bd_pd1_sigR2 | 831.6 | -376.875 | 12 | success |
| T2_T3_P2__bd_pd1_sigR1 | 831.6 | -376.875 | 12 | success |
| T2_T3_P1__bd_pd1_sigL3 | 832.4 | -377.269 | 12 | success |
| T2_P2__bd_sigL2 | 832.8 | -390.453 | 8 | success |
| T2_P2__bd_sigR1 | 832.8 | -390.453 | 8 | success |
| T2_P2__bd_sigL1 | 832.8 | -390.453 | 8 | success |
| T2_P2__bd_sigR2 | 832.8 | -390.453 | 8 | success |
| T2_T3_P1__bd_pd1_sigL2 | 832.8 | -377.490 | 12 | success |
| T2_T3_P1__bd_pd1_sigR3 | 832.8 | -377.490 | 12 | success |
| T2_T3_P2__bd_pd1_sigR3 | 832.9 | -377.524 | 12 | success |
| T2_T3_P1__bd_pd1_sigR1 | 833.0 | -377.579 | 12 | success |
| T2_P2__bd_pd1 | 833.7 | -390.903 | 8 | success |
| T3_P2_P3__bd_sigL1 | 834.0 | -374.844 | 13 | success |
| T3_P2_P3__bd_sigR1 | 834.0 | -374.845 | 13 | success |
| T3_P2_P3__bd_sigR2 | 834.0 | -374.848 | 13 | success |
| T3_P2_P3__bd_sigR3 | 834.0 | -374.856 | 13 | success |
| T3_P2_P3__bd_sigL3 | 834.0 | -374.856 | 13 | success |
| T3_P2_P3__bd_sigL2 | 834.0 | -374.857 | 13 | success |
| T1_P2_P3__bd_sigR1 | 834.3 | -375.011 | 13 | success |
| T1_P2_P3__bd_sigR2 | 834.3 | -375.012 | 13 | success |
| T1_P2_P3__bd_sigL1 | 834.3 | -375.016 | 13 | success |
| T1_P2_P3__bd_sigL2 | 834.3 | -375.022 | 13 | success |
| T1_P2_P3__bd_sigR3 | 834.3 | -375.024 | 13 | success |
| T1_P2_P3__bd_sigL3 | 834.4 | -375.028 | 13 | success |
| T3_P1__bd_sigR2 | 835.1 | -391.618 | 8 | success |
| T2_T3_P2__bd_sigL3 | 835.3 | -375.516 | 13 | success |
| T3_P1__bd_sigL2 | 836.6 | -392.374 | 8 | success |
| T3_P1__bd_sigR1 | 836.6 | -392.375 | 8 | success |
| T3_P2__bd_pd1 | 837.8 | -392.945 | 8 | success |
| T2_T3_P2__bd_sigL1 | 837.9 | -376.800 | 13 | success |
| T2_T3_P2__bd_pd1 | 838.1 | -376.875 | 13 | success |
| T2_T3_noP__bd_pd1_sigL1 | 838.2 | -396.423 | 7 | success |
| T2_T3_noP__bd_pd1_sigR1 | 838.2 | -396.423 | 7 | success |
| T2_T3_noP__bd_pd1_sigL2 | 838.2 | -396.423 | 7 | success |
| T2_T3_noP__bd_pd1_sigR2 | 838.2 | -396.423 | 7 | success |
| T2_T3_P2__bd_sigL2 | 838.3 | -377.019 | 13 | success |
| T2_T3_P2__bd_sigR3 | 839.0 | -377.371 | 13 | success |
| T3_P2_P3__bd_pd1_sigL2 | 840.1 | -381.158 | 12 | success |
| T2_T3_P2__bd_sigR1 | 840.5 | -378.084 | 13 | success |
| T3_P1__bd_pd1_sigL2 | 840.5 | -397.541 | 7 | success |
| T3_P1__bd_pd1_sigL1 | 840.5 | -397.541 | 7 | success |
| T3_P1__bd_pd1_sigR1 | 840.5 | -397.541 | 7 | success |
| T3_P1__bd_pd1_sigR2 | 840.5 | -397.541 | 7 | success |
| T3_P2_P3__bd_pd1_sigL3 | 840.7 | -381.440 | 12 | success |
| T3_P2_P3__bd_pd1_sigL1 | 840.7 | -381.440 | 12 | success |
| T3_P2_P3__bd_pd1_sigR2 | 840.8 | -381.475 | 12 | success |
| T3_P2_P3__bd_pd1_sigR1 | 840.8 | -381.480 | 12 | success |
| T3_P1__bd_pd1 | 841.2 | -394.675 | 8 | success |
| T1_P2_P3__bd_pd1_sigL1 | 841.7 | -381.919 | 12 | success |
| T1_P2_P3__bd_pd1_sigL3 | 841.7 | -381.920 | 12 | success |
| T2_noP__bd_pd1 | 841.7 | -407.876 | 4 | success |
| T1_P2_P3__bd_pd1_sigR3 | 842.1 | -382.153 | 12 | success |
| T1_P2_P3__bd_pd1_sigR1 | 842.1 | -382.153 | 12 | success |
| T1_P2_P3__bd_pd1_sigR2 | 842.1 | -382.153 | 12 | success |
| T1_P2_P3__bd_pd1_sigL2 | 842.1 | -382.153 | 12 | success |
| T2_T3_noP__bd_sigL1 | 842.3 | -395.221 | 8 | success |
| T2_T3_noP__bd_sigL2 | 842.3 | -395.221 | 8 | success |
| T2_T3_noP__bd_sigR1 | 842.3 | -395.221 | 8 | success |
| T2_T3_noP__bd_sigR2 | 842.3 | -395.221 | 8 | success |
| T2_T3_P2__bd_sigR2 | 842.8 | -379.234 | 13 | success |
| T3_P2_P3__bd_pd1_sigR3 | 843.0 | -382.595 | 12 | success |
| T2_T3_noP__bd_pd1 | 844.7 | -396.423 | 8 | success |
| T3_P2_P3__bd_pd1 | 847.2 | -381.437 | 13 | success |
| T1_P2_P3__bd_pd1 | 848.1 | -381.920 | 13 | success |
| T3_P1__bd_sigL1 | 849.0 | -398.549 | 8 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_P1__bd_pd1_sigR1 | 812.4 | yes ✓ | ✓ | ✓ | 8.33e+02 | 6 |
| 2 | T2_P1__bd_pd1_sigR2 | 812.4 | yes ✓ | ✓ | ✓ | 8.29e+02 | 4 |
| 3 | T2_P1__bd_pd1_sigL1 | 812.4 | yes ✓ | ✓ | ✓ | 8.29e+02 | 6 |
| 4 | T2_P1__bd_pd1_sigL2 | 812.4 | yes ✓ | ✓ | ✓ | 8.29e+02 | 7 |
| 5 | T2_P3__bd_sigR2 | 813.3 | no | ✗ | ✗ | Inf | 1 |
| 6 | T2_P3__bd_sigR1 | 813.4 | no | ✗ | ✗ | Inf | 1 |
| 7 | T2_T3_P3__bd_pd1_sigR1 | 814.5 | no | ✓ | ✗ | Inf | 14 |
| 8 | T2_T3_P3__bd_pd1_sigL2 | 814.5 | no | ✓ | ✗ | Inf | 9 |
| 9 | T2_T3_P3__bd_pd1_sigR2 | 814.5 | no | ✓ | ✗ | Inf | 6 |
| 10 | T2_T3_P3__bd_pd1_sigL1 | 814.5 | no | ✓ | ✗ | Inf | 5 |
| 11 | T2_T3_P3__bd_pd1_sigL3 | 814.5 | no | ✓ | ✗ | Inf | 6 |
| 12 | T2_T3_P3__bd_pd1_sigR3 | 814.5 | no | ✓ | ✗ | Inf | 8 |
| 13 | T2_P3__bd_sigL1 | 815.1 | no | ✗ | ✗ | Inf | 1 |
| 14 | T1_P3__bd_pd1_sigL1 | 815.9 | yes ✓ | ✓ | ✓ | 3.50e+04 | 7 |
| 15 | T1_P3__bd_pd1_sigL2 | 815.9 | yes ✓ | ✓ | ✓ | 3.49e+04 | 13 |
| 16 | T1_P3__bd_pd1_sigR2 | 815.9 | yes ✓ | ✓ | ✓ | 3.54e+04 | 8 |
| 17 | T1_P3__bd_pd1_sigR1 | 815.9 | yes ✓ | ✓ | ✓ | 3.49e+04 | 5 |
| 18 | T2_T3_P3__bd_sigR3 | 816.3 | no | ✗ | ✗ | Inf | 1 |
| 19 | T2_P1__bd_sigL2 | 816.7 | yes ✓ | ✓ | ✓ | 5.83e+03 | 8 |
| 20 | T2_P1__bd_sigR1 | 816.7 | yes ✓ | ✓ | ✓ | 6.51e+03 | 6 |
| 21 | T2_P1__bd_sigR2 | 816.7 | yes ✓ | ✓ | ✓ | 6.79e+03 | 6 |
| 22 | T2_P1__bd_sigL1 | 816.7 | yes ✓ | ✓ | ✓ | 8.15e+03 | 3 |
| 23 | T1_P3__bd_sigR1 | 817.7 | yes ✓ | ✓ | ✓ | 1.27e+05 | 11 |
| 24 | T1_P3__bd_sigR2 | 817.7 | yes ✓ | ✓ | ✓ | 1.23e+05 | 12 |
| 25 | T1_P3__bd_sigL1 | 817.7 | yes ✓ | ✓ | ✓ | 1.17e+05 | 16 |
| 26 | T1_P3__bd_sigL2 | 817.7 | yes ✓ | ✓ | ✓ | 1.45e+05 | 8 |
| 27 | T2_T3_P3__bd_sigL3 | 818.5 | no | ✗ | ✗ | Inf | 1 |
| 28 | T3_P2__bd_sigL1 | 818.6 | no | ✗ | ✗ | Inf | 1 |
| 29 | T3_P2__bd_sigR2 | 818.6 | no | ✗ | ✗ | Inf | 1 |
| 30 | T3_P2__bd_sigL2 | 818.6 | no | ✗ | ✗ | Inf | 1 |
| 31 | T3_P2__bd_sigR1 | 818.7 | no | ✗ | ✗ | Inf | 1 |
| 32 | T3_P3 | 818.8 | no | ✗ | ✗ | Inf | 1 |
| 33 | T2_P1__bd_pd1 | 818.8 | no | ✓ | ✗ | 3.17e+12 | 21 |
| 34 | T2_P3__bd_sigL2 | 819.5 | no | ✓ | ✗ | Inf | 5 |
| 35 | T2_P3 | 819.8 | no | ✗ | ✗ | Inf | 1 |
| 36 | T2_T3_P3__bd_sigR2 | 820.2 | no | ✓ | ✗ | Inf | 7 |
| 37 | T2_T3_P3__bd_sigL1 | 820.2 | no | ✓ | ✗ | Inf | 6 |
| 38 | T2_T3_P3__bd_sigL2 | 820.2 | no | ✗ | ✗ | Inf | 1 |
| 39 | T2_T3_P3__bd_sigR1 | 820.2 | no | ✓ | ✗ | Inf | 4 |
| 40 | T1_P2__bd_sigL1 | 820.6 | no | ✓ | ✗ | Inf | 10 |
| 41 | T1_P2__bd_sigL2 | 820.6 | no | ✓ | ✗ | Inf | 3 |
| 42 | T1_P2__bd_sigR1 | 820.6 | no | ✓ | ✗ | Inf | 6 |
| 43 | T1_P2__bd_sigR2 | 820.6 | no | ✓ | ✗ | 6.07e+08 | 8 |
| 44 | T2_T3_P3__bd_pd1 | 821.0 | no | ✓ | ✗ | Inf | 13 |
| 45 | T3_P3__bd_sigL1 | 821.5 | yes ✓ | ✓ | ✓ | 6.01e+04 | 9 |
| 46 | T3_P3__bd_sigR1 | 821.5 | yes ✓ | ✓ | ✓ | 2.82e+04 | 10 |
| 47 | T3_P3__bd_sigR2 | 821.5 | no | ✓ | ✗ | Inf | 10 |
| 48 | T3_P3__bd_sigL2 | 821.5 | no | ✓ | ✗ | Inf | 7 |
| 49 | T2_P3__bd_pd1_sigR1 | 821.9 | yes ✓ | ✓ | ✓ | 7.24e+03 | 9 |
| 50 | T2_P3__bd_pd1_sigL2 | 821.9 | yes ✓ | ✓ | ✓ | 6.79e+03 | 5 |
| 51 | T2_P3__bd_pd1_sigL1 | 821.9 | yes ✓ | ✓ | ✓ | 7.25e+03 | 8 |
| 52 | T2_P3__bd_pd1_sigR2 | 821.9 | yes ✓ | ✓ | ✓ | 6.81e+03 | 7 |
| 53 | T1_P3__bd_pd1 | 822.4 | no | ✓ | ✗ | 3.29e+20 | 22 |
| 54 | T1_P2__bd_pd1_sigR2 | 822.6 | no | ✓ | ✗ | 2.47e+17 | 19 |
| 55 | T1_P2__bd_pd1_sigR1 | 822.6 | no | ✓ | ✗ | 8.13e+17 | 17 |
| 56 | T1_P2__bd_pd1_sigL1 | 822.6 | no | ✓ | ✗ | 1.54e+18 | 14 |
| 57 | T1_P2__bd_pd1_sigL2 | 822.6 | no | ✓ | ✗ | 2.37e+12 | 12 |
| 58 | T2_P1 | 823.2 | no | ✓ | ✗ | 7.12e+15 | 24 |
| 59 | T1_P3 | 823.9 | no | ✓ | ✗ | Inf | 3 |
| 60 | T2_T3_P1__bd_pd1_sigR2 | 824.0 | no | ✗ | ✗ | 1.95e+07 | 1 |
| 61 | T2_T3_P1__bd_pd1_sigL1 | 824.0 | no | ✗ | ✗ | Inf | 1 |
| 62 | T3_P3__bd_pd1 | 824.5 | yes ✓ | ✓ | ✓ | 1.59e+04 | 22 |
| 63 | T3_P2 | 825.1 | no | ✗ | ✗ | Inf | 1 |
| 64 | T1_P1__bd_pd1_sigL1 | 826.3 | yes ✓ | ✓ | ✓ | 6.30e+05 | 4 |
| 65 | T1_P1__bd_pd1_sigR1 | 826.3 | yes ✓ | ✓ | ✓ | 6.68e+05 | 4 |
| 66 | T1_P1__bd_pd1_sigR2 | 826.3 | no | ✓ | ✗ | Inf | 5 |
| 67 | T1_P1__bd_pd1_sigL2 | 826.3 | yes ✓ | ✓ | ✓ | 6.66e+05 | 5 |
| 68 | T2_T3_P3 | 826.7 | no | ✓ | ✗ | Inf | 11 |
| 69 | T3_P3__bd_pd1_sigR1 | 826.8 | yes ✓ | ✓ | ✓ | 7.88e+03 | 9 |
| 70 | T3_P3__bd_pd1_sigL2 | 826.8 | yes ✓ | ✓ | ✓ | 7.83e+03 | 11 |
| 71 | T3_P3__bd_pd1_sigR2 | 826.8 | yes ✓ | ✓ | ✓ | 7.82e+03 | 7 |
| 72 | T3_P3__bd_pd1_sigL1 | 826.8 | yes ✓ | ✓ | ✓ | 7.82e+03 | 8 |
| 73 | T1_P2 | 827.1 | no | ✓ | ✗ | Inf | 16 |
| 74 | T2_P2__bd_pd1_sigL2 | 827.2 | yes ✓ | ✓ | ✓ | 3.24e+04 | 4 |
| 75 | T2_P2__bd_pd1_sigL1 | 827.2 | no | ✗ | ✓ | 3.26e+04 | 2 |
| 76 | T2_P2__bd_pd1_sigR1 | 827.2 | no | ✗ | ✓ | 3.26e+04 | 2 |
| 77 | T2_P2__bd_pd1_sigR2 | 827.2 | no | ✓ | ✗ | Inf | 4 |
| 78 | T1_P1__bd_sigR1 | 827.2 | no | ✓ | ✗ | Inf | 7 |
| 79 | T1_P1__bd_sigR2 | 827.2 | no | ✓ | ✗ | 2.44e+07 | 7 |
| 80 | T1_P1__bd_sigL2 | 827.2 | no | ✓ | ✗ | Inf | 5 |
| 81 | T1_P1__bd_sigL1 | 827.2 | no | ✓ | ✗ | Inf | 4 |
| 82 | T2_T3_P1__bd_sigR2 | 828.0 | no | ✗ | ✗ | Inf | 1 |
| 83 | T2_P3__bd_pd1 | 828.3 | no | ✓ | ✗ | Inf | 25 |
| 84 | T2_T3_P1__bd_sigL1 | 828.4 | no | ✗ | ✗ | Inf | 2 |
| 85 | T2_T3_P1__bd_sigL2 | 828.4 | no | ✗ | ✗ | Inf | 1 |
| 86 | T1_P2__bd_pd1 | 829.1 | no | ✓ | ✗ | Inf | 23 |
| 87 | T3_P2__bd_pd1_sigL1 | 829.5 | no | ✗ | ✗ | Inf | 1 |
| 88 | T1_P1__bd_pd1 | 830.3 | no | ✓ | ✗ | Inf | 5 |
| 89 | T1_P1 | 830.4 | no | ✓ | ✗ | Inf | 13 |
| 90 | T2_T3_P1__bd_pd1 | 830.5 | no | ✓ | ✗ | 1.76e+12 | 3 |
| 91 | T2_T3_P1__bd_sigL3 | 830.9 | no | ✗ | ✗ | Inf | 1 |
| 92 | T2_T3_P1__bd_sigR1 | 831.2 | no | ✗ | ✗ | Inf | 1 |
| 93 | T3_P2__bd_pd1_sigL2 | 831.3 | yes ✓ | ✓ | ✓ | 7.54e+04 | 7 |
| 94 | T3_P2__bd_pd1_sigR1 | 831.3 | yes ✓ | ✓ | ✓ | 7.30e+04 | 7 |
| 95 | T3_P2__bd_pd1_sigR2 | 831.3 | yes ✓ | ✓ | ✓ | 7.47e+04 | 13 |
| 96 | T2_T3_P1__bd_sigR3 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 97 | T2_T3_P2__bd_pd1_sigL3 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 98 | T2_T3_P2__bd_pd1_sigL2 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 99 | T2_T3_P2__bd_pd1_sigL1 | 831.6 | no | ✗ | ✗ | Inf | 2 |
| 100 | T2_T3_P2__bd_pd1_sigR2 | 831.6 | no | ✗ | ✗ | 1.64e+06 | 1 |
| 101 | T2_T3_P2__bd_pd1_sigR1 | 831.6 | no | ✗ | ✗ | Inf | 1 |
| 102 | T2_T3_P1 | 831.8 | no | ✗ | ✗ | Inf | 1 |
| 103 | T2_T3_P1__bd_pd1_sigL3 | 832.4 | no | ✗ | ✗ | Inf | 1 |
| 104 | T2_P2__bd_sigL2 | 832.8 | no | ✓ | ✗ | 1.23e+17 | 7 |
| 105 | T2_P2__bd_sigR1 | 832.8 | no | ✓ | ✗ | Inf | 8 |
| 106 | T2_P2__bd_sigL1 | 832.8 | no | ✓ | ✗ | 7.99e+17 | 3 |
| 107 | T2_P2__bd_sigR2 | 832.8 | no | ✓ | ✗ | 4.40e+12 | 10 |
| 108 | T2_T3_P1__bd_pd1_sigL2 | 832.8 | no | ✗ | ✗ | Inf | 2 |
| 109 | T2_T3_P1__bd_pd1_sigR3 | 832.8 | no | ✗ | ✗ | 2.27e+07 | 1 |
| 110 | T2_T3_P2__bd_pd1_sigR3 | 832.9 | no | ✓ | ✗ | Inf | 5 |
| 111 | T2_T3_P1__bd_pd1_sigR1 | 833.0 | no | ✓ | ✗ | Inf | 3 |
| 112 | T2_P2__bd_pd1 | 833.7 | no | ✓ | ✗ | Inf | 16 |
| 113 | T3_P2_P3__bd_sigL1 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 114 | T3_P2_P3__bd_sigR1 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 115 | T3_P2_P3__bd_sigR2 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 116 | T3_P2_P3__bd_sigR3 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 117 | T3_P2_P3__bd_sigL3 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 118 | T3_P2_P3__bd_sigL2 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 119 | T1_P2_P3__bd_sigR1 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 120 | T1_P2_P3__bd_sigR2 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 121 | T1_P2_P3__bd_sigL1 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 122 | T1_P2_P3__bd_sigL2 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 123 | T1_P2_P3__bd_sigR3 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 124 | T1_P2_P3__bd_sigL3 | 834.4 | no | ✗ | ✗ | Inf | 1 |
| 125 | T3_P1__bd_sigR2 | 835.1 | no | ✗ | ✗ | Inf | 1 |
| 126 | T2_T3_P2__bd_sigL3 | 835.3 | no | ✗ | ✗ | Inf | 1 |
| 127 | T3_P1__bd_sigL2 | 836.6 | no | ✗ | ✗ | Inf | 1 |
| 128 | T3_P1__bd_sigR1 | 836.6 | no | ✗ | ✗ | Inf | 1 |
| 129 | T3_P2__bd_pd1 | 837.8 | no | ✓ | ✗ | Inf | 24 |
| 130 | T2_T3_P2__bd_sigL1 | 837.9 | no | ✗ | ✗ | Inf | 2 |
| 131 | T2_T3_P2__bd_pd1 | 838.1 | no | ✓ | ✗ | Inf | 5 |
| 132 | T2_T3_noP__bd_pd1_sigL1 | 838.2 | no | ✗ | ✓ | 4.37e+04 | 2 |
| 133 | T2_T3_noP__bd_pd1_sigR1 | 838.2 | no | ✓ | ✗ | Inf | 4 |
| 134 | T2_T3_noP__bd_pd1_sigL2 | 838.2 | no | ✗ | ✓ | 4.18e+04 | 2 |
| 135 | T2_T3_noP__bd_pd1_sigR2 | 838.2 | no | ✗ | ✓ | 4.18e+04 | 1 |
| 136 | T2_T3_P2__bd_sigL2 | 838.3 | no | ✗ | ✓ | 6.31e+04 | 1 |
| 137 | T2_P2 | 838.9 | no | ✗ | ✗ | Inf | 1 |
| 138 | T2_T3_P2__bd_sigR3 | 839.0 | no | ✗ | ✗ | 9.76e+11 | 1 |
| 139 | T2_T3_noP | 840.1 | no | ✗ | ✗ | Inf | 1 |
| 140 | T3_P2_P3__bd_pd1_sigL2 | 840.1 | no | ✗ | ✗ | Inf | 1 |
| 141 | T2_T3_P2__bd_sigR1 | 840.5 | no | ✗ | ✗ | Inf | 1 |
| 142 | T3_P1__bd_pd1_sigL2 | 840.5 | no | ✓ | ✗ | Inf | 6 |
| 143 | T3_P1__bd_pd1_sigL1 | 840.5 | no | ✓ | ✗ | 5.60e+06 | 8 |
| 144 | T3_P1__bd_pd1_sigR1 | 840.5 | no | ✓ | ✗ | 5.52e+06 | 4 |
| 145 | T3_P1__bd_pd1_sigR2 | 840.5 | no | ✓ | ✗ | Inf | 10 |
| 146 | T3_P2_P3 | 840.5 | no | ✗ | ✗ | Inf | 1 |
| 147 | T3_P2_P3__bd_pd1_sigL3 | 840.7 | no | ✗ | ✓ | 5.05e+05 | 2 |
| 148 | T3_P2_P3__bd_pd1_sigL1 | 840.7 | no | ✗ | ✓ | 7.80e+05 | 2 |
| 149 | T3_P2_P3__bd_pd1_sigR2 | 840.8 | no | ✗ | ✓ | 6.13e+05 | 1 |
| 150 | T3_P2_P3__bd_pd1_sigR1 | 840.8 | no | ✗ | ✗ | 9.27e+13 | 1 |
| 151 | T1_P2_P3 | 840.8 | no | ✗ | ✗ | Inf | 1 |
| 152 | T3_P1__bd_pd1 | 841.2 | no | ✓ | ✗ | 3.86e+06 | 19 |
| 153 | T1_P2_P3__bd_pd1_sigL1 | 841.7 | no | ✗ | ✗ | Inf | 1 |
| 154 | T1_P2_P3__bd_pd1_sigL3 | 841.7 | no | ✗ | ✗ | Inf | 1 |
| 155 | T2_noP__bd_pd1 | 841.7 | no | ✓ | ✗ | Inf | 25 |
| 156 | T2_T3_P2 | 841.8 | no | ✗ | ✗ | Inf | 1 |
| 157 | T1_P2_P3__bd_pd1_sigR3 | 842.1 | no | ✓ | ✗ | 3.91e+17 | 6 |
| 158 | T1_P2_P3__bd_pd1_sigR1 | 842.1 | no | ✓ | ✗ | 6.02e+17 | 7 |
| 159 | T1_P2_P3__bd_pd1_sigR2 | 842.1 | no | ✓ | ✗ | Inf | 13 |
| 160 | T1_P2_P3__bd_pd1_sigL2 | 842.1 | no | ✓ | ✗ | 1.10e+12 | 5 |
| 161 | T2_T3_noP__bd_sigL1 | 842.3 | no | ✗ | ✗ | Inf | 2 |
| 162 | T2_T3_noP__bd_sigL2 | 842.3 | no | ✓ | ✗ | Inf | 3 |
| 163 | T2_T3_noP__bd_sigR1 | 842.3 | no | ✗ | ✗ | Inf | 1 |
| 164 | T2_T3_noP__bd_sigR2 | 842.3 | no | ✓ | ✗ | Inf | 3 |
| 165 | T2_T3_P2__bd_sigR2 | 842.8 | no | ✗ | ✗ | Inf | 1 |
| 166 | T3_P2_P3__bd_pd1_sigR3 | 843.0 | no | ✓ | ✗ | 7.16e+11 | 5 |
| 167 | T3_P1 | 843.1 | no | ✗ | ✗ | Inf | 1 |
| 168 | T2_T3_noP__bd_pd1 | 844.7 | no | ✓ | ✗ | Inf | 6 |
| 169 | T1_noP | 846.9 | yes ✓ | ✓ | ✓ | 2.65e+03 | 23 |
| 170 | T3_P2_P3__bd_pd1 | 847.2 | no | ✗ | ✗ | 1.11e+06 | 2 |
| 171 | T1_P2_P3__bd_pd1 | 848.1 | no | ✗ | ✗ | Inf | 1 |
| 172 | T2_noP | 848.2 | no | ✓ | ✗ | Inf | 24 |
| 173 | T3_P1__bd_sigL1 | 849.0 | no | ✗ | ✗ | Inf | 1 |
| 174 | T2_P2_P3 | 854.5 | no | ✗ | ✗ | Inf | 1 |
| 175 | T3_noP | 861.1 | no | ✗ | ✗ | Inf | 1 |
| 176 | noT_P2 | 899.2 | no | ✗ | ✗ | Inf | 1 |
| 177 | noT_P2_P3 | 902.3 | no | ✗ | ✗ | Inf | 1 |
| 178 | noT_P3 | 905.4 | no | ✗ | ✗ | Inf | 1 |
| 179 | noT_P1 | 907.9 | no | ✗ | ✗ | Inf | 1 |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T2_P1__bd_pd1_sigR1` — **Ω = 812.4**

## L3 supplementary appendices — per-model diagnostics

### T2_P1__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -383.481 | 23.6084 | 12.6830 | 0.9212 | 4.2888 |   Inf | 1.7188 | -1.2150 | 1.0000 | 0.8406 | 0.5417 | -0.5417 | 0.8406 | 0.00000000 |
| 2 | -383.481 | 23.6084 | 12.6830 | 0.9212 | 4.2888 |   Inf | 1.7188 | -1.2150 | 1.0000 | 0.8406 | 0.5417 | -0.5417 | 0.8406 | 0.00000026 |
| 3 | -383.481 | 23.6084 | 12.6830 | 0.9212 | 4.2888 |   Inf | 1.7188 | -1.2150 | 1.0000 | 0.8406 | 0.5417 | -0.5417 | 0.8406 | 0.00000011 |
| 4 | -383.481 | 23.6084 | 12.6830 | 0.9212 | 4.2888 |   Inf | 1.7188 | -1.2150 | 1.0000 | 0.8406 | 0.5417 | -0.5417 | 0.8406 | 0.00000026 |
| 5 | -383.481 | 23.6084 | 12.6830 | 0.9212 | 4.2888 |   Inf | 1.7188 | -1.2150 | 1.0000 | 0.8406 | 0.5417 | -0.5417 | 0.8406 | 0.00000010 |
| 6 | -383.481 | 23.6084 | 12.6830 | 0.9212 | 4.2888 |   Inf | 1.7188 | -1.2150 | 1.0000 | 0.8406 | 0.5417 | -0.5417 | 0.8406 | 0.00000047 |
| 7 | -386.730 | 23.1067 | 14.2371 | 0.6387 | 2.4081 |   Inf | 2.9542 | -1.1488 | 1.0000 | 0.9256 | -0.3785 | 0.3785 | 0.9256 | 2.16849134 |
| 8 | -386.730 | 23.1067 | 14.2371 | 0.6387 | 2.4081 |   Inf | 2.9542 | -1.1488 | 1.0000 | 0.9256 | -0.3785 | 0.3785 | 0.9256 | 2.16849145 |
| 9 | -386.730 | 23.1067 | 14.2371 | 0.6387 | 2.4081 |   Inf | 2.9542 | -1.1488 | 1.0000 | 0.9256 | -0.3785 | 0.3785 | 0.9256 | 2.16849161 |
| 10 | -386.730 | 23.1067 | 14.2371 | 0.6387 | 2.4081 |   Inf | 2.9542 | -1.1488 | 1.0000 | 0.9256 | -0.3785 | 0.3785 | 0.9256 | 2.16849150 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P1__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.702e+02 | 4.714e+02 |
| 2 | 3.653e+02 | 3.655e+02 |
| 3 | 1.776e+02 | 1.776e+02 |
| 4 | 2.773e+01 | 2.820e+01 |
| 5 | 1.572e+01 | 1.573e+01 |
| 6 | 1.388e+00 | 1.352e+00 |
| 7 | 5.643e-01 | 5.789e-01 |

numDeriv::hessian (operative): cond = 833.2342, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 814.4372, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: none

Across 1 scanned models: 1 pass Flag A (convergence), 1 pass strict Flag B, 1 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 0 models that fail Flag A: **0** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **0** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 8 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T2_noP, T2_P2_P3, T3_noP)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T2_P1__bd_pd1_sigR1`
- **pBIC (Ω):** 812.4
- **logLik:** -383.4814
- **Variables:** T2, P1
- **Free parameters (n_free):** 7
- **Boundary mask:** pd=Inf, sigrtil1=Inf

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.3270
- **Threshold:** 0.5414
- **Sensitivity:** 0.7970
- **Specificity:** 0.5300
- **Presences / pseudo-absences:** 336 / 319
- **Prevalence:** 0.5276

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | 23.6084, 12.6830 |
| sigltil | 0.9212, 4.2888 |
| sigrtil |   Inf, 1.7188 |
| ctil | -1.2150 |
| pd | 1.0000 |
| o_mat | 0.8406, 0.5417, -0.5417, 0.8406 |

### Profile likelihoods and arc check

- **Arc check:** 7/7 parameters pass → **ALL PASS ✓**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | PASS | pass |
| mu2 | PASS | pass |
| sigltil1 | PASS | pass |
| sigltil2 | PASS | pass |
| sigrtil2 | PASS | pass |
| ctil | PASS | pass |
| o_par1 | PASS | pass |

## Profile likelihood plots

![Profile likelihood plots for the best model (T2_P1__bd_pd1_sigR1)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T2_P1__bd_pd1_sigR1` (pBIC = 812.4)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 156
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 02:00:57_

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
| 2 | T2_P3 ≤τ | T2+P3 | 819.8 | -380.710 | 9 | success |
| 3 | T2_T3_P3 ≤τ | T2+T3+P3 | 822.8 | -366.010 | 14 | success |
| 4 | T2_P1 ≤τ | T2+P1 | 823.2 | -382.435 | 9 | success |
| 5 | T1_P3 ≤τ | T1+P3 | 823.9 | -382.768 | 9 | success |
| 6 | T3_P2 ≤τ | T3+P2 | 825.1 | -383.380 | 9 | success |
| 7 | T1_P2 ≤τ | T1+P2 | 827.1 | -384.367 | 9 | success |
| 8 | T1_P1 ≤τ | T1+P1 | 830.4 | -386.000 | 9 | success |
| 9 | T2_T3_P1 ≤τ | T2+T3+P1 | 831.8 | -370.527 | 14 | success |
| 10 | T2_P2 ≤τ | T2+P2 | 839.3 | -390.453 | 9 | success |
| 11 | T2_T3_noP ≤τ | T2+T3 | 840.1 | -390.883 | 9 | success |
| 12 | T3_P2_P3 ≤τ | T3+P2+P3 | 840.5 | -374.846 | 14 | success |
| 13 | T1_P2_P3 ≤τ | T1+P2+P3 | 840.8 | -375.007 | 14 | success |
| 14 | T3_P1 ≤τ | T3+P1 | 842.0 | -391.821 | 9 | success |
| 15 | T2_T3_P2 ≤τ | T2+T3+P2 | 842.8 | -376.007 | 14 | success |
| 16 | T1_noP | T1 | 846.9 | -407.242 | 5 | success |
| 17 | T2_noP | T2 | 848.2 | -407.876 | 5 | success |
| 18 | T2_P2_P3 | T2+P2+P3 | 853.7 | -381.479 | 14 | success |
| 19 | T3_noP | T3 | 861.1 | -414.361 | 5 | success |
| 20 | noT_P2 | P2 | 899.2 | -433.394 | 5 | success |
| 21 | noT_P2_P3 | P2+P3 | 902.4 | -422.032 | 9 | success |
| 22 | noT_P3 | P3 | 905.4 | -436.502 | 5 | success |
| 23 | noT_P1 | P1 | 907.9 | -437.737 | 5 | success |

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
| T2_P3__bd_sigL1 | 810.2 | -379.166 | 8 | success |
| T1_P3__bd_sigL2 | 811.4 | -379.748 | 8 | success |
| T2_P1__bd_pd1_sigR2 | 812.4 | -383.481 | 7 | success |
| T2_P1__bd_pd1_sigR1 | 812.4 | -383.481 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 812.4 | -383.481 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 812.4 | -383.481 | 7 | success |
| T2_P3__bd_sigR2 | 813.3 | -380.720 | 8 | success |
| T2_T3_P3__bd_pd1_sigR1 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigL1 | 814.5 | -368.354 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 814.5 | -368.354 | 12 | success |
| T2_P3__bd_sigL2 | 815.1 | -381.614 | 8 | success |
| T2_P3__bd_sigR1 | 815.2 | -381.654 | 8 | success |
| T2_T3_P3__bd_sigL3 | 815.8 | -365.741 | 13 | success |
| T1_P3__bd_pd1_sigL1 | 815.9 | -385.261 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 815.9 | -385.261 | 7 | success |
| T1_P3__bd_pd1_sigR1 | 815.9 | -385.261 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 815.9 | -385.261 | 7 | success |
| T2_P1__bd_sigL2 | 816.7 | -382.435 | 8 | success |
| T2_P1__bd_sigR1 | 816.7 | -382.435 | 8 | success |
| T2_P1__bd_sigL1 | 816.7 | -382.435 | 8 | success |
| T2_P1__bd_sigR2 | 816.7 | -382.435 | 8 | success |
| T3_P2__bd_sigL1 | 817.4 | -382.766 | 8 | success |
| T1_P3__bd_sigR2 | 817.7 | -382.889 | 8 | success |
| T1_P3__bd_sigR1 | 817.7 | -382.889 | 8 | success |
| T1_P3__bd_sigL1 | 817.7 | -382.889 | 8 | success |
| T2_T3_P3__bd_sigL2 | 818.3 | -367.013 | 13 | success |
| T3_P2__bd_sigR2 | 818.6 | -383.379 | 8 | success |
| T3_P2__bd_sigL2 | 818.6 | -383.381 | 8 | success |
| T3_P2__bd_sigR1 | 818.6 | -383.383 | 8 | success |
| T2_P1__bd_pd1 | 818.8 | -383.481 | 8 | success |
| T2_T3_P3__bd_sigL1 | 820.2 | -367.934 | 13 | success |
| T2_T3_P3__bd_sigR1 | 820.2 | -367.934 | 13 | success |
| T2_T3_P3__bd_sigR2 | 820.2 | -367.934 | 13 | success |
| T2_T3_P3__bd_sigR3 | 820.2 | -367.934 | 13 | success |
| T1_P2__bd_sigR1 | 820.6 | -384.367 | 8 | success |
| T1_P2__bd_sigR2 | 820.6 | -384.367 | 8 | success |
| T1_P2__bd_sigL1 | 820.6 | -384.367 | 8 | success |
| T1_P2__bd_sigL2 | 820.6 | -384.367 | 8 | success |
| T2_T3_P3__bd_pd1 | 821.0 | -368.354 | 13 | success |
| T3_P3__bd_sigR1 | 821.5 | -384.803 | 8 | success |
| T3_P3__bd_sigR2 | 821.5 | -384.803 | 8 | success |
| T3_P3__bd_sigL2 | 821.5 | -384.803 | 8 | success |
| T3_P3__bd_sigL1 | 821.5 | -384.803 | 8 | success |
| T2_P3__bd_pd1_sigL1 | 821.9 | -388.234 | 7 | success |
| T2_P3__bd_pd1_sigR1 | 821.9 | -388.234 | 7 | success |
| T2_P3__bd_pd1_sigL2 | 821.9 | -388.234 | 7 | success |
| T2_P3__bd_pd1_sigR2 | 821.9 | -388.234 | 7 | success |
| T1_P3__bd_pd1 | 822.4 | -385.261 | 8 | success |
| T1_P2__bd_pd1_sigL1 | 822.6 | -388.611 | 7 | success |
| T1_P2__bd_pd1_sigR2 | 822.6 | -388.611 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 822.6 | -388.611 | 7 | success |
| T1_P2__bd_pd1_sigL2 | 822.6 | -388.611 | 7 | success |
| T2_T3_P1__bd_pd1_sigR2 | 824.0 | -373.115 | 12 | success |
| T2_T3_P1__bd_pd1_sigL1 | 824.0 | -373.115 | 12 | success |
| T2_T3_P1__bd_pd1_sigL3 | 824.0 | -373.115 | 12 | success |
| T2_T3_P1__bd_pd1_sigR1 | 824.0 | -373.115 | 12 | success |
| T3_P3__bd_pd1 | 824.5 | -386.290 | 8 | success |
| T1_P1__bd_pd1_sigL2 | 826.3 | -390.435 | 7 | success |
| T1_P1__bd_pd1_sigR1 | 826.3 | -390.435 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 826.3 | -390.435 | 7 | success |
| T1_P1__bd_pd1_sigL1 | 826.3 | -390.435 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 826.8 | -390.723 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 826.8 | -390.723 | 7 | success |
| T3_P3__bd_pd1_sigR2 | 826.8 | -390.723 | 7 | success |
| T3_P3__bd_pd1_sigR1 | 826.8 | -390.723 | 7 | success |
| T2_P2__bd_pd1_sigR1 | 827.2 | -390.903 | 7 | success |
| T2_P2__bd_pd1_sigL1 | 827.2 | -390.903 | 7 | success |
| T2_P2__bd_pd1_sigL2 | 827.2 | -390.903 | 7 | success |
| T2_P2__bd_pd1_sigR2 | 827.2 | -390.903 | 7 | success |
| T1_P1__bd_sigR1 | 827.2 | -387.678 | 8 | success |
| T1_P1__bd_sigL2 | 827.2 | -387.678 | 8 | success |
| T1_P1__bd_sigR2 | 827.2 | -387.678 | 8 | success |
| T1_P1__bd_sigL1 | 827.2 | -387.678 | 8 | success |
| T2_T3_P1__bd_sigR2 | 828.0 | -371.830 | 13 | success |
| T2_P3__bd_pd1 | 828.3 | -388.234 | 8 | success |
| T2_T3_P1__bd_sigL1 | 828.4 | -372.031 | 13 | success |
| T2_T3_P1__bd_sigL2 | 828.4 | -372.031 | 13 | success |
| T2_T3_P1__bd_sigR1 | 828.4 | -372.031 | 13 | success |
| T1_P2__bd_pd1 | 829.1 | -388.611 | 8 | success |
| T3_P2__bd_pd1_sigL2 | 829.5 | -392.056 | 7 | success |
| T1_P1__bd_pd1 | 830.3 | -389.233 | 8 | success |
| T2_T3_P1__bd_pd1 | 830.5 | -373.115 | 13 | success |
| T2_T3_P1__bd_sigL3 | 830.9 | -373.280 | 13 | success |
| T2_T3_P1__bd_sigR3 | 831.2 | -373.463 | 13 | success |
| T3_P2__bd_pd1_sigR1 | 831.3 | -392.945 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 831.3 | -392.945 | 7 | success |
| T3_P2__bd_pd1_sigR2 | 831.3 | -392.945 | 7 | success |
| T2_T3_P2__bd_pd1_sigL1 | 831.4 | -376.792 | 12 | success |
| T2_T3_P2__bd_pd1_sigR1 | 831.4 | -376.792 | 12 | success |
| T2_T3_P2__bd_pd1_sigL2 | 831.4 | -376.792 | 12 | success |
| T2_T3_P2__bd_pd1_sigR3 | 831.4 | -376.792 | 12 | success |
| T2_T3_P2__bd_pd1_sigR2 | 831.6 | -376.875 | 12 | success |
| T2_T3_P2__bd_pd1_sigL3 | 831.6 | -376.875 | 12 | success |
| T2_P2__bd_sigL2 | 832.8 | -390.453 | 8 | success |
| T2_P2__bd_sigR1 | 832.8 | -390.453 | 8 | success |
| T2_P2__bd_sigR2 | 832.8 | -390.453 | 8 | success |
| T2_P2__bd_sigL1 | 832.8 | -390.453 | 8 | success |
| T2_T3_P1__bd_pd1_sigL2 | 832.8 | -377.490 | 12 | success |
| T2_T3_P1__bd_pd1_sigR3 | 832.8 | -377.490 | 12 | success |
| T3_P1__bd_sigL1 | 833.6 | -390.873 | 8 | success |
| T2_P2__bd_pd1 | 833.7 | -390.903 | 8 | success |
| T3_P2_P3__bd_sigL3 | 834.0 | -374.846 | 13 | success |
| T3_P2_P3__bd_sigR2 | 834.0 | -374.847 | 13 | success |
| T3_P2_P3__bd_sigR3 | 834.0 | -374.850 | 13 | success |
| T3_P2_P3__bd_sigL1 | 834.0 | -374.850 | 13 | success |
| T3_P2_P3__bd_sigR1 | 834.0 | -374.852 | 13 | success |
| T3_P2_P3__bd_sigL2 | 834.0 | -374.856 | 13 | success |
| T1_P2_P3__bd_sigR2 | 834.3 | -375.005 | 13 | success |
| T1_P2_P3__bd_sigR1 | 834.3 | -375.009 | 13 | success |
| T1_P2_P3__bd_sigR3 | 834.3 | -375.016 | 13 | success |
| T1_P2_P3__bd_sigL2 | 834.3 | -375.016 | 13 | success |
| T1_P2_P3__bd_sigL3 | 834.3 | -375.018 | 13 | success |
| T1_P2_P3__bd_sigL1 | 834.4 | -375.029 | 13 | success |
| T2_T3_P2__bd_sigR3 | 835.3 | -375.505 | 13 | success |
| T2_T3_P2__bd_sigL3 | 835.5 | -375.588 | 13 | success |
| T3_P1__bd_sigR2 | 836.6 | -392.367 | 8 | success |
| T3_P1__bd_sigR1 | 836.6 | -392.372 | 8 | success |
| T3_P1__bd_sigL2 | 836.6 | -392.374 | 8 | success |
| T3_P2__bd_pd1 | 837.8 | -392.945 | 8 | success |
| T2_T3_P2__bd_sigR1 | 837.9 | -376.800 | 13 | success |
| T2_T3_P2__bd_sigL2 | 837.9 | -376.800 | 13 | success |
| T2_T3_P2__bd_sigR2 | 837.9 | -376.800 | 13 | success |
| T2_T3_P2__bd_sigL1 | 837.9 | -376.800 | 13 | success |
| T2_T3_P2__bd_pd1 | 838.1 | -376.875 | 13 | success |
| T2_T3_noP__bd_pd1_sigL2 | 838.2 | -396.423 | 7 | success |
| T2_T3_noP__bd_pd1_sigR2 | 838.2 | -396.423 | 7 | success |
| T2_T3_noP__bd_pd1_sigR1 | 838.2 | -396.423 | 7 | success |
| T2_T3_noP__bd_pd1_sigL1 | 838.2 | -396.423 | 7 | success |
| T3_P1__bd_pd1_sigL1 | 840.5 | -397.541 | 7 | success |
| T3_P1__bd_pd1_sigL2 | 840.5 | -397.541 | 7 | success |
| T3_P1__bd_pd1_sigR2 | 840.5 | -397.541 | 7 | success |
| T3_P1__bd_pd1_sigR1 | 840.5 | -397.541 | 7 | success |
| T3_P2_P3__bd_pd1_sigL3 | 840.7 | -381.440 | 12 | success |
| T3_P2_P3__bd_pd1_sigR2 | 840.7 | -381.440 | 12 | success |
| T3_P2_P3__bd_pd1_sigR1 | 840.7 | -381.440 | 12 | success |
| T3_P2_P3__bd_pd1_sigR3 | 840.8 | -381.475 | 12 | success |
| T3_P2_P3__bd_pd1_sigL1 | 840.8 | -381.480 | 12 | success |
| T3_P1__bd_pd1 | 841.2 | -394.675 | 8 | success |
| T1_P2_P3__bd_pd1_sigR2 | 841.7 | -381.918 | 12 | success |
| T1_P2_P3__bd_pd1_sigL1 | 841.7 | -381.918 | 12 | success |
| T2_noP__bd_pd1 | 841.7 | -407.876 | 4 | success |
| T1_P2_P3__bd_pd1_sigR3 | 842.1 | -382.153 | 12 | success |
| T1_P2_P3__bd_pd1_sigL3 | 842.1 | -382.153 | 12 | success |
| T1_P2_P3__bd_pd1_sigR1 | 842.1 | -382.153 | 12 | success |
| T1_P2_P3__bd_pd1_sigL2 | 842.1 | -382.153 | 12 | success |
| T2_T3_noP__bd_sigR1 | 842.3 | -395.221 | 8 | success |
| T2_T3_noP__bd_sigL2 | 842.3 | -395.221 | 8 | success |
| T2_T3_noP__bd_sigR2 | 842.3 | -395.221 | 8 | success |
| T2_T3_noP__bd_sigL1 | 842.3 | -395.221 | 8 | success |
| T3_P2_P3__bd_pd1_sigL2 | 843.0 | -382.595 | 12 | success |
| T2_T3_noP__bd_pd1 | 844.7 | -396.423 | 8 | success |
| T3_P2_P3__bd_pd1 | 846.5 | -381.119 | 13 | success |
| T1_P2_P3__bd_pd1 | 848.1 | -381.919 | 13 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_P3__bd_sigL1 | 810.2 | no | ✗ | ✗ | Inf | 1 |
| 2 | T1_P3__bd_sigL2 | 811.4 | no | ✗ | ✗ | Inf | 1 |
| 3 | T2_P1__bd_pd1_sigR2 | 812.4 | yes ✓ | ✓ | ✓ | 8.29e+02 | 14 |
| 4 | T2_P1__bd_pd1_sigR1 | 812.4 | yes ✓ | ✓ | ✓ | 8.29e+02 | 13 |
| 5 | T2_P1__bd_pd1_sigL2 | 812.4 | yes ✓ | ✓ | ✓ | 8.32e+02 | 14 |
| 6 | T2_P1__bd_pd1_sigL1 | 812.4 | yes ✓ | ✓ | ✓ | 8.29e+02 | 11 |
| 7 | T2_P3__bd_sigR2 | 813.3 | no | ✗ | ✗ | Inf | 1 |
| 8 | T2_T3_P3__bd_pd1_sigR1 | 814.5 | no | ✓ | ✗ | 3.42e+15 | 29 |
| 9 | T2_T3_P3__bd_pd1_sigL3 | 814.5 | no | ✓ | ✗ | Inf | 18 |
| 10 | T2_T3_P3__bd_pd1_sigL2 | 814.5 | no | ✓ | ✗ | Inf | 23 |
| 11 | T2_T3_P3__bd_pd1_sigR3 | 814.5 | no | ✓ | ✗ | Inf | 11 |
| 12 | T2_T3_P3__bd_pd1_sigL1 | 814.5 | no | ✓ | ✗ | Inf | 17 |
| 13 | T2_T3_P3__bd_pd1_sigR2 | 814.5 | no | ✓ | ✗ | 3.01e+13 | 11 |
| 14 | T2_P3__bd_sigL2 | 815.1 | no | ✗ | ✗ | Inf | 1 |
| 15 | T2_P3__bd_sigR1 | 815.2 | no | ✗ | ✗ | Inf | 1 |
| 16 | T2_T3_P3__bd_sigL3 | 815.8 | no | ✗ | ✗ | Inf | 1 |
| 17 | T1_P3__bd_pd1_sigL1 | 815.9 | yes ✓ | ✓ | ✓ | 3.50e+04 | 14 |
| 18 | T1_P3__bd_pd1_sigL2 | 815.9 | yes ✓ | ✓ | ✓ | 3.49e+04 | 19 |
| 19 | T1_P3__bd_pd1_sigR1 | 815.9 | yes ✓ | ✓ | ✓ | 3.72e+04 | 11 |
| 20 | T1_P3__bd_pd1_sigR2 | 815.9 | yes ✓ | ✓ | ✓ | 3.54e+04 | 12 |
| 21 | T2_P1__bd_sigL2 | 816.7 | yes ✓ | ✓ | ✓ | 5.83e+03 | 19 |
| 22 | T2_P1__bd_sigR1 | 816.7 | yes ✓ | ✓ | ✓ | 6.51e+03 | 16 |
| 23 | T2_P1__bd_sigL1 | 816.7 | yes ✓ | ✓ | ✓ | 5.85e+03 | 15 |
| 24 | T2_P1__bd_sigR2 | 816.7 | yes ✓ | ✓ | ✓ | 6.79e+03 | 10 |
| 25 | T3_P2__bd_sigL1 | 817.4 | no | ✗ | ✗ | Inf | 1 |
| 26 | T1_P3__bd_sigR2 | 817.7 | yes ✓ | ✓ | ✓ | 1.51e+05 | 25 |
| 27 | T1_P3__bd_sigR1 | 817.7 | yes ✓ | ✓ | ✓ | 1.27e+05 | 23 |
| 28 | T1_P3__bd_sigL1 | 817.7 | yes ✓ | ✓ | ✓ | 1.17e+05 | 16 |
| 29 | T2_T3_P3__bd_sigL2 | 818.3 | no | ✗ | ✗ | Inf | 1 |
| 30 | T3_P2__bd_sigR2 | 818.6 | no | ✗ | ✗ | Inf | 1 |
| 31 | T3_P2__bd_sigL2 | 818.6 | no | ✗ | ✗ | Inf | 1 |
| 32 | T3_P2__bd_sigR1 | 818.6 | no | ✗ | ✗ | Inf | 1 |
| 33 | T3_P3 | 818.8 | no | ✗ | ✗ | Inf | 1 |
| 34 | T2_P1__bd_pd1 | 818.8 | no | ✓ | ✗ | Inf | 41 |
| 35 | T2_P3 | 819.8 | no | ✗ | ✗ | Inf | 1 |
| 36 | T2_T3_P3__bd_sigL1 | 820.2 | no | ✓ | ✗ | Inf | 14 |
| 37 | T2_T3_P3__bd_sigR1 | 820.2 | no | ✓ | ✗ | Inf | 9 |
| 38 | T2_T3_P3__bd_sigR2 | 820.2 | no | ✓ | ✗ | 1.46e+19 | 11 |
| 39 | T2_T3_P3__bd_sigR3 | 820.2 | no | ✓ | ✗ | Inf | 6 |
| 40 | T1_P2__bd_sigR1 | 820.6 | no | ✓ | ✗ | Inf | 10 |
| 41 | T1_P2__bd_sigR2 | 820.6 | no | ✓ | ✗ | Inf | 15 |
| 42 | T1_P2__bd_sigL1 | 820.6 | no | ✓ | ✗ | Inf | 11 |
| 43 | T1_P2__bd_sigL2 | 820.6 | no | ✓ | ✗ | Inf | 11 |
| 44 | T2_T3_P3__bd_pd1 | 821.0 | no | ✓ | ✗ | Inf | 38 |
| 45 | T3_P3__bd_sigR1 | 821.5 | no | ✓ | ✗ | Inf | 22 |
| 46 | T3_P3__bd_sigR2 | 821.5 | no | ✓ | ✗ | Inf | 22 |
| 47 | T3_P3__bd_sigL2 | 821.5 | yes ✓ | ✓ | ✓ | 2.94e+04 | 18 |
| 48 | T3_P3__bd_sigL1 | 821.5 | no | ✓ | ✗ | Inf | 9 |
| 49 | T2_P3__bd_pd1_sigL1 | 821.9 | yes ✓ | ✓ | ✓ | 6.76e+03 | 9 |
| 50 | T2_P3__bd_pd1_sigR1 | 821.9 | yes ✓ | ✓ | ✓ | 7.24e+03 | 13 |
| 51 | T2_P3__bd_pd1_sigL2 | 821.9 | yes ✓ | ✓ | ✓ | 7.20e+03 | 11 |
| 52 | T2_P3__bd_pd1_sigR2 | 821.9 | yes ✓ | ✓ | ✓ | 6.81e+03 | 11 |
| 53 | T1_P3__bd_pd1 | 822.4 | no | ✓ | ✗ | Inf | 46 |
| 54 | T1_P2__bd_pd1_sigL1 | 822.6 | no | ✓ | ✗ | Inf | 30 |
| 55 | T1_P2__bd_pd1_sigR2 | 822.6 | no | ✓ | ✗ | 2.47e+17 | 34 |
| 56 | T1_P2__bd_pd1_sigR1 | 822.6 | no | ✓ | ✗ | Inf | 31 |
| 57 | T1_P2__bd_pd1_sigL2 | 822.6 | no | ✓ | ✗ | 9.85e+12 | 30 |
| 58 | T2_T3_P3 | 822.8 | no | ✗ | ✗ | Inf | 1 |
| 59 | T2_P1 | 823.2 | no | ✓ | ✗ | Inf | 47 |
| 60 | T1_P3 | 823.9 | no | ✓ | ✗ | Inf | 6 |
| 61 | T2_T3_P1__bd_pd1_sigR2 | 824.0 | no | ✗ | ✗ | 2.01e+06 | 2 |
| 62 | T2_T3_P1__bd_pd1_sigL1 | 824.0 | no | ✗ | ✗ | Inf | 2 |
| 63 | T2_T3_P1__bd_pd1_sigL3 | 824.0 | no | ✗ | ✗ | Inf | 1 |
| 64 | T2_T3_P1__bd_pd1_sigR1 | 824.0 | no | ✗ | ✗ | 1.34e+06 | 1 |
| 65 | T3_P3__bd_pd1 | 824.5 | yes ✓ | ✓ | ✓ | 1.59e+04 | 36 |
| 66 | T3_P2 | 825.1 | no | ✗ | ✗ | Inf | 1 |
| 67 | T1_P1__bd_pd1_sigL2 | 826.3 | no | ✓ | ✗ | 5.25e+06 | 12 |
| 68 | T1_P1__bd_pd1_sigR1 | 826.3 | yes ✓ | ✓ | ✓ | 6.68e+05 | 8 |
| 69 | T1_P1__bd_pd1_sigR2 | 826.3 | no | ✓ | ✗ | Inf | 10 |
| 70 | T1_P1__bd_pd1_sigL1 | 826.3 | yes ✓ | ✓ | ✓ | 6.30e+05 | 9 |
| 71 | T3_P3__bd_pd1_sigL1 | 826.8 | yes ✓ | ✓ | ✓ | 8.65e+03 | 18 |
| 72 | T3_P3__bd_pd1_sigL2 | 826.8 | yes ✓ | ✓ | ✓ | 7.83e+03 | 19 |
| 73 | T3_P3__bd_pd1_sigR2 | 826.8 | yes ✓ | ✓ | ✓ | 7.86e+03 | 14 |
| 74 | T3_P3__bd_pd1_sigR1 | 826.8 | yes ✓ | ✓ | ✓ | 7.81e+03 | 13 |
| 75 | T1_P2 | 827.1 | no | ✗ | ✗ | Inf | 27 |
| 76 | T2_P2__bd_pd1_sigR1 | 827.2 | yes ✓ | ✓ | ✓ | 3.26e+04 | 11 |
| 77 | T2_P2__bd_pd1_sigL1 | 827.2 | yes ✓ | ✓ | ✓ | 3.26e+04 | 8 |
| 78 | T2_P2__bd_pd1_sigL2 | 827.2 | yes ✓ | ✓ | ✓ | 3.21e+04 | 7 |
| 79 | T2_P2__bd_pd1_sigR2 | 827.2 | no | ✓ | ✗ | Inf | 5 |
| 80 | T1_P1__bd_sigR1 | 827.2 | no | ✓ | ✗ | Inf | 9 |
| 81 | T1_P1__bd_sigL2 | 827.2 | no | ✓ | ✗ | Inf | 10 |
| 82 | T1_P1__bd_sigR2 | 827.2 | no | ✓ | ✗ | Inf | 20 |
| 83 | T1_P1__bd_sigL1 | 827.2 | no | ✓ | ✗ | 2.41e+07 | 10 |
| 84 | T2_T3_P1__bd_sigR2 | 828.0 | no | ✗ | ✗ | Inf | 1 |
| 85 | T2_P3__bd_pd1 | 828.3 | no | ✓ | ✗ | Inf | 49 |
| 86 | T2_T3_P1__bd_sigL1 | 828.4 | no | ✗ | ✗ | Inf | 2 |
| 87 | T2_T3_P1__bd_sigL2 | 828.4 | no | ✗ | ✗ | Inf | 1 |
| 88 | T2_T3_P1__bd_sigR1 | 828.4 | no | ✗ | ✗ | Inf | 1 |
| 89 | T1_P2__bd_pd1 | 829.1 | no | ✓ | ✗ | Inf | 45 |
| 90 | T3_P2__bd_pd1_sigL2 | 829.5 | no | ✗ | ✗ | Inf | 1 |
| 91 | T1_P1__bd_pd1 | 830.3 | no | ✓ | ✗ | 3.93e+06 | 11 |
| 92 | T1_P1 | 830.4 | no | ✓ | ✗ | Inf | 28 |
| 93 | T2_T3_P1__bd_pd1 | 830.5 | no | ✓ | ✗ | Inf | 7 |
| 94 | T2_T3_P1__bd_sigL3 | 830.9 | no | ✗ | ✗ | Inf | 1 |
| 95 | T2_T3_P1__bd_sigR3 | 831.2 | no | ✗ | ✗ | Inf | 1 |
| 96 | T3_P2__bd_pd1_sigR1 | 831.3 | yes ✓ | ✓ | ✓ | 7.30e+04 | 10 |
| 97 | T3_P2__bd_pd1_sigL1 | 831.3 | yes ✓ | ✓ | ✓ | 7.51e+04 | 11 |
| 98 | T3_P2__bd_pd1_sigR2 | 831.3 | yes ✓ | ✓ | ✓ | 7.47e+04 | 21 |
| 99 | T2_T3_P2__bd_pd1_sigL1 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 100 | T2_T3_P2__bd_pd1_sigR1 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 101 | T2_T3_P2__bd_pd1_sigL2 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 102 | T2_T3_P2__bd_pd1_sigR3 | 831.4 | no | ✗ | ✗ | Inf | 1 |
| 103 | T2_T3_P2__bd_pd1_sigR2 | 831.6 | no | ✗ | ✗ | 1.64e+06 | 2 |
| 104 | T2_T3_P2__bd_pd1_sigL3 | 831.6 | no | ✗ | ✗ | Inf | 2 |
| 105 | T2_T3_P1 | 831.8 | no | ✓ | ✗ | Inf | 3 |
| 106 | T2_P2__bd_sigL2 | 832.8 | no | ✓ | ✗ | Inf | 19 |
| 107 | T2_P2__bd_sigR1 | 832.8 | no | ✓ | ✗ | Inf | 18 |
| 108 | T2_P2__bd_sigR2 | 832.8 | no | ✓ | ✗ | Inf | 25 |
| 109 | T2_P2__bd_sigL1 | 832.8 | no | ✓ | ✗ | Inf | 8 |
| 110 | T2_T3_P1__bd_pd1_sigL2 | 832.8 | no | ✗ | ✗ | Inf | 2 |
| 111 | T2_T3_P1__bd_pd1_sigR3 | 832.8 | no | ✗ | ✗ | Inf | 2 |
| 112 | T3_P1__bd_sigL1 | 833.6 | no | ✗ | ✗ | Inf | 1 |
| 113 | T2_P2__bd_pd1 | 833.7 | no | ✓ | ✗ | 1.85e+16 | 29 |
| 114 | T3_P2_P3__bd_sigL3 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 115 | T3_P2_P3__bd_sigR2 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 116 | T3_P2_P3__bd_sigR3 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 117 | T3_P2_P3__bd_sigL1 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 118 | T3_P2_P3__bd_sigR1 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 119 | T3_P2_P3__bd_sigL2 | 834.0 | no | ✗ | ✗ | Inf | 1 |
| 120 | T1_P2_P3__bd_sigR2 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 121 | T1_P2_P3__bd_sigR1 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 122 | T1_P2_P3__bd_sigR3 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 123 | T1_P2_P3__bd_sigL2 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 124 | T1_P2_P3__bd_sigL3 | 834.3 | no | ✗ | ✗ | Inf | 1 |
| 125 | T1_P2_P3__bd_sigL1 | 834.4 | no | ✗ | ✗ | Inf | 1 |
| 126 | T2_T3_P2__bd_sigR3 | 835.3 | no | ✗ | ✗ | Inf | 1 |
| 127 | T2_T3_P2__bd_sigL3 | 835.5 | no | ✗ | ✗ | Inf | 1 |
| 128 | T3_P1__bd_sigR2 | 836.6 | no | ✗ | ✗ | Inf | 1 |
| 129 | T3_P1__bd_sigR1 | 836.6 | no | ✗ | ✗ | Inf | 1 |
| 130 | T3_P1__bd_sigL2 | 836.6 | no | ✗ | ✗ | Inf | 1 |
| 131 | T3_P2__bd_pd1 | 837.8 | no | ✓ | ✗ | 5.04e+16 | 42 |
| 132 | T2_T3_P2__bd_sigR1 | 837.9 | no | ✗ | ✗ | Inf | 2 |
| 133 | T2_T3_P2__bd_sigL2 | 837.9 | no | ✗ | ✗ | Inf | 2 |
| 134 | T2_T3_P2__bd_sigR2 | 837.9 | no | ✗ | ✗ | Inf | 1 |
| 135 | T2_T3_P2__bd_sigL1 | 837.9 | no | ✗ | ✗ | Inf | 1 |
| 136 | T2_T3_P2__bd_pd1 | 838.1 | no | ✓ | ✗ | Inf | 11 |
| 137 | T2_T3_noP__bd_pd1_sigL2 | 838.2 | no | ✓ | ✗ | Inf | 8 |
| 138 | T2_T3_noP__bd_pd1_sigR2 | 838.2 | yes ✓ | ✓ | ✓ | 4.18e+04 | 7 |
| 139 | T2_T3_noP__bd_pd1_sigR1 | 838.2 | no | ✓ | ✗ | Inf | 6 |
| 140 | T2_T3_noP__bd_pd1_sigL1 | 838.2 | yes ✓ | ✓ | ✓ | 4.37e+04 | 5 |
| 141 | T2_P2 | 839.3 | no | ✓ | ✗ | Inf | 33 |
| 142 | T2_T3_noP | 840.1 | no | ✗ | ✗ | Inf | 1 |
| 143 | T3_P1__bd_pd1_sigL1 | 840.5 | no | ✓ | ✗ | Inf | 13 |
| 144 | T3_P1__bd_pd1_sigL2 | 840.5 | no | ✓ | ✗ | 6.01e+06 | 17 |
| 145 | T3_P1__bd_pd1_sigR2 | 840.5 | no | ✓ | ✗ | Inf | 19 |
| 146 | T3_P1__bd_pd1_sigR1 | 840.5 | no | ✓ | ✗ | Inf | 14 |
| 147 | T3_P2_P3 | 840.5 | no | ✗ | ✗ | Inf | 1 |
| 148 | T3_P2_P3__bd_pd1_sigL3 | 840.7 | no | ✗ | ✓ | 5.05e+05 | 1 |
| 149 | T3_P2_P3__bd_pd1_sigR2 | 840.7 | no | ✗ | ✗ | 1.69e+06 | 2 |
| 150 | T3_P2_P3__bd_pd1_sigR1 | 840.7 | no | ✗ | ✗ | Inf | 1 |
| 151 | T3_P2_P3__bd_pd1_sigR3 | 840.8 | no | ✗ | ✗ | Inf | 1 |
| 152 | T3_P2_P3__bd_pd1_sigL1 | 840.8 | no | ✗ | ✗ | Inf | 1 |
| 153 | T1_P2_P3 | 840.8 | (not scanned) | — | — | — | — |
| 154 | T3_P1__bd_pd1 | 841.2 | no | ✓ | ✗ | 3.72e+06 | 42 |
| 155 | T1_P2_P3__bd_pd1_sigR2 | 841.7 | no | ✗ | ✗ | Inf | 1 |
| 156 | T1_P2_P3__bd_pd1_sigL1 | 841.7 | no | ✗ | ✗ | Inf | 1 |
| 157 | T2_noP__bd_pd1 | 841.7 | no | ✓ | ✗ | Inf | 50 |
| 158 | T3_P1 | 842.0 | no | ✗ | ✗ | Inf | 1 |
| 159 | T1_P2_P3__bd_pd1_sigR3 | 842.1 | no | ✓ | ✗ | 3.91e+17 | 15 |
| 160 | T1_P2_P3__bd_pd1_sigL3 | 842.1 | no | ✓ | ✗ | Inf | 30 |
| 161 | T1_P2_P3__bd_pd1_sigR1 | 842.1 | no | ✓ | ✗ | 6.02e+17 | 14 |
| 162 | T1_P2_P3__bd_pd1_sigL2 | 842.1 | no | ✓ | ✗ | Inf | 19 |
| 163 | T2_T3_noP__bd_sigR1 | 842.3 | no | ✓ | ✗ | Inf | 4 |
| 164 | T2_T3_noP__bd_sigL2 | 842.3 | no | ✓ | ✗ | Inf | 4 |
| 165 | T2_T3_noP__bd_sigR2 | 842.3 | no | ✓ | ✗ | Inf | 3 |
| 166 | T2_T3_noP__bd_sigL1 | 842.3 | no | ✗ | ✗ | Inf | 1 |
| 167 | T2_T3_P2 | 842.8 | no | ✗ | ✗ | Inf | 1 |
| 168 | T3_P2_P3__bd_pd1_sigL2 | 843.0 | no | ✓ | ✗ | Inf | 5 |
| 169 | T2_T3_noP__bd_pd1 | 844.7 | no | ✓ | ✗ | Inf | 11 |
| 170 | T3_P2_P3__bd_pd1 | 846.5 | no | ✗ | ✗ | Inf | 1 |
| 171 | T1_noP | 846.9 | yes ✓ | ✓ | ✓ | 2.65e+03 | 48 |
| 172 | T1_P2_P3__bd_pd1 | 848.1 | no | ✗ | ✗ | Inf | 1 |
| 173 | T2_noP | 848.2 | no | ✓ | ✗ | Inf | 50 |
| 174 | T2_P2_P3 | 853.7 | no | ✗ | ✗ | Inf | 1 |
| 175 | T3_noP | 861.1 | no | ✗ | ✗ | Inf | 1 |
| 176 | noT_P2 | 899.2 | no | ✗ | ✗ | Inf | 1 |
| 177 | noT_P2_P3 | 902.4 | no | ✗ | ✗ | Inf | 1 |
| 178 | noT_P3 | 905.4 | no | ✗ | ✗ | Inf | 1 |
| 179 | noT_P1 | 907.9 | no | ✗ | ✗ | Inf | 1 |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T2_P1__bd_pd1_sigR2` — **Ω = 812.4**

## L3 supplementary appendices — per-model diagnostics

### T2_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -379.166 | 41.3233 | 28.3886 |   Inf | 0.0000 | 2.2281 | 3.9503 | -22.1125 | 0.6508 | -0.7780 | 0.6283 | -0.6283 | -0.7780 | 0.00000000 |
| 2 | -379.228 | 41.3968 | 28.2266 |   Inf | 0.0005 | 2.1600 | 3.7941 | -23.9357 | 0.6474 | -0.7759 | 0.6309 | -0.6309 | -0.7759 | 23120.70453181 |
| 3 | -381.614 | 39.3976 | 35.2001 |   Inf | 0.0002 | 1.8964 | 4.8308 | -20.9712 | 0.6512 | -0.8917 | 0.4526 | -0.4526 | -0.8917 | 19349.96366888 |
| 4 | -383.771 | 43.1065 | 29.3064 |   Inf | 0.0004 | 2.3142 | 4.1279 | -23.2658 | 0.6414 | -0.7610 | 0.6488 | -0.6488 | -0.7610 | 22494.42543461 |
| 5 | -383.799 | 27.1491 | 19.0230 | 3.3923 | 1.4207 | 2.7394 |   Inf | -8.0859 | 0.6519 | -0.0002 | 1.0000 | 1.0000 | 0.0002 | 25114.07246467 |
| 6 | -383.799 | 27.1491 | 19.0230 | 3.3923 | 1.4207 | 2.7394 |   Inf | -8.0859 | 0.6519 | -0.0002 | 1.0000 | 1.0000 | 0.0002 | 25114.07246471 |
| 7 | -383.799 | 27.1491 | 19.0230 | 3.3923 | 1.4207 | 2.7394 |   Inf | -8.0859 | 0.6519 | -0.0002 | 1.0000 | 1.0000 | 0.0002 | 25114.07246463 |
| 8 | -383.799 | 27.1491 | 19.0230 | 3.3923 | 1.4207 | 2.7394 |   Inf | -8.0859 | 0.6519 | -0.0002 | 1.0000 | 1.0000 | 0.0002 | 25114.07246473 |
| 9 | -383.799 | 27.1491 | 19.0230 | 3.3923 | 1.4207 | 2.7394 |   Inf | -8.0859 | 0.6519 | -0.0002 | 1.0000 | 1.0000 | 0.0002 | 25114.07246472 |
| 10 | -383.977 | 150.2940 | 177.4541 | 12.0378 | 1.8350 |   Inf | 118850540183849915205311625816772403815340853098441223726141074834930496468524390285779617442368002640799368564958765201068681323207074303096800807739675017063853358549249807142189945350907576259449830549454503782273456524457220668628090522435584.0000 | -153.2328 | 0.6438 | 0.5997 | 0.8003 | 0.8003 | -0.5997 | 25115.24276187 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=2.4486, max_pdist=23120.7045 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.186e+09 | 3.171e+06 |
| 2 | 1.608e+04 | 1.609e+04 |
| 3 | 2.680e+03 | 2.681e+03 |
| 4 | 9.564e+01 | 9.577e+01 |
| 5 | 4.334e-02 | 5.113e+00 |
| 6 | -1.118e+05 | 4.140e-02 |
| 7 | -9.283e+05 | -1.015e+05 |
| 8 | -4.117e+06 | -3.777e+08 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -379.748 | 22.2229 | 38.4444 | 5.5271 |   Inf | 0.0037 | 0.9566 | -16.2824 | 0.6457 | 0.4154 | 0.9096 | -0.9096 | 0.4154 | 0.00000000 |
| 2 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765326 |
| 3 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765327 |
| 4 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765329 |
| 5 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765326 |
| 6 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765331 |
| 7 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765330 |
| 8 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765323 |
| 9 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765332 |
| 10 | -382.889 | 17.6435 | 22.0341 | 4.7012 |   Inf | 1.5113 | 3.4804 | -9.7684 | 0.6527 | -0.8885 | 0.4589 | -0.4589 | -0.8885 | 273.28765330 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.1414, max_pdist=273.2877 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.452e+05 | 6.068e+04 |
| 2 | 8.867e+03 | 7.982e+03 |
| 3 | 9.382e+02 | 8.153e+02 |
| 4 | 2.667e+02 | 9.790e+01 |
| 5 | 9.785e+01 | 9.433e-02 |
| 6 | 9.880e-02 | 4.109e-02 |
| 7 | -7.086e+00 | -1.182e+01 |
| 8 | -7.211e+02 | -1.370e+01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_P1__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000000 |
| 2 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000033 |
| 3 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000056 |
| 4 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000033 |
| 5 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000057 |
| 6 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000005 |
| 7 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000016 |
| 8 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000063 |
| 9 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000042 |
| 10 | -383.481 | 23.6084 | 12.6830 | 1.7188 | 0.9212 | 4.2888 |   Inf | -1.2150 | 1.0000 | 0.5417 | -0.8406 | 0.8406 | 0.5417 | 0.00000059 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P1__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.669e+02 | 4.714e+02 |
| 2 | 3.650e+02 | 3.655e+02 |
| 3 | 1.776e+02 | 1.776e+02 |
| 4 | 2.647e+01 | 2.817e+01 |
| 5 | 1.572e+01 | 1.572e+01 |
| 6 | 1.396e+00 | 1.338e+00 |
| 7 | 5.634e-01 | 5.773e-01 |

numDeriv::hessian (operative): cond = 828.7211, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 816.6011, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: none

Across 3 scanned models: 1 pass Flag A (convergence), 1 pass strict Flag B, 1 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 2 models that fail Flag A: **2** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **0** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 8 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T2_noP, T2_P2_P3, T3_noP)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T2_P1__bd_pd1_sigR2`
- **pBIC (Ω):** 812.4
- **logLik:** -383.4814
- **Variables:** T2, P1
- **Free parameters (n_free):** 7
- **Boundary mask:** pd=Inf, sigrtil2=Inf

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
| sigltil | 1.7188, 0.9212 |
| sigrtil | 4.2888,   Inf |
| ctil | -1.2150 |
| pd | 1.0000 |
| o_mat | 0.5417, -0.8406, 0.8406, 0.5417 |

### Profile likelihoods and arc check

- **Arc check:** 7/7 parameters pass → **ALL PASS ✓**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | PASS | pass |
| mu2 | PASS | pass |
| sigltil1 | PASS | pass |
| sigltil2 | PASS | pass |
| sigrtil1 | PASS | pass |
| ctil | PASS | pass |
| o_par1 | PASS | pass |

## Profile likelihood plots

![Profile likelihood plots for the best model (T2_P1__bd_pd1_sigR2)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T2_P1__bd_pd1_sigR2` (pBIC = 812.4)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 156
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 03:23:30_

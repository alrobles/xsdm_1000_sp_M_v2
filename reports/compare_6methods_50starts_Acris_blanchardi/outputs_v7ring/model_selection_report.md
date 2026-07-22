# xsdm v6 — Model selection report (Algorithm2)

**Species:** *Acris blanchardi*

This report documents, step by step, the literal Algorithm2 selection rules
applied to this species. Each phase (L1–L4) includes the rule itself and
the complete list of models with their classification.

**Definition of model success:** a model has `status == "success"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.

## Data and units

- Species directory: `/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_v7ring_smoke/Acris_blanchardi`
- Sample size: 982
- Maximum variables per model: 3
- Tau (τ): 27.5584
- L2 threshold: best L1 + τ = 676.2529
- Ω threshold: 721.9125
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
| 1 | T2_T3_P3 ≤τ | T2+T3+P3 | 648.7 | -276.120 | 14 | success |
| 2 | T3_P3 | T3+P3 | 694.4 | -316.174 | 9 | success |
| 3 | T3_P2_P3 | T3+P2+P3 | 707.5 | -305.521 | 14 | success |
| 4 | T2_T3_P1 | T2+T3+P1 | 709.6 | -306.548 | 14 | success |
| 5 | T1_P3 | T1+P3 | 714.9 | -326.462 | 9 | success |
| 6 | T1_P2_P3 | T1+P2+P3 | 731.4 | -317.490 | 14 | success |
| 7 | T2_T3_P2 | T2+T3+P2 | 746.6 | -325.096 | 14 | success |
| 8 | T2_P3 | T2+P3 | 757.2 | -347.617 | 9 | success |
| 9 | T2_P2_P3 | T2+P2+P3 | 784.7 | -344.125 | 14 | success |
| 10 | T2_P1 | T2+P1 | 811.3 | -374.651 | 9 | success |
| 11 | T1_P1 | T1+P1 | 844.7 | -391.346 | 9 | success |
| 12 | T3_P1 | T3+P1 | 877.4 | -407.689 | 9 | success |
| 13 | T1_P2 | T1+P2 | 918.3 | -428.165 | 9 | success |
| 14 | T2_P2 | T2+P2 | 928.3 | -433.131 | 9 | success |
| 15 | T3_P2 | T3+P2 | 937.8 | -437.906 | 9 | success |
| 16 | T2_T3_noP | T2+T3 | 1036.5 | -487.233 | 9 | success |
| 17 | T1_noP | T1 | 1054.9 | -510.239 | 5 | success |
| 18 | noT_P3 | P3 | 1059.8 | -512.677 | 5 | success |
| 19 | noT_P2_P3 | P2+P3 | 1065.4 | -501.687 | 9 | success |
| 20 | T2_noP | T2 | 1082.4 | -523.966 | 5 | success |
| 21 | T3_noP | T3 | 1107.0 | -536.268 | 5 | success |
| 22 | noT_P2 | P2 | 1147.4 | -556.455 | 5 | success |
| 23 | noT_P1 | P1 | 1163.9 | -564.707 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 676.3**.
**Eligible L1 models:** 1 (T2_T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_T3_P3__bd_pd1_sigL1 | 640.3 | -278.836 | 12 | success |
| T2_T3_P3__bd_pd1_sigR1 | 640.3 | -278.836 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 640.3 | -278.836 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 640.3 | -278.836 | 12 | success |
| T2_T3_P3__bd_pd1 | 641.8 | -276.120 | 13 | success |
| T2_T3_P3__bd_pd1_sigL2 | 653.8 | -285.577 | 12 | success |
| T2_T3_P3__bd_sigR3 | 660.7 | -285.577 | 13 | success |
| T2_T3_P3__bd_sigL2 | 660.7 | -285.577 | 13 | success |
| T2_T3_P3__bd_sigL3 | 660.7 | -285.577 | 13 | success |
| T2_T3_P3__bd_sigR2 | 660.7 | -285.577 | 13 | success |
| T2_T3_P3__bd_sigL1 | 660.7 | -285.577 | 13 | success |
| T2_T3_P3__bd_sigR1 | 671.9 | -291.164 | 13 | success |
| T2_T3_P3__bd_pd1_sigL3 | 672.0 | -294.684 | 12 | success |
| T2_T3_P1__bd_pd1 | 702.7 | -306.548 | 13 | success |
| T2_T3_P2__bd_pd1 | 739.8 | -325.096 | 13 | success |
| T3_P1__bd_pd1 | 870.5 | -407.689 | 8 | success |
| T2_P2__bd_pd1 | 921.4 | -433.131 | 8 | success |
| T2_T3_noP__bd_pd1 | 1029.6 | -487.233 | 8 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_pd1_sigL1 | 640.3 | no | ✗ | ✓ | 4.45e+04 | 2 |
| 2 | T2_T3_P3__bd_pd1_sigR1 | 640.3 | no | ✗ | ✗ | Inf | 1 |
| 3 | T2_T3_P3__bd_pd1_sigR2 | 640.3 | no | ✗ | ✗ | Inf | 1 |
| 4 | T2_T3_P3__bd_pd1_sigR3 | 640.3 | no | ✗ | ✗ | Inf | 1 |
| 5 | T2_T3_P3__bd_pd1 | 641.8 | no | ✓ | ✗ | Inf | 3 |
| 6 | T2_T3_P3 | 648.7 | no | ✗ | ✗ | Inf | 2 |
| 7 | T2_T3_P3__bd_pd1_sigL2 | 653.8 | no | ✓ | ✗ | Inf | 5 |
| 8 | T2_T3_P3__bd_sigR3 | 660.7 | no | ✓ | ✗ | Inf | 4 |
| 9 | T2_T3_P3__bd_sigL2 | 660.7 | no | ✗ | ✗ | Inf | 1 |
| 10 | T2_T3_P3__bd_sigL3 | 660.7 | no | ✗ | ✗ | Inf | 2 |
| 11 | T2_T3_P3__bd_sigR2 | 660.7 | no | ✗ | ✗ | Inf | 1 |
| 12 | T2_T3_P3__bd_sigL1 | 660.7 | no | ✗ | ✗ | Inf | 2 |
| 13 | T2_T3_P3__bd_sigR1 | 671.9 | no | ✗ | ✗ | Inf | 1 |
| 14 | T2_T3_P3__bd_pd1_sigL3 | 672.0 | no | ✓ | ✗ | Inf | 5 |
| 15 | T3_P3 | 694.4 | yes ✓ | ✓ | ✓ | 2.64e+04 | 50 |
| 16 | T3_P2_P3__bd_sigR2 | 700.6 | no | ✗ | ✗ | Inf | 1 |
| 17 | T3_P2_P3__bd_sigR1 | 700.6 | no | ✗ | ✗ | Inf | 1 |
| 18 | T3_P2_P3__bd_sigL3 | 700.6 | no | ✗ | ✗ | Inf | 1 |
| 19 | T3_P2_P3__bd_sigL1 | 700.6 | no | ✗ | ✗ | Inf | 1 |
| 20 | T3_P2_P3__bd_sigL2 | 700.6 | no | ✗ | ✗ | Inf | 1 |
| 21 | T3_P2_P3__bd_sigR3 | 700.6 | no | ✗ | ✗ | Inf | 1 |
| 22 | T2_T3_P1__bd_pd1 | 702.7 | no | ✓ | ✗ | Inf | 7 |
| 23 | T3_P2_P3 | 707.5 | no | ✗ | ✗ | Inf | 1 |
| 24 | T2_T3_P1 | 709.6 | no | ✓ | ✗ | Inf | 4 |
| 25 | T2_T3_P1__bd_pd1_sigL2 | 709.7 | no | ✓ | ✗ | Inf | 3 |
| 26 | T2_T3_P1__bd_pd1_sigR2 | 709.7 | no | ✗ | ✗ | 7.95e+07 | 1 |
| 27 | T2_T3_P1__bd_pd1_sigR1 | 709.7 | no | ✓ | ✗ | Inf | 4 |
| 28 | T2_T3_P1__bd_pd1_sigR3 | 709.7 | no | ✗ | ✗ | Inf | 1 |
| 29 | T2_T3_P1__bd_pd1_sigL1 | 709.7 | no | ✗ | ✗ | Inf | 2 |
| 30 | T2_T3_P1__bd_pd1_sigL3 | 709.7 | no | ✗ | ✗ | Inf | 1 |
| 31 | T1_P3 | 714.9 | yes ✓ | ✓ | ✓ | 4.06e+04 | 32 |
| 32 | T2_T3_P1__bd_sigR1 | 716.6 | no | ✓ | ✗ | Inf | 4 |
| 33 | T2_T3_P1__bd_sigL2 | 716.6 | no | ✓ | ✗ | Inf | 3 |
| 34 | T2_T3_P1__bd_sigR2 | 716.6 | no | ✗ | ✗ | Inf | 1 |
| 35 | T2_T3_P1__bd_sigL1 | 716.6 | no | ✗ | ✗ | Inf | 1 |
| 36 | T2_T3_P1__bd_sigL3 | 716.6 | no | ✗ | ✗ | Inf | 1 |
| 37 | T2_T3_P1__bd_sigR3 | 722.5 | no | ✓ | ✗ | Inf | 3 |
| 38 | T3_P3__bd_pd1 | 729.1 | yes ✓ | ✓ | ✓ | 1.13e+04 | 50 |
| 39 | T3_P2_P3__bd_pd1_sigR3 | 730.7 | no | ✓ | ✗ | 1.25e+06 | 6 |
| 40 | T3_P2_P3__bd_pd1_sigL1 | 730.7 | no | ✓ | ✗ | Inf | 17 |
| 41 | T3_P2_P3__bd_pd1_sigR2 | 730.7 | yes ✓ | ✓ | ✓ | 2.99e+05 | 20 |
| 42 | T3_P2_P3__bd_pd1_sigL3 | 730.7 | yes ✓ | ✓ | ✓ | 3.44e+05 | 15 |
| 43 | T3_P2_P3__bd_pd1_sigR1 | 730.7 | no | ✓ | ✗ | Inf | 9 |
| 44 | T3_P2_P3__bd_pd1_sigL2 | 730.7 | no | ✓ | ✗ | Inf | 7 |
| 45 | T1_P2_P3 | 731.4 | no | ✗ | ✗ | Inf | 1 |
| 46 | T1_P3__bd_pd1 | 736.4 | yes ✓ | ✓ | ✓ | 5.96e+03 | 19 |
| 47 | T3_P2_P3__bd_pd1 | 737.6 | no | ✓ | ✗ | Inf | 35 |
| 48 | T2_T3_P2__bd_pd1 | 739.8 | no | ✓ | ✗ | Inf | 28 |
| 49 | T2_T3_P2 | 746.6 | no | ✓ | ✗ | Inf | 22 |
| 50 | T1_P3__bd_sigL2 | 752.2 | yes ✓ | ✓ | ✓ | 2.76e+04 | 20 |
| 51 | T1_P3__bd_sigL1 | 752.2 | yes ✓ | ✓ | ✓ | 2.30e+04 | 14 |
| 52 | T1_P3__bd_sigR1 | 752.2 | yes ✓ | ✓ | ✓ | 2.19e+04 | 8 |
| 53 | T1_P3__bd_sigR2 | 752.2 | yes ✓ | ✓ | ✓ | 2.23e+04 | 12 |
| 54 | T1_P3__bd_pd1_sigL1 | 753.1 | yes ✓ | ✓ | ✓ | 2.63e+04 | 38 |
| 55 | T1_P3__bd_pd1_sigL2 | 753.1 | yes ✓ | ✓ | ✓ | 1.63e+04 | 28 |
| 56 | T1_P3__bd_pd1_sigR1 | 753.1 | yes ✓ | ✓ | ✓ | 2.05e+04 | 31 |
| 57 | T1_P3__bd_pd1_sigR2 | 753.1 | yes ✓ | ✓ | ✓ | 1.65e+04 | 28 |
| 58 | T2_P3 | 757.2 | yes ✓ | ✓ | ✓ | 7.05e+03 | 34 |
| 59 | T2_P2_P3 | 784.7 | no | ✗ | ✗ | Inf | 1 |
| 60 | T3_P3__bd_sigL1 | 786.6 | yes ✓ | ✓ | ✓ | 1.38e+04 | 36 |
| 61 | T3_P3__bd_sigR1 | 786.6 | yes ✓ | ✓ | ✓ | 1.25e+04 | 33 |
| 62 | T3_P3__bd_sigR2 | 786.6 | yes ✓ | ✓ | ✓ | 1.37e+04 | 30 |
| 63 | T3_P3__bd_sigL2 | 786.6 | yes ✓ | ✓ | ✓ | 1.37e+04 | 38 |
| 64 | T3_P3__bd_pd1_sigR2 | 797.1 | yes ✓ | ✓ | ✓ | 1.26e+04 | 33 |
| 65 | T3_P3__bd_pd1_sigR1 | 797.1 | yes ✓ | ✓ | ✓ | 1.25e+04 | 28 |
| 66 | T3_P3__bd_pd1_sigL2 | 797.1 | yes ✓ | ✓ | ✓ | 1.16e+04 | 33 |
| 67 | T3_P3__bd_pd1_sigL1 | 797.1 | yes ✓ | ✓ | ✓ | 1.23e+04 | 30 |
| 68 | T2_P1 | 811.3 | no | ✓ | ✗ | Inf | 39 |
| 69 | T1_P1 | 844.7 | yes ✓ | ✓ | ✓ | 8.57e+05 | 22 |
| 70 | T3_P1__bd_pd1 | 870.5 | no | ✓ | ✗ | Inf | 43 |
| 71 | T3_P1 | 877.4 | yes ✓ | ✓ | ✓ | 3.31e+05 | 41 |
| 72 | T1_P2 | 918.3 | no | ✓ | ✗ | Inf | 16 |
| 73 | T2_P2__bd_pd1 | 921.4 | no | ✓ | ✗ | Inf | 38 |
| 74 | T2_P2 | 928.3 | no | ✓ | ✗ | Inf | 14 |
| 75 | T3_P2 | 937.8 | no | ✗ | ✗ | Inf | 1 |
| 76 | T3_P3__bd_sigL2_sigR2 | 1020.6 | no | ✗ | ✗ | Inf | 1 |
| 77 | T2_T3_noP__bd_pd1 | 1029.6 | yes ✓ | ✓ | ✓ | 1.30e+04 | 18 |
| 78 | T2_T3_noP | 1036.5 | yes ✓ | ✓ | ✓ | 1.32e+04 | 7 |
| 79 | T1_noP | 1054.9 | yes ✓ | ✓ | ✓ | 5.82e+03 | 45 |
| 80 | noT_P3 | 1059.8 | no | ✓ | ✗ | 7.97e+07 | 43 |
| 81 | noT_P2_P3 | 1065.4 | no | ✗ | ✗ | Inf | 1 |
| 82 | T2_noP | 1082.4 | yes ✓ | ✓ | ✓ | 2.37e+04 | 17 |
| 83 | T3_noP | 1107.0 | no | ✗ | ✗ | Inf | 1 |
| 84 | noT_P2 | 1147.4 | no | ✗ | ✗ | Inf | 1 |
| 85 | noT_P1 | 1163.9 | no | ✗ | ✗ | Inf | 1 |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T3_P3` — **Ω = 694.4**

## L3 supplementary appendices — per-model diagnostics

### T2_T3_P3__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -278.836 | 24.7419 | -4.2394 | 18.0429 |   Inf | 0.1121 | 2.2907 | 0.7547 | 1.6557 | 2.5367 | -8.1175 | 1.0000 | -0.4750 | -0.8461 | 0.2419 | -0.8793 | 0.4670 | -0.0935 | -0.0339 | -0.2571 | -0.9658 | 0.00000000 |
| 2 | -278.836 | 24.7419 | -4.2394 | 18.0429 |   Inf | 0.1121 | 2.2907 | 0.7547 | 1.6557 | 2.5367 | -8.1175 | 1.0000 | -0.4750 | -0.8461 | 0.2419 | -0.8793 | 0.4670 | -0.0935 | -0.0339 | -0.2571 | -0.9658 | 0.00000012 |
| 3 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.1101 | 0.2149 | 1.7463 |   Inf | 1.0744 | 3.4145 | -7.7488 | 1.0000 | -0.3113 | -0.8316 | 0.4600 | -0.9454 | 0.3203 | -0.0607 | -0.0969 | -0.4538 | -0.8858 | 19.39459919 |
| 4 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.1101 | 0.2149 | 1.7463 |   Inf | 1.0744 | 3.4145 | -7.7488 | 1.0000 | -0.3113 | -0.8316 | 0.4600 | -0.9454 | 0.3203 | -0.0607 | -0.0969 | -0.4538 | -0.8858 | 19.39459948 |
| 5 | -291.164 | 24.8420 | -4.0554 | 17.7528 | 5.5152 | 0.1090 | 2.2667 | 0.7294 |   Inf | 2.1681 | -8.2742 | 1.0000 | -0.4779 | -0.8130 | 0.3327 | -0.8752 | 0.4731 | -0.1012 | -0.0751 | -0.3395 | -0.9376 | 0.80000121 |
| 6 | -291.164 | 24.8420 | -4.0554 | 17.7528 | 5.5152 | 0.1090 | 2.2667 | 0.7294 |   Inf | 2.1681 | -8.2742 | 1.0000 | -0.4779 | -0.8130 | 0.3327 | -0.8752 | 0.4731 | -0.1012 | -0.0751 | -0.3395 | -0.9376 | 0.80000151 |
| 7 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 13.6520 | 0.0577 | 2.2958 | 0.7862 |   Inf | 2.5707 | -4.7255 | 1.0000 | -0.6218 | -0.7487 | 0.2298 | 0.7495 | -0.4837 | 0.4520 | 0.2273 | -0.4533 | -0.8619 | 15.38339293 |
| 8 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 13.6520 | 0.0577 | 2.2958 | 0.7862 |   Inf | 2.5707 | -4.7255 | 1.0000 | -0.6218 | -0.7487 | 0.2298 | 0.7495 | -0.4837 | 0.4520 | 0.2273 | -0.4533 | -0.8619 | 15.38339305 |
| 9 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 13.6520 | 0.0577 | 2.2958 | 0.7862 |   Inf | 2.5707 | -4.7255 | 1.0000 | -0.6218 | -0.7487 | 0.2298 | 0.7495 | -0.4837 | 0.4520 | 0.2273 | -0.4533 | -0.8619 | 15.38339394 |
| 10 | -295.609 | 17.6222 | 11.3495 | 14.4072 | 1.0171 | 0.1907 | 2.2601 |   Inf | 7.8251 | 2.7980 | -4.9870 | 1.0000 | 0.2149 | -0.9077 | 0.3605 | 0.9737 | 0.1708 | -0.1506 | -0.0751 | -0.3834 | -0.9205 | 18.36433531 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.7402, max_pdist=19.3946 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.554e+04 | 1.572e+04 |
| 2 | 6.746e+03 | 6.689e+03 |
| 3 | 3.949e+03 | 3.915e+03 |
| 4 | 1.107e+03 | 1.142e+03 |
| 5 | 7.560e+02 | 7.549e+02 |
| 6 | 5.909e+02 | 5.886e+02 |
| 7 | 2.138e+02 | 1.997e+02 |
| 8 | 1.585e+02 | 1.188e+02 |
| 9 | 2.925e+01 | 3.824e+01 |
| 10 | 2.691e+00 | 2.640e+00 |
| 11 | 5.002e-01 | 9.977e-01 |
| 12 | 3.490e-01 | 3.324e-01 |

numDeriv::hessian (operative): cond = 44514.4460, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 47310.3190, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -278.836 | 24.7419 | -4.2394 | 18.0429 | 0.7547 | 0.1121 | 2.5367 |   Inf | 1.6557 | 2.2907 | -8.1175 | 1.0000 | 0.4750 | 0.8461 | -0.2419 | -0.8793 | 0.4670 | -0.0935 | 0.0339 | 0.2571 | 0.9658 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 |   Inf | 0.2149 | 3.4145 | 1.1101 | 1.0744 | 1.7463 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.0969 | 0.4538 | 0.8858 | 19.39459888 |
| 3 | -285.577 | 31.2942 | 12.9346 | 13.9126 |   Inf | 0.2149 | 3.4145 | 1.1101 | 1.0744 | 1.7463 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.0969 | 0.4538 | 0.8858 | 19.39459930 |
| 4 | -285.577 | 31.2942 | 12.9346 | 13.9126 |   Inf | 0.2149 | 3.4145 | 1.1101 | 1.0744 | 1.7463 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.0969 | 0.4538 | 0.8858 | 19.39459944 |
| 5 | -285.577 | 31.2942 | 12.9346 | 13.9126 |   Inf | 0.2149 | 3.4145 | 1.1101 | 1.0744 | 1.7463 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.0969 | 0.4538 | 0.8858 | 19.39459905 |
| 6 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 0.0577 | 2.5707 | 13.6520 |   Inf | 2.2958 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.7495 | -0.4837 | 0.4520 | -0.2273 | 0.4533 | 0.8619 | 15.38339282 |
| 7 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 0.0577 | 2.5707 | 13.6520 |   Inf | 2.2958 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.7495 | -0.4837 | 0.4520 | -0.2273 | 0.4533 | 0.8619 | 15.38339280 |
| 8 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 0.0675 | 2.4290 | 13229.7106 |   Inf | 2.4514 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.7180 | -0.4971 | 0.4871 | -0.2713 | 0.4446 | 0.8537 | 14.78122320 |
| 9 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 0.0675 | 2.4290 | 79944775.0338 |   Inf | 2.4514 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.7180 | -0.4971 | 0.4871 | -0.2713 | 0.4446 | 0.8537 | 14.78121904 |
| 10 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 0.0675 | 2.4290 | 660972382480.2748 |   Inf | 2.4514 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.7180 | -0.4971 | 0.4871 | -0.2713 | 0.4446 | 0.8537 | 14.78121854 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.7402, max_pdist=19.3946 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.654e+04 | 4.622e+04 |
| 2 | 5.534e+03 | 5.614e+03 |
| 3 | 4.076e+03 | 4.081e+03 |
| 4 | 7.568e+02 | 7.545e+02 |
| 5 | 6.259e+02 | 6.144e+02 |
| 6 | 2.649e+02 | 2.419e+02 |
| 7 | 1.667e+02 | 1.872e+02 |
| 8 | 1.258e+02 | 5.051e+01 |
| 9 | 9.603e+00 | 3.687e+01 |
| 10 | 1.947e+00 | 2.640e+00 |
| 11 | 8.877e-01 | 9.981e-01 |
| 12 | -2.966e+01 | 3.302e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 139962.9999, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -278.836 | 24.7419 | -4.2394 | 18.0429 | 1.6557 | 0.7547 | 2.5367 | 0.1121 |   Inf | 2.2907 | -8.1175 | 1.0000 | 0.8793 | -0.4670 | 0.0935 | 0.4750 | 0.8461 | -0.2419 | 0.0339 | 0.2571 | 0.9658 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.0744 |   Inf | 3.4145 | 0.2149 | 1.1101 | 1.7463 | -7.7488 | 1.0000 | 0.9454 | -0.3203 | 0.0607 | 0.3113 | 0.8316 | -0.4600 | 0.0969 | 0.4538 | 0.8858 | 19.39459927 |
| 3 | -294.684 | 14.6925 | 1.7610 | 14.4348 |   Inf | 0.7862 | 2.5707 | 0.0577 | 13.6520 | 2.2958 | -4.7255 | 1.0000 | -0.7495 | 0.4837 | -0.4520 | 0.6218 | 0.7487 | -0.2298 | -0.2273 | 0.4533 | 0.8619 | 15.38339291 |
| 4 | -294.684 | 14.6925 | 1.7610 | 14.4348 |   Inf | 0.7862 | 2.5707 | 0.0577 | 13.6520 | 2.2958 | -4.7255 | 1.0000 | -0.7495 | 0.4837 | -0.4520 | 0.6218 | 0.7487 | -0.2298 | -0.2273 | 0.4533 | 0.8619 | 15.38339256 |
| 5 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 3112899837.3138 | 0.8795 | 2.4290 | 0.0675 |   Inf | 2.4514 | -4.2745 | 1.0000 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | -0.2713 | 0.4446 | 0.8537 | 14.78121831 |
| 6 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 10287488484676639879584773308416.0000 | 0.8795 | 2.4290 | 0.0675 |   Inf | 2.4514 | -4.2745 | 1.0000 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | -0.2713 | 0.4446 | 0.8537 | 14.78121825 |
| 7 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 23758652.0574 | 0.8795 | 2.4290 | 0.0675 |   Inf | 2.4514 | -4.2745 | 1.0000 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | -0.2713 | 0.4446 | 0.8537 | 14.78121828 |
| 8 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 1063539.7771 | 0.8795 | 2.4290 | 0.0675 |   Inf | 2.4514 | -4.2745 | 1.0000 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | -0.2713 | 0.4446 | 0.8537 | 14.78121447 |
| 9 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 540067.1843 | 0.8795 | 2.4290 | 0.0675 |   Inf | 2.4514 | -4.2745 | 1.0000 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | -0.2713 | 0.4446 | 0.8537 | 14.78120475 |
| 10 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 453660.3116 | 0.8795 | 2.4290 | 0.0675 |   Inf | 2.4514 | -4.2745 | 1.0000 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | -0.2713 | 0.4446 | 0.8537 | 14.78121749 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=15.8475, max_pdist=19.3946 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.003e+04 | 4.138e+04 |
| 2 | 5.994e+03 | 6.072e+03 |
| 3 | 3.925e+03 | 3.849e+03 |
| 4 | 1.092e+03 | 7.525e+02 |
| 5 | 7.520e+02 | 6.117e+02 |
| 6 | 6.121e+02 | 2.199e+02 |
| 7 | 1.767e+02 | 6.244e+01 |
| 8 | 5.554e+01 | 3.828e+01 |
| 9 | 2.409e+01 | 1.983e+01 |
| 10 | 2.429e+00 | 2.640e+00 |
| 11 | 1.302e+00 | 9.975e-01 |
| 12 | -9.547e-02 | 3.159e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 130981.4905, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -278.836 | 24.7419 | -4.2394 | 18.0429 | 1.6557 | 2.2907 | 0.7547 | 0.1121 | 2.5367 |   Inf | -8.1175 | 1.0000 | 0.8793 | -0.4670 | 0.0935 | -0.0339 | -0.2571 | -0.9658 | 0.4750 | 0.8461 | -0.2419 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.0744 | 1.7463 |   Inf | 0.2149 | 3.4145 | 1.1101 | -7.7488 | 1.0000 | 0.9454 | -0.3203 | 0.0607 | -0.0969 | -0.4538 | -0.8858 | 0.3113 | 0.8316 | -0.4600 | 19.39459926 |
| 3 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.0744 | 1.7463 |   Inf | 0.2149 | 3.4145 | 1.1101 | -7.7488 | 1.0000 | 0.9454 | -0.3203 | 0.0607 | -0.0969 | -0.4538 | -0.8858 | 0.3113 | 0.8316 | -0.4600 | 19.39459895 |
| 4 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.0744 | 1.7463 |   Inf | 0.2149 | 3.4145 | 1.1101 | -7.7488 | 1.0000 | 0.9454 | -0.3203 | 0.0607 | -0.0969 | -0.4538 | -0.8858 | 0.3113 | 0.8316 | -0.4600 | 19.39459920 |
| 5 | -291.164 | 24.8420 | -4.0554 | 17.7528 |   Inf | 2.2667 | 0.7294 | 0.1090 | 2.1681 | 5.5152 | -8.2742 | 1.0000 | 0.8752 | -0.4731 | 0.1012 | -0.0751 | -0.3395 | -0.9376 | 0.4779 | 0.8130 | -0.3327 | 0.80000100 |
| 6 | -291.164 | 24.8420 | -4.0554 | 17.7528 |   Inf | 2.2667 | 0.7294 | 0.1090 | 2.1681 | 5.5152 | -8.2742 | 1.0000 | 0.8752 | -0.4731 | 0.1012 | -0.0751 | -0.3395 | -0.9376 | 0.4779 | 0.8130 | -0.3327 | 0.80000084 |
| 7 | -294.684 | 14.6925 | 1.7610 | 14.4348 |   Inf | 2.2958 | 0.7862 | 0.0577 | 2.5707 | 13.6520 | -4.7255 | 1.0000 | -0.7495 | 0.4837 | -0.4520 | 0.2273 | -0.4533 | -0.8619 | 0.6218 | 0.7487 | -0.2298 | 15.38339326 |
| 8 | -294.684 | 14.6925 | 1.7610 | 14.4348 |   Inf | 2.2958 | 0.7862 | 0.0577 | 2.5707 | 13.6520 | -4.7255 | 1.0000 | -0.7495 | 0.4837 | -0.4520 | 0.2273 | -0.4533 | -0.8619 | 0.6218 | 0.7487 | -0.2298 | 15.38339416 |
| 9 | -294.684 | 14.6925 | 1.7610 | 14.4348 |   Inf | 2.2958 | 0.7862 | 0.0577 | 2.5707 | 13.6520 | -4.7255 | 1.0000 | -0.7495 | 0.4837 | -0.4520 | 0.2273 | -0.4533 | -0.8619 | 0.6218 | 0.7487 | -0.2298 | 15.38339317 |
| 10 | -294.684 | 14.6925 | 1.7610 | 14.4348 |   Inf | 2.2958 | 0.7862 | 0.0577 | 2.5707 | 13.6520 | -4.7255 | 1.0000 | -0.7495 | 0.4837 | -0.4520 | 0.2273 | -0.4533 | -0.8619 | 0.6218 | 0.7487 | -0.2298 | 15.38339217 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.7402, max_pdist=19.3946 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.441e+04 | 1.463e+04 |
| 2 | 6.972e+03 | 6.970e+03 |
| 3 | 3.362e+03 | 3.329e+03 |
| 4 | 8.656e+02 | 8.139e+02 |
| 5 | 6.947e+02 | 6.499e+02 |
| 6 | 6.241e+02 | 6.223e+02 |
| 7 | 3.407e+02 | 3.196e+02 |
| 8 | 1.476e+02 | 1.135e+02 |
| 9 | 2.832e+01 | 3.848e+01 |
| 10 | 2.708e+00 | 2.640e+00 |
| 11 | 8.572e-01 | 9.983e-01 |
| 12 | -9.681e-02 | 3.317e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 44124.3725, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -276.120 | 24.6972 | -4.1977 | 18.4049 | 0.6911 | 2.1804 | 0.1139 | 9.5037 | 2.4573 | 1.8846 | -8.5741 | 1.0000 | 0.4680 | 0.8347 | -0.2904 | -0.0543 | -0.3008 | -0.9521 | -0.8821 | 0.4613 | -0.0954 | 0.00000000 |
| 2 | -276.120 | 24.6972 | -4.1977 | 18.4049 | 0.6911 | 2.1804 | 0.1139 | 9.5037 | 2.4573 | 1.8846 | -8.5741 | 1.0000 | 0.4680 | 0.8347 | -0.2904 | -0.0543 | -0.3008 | -0.9521 | -0.8821 | 0.4613 | -0.0954 | 0.00000033 |
| 3 | -276.120 | 24.6972 | -4.1977 | 18.4049 | 0.6911 | 2.1804 | 0.1139 | 9.5037 | 2.4573 | 1.8846 | -8.5741 | 1.0000 | 0.4680 | 0.8347 | -0.2904 | -0.0543 | -0.3008 | -0.9521 | -0.8821 | 0.4613 | -0.0954 | 0.00000026 |
| 4 | -285.565 | 31.3253 | 12.8769 | 13.9059 | 33.9227 | 1.7520 | 0.2117 | 1.1163 | 3.3989 | 1.0793 | -7.8266 | 1.0000 | 0.3141 | 0.8307 | -0.4597 | -0.0979 | -0.4532 | -0.8860 | -0.9443 | 0.3233 | -0.0610 | 19.38088844 |
| 5 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3849017124.1127 | 1.7463 | 0.2149 | 1.1101 | 3.4145 | 1.0744 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.0969 | -0.4538 | -0.8858 | -0.9454 | 0.3203 | -0.0607 | 19.44000719 |
| 6 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 | 0.0577 | 13.6520 | 2.5707 | 7569103646.4039 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | 0.7495 | -0.4837 | 0.4520 | 15.61155034 |
| 7 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 | 0.0577 | 13.6520 | 2.5707 | 438771907.4417 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | 0.7495 | -0.4837 | 0.4520 | 15.61155054 |
| 8 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 | 0.0577 | 13.6520 | 2.5707 | 16962329892899.9922 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | 0.7495 | -0.4837 | 0.4520 | 15.61155205 |
| 9 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 | 0.0577 | 13.6520 | 2.5707 | 38915921303398380336054272.0000 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | 0.7495 | -0.4837 | 0.4520 | 15.61155137 |
| 10 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 | 0.0577 | 13.6520 | 2.5707 | 83156588282.3055 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | 0.7495 | -0.4837 | 0.4520 | 15.61155517 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.394e+04 | 1.465e+04 |
| 2 | 6.081e+03 | 6.102e+03 |
| 3 | 2.505e+03 | 2.620e+03 |
| 4 | 1.900e+03 | 1.940e+03 |
| 5 | 9.298e+02 | 9.297e+02 |
| 6 | 6.039e+02 | 5.956e+02 |
| 7 | 3.504e+02 | 1.055e+02 |
| 8 | 1.571e+02 | 8.796e+01 |
| 9 | 2.600e+01 | 3.420e+01 |
| 10 | 1.783e+01 | 1.735e+01 |
| 11 | 2.303e+00 | 2.234e+00 |
| 12 | 9.134e-01 | 1.201e+00 |
| 13 | -7.779e+00 | 4.680e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 31300.9620, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -276.120 | 24.6972 | -4.1977 | 18.4049 | 9.5037 | 2.4573 | 0.1139 | 0.6911 | 2.1804 | 1.8846 | -8.5741 | 1.0000 | -0.4680 | -0.8347 | 0.2904 | 0.0543 | 0.3008 | 0.9521 | -0.8821 | 0.4613 | -0.0954 | 0.00000000 |
| 2 | -276.120 | 24.6972 | -4.1977 | 18.4049 | 9.5037 | 2.4573 | 0.1139 | 0.6911 | 2.1804 | 1.8846 | -8.5741 | 1.0000 | -0.4680 | -0.8347 | 0.2904 | 0.0543 | 0.3008 | 0.9521 | -0.8821 | 0.4613 | -0.0954 | 0.00000029 |
| 3 | -285.565 | 31.3253 | 12.8769 | 13.9059 | 1.1163 | 3.3989 | 0.2117 | 33.9227 | 1.7520 | 1.0793 | -7.8266 | 1.0000 | -0.3141 | -0.8307 | 0.4597 | 0.0979 | 0.4532 | 0.8860 | -0.9443 | 0.3233 | -0.0610 | 19.38088847 |
| 4 | -285.565 | 31.3253 | 12.8769 | 13.9059 | 1.1163 | 3.3989 | 0.2117 | 33.9227 | 1.7520 | 1.0793 | -7.8266 | 1.0000 | -0.3141 | -0.8307 | 0.4597 | 0.0979 | 0.4532 | 0.8860 | -0.9443 | 0.3233 | -0.0610 | 19.38088827 |
| 5 | -285.565 | 31.3253 | 12.8769 | 13.9059 | 1.1163 | 3.3989 | 0.2117 | 33.9227 | 1.7520 | 1.0793 | -7.8266 | 1.0000 | -0.3141 | -0.8307 | 0.4597 | 0.0979 | 0.4532 | 0.8860 | -0.9443 | 0.3233 | -0.0610 | 19.38088889 |
| 6 | -285.565 | 31.3253 | 12.8769 | 13.9059 | 1.1163 | 3.3989 | 0.2117 | 33.9227 | 1.7520 | 1.0793 | -7.8266 | 1.0000 | -0.3141 | -0.8307 | 0.4597 | 0.0979 | 0.4532 | 0.8860 | -0.9443 | 0.3233 | -0.0610 | 19.38088847 |
| 7 | -285.565 | 31.3253 | 12.8769 | 13.9059 | 1.1163 | 3.3989 | 0.2117 | 33.9227 | 1.7520 | 1.0793 | -7.8266 | 1.0000 | -0.3141 | -0.8307 | 0.4597 | 0.0979 | 0.4532 | 0.8860 | -0.9443 | 0.3233 | -0.0610 | 19.38088854 |
| 8 | -285.577 | 31.2942 | 12.9345 | 13.9126 | 1.1101 | 3.4145 | 0.2149 | 1417.2546 | 1.7464 | 1.0744 | -7.7489 | 1.0000 | -0.3113 | -0.8315 | 0.4600 | 0.0969 | 0.4538 | 0.8858 | -0.9454 | 0.3203 | -0.0607 | 19.43992473 |
| 9 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.1101 | 3.4145 | 0.2149 | 140347.1511 | 1.7463 | 1.0744 | -7.7488 | 1.0000 | -0.3113 | -0.8316 | 0.4600 | 0.0969 | 0.4538 | 0.8858 | -0.9454 | 0.3203 | -0.0607 | 19.44000638 |
| 10 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.1101 | 3.4145 | 0.2149 | 134108476938.7257 | 1.7463 | 1.0744 | -7.7488 | 1.0000 | -0.3113 | -0.8316 | 0.4600 | 0.0969 | 0.4538 | 0.8858 | -0.9454 | 0.3203 | -0.0607 | 19.44000678 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=9.4445, max_pdist=19.3809 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.695e+04 | 3.760e+04 |
| 2 | 6.335e+03 | 6.356e+03 |
| 3 | 4.536e+03 | 4.631e+03 |
| 4 | 9.459e+02 | 9.442e+02 |
| 5 | 7.143e+02 | 6.143e+02 |
| 6 | 5.987e+02 | 4.503e+02 |
| 7 | 3.539e+02 | 1.642e+02 |
| 8 | 1.090e+02 | 1.267e+02 |
| 9 | 3.312e+01 | 3.487e+01 |
| 10 | 1.277e+01 | 1.879e+01 |
| 11 | 2.336e+00 | 2.237e+00 |
| 12 | 5.256e-01 | 1.199e+00 |
| 13 | 3.661e-15 | 4.711e-01 |
| 14 | -5.295e+00 | 8.707e-16 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 43185708449359822848.0000, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 |   Inf | 0.2149 | 1.7463 | 1.1101 | 1.0744 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 |   Inf | 0.2149 | 1.7463 | 1.1101 | 1.0744 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.00000020 |
| 3 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 |   Inf | 0.2149 | 1.7463 | 1.1101 | 1.0744 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.00000007 |
| 4 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 |   Inf | 0.2149 | 1.7463 | 1.1101 | 1.0744 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.00000016 |
| 5 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 |   Inf | 0.2149 | 1.7463 | 1.1101 | 1.0744 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.3113 | 0.8316 | -0.4600 | -0.9454 | 0.3203 | -0.0607 | 0.00000075 |
| 6 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 2.5707 | 0.7862 | 0.0577 | 2.2958 | 13.6520 |   Inf | -4.7255 | 1.0000 | -0.2273 | 0.4533 | 0.8619 | 0.6218 | 0.7487 | -0.2298 | 0.7495 | -0.4837 | 0.4520 | 24.03976714 |
| 7 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 2.5707 | 0.7862 | 0.0577 | 2.2958 | 13.6520 |   Inf | -4.7255 | 1.0000 | -0.2273 | 0.4533 | 0.8619 | 0.6218 | 0.7487 | -0.2298 | 0.7495 | -0.4837 | 0.4520 | 24.03976709 |
| 8 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 2.5707 | 0.7862 | 0.0577 | 2.2958 | 13.6520 |   Inf | -4.7255 | 1.0000 | -0.2273 | 0.4533 | 0.8619 | 0.6218 | 0.7487 | -0.2298 | 0.7495 | -0.4837 | 0.4520 | 24.03976746 |
| 9 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 2.5707 | 0.7862 | 0.0577 | 2.2958 | 13.6520 |   Inf | -4.7255 | 1.0000 | -0.2273 | 0.4533 | 0.8619 | 0.6218 | 0.7487 | -0.2298 | 0.7495 | -0.4837 | 0.4520 | 24.03976889 |
| 10 | -295.609 | 17.6222 | 11.3495 | 14.4072 | 2.7980 |   Inf | 0.1907 | 2.2601 | 1.0171 | 7.8251 | -4.9870 | 1.0000 | 0.0751 | 0.3834 | 0.9205 | -0.2149 | 0.9077 | -0.3605 | 0.9737 | 0.1708 | -0.1506 | 14.22464762 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.424e+04 | 1.858e+04 |
| 2 | 5.378e+03 | 5.893e+03 |
| 3 | 2.578e+03 | 2.603e+03 |
| 4 | 1.724e+03 | 1.337e+03 |
| 5 | 9.534e+02 | 3.765e+02 |
| 6 | 3.030e+02 | 2.303e+02 |
| 7 | 1.241e+02 | 8.215e+01 |
| 8 | 1.794e+01 | 1.735e+01 |
| 9 | 4.227e+00 | 1.305e+01 |
| 10 | 1.821e+00 | 2.664e+00 |
| 11 | 3.993e-01 | 1.360e+00 |
| 12 | -3.382e+02 | 1.049e+00 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 17722.8480, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.7464 | 1.0744 | 1.1101 | 3.4145 | 0.2149 |   Inf | -7.7488 | 1.0000 | -0.0969 | -0.4538 | -0.8858 | 0.9454 | -0.3203 | 0.0607 | -0.3113 | -0.8316 | 0.4600 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.7464 | 1.0744 | 1.1101 | 3.4145 | 0.2149 |   Inf | -7.7488 | 1.0000 | -0.0969 | -0.4538 | -0.8858 | 0.9454 | -0.3203 | 0.0607 | -0.3113 | -0.8316 | 0.4600 | 0.00000109 |
| 3 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.7464 | 1.0744 | 1.1101 | 3.4145 | 0.2149 |   Inf | -7.7488 | 1.0000 | -0.0969 | -0.4538 | -0.8858 | 0.9454 | -0.3203 | 0.0607 | -0.3113 | -0.8316 | 0.4600 | 0.00000032 |
| 4 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 1.7464 | 1.0744 | 1.1101 | 3.4145 | 0.2149 |   Inf | -7.7488 | 1.0000 | -0.0969 | -0.4538 | -0.8858 | 0.9454 | -0.3203 | 0.0607 | -0.3113 | -0.8316 | 0.4600 | 0.00000321 |
| 5 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 1.9907 | 5.3543 | 0.9990 | 2.1751 | 0.2374 |   Inf | -9.0363 | 0.8758 | -0.0995 | -0.3238 | -0.9409 | -0.9119 | -0.3487 | 0.2165 | 0.3982 | -0.8795 | 0.2606 | 16.38342889 |
| 6 | -293.290 | 14.1209 | 7.6913 | 15.6519 | 1.9827 |   Inf | 0.3048 | 2.1320 | 0.1257 | 5.3606 | -9.4839 | 0.8737 | -0.1092 | -0.3214 | -0.9406 | -0.5254 | 0.8219 | -0.2199 | 0.8438 | 0.4702 | -0.2586 | 18.79060020 |
| 7 | -293.932 | 16.2708 | 0.9162 | 12.7213 | 2.4213 |   Inf | 7.8045 | 1.8040 | 0.0492 | 0.8255 | -7.3304 | 0.8953 | 0.2225 | -0.3917 | -0.8928 | -0.7813 | 0.4760 | -0.4036 | -0.5831 | -0.7874 | 0.2002 | 25.00050135 |
| 8 | -293.932 | 16.2708 | 0.9162 | 12.7213 | 2.4213 |   Inf | 7.8045 | 1.8040 | 0.0492 | 0.8255 | -7.3304 | 0.8953 | 0.2225 | -0.3917 | -0.8928 | -0.7813 | 0.4760 | -0.4036 | -0.5831 | -0.7874 | 0.2002 | 25.00050081 |
| 9 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 2.4964 |   Inf | 1.0913 | 2.6833 | 0.1789 | 286643185345509838673090996862976.0000 | -4.2755 | 1.0000 | -0.0694 | -0.3564 | -0.9317 | -0.9819 | -0.1409 | 0.1270 | 0.1765 | -0.9236 | 0.3402 | 13.90940856 |
| 10 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 2.4964 |   Inf | 1.0913 | 2.6833 | 0.1789 | 1349192.5995 | -4.2755 | 1.0000 | -0.0694 | -0.3564 | -0.9317 | -0.9819 | -0.1409 | 0.1270 | 0.1765 | -0.9236 | 0.3402 | 13.90941024 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.541e+04 | 4.734e+04 |
| 2 | 5.379e+03 | 5.158e+03 |
| 3 | 3.401e+03 | 3.039e+03 |
| 4 | 1.601e+03 | 6.490e+02 |
| 5 | 5.946e+02 | 4.403e+02 |
| 6 | 3.201e+02 | 2.142e+02 |
| 7 | 1.620e+02 | 9.628e+01 |
| 8 | 9.231e+00 | 2.527e+01 |
| 9 | 2.628e+00 | 1.310e+01 |
| 10 | 1.343e+00 | 2.664e+00 |
| 11 | -1.652e-15 | 1.364e+00 |
| 12 | -6.228e-01 | 1.051e+00 |
| 13 | -3.082e+02 | -1.882e-15 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 0.2149 |   Inf | 1.7463 | 1.0744 | 1.1101 | 3.4145 | -7.7488 | 1.0000 | -0.9454 | 0.3203 | -0.0607 | 0.3113 | 0.8316 | -0.4600 | -0.0969 | -0.4538 | -0.8858 | 0.00000000 |
| 2 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 0.2374 |   Inf | 1.9907 | 5.3543 | 0.9990 | 2.1751 | -9.0363 | 0.8758 | 0.9119 | 0.3487 | -0.2165 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 16.38342915 |
| 3 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 0.2374 |   Inf | 1.9907 | 5.3543 | 0.9990 | 2.1751 | -9.0363 | 0.8758 | 0.9119 | 0.3487 | -0.2165 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 16.38343166 |
| 4 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 0.2374 |   Inf | 1.9907 | 5.3543 | 0.9990 | 2.1751 | -9.0363 | 0.8758 | 0.9119 | 0.3487 | -0.2165 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 16.38343190 |
| 5 | -293.290 | 14.1209 | 7.6913 | 15.6519 | 0.1257 | 5.3606 | 1.9827 |   Inf | 0.3048 | 2.1320 | -9.4839 | 0.8737 | 0.5254 | -0.8219 | 0.2199 | -0.8438 | -0.4702 | 0.2586 | -0.1092 | -0.3214 | -0.9406 | 18.79060048 |
| 6 | -293.932 | 16.2708 | 0.9162 | 12.7213 | 0.0492 | 0.8255 | 2.4213 |   Inf | 7.8045 | 1.8040 | -7.3304 | 0.8953 | 0.7813 | -0.4760 | 0.4036 | 0.5831 | 0.7874 | -0.2002 | 0.2225 | -0.3917 | -0.8928 | 25.00050377 |
| 7 | -293.932 | 16.2708 | 0.9162 | 12.7213 | 0.0492 | 0.8255 | 2.4213 |   Inf | 7.8045 | 1.8040 | -7.3304 | 0.8953 | 0.7813 | -0.4760 | 0.4036 | 0.5831 | 0.7874 | -0.2002 | 0.2225 | -0.3917 | -0.8928 | 25.00049873 |
| 8 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.0577 | 0.7862 | 2.2958 |   Inf | 13.6520 | 2.5707 | -4.7255 | 1.0000 | 0.7495 | -0.4837 | 0.4520 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | 24.03976477 |
| 9 | -295.609 | 17.6222 | 11.3495 | 14.4072 | 0.1907 |   Inf | 2.2601 | 7.8251 | 1.0171 | 2.7980 | -4.9870 | 1.0000 | 0.9737 | 0.1708 | -0.1506 | -0.2149 | 0.9077 | -0.3605 | -0.0751 | -0.3834 | -0.9205 | 14.22463839 |
| 10 | -295.609 | 17.6222 | 11.3495 | 14.4072 | 0.1907 |   Inf | 2.2601 | 7.8251 | 1.0171 | 2.7980 | -4.9870 | 1.0000 | 0.9737 | 0.1708 | -0.1506 | -0.2149 | 0.9077 | -0.3605 | -0.0751 | -0.3834 | -0.9205 | 14.22464807 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.5314, max_pdist=16.3834 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.046e+04 | 1.273e+04 |
| 2 | 8.299e+03 | 8.662e+03 |
| 3 | 3.263e+03 | 3.243e+03 |
| 4 | 1.433e+03 | 1.593e+03 |
| 5 | 4.705e+02 | 4.460e+02 |
| 6 | 2.731e+02 | 2.450e+02 |
| 7 | 2.005e+02 | 1.112e+02 |
| 8 | 1.852e+01 | 4.174e+01 |
| 9 | 3.743e+00 | 1.337e+01 |
| 10 | 1.844e+00 | 2.666e+00 |
| 11 | 4.837e-01 | 1.361e+00 |
| 12 | 7.108e-11 | 1.048e+00 |
| 13 | -1.873e+02 | -8.755e-08 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 | 1.0744 |   Inf | 1.7463 | 0.2149 | 1.1101 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.9454 | -0.3203 | 0.0607 | 0.3113 | 0.8316 | -0.4600 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 3.4145 | 1.0744 |   Inf | 1.7463 | 0.2149 | 1.1101 | -7.7488 | 1.0000 | 0.0969 | 0.4538 | 0.8858 | 0.9454 | -0.3203 | 0.0607 | 0.3113 | 0.8316 | -0.4600 | 0.00000072 |
| 3 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 2.1751 | 5.3543 |   Inf | 1.9907 | 0.2374 | 0.9990 | -9.0363 | 0.8758 | 0.0995 | 0.3238 | 0.9409 | -0.9119 | -0.3487 | 0.2165 | -0.3982 | 0.8795 | -0.2606 | 16.38342953 |
| 4 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 2.1751 | 5.3543 |   Inf | 1.9907 | 0.2374 | 0.9990 | -9.0363 | 0.8758 | 0.0995 | 0.3238 | 0.9409 | -0.9119 | -0.3487 | 0.2165 | -0.3982 | 0.8795 | -0.2606 | 16.38342963 |
| 5 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 2.1751 | 5.3543 |   Inf | 1.9907 | 0.2374 | 0.9990 | -9.0363 | 0.8758 | 0.0995 | 0.3238 | 0.9409 | -0.9119 | -0.3487 | 0.2165 | -0.3982 | 0.8795 | -0.2606 | 16.38343031 |
| 6 | -293.932 | 16.2708 | 0.9162 | 12.7213 | 1.8040 |   Inf | 0.8255 | 2.4213 | 0.0492 | 7.8045 | -7.3304 | 0.8953 | -0.2225 | 0.3917 | 0.8928 | -0.7813 | 0.4760 | -0.4036 | 0.5831 | 0.7874 | -0.2002 | 25.00050271 |
| 7 | -293.932 | 16.2708 | 0.9162 | 12.7214 | 1.8040 |   Inf | 0.8255 | 2.4213 | 0.0492 | 7.8045 | -7.3304 | 0.8953 | -0.2225 | 0.3917 | 0.8928 | -0.7813 | 0.4760 | -0.4036 | 0.5831 | 0.7874 | -0.2002 | 25.00050324 |
| 8 | -295.609 | 17.6222 | 11.3495 | 14.4072 | 2.7980 | 7.8251 |   Inf | 2.2601 | 0.1907 | 1.0171 | -4.9870 | 1.0000 | 0.0751 | 0.3834 | 0.9205 | -0.9737 | -0.1708 | 0.1506 | -0.2149 | 0.9077 | -0.3605 | 14.22464663 |
| 9 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 2.4290 | 2871785.7732 | 0.8795 | 2.4514 | 0.0675 |   Inf | -4.2745 | 1.0000 | -0.2713 | 0.4446 | 0.8537 | -0.7180 | 0.4971 | -0.4871 | 0.6409 | 0.7451 | -0.1843 | 22.67504332 |
| 10 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 2.6833 |   Inf | 1473377.6653 | 2.4964 | 0.1789 | 1.0913 | -4.2755 | 1.0000 | 0.0694 | 0.3564 | 0.9317 | -0.9819 | -0.1409 | 0.1270 | -0.1765 | 0.9236 | -0.3402 | 13.90941023 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.5314, max_pdist=16.3834 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.391e+04 | 4.522e+04 |
| 2 | 4.943e+03 | 4.832e+03 |
| 3 | 2.378e+03 | 2.294e+03 |
| 4 | 1.956e+03 | 1.484e+03 |
| 5 | 1.241e+03 | 4.844e+02 |
| 6 | 4.041e+02 | 2.342e+02 |
| 7 | 2.177e+02 | 8.827e+01 |
| 8 | 2.026e+01 | 4.261e+01 |
| 9 | 3.128e+00 | 1.326e+01 |
| 10 | 1.804e+00 | 2.669e+00 |
| 11 | 1.165e+00 | 1.365e+00 |
| 12 | 3.361e-10 | 1.057e+00 |
| 13 | -1.187e+02 | 2.424e-06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 18657680291.3171, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -285.577 | 31.2942 | 12.9346 | 13.9126 | 0.2149 | 1.1101 | 3.4145 | 1.0744 |   Inf | 1.7463 | -7.7488 | 1.0000 | -0.9454 | 0.3203 | -0.0607 | -0.3113 | -0.8316 | 0.4600 | 0.0969 | 0.4538 | 0.8858 | 0.00000000 |
| 2 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 0.2374 | 0.9990 | 2.1751 | 5.3543 |   Inf | 1.9907 | -9.0363 | 0.8758 | 0.9119 | 0.3487 | -0.2165 | 0.3982 | -0.8795 | 0.2606 | 0.0995 | 0.3238 | 0.9409 | 16.38342860 |
| 3 | -293.932 | 16.2708 | 0.9162 | 12.7213 | 0.0492 | 7.8045 | 1.8040 |   Inf | 0.8255 | 2.4213 | -7.3304 | 0.8953 | 0.7813 | -0.4760 | 0.4036 | -0.5831 | -0.7874 | 0.2002 | -0.2225 | 0.3917 | 0.8928 | 25.00050205 |
| 4 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.0577 | 13.6520 | 2.5707 |   Inf | 0.7862 | 2.2958 | -4.7255 | 1.0000 | 0.7495 | -0.4837 | 0.4520 | -0.6218 | -0.7487 | 0.2298 | -0.2273 | 0.4533 | 0.8619 | 24.03976894 |
| 5 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.0577 | 13.6520 | 2.5707 |   Inf | 0.7862 | 2.2958 | -4.7255 | 1.0000 | 0.7495 | -0.4837 | 0.4520 | -0.6218 | -0.7487 | 0.2298 | -0.2273 | 0.4533 | 0.8619 | 24.03976574 |
| 6 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.0577 | 13.6520 | 2.5707 |   Inf | 0.7862 | 2.2958 | -4.7255 | 1.0000 | 0.7495 | -0.4837 | 0.4520 | -0.6218 | -0.7487 | 0.2298 | -0.2273 | 0.4533 | 0.8619 | 24.03976739 |
| 7 | -295.609 | 17.6222 | 11.3495 | 14.4072 | 0.1907 | 1.0171 | 2.7980 | 7.8251 |   Inf | 2.2601 | -4.9870 | 1.0000 | 0.9737 | 0.1708 | -0.1506 | 0.2149 | -0.9077 | 0.3605 | 0.0751 | 0.3834 | 0.9205 | 14.22464526 |
| 8 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.0675 |   Inf | 2.4290 | 1867702.9041 | 0.8795 | 2.4514 | -4.2745 | 1.0000 | 0.7180 | -0.4971 | 0.4871 | -0.6409 | -0.7451 | 0.1843 | -0.2713 | 0.4446 | 0.8537 | 22.67504784 |
| 9 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.0675 |   Inf | 2.4290 | 661879.7280 | 0.8795 | 2.4514 | -4.2745 | 1.0000 | 0.7180 | -0.4971 | 0.4871 | -0.6409 | -0.7451 | 0.1843 | -0.2713 | 0.4446 | 0.8537 | 22.67505537 |
| 10 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.0675 |   Inf | 2.4290 | 45481.9730 | 0.8795 | 2.4514 | -4.2745 | 1.0000 | 0.7180 | -0.4971 | 0.4871 | -0.6409 | -0.7451 | 0.1843 | -0.2713 | 0.4446 | 0.8537 | 22.67505262 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=8.3557, max_pdist=25.0005 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 6.105e+04 | 8.004e+04 |
| 2 | 5.265e+03 | 3.733e+03 |
| 3 | 3.491e+03 | 3.193e+03 |
| 4 | 1.572e+03 | 8.218e+02 |
| 5 | 7.663e+02 | 5.263e+02 |
| 6 | 4.569e+02 | 2.376e+02 |
| 7 | 1.985e+02 | 7.087e+01 |
| 8 | 3.961e+01 | 3.516e+01 |
| 9 | 5.303e+00 | 1.321e+01 |
| 10 | 2.184e+00 | 2.662e+00 |
| 11 | 1.315e+00 | 1.363e+00 |
| 12 | 6.634e-10 | 1.046e+00 |
| 13 | -1.058e+02 | -9.841e-07 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -285.577 | 31.2942 | 12.9346 | 13.9126 |   Inf | 1.7464 | 0.2149 | 1.1101 | 3.4145 | 1.0744 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.0969 | -0.4538 | -0.8858 | -0.9454 | 0.3203 | -0.0607 | 0.00000000 |
| 2 | -285.577 | 31.2942 | 12.9346 | 13.9126 |   Inf | 1.7463 | 0.2149 | 1.1101 | 3.4145 | 1.0744 | -7.7488 | 1.0000 | 0.3113 | 0.8316 | -0.4600 | -0.0969 | -0.4538 | -0.8858 | -0.9454 | 0.3203 | -0.0607 | 0.00000434 |
| 3 | -292.108 | 16.0669 | 7.6814 | 15.4767 |   Inf | 1.9907 | 0.2374 | 0.9990 | 2.1751 | 5.3543 | -9.0363 | 0.8758 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 0.9119 | 0.3487 | -0.2165 | 16.38343221 |
| 4 | -292.108 | 16.0669 | 7.6814 | 15.4767 |   Inf | 1.9907 | 0.2374 | 0.9990 | 2.1751 | 5.3543 | -9.0363 | 0.8758 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 0.9119 | 0.3487 | -0.2165 | 16.38343184 |
| 5 | -292.108 | 16.0669 | 7.6814 | 15.4767 |   Inf | 1.9907 | 0.2374 | 0.9990 | 2.1751 | 5.3543 | -9.0363 | 0.8758 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 0.9119 | 0.3487 | -0.2165 | 16.38343082 |
| 6 | -292.108 | 16.0669 | 7.6814 | 15.4767 |   Inf | 1.9907 | 0.2374 | 0.9990 | 2.1751 | 5.3543 | -9.0363 | 0.8758 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 0.9119 | 0.3487 | -0.2165 | 16.38343263 |
| 7 | -292.108 | 16.0669 | 7.6814 | 15.4767 |   Inf | 1.9907 | 0.2374 | 0.9990 | 2.1751 | 5.3543 | -9.0363 | 0.8758 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 0.9119 | 0.3487 | -0.2165 | 16.38343189 |
| 8 | -292.108 | 16.0669 | 7.6814 | 15.4767 |   Inf | 1.9907 | 0.2374 | 0.9990 | 2.1751 | 5.3543 | -9.0363 | 0.8758 | -0.3982 | 0.8795 | -0.2606 | -0.0995 | -0.3238 | -0.9409 | 0.9119 | 0.3487 | -0.2165 | 16.38343240 |
| 9 | -300.748 | 26.9303 | -5.1343 | 19.4126 |   Inf | 1.7018 | 0.4727 | 2.7517 | 1.5675 | 5.5582 | -11.6939 | 0.8794 | -0.7260 | -0.0259 | -0.6872 | 0.6338 | -0.4132 | -0.6539 | 0.2670 | 0.9103 | -0.3164 | 20.07757483 |
| 10 | -300.748 | 26.9303 | -5.1343 | 19.4126 |   Inf | 1.7018 | 0.4727 | 2.7517 | 1.5675 | 5.5582 | -11.6939 | 0.8794 | -0.7260 | -0.0259 | -0.6872 | 0.6338 | -0.4132 | -0.6539 | 0.2670 | 0.9103 | -0.3164 | 20.07757478 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.5314, max_pdist=16.3834 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.298e+04 | 3.296e+04 |
| 2 | 6.430e+03 | 6.412e+03 |
| 3 | 2.782e+03 | 2.863e+03 |
| 4 | 7.100e+02 | 7.150e+02 |
| 5 | 4.593e+02 | 4.182e+02 |
| 6 | 2.072e+02 | 2.136e+02 |
| 7 | 1.362e+02 | 1.190e+02 |
| 8 | 4.191e+01 | 2.856e+01 |
| 9 | 6.162e+00 | 1.311e+01 |
| 10 | 2.878e+00 | 2.666e+00 |
| 11 | 1.290e+00 | 1.360e+00 |
| 12 | 2.405e-09 | 1.046e+00 |
| 13 | -1.070e+01 | 3.172e-06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 10391824656.8928, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -291.164 | 24.8420 | -4.0554 | 17.7528 | 0.1090 | 2.1681 | 0.7294 |   Inf | 2.2667 | 5.5152 | -8.2742 | 1.0000 | -0.8752 | 0.4731 | -0.1012 | 0.0751 | 0.3395 | 0.9376 | 0.4779 | 0.8130 | -0.3327 | 0.00000000 |
| 2 | -292.108 | 16.0669 | 7.6814 | 15.4767 | 0.2374 | 2.1751 |   Inf | 5.3543 | 1.9907 | 0.9990 | -9.0363 | 0.8758 | 0.9119 | 0.3487 | -0.2165 | 0.0995 | 0.3238 | 0.9409 | -0.3982 | 0.8795 | -0.2606 | 15.86733288 |
| 3 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.0577 | 2.5707 | 0.7862 |   Inf | 2.2958 | 13.6520 | -4.7255 | 1.0000 | 0.7495 | -0.4837 | 0.4520 | -0.2273 | 0.4533 | 0.8619 | 0.6218 | 0.7487 | -0.2298 | 15.19960601 |
| 4 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.0675 | 2.4290 | 0.8795 | 748032.2408 | 2.4514 |   Inf | -4.2745 | 1.0000 | 0.7180 | -0.4971 | 0.4871 | -0.2713 | 0.4446 | 0.8537 | 0.6409 | 0.7451 | -0.1843 | 14.60820363 |
| 5 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.0675 | 2.4290 | 0.8795 | 943772008650086144.0000 | 2.4514 |   Inf | -4.2745 | 1.0000 | 0.7180 | -0.4971 | 0.4871 | -0.2713 | 0.4446 | 0.8537 | 0.6409 | 0.7451 | -0.1843 | 14.60821149 |
| 6 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.0675 | 2.4290 | 0.8795 | 5987397.3287 | 2.4514 |   Inf | -4.2745 | 1.0000 | 0.7180 | -0.4971 | 0.4871 | -0.2713 | 0.4446 | 0.8537 | 0.6409 | 0.7451 | -0.1843 | 14.60821935 |
| 7 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 0.1789 | 2.6833 | 112195914214063056.0000 |   Inf | 2.4964 | 1.0913 | -4.2755 | 1.0000 | 0.9819 | 0.1409 | -0.1270 | 0.0694 | 0.3564 | 0.9317 | -0.1765 | 0.9236 | -0.3402 | 17.97812658 |
| 8 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 0.1789 | 2.6833 | 58585855199733304.0000 |   Inf | 2.4964 | 1.0913 | -4.2755 | 1.0000 | 0.9819 | 0.1409 | -0.1270 | 0.0694 | 0.3564 | 0.9317 | -0.1765 | 0.9236 | -0.3402 | 17.97812703 |
| 9 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 0.1789 | 2.6833 | 7424123.8775 |   Inf | 2.4964 | 1.0913 | -4.2755 | 1.0000 | 0.9819 | 0.1409 | -0.1270 | 0.0694 | 0.3564 | 0.9317 | -0.1765 | 0.9236 | -0.3402 | 17.97812696 |
| 10 | -298.135 | 18.1708 | 11.0998 | 14.0455 | 0.1789 | 2.6833 | 663448.7771 |   Inf | 2.4964 | 1.0913 | -4.2755 | 1.0000 | 0.9819 | 0.1409 | -0.1270 | 0.0694 | 0.3564 | 0.9317 | -0.1765 | 0.9236 | -0.3402 | 17.97812662 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=3.5201, max_pdist=15.8673 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.452e+04 | 3.503e+04 |
| 2 | 7.046e+03 | 7.029e+03 |
| 3 | 4.443e+03 | 4.392e+03 |
| 4 | 2.074e+03 | 2.054e+03 |
| 5 | 1.062e+03 | 1.034e+03 |
| 6 | 6.169e+02 | 5.907e+02 |
| 7 | 4.391e+02 | 1.531e+02 |
| 8 | 1.200e+02 | 7.365e+01 |
| 9 | 3.875e+00 | 3.429e+01 |
| 10 | 1.912e+00 | 2.729e+00 |
| 11 | 3.034e-01 | 1.680e+00 |
| 12 | 2.334e-09 | 6.917e-01 |
| 13 | -5.431e+01 | 1.808e-06 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 19378241451.6820, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 |   Inf | 13.6520 | 2.5707 | 0.0577 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | -0.7495 | 0.4837 | -0.4520 | 0.00000000 |
| 2 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 |   Inf | 13.6520 | 2.5707 | 0.0577 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | -0.7495 | 0.4837 | -0.4520 | 0.00000025 |
| 3 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 |   Inf | 13.6520 | 2.5707 | 0.0577 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | -0.7495 | 0.4837 | -0.4520 | 0.00000058 |
| 4 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 |   Inf | 13.6520 | 2.5707 | 0.0577 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | -0.7495 | 0.4837 | -0.4520 | 0.00000505 |
| 5 | -294.684 | 14.6925 | 1.7610 | 14.4348 | 0.7862 | 2.2958 |   Inf | 13.6520 | 2.5707 | 0.0577 | -4.7255 | 1.0000 | 0.6218 | 0.7487 | -0.2298 | 0.2273 | -0.4533 | -0.8619 | -0.7495 | 0.4837 | -0.4520 | 0.00000302 |
| 6 | -295.609 | 17.6222 | 11.3495 | 14.4072 |   Inf | 2.2601 | 7.8251 | 1.0171 | 2.7980 | 0.1907 | -4.9870 | 1.0000 | -0.2149 | 0.9077 | -0.3605 | -0.0751 | -0.3834 | -0.9205 | -0.9737 | -0.1708 | 0.1506 | 15.84062225 |
| 7 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 2.4514 |   Inf | 1479559.0890 | 2.4290 | 0.0675 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.2713 | -0.4446 | -0.8537 | -0.7180 | 0.4971 | -0.4871 | 2.93479770 |
| 8 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 2.4514 |   Inf | 2023694.2249 | 2.4290 | 0.0675 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.2713 | -0.4446 | -0.8537 | -0.7180 | 0.4971 | -0.4871 | 2.93479676 |
| 9 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 2.4514 | 8082060.4329 |   Inf | 2.4290 | 0.0675 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.2713 | -0.4446 | -0.8537 | -0.7180 | 0.4971 | -0.4871 | 2.93479736 |
| 10 | -296.114 | 14.7571 | 2.0896 | 13.0550 | 0.8795 | 2.4514 | 3785038.4320 |   Inf | 2.4290 | 0.0675 | -4.2745 | 1.0000 | 0.6409 | 0.7451 | -0.1843 | 0.2713 | -0.4446 | -0.8537 | -0.7180 | 0.4971 | -0.4871 | 2.93479696 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 6.538e+03 | 6.720e+03 |
| 2 | 3.647e+03 | 3.702e+03 |
| 3 | 2.906e+03 | 2.938e+03 |
| 4 | 9.254e+02 | 1.094e+03 |
| 5 | 2.842e+02 | 2.880e+02 |
| 6 | 1.001e+02 | 5.385e+01 |
| 7 | 2.818e+01 | 2.776e+01 |
| 8 | 1.021e+01 | 9.687e+00 |
| 9 | 5.392e+00 | 5.357e+00 |
| 10 | 3.860e+00 | 1.821e+00 |
| 11 | 2.462e+00 | 6.858e-01 |
| 12 | -5.039e-01 | 3.233e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 20784.0461, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T3_P3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000000 |
| 2 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000022 |
| 3 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000052 |
| 4 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000029 |
| 5 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000007 |
| 6 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000026 |
| 7 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000005 |
| 8 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000006 |
| 9 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000039 |
| 10 | -316.174 | -2.4608 | 14.0519 | 4.6971 | 2.5901 | 0.8873 | 1.4925 | -9.5914 | 0.8732 | -0.9675 | 0.2528 | -0.2528 | -0.9675 | 0.00000002 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T3_P3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.368e+04 | 1.370e+04 |
| 2 | 7.078e+03 | 7.078e+03 |
| 3 | 1.961e+03 | 1.962e+03 |
| 4 | 1.177e+03 | 1.177e+03 |
| 5 | 5.110e+02 | 5.205e+02 |
| 6 | 2.741e+01 | 2.742e+01 |
| 7 | 2.449e+00 | 2.410e+00 |
| 8 | 1.394e+00 | 1.392e+00 |
| 9 | 5.188e-01 | 5.329e-01 |

numDeriv::hessian (operative): cond = 26359.1971, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 25698.7816, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: none

Across 15 scanned models: 5 pass Flag A (convergence), 2 pass strict Flag B, 2 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 10 models that fail Flag A: **10** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **0** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 22 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T1_P1, T1_P2_P3, T1_P2, T1_P3, T2_noP, T2_P1, T2_P2_P3, T2_P2, T2_P3, T2_T3_noP, T2_T3_P1, T2_T3_P2, T3_noP, T3_P1, T3_P2_P3, T3_P2, T3_P3)

| # | Boundary model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv | logLik | n_free | status |
|---|----------------|------|--------------|--------|--------|---------|--------|--------|--------|--------|
| 1 | T3_P2_P3__bd_sigR2 | 700.6 | no | ✗ | ✗ | Inf | 1 | -305.521 | 13 | success |
| 2 | T3_P2_P3__bd_sigR1 | 700.6 | no | ✗ | ✗ | Inf | 1 | -305.522 | 13 | success |
| 3 | T3_P2_P3__bd_sigL3 | 700.6 | no | ✗ | ✗ | Inf | 1 | -305.526 | 13 | success |
| 4 | T3_P2_P3__bd_sigL1 | 700.6 | no | ✗ | ✗ | Inf | 1 | -305.528 | 13 | success |
| 5 | T3_P2_P3__bd_sigL2 | 700.6 | no | ✗ | ✗ | Inf | 1 | -305.530 | 13 | success |
| 6 | T3_P2_P3__bd_sigR3 | 700.6 | no | ✗ | ✗ | Inf | 1 | -305.531 | 13 | success |
| 7 | T2_T3_P1__bd_pd1 | 702.7 | no | ✓ | ✗ | Inf | 7 | -306.548 | 13 | success |
| 8 | T2_T3_P1__bd_pd1_sigL2 | 709.7 | no | ✓ | ✗ | Inf | 3 | -313.494 | 12 | success |
| 9 | T2_T3_P1__bd_pd1_sigR2 | 709.7 | no | ✗ | ✗ | 7.95e+07 | 1 | -313.494 | 12 | success |
| 10 | T2_T3_P1__bd_pd1_sigR1 | 709.7 | no | ✓ | ✗ | Inf | 4 | -313.494 | 12 | success |
| 11 | T2_T3_P1__bd_pd1_sigR3 | 709.7 | no | ✗ | ✗ | Inf | 1 | -313.494 | 12 | success |
| 12 | T2_T3_P1__bd_pd1_sigL1 | 709.7 | no | ✗ | ✗ | Inf | 2 | -313.494 | 12 | success |
| 13 | T2_T3_P1__bd_pd1_sigL3 | 709.7 | no | ✗ | ✗ | Inf | 1 | -313.494 | 12 | success |
| 14 | T2_T3_P1__bd_sigR1 | 716.6 | no | ✓ | ✗ | Inf | 4 | -313.494 | 13 | success |
| 15 | T2_T3_P1__bd_sigL2 | 716.6 | no | ✓ | ✗ | Inf | 3 | -313.494 | 13 | success |
| 16 | T2_T3_P1__bd_sigR2 | 716.6 | no | ✗ | ✗ | Inf | 1 | -313.494 | 13 | success |
| 17 | T2_T3_P1__bd_sigL1 | 716.6 | no | ✗ | ✗ | Inf | 1 | -313.494 | 13 | success |
| 18 | T2_T3_P1__bd_sigL3 | 716.6 | no | ✗ | ✗ | Inf | 1 | -313.494 | 13 | success |
| 19 | T2_T3_P1__bd_sigR3 | 722.5 | no | ✓ | ✗ | Inf | 3 | -316.484 | 13 | success |
| 20 | T3_P3__bd_pd1 | 729.1 | yes ✓ | ✓ | ✓ | 1.13e+04 | 50 | -337.008 | 8 | success |
| 21 | T3_P2_P3__bd_pd1_sigR3 | 730.7 | no | ✓ | ✗ | 1.25e+06 | 6 | -324.012 | 12 | success |
| 22 | T3_P2_P3__bd_pd1_sigL1 | 730.7 | no | ✓ | ✗ | Inf | 17 | -324.012 | 12 | success |
| 23 | T3_P2_P3__bd_pd1_sigR2 | 730.7 | yes ✓ | ✓ | ✓ | 2.99e+05 | 20 | -324.012 | 12 | success |
| 24 | T3_P2_P3__bd_pd1_sigL3 | 730.7 | yes ✓ | ✓ | ✓ | 3.44e+05 | 15 | -324.012 | 12 | success |
| 25 | T3_P2_P3__bd_pd1_sigR1 | 730.7 | no | ✓ | ✗ | Inf | 9 | -324.012 | 12 | success |
| 26 | T3_P2_P3__bd_pd1_sigL2 | 730.7 | no | ✓ | ✗ | Inf | 7 | -324.012 | 12 | success |
| 27 | T1_P3__bd_pd1 | 736.4 | yes ✓ | ✓ | ✓ | 5.96e+03 | 19 | -340.623 | 8 | success |
| 28 | T3_P2_P3__bd_pd1 | 737.6 | no | ✓ | ✗ | Inf | 35 | -324.012 | 13 | success |
| 29 | T1_P3__bd_sigL2 | 752.2 | yes ✓ | ✓ | ✓ | 2.76e+04 | 20 | -348.527 | 8 | success |
| 30 | T1_P3__bd_sigL1 | 752.2 | yes ✓ | ✓ | ✓ | 2.30e+04 | 14 | -348.527 | 8 | success |
| 31 | T1_P3__bd_sigR1 | 752.2 | yes ✓ | ✓ | ✓ | 2.19e+04 | 8 | -348.527 | 8 | success |
| 32 | T1_P3__bd_sigR2 | 752.2 | yes ✓ | ✓ | ✓ | 2.23e+04 | 12 | -348.527 | 8 | success |
| 33 | T1_P3__bd_pd1_sigL1 | 753.1 | yes ✓ | ✓ | ✓ | 2.63e+04 | 38 | -352.417 | 7 | success |
| 34 | T1_P3__bd_pd1_sigL2 | 753.1 | yes ✓ | ✓ | ✓ | 1.63e+04 | 28 | -352.417 | 7 | success |
| 35 | T1_P3__bd_pd1_sigR1 | 753.1 | yes ✓ | ✓ | ✓ | 2.05e+04 | 31 | -352.417 | 7 | success |
| 36 | T1_P3__bd_pd1_sigR2 | 753.1 | yes ✓ | ✓ | ✓ | 1.65e+04 | 28 | -352.417 | 7 | success |
| 37 | T3_P3__bd_sigL1 | 786.6 | yes ✓ | ✓ | ✓ | 1.38e+04 | 36 | -365.741 | 8 | success |
| 38 | T3_P3__bd_sigR1 | 786.6 | yes ✓ | ✓ | ✓ | 1.25e+04 | 33 | -365.741 | 8 | success |
| 39 | T3_P3__bd_sigR2 | 786.6 | yes ✓ | ✓ | ✓ | 1.37e+04 | 30 | -365.741 | 8 | success |
| 40 | T3_P3__bd_sigL2 | 786.6 | yes ✓ | ✓ | ✓ | 1.37e+04 | 38 | -365.741 | 8 | success |
| 41 | T3_P3__bd_pd1_sigR2 | 797.1 | yes ✓ | ✓ | ✓ | 1.26e+04 | 33 | -374.452 | 7 | success |
| 42 | T3_P3__bd_pd1_sigR1 | 797.1 | yes ✓ | ✓ | ✓ | 1.25e+04 | 28 | -374.452 | 7 | success |
| 43 | T3_P3__bd_pd1_sigL2 | 797.1 | yes ✓ | ✓ | ✓ | 1.16e+04 | 33 | -374.452 | 7 | success |
| 44 | T3_P3__bd_pd1_sigL1 | 797.1 | yes ✓ | ✓ | ✓ | 1.23e+04 | 30 | -374.452 | 7 | success |

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T3_P3`
- **pBIC (Ω):** 694.4
- **logLik:** -316.1739
- **Variables:** T3, P3
- **Free parameters (n_free):** 9

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.7816
- **Threshold:** 0.4780
- **Sensitivity:** 0.8971
- **Specificity:** 0.8846
- **Presences / pseudo-absences:** 341 / 641
- **Prevalence:** 0.3466

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | -2.4608, 14.0519 |
| sigltil | 4.6971, 2.5901 |
| sigrtil | 0.8873, 1.4925 |
| ctil | -9.5914 |
| pd | 0.8732 |
| o_mat | -0.9675, 0.2528, -0.2528, -0.9675 |

### Profile likelihoods and arc check

- **Arc check:** 8/9 parameters pass → **AT LEAST ONE FAILS**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | PASS | pass |
| mu2 | FAIL | no_left_crossing;no_right_crossing |
| sigltil1 | PASS | pass |
| sigltil2 | PASS | pass |
| sigrtil1 | PASS | pass |
| sigrtil2 | PASS | pass |
| ctil | PASS | pass |
| pd | PASS | pass |
| o_par1 | PASS | pass |

## Profile likelihood plots

![Profile likelihood plots for the best model (T3_P3)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T3_P3` (pBIC = 694.4)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 18
- **Boundary L4 fits:** 44
- **τ:** 27.5584

_Generated: 2026-07-22 03:43:24_

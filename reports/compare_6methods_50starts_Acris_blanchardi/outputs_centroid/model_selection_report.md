# xsdm v6 — Model selection report (Algorithm2)

**Species:** *Acris blanchardi*

This report documents, step by step, the literal Algorithm2 selection rules
applied to this species. Each phase (L1–L4) includes the rule itself and
the complete list of models with their classification.

**Definition of model success:** a model has `status == "success"` when the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector. Models that fail to converge are marked `failed`; models with fewer than 3 presences are marked `too_few_presences`. Only successful models receive a pBIC and enter the L1 ranking.

## Data and units

- Species directory: `/home/a474r867/work/xsdm_1000_sp_M_v2/outputs_centroid_smoke/Acris_blanchardi`
- Sample size: 655
- Maximum variables per model: 3
- Tau (τ): 25.9385
- L2 threshold: best L1 + τ = 766.7736
- Ω threshold: 763.2327
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
| 1 | T2_T3_P3 ≤τ | T2+T3+P3 | 740.8 | -325.025 | 14 | success |
| 2 | T3_P3 ≤τ | T3+P3 | 745.2 | -343.406 | 9 | success |
| 3 | T1_P2 ≤τ | T1+P2 | 747.6 | -344.634 | 9 | success |
| 4 | T1_P3 ≤τ | T1+P3 | 747.7 | -344.684 | 9 | success |
| 5 | T2_T3_P1 ≤τ | T2+T3+P1 | 749.6 | -329.407 | 14 | success |
| 6 | T1_P1 ≤τ | T1+P1 | 751.6 | -346.624 | 9 | success |
| 7 | T2_P1 ≤τ | T2+P1 | 752.6 | -347.120 | 9 | success |
| 8 | T3_P2 ≤τ | T3+P2 | 754.5 | -348.054 | 9 | success |
| 9 | T2_P3 ≤τ | T2+P3 | 754.8 | -348.230 | 9 | success |
| 10 | T3_P2_P3 ≤τ | T3+P2+P3 | 758.4 | -333.785 | 14 | success |
| 11 | T1_P2_P3 ≤τ | T1+P2+P3 | 759.4 | -334.328 | 14 | success |
| 12 | T2_T3_P2 ≤τ | T2+T3+P2 | 764.2 | -336.694 | 14 | success |
| 13 | T2_P2 | T2+P2 | 773.5 | -357.546 | 9 | success |
| 14 | T1_noP | T1 | 774.6 | -371.064 | 5 | success |
| 15 | T3_P1 | T3+P1 | 778.5 | -360.068 | 9 | success |
| 16 | T2_T3_noP | T2+T3 | 782.1 | -361.881 | 9 | success |
| 17 | T2_P2_P3 | T2+P2+P3 | 782.2 | -345.722 | 14 | success |
| 18 | T3_noP | T3 | 802.7 | -385.116 | 5 | success |
| 19 | T2_noP | T2 | 807.2 | -387.388 | 5 | success |
| 20 | noT_P2_P3 | P2+P3 | 868.0 | -404.833 | 9 | success |
| 21 | noT_P3 | P3 | 873.2 | -420.388 | 5 | success |
| 22 | noT_P2 | P2 | 885.1 | -426.332 | 5 | success |
| 23 | noT_P1 | P1 | 891.3 | -429.447 | 5 | success |

*(The `≤τ` marker identifies models eligible for boundary expansion in L2.)*
**Success** here means `status == "success"`: the optimizer (`optimize_likelihood`) converged and returned a finite best parameter vector; `failed` and `too_few_presences` models do not enter the pBIC ranking.

### BIC vs AIC (L1)

![BIC vs AIC for the 23 L1 models](plots/bic_vs_aic_v7.png)

*Each point is one non-boundary L1 model. BIC = −2·logLik + n_free·log(n) (pBIC); AIC = −2·logLik + 2·n_free. The red point is the smallest pBIC.*

## Phase L2 — boundary models for eligible L1 fits

Rule: expand the L1 models with **pBIC ≤ best_L1 + τ = 766.8**.
**Eligible L1 models:** 12 (T1_P1, T1_P2_P3, T1_P2, T1_P3, T2_P1, T2_P3, T2_T3_P1, T2_T3_P2, T2_T3_P3, T3_P2_P3, T3_P2, T3_P3)

| Boundary model | pBIC | logLik | n_free | status |
|---------------|------|--------|--------|--------|
| T2_T3_P3__bd_pd1_sigR3 | 727.5 | -324.835 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 727.5 | -324.843 | 12 | success |
| T2_T3_P3__bd_pd1_sigL1 | 727.5 | -324.845 | 12 | success |
| T2_T3_P3__bd_pd1_sigR1 | 727.9 | -325.045 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 730.9 | -326.547 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 730.9 | -326.547 | 12 | success |
| T2_T3_P3__bd_sigL3 | 734.4 | -325.032 | 13 | success |
| T2_T3_P3__bd_pd1 | 734.4 | -325.033 | 13 | success |
| T2_T3_P3__bd_sigL1 | 734.4 | -325.048 | 13 | success |
| T2_T3_P3__bd_sigR3 | 737.3 | -326.497 | 13 | success |
| T2_T3_P3__bd_sigL2 | 737.3 | -326.497 | 13 | success |
| T2_T3_P3__bd_sigR1 | 737.3 | -326.497 | 13 | success |
| T2_T3_P3__bd_sigR2 | 737.3 | -326.497 | 13 | success |
| T2_T3_P1__bd_pd1_sigR2 | 737.7 | -329.948 | 12 | success |
| T2_T3_P1__bd_pd1_sigL1 | 737.7 | -329.948 | 12 | success |
| T2_T3_P1__bd_pd1_sigL2 | 737.7 | -329.948 | 12 | success |
| T2_T3_P1__bd_pd1_sigR1 | 737.7 | -329.948 | 12 | success |
| T1_P2__bd_sigL2 | 742.9 | -345.495 | 8 | success |
| T1_P2__bd_sigR2 | 742.9 | -345.512 | 8 | success |
| T1_P2__bd_sigR1 | 742.9 | -345.528 | 8 | success |
| T1_P2__bd_sigL1 | 742.9 | -345.534 | 8 | success |
| T2_T3_P1__bd_sigL2 | 743.1 | -329.407 | 13 | success |
| T2_T3_P1__bd_sigR2 | 743.1 | -329.407 | 13 | success |
| T2_T3_P1__bd_sigL1 | 743.1 | -329.407 | 13 | success |
| T2_P1__bd_pd1_sigR1 | 744.2 | -349.384 | 7 | success |
| T2_P1__bd_pd1_sigL1 | 744.2 | -349.384 | 7 | success |
| T2_P1__bd_pd1_sigR2 | 744.2 | -349.384 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 744.2 | -349.384 | 7 | success |
| T2_T3_P1__bd_pd1 | 744.2 | -329.948 | 13 | success |
| T3_P3__bd_pd1 | 744.7 | -346.390 | 8 | success |
| T1_P3__bd_sigR1 | 745.4 | -346.750 | 8 | success |
| T1_P3__bd_sigL1 | 745.4 | -346.750 | 8 | success |
| T1_P3__bd_sigR2 | 745.4 | -346.750 | 8 | success |
| T1_P3__bd_sigL2 | 745.4 | -346.750 | 8 | success |
| T3_P3__bd_sigR1 | 745.4 | -346.779 | 8 | success |
| T3_P3__bd_sigL1 | 745.4 | -346.779 | 8 | success |
| T3_P3__bd_sigR2 | 745.4 | -346.779 | 8 | success |
| T3_P3__bd_sigL2 | 745.4 | -346.779 | 8 | success |
| T2_P1__bd_sigL1 | 746.8 | -347.457 | 8 | success |
| T2_P1__bd_sigR2 | 746.8 | -347.457 | 8 | success |
| T2_P1__bd_sigR1 | 746.8 | -347.457 | 8 | success |
| T2_P1__bd_sigL2 | 746.8 | -347.457 | 8 | success |
| T2_T3_P1__bd_sigR1 | 747.1 | -331.385 | 13 | success |
| T3_P2__bd_sigR2 | 748.1 | -348.104 | 8 | success |
| T3_P2__bd_sigL1 | 748.2 | -348.148 | 8 | success |
| T3_P2__bd_sigR1 | 748.2 | -348.167 | 8 | success |
| T1_P3__bd_pd1_sigR1 | 748.3 | -351.460 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 748.3 | -351.460 | 7 | success |
| T1_P3__bd_pd1_sigL1 | 748.3 | -351.460 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 748.3 | -351.460 | 7 | success |
| T3_P2__bd_sigL2 | 748.4 | -348.254 | 8 | success |
| T2_P3__bd_sigR2 | 749.1 | -348.635 | 8 | success |
| T2_T3_P1__bd_pd1_sigR3 | 749.5 | -335.848 | 12 | success |
| T2_T3_P1__bd_pd1_sigL3 | 749.5 | -335.855 | 12 | success |
| T2_T3_P1__bd_sigL3 | 750.1 | -332.891 | 13 | success |
| T2_P1__bd_pd1 | 750.5 | -349.297 | 8 | success |
| T1_P3__bd_pd1 | 750.6 | -349.341 | 8 | success |
| T2_P3__bd_sigL1 | 751.5 | -349.803 | 8 | success |
| T2_P3__bd_sigR1 | 751.5 | -349.803 | 8 | success |
| T2_P3__bd_sigL2 | 751.5 | -349.803 | 8 | success |
| T2_P3__bd_pd1_sigL2 | 751.6 | -353.112 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 751.6 | -353.112 | 7 | success |
| T2_P3__bd_pd1_sigR1 | 751.6 | -353.112 | 7 | success |
| T2_P3__bd_pd1_sigR2 | 751.6 | -353.112 | 7 | success |
| T1_P1__bd_pd1 | 752.3 | -350.217 | 8 | success |
| T3_P2_P3__bd_sigR2 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigL3 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigR1 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigL2 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigR3 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigL1 | 752.6 | -334.159 | 13 | success |
| T2_T3_P2__bd_pd1_sigL1 | 752.7 | -337.435 | 12 | success |
| T2_T3_P2__bd_pd1_sigR2 | 752.7 | -337.435 | 12 | success |
| T2_T3_P2__bd_pd1_sigL3 | 752.7 | -337.435 | 12 | success |
| T2_T3_P2__bd_pd1_sigR1 | 752.7 | -337.435 | 12 | success |
| T1_P1__bd_pd1_sigR1 | 752.8 | -353.686 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 752.8 | -353.686 | 7 | success |
| T1_P1__bd_pd1_sigL2 | 752.8 | -353.686 | 7 | success |
| T1_P1__bd_pd1_sigL1 | 752.8 | -353.686 | 7 | success |
| T1_P2_P3__bd_sigR2 | 752.9 | -334.278 | 13 | success |
| T3_P2_P3__bd_pd1_sigL1 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigR2 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigL3 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigR1 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigL2 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigR3 | 754.0 | -338.107 | 12 | success |
| T1_P1__bd_sigR2 | 754.3 | -351.195 | 8 | success |
| T1_P1__bd_sigL1 | 754.3 | -351.199 | 8 | success |
| T1_P1__bd_sigR1 | 754.3 | -351.200 | 8 | success |
| T1_P1__bd_sigL2 | 754.3 | -351.201 | 8 | success |
| T1_P2__bd_pd1_sigR1 | 754.7 | -354.643 | 7 | success |
| T1_P2__bd_pd1_sigL2 | 754.7 | -354.643 | 7 | success |
| T1_P2__bd_pd1_sigR2 | 754.7 | -354.643 | 7 | success |
| T1_P2__bd_pd1_sigL1 | 754.7 | -354.643 | 7 | success |
| T2_T3_P1__bd_sigR3 | 755.3 | -335.481 | 13 | success |
| T1_P2_P3__bd_sigL2 | 756.2 | -335.969 | 13 | success |
| T2_T3_P2__bd_pd1_sigR3 | 756.5 | -339.319 | 12 | success |
| T2_T3_P2__bd_pd1_sigL2 | 756.5 | -339.319 | 12 | success |
| T1_P2_P3__bd_sigR3 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigL1 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigL3 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigR1 | 756.5 | -336.104 | 13 | success |
| T2_T3_P2__bd_sigL1 | 756.8 | -336.252 | 13 | success |
| T2_T3_P2__bd_sigR3 | 756.8 | -336.256 | 13 | success |
| T2_T3_P2__bd_sigL3 | 757.7 | -336.693 | 13 | success |
| T2_T3_P2__bd_sigR1 | 757.8 | -336.751 | 13 | success |
| T1_P2_P3__bd_pd1_sigL2 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigR1 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigR3 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigL1 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigR2 | 758.0 | -340.070 | 12 | success |
| T2_P3__bd_pd1 | 758.0 | -353.051 | 8 | success |
| T2_T3_P2__bd_sigR2 | 758.8 | -337.265 | 13 | success |
| T2_T3_P2__bd_pd1 | 759.2 | -337.435 | 13 | success |
| T2_T3_P2__bd_sigL2 | 759.2 | -337.435 | 13 | success |
| T1_P2_P3__bd_pd1_sigL3 | 759.3 | -340.760 | 12 | success |
| T3_P2_P3__bd_pd1 | 759.7 | -337.689 | 13 | success |
| T1_P2__bd_pd1 | 760.1 | -354.090 | 8 | success |
| T3_P3__bd_pd1_sigR2 | 761.7 | -358.130 | 7 | success |
| T3_P3__bd_pd1_sigL1 | 761.7 | -358.130 | 7 | success |
| T3_P3__bd_pd1_sigR1 | 761.7 | -358.130 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 761.7 | -358.130 | 7 | success |
| T1_P2_P3__bd_pd1 | 763.4 | -339.541 | 13 | success |
| T3_P2__bd_pd1_sigR2 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1_sigL2 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1 | 775.1 | -361.634 | 8 | success |
| T2_noP__bd_pd1 | 800.7 | -387.388 | 4 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_sigR1_sigL2 | 727.3 | no | ✗ | ✗ | Inf | 1 |
| 2 | T2_T3_P3__bd_sigR1_sigR3 | 727.4 | no | ✗ | ✗ | Inf | 1 |
| 3 | T2_T3_P3__bd_pd1_sigR3 | 727.5 | no | ✗ | ✗ | Inf | 1 |
| 4 | T2_T3_P3__bd_pd1_sigL3 | 727.5 | no | ✗ | ✗ | Inf | 1 |
| 5 | T2_T3_P3__bd_pd1_sigL1 | 727.5 | no | ✗ | ✗ | Inf | 1 |
| 6 | T2_T3_P3__bd_pd1_sigR1 | 727.9 | no | ✗ | ✗ | Inf | 1 |
| 7 | T2_T3_P3__bd_pd1_sigL2 | 730.9 | no | ✓ | ✗ | Inf | 14 |
| 8 | T2_T3_P3__bd_pd1_sigR2 | 730.9 | no | ✓ | ✗ | Inf | 3 |
| 9 | T2_T3_P3__bd_sigR1_sigR2 | 732.7 | no | ✓ | ✗ | Inf | 8 |
| 10 | T2_T3_P3__bd_sigL3 | 734.4 | no | ✗ | ✗ | Inf | 1 |
| 11 | T2_T3_P3__bd_pd1 | 734.4 | no | ✗ | ✗ | Inf | 1 |
| 12 | T2_T3_P3__bd_sigL1 | 734.4 | no | ✗ | ✗ | Inf | 1 |
| 13 | T2_T3_P3__bd_sigR3 | 737.3 | no | ✗ | ✓ | 7.07e+04 | 2 |
| 14 | T2_T3_P3__bd_sigL2 | 737.3 | no | ✓ | ✗ | Inf | 5 |
| 15 | T2_T3_P3__bd_sigR1 | 737.3 | yes ✓ | ✓ | ✓ | 1.46e+04 | 3 |
| 16 | T2_T3_P3__bd_sigR2 | 737.3 | no | ✗ | ✗ | Inf | 2 |
| 17 | T2_T3_P1__bd_pd1_sigR2 | 737.7 | no | ✗ | ✓ | 8.00e+05 | 2 |
| 18 | T2_T3_P1__bd_pd1_sigL1 | 737.7 | no | ✗ | ✗ | Inf | 1 |
| 19 | T2_T3_P1__bd_pd1_sigL2 | 737.7 | no | ✗ | ✗ | 4.31e+06 | 1 |
| 20 | T2_T3_P1__bd_pd1_sigR1 | 737.7 | no | ✗ | ✗ | Inf | 1 |
| 21 | T2_T3_P3 | 740.8 | no | ✗ | ✗ | Inf | 1 |
| 22 | T2_T3_P3__bd_sigR1_sigR2_sigR3 | 741.2 | no | ✗ | ✗ | Inf | 1 |
| 23 | T2_T3_P3__bd_sigR1_sigL2_sigR3 | 742.2 | no | ✗ | ✗ | Inf | 1 |
| 24 | T1_P2__bd_sigL2 | 742.9 | no | ✗ | ✗ | Inf | 1 |
| 25 | T1_P2__bd_sigR2 | 742.9 | no | ✗ | ✗ | Inf | 1 |
| 26 | T1_P2__bd_sigR1 | 742.9 | no | ✗ | ✗ | Inf | 1 |
| 27 | T1_P2__bd_sigL1 | 742.9 | no | ✗ | ✗ | Inf | 1 |
| 28 | T2_T3_P1__bd_sigL2 | 743.1 | no | ✗ | ✗ | Inf | 1 |
| 29 | T2_T3_P1__bd_sigR2 | 743.1 | no | ✓ | ✗ | 4.06e+07 | 3 |
| 30 | T2_T3_P1__bd_sigL1 | 743.1 | no | ✗ | ✗ | Inf | 1 |
| 31 | T2_P1__bd_pd1_sigR1 | 744.2 | yes ✓ | ✓ | ✓ | 1.07e+03 | 16 |
| 32 | T2_P1__bd_pd1_sigL1 | 744.2 | yes ✓ | ✓ | ✓ | 1.06e+03 | 12 |
| 33 | T2_P1__bd_pd1_sigR2 | 744.2 | yes ✓ | ✓ | ✓ | 1.07e+03 | 13 |
| 34 | T2_P1__bd_pd1_sigL2 | 744.2 | yes ✓ | ✓ | ✓ | 1.07e+03 | 11 |
| 35 | T2_T3_P1__bd_pd1 | 744.2 | no | ✓ | ✗ | Inf | 10 |
| 36 | T3_P3__bd_pd1 | 744.7 | yes ✓ | ✓ | ✓ | 1.47e+04 | 50 |
| 37 | T3_P3 | 745.2 | yes ✓ | ✓ | ✓ | 5.89e+04 | 33 |
| 38 | T1_P3__bd_sigR1 | 745.4 | yes ✓ | ✓ | ✓ | 1.68e+04 | 21 |
| 39 | T1_P3__bd_sigL1 | 745.4 | yes ✓ | ✓ | ✓ | 1.69e+04 | 13 |
| 40 | T1_P3__bd_sigR2 | 745.4 | yes ✓ | ✓ | ✓ | 1.69e+04 | 19 |
| 41 | T1_P3__bd_sigL2 | 745.4 | no | ✓ | ✗ | Inf | 14 |
| 42 | T3_P3__bd_sigR1 | 745.4 | yes ✓ | ✓ | ✓ | 2.61e+04 | 30 |
| 43 | T3_P3__bd_sigL1 | 745.4 | no | ✓ | ✗ | Inf | 22 |
| 44 | T3_P3__bd_sigR2 | 745.4 | yes ✓ | ✓ | ✓ | 2.53e+04 | 24 |
| 45 | T3_P3__bd_sigL2 | 745.4 | no | ✓ | ✗ | Inf | 24 |
| 46 | T2_P1__bd_sigL1 | 746.8 | yes ✓ | ✓ | ✓ | 5.31e+03 | 16 |
| 47 | T2_P1__bd_sigR2 | 746.8 | yes ✓ | ✓ | ✓ | 4.25e+03 | 5 |
| 48 | T2_P1__bd_sigR1 | 746.8 | yes ✓ | ✓ | ✓ | 4.85e+03 | 14 |
| 49 | T2_P1__bd_sigL2 | 746.8 | yes ✓ | ✓ | ✓ | 4.59e+03 | 7 |
| 50 | T2_T3_P1__bd_sigR1 | 747.1 | no | ✗ | ✗ | Inf | 1 |
| 51 | T1_P2 | 747.6 | no | ✗ | ✗ | Inf | 1 |
| 52 | T1_P3 | 747.7 | no | ✗ | ✓ | 3.69e+04 | 2 |
| 53 | T3_P2__bd_sigR2 | 748.1 | no | ✗ | ✗ | Inf | 1 |
| 54 | T3_P2__bd_sigL1 | 748.2 | no | ✗ | ✗ | Inf | 1 |
| 55 | T3_P2__bd_sigR1 | 748.2 | no | ✗ | ✗ | Inf | 1 |
| 56 | T1_P3__bd_pd1_sigR1 | 748.3 | yes ✓ | ✓ | ✓ | 1.39e+04 | 14 |
| 57 | T1_P3__bd_pd1_sigL2 | 748.3 | yes ✓ | ✓ | ✓ | 1.37e+04 | 12 |
| 58 | T1_P3__bd_pd1_sigL1 | 748.3 | yes ✓ | ✓ | ✓ | 1.55e+04 | 7 |
| 59 | T1_P3__bd_pd1_sigR2 | 748.3 | yes ✓ | ✓ | ✓ | 1.37e+04 | 11 |
| 60 | T3_P2__bd_sigL2 | 748.4 | no | ✗ | ✗ | Inf | 1 |
| 61 | T2_P3__bd_sigR2 | 749.1 | no | ✗ | ✗ | Inf | 1 |
| 62 | T2_T3_P1__bd_pd1_sigR3 | 749.5 | no | ✗ | ✗ | Inf | 1 |
| 63 | T2_T3_P1__bd_pd1_sigL3 | 749.5 | no | ✗ | ✗ | Inf | 1 |
| 64 | T2_T3_P1 | 749.6 | no | ✓ | ✗ | Inf | 6 |
| 65 | T2_T3_P1__bd_sigL3 | 750.1 | no | ✗ | ✗ | Inf | 2 |
| 66 | T2_P1__bd_pd1 | 750.5 | yes ✓ | ✓ | ✓ | 1.52e+03 | 18 |
| 67 | T1_P3__bd_pd1 | 750.6 | yes ✓ | ✓ | ✓ | 1.33e+04 | 46 |
| 68 | T2_P3__bd_sigL1 | 751.5 | yes ✓ | ✓ | ✓ | 1.32e+04 | 6 |
| 69 | T2_P3__bd_sigR1 | 751.5 | yes ✓ | ✓ | ✓ | 1.34e+04 | 12 |
| 70 | T2_P3__bd_sigL2 | 751.5 | yes ✓ | ✓ | ✓ | 1.34e+04 | 7 |
| 71 | T1_P1 | 751.6 | no | ✓ | ✗ | 3.67e+06 | 27 |
| 72 | T2_P3__bd_pd1_sigL2 | 751.6 | yes ✓ | ✓ | ✓ | 8.36e+03 | 12 |
| 73 | T2_P3__bd_pd1_sigL1 | 751.6 | yes ✓ | ✓ | ✓ | 8.49e+03 | 8 |
| 74 | T2_P3__bd_pd1_sigR1 | 751.6 | yes ✓ | ✓ | ✓ | 8.26e+03 | 16 |
| 75 | T2_P3__bd_pd1_sigR2 | 751.6 | yes ✓ | ✓ | ✓ | 8.34e+03 | 9 |
| 76 | T1_P1__bd_pd1 | 752.3 | no | ✓ | ✗ | 1.33e+06 | 45 |
| 77 | T2_P1 | 752.6 | yes ✓ | ✓ | ✓ | 7.37e+03 | 10 |
| 78 | T3_P2_P3__bd_sigR2 | 752.6 | no | ✗ | ✗ | Inf | 1 |
| 79 | T3_P2_P3__bd_sigL3 | 752.6 | no | ✓ | ✗ | 1.40e+06 | 5 |
| 80 | T3_P2_P3__bd_sigR1 | 752.6 | no | ✓ | ✗ | Inf | 3 |
| 81 | T3_P2_P3__bd_sigL2 | 752.6 | no | ✓ | ✗ | Inf | 3 |
| 82 | T3_P2_P3__bd_sigR3 | 752.6 | no | ✓ | ✗ | Inf | 4 |
| 83 | T3_P2_P3__bd_sigL1 | 752.6 | no | ✗ | ✗ | Inf | 1 |
| 84 | T2_T3_P2__bd_pd1_sigL1 | 752.7 | yes ✓ | ✓ | ✓ | 3.92e+05 | 3 |
| 85 | T2_T3_P2__bd_pd1_sigR2 | 752.7 | no | ✗ | ✓ | 5.31e+05 | 2 |
| 86 | T2_T3_P2__bd_pd1_sigL3 | 752.7 | no | ✗ | ✗ | Inf | 2 |
| 87 | T2_T3_P2__bd_pd1_sigR1 | 752.7 | no | ✗ | ✓ | 8.85e+04 | 1 |
| 88 | T1_P1__bd_pd1_sigR1 | 752.8 | yes ✓ | ✓ | ✓ | 5.68e+05 | 10 |
| 89 | T1_P1__bd_pd1_sigR2 | 752.8 | yes ✓ | ✓ | ✓ | 5.77e+05 | 11 |
| 90 | T1_P1__bd_pd1_sigL2 | 752.8 | yes ✓ | ✓ | ✓ | 5.45e+05 | 14 |
| 91 | T1_P1__bd_pd1_sigL1 | 752.8 | no | ✓ | ✗ | Inf | 9 |
| 92 | T1_P2_P3__bd_sigR2 | 752.9 | no | ✗ | ✗ | Inf | 1 |
| 93 | T2_T3_P3__bd_sigR1_sigL2_sigR2_sigR3 | 753.1 | no | ✗ | ✗ | Inf | 1 |
| 94 | T3_P2_P3__bd_pd1_sigL1 | 754.0 | no | ✓ | ✗ | Inf | 18 |
| 95 | T3_P2_P3__bd_pd1_sigR2 | 754.0 | yes ✓ | ✓ | ✓ | 6.62e+04 | 9 |
| 96 | T3_P2_P3__bd_pd1_sigL3 | 754.0 | no | ✓ | ✗ | Inf | 9 |
| 97 | T3_P2_P3__bd_pd1_sigR1 | 754.0 | yes ✓ | ✓ | ✓ | 2.20e+05 | 6 |
| 98 | T3_P2_P3__bd_pd1_sigL2 | 754.0 | yes ✓ | ✓ | ✓ | 1.28e+05 | 3 |
| 99 | T3_P2_P3__bd_pd1_sigR3 | 754.0 | no | ✓ | ✗ | Inf | 4 |
| 100 | T2_T3_P3__bd_sigR1_sigL2_sigR2 | 754.2 | no | ✗ | ✗ | Inf | 1 |
| 101 | T1_P1__bd_sigR2 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 102 | T1_P1__bd_sigL1 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 103 | T1_P1__bd_sigR1 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 104 | T1_P1__bd_sigL2 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 105 | T3_P2 | 754.5 | no | ✗ | ✗ | Inf | 1 |
| 106 | T1_P2__bd_pd1_sigR1 | 754.7 | yes ✓ | ✓ | ✓ | 8.08e+04 | 14 |
| 107 | T1_P2__bd_pd1_sigL2 | 754.7 | yes ✓ | ✓ | ✓ | 8.18e+04 | 17 |
| 108 | T1_P2__bd_pd1_sigR2 | 754.7 | yes ✓ | ✓ | ✓ | 8.05e+04 | 27 |
| 109 | T1_P2__bd_pd1_sigL1 | 754.7 | yes ✓ | ✓ | ✓ | 8.21e+04 | 18 |
| 110 | T2_P3 | 754.8 | no | ✗ | ✗ | Inf | 1 |
| 111 | T2_T3_P1__bd_sigR3 | 755.3 | no | ✗ | ✗ | Inf | 3 |
| 112 | T1_P2_P3__bd_sigL2 | 756.2 | no | ✗ | ✗ | Inf | 1 |
| 113 | T2_T3_P2__bd_pd1_sigR3 | 756.5 | no | ✗ | ✗ | 2.11e+11 | 1 |
| 114 | T2_T3_P2__bd_pd1_sigL2 | 756.5 | no | ✗ | ✗ | Inf | 2 |
| 115 | T1_P2_P3__bd_sigR3 | 756.5 | no | ✓ | ✗ | 6.85e+06 | 3 |
| 116 | T1_P2_P3__bd_sigL1 | 756.5 | no | ✓ | ✗ | Inf | 6 |
| 117 | T1_P2_P3__bd_sigL3 | 756.5 | no | ✓ | ✗ | Inf | 4 |
| 118 | T1_P2_P3__bd_sigR1 | 756.5 | no | ✓ | ✗ | Inf | 7 |
| 119 | T2_T3_P2__bd_sigL1 | 756.8 | no | ✗ | ✗ | Inf | 1 |
| 120 | T2_T3_P2__bd_sigR3 | 756.8 | no | ✗ | ✗ | Inf | 1 |
| 121 | T2_T3_P2__bd_sigL3 | 757.7 | no | ✗ | ✗ | Inf | 1 |
| 122 | T2_T3_P2__bd_sigR1 | 757.8 | no | ✗ | ✗ | Inf | 1 |
| 123 | T1_P2_P3__bd_pd1_sigL2 | 758.0 | no | ✓ | ✗ | Inf | 16 |
| 124 | T1_P2_P3__bd_pd1_sigR1 | 758.0 | no | ✓ | ✗ | Inf | 9 |
| 125 | T1_P2_P3__bd_pd1_sigR3 | 758.0 | no | ✓ | ✗ | Inf | 16 |
| 126 | T1_P2_P3__bd_pd1_sigL1 | 758.0 | no | ✓ | ✗ | Inf | 6 |
| 127 | T1_P2_P3__bd_pd1_sigR2 | 758.0 | no | ✗ | ✗ | Inf | 1 |
| 128 | T2_P3__bd_pd1 | 758.0 | yes ✓ | ✓ | ✓ | 5.81e+04 | 34 |
| 129 | T3_P2_P3 | 758.4 | no | ✓ | ✗ | 1.41e+06 | 7 |
| 130 | T2_T3_P2__bd_sigR2 | 758.8 | no | ✗ | ✗ | Inf | 1 |
| 131 | T2_T3_P2__bd_pd1 | 759.2 | no | ✓ | ✗ | Inf | 13 |
| 132 | T2_T3_P2__bd_sigL2 | 759.2 | no | ✗ | ✗ | Inf | 1 |
| 133 | T1_P2_P3__bd_pd1_sigL3 | 759.3 | yes ✓ | ✓ | ✓ | 4.45e+05 | 10 |
| 134 | T1_P2_P3 | 759.4 | no | ✗ | ✗ | Inf | 1 |
| 135 | T3_P2_P3__bd_pd1 | 759.7 | no | ✓ | ✗ | Inf | 34 |
| 136 | T1_P2__bd_pd1 | 760.1 | yes ✓ | ✓ | ✓ | 5.66e+04 | 40 |
| 137 | T3_P3__bd_pd1_sigR2 | 761.7 | yes ✓ | ✓ | ✓ | 1.24e+04 | 26 |
| 138 | T3_P3__bd_pd1_sigL1 | 761.7 | yes ✓ | ✓ | ✓ | 1.16e+04 | 22 |
| 139 | T3_P3__bd_pd1_sigR1 | 761.7 | yes ✓ | ✓ | ✓ | 1.15e+04 | 22 |
| 140 | T3_P3__bd_pd1_sigL2 | 761.7 | yes ✓ | ✓ | ✓ | 1.46e+04 | 21 |
| 141 | T1_P2_P3__bd_pd1 | 763.4 | yes ✓ | ✓ | ✓ | 2.12e+05 | 37 |
| 142 | T2_T3_P2 | 764.2 | no | ✗ | ✗ | Inf | 1 |
| 143 | T3_P2__bd_pd1_sigR2 | 768.7 | yes ✓ | ✓ | ✓ | 4.71e+04 | 16 |
| 144 | T3_P2__bd_pd1_sigL2 | 768.7 | yes ✓ | ✓ | ✓ | 4.52e+04 | 12 |
| 145 | T3_P2__bd_pd1_sigL1 | 768.7 | no | ✗ | ✓ | 4.53e+04 | 2 |
| 146 | T3_P2__bd_pd1_sigR1 | 768.7 | yes ✓ | ✓ | ✓ | 7.46e+04 | 6 |
| 147 | T2_P2 | 773.5 | no | ✗ | ✗ | Inf | 1 |
| 148 | T1_noP | 774.6 | yes ✓ | ✓ | ✓ | 3.58e+04 | 38 |
| 149 | T3_P2__bd_pd1 | 775.1 | no | ✓ | ✗ | 9.21e+17 | 15 |
| 150 | T3_P1 | 778.5 | no | ✗ | ✗ | Inf | 1 |
| 151 | T2_T3_noP | 782.1 | no | ✗ | ✗ | Inf | 1 |
| 152 | T2_P2_P3 | 782.2 | no | ✗ | ✗ | 1.63e+12 | 2 |
| 153 | T2_noP__bd_pd1 | 800.7 | yes ✓ | ✓ | ✓ | 1.40e+02 | 45 |
| 154 | T3_noP | 802.7 | no | ✗ | ✗ | Inf | 1 |
| 155 | T2_noP | 807.2 | yes ✓ | ✓ | ✓ | 1.40e+02 | 47 |
| 156 | noT_P2_P3 | 868.0 | no | ✗ | ✗ | Inf | 1 |
| 157 | noT_P3 | 873.2 | no | ✓ | ✗ | 7.98e+07 | 3 |
| 158 | noT_P2 | 885.1 | no | ✗ | ✗ | 3.35e+19 | 1 |
| 159 | noT_P1 | 891.3 | no | ✗ | ✗ | Inf | 1 |
| 160 | T2_T3_P3__bd_sigL01_sigR1_sigL2_sigR2_sigR3 | NA | (not scanned) | — | — | — | — |
| 161 | T2_T3_P3__bd_sigL01_sigR1_sigL2_sigR2 | NA | (not scanned) | — | — | — | — |
| 162 | T2_T3_P3__bd_sigL01_sigR1_sigL2_sigR3 | NA | (not scanned) | — | — | — | — |
| 163 | T2_T3_P3__bd_sigL01_sigR1_sigL2 | NA | (not scanned) | — | — | — | — |
| 164 | T2_T3_P3__bd_sigL01_sigR1_sigR2_sigR3 | NA | (not scanned) | — | — | — | — |
| 165 | T2_T3_P3__bd_sigL01_sigR1_sigR2 | NA | (not scanned) | — | — | — | — |
| 166 | T2_T3_P3__bd_sigL01_sigR1_sigR3 | NA | (not scanned) | — | — | — | — |
| 167 | T2_T3_P3__bd_sigL01_sigR1 | NA | (not scanned) | — | — | — | — |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T2_T3_P3__bd_sigR1` — **Ω = 737.3**

## L3 supplementary appendices — per-model diagnostics

### T2_T3_P3__bd_pd1_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -324.835 | 16.8558 | -1.1601 | 10.3507 | 5.8633 | 1.0556 | 0.0000 | 1.6321 | 12.9928 |   Inf | -2.5063 | 1.0000 | 0.2041 | -0.4229 | -0.8829 | 0.5300 | 0.8060 | -0.2635 | 0.8231 | -0.4142 | 0.3886 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994741 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994763 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994749 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994792 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994745 |
| 7 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994801 |
| 8 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.6781 | 0.3590 | 2.0168 | 9.9783 |   Inf | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 0.4049 | -0.8660 | 0.2935 | 58008.49994745 |
| 9 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 5.8521 | 1.0136 | 0.3646 | 1.7274 | 14.8832 |   Inf | -2.4111 | 1.0000 | 0.1658 | -0.4316 | -0.8867 | 0.6191 | 0.7454 | -0.2470 | 0.7676 | -0.5080 | 0.3908 | 58008.54157470 |
| 10 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 5.8521 | 1.0136 | 0.3646 | 1.7274 | 14.8832 |   Inf | -2.4111 | 1.0000 | 0.1658 | -0.4316 | -0.8867 | 0.6191 | 0.7454 | -0.2470 | 0.7676 | -0.5080 | 0.3908 | 58008.54157501 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.7124, max_pdist=58008.4999 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.507e+09 | 1.880e+07 |
| 2 | 3.407e+08 | 1.660e+04 |
| 3 | 7.113e+04 | 1.966e+03 |
| 4 | 7.684e+02 | 7.681e+02 |
| 5 | 4.676e+02 | 4.652e+02 |
| 6 | 2.184e+02 | 2.181e+02 |
| 7 | 5.746e+01 | 5.745e+01 |
| 8 | 7.322e+00 | 7.326e+00 |
| 9 | -4.779e+05 | 2.353e-02 |
| 10 | -5.332e+06 | -7.192e+05 |
| 11 | -1.414e+08 | -9.356e+06 |
| 12 | -3.367e+08 | -2.788e+07 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 3, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -324.843 | 16.8857 | -1.1854 | 10.3142 | 5.8485 | 13.0709 |   Inf | 1.6290 | 1.0557 | 0.0004 | -2.5061 | 1.0000 | 0.2093 | -0.4224 | -0.8819 | -0.5283 | -0.8077 | 0.2615 | -0.8228 | 0.4112 | -0.3922 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 9.9783 |   Inf | 2.0168 | 0.6781 | 0.3590 | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | -0.9130 | -0.3654 | 0.1814 | -0.4049 | 0.8660 | -0.2935 | 2294.09774618 |
| 3 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 5.8521 | 14.8832 |   Inf | 1.7274 | 1.0136 | 0.3646 | -2.4111 | 1.0000 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | -0.7676 | 0.5080 | -0.3908 | 2294.11382819 |
| 4 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 5.8521 | 14.8832 |   Inf | 1.7274 | 1.0136 | 0.3646 | -2.4111 | 1.0000 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | -0.7676 | 0.5080 | -0.3908 | 2294.11382792 |
| 5 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 6.3962 |   Inf | 41862962356417753196746128769417216.0000 | 1.7106 | 1.0414 | 0.6359 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | -0.6564 | -0.7175 | 0.2330 | -0.7495 | 0.5854 | -0.3091 | 2295.28442239 |
| 6 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 6.3962 |   Inf | 446271.3600 | 1.7106 | 1.0414 | 0.6359 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | -0.6564 | -0.7175 | 0.2330 | -0.7495 | 0.5854 | -0.3091 | 2295.28442229 |
| 7 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 6.3962 |   Inf | 411394.1886 | 1.7106 | 1.0414 | 0.6359 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | -0.6564 | -0.7175 | 0.2330 | -0.7495 | 0.5854 | -0.3091 | 2295.28442213 |
| 8 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 6.3962 |   Inf | 228166.5182 | 1.7106 | 1.0414 | 0.6359 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | -0.6565 | -0.7175 | 0.2330 | -0.7495 | 0.5854 | -0.3091 | 2295.28442685 |
| 9 | -328.206 | 17.7356 | -0.4509 | 11.0300 | 6.3962 |   Inf | 297137.3609 | 1.7106 | 1.0414 | 0.6358 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | -0.6564 | -0.7175 | 0.2330 | -0.7495 | 0.5854 | -0.3091 | 2295.28436963 |
| 10 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 6.3962 |   Inf | 160327.0129 | 1.7106 | 1.0414 | 0.6359 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | -0.6564 | -0.7175 | 0.2330 | -0.7495 | 0.5854 | -0.3091 | 2295.28442242 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=2.1571, max_pdist=2294.1138 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.994e+07 | 6.949e+06 |
| 2 | 1.081e+07 | 7.724e+02 |
| 3 | 1.557e+03 | 4.811e+02 |
| 4 | 7.713e+02 | 2.204e+02 |
| 5 | 4.815e+02 | 5.626e+01 |
| 6 | 2.177e+02 | 7.283e+00 |
| 7 | 5.734e+01 | 2.926e-01 |
| 8 | 7.319e+00 | -4.946e+02 |
| 9 | -1.650e+02 | -1.458e+03 |
| 10 | -3.980e+04 | -4.917e+03 |
| 11 | -1.089e+05 | -4.222e+04 |
| 12 | -1.393e+07 | -1.334e+05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 5, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -324.845 | 16.8451 | -1.2070 | 10.4164 |   Inf | 5.8021 | 12.9996 | 0.0007 | 1.6517 | 1.0422 | -2.5174 | 1.0000 | -0.8229 | 0.4098 | -0.3935 | 0.2091 | -0.4256 | -0.8804 | -0.5283 | -0.8068 | 0.2645 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 |   Inf | 5.7891 | 9.9783 | 0.3590 | 2.0168 | 0.6781 | -2.4569 | 1.0000 | -0.4049 | 0.8660 | -0.2935 | -0.0499 | -0.3414 | -0.9386 | -0.9130 | -0.3654 | 0.1814 | 1507.81495093 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 |   Inf | 5.7891 | 9.9783 | 0.3590 | 2.0168 | 0.6781 | -2.4569 | 1.0000 | -0.4049 | 0.8660 | -0.2935 | -0.0499 | -0.3414 | -0.9386 | -0.9130 | -0.3654 | 0.1814 | 1507.81495137 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 |   Inf | 5.7891 | 9.9783 | 0.3590 | 2.0168 | 0.6781 | -2.4569 | 1.0000 | -0.4049 | 0.8660 | -0.2935 | -0.0499 | -0.3414 | -0.9386 | -0.9130 | -0.3654 | 0.1814 | 1507.81495105 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 |   Inf | 5.7891 | 9.9783 | 0.3590 | 2.0168 | 0.6781 | -2.4569 | 1.0000 | -0.4049 | 0.8660 | -0.2935 | -0.0499 | -0.3414 | -0.9386 | -0.9130 | -0.3654 | 0.1814 | 1507.81495118 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 |   Inf | 5.7891 | 9.9783 | 0.3590 | 2.0168 | 0.6781 | -2.4569 | 1.0000 | -0.4049 | 0.8660 | -0.2935 | -0.0499 | -0.3414 | -0.9386 | -0.9130 | -0.3654 | 0.1814 | 1507.81495084 |
| 7 | -327.000 | 17.4069 | -0.6220 | 10.8093 |   Inf | 5.8521 | 14.8832 | 0.3646 | 1.7274 | 1.0136 | -2.4111 | 1.0000 | -0.7676 | 0.5080 | -0.3908 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | 1507.81698814 |
| 8 | -327.000 | 17.4069 | -0.6220 | 10.8093 |   Inf | 5.8521 | 14.8832 | 0.3646 | 1.7274 | 1.0136 | -2.4111 | 1.0000 | -0.7676 | 0.5080 | -0.3908 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | 1507.81698872 |
| 9 | -327.000 | 17.4069 | -0.6220 | 10.8093 |   Inf | 5.8521 | 14.8832 | 0.3646 | 1.7274 | 1.0136 | -2.4111 | 1.0000 | -0.7676 | 0.5080 | -0.3908 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | 1507.81698788 |
| 10 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 1307055.4576 | 6.3962 |   Inf | 0.6359 | 1.7106 | 1.0414 | -2.0837 | 1.0000 | -0.7495 | 0.5854 | -0.3091 | 0.0854 | -0.3775 | -0.9221 | -0.6564 | -0.7175 | 0.2330 | 1508.98771476 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.7023, max_pdist=1507.8150 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 7.846e+06 | 1.323e+06 |
| 2 | 7.448e+04 | 7.672e+03 |
| 3 | 2.195e+03 | 5.231e+03 |
| 4 | 7.739e+02 | 1.376e+03 |
| 5 | 4.772e+02 | 7.734e+02 |
| 6 | 2.196e+02 | 4.272e+02 |
| 7 | 5.782e+01 | 3.809e+02 |
| 8 | 7.299e+00 | 2.053e+02 |
| 9 | -3.546e+03 | 5.793e+01 |
| 10 | -1.054e+04 | 4.789e+01 |
| 11 | -5.258e+04 | 7.303e+00 |
| 12 | -1.677e+06 | 8.126e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 16281783.9176, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -325.045 | 15.6993 | 13.7633 | 8.4022 | 0.0002 | 0.6699 | 2.1265 |   Inf | 9.1630 | 5.6188 | -2.4635 | 1.0000 | 0.3298 | -0.8915 | 0.3106 | 0.9430 | 0.2951 | -0.1541 | 0.0457 | 0.3437 | 0.9380 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645278 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645220 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645199 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0167 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645224 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645220 |
| 7 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645199 |
| 8 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645212 |
| 9 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 0.6781 | 2.0168 |   Inf | 9.9783 | 5.7891 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 4075.33645198 |
| 10 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 0.3646 | 1.0136 | 1.7274 |   Inf | 14.8832 | 5.8521 | -2.4111 | 1.0000 | 0.7676 | -0.5080 | 0.3908 | 0.6191 | 0.7454 | -0.2470 | -0.1658 | 0.4316 | 0.8867 | 4075.40355161 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.5025, max_pdist=4075.3365 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.092e+08 | 3.508e+07 |
| 2 | 5.351e+06 | 3.389e+05 |
| 3 | 3.980e+03 | 1.305e+05 |
| 4 | 7.124e+02 | 2.028e+03 |
| 5 | 4.954e+02 | 7.394e+02 |
| 6 | 1.702e+02 | 6.346e+02 |
| 7 | 5.373e+01 | 4.786e+02 |
| 8 | 6.534e+00 | 2.209e+02 |
| 9 | -1.022e+04 | 5.352e+01 |
| 10 | -4.808e+04 | 1.068e+01 |
| 11 | -2.573e+05 | 6.484e+00 |
| 12 | -3.382e+07 | -6.091e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000041 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000084 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000040 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000089 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000191 |
| 7 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000078 |
| 8 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0167 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000304 |
| 9 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000230 |
| 10 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000155 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 9.814e+03 | 9.713e+03 |
| 2 | 6.566e+02 | 6.563e+02 |
| 3 | 5.338e+02 | 5.341e+02 |
| 4 | 6.163e+01 | 6.233e+01 |
| 5 | 3.150e+01 | 3.028e+01 |
| 6 | 7.706e+00 | 1.210e+01 |
| 7 | 6.130e+00 | 6.679e+00 |
| 8 | 2.396e+00 | 3.300e+00 |
| 9 | 5.231e-01 | 1.508e+00 |
| 10 | 3.197e-01 | 2.823e-01 |
| 11 | -1.379e+00 | 2.393e-01 |
| 12 | -4.002e+00 | 2.932e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 331291.4347, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 9.9783 | 0.3590 | 2.0168 | 0.6781 |   Inf | 5.7891 | -2.4569 | 1.0000 | -0.9130 | -0.3654 | 0.1814 | 0.4049 | -0.8660 | 0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 9.9783 | 0.3590 | 2.0168 | 0.6781 |   Inf | 5.7891 | -2.4569 | 1.0000 | -0.9130 | -0.3654 | 0.1814 | 0.4049 | -0.8660 | 0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000039 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 9.9783 | 0.3590 | 2.0168 | 0.6781 |   Inf | 5.7891 | -2.4569 | 1.0000 | -0.9130 | -0.3654 | 0.1814 | 0.4049 | -0.8660 | 0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000108 |
| 4 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 14.8832 | 0.3646 | 1.7274 | 1.0136 |   Inf | 5.8521 | -2.4111 | 1.0000 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | -0.1658 | 0.4316 | 0.8867 | 10.63756389 |
| 5 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 14.8832 | 0.3646 | 1.7274 | 1.0136 |   Inf | 5.8521 | -2.4111 | 1.0000 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | -0.1658 | 0.4316 | 0.8867 | 10.63756346 |
| 6 | -328.206 | 17.7355 | -0.4508 | 11.0301 |   Inf | 0.6359 | 1.7106 | 1.0414 | 418407.7878 | 6.3962 | -2.0837 | 1.0000 | -0.6564 | -0.7175 | 0.2330 | 0.7495 | -0.5854 | 0.3091 | -0.0854 | 0.3775 | 0.9221 | 10.63084736 |
| 7 | -328.206 | 17.7355 | -0.4508 | 11.0301 |   Inf | 0.6359 | 1.7106 | 1.0414 | 387900.9864 | 6.3962 | -2.0837 | 1.0000 | -0.6564 | -0.7175 | 0.2330 | 0.7495 | -0.5854 | 0.3091 | -0.0854 | 0.3775 | 0.9221 | 10.63086069 |
| 8 | -328.206 | 17.7355 | -0.4508 | 11.0301 |   Inf | 0.6359 | 1.7106 | 1.0414 | 264877.2452 | 6.3962 | -2.0837 | 1.0000 | -0.6564 | -0.7175 | 0.2330 | 0.7495 | -0.5854 | 0.3091 | -0.0854 | 0.3775 | 0.9221 | 10.63084480 |
| 9 | -328.206 | 17.7355 | -0.4508 | 11.0301 |   Inf | 0.6359 | 1.7106 | 1.0414 | 246997.5902 | 6.3962 | -2.0837 | 1.0000 | -0.6564 | -0.7175 | 0.2330 | 0.7495 | -0.5854 | 0.3091 | -0.0854 | 0.3775 | 0.9221 | 10.63084509 |
| 10 | -328.206 | 17.7355 | -0.4508 | 11.0301 |   Inf | 0.6359 | 1.7106 | 1.0414 | 189408.1132 | 6.3962 | -2.0837 | 1.0000 | -0.6564 | -0.7175 | 0.2330 | 0.7495 | -0.5854 | 0.3091 | -0.0854 | 0.3775 | 0.9221 | 10.63084490 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.211e+04 | 1.146e+04 |
| 2 | 6.795e+02 | 6.786e+02 |
| 3 | 6.358e+02 | 6.313e+02 |
| 4 | 7.427e+01 | 7.379e+01 |
| 5 | 5.663e+01 | 5.706e+01 |
| 6 | 2.427e+01 | 2.561e+01 |
| 7 | 8.227e+00 | 1.096e+01 |
| 8 | 6.292e+00 | 5.407e+00 |
| 9 | 4.792e-01 | 2.182e+00 |
| 10 | 2.970e-01 | 2.911e-01 |
| 11 | 2.165e-01 | 2.460e-01 |
| 12 | -3.934e+01 | 2.808e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 408215.6341, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -325.032 | 15.4762 | 13.5748 | 8.5446 | 8.9774 | 2.1034 |   Inf | 0.6429 | 5.4888 | 0.0008 | -2.6198 | 0.9775 | -0.9397 | -0.3012 | 0.1621 | 0.0509 | 0.3455 | 0.9370 | -0.3383 | 0.8887 | -0.3094 | 0.00000000 |
| 2 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 9.5937 | 2.0301 |   Inf | 0.6714 | 5.3129 | 0.3420 | -2.8920 | 0.9426 | -0.8997 | -0.3910 | 0.1940 | 0.0536 | 0.3422 | 0.9381 | -0.4331 | 0.8544 | -0.2869 | 1190.48768173 |
| 3 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 9.5937 | 2.0301 |   Inf | 0.6714 | 5.3129 | 0.3420 | -2.8920 | 0.9426 | -0.8997 | -0.3910 | 0.1940 | 0.0536 | 0.3422 | 0.9381 | -0.4331 | 0.8544 | -0.2869 | 1190.48768241 |
| 4 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 9.5937 | 2.0301 |   Inf | 0.6714 | 5.3129 | 0.3420 | -2.8920 | 0.9426 | -0.8997 | -0.3910 | 0.1940 | 0.0536 | 0.3422 | 0.9381 | -0.4331 | 0.8544 | -0.2869 | 1190.48768242 |
| 5 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 9.5937 | 2.0301 |   Inf | 0.6714 | 5.3129 | 0.3420 | -2.8920 | 0.9426 | -0.8997 | -0.3910 | 0.1940 | 0.0536 | 0.3422 | 0.9381 | -0.4331 | 0.8544 | -0.2869 | 1190.48768190 |
| 6 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 13.5961 | 1.6725 |   Inf | 0.9336 | 5.1528 | 0.3264 | -3.2498 | 0.8929 | -0.6101 | -0.7489 | 0.2585 | -0.1476 | 0.4280 | 0.8917 | -0.7784 | 0.5059 | -0.3717 | 1190.43055694 |
| 7 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 13.5961 | 1.6725 |   Inf | 0.9336 | 5.1528 | 0.3264 | -3.2498 | 0.8929 | -0.6101 | -0.7489 | 0.2585 | -0.1476 | 0.4280 | 0.8917 | -0.7784 | 0.5059 | -0.3717 | 1190.43055706 |
| 8 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 13.5961 | 1.6725 |   Inf | 0.9336 | 5.1528 | 0.3264 | -3.2498 | 0.8929 | -0.6101 | -0.7489 | 0.2585 | -0.1476 | 0.4280 | 0.8917 | -0.7784 | 0.5059 | -0.3717 | 1190.43055697 |
| 9 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 335581.7446 | 1.6460 |   Inf | 0.8906 | 4.8275 | 0.4411 | -3.7263 | 0.8236 | -0.6248 | -0.7371 | 0.2574 | -0.0818 | 0.3896 | 0.9173 | -0.7765 | 0.5521 | -0.3037 | 1191.23014808 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 57433033275330.0000 | 1.6460 |   Inf | 0.8906 | 4.8275 | 0.4411 | -3.7263 | 0.8236 | -0.6248 | -0.7371 | 0.2574 | -0.0818 | 0.3896 | 0.9173 | -0.7765 | 0.5521 | -0.3037 | 1191.23014797 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.4653, max_pdist=1190.4877 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.463e+06 | 1.091e+06 |
| 2 | 2.947e+05 | 7.277e+02 |
| 3 | 2.612e+04 | 5.241e+02 |
| 4 | 7.157e+02 | 3.573e+02 |
| 5 | 5.133e+02 | 1.091e+02 |
| 6 | 1.762e+02 | 5.712e+01 |
| 7 | 5.771e+01 | 6.249e+00 |
| 8 | 6.243e+00 | 7.744e-01 |
| 9 | 2.749e-02 | 6.259e-02 |
| 10 | -5.800e+02 | 1.478e-02 |
| 11 | -1.556e+03 | -8.110e+02 |
| 12 | -1.031e+04 | -2.155e+04 |
| 13 | -5.784e+04 | -2.841e+04 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 3, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -325.033 | 15.6109 | 13.7390 | 8.3424 | 0.0001 | 5.6759 | 0.6422 | 3295.5408 | 2.0947 | 9.1182 | -2.4627 | 1.0000 | 0.3281 | -0.8921 | 0.3107 | -0.0502 | -0.3449 | -0.9373 | 0.9433 | 0.2919 | -0.1579 | 0.00000000 |
| 2 | -325.038 | 15.5767 | 13.6628 | 8.3203 | 0.0004 | 5.7125 | 0.6456 | 632.9392 | 2.0705 | 9.1418 | -2.4591 | 1.0000 | 0.3307 | -0.8918 | 0.3088 | -0.0503 | -0.3435 | -0.9378 | 0.9424 | 0.2946 | -0.1585 | 4641.37442949 |
| 3 | -325.042 | 15.5043 | 13.5798 | 8.3839 | 0.0006 | 5.6872 | 0.6459 | 214314.6950 | 2.0852 | 9.2012 | -2.4619 | 1.0000 | 0.3353 | -0.8900 | 0.3091 | -0.0498 | -0.3444 | -0.9375 | 0.9408 | 0.2990 | -0.1597 | 5778.55232342 |
| 4 | -325.727 | 16.8288 | -1.0914 | 10.9225 | 0.0007 | 5.8443 | 1.0354 | 35065837150723555328.0000 | 1.7231 | 12.8411 | -2.5164 | 1.0000 | 0.8324 | -0.4326 | 0.3462 | 0.1618 | -0.4078 | -0.8986 | 0.5300 | 0.8041 | -0.2695 | 5908.83480057 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 5.7891 | 0.6781 | 1041349136809.8003 | 2.0168 | 9.9783 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 7349.46129402 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 5.7891 | 0.6781 | 74362586.8712 | 2.0168 | 9.9783 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 7349.46129409 |
| 7 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 5.7891 | 0.6781 | 40434282.7994 | 2.0168 | 9.9783 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 7349.46129431 |
| 8 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 5.7891 | 0.6781 | 2006647071374269743104.0000 | 2.0168 | 9.9783 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 7349.46129350 |
| 9 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 5.7891 | 0.6781 | 107986187.9766 | 2.0168 | 9.9783 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 7349.46129399 |
| 10 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 5.7891 | 0.6781 | 1330715419858.9390 | 2.0168 | 9.9783 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.0499 | -0.3414 | -0.9386 | 0.9130 | 0.3654 | -0.1814 | 7349.46129419 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0090, max_pdist=5778.5523 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 9.227e+07 | 1.746e+07 |
| 2 | 2.724e+06 | 2.303e+05 |
| 3 | 2.102e+03 | 6.544e+03 |
| 4 | 7.064e+02 | 3.237e+03 |
| 5 | 4.892e+02 | 9.611e+02 |
| 6 | 1.690e+02 | 7.065e+02 |
| 7 | 5.615e+01 | 5.200e+02 |
| 8 | 6.614e+00 | 4.409e+02 |
| 9 | 1.122e-04 | 1.553e+02 |
| 10 | -3.553e+04 | 5.519e+01 |
| 11 | -1.571e+05 | 6.572e+00 |
| 12 | -3.969e+05 | 4.139e-03 |
| 13 | -1.337e+06 | 6.124e-05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 285181739468.8837, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -325.048 | 15.4531 | 13.4954 | 8.3095 |   Inf | 0.6483 | 5.7445 | 0.0001 | 9.2211 | 2.0468 | -2.4615 | 0.9989 | -0.3384 | 0.8894 | -0.3074 | 0.9397 | 0.3022 | -0.1602 | -0.0496 | -0.3431 | -0.9380 | 0.00000000 |
| 2 | -326.497 | 15.3607 | 9.2392 | 10.1372 |   Inf | 0.6714 | 5.3129 | 0.3420 | 9.5937 | 2.0301 | -2.8920 | 0.9426 | -0.4331 | 0.8544 | -0.2869 | 0.8997 | 0.3910 | -0.1940 | -0.0536 | -0.3422 | -0.9381 | 12961.74039760 |
| 3 | -326.497 | 15.3607 | 9.2392 | 10.1372 |   Inf | 0.6714 | 5.3129 | 0.3420 | 9.5937 | 2.0301 | -2.8920 | 0.9426 | -0.4331 | 0.8544 | -0.2869 | 0.8997 | 0.3910 | -0.1940 | -0.0536 | -0.3422 | -0.9381 | 12961.74039752 |
| 4 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 0.9336 | 5.1528 | 0.3264 | 13.5961 | 1.6725 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.1476 | -0.4280 | -0.8917 | 12961.60859953 |
| 5 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 0.9336 | 5.1528 | 0.3264 | 13.5961 | 1.6725 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.1476 | -0.4280 | -0.8917 | 12961.60859964 |
| 6 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 0.9336 | 5.1528 | 0.3264 | 13.5961 | 1.6725 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.1476 | -0.4280 | -0.8917 | 12961.60859949 |
| 7 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 0.9336 | 5.1528 | 0.3264 | 13.5961 | 1.6725 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.1476 | -0.4280 | -0.8917 | 12961.60859972 |
| 8 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 0.9336 | 5.1528 | 0.3264 | 13.5961 | 1.6725 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.1476 | -0.4280 | -0.8917 | 12961.60859960 |
| 9 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 0.9336 | 5.1528 | 0.3264 | 13.5961 | 1.6725 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.1476 | -0.4280 | -0.8917 | 12961.60859866 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 |   Inf | 0.8906 | 4.8275 | 0.4411 | 181213022.8012 | 1.6460 | -3.7263 | 0.8236 | -0.7765 | 0.5521 | -0.3037 | 0.6248 | 0.7371 | -0.2574 | 0.0818 | -0.3896 | -0.9173 | 12962.40516488 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.4489, max_pdist=12961.7404 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.565e+08 | 3.844e+05 |
| 2 | 1.542e+06 | 1.262e+03 |
| 3 | 5.152e+04 | 7.089e+02 |
| 4 | 7.037e+02 | 2.938e+02 |
| 5 | 4.839e+02 | 7.111e+01 |
| 6 | 1.701e+02 | 4.808e+01 |
| 7 | 5.629e+01 | 1.078e+01 |
| 8 | 6.642e+00 | 4.966e+00 |
| 9 | -7.748e-04 | 9.503e-01 |
| 10 | -2.107e+05 | 5.175e-01 |
| 11 | -5.818e+05 | -7.654e-04 |
| 12 | -3.282e+06 | -2.293e-01 |
| 13 | -6.415e+06 | -2.820e+05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 5, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 3, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 2.0301 | 0.3420 | 9.5937 | 5.3129 |   Inf | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | 0.0536 | 0.3422 | 0.9381 | 0.4331 | -0.8544 | 0.2869 | 0.00000000 |
| 2 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 2.0301 | 0.3420 | 9.5937 | 5.3129 |   Inf | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | 0.0536 | 0.3422 | 0.9381 | 0.4331 | -0.8544 | 0.2869 | 0.00000084 |
| 3 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 | 1.6725 | 0.3264 | 13.5961 | 5.1528 |   Inf | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.1476 | 0.4280 | 0.8917 | 0.7784 | -0.5059 | 0.3717 | 10.28446548 |
| 4 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 | 1.6725 | 0.3264 | 13.5961 | 5.1528 |   Inf | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.1476 | 0.4280 | 0.8917 | 0.7784 | -0.5059 | 0.3717 | 10.28446568 |
| 5 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 | 1.6725 | 0.3264 | 13.5961 | 5.1528 |   Inf | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.1476 | 0.4280 | 0.8917 | 0.7784 | -0.5059 | 0.3717 | 10.28446529 |
| 6 | -327.085 | 17.2001 | -0.9023 | 10.0729 | 1.1022 | 1.5125 | 0.0009 |   Inf | 5.1067 | 1739.4801 | -3.3020 | 0.8422 | 0.5188 | 0.8220 | -0.2348 | -0.2329 | 0.4002 | 0.8864 | 0.8225 | -0.4052 | 0.3990 | 1126.62514581 |
| 7 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 | 1.6460 | 0.4411 | 29508.7056 | 4.8275 |   Inf | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 10.56204096 |
| 8 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 | 1.6460 | 0.4411 |   Inf | 4.8275 | 94890166150742.3594 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 10.56204030 |
| 9 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 | 1.6460 | 0.4411 |   Inf | 4.8275 | 12425817.9423 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 10.56204078 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 | 1.6460 | 0.4411 |   Inf | 4.8275 | 481841.9357 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 10.56204072 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.2120, max_pdist=10.2845 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.145e+03 | 3.147e+03 |
| 2 | 7.491e+02 | 7.483e+02 |
| 3 | 4.561e+02 | 4.554e+02 |
| 4 | 1.200e+02 | 1.217e+02 |
| 5 | 6.150e+01 | 6.158e+01 |
| 6 | 2.280e+01 | 2.234e+01 |
| 7 | 1.461e+01 | 1.370e+01 |
| 8 | 5.232e+00 | 5.131e+00 |
| 9 | 1.903e+00 | 1.995e+00 |
| 10 | 2.909e-01 | 2.793e-01 |
| 11 | 2.592e-01 | 2.736e-01 |
| 12 | 9.460e-02 | 9.079e-02 |
| 13 | 4.448e-02 | 2.858e-02 |

numDeriv::hessian (operative): cond = 70708.7963, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 110099.9058, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 |   Inf | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 0.00000000 |
| 2 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 |   Inf | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 0.00000111 |
| 3 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 |   Inf | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 0.00000166 |
| 4 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 |   Inf | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 0.00000167 |
| 5 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 |   Inf | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 0.00000223 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.90943419 |
| 7 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 |   Inf | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 10.28446586 |
| 8 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 |   Inf | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 10.28446385 |
| 9 | -327.050 | 23.5801 | -8.2544 | 7.7663 | 0.7520 | 5.4495 | 0.9727 | 74293.0070 | 0.0000 |   Inf | -6.5121 | 0.7541 | 0.5729 | 0.7462 | -0.3391 | 0.3959 | -0.6142 | -0.6827 | 0.7177 | -0.2569 | 0.6473 | 215094.02208381 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 |   Inf | 1.6460 | 457105.7559 | 0.4411 | 4.8275 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | -0.0818 | 0.3896 | 0.9173 | 10.56204051 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 9.739e+03 | 9.651e+03 |
| 2 | 6.652e+02 | 6.651e+02 |
| 3 | 5.744e+02 | 5.747e+02 |
| 4 | 6.443e+01 | 6.550e+01 |
| 5 | 3.650e+01 | 3.377e+01 |
| 6 | 5.971e+00 | 1.310e+01 |
| 7 | 5.120e+00 | 6.137e+00 |
| 8 | 2.100e+00 | 3.249e+00 |
| 9 | 8.051e-01 | 1.762e+00 |
| 10 | 3.003e-01 | 2.803e-01 |
| 11 | 1.125e-01 | 2.714e-01 |
| 12 | -5.299e-01 | 9.099e-02 |
| 13 | -1.085e+01 | 3.526e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 273730.4663, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.3420 | 5.3129 | 0.6714 |   Inf | 2.0301 | 9.5937 | -2.8920 | 0.9426 | 0.4331 | -0.8544 | 0.2869 | -0.0536 | -0.3422 | -0.9381 | 0.8997 | 0.3910 | -0.1940 | 0.00000000 |
| 2 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.3420 | 5.3129 | 0.6714 |   Inf | 2.0301 | 9.5937 | -2.8920 | 0.9426 | 0.4331 | -0.8544 | 0.2869 | -0.0536 | -0.3422 | -0.9381 | 0.8997 | 0.3910 | -0.1940 | 0.00000445 |
| 3 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.3420 | 5.3129 | 0.6714 |   Inf | 2.0301 | 9.5937 | -2.8920 | 0.9426 | 0.4331 | -0.8544 | 0.2869 | -0.0536 | -0.3422 | -0.9381 | 0.8997 | 0.3910 | -0.1940 | 0.00000069 |
| 4 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 5.1528 | 0.9336 |   Inf | 1.6725 | 13.5961 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | 0.1476 | -0.4280 | -0.8917 | 0.6101 | 0.7489 | -0.2585 | 10.28446472 |
| 5 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 5.1528 | 0.9336 |   Inf | 1.6725 | 13.5961 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | 0.1476 | -0.4280 | -0.8917 | 0.6101 | 0.7489 | -0.2585 | 10.28446446 |
| 6 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 5.1528 | 0.9336 |   Inf | 1.6725 | 13.5961 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | 0.1476 | -0.4280 | -0.8917 | 0.6101 | 0.7489 | -0.2585 | 10.28446403 |
| 7 | -327.083 | 17.1503 | -0.8362 | 10.0158 | 0.0000 | 5.1363 | 1.1073 | 220858.5617 | 1.5107 |   Inf | -3.2739 | 0.8444 | 0.8206 | -0.4089 | 0.3992 | 0.2319 | -0.4002 | -0.8866 | 0.5223 | 0.8202 | -0.2336 | 53000.20321760 |
| 8 | -327.084 | 17.1657 | -0.8539 | 10.0387 | 0.0003 | 5.1147 | 1.1051 | 14766614.2476 | 1.5126 |   Inf | -3.2929 | 0.8428 | 0.8212 | -0.4075 | 0.3996 | 0.2327 | -0.4003 | -0.8864 | 0.5211 | 0.8208 | -0.2339 | 3102.30476859 |
| 9 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.4411 | 4.8275 | 0.8906 | 11036252630.8020 | 1.6460 |   Inf | -3.7263 | 0.8236 | 0.7765 | -0.5521 | 0.3037 | 0.0818 | -0.3896 | -0.9173 | 0.6248 | 0.7371 | -0.2574 | 10.56203959 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.4411 | 4.8275 | 0.8906 | 5154197994627686184517632.0000 | 1.6460 |   Inf | -3.7263 | 0.8236 | 0.7765 | -0.5521 | 0.3037 | 0.0818 | -0.3896 | -0.9173 | 0.6248 | 0.7371 | -0.2574 | 10.56203974 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.191e+03 | 1.196e+03 |
| 2 | 9.460e+02 | 9.459e+02 |
| 3 | 6.189e+02 | 6.202e+02 |
| 4 | 5.204e+02 | 5.188e+02 |
| 5 | 6.180e+01 | 6.168e+01 |
| 6 | 2.925e+01 | 2.855e+01 |
| 7 | 9.584e+00 | 1.014e+01 |
| 8 | 4.884e+00 | 4.893e+00 |
| 9 | 2.719e+00 | 2.237e+00 |
| 10 | 3.177e-01 | 2.814e-01 |
| 11 | 2.717e-01 | 2.743e-01 |
| 12 | 9.676e-02 | 9.081e-02 |
| 13 | 8.172e-02 | 2.926e-02 |

numDeriv::hessian (operative): cond = 14577.2617, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 40873.1149, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: none

Across 12 scanned models: 4 pass Flag A (convergence), 2 pass strict Flag B, 2 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 8 models that fail Flag A: **7** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **1** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 11 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T2_noP, T2_P2_P3, T2_P2, T2_T3_noP, T3_noP, T3_P1)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T2_T3_P3__bd_sigR1`
- **pBIC (Ω):** 737.3
- **logLik:** -326.4970
- **Variables:** T2, T3, P3
- **Free parameters (n_free):** 13
- **Boundary mask:** sigrtil1=Inf

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.5074
- **Threshold:** 0.5357
- **Sensitivity:** 0.8836
- **Specificity:** 0.6238
- **Presences / pseudo-absences:** 336 / 319
- **Prevalence:** 0.5122

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | 15.3607, 9.2392, 10.1372 |
| sigltil | 0.3420, 5.3129, 0.6714 |
| sigrtil |   Inf, 2.0301, 9.5937 |
| ctil | -2.8920 |
| pd | 0.9426 |
| o_mat | 0.4331, -0.8544, 0.2869, -0.0536, -0.3422, -0.9381, 0.8997, 0.3910, -0.1940 |

### Profile likelihoods and arc check

- **Arc check:** 4/13 parameters pass → **AT LEAST ONE FAILS**

| Parameter | arc check | reason |
|-----------|-----------|--------|
| mu1 | FAIL | no_right_crossing;found_better_ll |
| mu2 | FAIL | no_left_crossing;no_right_crossing |
| mu3 | FAIL | no_right_crossing |
| sigltil1 | FAIL | no_left_crossing;found_better_ll |
| sigltil2 | PASS | pass |
| sigltil3 | PASS | pass |
| sigrtil2 | PASS | pass |
| sigrtil3 | PASS | pass |
| ctil | FAIL | no_left_crossing |
| pd | FAIL | no_right_crossing |
| o_par1 | FAIL | no_left_crossing;found_better_ll |
| o_par2 | FAIL | no_right_crossing;right_not_monotone |
| o_par3 | FAIL | found_better_ll |

## Profile likelihood plots

![Profile likelihood plots for the best model (T2_T3_P3__bd_sigR1)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T2_T3_P3__bd_sigR1` (pBIC = 737.3)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 129
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 03:17:57_

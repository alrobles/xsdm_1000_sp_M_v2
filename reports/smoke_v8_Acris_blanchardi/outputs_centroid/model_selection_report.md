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
- Ω threshold: 770.0992
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
| 3 | T1_P3 ≤τ | T1+P3 | 747.7 | -344.684 | 9 | success |
| 4 | T1_P2 ≤τ | T1+P2 | 747.8 | -344.741 | 9 | success |
| 5 | T2_T3_P1 ≤τ | T2+T3+P1 | 749.6 | -329.407 | 14 | success |
| 6 | T1_P1 ≤τ | T1+P1 | 751.6 | -346.624 | 9 | success |
| 7 | T2_P3 ≤τ | T2+P3 | 752.5 | -347.049 | 9 | success |
| 8 | T2_P1 ≤τ | T2+P1 | 752.6 | -347.120 | 9 | success |
| 9 | T3_P2 ≤τ | T3+P2 | 754.6 | -348.095 | 9 | success |
| 10 | T3_P2_P3 ≤τ | T3+P2+P3 | 758.4 | -333.785 | 14 | success |
| 11 | T1_P2_P3 ≤τ | T1+P2+P3 | 762.9 | -336.066 | 14 | success |
| 12 | T2_T3_P2 ≤τ | T2+T3+P2 | 764.2 | -336.710 | 14 | success |
| 13 | T2_P2 | T2+P2 | 774.1 | -357.884 | 9 | success |
| 14 | T1_noP | T1 | 774.6 | -371.064 | 5 | success |
| 15 | T3_P1 | T3+P1 | 779.0 | -360.338 | 9 | success |
| 16 | T2_P2_P3 | T2+P2+P3 | 782.2 | -345.722 | 14 | success |
| 17 | T2_T3_noP | T2+T3 | 786.1 | -363.889 | 9 | success |
| 18 | T3_noP | T3 | 802.7 | -385.116 | 5 | success |
| 19 | T2_noP | T2 | 807.2 | -387.388 | 5 | success |
| 20 | noT_P2_P3 | P2+P3 | 868.1 | -404.867 | 9 | success |
| 21 | noT_P3 | P3 | 873.2 | -420.388 | 5 | success |
| 22 | noT_P2 | P2 | 887.8 | -427.689 | 5 | success |
| 23 | noT_P1 | P1 | 891.3 | -429.454 | 5 | success |

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
| T2_T3_P3__bd_pd1_sigL1 | 727.5 | -324.842 | 12 | success |
| T2_T3_P3__bd_pd1_sigL2 | 730.9 | -326.547 | 12 | success |
| T2_T3_P3__bd_pd1_sigR3 | 730.9 | -326.547 | 12 | success |
| T2_T3_P3__bd_pd1_sigR1 | 730.9 | -326.547 | 12 | success |
| T2_T3_P3__bd_pd1_sigR2 | 730.9 | -326.547 | 12 | success |
| T2_T3_P3__bd_pd1_sigL3 | 734.2 | -328.206 | 12 | success |
| T2_T3_P3__bd_pd1 | 734.4 | -325.042 | 13 | success |
| T2_T3_P3__bd_sigL1 | 737.3 | -326.497 | 13 | success |
| T2_T3_P3__bd_sigL3 | 737.3 | -326.497 | 13 | success |
| T2_T3_P3__bd_sigL2 | 737.4 | -326.547 | 13 | success |
| T2_T3_P1__bd_pd1_sigL1 | 737.7 | -329.948 | 12 | success |
| T2_T3_P1__bd_pd1_sigR2 | 737.7 | -329.948 | 12 | success |
| T2_T3_P3__bd_sigR1 | 737.7 | -326.709 | 13 | success |
| T2_T3_P3__bd_sigR2 | 737.7 | -326.709 | 13 | success |
| T2_T3_P3__bd_sigR3 | 737.7 | -326.709 | 13 | success |
| T2_T3_P1__bd_sigR3 | 741.5 | -328.595 | 13 | success |
| T1_P2__bd_sigR2 | 742.9 | -345.516 | 8 | success |
| T1_P2__bd_sigR1 | 743.0 | -345.541 | 8 | success |
| T1_P2__bd_sigL2 | 743.0 | -345.543 | 8 | success |
| T1_P2__bd_sigL1 | 743.0 | -345.549 | 8 | success |
| T2_T3_P1__bd_sigL2 | 743.1 | -329.407 | 13 | success |
| T2_T3_P1__bd_sigR2 | 743.1 | -329.407 | 13 | success |
| T2_P1__bd_pd1_sigL1 | 744.2 | -349.384 | 7 | success |
| T2_P1__bd_pd1_sigR1 | 744.2 | -349.384 | 7 | success |
| T2_P1__bd_pd1_sigL2 | 744.2 | -349.384 | 7 | success |
| T2_P1__bd_pd1_sigR2 | 744.2 | -349.384 | 7 | success |
| T2_T3_P1__bd_pd1 | 744.2 | -329.948 | 13 | success |
| T3_P3__bd_pd1 | 744.7 | -346.390 | 8 | success |
| T1_P3__bd_sigR1 | 745.4 | -346.750 | 8 | success |
| T1_P3__bd_sigR2 | 745.4 | -346.750 | 8 | success |
| T1_P3__bd_sigL1 | 745.4 | -346.750 | 8 | success |
| T1_P3__bd_sigL2 | 745.4 | -346.750 | 8 | success |
| T3_P3__bd_sigR1 | 745.4 | -346.779 | 8 | success |
| T3_P3__bd_sigL1 | 745.4 | -346.779 | 8 | success |
| T3_P3__bd_sigL2 | 745.4 | -346.779 | 8 | success |
| T3_P3__bd_sigR2 | 745.4 | -346.779 | 8 | success |
| T2_P1__bd_sigR1 | 746.8 | -347.457 | 8 | success |
| T2_P1__bd_sigL2 | 746.8 | -347.457 | 8 | success |
| T2_P1__bd_sigL1 | 746.8 | -347.457 | 8 | success |
| T2_P1__bd_sigR2 | 746.8 | -347.457 | 8 | success |
| T2_T3_P1__bd_sigR1 | 747.1 | -331.385 | 13 | success |
| T3_P2__bd_sigL1 | 748.2 | -348.157 | 8 | success |
| T3_P2__bd_sigR2 | 748.2 | -348.165 | 8 | success |
| T1_P3__bd_pd1_sigR1 | 748.3 | -351.460 | 7 | success |
| T1_P3__bd_pd1_sigL2 | 748.3 | -351.460 | 7 | success |
| T1_P3__bd_pd1_sigL1 | 748.3 | -351.460 | 7 | success |
| T1_P3__bd_pd1_sigR2 | 748.3 | -351.460 | 7 | success |
| T3_P2__bd_sigR1 | 748.4 | -348.240 | 8 | success |
| T3_P2__bd_sigL2 | 748.8 | -348.473 | 8 | success |
| T2_P3__bd_sigL2 | 749.2 | -348.645 | 8 | success |
| T2_T3_P1__bd_pd1_sigR3 | 749.5 | -335.848 | 12 | success |
| T2_T3_P1__bd_pd1_sigL2 | 749.5 | -335.853 | 12 | success |
| T2_T3_P1__bd_sigL1 | 750.1 | -332.891 | 13 | success |
| T2_T3_P1__bd_sigL3 | 750.1 | -332.891 | 13 | success |
| T2_P1__bd_pd1 | 750.5 | -349.297 | 8 | success |
| T2_T3_P1__bd_pd1_sigR1 | 750.5 | -336.341 | 12 | success |
| T1_P3__bd_pd1 | 750.6 | -349.341 | 8 | success |
| T2_P3__bd_sigR1 | 751.5 | -349.803 | 8 | success |
| T2_P3__bd_sigR2 | 751.5 | -349.803 | 8 | success |
| T2_P3__bd_sigL1 | 751.5 | -349.803 | 8 | success |
| T2_P3__bd_pd1_sigL2 | 751.6 | -353.112 | 7 | success |
| T2_P3__bd_pd1_sigL1 | 751.6 | -353.112 | 7 | success |
| T2_P3__bd_pd1_sigR1 | 751.6 | -353.112 | 7 | success |
| T2_P3__bd_pd1_sigR2 | 751.6 | -353.112 | 7 | success |
| T1_P1__bd_pd1 | 752.3 | -350.217 | 8 | success |
| T3_P2_P3__bd_sigR1 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigL3 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigL1 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigR3 | 752.6 | -334.159 | 13 | success |
| T3_P2_P3__bd_sigR2 | 752.6 | -334.159 | 13 | success |
| T2_T3_P2__bd_pd1_sigL1 | 752.7 | -337.435 | 12 | success |
| T2_T3_P2__bd_pd1_sigR2 | 752.7 | -337.435 | 12 | success |
| T2_T3_P2__bd_pd1_sigL3 | 752.7 | -337.435 | 12 | success |
| T2_T3_P2__bd_pd1_sigR1 | 752.7 | -337.435 | 12 | success |
| T1_P1__bd_pd1_sigL2 | 752.8 | -353.686 | 7 | success |
| T1_P1__bd_pd1_sigR1 | 752.8 | -353.686 | 7 | success |
| T1_P1__bd_pd1_sigR2 | 752.8 | -353.686 | 7 | success |
| T1_P1__bd_pd1_sigL1 | 752.8 | -353.686 | 7 | success |
| T3_P2_P3__bd_pd1_sigL1 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigL3 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigR1 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigR2 | 754.0 | -338.107 | 12 | success |
| T3_P2_P3__bd_pd1_sigR3 | 754.0 | -338.107 | 12 | success |
| T1_P1__bd_sigR2 | 754.3 | -351.195 | 8 | success |
| T1_P1__bd_sigL2 | 754.3 | -351.201 | 8 | success |
| T1_P1__bd_sigL1 | 754.3 | -351.209 | 8 | success |
| T1_P1__bd_sigR1 | 754.3 | -351.215 | 8 | success |
| T1_P2__bd_pd1_sigL1 | 754.7 | -354.643 | 7 | success |
| T1_P2__bd_pd1_sigL2 | 754.7 | -354.643 | 7 | success |
| T1_P2__bd_pd1_sigR2 | 754.7 | -354.643 | 7 | success |
| T1_P2__bd_pd1_sigR1 | 754.7 | -354.643 | 7 | success |
| T3_P2_P3__bd_pd1_sigL2 | 754.7 | -338.455 | 12 | success |
| T3_P2_P3__bd_sigL2 | 756.2 | -335.955 | 13 | success |
| T2_T3_P2__bd_pd1_sigL2 | 756.5 | -339.319 | 12 | success |
| T2_T3_P2__bd_pd1_sigR3 | 756.5 | -339.319 | 12 | success |
| T1_P2_P3__bd_sigL1 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigL3 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigR2 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigR1 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigL2 | 756.5 | -336.104 | 13 | success |
| T1_P2_P3__bd_sigR3 | 756.6 | -336.171 | 13 | success |
| T2_T3_P2__bd_sigR2 | 757.7 | -336.703 | 13 | success |
| T1_P2_P3__bd_pd1_sigL2 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigR1 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigR2 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigR3 | 758.0 | -340.070 | 12 | success |
| T1_P2_P3__bd_pd1_sigL1 | 758.0 | -340.070 | 12 | success |
| T2_P3__bd_pd1 | 758.0 | -353.051 | 8 | success |
| T2_T3_P2__bd_sigR3 | 759.0 | -337.363 | 13 | success |
| T2_T3_P2__bd_pd1 | 759.2 | -337.435 | 13 | success |
| T2_T3_P2__bd_sigL2 | 759.2 | -337.435 | 13 | success |
| T1_P2_P3__bd_pd1_sigL3 | 759.3 | -340.760 | 12 | success |
| T3_P2_P3__bd_pd1 | 759.7 | -337.689 | 13 | success |
| T1_P2__bd_pd1 | 760.1 | -354.090 | 8 | success |
| T2_T3_P1__bd_pd1_sigL3 | 760.1 | -341.131 | 12 | success |
| T2_T3_P2__bd_sigR1 | 761.4 | -338.531 | 13 | success |
| T3_P3__bd_pd1_sigL1 | 761.7 | -358.130 | 7 | success |
| T3_P3__bd_pd1_sigR1 | 761.7 | -358.130 | 7 | success |
| T3_P3__bd_pd1_sigL2 | 761.7 | -358.130 | 7 | success |
| T3_P3__bd_pd1_sigR2 | 761.7 | -358.130 | 7 | success |
| T2_T3_P2__bd_sigL3 | 762.9 | -339.319 | 13 | success |
| T1_P2_P3__bd_pd1 | 763.4 | -339.541 | 13 | success |
| T2_T3_P2__bd_sigL1 | 764.4 | -340.033 | 13 | success |
| T2_P2__bd_pd1 | 767.6 | -357.884 | 8 | success |
| T3_P2__bd_pd1_sigL2 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1_sigR2 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1_sigR1 | 768.7 | -361.634 | 7 | success |
| T3_P2__bd_pd1_sigL1 | 768.9 | -361.736 | 7 | success |
| T3_P2__bd_pd1 | 775.1 | -361.634 | 8 | success |
| T2_noP__bd_pd1 | 800.7 | -387.388 | 4 | success |
| noT_P2__bd_pd1 | 881.3 | -427.688 | 4 | success |

## Phase L3 — union of L1 ∪ L2 and the well-behaved scan

Rule: combine L1 and L2, sort by ascending pBIC, and accept the **first**
model with both Flag A and Flag B passing. That model is M_Ω.

| # | Model | pBIC | well-behaved | Flag A | Flag B | cond no. | n_conv |
|---|-------|------|--------------|--------|--------|---------|--------|
| 1 | T2_T3_P3__bd_pd1_sigL1 | 727.5 | no | ✗ | ✗ | Inf | 1 |
| 2 | T2_T3_P3__bd_pd1_sigL2 | 730.9 | no | ✓ | ✗ | Inf | 5 |
| 3 | T2_T3_P3__bd_pd1_sigR3 | 730.9 | no | ✗ | ✗ | Inf | 2 |
| 4 | T2_T3_P3__bd_pd1_sigR1 | 730.9 | no | ✓ | ✗ | Inf | 6 |
| 5 | T2_T3_P3__bd_pd1_sigR2 | 730.9 | no | ✗ | ✓ | 5.98e+05 | 1 |
| 6 | T2_T3_P3__bd_pd1_sigL3 | 734.2 | no | ✓ | ✗ | Inf | 4 |
| 7 | T2_T3_P3__bd_pd1 | 734.4 | no | ✗ | ✗ | Inf | 1 |
| 8 | T2_T3_P3__bd_sigL1 | 737.3 | no | ✗ | ✗ | Inf | 1 |
| 9 | T2_T3_P3__bd_sigL3 | 737.3 | no | ✗ | ✗ | Inf | 1 |
| 10 | T2_T3_P3__bd_sigL2 | 737.4 | no | ✗ | ✗ | Inf | 1 |
| 11 | T2_T3_P1__bd_pd1_sigL1 | 737.7 | no | ✗ | ✗ | Inf | 1 |
| 12 | T2_T3_P1__bd_pd1_sigR2 | 737.7 | no | ✗ | ✗ | 2.57e+07 | 1 |
| 13 | T2_T3_P3__bd_sigR1 | 737.7 | no | ✓ | ✗ | Inf | 7 |
| 14 | T2_T3_P3__bd_sigR2 | 737.7 | no | ✗ | ✗ | Inf | 1 |
| 15 | T2_T3_P3__bd_sigR3 | 737.7 | no | ✓ | ✗ | Inf | 3 |
| 16 | T2_T3_P3 | 740.8 | no | ✗ | ✗ | Inf | 1 |
| 17 | T2_T3_P1__bd_sigR3 | 741.5 | no | ✗ | ✗ | Inf | 1 |
| 18 | T1_P2__bd_sigR2 | 742.9 | no | ✗ | ✗ | Inf | 1 |
| 19 | T1_P2__bd_sigR1 | 743.0 | no | ✗ | ✗ | Inf | 1 |
| 20 | T1_P2__bd_sigL2 | 743.0 | no | ✗ | ✗ | Inf | 1 |
| 21 | T1_P2__bd_sigL1 | 743.0 | no | ✗ | ✗ | Inf | 1 |
| 22 | T2_T3_P1__bd_sigL2 | 743.1 | no | ✗ | ✗ | Inf | 2 |
| 23 | T2_T3_P1__bd_sigR2 | 743.1 | no | ✗ | ✗ | 4.06e+07 | 2 |
| 24 | T2_P1__bd_pd1_sigL1 | 744.2 | yes ✓ | ✓ | ✓ | 1.06e+03 | 7 |
| 25 | T2_P1__bd_pd1_sigR1 | 744.2 | yes ✓ | ✓ | ✓ | 1.07e+03 | 7 |
| 26 | T2_P1__bd_pd1_sigL2 | 744.2 | yes ✓ | ✓ | ✓ | 1.07e+03 | 7 |
| 27 | T2_P1__bd_pd1_sigR2 | 744.2 | yes ✓ | ✓ | ✓ | 1.08e+03 | 5 |
| 28 | T2_T3_P1__bd_pd1 | 744.2 | no | ✓ | ✗ | Inf | 3 |
| 29 | T3_P3__bd_pd1 | 744.7 | yes ✓ | ✓ | ✓ | 1.70e+04 | 25 |
| 30 | T3_P3 | 745.2 | yes ✓ | ✓ | ✓ | 2.20e+04 | 16 |
| 31 | T1_P3__bd_sigR1 | 745.4 | yes ✓ | ✓ | ✓ | 1.68e+04 | 10 |
| 32 | T1_P3__bd_sigR2 | 745.4 | yes ✓ | ✓ | ✓ | 1.71e+04 | 8 |
| 33 | T1_P3__bd_sigL1 | 745.4 | yes ✓ | ✓ | ✓ | 1.69e+04 | 9 |
| 34 | T1_P3__bd_sigL2 | 745.4 | no | ✓ | ✗ | Inf | 8 |
| 35 | T3_P3__bd_sigR1 | 745.4 | yes ✓ | ✓ | ✓ | 2.61e+04 | 16 |
| 36 | T3_P3__bd_sigL1 | 745.4 | yes ✓ | ✓ | ✓ | 2.80e+04 | 11 |
| 37 | T3_P3__bd_sigL2 | 745.4 | no | ✓ | ✗ | Inf | 7 |
| 38 | T3_P3__bd_sigR2 | 745.4 | yes ✓ | ✓ | ✓ | 2.53e+04 | 15 |
| 39 | T2_P1__bd_sigR1 | 746.8 | yes ✓ | ✓ | ✓ | 5.37e+03 | 7 |
| 40 | T2_P1__bd_sigL2 | 746.8 | yes ✓ | ✓ | ✓ | 4.59e+03 | 3 |
| 41 | T2_P1__bd_sigL1 | 746.8 | yes ✓ | ✓ | ✓ | 5.28e+03 | 3 |
| 42 | T2_P1__bd_sigR2 | 746.8 | yes ✓ | ✓ | ✓ | 5.10e+03 | 3 |
| 43 | T2_T3_P1__bd_sigR1 | 747.1 | no | ✗ | ✗ | Inf | 1 |
| 44 | T1_P3 | 747.7 | no | ✗ | ✗ | Inf | 1 |
| 45 | T1_P2 | 747.8 | no | ✗ | ✗ | Inf | 1 |
| 46 | T3_P2__bd_sigL1 | 748.2 | no | ✗ | ✗ | Inf | 1 |
| 47 | T3_P2__bd_sigR2 | 748.2 | no | ✗ | ✗ | Inf | 1 |
| 48 | T1_P3__bd_pd1_sigR1 | 748.3 | yes ✓ | ✓ | ✓ | 1.39e+04 | 7 |
| 49 | T1_P3__bd_pd1_sigL2 | 748.3 | yes ✓ | ✓ | ✓ | 1.44e+04 | 9 |
| 50 | T1_P3__bd_pd1_sigL1 | 748.3 | yes ✓ | ✓ | ✓ | 1.37e+04 | 4 |
| 51 | T1_P3__bd_pd1_sigR2 | 748.3 | yes ✓ | ✓ | ✓ | 1.38e+04 | 5 |
| 52 | T3_P2__bd_sigR1 | 748.4 | no | ✗ | ✗ | Inf | 1 |
| 53 | T3_P2__bd_sigL2 | 748.8 | no | ✗ | ✗ | Inf | 1 |
| 54 | T2_P3__bd_sigL2 | 749.2 | no | ✗ | ✗ | Inf | 1 |
| 55 | T2_T3_P1__bd_pd1_sigR3 | 749.5 | no | ✗ | ✗ | Inf | 1 |
| 56 | T2_T3_P1__bd_pd1_sigL2 | 749.5 | no | ✗ | ✗ | Inf | 1 |
| 57 | T2_T3_P1 | 749.6 | no | ✗ | ✗ | 2.86e+13 | 1 |
| 58 | T2_T3_P1__bd_sigL1 | 750.1 | no | ✗ | ✗ | Inf | 1 |
| 59 | T2_T3_P1__bd_sigL3 | 750.1 | no | ✗ | ✗ | Inf | 1 |
| 60 | T2_P1__bd_pd1 | 750.5 | yes ✓ | ✓ | ✓ | 1.68e+03 | 9 |
| 61 | T2_T3_P1__bd_pd1_sigR1 | 750.5 | no | ✗ | ✗ | Inf | 1 |
| 62 | T1_P3__bd_pd1 | 750.6 | yes ✓ | ✓ | ✓ | 1.34e+04 | 22 |
| 63 | T2_P3__bd_sigR1 | 751.5 | yes ✓ | ✓ | ✓ | 1.26e+04 | 4 |
| 64 | T2_P3__bd_sigR2 | 751.5 | no | ✗ | ✓ | 1.51e+04 | 2 |
| 65 | T2_P3__bd_sigL1 | 751.5 | no | ✗ | ✓ | 1.32e+04 | 1 |
| 66 | T1_P1 | 751.6 | no | ✓ | ✗ | 8.86e+06 | 10 |
| 67 | T2_P3__bd_pd1_sigL2 | 751.6 | yes ✓ | ✓ | ✓ | 8.47e+03 | 5 |
| 68 | T2_P3__bd_pd1_sigL1 | 751.6 | yes ✓ | ✓ | ✓ | 8.49e+03 | 7 |
| 69 | T2_P3__bd_pd1_sigR1 | 751.6 | yes ✓ | ✓ | ✓ | 8.69e+03 | 9 |
| 70 | T2_P3__bd_pd1_sigR2 | 751.6 | yes ✓ | ✓ | ✓ | 8.44e+03 | 5 |
| 71 | T1_P1__bd_pd1 | 752.3 | no | ✓ | ✗ | 7.22e+06 | 20 |
| 72 | T2_P3 | 752.5 | no | ✗ | ✗ | Inf | 1 |
| 73 | T2_P1 | 752.6 | yes ✓ | ✓ | ✓ | 8.59e+03 | 8 |
| 74 | T3_P2_P3__bd_sigR1 | 752.6 | no | ✗ | ✗ | Inf | 1 |
| 75 | T3_P2_P3__bd_sigL3 | 752.6 | no | ✗ | ✓ | 8.08e+05 | 1 |
| 76 | T3_P2_P3__bd_sigL1 | 752.6 | no | ✗ | ✗ | Inf | 2 |
| 77 | T3_P2_P3__bd_sigR3 | 752.6 | no | ✗ | ✗ | 1.92e+06 | 2 |
| 78 | T3_P2_P3__bd_sigR2 | 752.6 | no | ✗ | ✗ | Inf | 1 |
| 79 | T2_T3_P2__bd_pd1_sigL1 | 752.7 | no | ✗ | ✓ | 3.92e+05 | 2 |
| 80 | T2_T3_P2__bd_pd1_sigR2 | 752.7 | no | ✗ | ✓ | 5.31e+05 | 1 |
| 81 | T2_T3_P2__bd_pd1_sigL3 | 752.7 | no | ✗ | ✗ | Inf | 2 |
| 82 | T2_T3_P2__bd_pd1_sigR1 | 752.7 | no | ✗ | ✗ | Inf | 2 |
| 83 | T1_P1__bd_pd1_sigL2 | 752.8 | no | ✓ | ✗ | Inf | 8 |
| 84 | T1_P1__bd_pd1_sigR1 | 752.8 | no | ✓ | ✗ | Inf | 5 |
| 85 | T1_P1__bd_pd1_sigR2 | 752.8 | no | ✓ | ✗ | Inf | 5 |
| 86 | T1_P1__bd_pd1_sigL1 | 752.8 | yes ✓ | ✓ | ✓ | 5.32e+05 | 3 |
| 87 | T3_P2_P3__bd_pd1_sigL1 | 754.0 | no | ✓ | ✗ | Inf | 11 |
| 88 | T3_P2_P3__bd_pd1_sigL3 | 754.0 | no | ✓ | ✗ | Inf | 6 |
| 89 | T3_P2_P3__bd_pd1_sigR1 | 754.0 | yes ✓ | ✓ | ✓ | 1.15e+05 | 3 |
| 90 | T3_P2_P3__bd_pd1_sigR2 | 754.0 | no | ✓ | ✗ | Inf | 5 |
| 91 | T3_P2_P3__bd_pd1_sigR3 | 754.0 | no | ✗ | ✓ | 6.85e+04 | 2 |
| 92 | T1_P1__bd_sigR2 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 93 | T1_P1__bd_sigL2 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 94 | T1_P1__bd_sigL1 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 95 | T1_P1__bd_sigR1 | 754.3 | no | ✗ | ✗ | Inf | 1 |
| 96 | T3_P2 | 754.6 | no | ✗ | ✗ | Inf | 1 |
| 97 | T1_P2__bd_pd1_sigL1 | 754.7 | yes ✓ | ✓ | ✓ | 8.21e+04 | 9 |
| 98 | T1_P2__bd_pd1_sigL2 | 754.7 | yes ✓ | ✓ | ✓ | 8.14e+04 | 6 |
| 99 | T1_P2__bd_pd1_sigR2 | 754.7 | yes ✓ | ✓ | ✓ | 8.22e+04 | 12 |
| 100 | T1_P2__bd_pd1_sigR1 | 754.7 | yes ✓ | ✓ | ✓ | 8.08e+04 | 10 |
| 101 | T3_P2_P3__bd_pd1_sigL2 | 754.7 | no | ✗ | ✓ | 1.59e+05 | 2 |
| 102 | T3_P2_P3__bd_sigL2 | 756.2 | no | ✗ | ✗ | Inf | 2 |
| 103 | T2_T3_P2__bd_pd1_sigL2 | 756.5 | no | ✓ | ✗ | 1.84e+12 | 3 |
| 104 | T2_T3_P2__bd_pd1_sigR3 | 756.5 | no | ✗ | ✗ | 1.46e+11 | 1 |
| 105 | T1_P2_P3__bd_sigL1 | 756.5 | no | ✓ | ✗ | Inf | 5 |
| 106 | T1_P2_P3__bd_sigL3 | 756.5 | no | ✗ | ✗ | Inf | 2 |
| 107 | T1_P2_P3__bd_sigR2 | 756.5 | no | ✓ | ✗ | 1.17e+06 | 6 |
| 108 | T1_P2_P3__bd_sigR1 | 756.5 | no | ✗ | ✗ | 4.10e+06 | 2 |
| 109 | T1_P2_P3__bd_sigL2 | 756.5 | no | ✗ | ✗ | Inf | 1 |
| 110 | T1_P2_P3__bd_sigR3 | 756.6 | no | ✗ | ✗ | Inf | 1 |
| 111 | T2_T3_P2__bd_sigR2 | 757.7 | no | ✗ | ✗ | Inf | 1 |
| 112 | T1_P2_P3__bd_pd1_sigL2 | 758.0 | no | ✓ | ✗ | Inf | 7 |
| 113 | T1_P2_P3__bd_pd1_sigR1 | 758.0 | no | ✓ | ✗ | Inf | 5 |
| 114 | T1_P2_P3__bd_pd1_sigR2 | 758.0 | no | ✗ | ✗ | Inf | 1 |
| 115 | T1_P2_P3__bd_pd1_sigR3 | 758.0 | no | ✓ | ✗ | Inf | 6 |
| 116 | T1_P2_P3__bd_pd1_sigL1 | 758.0 | no | ✗ | ✗ | Inf | 1 |
| 117 | T2_P3__bd_pd1 | 758.0 | yes ✓ | ✓ | ✓ | 8.89e+03 | 14 |
| 118 | T3_P2_P3 | 758.4 | no | ✓ | ✗ | Inf | 7 |
| 119 | T2_T3_P2__bd_sigR3 | 759.0 | no | ✗ | ✗ | Inf | 1 |
| 120 | T2_T3_P2__bd_pd1 | 759.2 | no | ✓ | ✗ | Inf | 6 |
| 121 | T2_T3_P2__bd_sigL2 | 759.2 | no | ✗ | ✓ | 5.81e+04 | 1 |
| 122 | T1_P2_P3__bd_pd1_sigL3 | 759.3 | no | ✗ | ✓ | 4.27e+05 | 2 |
| 123 | T3_P2_P3__bd_pd1 | 759.7 | no | ✓ | ✗ | Inf | 12 |
| 124 | T1_P2__bd_pd1 | 760.1 | yes ✓ | ✓ | ✓ | 5.69e+04 | 22 |
| 125 | T2_T3_P1__bd_pd1_sigL3 | 760.1 | no | ✗ | ✗ | Inf | 1 |
| 126 | T2_T3_P2__bd_sigR1 | 761.4 | no | ✗ | ✗ | Inf | 1 |
| 127 | T3_P3__bd_pd1_sigL1 | 761.7 | yes ✓ | ✓ | ✓ | 1.26e+04 | 10 |
| 128 | T3_P3__bd_pd1_sigR1 | 761.7 | yes ✓ | ✓ | ✓ | 1.20e+04 | 12 |
| 129 | T3_P3__bd_pd1_sigL2 | 761.7 | yes ✓ | ✓ | ✓ | 1.13e+04 | 9 |
| 130 | T3_P3__bd_pd1_sigR2 | 761.7 | yes ✓ | ✓ | ✓ | 1.24e+04 | 11 |
| 131 | T1_P2_P3 | 762.9 | no | ✗ | ✗ | Inf | 1 |
| 132 | T2_T3_P2__bd_sigL3 | 762.9 | no | ✗ | ✗ | Inf | 1 |
| 133 | T1_P2_P3__bd_pd1 | 763.4 | no | ✓ | ✗ | Inf | 21 |
| 134 | T2_T3_P2 | 764.2 | no | ✗ | ✗ | Inf | 1 |
| 135 | T2_T3_P2__bd_sigL1 | 764.4 | no | ✗ | ✗ | Inf | 1 |
| 136 | T2_P2__bd_pd1 | 767.6 | no | ✓ | ✗ | Inf | 23 |
| 137 | T3_P2__bd_pd1_sigL2 | 768.7 | yes ✓ | ✓ | ✓ | 4.52e+04 | 5 |
| 138 | T3_P2__bd_pd1_sigR2 | 768.7 | yes ✓ | ✓ | ✓ | 4.59e+04 | 8 |
| 139 | T3_P2__bd_pd1_sigR1 | 768.7 | yes ✓ | ✓ | ✓ | 7.46e+04 | 3 |
| 140 | T3_P2__bd_pd1_sigL1 | 768.9 | yes ✓ | ✓ | ✓ | 1.64e+05 | 8 |
| 141 | T2_P2 | 774.1 | no | ✓ | ✗ | 1.93e+32 | 12 |
| 142 | T1_noP | 774.6 | yes ✓ | ✓ | ✓ | 3.58e+04 | 16 |
| 143 | T3_P2__bd_pd1 | 775.1 | no | ✓ | ✗ | Inf | 9 |
| 144 | T3_P1 | 779.0 | no | ✓ | ✗ | 2.74e+06 | 14 |
| 145 | T2_P2_P3 | 782.2 | no | ✗ | ✗ | 1.63e+12 | 2 |
| 146 | T2_T3_noP | 786.1 | no | ✗ | ✗ | Inf | 1 |
| 147 | T2_noP__bd_pd1 | 800.7 | yes ✓ | ✓ | ✓ | 1.40e+02 | 24 |
| 148 | T3_noP | 802.7 | no | ✗ | ✗ | Inf | 1 |
| 149 | T2_noP | 807.2 | yes ✓ | ✓ | ✓ | 1.40e+02 | 22 |
| 150 | noT_P2_P3 | 868.1 | no | ✗ | ✗ | Inf | 1 |
| 151 | noT_P3 | 873.2 | no | ✗ | ✗ | 7.98e+07 | 2 |
| 152 | noT_P2__bd_pd1 | 881.3 | no | ✗ | ✗ | Inf | 1 |
| 153 | noT_P2 | 887.8 | no | ✗ | ✗ | Inf | 1 |
| 154 | noT_P1 | 891.3 | no | ✗ | ✗ | Inf | 1 |
*(The scan stops at the first well-behaved model; higher-pBIC models may therefore be left unscanned.)*

**M_Ω (L3):** `T2_P1__bd_pd1_sigL1` — **Ω = 744.2**

## L3 supplementary appendices — per-model diagnostics

### T2_T3_P3__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -324.842 | 16.8746 | -1.1694 | 10.2366 |   Inf | 5.8326 | 13.0191 | 0.0000 | 1.6246 | 1.0600 | -2.5071 | 1.0000 | -0.8203 | 0.4081 | -0.4007 | 0.2172 | -0.4259 | -0.8783 | -0.5291 | -0.8075 | 0.2607 | 0.00000000 |
| 2 | -327.000 | 17.4069 | -0.6220 | 10.8093 |   Inf | 5.8521 | 14.8832 | 0.3646 | 1.7274 | 1.0136 | -2.4111 | 1.0000 | -0.7676 | 0.5080 | -0.3908 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | 23661.80266889 |
| 3 | -327.000 | 17.4069 | -0.6220 | 10.8093 |   Inf | 5.8521 | 14.8832 | 0.3646 | 1.7274 | 1.0136 | -2.4111 | 1.0000 | -0.7676 | 0.5080 | -0.3908 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | 23661.80266958 |
| 4 | -327.000 | 17.4069 | -0.6220 | 10.8093 |   Inf | 5.8521 | 14.8832 | 0.3646 | 1.7274 | 1.0136 | -2.4111 | 1.0000 | -0.7676 | 0.5080 | -0.3908 | 0.1658 | -0.4316 | -0.8867 | -0.6191 | -0.7454 | 0.2470 | 23661.80266878 |
| 5 | -328.424 | 17.6133 | 6.0147 | 10.3732 | 134082822.0265 | 6.3448 | 1.7701 | 0.7248 | 1.9291 |   Inf | -2.0261 | 1.0000 | -0.9209 | -0.3559 | 0.1587 | -0.0382 | -0.3227 | -0.9457 | 0.3878 | -0.8770 | 0.2835 | 23663.16714447 |
| 6 | -328.424 | 17.6133 | 6.0147 | 10.3732 |   Inf | 6.3448 | 1.7701 | 0.7248 | 1.9291 | 8624270.7184 | -2.0261 | 1.0000 | -0.9209 | -0.3559 | 0.1587 | -0.0382 | -0.3227 | -0.9457 | 0.3878 | -0.8770 | 0.2835 | 23663.16714475 |
| 7 | -335.430 | 18.8295 | -2.5261 | 8.7658 | 5.0034 |   Inf | 8.6370 | 0.4482 | 1.1169 | 1.0906 | -3.1852 | 1.0000 | -0.7251 | 0.3334 | -0.6026 | 0.3926 | -0.5188 | -0.7594 | -0.5658 | -0.7872 | 0.2453 | 23662.31489025 |
| 8 | -337.453 | 18.0264 | 12.9503 | 5.2163 | 108872.5722 |   Inf | 39.3308 | 0.3468 | 1.0634 | 0.5723 | -0.9188 | 1.0000 | -0.1772 | 0.9516 | -0.2512 | -0.0852 | -0.2691 | -0.9593 | -0.9805 | -0.1486 | 0.1287 | 23661.66695976 |
| 9 | -339.695 | 15.2817 | 3.2161 | 11.0215 | 6.5218 | 5.8827 |   Inf | 0.8602 | 1.7164 | 6.4878 | -4.0360 | 1.0000 | -0.7594 | -0.5956 | 0.2620 | -0.0420 | -0.3570 | -0.9332 | 0.6493 | -0.7196 | 0.2461 | 23663.38370239 |
| 10 | -339.695 | 15.2817 | 3.2161 | 11.0215 | 6.5218 | 5.8827 |   Inf | 0.8602 | 1.7164 | 6.4878 | -4.0360 | 1.0000 | -0.7594 | -0.5956 | 0.2620 | -0.0420 | -0.3570 | -0.9332 | 0.6493 | -0.7196 | 0.2461 | 23663.38370250 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=2.1587, max_pdist=23661.8027 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.238e+09 | 5.545e+08 |
| 2 | 1.932e+08 | 8.550e+05 |
| 3 | 1.436e+06 | 7.713e+02 |
| 4 | 1.632e+05 | 4.706e+02 |
| 5 | 7.713e+02 | 2.176e+02 |
| 6 | 4.705e+02 | 5.671e+01 |
| 7 | 2.173e+02 | 7.328e+00 |
| 8 | 5.676e+01 | -4.200e-01 |
| 9 | 7.323e+00 | -4.934e+04 |
| 10 | -3.867e+06 | -2.019e+05 |
| 11 | -2.000e+07 | -7.760e+05 |
| 12 | -7.639e+08 | -1.292e+08 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 5, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000086 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000137 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000047 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000741 |
| 6 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.0136 |   Inf | 1.7274 | 14.8832 | 0.3646 | 5.8521 | -2.4111 | 1.0000 | 0.6191 | 0.7454 | -0.2470 | -0.7676 | 0.5080 | -0.3908 | -0.1658 | 0.4316 | 0.8867 | 10.63756323 |
| 7 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.0136 |   Inf | 1.7274 | 14.8832 | 0.3646 | 5.8521 | -2.4111 | 1.0000 | 0.6191 | 0.7454 | -0.2470 | -0.7676 | 0.5080 | -0.3908 | -0.1658 | 0.4316 | 0.8867 | 10.63756337 |
| 8 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.0136 |   Inf | 1.7274 | 14.8832 | 0.3646 | 5.8521 | -2.4111 | 1.0000 | 0.6191 | 0.7454 | -0.2470 | -0.7676 | 0.5080 | -0.3908 | -0.1658 | 0.4316 | 0.8867 | 10.63756309 |
| 9 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.0136 |   Inf | 1.7274 | 14.8832 | 0.3646 | 5.8521 | -2.4111 | 1.0000 | 0.6191 | 0.7454 | -0.2470 | -0.7676 | 0.5080 | -0.3908 | -0.1658 | 0.4316 | 0.8867 | 10.63756339 |
| 10 | -328.091 | 19.6962 | 17.6557 | 7.6877 | 0.5533 |   Inf | 2.4797 | 6.5423 | 0.0001 | 5.2463 | -2.4613 | 1.0000 | 0.9917 | 0.0875 | -0.0938 | -0.1149 | 0.9311 | -0.3463 | 0.0570 | 0.3543 | 0.9334 | 8721.87946307 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.584e+04 | 1.582e+04 |
| 2 | 3.445e+03 | 3.441e+03 |
| 3 | 9.177e+02 | 9.159e+02 |
| 4 | 6.209e+02 | 6.203e+02 |
| 5 | 5.941e+01 | 5.938e+01 |
| 6 | 4.262e+01 | 4.259e+01 |
| 7 | 2.835e+01 | 2.840e+01 |
| 8 | 6.003e+00 | 5.990e+00 |
| 9 | 2.567e+00 | 2.198e+00 |
| 10 | 2.891e-01 | 2.912e-01 |
| 11 | 1.931e-01 | 2.472e-01 |
| 12 | -6.748e-04 | 3.161e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 500549.5517, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 2.0168 | 9.9783 | 0.3590 | 5.7891 | 0.6781 |   Inf | -2.4569 | 1.0000 | 0.0499 | 0.3414 | 0.9386 | -0.9130 | -0.3654 | 0.1814 | 0.4049 | -0.8660 | 0.2935 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 2.0167 | 9.9783 | 0.3590 | 5.7891 | 0.6781 |   Inf | -2.4569 | 1.0000 | 0.0499 | 0.3414 | 0.9386 | -0.9130 | -0.3654 | 0.1814 | 0.4049 | -0.8660 | 0.2935 | 0.00000073 |
| 3 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756291 |
| 4 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756433 |
| 5 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756333 |
| 6 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756404 |
| 7 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756345 |
| 8 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756202 |
| 9 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.7274 | 14.8832 | 0.3646 | 5.8521 | 1.0136 |   Inf | -2.4111 | 1.0000 | -0.1658 | 0.4316 | 0.8867 | -0.6191 | -0.7454 | 0.2470 | 0.7676 | -0.5080 | 0.3908 | 10.63756239 |
| 10 | -328.267 | 17.6551 | -0.5969 | 10.1474 | 1.6357 |   Inf | 0.3874 | 6.3123 | 1.1067 | 390235.5391 | -2.0492 | 1.0000 | -0.1860 | 0.4230 | 0.8868 | -0.6290 | -0.7447 | 0.2232 | 0.7548 | -0.5163 | 0.4046 | 10.61688546 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.4531, max_pdist=10.6376 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.133e+04 | 1.132e+04 |
| 2 | 2.656e+03 | 2.660e+03 |
| 3 | 8.712e+02 | 8.625e+02 |
| 4 | 6.223e+02 | 6.201e+02 |
| 5 | 5.939e+01 | 5.934e+01 |
| 6 | 3.787e+01 | 4.048e+01 |
| 7 | 2.768e+01 | 2.801e+01 |
| 8 | 5.930e+00 | 5.982e+00 |
| 9 | 2.616e+00 | 2.195e+00 |
| 10 | 2.821e-01 | 2.916e-01 |
| 11 | 1.843e-01 | 2.472e-01 |
| 12 | -1.246e-01 | 3.163e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 357755.0931, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 9.9783 | 5.7891 |   Inf | 0.6781 | 2.0168 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | -0.0499 | -0.3414 | -0.9386 | 0.00000000 |
| 2 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 9.9783 | 5.7891 |   Inf | 0.6781 | 2.0168 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | -0.0499 | -0.3414 | -0.9386 | 0.00000029 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 9.9783 | 5.7891 |   Inf | 0.6781 | 2.0168 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | -0.0499 | -0.3414 | -0.9386 | 0.00000078 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 9.9783 | 5.7891 |   Inf | 0.6781 | 2.0168 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | -0.0499 | -0.3414 | -0.9386 | 0.00000051 |
| 5 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 9.9783 | 5.7891 |   Inf | 0.6781 | 2.0168 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | -0.0499 | -0.3414 | -0.9386 | 0.00000028 |
| 6 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.3590 | 9.9783 | 5.7891 |   Inf | 0.6781 | 2.0168 | -2.4569 | 1.0000 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | -0.0499 | -0.3414 | -0.9386 | 0.00000015 |
| 7 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 0.3646 | 14.8832 | 5.8521 |   Inf | 1.0136 | 1.7274 | -2.4111 | 1.0000 | 0.7676 | -0.5080 | 0.3908 | -0.6191 | -0.7454 | 0.2470 | 0.1658 | -0.4316 | -0.8867 | 10.63756368 |
| 8 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 0.3646 | 14.8832 | 5.8521 |   Inf | 1.0136 | 1.7274 | -2.4111 | 1.0000 | 0.7676 | -0.5080 | 0.3908 | -0.6191 | -0.7454 | 0.2470 | 0.1658 | -0.4316 | -0.8867 | 10.63756365 |
| 9 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 0.3646 | 14.8832 | 5.8521 |   Inf | 1.0136 | 1.7274 | -2.4111 | 1.0000 | 0.7676 | -0.5080 | 0.3908 | -0.6191 | -0.7454 | 0.2470 | 0.1658 | -0.4316 | -0.8867 | 10.63756351 |
| 10 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 0.3646 | 14.8832 | 5.8521 |   Inf | 1.0136 | 1.7274 | -2.4111 | 1.0000 | 0.7676 | -0.5080 | 0.3908 | -0.6191 | -0.7454 | 0.2470 | 0.1658 | -0.4316 | -0.8867 | 10.63756301 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.776e+03 | 3.725e+03 |
| 2 | 7.023e+02 | 7.035e+02 |
| 3 | 6.083e+02 | 6.084e+02 |
| 4 | 2.048e+02 | 2.172e+02 |
| 5 | 5.581e+01 | 5.658e+01 |
| 6 | 2.777e+01 | 2.789e+01 |
| 7 | 1.021e+01 | 1.180e+01 |
| 8 | 5.308e+00 | 5.582e+00 |
| 9 | 1.118e+00 | 1.964e+00 |
| 10 | 2.739e-01 | 2.888e-01 |
| 11 | 2.008e-01 | 2.453e-01 |
| 12 | -3.420e+00 | 3.062e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 121649.4396, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 5.7891 | 0.3590 | 9.9783 | 2.0168 |   Inf | 0.6781 | -2.4569 | 1.0000 | -0.0499 | -0.3414 | -0.9386 | 0.4049 | -0.8660 | 0.2935 | -0.9130 | -0.3654 | 0.1814 | 0.00000000 |
| 2 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 6.3962 | 0.6359 |   Inf | 1.7106 | 189408.1132 | 1.0414 | -2.0837 | 1.0000 | 0.0854 | -0.3775 | -0.9221 | 0.7495 | -0.5854 | 0.3091 | -0.6564 | -0.7175 | 0.2330 | 10.63084392 |
| 3 | -328.667 | 16.7662 | 11.6785 | 8.8490 | 6.6581 | 0.3216 |   Inf | 1.9442 | 411345.0950 | 0.6692 | -1.8899 | 1.0000 | -0.0505 | -0.2927 | -0.9549 | 0.3046 | -0.9151 | 0.2644 | -0.9512 | -0.2775 | 0.1353 | 2.47265932 |
| 4 | -335.430 | 18.8295 | -2.5261 | 8.7658 |   Inf | 0.4482 | 8.6370 | 1.1169 | 5.0034 | 1.0906 | -3.1852 | 1.0000 | 0.3926 | -0.5188 | -0.7594 | 0.7251 | -0.3334 | 0.6026 | -0.5658 | -0.7872 | 0.2453 | 12.81688342 |
| 5 | -335.430 | 18.8295 | -2.5261 | 8.7658 |   Inf | 0.4482 | 8.6370 | 1.1169 | 5.0034 | 1.0906 | -3.1852 | 1.0000 | 0.3926 | -0.5188 | -0.7594 | 0.7251 | -0.3334 | 0.6026 | -0.5658 | -0.7872 | 0.2453 | 12.81688352 |
| 6 | -335.430 | 18.8295 | -2.5261 | 8.7658 |   Inf | 0.4482 | 8.6370 | 1.1169 | 5.0034 | 1.0906 | -3.1852 | 1.0000 | 0.3926 | -0.5188 | -0.7594 | 0.7251 | -0.3334 | 0.6026 | -0.5658 | -0.7872 | 0.2453 | 12.81688334 |
| 7 | -337.453 | 18.0264 | 12.9503 | 5.2163 |   Inf | 0.3468 | 39.3309 | 1.0634 | 1569211.0921 | 0.5723 | -0.9188 | 1.0000 | -0.0852 | -0.2691 | -0.9593 | 0.1772 | -0.9516 | 0.2512 | -0.9805 | -0.1486 | 0.1287 | 6.17327795 |
| 8 | -337.453 | 18.0264 | 12.9503 | 5.2163 |   Inf | 0.3468 | 39.3302 | 1.0634 | 89466.5136 | 0.5723 | -0.9188 | 1.0000 | -0.0852 | -0.2691 | -0.9593 | 0.1772 | -0.9516 | 0.2512 | -0.9805 | -0.1486 | 0.1287 | 6.17327836 |
| 9 | -339.695 | 15.2817 | 3.2162 | 11.0215 | 5.8827 |   Inf | 6.5218 | 1.7164 | 6.4878 | 0.8602 | -4.0360 | 1.0000 | -0.0420 | -0.3570 | -0.9332 | 0.6493 | -0.7196 | 0.2461 | -0.7594 | -0.5956 | 0.2620 | 7.44178744 |
| 10 | -339.695 | 15.2817 | 3.2162 | 11.0215 | 5.8827 |   Inf | 6.5218 | 1.7164 | 6.4878 | 0.8602 | -4.0360 | 1.0000 | -0.0420 | -0.3570 | -0.9332 | 0.6493 | -0.7196 | 0.2461 | -0.7594 | -0.5956 | 0.2620 | 7.44178688 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=2.1196, max_pdist=10.6308 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.123e+04 | 1.117e+04 |
| 2 | 2.746e+03 | 2.745e+03 |
| 3 | 6.832e+02 | 6.858e+02 |
| 4 | 4.684e+02 | 4.817e+02 |
| 5 | 5.931e+01 | 5.927e+01 |
| 6 | 4.016e+01 | 4.075e+01 |
| 7 | 2.817e+01 | 2.834e+01 |
| 8 | 5.975e+00 | 5.989e+00 |
| 9 | 2.490e+00 | 2.189e+00 |
| 10 | 2.915e-01 | 2.914e-01 |
| 11 | 2.444e-01 | 2.471e-01 |
| 12 | 1.878e-02 | 3.252e-02 |

numDeriv::hessian (operative): cond = 598176.0547, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 343559.3841, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 1.7106 | 4728369940907206276690726617088.0000 |   Inf | 6.3962 | 0.6359 | 1.0414 | -2.0837 | 1.0000 | -0.0854 | 0.3775 | 0.9221 | -0.7495 | 0.5854 | -0.3091 | -0.6564 | -0.7175 | 0.2330 | 0.00000000 |
| 2 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 1.7106 | 483314.3882 |   Inf | 6.3962 | 0.6359 | 1.0414 | -2.0837 | 1.0000 | -0.0854 | 0.3775 | 0.9221 | -0.7495 | 0.5854 | -0.3091 | -0.6564 | -0.7175 | 0.2330 | 0.00000873 |
| 3 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 1.7106 | 228166.5182 |   Inf | 6.3962 | 0.6359 | 1.0414 | -2.0837 | 1.0000 | -0.0854 | 0.3775 | 0.9221 | -0.7495 | 0.5854 | -0.3091 | -0.6565 | -0.7175 | 0.2330 | 0.00002332 |
| 4 | -328.206 | 17.7355 | -0.4508 | 11.0301 | 1.7106 | 160327.0129 |   Inf | 6.3962 | 0.6359 | 1.0414 | -2.0837 | 1.0000 | -0.0854 | 0.3775 | 0.9221 | -0.7495 | 0.5854 | -0.3091 | -0.6564 | -0.7175 | 0.2330 | 0.00000628 |
| 5 | -328.267 | 17.6551 | -0.5969 | 10.1475 | 1.6357 |   Inf | 196629.0541 | 6.3123 | 0.3874 | 1.1067 | -2.0492 | 1.0000 | -0.1860 | 0.4230 | 0.8868 | -0.7548 | 0.5163 | -0.4046 | -0.6290 | -0.7447 | 0.2232 | 1.36315549 |
| 6 | -328.267 | 17.6551 | -0.5969 | 10.1475 | 1.6357 | 808970.1203 |   Inf | 6.3123 | 0.3874 | 1.1067 | -2.0492 | 1.0000 | -0.1860 | 0.4230 | 0.8868 | -0.7548 | 0.5163 | -0.4046 | -0.6290 | -0.7447 | 0.2232 | 1.36315590 |
| 7 | -335.430 | 18.8295 | -2.5261 | 8.7658 | 1.1169 | 5.0034 | 8.6370 |   Inf | 0.4482 | 1.0906 | -3.1852 | 1.0000 | -0.3926 | 0.5188 | 0.7594 | -0.7251 | 0.3334 | -0.6026 | -0.5658 | -0.7872 | 0.2453 | 3.57180035 |
| 8 | -336.170 | 16.1257 | 13.7370 | 5.4093 | 1.0659 | 363623208150247.2500 |   Inf | 324.2045 | 0.0001 | 0.6576 | -0.9174 | 1.0000 | 0.0934 | 0.2574 | 0.9618 | -0.2630 | 0.9381 | -0.2255 | -0.9603 | -0.2318 | 0.1553 | 15586.06629456 |
| 9 | -337.453 | 18.0264 | 12.9503 | 5.2163 | 1.0634 | 50364157795344281449483512712148287488.0000 | 39.3308 |   Inf | 0.3468 | 0.5723 | -0.9188 | 1.0000 | 0.0852 | 0.2691 | 0.9593 | -0.1772 | 0.9516 | -0.2512 | -0.9805 | -0.1486 | 0.1287 | 14.77386616 |
| 10 | -337.453 | 18.0264 | 12.9503 | 5.2163 | 1.0634 | 631718.9907 | 39.3310 |   Inf | 0.3468 | 0.5723 | -0.9188 | 1.0000 | 0.0852 | 0.2691 | 0.9593 | -0.1772 | 0.9516 | -0.2512 | -0.9805 | -0.1486 | 0.1287 | 14.77386980 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.696e+03 | 2.704e+03 |
| 2 | 6.104e+02 | 6.103e+02 |
| 3 | 3.857e+02 | 3.830e+02 |
| 4 | 2.038e+02 | 2.043e+02 |
| 5 | 7.769e+01 | 7.768e+01 |
| 6 | 1.426e+01 | 1.409e+01 |
| 7 | 5.707e+00 | 3.874e+00 |
| 8 | 3.127e+00 | 2.814e+00 |
| 9 | 1.019e+00 | 9.881e-01 |
| 10 | 4.545e-01 | 2.656e-01 |
| 11 | 2.377e-01 | 2.425e-01 |
| 12 | -1.098e-15 | 3.509e-14 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 77074422115811776.0000, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_pd1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -325.042 | 15.5043 | 13.5798 | 8.3839 | 0.6459 | 2.0852 | 0.0006 | 9.2012 | 5.6872 | 214314.6950 | -2.4619 | 1.0000 | 0.9408 | 0.2990 | -0.1597 | 0.0498 | 0.3444 | 0.9375 | 0.3353 | -0.8900 | 0.3091 | 0.00000000 |
| 2 | -325.189 | 14.7263 | 12.5202 | 8.7766 | 0.6437 | 2.0622 | 0.0003 | 9.7808 | 5.6879 | 99.3006 | -2.4850 | 1.0000 | 0.9216 | 0.3480 | -0.1720 | 0.0473 | 0.3391 | 0.9396 | 0.3853 | -0.8740 | 0.2960 | 2153.77713756 |
| 3 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 | 2.0168 | 0.3590 | 9.9783 | 5.7891 | 74362586.8712 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91292474 |
| 4 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 | 2.0168 | 0.3590 | 9.9783 | 5.7891 | 49688898.6358 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91292520 |
| 5 | -326.547 | 15.5922 | 9.7494 | 9.5906 | 0.6781 | 2.0167 | 0.3590 | 9.9783 | 5.7891 | 455843.5591 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91288380 |
| 6 | -326.547 | 15.5922 | 9.7494 | 9.5906 | 0.6781 | 2.0167 | 0.3590 | 9.9783 | 5.7891 | 293793.6636 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91291075 |
| 7 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 | 2.0168 | 0.3590 | 9.9783 | 5.7891 | 261659.4570 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91292414 |
| 8 | -326.547 | 15.5922 | 9.7495 | 9.5905 | 0.6781 | 2.0167 | 0.3590 | 9.9783 | 5.7891 | 217761.9178 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91289497 |
| 9 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 | 2.0167 | 0.3590 | 9.9783 | 5.7891 | 163673.5663 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | 0.0499 | 0.3414 | 0.9386 | 0.4049 | -0.8660 | 0.2935 | 1570.91285123 |
| 10 | -327.000 | 17.4069 | -0.6220 | 10.8093 | 1.0136 | 1.7274 | 0.3646 | 14.8832 | 5.8521 | 238052.2699 | -2.4111 | 1.0000 | 0.6191 | 0.7454 | -0.2470 | -0.1658 | 0.4316 | 0.8867 | 0.7676 | -0.5080 | 0.3908 | 1571.01800409 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.5050, max_pdist=2153.7771 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_pd1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.734e+06 | 7.905e+05 |
| 2 | 5.997e+04 | 7.144e+02 |
| 3 | 1.227e+03 | 5.686e+02 |
| 4 | 7.043e+02 | 2.084e+02 |
| 5 | 5.005e+02 | 5.730e+01 |
| 6 | 1.700e+02 | 7.870e+00 |
| 7 | 5.617e+01 | 5.227e+00 |
| 8 | 6.652e+00 | 1.403e-01 |
| 9 | 2.663e-08 | 2.350e-05 |
| 10 | -1.640e+03 | -5.693e+01 |
| 11 | -4.370e+03 | -2.688e+02 |
| 12 | -9.849e+03 | -6.082e+02 |
| 13 | -6.906e+04 | -2.058e+03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 4, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.497 | 15.3607 | 9.2392 | 10.1372 |   Inf | 5.3129 | 9.5937 | 0.3420 | 2.0301 | 0.6714 | -2.8920 | 0.9426 | -0.4331 | 0.8544 | -0.2869 | -0.0536 | -0.3422 | -0.9381 | -0.8997 | -0.3910 | 0.1940 | 0.00000000 |
| 2 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 5.1528 | 13.5961 | 0.3264 | 1.6725 | 0.9336 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.1476 | -0.4280 | -0.8917 | -0.6101 | -0.7489 | 0.2585 | 10.28446443 |
| 3 | -326.709 | 17.4666 | -0.7208 | 11.2698 |   Inf | 5.1528 | 13.5961 | 0.3264 | 1.6725 | 0.9336 | -3.2498 | 0.8929 | -0.7784 | 0.5059 | -0.3717 | 0.1476 | -0.4280 | -0.8917 | -0.6101 | -0.7489 | 0.2585 | 10.28446439 |
| 4 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 164887.2158 | 4.8275 |   Inf | 0.4410 | 1.6460 | 0.8906 | -3.7263 | 0.8236 | -0.7765 | 0.5521 | -0.3037 | 0.0818 | -0.3896 | -0.9173 | -0.6248 | -0.7371 | 0.2574 | 10.56204111 |
| 5 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 150485.4510 | 4.8275 |   Inf | 0.4410 | 1.6460 | 0.8906 | -3.7263 | 0.8236 | -0.7765 | 0.5521 | -0.3037 | 0.0818 | -0.3896 | -0.9173 | -0.6248 | -0.7371 | 0.2574 | 10.56203679 |
| 6 | -330.818 | 25.7410 | -5.4847 | 13.1330 |   Inf | 4.7567 | 6.5623 | 0.0417 | 1.4345 | 1.0280 | -5.0091 | 0.8598 | 0.8455 | -0.5309 | 0.0568 | -0.1287 | -0.3060 | -0.9433 | -0.5182 | -0.7903 | 0.3270 | 28.01124944 |
| 7 | -333.657 | 28.1048 | 11.0955 | 15.3314 | 0.6397 | 1.9859 | 2.3031 | 0.5131 | 3.2742 |   Inf | -8.4634 | 0.7413 | -0.9532 | 0.2953 | -0.0653 | -0.0591 | -0.3936 | -0.9174 | -0.2966 | -0.8705 | 0.3927 | 15.20013330 |
| 8 | -335.414 | 17.3896 | 14.5811 | 8.5934 | 12926.7628 |   Inf | 36347452393534909317120.0000 | 0.0000 | 1.5306 | 0.9007 | -3.2117 | 0.7363 | -0.2735 | 0.9415 | -0.1970 | -0.1435 | -0.2424 | -0.9595 | -0.9511 | -0.2342 | 0.2014 | 1458609.86033723 |
| 9 | -335.497 | 22.0569 | 15.8499 | 19.7874 | 206.6898 | 18355335.1144 |   Inf | 0.0000 | 3.1874 | 1.2562 | -7.8546 | 0.7058 | -0.2638 | 0.9623 | -0.0660 | -0.3184 | -0.1515 | -0.9358 | -0.9105 | -0.2259 | 0.3464 | 2866100.81804494 |
| 10 | -336.008 | 34.2215 | 15.1649 | 33.4345 | 10.4555 | 3050645.1067 |   Inf | 0.0001 | 4.4172 | 1.5137 | -19.2062 | 0.7018 | -0.0920 | 0.9932 | 0.0714 | -0.4826 | 0.0182 | -0.8756 | -0.8710 | -0.1151 | 0.4777 | 11356.38710610 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.2120, max_pdist=10.2845 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.935e+03 | 3.901e+03 |
| 2 | 1.006e+03 | 1.003e+03 |
| 3 | 6.222e+02 | 6.218e+02 |
| 4 | 7.781e+01 | 7.962e+01 |
| 5 | 6.220e+01 | 6.262e+01 |
| 6 | 2.871e+01 | 2.981e+01 |
| 7 | 1.071e+01 | 1.865e+01 |
| 8 | 4.607e+00 | 5.326e+00 |
| 9 | 2.501e+00 | 2.259e+00 |
| 10 | 2.664e-01 | 2.826e-01 |
| 11 | 1.575e-01 | 2.735e-01 |
| 12 | 7.894e-02 | 9.097e-02 |
| 13 | -9.269e-01 | 3.072e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 127014.7150, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 2.0301 | 0.6714 |   Inf | 5.3129 | 9.5937 | 0.3420 | -2.8920 | 0.9426 | 0.0536 | 0.3422 | 0.9381 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.00000000 |
| 2 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 1.6725 | 0.9336 |   Inf | 5.1528 | 13.5961 | 0.3264 | -3.2498 | 0.8929 | -0.1476 | 0.4280 | 0.8917 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | 10.28446471 |
| 3 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 |   Inf | 4.8275 | 57433033275330.0000 | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56204045 |
| 4 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 398826574.4687 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56204043 |
| 5 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 512954.2874 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56203834 |
| 6 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 453964.2403 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56204232 |
| 7 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 177661.6435 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56203851 |
| 8 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 150636.5778 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56204106 |
| 9 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 127178.9949 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56203994 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.8906 | 43345.2038 | 4.8275 |   Inf | 0.4411 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | 10.56203973 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.9256, max_pdist=10.5620 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 9.931e+03 | 9.906e+03 |
| 2 | 1.088e+03 | 1.085e+03 |
| 3 | 6.425e+02 | 6.421e+02 |
| 4 | 1.644e+02 | 1.728e+02 |
| 5 | 6.148e+01 | 6.270e+01 |
| 6 | 3.899e+01 | 3.900e+01 |
| 7 | 2.376e+01 | 2.399e+01 |
| 8 | 5.400e+00 | 5.334e+00 |
| 9 | 1.758e+00 | 2.331e+00 |
| 10 | 2.985e-01 | 2.865e-01 |
| 11 | 2.548e-01 | 2.740e-01 |
| 12 | 8.192e-02 | 9.122e-02 |
| 13 | -2.434e-01 | 3.441e-02 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 287910.5688, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.547 | 15.5922 | 9.7495 | 9.5906 | 0.6781 |   Inf | 2.0168 | 9.9783 | 0.3590 | 5.7891 | -2.4569 | 1.0000 | 0.9130 | 0.3654 | -0.1814 | -0.4049 | 0.8660 | -0.2935 | 0.0499 | 0.3414 | 0.9386 | 0.00000000 |
| 2 | -326.558 | 90.8828 | 32.2292 | 13.3469 | 7.2345 | 3.8498 | 2.4542 |   Inf | 0.0004 | 15.8208 | -61.2181 | 0.7064 | 0.8371 | 0.5465 | 0.0221 | 0.4338 | -0.6387 | -0.6355 | 0.3332 | -0.5416 | 0.7718 | 2631.93101632 |
| 3 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 |   Inf | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 10.83605086 |
| 4 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 |   Inf | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 10.83605104 |
| 5 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 |   Inf | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 10.83605097 |
| 6 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 |   Inf | 1.6460 | 457105.7559 | 0.4411 | 4.8275 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | -0.0818 | 0.3896 | 0.9173 | 11.13586403 |
| 7 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 |   Inf | 1.6460 | 1186765105856.9019 | 0.4411 | 4.8275 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | -0.0818 | 0.3896 | 0.9173 | 11.13586438 |
| 8 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.8906 | 226655.8400 | 1.6460 |   Inf | 0.4411 | 4.8275 | -3.7263 | 0.8236 | 0.6248 | 0.7371 | -0.2574 | -0.7765 | 0.5521 | -0.3037 | -0.0818 | 0.3896 | 0.9173 | 11.13586460 |
| 9 | -328.500 | 15.8200 | 10.3538 | 10.6916 | 0.6822 | 290181.2603 | 2.0637 |   Inf | 0.2502 | 5.1020 | -3.0227 | 0.8574 | 0.9167 | 0.3602 | -0.1729 | -0.3938 | 0.8875 | -0.2392 | 0.0673 | 0.2873 | 0.9555 | 1.85906157 |
| 10 | -329.745 | 32.1712 | 16.4080 | 37.0252 | 0.0031 | 4.9731 |   Inf | 8303.2147 | 0.0001 | 1.3586 | -18.4309 | 0.7110 | 0.2515 | -0.9669 | -0.0425 | 0.4609 | 0.0811 | 0.8838 | -0.8511 | -0.2418 | 0.4660 | 7080.88657898 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.1618, max_pdist=2631.9310 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.010e+04 | 9.681e+03 |
| 2 | 6.554e+02 | 6.562e+02 |
| 3 | 5.051e+02 | 5.055e+02 |
| 4 | 6.357e+01 | 6.198e+01 |
| 5 | 2.824e+01 | 2.993e+01 |
| 6 | 1.264e+01 | 7.120e+00 |
| 7 | 6.293e+00 | 6.044e+00 |
| 8 | 1.019e+00 | 9.402e-01 |
| 9 | 3.264e-01 | 7.209e-01 |
| 10 | 2.036e-01 | 2.602e-01 |
| 11 | -2.251e-12 | 2.087e-01 |
| 12 | -2.252e+01 | 3.999e-02 |
| 13 | -8.580e+01 | 1.466e-10 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 66045106492090.5078, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -329.948 | 28.1515 | 2.4500 | 122.2235 |   Inf | 20.5504 | 1.7992 | 3.5370 | 23.9253 | 0.2798 | -4.0074 | 1.0000 | -0.4024 | -0.9083 | -0.1143 | 0.0421 | 0.1063 | -0.9934 | 0.9145 | -0.4046 | -0.0045 | 0.00000000 |
| 2 | -338.975 | 27.8232 | 1.6652 | 137.2118 | 684868.6103 | 15.9109 | 1.7142 | 4.9905 |   Inf | 0.2426 | -3.6917 | 1.0000 | -0.4001 | -0.8895 | -0.2209 | 0.0965 | 0.1988 | -0.9753 | 0.9114 | -0.4115 | 0.0063 | 15.02692340 |
| 3 | -342.990 | -1.4792 | -61.7227 | 341.9996 | 7.6626 | 11.3058 | 635013.3146 | 8.1000 |   Inf | 0.6089 | -1.8171 | 1.0000 | -0.2972 | -0.8984 | -0.3233 | 0.1206 | 0.3006 | -0.9461 | -0.9472 | 0.3202 | -0.0190 | 230.89098080 |
| 4 | -343.103 | 23.5373 | -4.8017 | 143.5796 | 10.8723 | 108320.5805 |   Inf | 17.5737 | 35.0291 | 0.9284 | -2.0066 | 1.0000 | -0.0380 | -0.8802 | -0.4731 | 0.0492 | 0.4712 | -0.8806 | -0.9981 | 0.0567 | -0.0254 | 23.34210439 |
| 5 | -343.469 | 23.5979 | -12.1697 | 143.5754 | 13.7056 | 201822.2196 | 205396325.9233 |   Inf | 29.7816 | 1.0984 | -2.2633 | 1.0000 | -0.0100 | -0.8199 | -0.5725 | 0.0539 | 0.5712 | -0.8190 | -0.9985 | 0.0391 | -0.0385 | 26.55912669 |
| 6 | -343.660 | -1.0594 | -383.4972 | 508.1247 | 14.2429 |   Inf | 1020448.5331 | 21.7874 | 133.3157 | 0.9821 | -10.1915 | 1.0000 | -0.0084 | -0.7024 | -0.7117 | 0.0470 | 0.7107 | -0.7019 | -0.9989 | 0.0394 | -0.0270 | 546.60620410 |
| 7 | -344.677 | -20.5397 | -899.1317 | 884.7304 | 15.0528 |   Inf | 1318919392318829143702714403506983929357630053881791799024605767041334741483472459578390813694122415249551435869566372118363687548518253796892328513833241183566776560788169391493294296219483373568.0000 | 13692877449806254130338871448273070435701814205754638336.0000 | 132.2349 | 1.3563 | -42.0022 | 1.0000 | 0.0175 | -0.6485 | -0.7611 | 0.0392 | 0.7610 | -0.6475 | -0.9991 | 0.0185 | -0.0388 | 1182.41039453 |
| 8 | -344.709 | 32.1336 | 34.6191 | 81.8305 | 2.9207 | 7095988.3105 | 2901.1122 | 1.1056 |   Inf | 0.0006 | -1.1855 | 1.0000 | -0.9886 | 0.1391 | -0.0569 | -0.0018 | -0.3896 | -0.9210 | 0.1503 | 0.9104 | -0.3854 | 1748.34803472 |
| 9 | -344.949 | 19.5595 | -48.8638 | 171.9996 |   Inf | 16.3861 | 386665.1539 | 6260.8099 | 20.8132 | 0.7601 | -1.7447 | 1.0000 | -0.0637 | -0.8067 | 0.5875 | -0.0137 | -0.5880 | -0.8088 | -0.9979 | 0.0596 | -0.0263 | 72.11248086 |
| 10 | -344.949 | 15.2057 | -104.0348 | 212.1823 | 3072344.7695 | 16.3861 |   Inf | 0.7601 | 20.8133 | 0.3510 | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | -0.0137 | -0.5880 | -0.8088 | -0.0637 | -0.8067 | 0.5875 | 140.03401269 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=13.0421, max_pdist=230.8910 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.848e+04 | 3.432e+04 |
| 2 | 6.171e+03 | 1.555e+03 |
| 3 | 2.977e+03 | 5.885e+02 |
| 4 | 1.220e+03 | 4.048e+02 |
| 5 | 4.112e+02 | 1.656e+02 |
| 6 | 2.777e+02 | 8.535e+01 |
| 7 | 1.032e+02 | 6.799e+01 |
| 8 | 7.315e+00 | 3.565e+01 |
| 9 | 9.576e-01 | 5.744e+00 |
| 10 | 1.617e-01 | 3.600e+00 |
| 11 | -4.702e+00 | 2.759e-01 |
| 12 | -2.181e+03 | 5.837e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 2, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 5879114.8035, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_pd1_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -329.948 | 28.1515 | 2.4500 | 122.2235 | 1.7992 | 3.5370 | 23.9253 | 0.2798 |   Inf | 20.5504 | -4.0074 | 1.0000 | 0.9145 | -0.4046 | -0.0045 | 0.4024 | 0.9083 | 0.1143 | -0.0421 | -0.1063 | 0.9934 | 0.00000000 |
| 2 | -339.834 | 23.3507 | -0.8710 | 132.6574 | 1497988075221060608.0000 | 3.5479 | 32.6981 | 0.6670 |   Inf | 20.0045 | -1.8564 | 1.0000 | -0.9399 | 0.3413 | -0.0082 | 0.3355 | 0.9278 | 0.1630 | -0.0633 | -0.1505 | 0.9866 | 12.49755624 |
| 3 | -342.114 | 25.5005 | 14.5144 | 138.9584 | 338578.1440 | 1.2601 |   Inf | 0.5436 | 8.0234 | 22.0923 | -1.3133 | 1.0000 | 0.1058 | 0.9944 | 0.0057 | 0.9920 | -0.1060 | 0.0688 | -0.0690 | 0.0016 | 0.9976 | 21.15397818 |
| 4 | -343.001 | 22.6169 | -3.2445 | 128.7144 | 12.1260 | 3.2256 | 28.0667 | 0.5636 |   Inf | 21.4655 | -1.7223 | 1.0000 | -0.9925 | 0.1220 | 0.0024 | 0.1203 | 0.9754 | 0.1849 | -0.0202 | -0.1838 | 0.9828 | 10.85757540 |
| 5 | -343.103 | 23.5372 | -4.8020 | 143.5802 |   Inf | 17.5739 | 35.0292 | 0.9284 | 10.8723 | 475534.0871 | -2.0066 | 1.0000 | -0.9981 | 0.0567 | -0.0254 | 0.0380 | 0.8802 | 0.4731 | -0.0492 | -0.4712 | 0.8806 | 23.34265956 |
| 6 | -343.103 | 23.5372 | -4.8020 | 143.5801 | 128901.4576 | 17.5739 | 35.0292 | 0.9284 | 10.8723 |   Inf | -2.0066 | 1.0000 | -0.9981 | 0.0567 | -0.0254 | 0.0380 | 0.8802 | 0.4731 | -0.0492 | -0.4712 | 0.8806 | 23.34258063 |
| 7 | -343.649 | -2.1179 | -349.4339 | 486.2180 | 127.8061 | 0.9726 | 21.6456 | 0.6935 |   Inf | 13.9947 | -9.6605 | 1.0000 | -0.0529 | -0.6988 | 0.7134 | 0.9985 | -0.0480 | 0.0269 | 0.0154 | 0.7137 | 0.7003 | 507.21939455 |
| 8 | -344.545 | 7.7953 | -331.0905 | 406.1524 |   Inf | 54543570069.5276 | 81.9787 | 1.3347 | 15.1607 | 3237657310475151525613257960041069111821729792.0000 | -16.3642 | 1.0000 | -0.9990 | 0.0205 | -0.0390 | -0.0161 | 0.6549 | 0.7556 | -0.0410 | -0.7555 | 0.6539 | 438.68601252 |
| 9 | -344.949 | 22.2241 | -15.1007 | 147.4090 |   Inf | 56323008.4063 | 20.8129 | 0.7601 | 22410671002.9515 | 16.3858 | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | 0.0637 | 0.8067 | -0.5876 | 0.0137 | 0.5880 | 0.8088 | 31.51340176 |
| 10 | -344.949 | 25.0653 | 20.8984 | 121.1877 | 137737.4019 | 2110391.9563 | 20.8123 | 0.7601 |   Inf | 16.3854 | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | 0.0637 | 0.8067 | -0.5876 | 0.0138 | 0.5880 | 0.8087 | 19.14570812 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=12.1664, max_pdist=21.1540 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_pd1_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.627e+05 | 1.628e+05 |
| 2 | 4.661e+03 | 4.667e+03 |
| 3 | 2.878e+03 | 2.875e+03 |
| 4 | 1.170e+03 | 1.171e+03 |
| 5 | 3.266e+02 | 3.265e+02 |
| 6 | 2.434e+02 | 2.435e+02 |
| 7 | 1.263e+02 | 1.267e+02 |
| 8 | 6.685e+01 | 6.700e+01 |
| 9 | 5.783e+00 | 5.761e+00 |
| 10 | 3.793e+00 | 3.632e+00 |
| 11 | 3.786e-01 | 2.733e-01 |
| 12 | 6.340e-03 | 5.793e-03 |

numDeriv::hessian (operative): cond = 25660334.6050, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 28100517.2358, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000000 |
| 2 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000071 |
| 3 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000088 |
| 4 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000083 |
| 5 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000113 |
| 6 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000102 |
| 7 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.3264 | 13.5961 | 5.1528 |   Inf | 0.9336 | 1.6725 | -3.2498 | 0.8929 | 0.7784 | -0.5059 | 0.3717 | -0.6101 | -0.7489 | 0.2585 | 0.1476 | -0.4280 | -0.8917 | 0.00000309 |
| 8 | -327.084 | 17.1657 | -0.8539 | 10.0387 | 0.0003 |   Inf | 5.1147 | 14766614.2476 | 1.1051 | 1.5126 | -3.2929 | 0.8428 | 0.8212 | -0.4075 | 0.3996 | -0.5211 | -0.8208 | 0.2339 | 0.2327 | -0.4003 | -0.8864 | 3102.14856844 |
| 9 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.4411 | 12000.6170 | 4.8275 |   Inf | 0.8906 | 1.6460 | -3.7263 | 0.8236 | 0.7765 | -0.5521 | 0.3037 | -0.6248 | -0.7371 | 0.2574 | 0.0818 | -0.3896 | -0.9173 | 1.21816658 |
| 10 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 0.4411 |   Inf | 4.8275 | 47459664891343.8359 | 0.8906 | 1.6460 | -3.7263 | 0.8236 | 0.7765 | -0.5521 | 0.3037 | -0.6248 | -0.7371 | 0.2574 | 0.0818 | -0.3896 | -0.9173 | 1.21816673 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.041e+03 | 3.977e+03 |
| 2 | 7.209e+02 | 7.210e+02 |
| 3 | 4.645e+02 | 4.692e+02 |
| 4 | 2.347e+02 | 2.519e+02 |
| 5 | 1.016e+02 | 1.202e+02 |
| 6 | 2.255e+01 | 2.254e+01 |
| 7 | 5.502e+00 | 5.636e+00 |
| 8 | 5.277e+00 | 5.335e+00 |
| 9 | 1.473e+00 | 2.246e+00 |
| 10 | 6.486e-01 | 1.015e+00 |
| 11 | 4.353e-01 | 4.917e-01 |
| 12 | 1.469e-01 | 3.603e-01 |
| 13 | -3.249e+00 | 1.676e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 23734.0971, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 1.6725 | 0.3264 | 0.9336 | 5.1528 |   Inf | 13.5961 | -3.2498 | 0.8929 | -0.1476 | 0.4280 | 0.8917 | 0.7784 | -0.5059 | 0.3717 | 0.6101 | 0.7489 | -0.2585 | 0.00000000 |
| 2 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.4411 | 0.8906 | 4.8275 | 439039.2091 |   Inf | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 0.6248 | 0.7371 | -0.2574 | 1.21816436 |
| 3 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.4411 | 0.8906 | 4.8275 | 252516.8988 |   Inf | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 0.6248 | 0.7371 | -0.2574 | 1.21816631 |
| 4 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 0.4411 | 0.8906 | 4.8275 | 10542.5795 |   Inf | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | 0.7765 | -0.5521 | 0.3037 | 0.6248 | 0.7371 | -0.2574 | 1.21816712 |
| 5 | -331.826 | 22.6859 | -4.7649 | 4.1703 | 0.5355 | 0.0001 | 1.1122 | 3.2054 |   Inf | 248317696.3827 | -8.9173 | 0.6942 | 0.6240 | -0.3858 | 0.6795 | -0.3793 | 0.6107 | 0.6951 | 0.6832 | 0.6915 | -0.2348 | 6668.25338568 |
| 6 | -332.580 | 71.9783 | 82.9634 | 99.3896 | 10.0289 | 0.0392 | 1.5523 |   Inf | 1.6544 | 3.9641 | -91.7792 | 0.7066 | 0.3506 | 0.6682 | 0.6562 | -0.8569 | 0.5116 | -0.0632 | 0.3780 | 0.5401 | -0.7520 | 161.50946701 |
| 7 | -335.229 | 19.1332 | -2.7816 | 9.1404 | 1.0479 | 0.5015 | 1.0107 |   Inf | 4.3717 | 7.6843 | -4.1555 | 0.9003 | -0.4002 | 0.5278 | 0.7492 | 0.7283 | -0.3131 | 0.6096 | 0.5563 | 0.7895 | -0.2591 | 3.73421379 |
| 8 | -335.413 | 17.3855 | 14.5137 | 8.5965 | 1.5281 | 0.0016 | 0.8999 | 295.0923 |   Inf | 2817.1513 | -3.2049 | 0.7366 | 0.1434 | 0.2425 | 0.9595 | 0.2742 | -0.9413 | 0.1969 | 0.9509 | 0.2349 | -0.2015 | 607.81182818 |
| 9 | -335.596 | 24.7701 | 16.0436 | 23.4473 | 3.5848 | 1.3780 | 1635458324024449280.0000 |   Inf |   Inf | 0.0000 | -10.1342 | 0.7062 | 0.3735 | 0.1176 | 0.9202 | 0.8951 | 0.2149 | -0.3907 | -0.2437 | 0.9695 | -0.0251 | 1497733400764433226757009346888106580581023744.00000000 |
| 10 | -335.774 | 41.7946 | 17.1480 | 49.3528 | 5.9145 | 0.0002 | 1.4378 | 63883125.5581 | 131169.9976 |   Inf | -28.8796 | 0.7014 | 0.5083 | 0.0568 | 0.8593 | 0.2156 | -0.9744 | -0.0631 | 0.8337 | 0.2174 | -0.5076 | 4317.25175308 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.7136, max_pdist=1.2182 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.275e+03 | 4.222e+03 |
| 2 | 7.619e+02 | 7.810e+02 |
| 3 | 5.140e+02 | 5.532e+02 |
| 4 | 2.431e+02 | 2.665e+02 |
| 5 | 7.006e+01 | 6.596e+01 |
| 6 | 2.991e+01 | 2.115e+01 |
| 7 | 7.624e+00 | 6.851e+00 |
| 8 | 4.564e+00 | 5.354e+00 |
| 9 | 1.251e+00 | 2.363e+00 |
| 10 | 5.974e-01 | 1.029e+00 |
| 11 | 4.099e-01 | 4.874e-01 |
| 12 | 2.032e-01 | 3.588e-01 |
| 13 | -8.194e+02 | 1.629e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 25923.2904, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3__bd_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 1.6725 | 13.5961 | 0.3264 | 5.1528 | 0.9336 |   Inf | -3.2498 | 0.8929 | -0.1476 | 0.4280 | 0.8917 | -0.6101 | -0.7489 | 0.2585 | 0.7784 | -0.5059 | 0.3717 | 0.00000000 |
| 2 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 1.6725 | 13.5961 | 0.3264 | 5.1528 | 0.9336 |   Inf | -3.2498 | 0.8929 | -0.1476 | 0.4280 | 0.8917 | -0.6101 | -0.7489 | 0.2585 | 0.7784 | -0.5059 | 0.3717 | 0.00000117 |
| 3 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 1.6725 | 13.5961 | 0.3264 | 5.1528 | 0.9336 |   Inf | -3.2498 | 0.8929 | -0.1476 | 0.4280 | 0.8917 | -0.6101 | -0.7489 | 0.2585 | 0.7784 | -0.5059 | 0.3717 | 0.00000055 |
| 4 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 | 2086144.5626 | 0.4411 | 4.8275 | 0.8906 |   Inf | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | -0.6248 | -0.7371 | 0.2574 | 0.7765 | -0.5521 | 0.3037 | 1.21816782 |
| 5 | -327.423 | 17.8616 | -0.7785 | 11.9307 | 1.6460 |   Inf | 0.4411 | 4.8275 | 0.8906 | 7082.8082 | -3.7263 | 0.8236 | -0.0818 | 0.3896 | 0.9173 | -0.6248 | -0.7371 | 0.2574 | 0.7765 | -0.5521 | 0.3037 | 1.21816493 |
| 6 | -333.657 | 28.1048 | 11.0955 | 15.3314 | 3.2742 | 2.3031 | 0.5131 | 1.9859 |   Inf | 0.6397 | -8.4634 | 0.7413 | 0.0591 | 0.3936 | 0.9174 | -0.2966 | -0.8705 | 0.3927 | 0.9532 | -0.2953 | 0.0653 | 17.37775037 |
| 7 | -333.657 | 28.1048 | 11.0955 | 15.3314 | 3.2742 | 2.3031 | 0.5131 | 1.9859 |   Inf | 0.6397 | -8.4634 | 0.7413 | 0.0591 | 0.3936 | 0.9174 | -0.2966 | -0.8705 | 0.3927 | 0.9532 | -0.2953 | 0.0653 | 17.37775002 |
| 8 | -334.566 | 50.9713 | 17.0265 | 61.9306 | 6.7955 | 651.0869 | 0.0010 | 161.4441 | 1.4572 |   Inf | -39.0379 | 0.7029 | 0.5328 | 0.0440 | 0.8451 | -0.8186 | -0.2265 | 0.5278 | 0.2147 | -0.9730 | -0.0846 | 976.92193237 |
| 9 | -335.229 | 19.1332 | -2.7816 | 9.1404 | 1.0479 | 7.6843 | 0.5015 |   Inf | 1.0107 | 4.3717 | -4.1555 | 0.9003 | -0.4002 | 0.5278 | 0.7492 | -0.5563 | -0.7895 | 0.2591 | 0.7283 | -0.3131 | 0.6096 | 3.73421452 |
| 10 | -335.413 | 17.4004 | 14.5285 | 8.5957 | 1.5291 |   Inf | 0.0003 | 332.0860 | 0.9003 | 6213.1539 | -3.2074 | 0.7365 | 0.1434 | 0.2425 | 0.9595 | -0.9511 | -0.2342 | 0.2013 | 0.2736 | -0.9415 | 0.1970 | 3533.73305892 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3__bd_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 3.926e+03 | 3.119e+03 |
| 2 | 8.162e+02 | 8.523e+02 |
| 3 | 6.160e+02 | 6.372e+02 |
| 4 | 2.956e+02 | 2.852e+02 |
| 5 | 9.144e+01 | 8.666e+01 |
| 6 | 2.143e+01 | 2.139e+01 |
| 7 | 5.494e+00 | 5.468e+00 |
| 8 | 3.554e+00 | 5.048e+00 |
| 9 | 1.407e+00 | 2.391e+00 |
| 10 | 4.622e-01 | 1.005e+00 |
| 11 | 4.292e-01 | 4.901e-01 |
| 12 | 1.873e-01 | 3.597e-01 |
| 13 | -6.741e+02 | 1.608e-01 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 19390.4971, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -325.025 | 15.5509 | 13.6785 | 8.5802 | 0.6453 | 645.3181 | 2.1227 | 8.8350 | 0.0005 | 5.3932 | -2.6869 | 0.9691 | 0.9408 | 0.2985 | -0.1609 | -0.3353 | 0.8892 | -0.3113 | 0.0502 | 0.3469 | 0.9366 | 0.00000000 |
| 2 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 27813669.9025 | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43282476 |
| 3 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 555221.0305 | 2.0301 | 9.5937 | 0.3420 | 5.3128 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43280184 |
| 4 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 290585.7479 | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43282313 |
| 5 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 212936.3217 | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43282341 |
| 6 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 205870.3242 | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43282240 |
| 7 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 65823.7058 | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43282299 |
| 8 | -326.497 | 15.3607 | 9.2392 | 10.1372 | 0.6714 | 43123.3824 | 2.0301 | 9.5937 | 0.3420 | 5.3129 | -2.8920 | 0.9426 | 0.8997 | 0.3910 | -0.1940 | -0.4331 | 0.8544 | -0.2869 | 0.0536 | 0.3422 | 0.9381 | 1837.43281686 |
| 9 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 | 10040606346654.6719 | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 1837.34720002 |
| 10 | -326.709 | 17.4666 | -0.7208 | 11.2698 | 0.9336 | 28926034535677911147032513938651493695488.0000 | 1.6725 | 13.5961 | 0.3264 | 5.1528 | -3.2498 | 0.8929 | 0.6101 | 0.7489 | -0.2585 | -0.7784 | 0.5059 | -0.3717 | -0.1476 | 0.4280 | 0.8917 | 1837.34720026 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=1.4718, max_pdist=1837.4328 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.364e+06 | 9.056e+05 |
| 2 | 2.570e+04 | 3.461e+03 |
| 3 | 3.735e+03 | 1.320e+03 |
| 4 | 7.165e+02 | 7.476e+02 |
| 5 | 5.144e+02 | 5.249e+02 |
| 6 | 1.780e+02 | 4.075e+02 |
| 7 | 5.678e+01 | 5.807e+01 |
| 8 | 6.044e+00 | 4.930e+01 |
| 9 | 3.904e-02 | 3.607e+01 |
| 10 | 2.794e-03 | 2.609e+01 |
| 11 | -2.374e+03 | 5.979e+00 |
| 12 | -7.882e+03 | 1.210e-01 |
| 13 | -2.781e+04 | 3.856e-02 |
| 14 | -9.700e+04 | 2.863e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 316357355.7343, n negative = 0, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_sigR3 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -328.595 | 50.1774 | 27.9548 | 134.6504 | 1.9598 | 0.0267 | 10.0534 | 0.0001 | 7.0670 |   Inf | -23.0323 | 0.7576 | 0.8231 | -0.5678 | -0.0085 | -0.5582 | -0.8062 | -0.1959 | 0.1044 | 0.1660 | -0.9806 | 0.00000000 |
| 2 | -335.281 | 24.7789 | 2.5700 | 136.9873 |   Inf | 3.7118 | 13.8574 | 0.6032 | 5.5187 | 23.4831 | -4.7958 | 0.7833 | -0.9518 | 0.3066 | -0.0075 | 0.3040 | 0.9464 | 0.1093 | 0.0406 | 0.1017 | -0.9940 | 8315.90767798 |
| 3 | -335.481 | 46.1466 | 4.4792 | 133.2170 |   Inf | 3.2642 | 7.7891 | 2.5314 | 21038150869.0328 | 595866.6768 | -28.6587 | 0.7143 | 0.0306 | 0.9995 | 0.0021 | 0.9958 | -0.0306 | 0.0857 | 0.0857 | -0.0005 | -0.9963 | 8317.10840348 |
| 4 | -335.481 | 46.1468 | 4.4792 | 133.2170 | 3954317350.1764 | 3.2642 | 7.7891 | 2.5314 |   Inf | 441512.7509 | -28.6589 | 0.7143 | 0.0306 | 0.9995 | 0.0021 | 0.9958 | -0.0306 | 0.0857 | 0.0857 | -0.0005 | -0.9963 | 8317.10840331 |
| 5 | -335.481 | 46.1450 | 4.4790 | 133.2156 | 3.2641 | 2.5315 | 7.7894 | 0.0001 | 8883.1002 |   Inf | -28.6566 | 0.7143 | 0.9958 | -0.0306 | 0.0857 | -0.0305 | -0.9995 | -0.0021 | 0.0857 | -0.0005 | -0.9963 | 7633.15613114 |
| 6 | -335.856 | 187.2962 | -318.7997 | 146.0428 | 19.5931 | 2.7448 | 11.4265 | 0.9280 | 35.2729 |   Inf | -182.5134 | 0.7398 | 0.4217 | -0.9026 | 0.0865 | 0.9026 | 0.4270 | 0.0547 | 0.0863 | -0.0550 | -0.9948 | 8326.27983534 |
| 7 | -338.041 | 38.5120 | -56.3523 | 154.3691 | 2.2884 | 3.1712 |   Inf | 0.0784 | 9.7545 | 19.5569 | -24.6846 | 0.7635 | 0.9918 | 0.1179 | 0.0493 | -0.1276 | 0.9370 | 0.3252 | 0.0079 | 0.3288 | -0.9444 | 8305.17767837 |
| 8 | -339.131 | 25.4323 | 3.5261 | 108.7776 | 1.6445 | 3.8748 |   Inf | 0.6582 | 8.9954 | 23.8768 | -2.1771 | 1.0000 | -0.9478 | 0.3187 | -0.0113 | 0.3104 | 0.9301 | 0.1962 | 0.0731 | 0.1824 | -0.9805 | 8316.08744767 |
| 9 | -339.225 | 31.4910 | 24.0025 | 299.3238 | 7.9752 | 1.2952 | 169.9155 | 0.0007 |   Inf | 40.1645 | -17.7276 | 0.6968 | 0.1978 | 0.9798 | -0.0301 | 0.9802 | -0.1978 | 0.0001 | -0.0059 | -0.0295 | -0.9995 | 6983.20558491 |
| 10 | -339.588 | 27.2912 | 16.8119 | 140.7772 | 64.7507 | 0.6047 |   Inf | 0.0000 | 1.8929 | 29.4651 | -5.5666 | 0.7268 | -0.0246 | 0.9997 | 0.0034 | -0.9981 | -0.0244 | -0.0557 | 0.0556 | 0.0047 | -0.9984 | 293979.15418666 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.8864, max_pdist=8317.1084 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_sigR3 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 6.126e+09 | 2.391e+08 |
| 2 | 3.710e+06 | 2.661e+04 |
| 3 | 1.935e+06 | 2.347e+04 |
| 4 | 2.654e+04 | 2.116e+03 |
| 5 | 2.108e+03 | 7.856e+02 |
| 6 | 7.788e+02 | 4.972e+01 |
| 7 | 4.967e+01 | 1.346e+01 |
| 8 | 4.454e-02 | 5.401e-02 |
| 9 | 3.147e-05 | 1.306e-02 |
| 10 | -7.879e+01 | -9.714e-05 |
| 11 | -1.597e+06 | -2.753e-01 |
| 12 | -3.473e+08 | -7.253e+05 |
| 13 | -2.383e+09 | -6.955e+07 |

numDeriv::hessian (operative): cond =   Inf, n negative = 4, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 4, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P2__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -345.516 | 20.4217 | 293.3971 | 3.3536 | 27.4657 | 0.0001 |   Inf | -47.7730 | 0.6877 | 0.9999 | 0.0147 | -0.0147 | 0.9999 | 0.00000000 |
| 2 | -345.532 | 18.4647 | 304.4726 | 3.3284 | 28.2669 | 0.0027 |   Inf | -48.9125 | 0.6876 | 0.9998 | 0.0210 | -0.0210 | 0.9998 | 8457.16846498 |
| 3 | -345.573 | 16.7418 | 408.1289 | 3.2552 | 32.3976 | 0.0000 |   Inf | -69.9258 | 0.6864 | 0.9998 | 0.0198 | -0.0198 | 0.9998 | 13532.88365322 |
| 4 | -345.596 | 16.4216 | 315.9279 | 3.2431 | 28.4575 | 0.0039 |   Inf | -52.2709 | 0.6868 | 0.9996 | 0.0271 | -0.0271 | 0.9996 | 8566.28142980 |
| 5 | -345.612 | 20.6341 | 201.8062 | 3.3846 | 22.5359 | 0.0013 |   Inf | -30.8246 | 0.6886 | 0.9998 | 0.0209 | -0.0209 | 0.9998 | 8038.45404226 |
| 6 | -345.613 | 20.7244 | 187.5138 | 3.2965 | 20.9134 | 0.0000 |   Inf | -30.1960 | 0.6871 | 0.9998 | 0.0222 | -0.0222 | 0.9998 | 32276.08180014 |
| 7 | -345.626 | 22.2306 | 170.9004 | 3.3754 | 19.7815 | 0.0001 |   Inf | -27.1723 | 0.6884 | 0.9999 | 0.0146 | -0.0146 | 0.9999 | 6668.13094933 |
| 8 | -345.644 | 22.0031 | 169.8293 | 3.2879 | 19.2515 | 0.0012 |   Inf | -28.2523 | 0.6866 | 0.9999 | 0.0162 | -0.0162 | 0.9999 | 7997.24102022 |
| 9 | -345.774 | 21.7978 | 130.8288 | 3.2691 | 16.2036 | 0.0002 |   Inf | -21.2057 | 0.6869 | 0.9997 | 0.0239 | -0.0239 | 0.9997 | 3861.93082317 |
| 10 | -352.865 | 16.0881 | 130.4394 | 16.4456 | 2.2381 | 0.0001 |   Inf | -17.9053 | 0.6892 | -0.0205 | 0.9998 | 0.9998 | 0.0205 | 374.58037973 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0572, max_pdist=13532.8837 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P2__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 7.083e+10 | 2.518e+09 |
| 2 | 8.710e+04 | 8.489e+04 |
| 3 | 1.581e+03 | 4.474e+02 |
| 4 | 4.446e+02 | 8.677e+01 |
| 5 | 8.713e+01 | 1.471e-02 |
| 6 | -4.807e-01 | 1.108e-02 |
| 7 | -4.926e+01 | -2.658e-02 |
| 8 | -3.916e+06 | -1.572e+03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P2__bd_sigR1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -345.541 | 20.5832 | 251.2079 | 25.0271 | 0.0002 |   Inf | 3.3367 | -40.8566 | 0.6874 | -0.0167 | 0.9999 | -0.9999 | -0.0167 | 0.00000000 |
| 2 | -345.545 | 20.4677 | 246.5558 | 24.8275 | 0.0013 |   Inf | 3.3377 | -39.8383 | 0.6876 | -0.0175 | 0.9998 | -0.9998 | -0.0175 | 3405.64685756 |
| 3 | -345.568 | 20.5255 | 220.4756 | 23.4120 | 0.0003 |   Inf | 3.3499 | -34.8670 | 0.6879 | -0.0195 | 0.9998 | -0.9998 | -0.0195 | 293.80405521 |
| 4 | -345.609 | 19.5993 | 203.2980 | 22.1547 | 0.0001 |   Inf | 3.2691 | -32.4456 | 0.6870 | -0.0264 | 0.9997 | -0.9997 | -0.0264 | 11272.27139581 |
| 5 | -345.660 | 22.3566 | 156.6942 | 18.2869 | 0.0000 |   Inf | 3.3043 | -25.8768 | 0.6870 | -0.0153 | 0.9999 | -0.9999 | -0.0153 | 59480889.75330894 |
| 6 | -345.875 | 23.0227 | 111.8894 | 14.4668 | 0.0000 |   Inf | 3.3120 | -18.0462 | 0.6879 | -0.0154 | 0.9999 | -0.9999 | -0.0154 | 33512.97469469 |
| 7 | -347.943 | 38.2043 | 233.7557 | 20.8605 | 0.0000 |   Inf | 3.5281 | -50.2577 | 0.6824 | 0.0637 | 0.9980 | -0.9980 | 0.0637 | 327310.78094989 |
| 8 | -348.590 | 30.6468 | 107.1991 | 12.3420 | 0.0001 |   Inf | 3.5721 | -22.2812 | 0.6813 | 0.0695 | 0.9976 | -0.9976 | 0.0695 | 7711.25603742 |
| 9 | -352.865 | 16.0928 | 130.4429 | 2.2383 | 0.0000 |   Inf | 16.4447 | -17.9085 | 0.6892 | 0.9998 | 0.0204 | 0.0204 | -0.9998 | 34567.14343756 |
| 10 | -353.704 | 24.9925 | 1182.8379 | 57.3162 | 2.3180 | 29621678658376860979590528139001856.0000 |   Inf | -201.3783 | 0.6872 | 0.0060 | 1.0000 | 1.0000 | -0.0060 | 4297.06926136 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0270, max_pdist=3405.6469 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P2__bd_sigR1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 4.031e+09 | 7.501e+09 |
| 2 | 3.476e+05 | 5.866e+04 |
| 3 | 5.979e+04 | 4.592e+02 |
| 4 | 4.493e+02 | 8.699e+01 |
| 5 | 8.747e+01 | 1.034e+00 |
| 6 | -3.329e-01 | 5.635e-02 |
| 7 | -1.863e+02 | 1.797e-02 |
| 8 | -2.495e+12 | -1.752e+05 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P2__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -345.543 | 16.9494 | 314.5962 | 0.0011 |   Inf | 3.3209 | 29.0824 | -49.6365 | 0.6879 | -0.9997 | -0.0254 | 0.0254 | -0.9997 | 0.00000000 |
| 2 | -345.569 | 21.1342 | 211.0360 | 0.0015 |   Inf | 3.3354 | 22.5807 | -33.9542 | 0.6875 | -0.9999 | -0.0173 | 0.0173 | -0.9999 | 235.41757400 |
| 3 | -345.569 | 18.6667 | 244.2659 | 0.0000 |   Inf | 3.3203 | 25.0828 | -38.2523 | 0.6879 | -0.9997 | -0.0257 | 0.0257 | -0.9997 | 133717443.50146475 |
| 4 | -353.700 | 31.2377 | 1393.4548 | 2.3295 | 62.1116 |   Inf | 0.0000 | -240.0409 | 0.6871 | 1.0000 | -0.0097 | 0.0097 | 1.0000 | 488464935583002656768.00000000 |
| 5 | -353.704 | 30.9472 | 1196.6155 | 2.3343 |   Inf | 44640052181327691776.0000 | 57.3199 | -206.2181 | 0.6871 | 0.9999 | -0.0111 | -0.0111 | -0.9999 | 1248.39342551 |
| 6 | -353.705 | 27.8071 | 1081.0590 | 2.3285 | 54.4730 |   Inf | 0.0000 | -185.2482 | 0.6871 | 1.0000 | -0.0093 | 0.0093 | 1.0000 | 110427787163082138690172651905998458521124864.00000000 |
| 7 | -353.709 | 27.2218 | 956.4737 | 2.3307 | 1203735480004631.0000 |   Inf | 51.0663 | -163.6737 | 0.6871 | 1.0000 | -0.0099 | -0.0099 | -1.0000 | 1086.70602481 |
| 8 | -353.712 | 25.0452 | 830.1428 | 2.3272 | 2149132438021032.2500 |   Inf | 47.4696 | -141.1580 | 0.6871 | 1.0000 | -0.0087 | -0.0087 | -1.0000 | 1014.90990522 |
| 9 | -353.713 | 25.0119 | 822.8332 | 0.0000 | 2.3272 | 47.2363 |   Inf | -139.9557 | 0.6871 | -0.0088 | -1.0000 | 1.0000 | -0.0088 | 26892.60087247 |
| 10 | -353.718 | 24.0042 | 704.3328 | 2.3278 | 4372261.9811 |   Inf | 43.5029 | -119.2359 | 0.6871 | 1.0000 | -0.0088 | -0.0088 | -1.0000 | 955.30142633 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0266, max_pdist=133717443.5015 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P2__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 5.157e+11 | 6.143e+07 |
| 2 | 9.659e+04 | 9.202e+04 |
| 3 | 2.244e+04 | 4.261e+02 |
| 4 | 4.283e+02 | 8.643e+01 |
| 5 | 8.677e+01 | 2.071e-01 |
| 6 | -6.104e-01 | 1.491e-02 |
| 7 | -2.397e+01 | 1.000e-02 |
| 8 | -2.713e+09 | -2.407e+04 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 1, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T1_P2__bd_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -345.549 | 19.8551 | 258.1088 |   Inf | 3.3678 | 25.8417 | 0.0000 | -40.7105 | 0.6881 | 0.0193 | -0.9998 | 0.9998 | 0.0193 | 0.00000000 |
| 2 | -345.553 | 20.1649 | 240.6597 |   Inf | 3.3370 | 24.5879 | 0.0008 | -38.4885 | 0.6877 | 0.0194 | -0.9998 | 0.9998 | 0.0194 | 2431419973.23961592 |
| 3 | -345.554 | 17.6007 | 291.8814 |   Inf | 3.2931 | 27.5967 | 0.0003 | -46.8207 | 0.6875 | 0.0252 | -0.9997 | 0.9997 | 0.0252 | 2431418010.06111288 |
| 4 | -345.572 | 21.2346 | 207.6272 |   Inf | 3.3452 | 22.3889 | 0.0015 | -33.2735 | 0.6877 | 0.0171 | -0.9999 | 0.9999 | 0.0171 | 2431420511.38634205 |
| 5 | -345.583 | 20.8058 | 230.7585 |   Inf | 3.2816 | 23.4216 | 0.0001 | -38.6168 | 0.6867 | 0.0172 | -0.9999 | 0.9999 | 0.0172 | 2431414388.61650419 |
| 6 | -345.596 | 21.8356 | 184.3320 |   Inf | 3.3418 | 20.6599 | 0.0004 | -29.7116 | 0.6874 | 0.0158 | -0.9999 | 0.9999 | 0.0158 | 2431418783.07990742 |
| 7 | -345.608 | 19.8809 | 195.4728 |   Inf | 3.3141 | 21.8380 | 0.0001 | -30.4986 | 0.6887 | 0.0260 | -0.9997 | 0.9997 | 0.0260 | 2431405880.37869358 |
| 8 | -345.825 | 23.0884 | 119.1346 |   Inf | 3.2894 | 14.9355 | 0.0000 | -19.8191 | 0.6867 | 0.0136 | -0.9999 | 0.9999 | 0.0136 | 2430981135.83707237 |
| 9 | -349.069 | 25.5191 | 86.3318 |   Inf | 3.1036 | 10.2818 | 0.0000 | -18.1078 | 0.6803 | -0.0159 | -0.9999 | 0.9999 | -0.0159 | 2017508360.40616536 |
| 10 | -352.865 | 16.0870 | 130.4422 |   Inf | 16.4461 | 2.2381 | 0.0000 | -17.9054 | 0.6892 | -0.9998 | -0.0205 | -0.0205 | 0.9998 | 2431400600.42235088 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0048, max_pdist=2431419973.2396 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T1_P2__bd_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.480e+21 | 3.906e+21 |
| 2 | 1.290e+17 | 3.017e+11 |
| 3 | 6.159e+04 | 6.045e+04 |
| 4 | 4.419e+02 | 4.426e+02 |
| 5 | 8.681e+01 | 8.632e+01 |
| 6 | -3.366e-01 | 1.548e-02 |
| 7 | -8.846e+13 | -1.265e+13 |
| 8 | -9.214e+23 | -4.461e+16 |

numDeriv::hessian (operative): cond =   Inf, n negative = 3, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond =   Inf, n negative = 2, strict Flag B → FAIL, relaxed → FAIL
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_sigL2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -329.407 | 29.0039 | 3.7049 | 127.4316 | 1.6747 |   Inf | 15.7544 | 0.2139 | 3.6605 | 23.0231 | -5.8589 | 0.8708 | 0.9085 | -0.4180 | -0.0031 | -0.4162 | -0.9038 | -0.1001 | 0.0390 | 0.0922 | -0.9950 | 0.00000000 |
| 2 | -329.407 | 29.0039 | 3.7049 | 127.4316 | 1.6747 |   Inf | 15.7544 | 0.2139 | 3.6605 | 23.0231 | -5.8589 | 0.8708 | 0.9085 | -0.4180 | -0.0031 | -0.4162 | -0.9038 | -0.1001 | 0.0390 | 0.0922 | -0.9950 | 0.00000127 |
| 3 | -335.481 | 46.1467 | 4.4792 | 133.2170 | 3.2642 | 2.5314 | 7.7891 | 245.3871 |   Inf | 30140989245227585536.0000 | -28.6588 | 0.7143 | 0.9958 | -0.0306 | 0.0857 | -0.0306 | -0.9995 | -0.0021 | 0.0857 | -0.0005 | -0.9963 | 29.50077535 |
| 4 | -335.481 | 46.1459 | 4.4792 | 133.2170 | 3.2641 | 2.5314 | 7.7891 | 473120.1303 |   Inf | 65754904071729593003495265402880.0000 | -28.6580 | 0.7143 | 0.9958 | -0.0306 | 0.0857 | -0.0306 | -0.9995 | -0.0021 | 0.0857 | -0.0005 | -0.9963 | 29.50035510 |
| 5 | -335.487 | 47.7378 | 10.0993 | 135.3875 | 3.3420 | 2.0576 | 7.5707 | 0.7935 |   Inf | 1462459640.1421 | -29.7131 | 0.7130 | 0.9948 | -0.0595 | 0.0829 | -0.0646 | -0.9961 | 0.0603 | 0.0790 | -0.0653 | -0.9947 | 32.19611898 |
| 6 | -335.487 | 47.7380 | 10.0993 | 135.3875 |   Inf | 70.5453 | 7.5707 | 2.0576 | 3.3420 | 692889.3211 | -29.7134 | 0.7130 | 0.0646 | 0.9961 | -0.0603 | -0.9948 | 0.0595 | -0.0829 | 0.0790 | -0.0653 | -0.9947 | 32.34405663 |
| 7 | -335.759 | 45.2148 | 22.3794 | 133.1081 | 1357.6882 |   Inf | 8.1510 | 0.0000 | 3.2347 | 2232.1948 | -23.1526 | 0.7173 | 0.0801 | 0.9931 | -0.0853 | -0.9935 | 0.0726 | -0.0874 | 0.0806 | -0.0918 | -0.9925 | 232036798.70243189 |
| 8 | -335.833 | 302.9703 | -489.1117 | 162.3192 | 23.5444 |   Inf | 11.2511 | 7933596573818171.0000 | 2.8794 | 72666584902157889175552.0000 | -302.5139 | 0.7385 | 0.4724 | -0.8775 | 0.0832 | -0.8770 | -0.4774 | -0.0552 | 0.0882 | -0.0469 | -0.9950 | 638.09890157 |
| 9 | -335.853 | 919.0612 | -2161.8543 | 341.5007 | 338462.2347 | 52.0656 | 11.5689 | 2.5935 |   Inf |   Inf | -1032.9738 | 0.7416 | -0.9228 | -0.3819 | -0.0514 | 0.3760 | -0.9216 | 0.0966 | 0.0843 | -0.0698 | -0.9940 | 2565.66996557 |
| 10 | -335.924 | 25.2276 | 23.8042 | 133.4906 | 263.7036 |   Inf | 19.9171 | 0.0001 | 0.8782 | 33.0339 | -1.6292 | 1.0000 | 0.0677 | 0.9943 | -0.0821 | -0.9971 | 0.0645 | -0.0409 | 0.0354 | -0.0846 | -0.9958 | 14024.60607696 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=6.0740, max_pdist=29.5008 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_sigL2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 1.961e+04 | 2.472e+04 |
| 2 | 3.988e+03 | 2.125e+03 |
| 3 | 1.966e+03 | 1.604e+03 |
| 4 | 6.318e+02 | 5.812e+02 |
| 5 | 5.552e+02 | 3.189e+02 |
| 6 | 2.149e+02 | 1.489e+02 |
| 7 | 1.394e+02 | 1.036e+02 |
| 8 | 4.334e+01 | 6.463e+01 |
| 9 | 1.211e+01 | 1.206e+01 |
| 10 | 3.206e+00 | 2.213e+00 |
| 11 | 3.657e-01 | 7.032e-01 |
| 12 | 2.412e-02 | 1.141e-01 |
| 13 | -7.149e-02 | 5.422e-03 |

numDeriv::hessian (operative): cond =   Inf, n negative = 1, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 4559712.7847, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_T3_P1__bd_sigR2 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | mu3 | sigltil1 | sigltil2 | sigltil3 | sigrtil1 | sigrtil2 | sigrtil3 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | o_mat5 | o_mat6 | o_mat7 | o_mat8 | o_mat9 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -329.407 | 29.0039 | 3.7049 | 127.4316 | 1.6747 | 3.6605 | 23.0231 | 0.2139 |   Inf | 15.7544 | -5.8589 | 0.8708 | 0.9085 | -0.4180 | -0.0031 | 0.4162 | 0.9038 | 0.1001 | -0.0390 | -0.0922 | 0.9950 | 0.00000000 |
| 2 | -329.407 | 29.0039 | 3.7049 | 127.4316 | 1.6747 | 3.6605 | 23.0231 | 0.2139 |   Inf | 15.7544 | -5.8589 | 0.8708 | 0.9085 | -0.4180 | -0.0031 | 0.4162 | 0.9038 | 0.1001 | -0.0390 | -0.0922 | 0.9950 | 0.00001438 |
| 3 | -334.921 | 59.5433 | -61.4527 | 125.3175 | 2.6564 | 0.1581 |   Inf | 0.0001 | 9.0468 | 10.6519 | -46.3057 | 0.7352 | 0.9414 | 0.3327 | 0.0557 | -0.3287 | 0.9418 | -0.0707 | -0.0760 | 0.0483 | 0.9959 | 15803.40886691 |
| 4 | -335.829 | 319.4068 | -542.3665 | 167.7013 |   Inf | 2.8352 | 24.9423 | 11.2922 | 2840806705740296984578426573030760120320.0000 | 0.0000 | -323.2402 | 0.7389 | -0.0876 | 0.0499 | 0.9949 | 0.8850 | 0.4624 | 0.0547 | 0.4573 | -0.8853 | 0.0847 | 9688552949042567291137341649933599209265966035801216962952953302996884802999175902559993856.00000000 |
| 5 | -339.181 | 71.8259 | -864.5196 | 1062.5483 | 85.2565 | 1.7400 |   Inf | 0.0000 | 7427330181711597207245815808.0000 | 9.2414 | -120.2024 | 0.7619 | 0.0332 | -0.6713 | 0.7405 | 0.9976 | 0.0675 | 0.0164 | -0.0610 | 0.7381 | 0.6719 | 35448.97418321 |
| 6 | -339.643 | 153.6686 | -282.1365 | -31.3505 | 25.5413 | 2.4944 | 15.1909 | 0.0000 |   Inf | 115880940519821459456.0000 | -110.9974 | 0.7603 | 0.3178 | -0.6963 | -0.6435 | 0.9316 | 0.3554 | 0.0755 | 0.1761 | -0.6236 | 0.7617 | 40661.06223371 |
| 7 | -344.949 | 10.6515 | -161.7362 | 254.2076 | 4399322.2214 | 3.1561 | 20.8134 | 0.7601 |   Inf | 16.3862 | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | 0.0637 | 0.8067 | -0.5875 | 0.0137 | 0.5880 | 0.8088 | 209.31631513 |
| 8 | -344.949 | 13.9152 | -120.3823 | 224.0894 | 63763.4832 | 20.8133 | 0.0000 | 0.7601 | 16.3861 |   Inf | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | 0.0137 | 0.5880 | 0.8088 | 0.0637 | 0.8067 | -0.5875 | 193349436896075474844785614097082796041519621769795757001257939128238208420797218816.00000000 |
| 9 | -344.949 | 25.0324 | 20.4816 | 121.4915 | 11467894308514068.0000 | 724165751139.6266 | 20.8124 | 0.7601 |   Inf | 16.3855 | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | 0.0637 | 0.8067 | -0.5876 | 0.0138 | 0.5880 | 0.8087 | 19.13505232 |
| 10 | -344.949 | 19.4116 | -50.7385 | 173.3651 | 31631.3096 | 73891.5635 | 20.8132 | 0.7601 |   Inf | 16.3861 | -1.7447 | 1.0000 | -0.9979 | 0.0596 | -0.0263 | 0.0637 | 0.8067 | -0.5875 | 0.0137 | 0.5880 | 0.8088 | 72.10844245 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=5.5135, max_pdist=15803.4089 → FAIL (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_T3_P1__bd_sigR2 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 2.176e+05 | 2.176e+05 |
| 2 | 4.697e+03 | 4.695e+03 |
| 3 | 3.401e+03 | 3.392e+03 |
| 4 | 1.771e+03 | 1.771e+03 |
| 5 | 3.717e+02 | 3.713e+02 |
| 6 | 3.334e+02 | 3.329e+02 |
| 7 | 1.417e+02 | 1.414e+02 |
| 8 | 7.036e+01 | 6.949e+01 |
| 9 | 1.207e+01 | 1.206e+01 |
| 10 | 1.506e+00 | 2.304e+00 |
| 11 | 7.379e-01 | 7.040e-01 |
| 12 | 6.062e-02 | 1.139e-01 |
| 13 | 5.362e-03 | 5.421e-03 |

numDeriv::hessian (operative): cond = 40578588.1940, n negative = 0, strict Flag B → FAIL
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 40137732.2786, n negative = 0, strict Flag B → FAIL, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### T2_P1__bd_pd1_sigL1 — Appendix A: optimization restarts (Flag A)

| rank | logLik | mu1 | mu2 | sigltil1 | sigltil2 | sigrtil1 | sigrtil2 | ctil | pd | o_mat1 | o_mat2 | o_mat3 | o_mat4 | dist_to_best |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000000 |
| 2 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000026 |
| 3 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000027 |
| 4 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000012 |
| 5 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000032 |
| 6 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000011 |
| 7 | -349.384 | 23.3846 | 13.2848 |   Inf | 1.6891 | 0.7686 | 3.3411 | -1.6801 | 1.0000 | -0.9520 | -0.3060 | 0.3060 | -0.9520 | 0.00000013 |
| 8 | -349.560 | 22.9333 | 14.3941 |   Inf | 1.9550 | 0.5459 | 2.3248 | -1.7214 | 1.0000 | -0.9589 | 0.2836 | -0.2836 | -0.9589 | 1.56088001 |
| 9 | -349.560 | 22.9333 | 14.3941 |   Inf | 1.9550 | 0.5459 | 2.3248 | -1.7214 | 1.0000 | -0.9589 | 0.2836 | -0.2836 | -0.9589 | 1.56088001 |
| 10 | -349.560 | 22.9333 | 14.3941 |   Inf | 1.9550 | 0.5459 | 2.3248 | -1.7214 | 1.0000 | -0.9589 | 0.2836 | -0.2836 | -0.9589 | 1.56087982 |

Flag A rule: on the top-3 restarts, logLik range < 0.1 AND max parameter-distance < 0.05 (the table above lists the top-10 restarts for inspection; the decision uses the top 3). This model: ll_range=0.0000, max_pdist=0.0000 → PASS (wb$flag_a). A max_pdist of NA means `dist_between_params` could not be evaluated because a shape parameter saturates to +/-Inf.

### T2_P1__bd_pd1_sigL1 — Appendix B: Hessian eigenvalues (Flag B)

| # | eigenvalue numDeriv::hessian (operative) | eigenvalue (J+Jᵀ)/2 (comparison) |
|---|---:|---:|
| 1 | 7.265e+02 | 7.278e+02 |
| 2 | 4.011e+02 | 4.015e+02 |
| 3 | 2.777e+02 | 2.780e+02 |
| 4 | 3.100e+01 | 3.240e+01 |
| 5 | 1.836e+01 | 1.836e+01 |
| 6 | 2.040e+00 | 2.071e+00 |
| 7 | 6.831e-01 | 6.935e-01 |

numDeriv::hessian (operative): cond = 1063.5765, n negative = 0, strict Flag B → PASS
(J+Jᵀ)/2 = jacobian(grad), symmetrized (comparison): cond = 1049.4547, n negative = 0, strict Flag B → PASS, relaxed → PASS
A large negative eigenvalue in the numDeriv::hessian column is a finite-difference artifact in stiff (e.g. rotation `o_par`) directions; the operative Flag B uses the symmetrized numDeriv::hessian. See docs/well_behaved_flag_b_hessian.md.
Hessian method: operative Flag B: symmetrized numDeriv::hessian (Richardson) on the reduced parameter space after fixing saturated boundary parameters; H_bar := (H + t(H))/2; symmetrized Jacobian of the gradient (J + t(J))/2 reported alongside for comparison

### Numerical Hessian & tolerance assessment

The operative curvature estimate is the symmetrized numDeriv::hessian at the optimum; the symmetrized Jacobian of the gradient, (J + Jᵀ)/2 with J = numDeriv::jacobian(numDeriv::grad(NLL)), is shown for comparison.
Strict Flag B uses eigenvalues > 1e-8 and condition number < 1e6; the relaxed diagnostic uses eigenvalues > -1e-6 and condition number < 1e8.
Under the relaxed tolerance, the following scanned model(s) that FAILED the strict Flag B would pass: T2_T3_P1__bd_pd1_sigR2, T2_T3_P1__bd_sigR2

Across 24 scanned models: 6 pass Flag A (convergence), 2 pass strict Flag B, 4 pass relaxed Flag B.

Well-behaved under the **strict** criteria (Flag A AND strict Flag B): **1**. Well-behaved if Flag B is **relaxed** (Flag A AND relaxed Flag B): **1**.

**Why models fail Flag A.** Of the 18 models that fail Flag A: **14** are genuine convergence failures (the top restarts reach different log-likelihoods, ll_range >= 0.1); **0** reach a reproducible log-likelihood (ll_range < 0.1) but the parameter-distance is undefined (NA) because a shape parameter saturates to +/-Inf, so `dist_between_params` cannot be evaluated; and **4** reach a reproducible log-likelihood but the parameter values genuinely differ (max_pdist >= 0.05).

Of the 0 models whose Flag A failure is caused *only* by the undefined (Inf-parameter) distance, **0 also have a positive-definite Hessian** (strict or relaxed Flag B). These are the only candidates that could plausibly be rescued — but doing so requires changing how Flag A treats a saturated (+/-Inf) shape parameter (currently NA -> fail), **not** relaxing the Hessian tolerance.

**Relaxing the Hessian (Flag B) tolerance rescues no additional model**: the binding constraint is Flag A (optimisation convergence), not the Hessian. Every model that already passes Flag A resolves Flag B identically under strict and relaxed tolerances, so widening the eigenvalue/condition thresholds changes nothing. The models with well-conditioned Hessians that are nonetheless rejected fail on Flag A, as decomposed above.

This is diagnostic only — M_Ω selection still uses the strict criterion.

## Phase L4 — boundary models in the intermediate band

Rule: expand boundary versions of L1 models with **pBIC ∈ [best_L1 + τ, Ω + τ]**.
**Eligible L1 models:** 11 (noT_P1, noT_P2_P3, noT_P2, noT_P3, T1_noP, T2_noP, T2_P2_P3, T2_P2, T2_T3_noP, T3_noP, T3_P1)

_No boundary models were fit in L4._

**L4 replacement check:** No L4 model is well-behaved with pBIC < Ω; M_Ω is unchanged under the L4 rule.

## Selected model (final M_Ω)

- **Model:** `T2_P1__bd_pd1_sigL1`
- **pBIC (Ω):** 744.2
- **logLik:** -349.3841
- **Variables:** T2, P1
- **Free parameters (n_free):** 7
- **Boundary mask:** pd=Inf, sigltil1=Inf

## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- A train/test split or k-fold cross-validation will be added in the next version.
- **TSS:** 0.4835
- **Threshold:** 0.4674
- **Sensitivity:** 0.9224
- **Specificity:** 0.5611
- **Presences / pseudo-absences:** 336 / 319
- **Prevalence:** 0.5122

### Biological-scale parameters (`best_bio`)

| Parameter | Value |
|-----------|-------|
| mu | 23.3846, 13.2848 |
| sigltil |   Inf, 1.6891 |
| sigrtil | 0.7686, 3.3411 |
| ctil | -1.6801 |
| pd | 1.0000 |
| o_mat | -0.9520, -0.3060, 0.3060, -0.9520 |

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

![Profile likelihood plots for the best model (T2_P1__bd_pd1_sigL1)](plots/profile_likelihood_v7.png)

*Red line: likelihood threshold. Blue line: the optimum. `(PASS)`/`(FAIL)` indicates the arc-check outcome for each parameter.*

## Habitat suitability prediction

![Habitat suitability prediction](plots/habitat_suitability_v7.png)

*Continuous habitat suitability (0–1) with presence (red) and absence (grey) points; 10 km buffered bounding box of all presence/absence points.*

![Binary habitat suitability](plots/habitat_suitability_binary_v7.png)

*Binary range map: suitability thresholded at the TSS-maximising cutoff (sensitivity+specificity). Presence (red) / absence (grey) points overlaid.*

## Summary

- **Final model:** `T2_P1__bd_pd1_sigL1` (pBIC = 744.2)
- **Successful L1 fits:** 23/23
- **Boundary L2 fits:** 131
- **Boundary L4 fits:** 0
- **τ:** 25.9385

_Generated: 2026-07-22 01:58:14_

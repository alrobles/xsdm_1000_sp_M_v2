# xsdm v6 Model Selection Report (Algorithm2 aligned)

**Species:** Acris blanchardi
**Date:** 2026-07-24 14:24:45.852056
**Starts per model:** 50
**Threads:** 16
**Years:** 1980–2020 (41 years)

## Data Summary

- **Total points:** 654
- **Presences:** 327
- **Absences:** 327
- **Time steps:** 41
- **Variables loaded:** 6
  - T1 → `T1 (bio01, annual mean temp)`
  - T2 → `T2 (bio10, warmest quarter temp)`
  - T3 → `T3 (bio11, coldest quarter temp)`
  - P1 → `P1 (bio12, annual precip)`
  - P2 → `P2 (bio16, wettest quarter precip)`
  - P3 → `P3 (bio17, driest quarter precip)`
- **Input units:** temperatures converted from ERA50Land Kelvin to °C; precipitation is mm
- **Adaptive rescaling:** applied per variable when IQR ratio > 10× temperature reference

| Variable | IQR | Scale factor | Post-scale range |
|----------|-----|--------------|------------------|
| T1 | 7.512 | 1 | [4.038, 24.966] |
| T2 | 4.355 | 1 | [17.102, 34.036] |
| T3 | 10.644 | 1 | [-13.684, 19.877] |
| P1 | 4230.707 | 1/100 | [15.205, 249.985] |
| P2 | 1820.541 | 1/100 | [8.502, 130.254] |
| P3 | 998.774 | 1/100 | [0.552, 45.886] |

## Phase 1: L1 — 23 non-boundary models

**Models fitted:** 23 / 23 succeeded

| # | Model | Vars | n | n_free | logLik | pBIC | Time (s) |
|---|-------|------|---|--------|--------|------|----------|
| 1 | T1_P3 | T1, P3 | 654 | 9 | -379.38 | 817.1 | 29.6 |
| 2 | T3_P3 | T3, P3 | 654 | 9 | -379.78 | 817.9 | 16.2 |
| 3 | T2_T3_P3 | T2, T3, P3 | 654 | 14 | -364.67 | 820.1 | 68.8 |
| 4 | T2_P3 | T2, P3 | 654 | 9 | -381.35 | 821.0 | 44.3 |
| 5 | T1_P1 | T1, P1 | 654 | 9 | -385.14 | 828.6 | 17.8 |
| 6 | T1_noP | T1 | 654 | 5 | -398.34 | 829.1 | 9.7 |
| 7 | T2_P1 | T2, P1 | 654 | 9 | -385.45 | 829.3 | 40.6 |
| 8 | T2_T3_noP | T2, T3 | 654 | 9 | -386.22 | 830.8 | 41.8 |
| 9 | T1_P2 | T1, P2 | 654 | 9 | -386.83 | 832.0 | 30.6 |
| 10 | T1_P2_P3 | T1, P2, P3 | 654 | 14 | -371.44 | 833.6 | 94.3 |
| 11 | T2_T3_P1 | T2, T3, P1 | 654 | 14 | -372.04 | 834.8 | 60.9 |
| 12 | T3_P2 | T3, P2 | 654 | 9 | -388.29 | 834.9 | 30.6 |
| 13 | T2_T3_P2 | T2, T3, P2 | 654 | 14 | -372.24 | 835.2 | 67.7 |
| 14 | T3_P2_P3 | T3, P2, P3 | 654 | 14 | -372.30 | 835.4 | 117.2 |
| 15 | T2_noP | T2 | 654 | 5 | -401.68 | 835.8 | 14.5 |
| 16 | T2_P2 | T2, P2 | 654 | 9 | -392.75 | 843.9 | 29.5 |
| 17 | T2_P2_P3 | T2, P2, P3 | 654 | 14 | -378.86 | 848.5 | 74.2 |
| 18 | T3_P1 | T3, P1 | 654 | 9 | -395.79 | 849.9 | 37.3 |
| 19 | T3_noP | T3 | 654 | 5 | -410.79 | 854.0 | 9.2 |
| 20 | noT_P2_P3 | P2, P3 | 654 | 9 | -422.53 | 903.4 | 39.9 |
| 21 | noT_P3 | P3 | 654 | 5 | -439.25 | 910.9 | 12.3 |
| 22 | noT_P2 | P2 | 654 | 5 | -442.52 | 917.4 | 33.7 |
| 23 | noT_P1 | P1 | 654 | 5 | -447.44 | 927.3 | 23.9 |

## Phase 2: L2 — Boundary models of eligible L1

- **tau** = (3 + 1) × log(654) = 4 × 6.4831 = **25.9324**
- **Best L1 pBIC:** 817.1
- **Threshold (best + tau):** 843.0

## Literal selection rules

- **L1:** fit all 23 non-boundary models; rank by pBIC.
- **L2:** fit boundary models for L1 models with pBIC ≤ best_L1 + tau.
- **L3:** union of L1 and L2, ranked by pBIC.
- **Well-behaved scan:** from lowest pBIC upward, accept the first model with top-5 logLik range < 0.1, max parameter distance < 0.05, positive-definite Hessian, and condition number < 1e6.
- **L4:** fit boundary models for L1 models with pBIC ≥ best_L1 + tau and pBIC ≤ Omega + tau.
- **Final scan:** from lowest L4 pBIC upward, stop when pBIC > Omega or accept the first well-behaved model.

**Eligible L1 models for boundary expansion:** 15

| Model | pBIC | ≤ threshold? |
|-------|------|-------------|
| noT_P1 | 927.3 |  |
| noT_P2 | 917.4 |  |
| noT_P3 | 910.9 |  |
| noT_P2_P3 | 903.4 |  |
| T1_noP | 829.1 | ✓ |
| T1_P1 | 828.6 | ✓ |
| T1_P2 | 832.0 | ✓ |
| T1_P3 | 817.1 | ✓ |
| T1_P2_P3 | 833.6 | ✓ |
| T2_noP | 835.8 | ✓ |
| T2_P1 | 829.3 | ✓ |
| T2_P2 | 843.9 |  |
| T2_P3 | 821.0 | ✓ |
| T2_P2_P3 | 848.5 |  |
| T3_noP | 854.0 |  |
| T3_P1 | 849.9 |  |
| T3_P2 | 834.9 | ✓ |
| T3_P3 | 817.9 | ✓ |
| T3_P2_P3 | 835.4 | ✓ |
| T2_T3_noP | 830.8 | ✓ |
| T2_T3_P1 | 834.8 | ✓ |
| T2_T3_P2 | 835.2 | ✓ |
| T2_T3_P3 | 820.1 | ✓ |

## L2 boundary model list

| Model | Base L1 | Mask | Status | n_free | pBIC | Time (s) |
|-------|---------|------|--------|--------|------|----------|
| T1_noP__bd_pd1 | T1_noP | bd_pd1 | success | 4 | 837.1 | 10.7 |
| T1_noP__bd_sigL1 | T1_noP | bd_sigL1 | success | 4 | 920.0 | 11.8 |
| T1_noP__bd_sigR1 | T1_noP | bd_sigR1 | success | 4 | 838.5 | 15.7 |
| T1_noP__bd_pd1_sigL1 | T1_noP | bd_pd1_sigL1 | success | 3 | 913.5 | 10.4 |
| T1_noP__bd_pd1_sigR1 | T1_noP | bd_pd1_sigR1 | success | 3 | 832.7 | 13.9 |
| T1_P1__bd_pd1 | T1_P1 | bd_pd1 | success | 8 | 833.1 | 16.6 |
| T1_P1__bd_sigL1 | T1_P1 | bd_sigL1 | success | 8 | 830.1 | 18.6 |
| T1_P1__bd_sigR1 | T1_P1 | bd_sigR1 | success | 8 | 829.9 | 28.2 |
| T1_P1__bd_sigL2 | T1_P1 | bd_sigL2 | success | 8 | 829.9 | 15.3 |
| T1_P1__bd_sigR2 | T1_P1 | bd_sigR2 | success | 8 | 829.9 | 16.3 |
| T1_P1__bd_pd1_sigL1 | T1_P1 | bd_pd1_sigL1 | success | 7 | 829.1 | 14.5 |
| T1_P1__bd_pd1_sigR1 | T1_P1 | bd_pd1_sigR1 | success | 7 | 829.1 | 10.9 |
| T1_P1__bd_pd1_sigL2 | T1_P1 | bd_pd1_sigL2 | success | 7 | 829.1 | 10.1 |
| T1_P1__bd_pd1_sigR2 | T1_P1 | bd_pd1_sigR2 | success | 7 | 829.1 | 15.2 |
| T1_P2__bd_pd1 | T1_P2 | bd_pd1 | success | 8 | 838.0 | 11.3 |
| T1_P2__bd_sigL1 | T1_P2 | bd_sigL1 | success | 8 | 826.1 | 24.5 |
| T1_P2__bd_sigR1 | T1_P2 | bd_sigR1 | success | 8 | 826.1 | 26.1 |
| T1_P2__bd_sigL2 | T1_P2 | bd_sigL2 | success | 8 | 826.1 | 28.8 |
| T1_P2__bd_sigR2 | T1_P2 | bd_sigR2 | success | 8 | 826.1 | 25.6 |
| T1_P2__bd_pd1_sigL1 | T1_P2 | bd_pd1_sigL1 | success | 7 | 831.5 | 11.6 |
| T1_P2__bd_pd1_sigR1 | T1_P2 | bd_pd1_sigR1 | success | 7 | 831.5 | 12.4 |
| T1_P2__bd_pd1_sigL2 | T1_P2 | bd_pd1_sigL2 | success | 7 | 831.5 | 14.7 |
| T1_P2__bd_pd1_sigR2 | T1_P2 | bd_pd1_sigR2 | success | 7 | 831.5 | 12.3 |
| T1_P3__bd_pd1 | T1_P3 | bd_pd1 | success | 8 | 816.5 | 14.0 |
| T1_P3__bd_sigL1 | T1_P3 | bd_sigL1 | success | 8 | 812.7 | 23.2 |
| T1_P3__bd_sigR1 | T1_P3 | bd_sigR1 | success | 8 | 812.7 | 28.5 |
| T1_P3__bd_sigL2 | T1_P3 | bd_sigL2 | success | 8 | 812.7 | 25.5 |
| T1_P3__bd_sigR2 | T1_P3 | bd_sigR2 | success | 8 | 812.7 | 33.4 |
| T1_P3__bd_pd1_sigL1 | T1_P3 | bd_pd1_sigL1 | success | 7 | 810.1 | 12.4 |
| T1_P3__bd_pd1_sigR1 | T1_P3 | bd_pd1_sigR1 | success | 7 | 810.1 | 12.3 |
| T1_P3__bd_pd1_sigL2 | T1_P3 | bd_pd1_sigL2 | success | 7 | 810.1 | 10.8 |
| T1_P3__bd_pd1_sigR2 | T1_P3 | bd_pd1_sigR2 | success | 7 | 810.1 | 14.6 |
| T1_P2_P3__bd_pd1 | T1_P2_P3 | bd_pd1 | success | 13 | 839.4 | 85.0 |
| T1_P2_P3__bd_sigL1 | T1_P2_P3 | bd_sigL1 | success | 13 | 828.9 | 64.9 |
| T1_P2_P3__bd_sigR1 | T1_P2_P3 | bd_sigR1 | success | 13 | 829.1 | 61.6 |
| T1_P2_P3__bd_sigL2 | T1_P2_P3 | bd_sigL2 | success | 13 | 829.1 | 81.8 |
| T1_P2_P3__bd_sigR2 | T1_P2_P3 | bd_sigR2 | success | 13 | 827.9 | 58.0 |
| T1_P2_P3__bd_sigL3 | T1_P2_P3 | bd_sigL3 | success | 13 | 828.8 | 53.6 |
| T1_P2_P3__bd_sigR3 | T1_P2_P3 | bd_sigR3 | success | 13 | 827.4 | 94.5 |
| T1_P2_P3__bd_pd1_sigL1 | T1_P2_P3 | bd_pd1_sigL1 | success | 12 | 833.2 | 47.9 |
| T1_P2_P3__bd_pd1_sigR1 | T1_P2_P3 | bd_pd1_sigR1 | success | 12 | 832.9 | 38.6 |
| T1_P2_P3__bd_pd1_sigL2 | T1_P2_P3 | bd_pd1_sigL2 | success | 12 | 833.2 | 35.9 |
| T1_P2_P3__bd_pd1_sigR2 | T1_P2_P3 | bd_pd1_sigR2 | success | 12 | 832.9 | 51.6 |
| T1_P2_P3__bd_pd1_sigL3 | T1_P2_P3 | bd_pd1_sigL3 | success | 12 | 832.9 | 45.7 |
| T1_P2_P3__bd_pd1_sigR3 | T1_P2_P3 | bd_pd1_sigR3 | success | 12 | 832.9 | 68.8 |
| T2_noP__bd_pd1 | T2_noP | bd_pd1 | success | 4 | 829.3 | 9.2 |
| T2_noP__bd_sigL1 | T2_noP | bd_sigL1 | success | 4 | 932.6 | 11.0 |
| T2_noP__bd_sigR1 | T2_noP | bd_sigR1 | success | 4 | 829.3 | 11.5 |
| T2_noP__bd_pd1_sigL1 | T2_noP | bd_pd1_sigL1 | success | 3 | 926.1 | 7.5 |
| T2_noP__bd_pd1_sigR1 | T2_noP | bd_pd1_sigR1 | success | 3 | 822.8 | 9.1 |
| T2_P1__bd_pd1 | T2_P1 | bd_pd1 | success | 8 | 824.0 | 13.7 |
| T2_P1__bd_sigL1 | T2_P1 | bd_sigL1 | success | 8 | 822.8 | 35.0 |
| T2_P1__bd_sigR1 | T2_P1 | bd_sigR1 | success | 8 | 822.8 | 45.5 |
| T2_P1__bd_sigL2 | T2_P1 | bd_sigL2 | success | 8 | 822.8 | 57.5 |
| T2_P1__bd_sigR2 | T2_P1 | bd_sigR2 | success | 8 | 822.8 | 45.8 |
| T2_P1__bd_pd1_sigL1 | T2_P1 | bd_pd1_sigL1 | success | 7 | 817.5 | 19.8 |
| T2_P1__bd_pd1_sigR1 | T2_P1 | bd_pd1_sigR1 | success | 7 | 817.5 | 17.2 |
| T2_P1__bd_pd1_sigL2 | T2_P1 | bd_pd1_sigL2 | success | 7 | 817.5 | 12.7 |
| T2_P1__bd_pd1_sigR2 | T2_P1 | bd_pd1_sigR2 | success | 7 | 817.5 | 19.5 |
| T2_P3__bd_pd1 | T2_P3 | bd_pd1 | success | 8 | 820.4 | 12.7 |
| T2_P3__bd_sigL1 | T2_P3 | bd_sigL1 | success | 8 | 814.6 | 28.7 |
| T2_P3__bd_sigR1 | T2_P3 | bd_sigR1 | success | 8 | 814.5 | 39.7 |
| T2_P3__bd_sigL2 | T2_P3 | bd_sigL2 | success | 8 | 814.6 | 47.6 |
| T2_P3__bd_sigR2 | T2_P3 | bd_sigR2 | success | 8 | 814.6 | 39.3 |
| T2_P3__bd_pd1_sigL1 | T2_P3 | bd_pd1_sigL1 | success | 7 | 813.9 | 13.7 |
| T2_P3__bd_pd1_sigR1 | T2_P3 | bd_pd1_sigR1 | success | 7 | 813.9 | 14.2 |
| T2_P3__bd_pd1_sigL2 | T2_P3 | bd_pd1_sigL2 | success | 7 | 813.9 | 16.1 |
| T2_P3__bd_pd1_sigR2 | T2_P3 | bd_pd1_sigR2 | success | 7 | 813.9 | 14.8 |
| T3_P2__bd_pd1 | T3_P2 | bd_pd1 | success | 8 | 851.8 | 15.5 |
| T3_P2__bd_sigL1 | T3_P2 | bd_sigL1 | success | 8 | 828.9 | 42.6 |
| T3_P2__bd_sigR1 | T3_P2 | bd_sigR1 | success | 8 | 828.8 | 49.1 |
| T3_P2__bd_sigL2 | T3_P2 | bd_sigL2 | success | 8 | 829.9 | 58.1 |
| T3_P2__bd_sigR2 | T3_P2 | bd_sigR2 | success | 8 | 829.8 | 41.8 |
| T3_P2__bd_pd1_sigL1 | T3_P2 | bd_pd1_sigL1 | success | 7 | 845.3 | 19.2 |
| T3_P2__bd_pd1_sigR1 | T3_P2 | bd_pd1_sigR1 | success | 7 | 845.3 | 16.1 |
| T3_P2__bd_pd1_sigL2 | T3_P2 | bd_pd1_sigL2 | success | 7 | 845.3 | 13.5 |
| T3_P2__bd_pd1_sigR2 | T3_P2 | bd_pd1_sigR2 | success | 7 | 845.3 | 15.6 |
| T3_P3__bd_pd1 | T3_P3 | bd_pd1 | success | 8 | 821.7 | 15.0 |
| T3_P3__bd_sigL1 | T3_P3 | bd_sigL1 | success | 8 | 823.3 | 23.1 |
| T3_P3__bd_sigR1 | T3_P3 | bd_sigR1 | success | 8 | 823.3 | 25.8 |
| T3_P3__bd_sigL2 | T3_P3 | bd_sigL2 | success | 8 | 823.3 | 17.8 |
| T3_P3__bd_sigR2 | T3_P3 | bd_sigR2 | success | 8 | 823.3 | 28.0 |
| T3_P3__bd_pd1_sigL1 | T3_P3 | bd_pd1_sigL1 | success | 7 | 829.5 | 15.5 |
| T3_P3__bd_pd1_sigR1 | T3_P3 | bd_pd1_sigR1 | success | 7 | 829.5 | 13.0 |
| T3_P3__bd_pd1_sigL2 | T3_P3 | bd_pd1_sigL2 | success | 7 | 829.5 | 12.7 |
| T3_P3__bd_pd1_sigR2 | T3_P3 | bd_pd1_sigR2 | success | 7 | 829.5 | 14.0 |
| T3_P2_P3__bd_pd1 | T3_P2_P3 | bd_pd1 | success | 13 | 834.3 | 68.1 |
| T3_P2_P3__bd_sigL1 | T3_P2_P3 | bd_sigL1 | success | 13 | 829.2 | 69.8 |
| T3_P2_P3__bd_sigR1 | T3_P2_P3 | bd_sigR1 | success | 13 | 829.3 | 80.6 |
| T3_P2_P3__bd_sigL2 | T3_P2_P3 | bd_sigL2 | success | 13 | 829.3 | 82.6 |
| T3_P2_P3__bd_sigR2 | T3_P2_P3 | bd_sigR2 | success | 13 | 829.5 | 120.2 |
| T3_P2_P3__bd_sigL3 | T3_P2_P3 | bd_sigL3 | success | 13 | 828.9 | 77.2 |
| T3_P2_P3__bd_sigR3 | T3_P2_P3 | bd_sigR3 | success | 13 | 828.8 | 69.1 |
| T3_P2_P3__bd_pd1_sigL1 | T3_P2_P3 | bd_pd1_sigL1 | success | 12 | 828.9 | 39.4 |
| T3_P2_P3__bd_pd1_sigR1 | T3_P2_P3 | bd_pd1_sigR1 | success | 12 | 828.9 | 63.6 |
| T3_P2_P3__bd_pd1_sigL2 | T3_P2_P3 | bd_pd1_sigL2 | success | 12 | 828.9 | 59.4 |
| T3_P2_P3__bd_pd1_sigR2 | T3_P2_P3 | bd_pd1_sigR2 | success | 12 | 828.9 | 64.3 |
| T3_P2_P3__bd_pd1_sigL3 | T3_P2_P3 | bd_pd1_sigL3 | success | 12 | 828.9 | 45.1 |
| T3_P2_P3__bd_pd1_sigR3 | T3_P2_P3 | bd_pd1_sigR3 | success | 12 | 828.9 | 49.0 |
| T2_T3_noP__bd_pd1 | T2_T3_noP | bd_pd1 | success | 8 | 832.8 | 15.2 |
| T2_T3_noP__bd_sigL1 | T2_T3_noP | bd_sigL1 | success | 8 | 830.5 | 26.7 |
| T2_T3_noP__bd_sigR1 | T2_T3_noP | bd_sigR1 | success | 8 | 830.5 | 42.0 |
| T2_T3_noP__bd_sigL2 | T2_T3_noP | bd_sigL2 | success | 8 | 830.5 | 44.8 |
| T2_T3_noP__bd_sigR2 | T2_T3_noP | bd_sigR2 | success | 8 | 830.5 | 36.2 |
| T2_T3_noP__bd_pd1_sigL1 | T2_T3_noP | bd_pd1_sigL1 | success | 7 | 828.1 | 12.9 |
| T2_T3_noP__bd_pd1_sigR1 | T2_T3_noP | bd_pd1_sigR1 | success | 7 | 827.6 | 13.6 |
| T2_T3_noP__bd_pd1_sigL2 | T2_T3_noP | bd_pd1_sigL2 | success | 7 | 827.6 | 14.9 |
| T2_T3_noP__bd_pd1_sigR2 | T2_T3_noP | bd_pd1_sigR2 | success | 7 | 827.6 | 14.7 |
| T2_T3_P1__bd_pd1 | T2_T3_P1 | bd_pd1 | success | 13 | 838.6 | 56.2 |
| T2_T3_P1__bd_sigL1 | T2_T3_P1 | bd_sigL1 | success | 13 | 826.5 | 83.5 |
| T2_T3_P1__bd_sigR1 | T2_T3_P1 | bd_sigR1 | success | 13 | 826.9 | 92.8 |
| T2_T3_P1__bd_sigL2 | T2_T3_P1 | bd_sigL2 | success | 13 | 827.1 | 82.0 |
| T2_T3_P1__bd_sigR2 | T2_T3_P1 | bd_sigR2 | success | 13 | 826.4 | 129.6 |
| T2_T3_P1__bd_sigL3 | T2_T3_P1 | bd_sigL3 | success | 13 | 821.1 | 88.7 |
| T2_T3_P1__bd_sigR3 | T2_T3_P1 | bd_sigR3 | success | 13 | 826.4 | 66.0 |
| T2_T3_P1__bd_pd1_sigL1 | T2_T3_P1 | bd_pd1_sigL1 | success | 12 | 832.1 | 70.8 |
| T2_T3_P1__bd_pd1_sigR1 | T2_T3_P1 | bd_pd1_sigR1 | success | 12 | 832.1 | 104.9 |
| T2_T3_P1__bd_pd1_sigL2 | T2_T3_P1 | bd_pd1_sigL2 | success | 12 | 833.1 | 78.7 |
| T2_T3_P1__bd_pd1_sigR2 | T2_T3_P1 | bd_pd1_sigR2 | success | 12 | 832.1 | 105.0 |
| T2_T3_P1__bd_pd1_sigL3 | T2_T3_P1 | bd_pd1_sigL3 | success | 12 | 832.1 | 47.7 |
| T2_T3_P1__bd_pd1_sigR3 | T2_T3_P1 | bd_pd1_sigR3 | success | 12 | 832.1 | 68.5 |
| T2_T3_P2__bd_pd1 | T2_T3_P2 | bd_pd1 | success | 13 | 846.3 | 86.7 |
| T2_T3_P2__bd_sigL1 | T2_T3_P2 | bd_sigL1 | success | 13 | 835.4 | 71.0 |
| T2_T3_P2__bd_sigR1 | T2_T3_P2 | bd_sigR1 | success | 13 | 827.0 | 73.8 |
| T2_T3_P2__bd_sigL2 | T2_T3_P2 | bd_sigL2 | success | 13 | 827.0 | 71.3 |
| T2_T3_P2__bd_sigR2 | T2_T3_P2 | bd_sigR2 | success | 13 | 830.2 | 73.1 |
| T2_T3_P2__bd_sigL3 | T2_T3_P2 | bd_sigL3 | success | 13 | 831.2 | 59.6 |
| T2_T3_P2__bd_sigR3 | T2_T3_P2 | bd_sigR3 | success | 13 | 825.2 | 77.4 |
| T2_T3_P2__bd_pd1_sigL1 | T2_T3_P2 | bd_pd1_sigL1 | success | 12 | 839.8 | 56.6 |
| T2_T3_P2__bd_pd1_sigR1 | T2_T3_P2 | bd_pd1_sigR1 | success | 12 | 839.8 | 50.0 |
| T2_T3_P2__bd_pd1_sigL2 | T2_T3_P2 | bd_pd1_sigL2 | success | 12 | 839.5 | 73.7 |
| T2_T3_P2__bd_pd1_sigR2 | T2_T3_P2 | bd_pd1_sigR2 | success | 12 | 839.6 | 67.3 |
| T2_T3_P2__bd_pd1_sigL3 | T2_T3_P2 | bd_pd1_sigL3 | success | 12 | 839.8 | 34.4 |
| T2_T3_P2__bd_pd1_sigR3 | T2_T3_P2 | bd_pd1_sigR3 | success | 12 | 839.6 | 42.1 |
| T2_T3_P3__bd_pd1 | T2_T3_P3 | bd_pd1 | success | 13 | 814.9 | 51.5 |
| T2_T3_P3__bd_sigL1 | T2_T3_P3 | bd_sigL1 | success | 13 | 810.4 | 52.3 |
| T2_T3_P3__bd_sigR1 | T2_T3_P3 | bd_sigR1 | success | 13 | 814.4 | 56.9 |
| T2_T3_P3__bd_sigL2 | T2_T3_P3 | bd_sigL2 | success | 13 | 814.4 | 63.1 |
| T2_T3_P3__bd_sigR2 | T2_T3_P3 | bd_sigR2 | success | 13 | 814.4 | 66.6 |
| T2_T3_P3__bd_sigL3 | T2_T3_P3 | bd_sigL3 | success | 13 | 811.9 | 54.1 |
| T2_T3_P3__bd_sigR3 | T2_T3_P3 | bd_sigR3 | success | 13 | 811.0 | 40.5 |
| T2_T3_P3__bd_pd1_sigL1 | T2_T3_P3 | bd_pd1_sigL1 | success | 12 | 808.4 | 25.9 |
| T2_T3_P3__bd_pd1_sigR1 | T2_T3_P3 | bd_pd1_sigR1 | success | 12 | 808.4 | 60.6 |
| T2_T3_P3__bd_pd1_sigL2 | T2_T3_P3 | bd_pd1_sigL2 | success | 12 | 808.4 | 53.7 |
| T2_T3_P3__bd_pd1_sigR2 | T2_T3_P3 | bd_pd1_sigR2 | success | 12 | 808.4 | 44.6 |
| T2_T3_P3__bd_pd1_sigL3 | T2_T3_P3 | bd_pd1_sigL3 | success | 12 | 808.4 | 38.3 |
| T2_T3_P3__bd_pd1_sigR3 | T2_T3_P3 | bd_pd1_sigR3 | success | 12 | 808.4 | 44.2 |

## Phase 3: L3 — Combined ranking (L1 + L2)

**Total L3 models:** 170 (23 L1 + 147 L2)

| # | Model | Type | Vars | n_free | pBIC |
|---|-------|------|------|--------|------|
| 1 | T2_T3_P3__bd_pd1_sigL2 | boundary | T2, T3, P3 | 12 | 808.4 |
| 2 | T2_T3_P3__bd_pd1_sigR2 | boundary | T2, T3, P3 | 12 | 808.4 |
| 3 | T2_T3_P3__bd_pd1_sigR3 | boundary | T2, T3, P3 | 12 | 808.4 |
| 4 | T2_T3_P3__bd_pd1_sigL3 | boundary | T2, T3, P3 | 12 | 808.4 |
| 5 | T2_T3_P3__bd_pd1_sigL1 | boundary | T2, T3, P3 | 12 | 808.4 |
| 6 | T2_T3_P3__bd_pd1_sigR1 | boundary | T2, T3, P3 | 12 | 808.4 |
| 7 | T1_P3__bd_pd1_sigR2 | boundary | T1, P3 | 7 | 810.1 |
| 8 | T1_P3__bd_pd1_sigR1 | boundary | T1, P3 | 7 | 810.1 |
| 9 | T1_P3__bd_pd1_sigL1 | boundary | T1, P3 | 7 | 810.1 |
| 10 | T1_P3__bd_pd1_sigL2 | boundary | T1, P3 | 7 | 810.1 |
| 11 | T2_T3_P3__bd_sigL1 | boundary | T2, T3, P3 | 13 | 810.4 |
| 12 | T2_T3_P3__bd_sigR3 | boundary | T2, T3, P3 | 13 | 811.0 |
| 13 | T2_T3_P3__bd_sigL3 | boundary | T2, T3, P3 | 13 | 811.9 |
| 14 | T1_P3__bd_sigL1 | boundary | T1, P3 | 8 | 812.7 |
| 15 | T1_P3__bd_sigL2 | boundary | T1, P3 | 8 | 812.7 |
| 16 | T1_P3__bd_sigR2 | boundary | T1, P3 | 8 | 812.7 |
| 17 | T1_P3__bd_sigR1 | boundary | T1, P3 | 8 | 812.7 |
| 18 | T2_P3__bd_pd1_sigL2 | boundary | T2, P3 | 7 | 813.9 |
| 19 | T2_P3__bd_pd1_sigR1 | boundary | T2, P3 | 7 | 813.9 |
| 20 | T2_P3__bd_pd1_sigR2 | boundary | T2, P3 | 7 | 813.9 |
| 21 | T2_P3__bd_pd1_sigL1 | boundary | T2, P3 | 7 | 813.9 |
| 22 | T2_T3_P3__bd_sigL2 | boundary | T2, T3, P3 | 13 | 814.4 |
| 23 | T2_T3_P3__bd_sigR1 | boundary | T2, T3, P3 | 13 | 814.4 |
| 24 | T2_T3_P3__bd_sigR2 | boundary | T2, T3, P3 | 13 | 814.4 |
| 25 | T2_P3__bd_sigR1 | boundary | T2, P3 | 8 | 814.5 |
| 26 | T2_P3__bd_sigR2 | boundary | T2, P3 | 8 | 814.6 |
| 27 | T2_P3__bd_sigL2 | boundary | T2, P3 | 8 | 814.6 |
| 28 | T2_P3__bd_sigL1 | boundary | T2, P3 | 8 | 814.6 |
| 29 | T2_T3_P3__bd_pd1 | boundary | T2, T3, P3 | 13 | 814.9 |
| 30 | T1_P3__bd_pd1 | boundary | T1, P3 | 8 | 816.5 |
| 31 | T1_P3 | non-boundary | T1, P3 | 9 | 817.1 |
| 32 | T2_P1__bd_pd1_sigR1 | boundary | T2, P1 | 7 | 817.5 |
| 33 | T2_P1__bd_pd1_sigR2 | boundary | T2, P1 | 7 | 817.5 |
| 34 | T2_P1__bd_pd1_sigL2 | boundary | T2, P1 | 7 | 817.5 |
| 35 | T2_P1__bd_pd1_sigL1 | boundary | T2, P1 | 7 | 817.5 |
| 36 | T3_P3 | non-boundary | T3, P3 | 9 | 817.9 |
| 37 | T2_T3_P3 | non-boundary | T2, T3, P3 | 14 | 820.1 |
| 38 | T2_P3__bd_pd1 | boundary | T2, P3 | 8 | 820.4 |
| 39 | T2_P3 | non-boundary | T2, P3 | 9 | 821.0 |
| 40 | T2_T3_P1__bd_sigL3 | boundary | T2, T3, P1 | 13 | 821.1 |
| 41 | T3_P3__bd_pd1 | boundary | T3, P3 | 8 | 821.7 |
| 42 | T2_P1__bd_sigR1 | boundary | T2, P1 | 8 | 822.8 |
| 43 | T2_P1__bd_sigR2 | boundary | T2, P1 | 8 | 822.8 |
| 44 | T2_P1__bd_sigL1 | boundary | T2, P1 | 8 | 822.8 |
| 45 | T2_P1__bd_sigL2 | boundary | T2, P1 | 8 | 822.8 |
| 46 | T2_noP__bd_pd1_sigR1 | boundary | T2 | 3 | 822.8 |
| 47 | T3_P3__bd_sigL2 | boundary | T3, P3 | 8 | 823.3 |
| 48 | T3_P3__bd_sigL1 | boundary | T3, P3 | 8 | 823.3 |
| 49 | T3_P3__bd_sigR1 | boundary | T3, P3 | 8 | 823.3 |
| 50 | T3_P3__bd_sigR2 | boundary | T3, P3 | 8 | 823.3 |
| 51 | T2_P1__bd_pd1 | boundary | T2, P1 | 8 | 824.0 |
| 52 | T2_T3_P2__bd_sigR3 | boundary | T2, T3, P2 | 13 | 825.2 |
| 53 | T1_P2__bd_sigR1 | boundary | T1, P2 | 8 | 826.1 |
| 54 | T1_P2__bd_sigL2 | boundary | T1, P2 | 8 | 826.1 |
| 55 | T1_P2__bd_sigL1 | boundary | T1, P2 | 8 | 826.1 |
| 56 | T1_P2__bd_sigR2 | boundary | T1, P2 | 8 | 826.1 |
| 57 | T2_T3_P1__bd_sigR2 | boundary | T2, T3, P1 | 13 | 826.4 |
| 58 | T2_T3_P1__bd_sigR3 | boundary | T2, T3, P1 | 13 | 826.4 |
| 59 | T2_T3_P1__bd_sigL1 | boundary | T2, T3, P1 | 13 | 826.5 |
| 60 | T2_T3_P1__bd_sigR1 | boundary | T2, T3, P1 | 13 | 826.9 |
| 61 | T2_T3_P2__bd_sigL2 | boundary | T2, T3, P2 | 13 | 827.0 |
| 62 | T2_T3_P2__bd_sigR1 | boundary | T2, T3, P2 | 13 | 827.0 |
| 63 | T2_T3_P1__bd_sigL2 | boundary | T2, T3, P1 | 13 | 827.1 |
| 64 | T1_P2_P3__bd_sigR3 | boundary | T1, P2, P3 | 13 | 827.4 |
| 65 | T2_T3_noP__bd_pd1_sigR2 | boundary | T2, T3 | 7 | 827.6 |
| 66 | T2_T3_noP__bd_pd1_sigL2 | boundary | T2, T3 | 7 | 827.6 |
| 67 | T2_T3_noP__bd_pd1_sigR1 | boundary | T2, T3 | 7 | 827.6 |
| 68 | T1_P2_P3__bd_sigR2 | boundary | T1, P2, P3 | 13 | 827.9 |
| 69 | T2_T3_noP__bd_pd1_sigL1 | boundary | T2, T3 | 7 | 828.1 |
| 70 | T1_P1 | non-boundary | T1, P1 | 9 | 828.6 |
| 71 | T3_P2__bd_sigR1 | boundary | T3, P2 | 8 | 828.8 |
| 72 | T3_P2_P3__bd_sigR3 | boundary | T3, P2, P3 | 13 | 828.8 |
| 73 | T1_P2_P3__bd_sigL3 | boundary | T1, P2, P3 | 13 | 828.8 |
| 74 | T1_P2_P3__bd_sigL1 | boundary | T1, P2, P3 | 13 | 828.9 |
| 75 | T3_P2_P3__bd_pd1_sigL3 | boundary | T3, P2, P3 | 12 | 828.9 |
| 76 | T3_P2_P3__bd_pd1_sigL1 | boundary | T3, P2, P3 | 12 | 828.9 |
| 77 | T3_P2_P3__bd_pd1_sigR2 | boundary | T3, P2, P3 | 12 | 828.9 |
| 78 | T3_P2_P3__bd_pd1_sigR1 | boundary | T3, P2, P3 | 12 | 828.9 |
| 79 | T3_P2_P3__bd_pd1_sigL2 | boundary | T3, P2, P3 | 12 | 828.9 |
| 80 | T3_P2_P3__bd_pd1_sigR3 | boundary | T3, P2, P3 | 12 | 828.9 |
| 81 | T3_P2__bd_sigL1 | boundary | T3, P2 | 8 | 828.9 |
| 82 | T3_P2_P3__bd_sigL3 | boundary | T3, P2, P3 | 13 | 828.9 |
| 83 | T1_P1__bd_pd1_sigR2 | boundary | T1, P1 | 7 | 829.1 |
| 84 | T1_P1__bd_pd1_sigL1 | boundary | T1, P1 | 7 | 829.1 |
| 85 | T1_P1__bd_pd1_sigL2 | boundary | T1, P1 | 7 | 829.1 |
| 86 | T1_P1__bd_pd1_sigR1 | boundary | T1, P1 | 7 | 829.1 |
| 87 | T1_P2_P3__bd_sigL2 | boundary | T1, P2, P3 | 13 | 829.1 |
| 88 | T1_noP | non-boundary | T1 | 5 | 829.1 |
| 89 | T1_P2_P3__bd_sigR1 | boundary | T1, P2, P3 | 13 | 829.1 |
| 90 | T3_P2_P3__bd_sigL1 | boundary | T3, P2, P3 | 13 | 829.2 |
| 91 | T2_P1 | non-boundary | T2, P1 | 9 | 829.3 |
| 92 | T2_noP__bd_pd1 | boundary | T2 | 4 | 829.3 |
| 93 | T2_noP__bd_sigR1 | boundary | T2 | 4 | 829.3 |
| 94 | T3_P2_P3__bd_sigR1 | boundary | T3, P2, P3 | 13 | 829.3 |
| 95 | T3_P2_P3__bd_sigL2 | boundary | T3, P2, P3 | 13 | 829.3 |
| 96 | T3_P2_P3__bd_sigR2 | boundary | T3, P2, P3 | 13 | 829.5 |
| 97 | T3_P3__bd_pd1_sigL1 | boundary | T3, P3 | 7 | 829.5 |
| 98 | T3_P3__bd_pd1_sigL2 | boundary | T3, P3 | 7 | 829.5 |
| 99 | T3_P3__bd_pd1_sigR2 | boundary | T3, P3 | 7 | 829.5 |
| 100 | T3_P3__bd_pd1_sigR1 | boundary | T3, P3 | 7 | 829.5 |
| 101 | T3_P2__bd_sigR2 | boundary | T3, P2 | 8 | 829.8 |
| 102 | T1_P1__bd_sigR2 | boundary | T1, P1 | 8 | 829.9 |
| 103 | T1_P1__bd_sigL2 | boundary | T1, P1 | 8 | 829.9 |
| 104 | T1_P1__bd_sigR1 | boundary | T1, P1 | 8 | 829.9 |
| 105 | T3_P2__bd_sigL2 | boundary | T3, P2 | 8 | 829.9 |
| 106 | T1_P1__bd_sigL1 | boundary | T1, P1 | 8 | 830.1 |
| 107 | T2_T3_P2__bd_sigR2 | boundary | T2, T3, P2 | 13 | 830.2 |
| 108 | T2_T3_noP__bd_sigR1 | boundary | T2, T3 | 8 | 830.5 |
| 109 | T2_T3_noP__bd_sigL1 | boundary | T2, T3 | 8 | 830.5 |
| 110 | T2_T3_noP__bd_sigL2 | boundary | T2, T3 | 8 | 830.5 |
| 111 | T2_T3_noP__bd_sigR2 | boundary | T2, T3 | 8 | 830.5 |
| 112 | T2_T3_noP | non-boundary | T2, T3 | 9 | 830.8 |
| 113 | T2_T3_P2__bd_sigL3 | boundary | T2, T3, P2 | 13 | 831.2 |
| 114 | T1_P2__bd_pd1_sigR1 | boundary | T1, P2 | 7 | 831.5 |
| 115 | T1_P2__bd_pd1_sigL2 | boundary | T1, P2 | 7 | 831.5 |
| 116 | T1_P2__bd_pd1_sigL1 | boundary | T1, P2 | 7 | 831.5 |
| 117 | T1_P2__bd_pd1_sigR2 | boundary | T1, P2 | 7 | 831.5 |
| 118 | T1_P2 | non-boundary | T1, P2 | 9 | 832.0 |
| 119 | T2_T3_P1__bd_pd1_sigR1 | boundary | T2, T3, P1 | 12 | 832.1 |
| 120 | T2_T3_P1__bd_pd1_sigR2 | boundary | T2, T3, P1 | 12 | 832.1 |
| 121 | T2_T3_P1__bd_pd1_sigL3 | boundary | T2, T3, P1 | 12 | 832.1 |
| 122 | T2_T3_P1__bd_pd1_sigL1 | boundary | T2, T3, P1 | 12 | 832.1 |
| 123 | T2_T3_P1__bd_pd1_sigR3 | boundary | T2, T3, P1 | 12 | 832.1 |
| 124 | T1_noP__bd_pd1_sigR1 | boundary | T1 | 3 | 832.7 |
| 125 | T2_T3_noP__bd_pd1 | boundary | T2, T3 | 8 | 832.8 |
| 126 | T1_P2_P3__bd_pd1_sigR1 | boundary | T1, P2, P3 | 12 | 832.9 |
| 127 | T1_P2_P3__bd_pd1_sigL3 | boundary | T1, P2, P3 | 12 | 832.9 |
| 128 | T1_P2_P3__bd_pd1_sigR2 | boundary | T1, P2, P3 | 12 | 832.9 |
| 129 | T1_P2_P3__bd_pd1_sigR3 | boundary | T1, P2, P3 | 12 | 832.9 |
| 130 | T2_T3_P1__bd_pd1_sigL2 | boundary | T2, T3, P1 | 12 | 833.1 |
| 131 | T1_P1__bd_pd1 | boundary | T1, P1 | 8 | 833.1 |
| 132 | T1_P2_P3__bd_pd1_sigL1 | boundary | T1, P2, P3 | 12 | 833.2 |
| 133 | T1_P2_P3__bd_pd1_sigL2 | boundary | T1, P2, P3 | 12 | 833.2 |
| 134 | T1_P2_P3 | non-boundary | T1, P2, P3 | 14 | 833.6 |
| 135 | T3_P2_P3__bd_pd1 | boundary | T3, P2, P3 | 13 | 834.3 |
| 136 | T2_T3_P1 | non-boundary | T2, T3, P1 | 14 | 834.8 |
| 137 | T3_P2 | non-boundary | T3, P2 | 9 | 834.9 |
| 138 | T2_T3_P2 | non-boundary | T2, T3, P2 | 14 | 835.2 |
| 139 | T3_P2_P3 | non-boundary | T3, P2, P3 | 14 | 835.4 |
| 140 | T2_T3_P2__bd_sigL1 | boundary | T2, T3, P2 | 13 | 835.4 |
| 141 | T2_noP | non-boundary | T2 | 5 | 835.8 |
| 142 | T1_noP__bd_pd1 | boundary | T1 | 4 | 837.1 |
| 143 | T1_P2__bd_pd1 | boundary | T1, P2 | 8 | 838.0 |
| 144 | T1_noP__bd_sigR1 | boundary | T1 | 4 | 838.5 |
| 145 | T2_T3_P1__bd_pd1 | boundary | T2, T3, P1 | 13 | 838.6 |
| 146 | T1_P2_P3__bd_pd1 | boundary | T1, P2, P3 | 13 | 839.4 |
| 147 | T2_T3_P2__bd_pd1_sigL2 | boundary | T2, T3, P2 | 12 | 839.5 |
| 148 | T2_T3_P2__bd_pd1_sigR2 | boundary | T2, T3, P2 | 12 | 839.6 |
| 149 | T2_T3_P2__bd_pd1_sigR3 | boundary | T2, T3, P2 | 12 | 839.6 |
| 150 | T2_T3_P2__bd_pd1_sigR1 | boundary | T2, T3, P2 | 12 | 839.8 |
| 151 | T2_T3_P2__bd_pd1_sigL3 | boundary | T2, T3, P2 | 12 | 839.8 |
| 152 | T2_T3_P2__bd_pd1_sigL1 | boundary | T2, T3, P2 | 12 | 839.8 |
| 153 | T2_P2 | non-boundary | T2, P2 | 9 | 843.9 |
| 154 | T3_P2__bd_pd1_sigL1 | boundary | T3, P2 | 7 | 845.3 |
| 155 | T3_P2__bd_pd1_sigL2 | boundary | T3, P2 | 7 | 845.3 |
| 156 | T3_P2__bd_pd1_sigR2 | boundary | T3, P2 | 7 | 845.3 |
| 157 | T3_P2__bd_pd1_sigR1 | boundary | T3, P2 | 7 | 845.3 |
| 158 | T2_T3_P2__bd_pd1 | boundary | T2, T3, P2 | 13 | 846.3 |
| 159 | T2_P2_P3 | non-boundary | T2, P2, P3 | 14 | 848.5 |
| 160 | T3_P1 | non-boundary | T3, P1 | 9 | 849.9 |
| 161 | T3_P2__bd_pd1 | boundary | T3, P2 | 8 | 851.8 |
| 162 | T3_noP | non-boundary | T3 | 5 | 854.0 |
| 163 | noT_P2_P3 | non-boundary | P2, P3 | 9 | 903.4 |
| 164 | noT_P3 | non-boundary | P3 | 5 | 910.9 |
| 165 | T1_noP__bd_pd1_sigL1 | boundary | T1 | 3 | 913.5 |
| 166 | noT_P2 | non-boundary | P2 | 5 | 917.4 |
| 167 | T1_noP__bd_sigL1 | boundary | T1 | 4 | 920.0 |
| 168 | T2_noP__bd_pd1_sigL1 | boundary | T2 | 3 | 926.1 |
| 169 | noT_P1 | non-boundary | P1 | 5 | 927.3 |
| 170 | T2_noP__bd_sigL1 | boundary | T2 | 4 | 932.6 |

## Phase 4: Well-behaved scan through L3

Scanning L3 from lowest pBIC upward. Stop at first model with **both** flags passing.

### Model: T2_T3_P3__bd_pd1_sigL2

- **Type:** boundary
- **Variables:** T2, T3, P3 (3)
- **n:** 654, **n_free:** 12, **pBIC:** 808.4, **logLik:** -365.3022

#### Flag A: Optimization convergence

Top 5 optimization results:

**Solution 1:** logLik = -365.302185, convergence = 4
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = -0.741194
  - `sigltil2` = Inf
  - `sigltil3` = 0.96152
  - `sigrtil1` = 2.34132
  - `sigrtil2` = -0.691913
  - `sigrtil3` = 1.63465
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 4.26277
  - `o_par2` = -1.92351
  - `o_par3` = -4.89267

**Solution 2:** logLik = -365.302185, convergence = 4
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = 0.96152
  - `sigltil2` = Inf
  - `sigltil3` = 2.34132
  - `sigrtil1` = 1.63465
  - `sigrtil2` = -0.691912
  - `sigrtil3` = -0.741194
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 0.504945
  - `o_par2` = 1.4027
  - `o_par3` = -0.0347408

**Solution 3:** logLik = -365.302185, convergence = 1
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = -0.741194
  - `sigltil2` = Inf
  - `sigltil3` = 0.96152
  - `sigrtil1` = 2.34132
  - `sigrtil2` = -0.691912
  - `sigrtil3` = 1.63465
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 4.26277
  - `o_par2` = -1.92351
  - `o_par3` = -4.89267

**Solution 4:** logLik = -365.302185, convergence = 4
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = -0.741194
  - `sigltil2` = Inf
  - `sigltil3` = 0.96152
  - `sigrtil1` = 2.34132
  - `sigrtil2` = -0.691913
  - `sigrtil3` = 1.63465
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 4.26277
  - `o_par2` = -1.92351
  - `o_par3` = -4.89267

**Solution 5:** logLik = -365.302185, convergence = 4
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = -0.741194
  - `sigltil2` = Inf
  - `sigltil3` = 0.96152
  - `sigrtil1` = 2.34132
  - `sigrtil2` = -0.691913
  - `sigrtil3` = 1.63465
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 0.305509
  - `o_par2` = -0.137857
  - `o_par3` = -0.350654

- **logLik range (top 5):** 0.000000
- **Max parameter distance (Hungarian):** 0.000001
- **Flag A:** ll_range < 0.1 (✓) AND max_pdist < 0.05 (✓) → **LIKELY WELL-BEHAVED**

#### Flag B: Hessian analysis

Hessian matrix (free parameters):

```
             [,1]        [,2]       [,3]          [,4]        [,5]       [,6]
 [1,]   54.171295   15.214298  -9.270155 -1.087703e+02  -22.782013   3.644701
 [2,]   15.214298    8.829011   1.296901 -3.176485e+01  -34.732802   1.497839
 [3,]   -9.270155    1.296901  16.726198  1.936188e+01  -80.792185 -12.315876
 [4,] -108.770277  -31.764854  19.361876  2.305259e+02   50.183997   1.863829
 [5,]  -22.782013  -34.732802 -80.792185  5.018400e+01  606.904512 102.432823
 [6,]    3.644701    1.497839 -12.315876  1.863829e+00  102.432823  79.360861
 [7,]   -1.129880    4.194307  -1.831134 -9.421775e-10    2.206118   5.266699
 [8,]  -29.113734    3.105220  32.382648  7.435141e+01   41.785531  85.335581
 [9,]   24.329573    8.828959   9.035616 -5.981875e+01 -168.019524 -79.377269
[10,]  541.739865  191.827951 -57.230050 -1.101624e+03 -509.904232  37.290934
[11,] -252.446967  -83.714897  38.445764  5.081068e+02  169.075909 -26.579316
[12,] -542.495459 -194.179712  41.260531  1.095872e+03  595.598493 -37.779994
               [,7]       [,8]        [,9]       [,10]       [,11]       [,12]
 [1,] -1.129880e+00  -29.11373   24.329573   541.73986  -252.44697  -542.49546
 [2,]  4.194307e+00    3.10522    8.828959   191.82795   -83.71490  -194.17971
 [3,] -1.831134e+00   32.38265    9.035616   -57.23005    38.44576    41.26053
 [4,] -9.421775e-10   74.35141  -59.818748 -1101.62392   508.10681  1095.87213
 [5,]  2.206118e+00   41.78553 -168.019524  -509.90423   169.07591   595.59849
 [6,]  5.266699e+00   85.33558  -79.377269    37.29093   -26.57932   -37.77999
 [7,]  7.801970e+00    1.98387   -3.384586    25.27925   -10.68898   -22.06166
 [8,]  1.983870e+00  435.61467 -169.099704  -232.16147   135.38847   194.63799
 [9,] -3.384586e+00 -169.09970  126.665360   282.31582  -122.35381  -286.60316
[10,]  2.527925e+01 -232.16147  282.315817  5847.32978 -2682.60959 -5892.35481
[11,] -1.068898e+01  135.38847 -122.353808 -2682.60959  1242.13995  2683.62337
[12,] -2.206166e+01  194.63799 -286.603164 -5892.35481  2683.62337  5962.93471
```

Eigenvalues:

  λ1 = 1.335627e+04 (> 0 ✓)
  λ2 = 6.798911e+02 (> 0 ✓)
  λ3 = 4.902890e+02 (> 0 ✓)
  λ4 = 5.455041e+01 (> 0 ✓)
  λ5 = 1.633155e+01 (> 0 ✓)
  λ6 = 1.056272e+01 (> 0 ✓)
  λ7 = 8.573901e+00 (> 0 ✓)
  λ8 = 5.416379e+00 (> 0 ✓)
  λ9 = 7.177045e-01 (> 0 ✓)
  λ10 = 2.305539e-01 (> 0 ✓)
  λ11 = 1.681120e-01 (> 0 ✓)
  λ12 = -3.999618e+00 (≤ 0 ✗)

- **All eigenvalues > 1e-8:** ✗
- **Condition number:** Inf
- **Condition number < 1e6:** ✗
- **Flag B:** Positive definite (✗) AND cond < 1e6 (✗) → **LIKELY BADLY-BEHAVED**

#### Verdict

- **⚠ WARNING: Flags disagree!** Flag A: well-behaved | Flag B: badly-behaved

---

### Model: T2_T3_P3__bd_pd1_sigR2

- **Type:** boundary
- **Variables:** T2, T3, P3 (3)
- **n:** 654, **n_free:** 12, **pBIC:** 808.4, **logLik:** -365.3022

#### Flag A: Optimization convergence

Top 5 optimization results:

**Solution 1:** logLik = -365.302185, convergence = 4
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = 1.63465
  - `sigltil2` = -0.691913
  - `sigltil3` = 2.34132
  - `sigrtil1` = 0.96152
  - `sigrtil2` = Inf
  - `sigrtil3` = -0.741194
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = -2.02153
  - `o_par2` = 0.0434891
  - `o_par3` = 1.75593

**Solution 2:** logLik = -365.302185, convergence = 1
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = -0.741194
  - `sigltil2` = -0.691912
  - `sigltil3` = 1.63465
  - `sigrtil1` = 2.34132
  - `sigrtil2` = Inf
  - `sigrtil3` = 0.96152
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = -0.629015
  - `o_par2` = -1.39399
  - `o_par3` = 8.946

**Solution 3:** logLik = -365.302185, convergence = 4
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = 1.63465
  - `sigltil2` = -0.691912
  - `sigltil3` = 2.34132
  - `sigrtil1` = 0.96152
  - `sigrtil2` = Inf
  - `sigrtil3` = -0.741194
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = -6.76446
  - `o_par2` = 0.145524
  - `o_par3` = 5.8757

**Solution 4:** logLik = -365.302185, convergence = 1
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = -0.741194
  - `sigltil2` = -0.691913
  - `sigltil3` = 1.63465
  - `sigrtil1` = 2.34132
  - `sigrtil2` = Inf
  - `sigrtil3` = 0.96152
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 0.241922
  - `o_par2` = 0.536133
  - `o_par3` = -3.44067

**Solution 5:** logLik = -365.302185, convergence = 1
  - `mu1` = 16.2598
  - `mu2` = 11.1162
  - `mu3` = 11.1042
  - `sigltil1` = 1.63465
  - `sigltil2` = -0.691913
  - `sigltil3` = 2.34132
  - `sigrtil1` = 0.96152
  - `sigrtil2` = Inf
  - `sigrtil3` = -0.741194
  - `ctil` = -2.16106
  - `pd` = Inf
  - `o_par1` = 7.46434
  - `o_par2` = -0.16058
  - `o_par3` = -6.48363

- **logLik range (top 5):** 0.000000
- **Max parameter distance (Hungarian):** 0.000002
- **Flag A:** ll_range < 0.1 (✓) AND max_pdist < 0.05 (✓) → **LIKELY WELL-BEHAVED**

#### Flag B: Hessian analysis

Hessian matrix (free parameters):

```
             [,1]        [,2]       [,3]        [,4]          [,5]       [,6]
 [1,]   54.171293   15.214298  -9.270154  -29.113734 -1.129880e+00   3.644701
 [2,]   15.214298    8.829011   1.296901    3.105219  4.194307e+00   1.497839
 [3,]   -9.270154    1.296901  16.726199   32.382648 -1.831134e+00 -12.315876
 [4,]  -29.113734    3.105219  32.382648  435.614671  1.983870e+00  85.335582
 [5,]   -1.129880    4.194307  -1.831134    1.983870  7.801970e+00   5.266699
 [6,]    3.644701    1.497839 -12.315876   85.335582  5.266699e+00  79.360860
 [7,]  -22.782012  -34.732802 -80.792187   41.785528  2.206118e+00 102.432818
 [8,] -108.770275  -31.764856  19.361876   74.351412 -1.497299e-09   1.863829
 [9,]   24.329572    8.828959   9.035617 -169.099705 -3.384585e+00 -79.377269
[10,]  267.939245  146.110948 112.838940  209.567675  1.552219e+01 -63.165924
[11,] -518.852856 -158.505598 162.089355  480.776847 -4.614965e+01 -33.163160
[12,] -777.285130 -247.059008 151.588943  492.305208 -3.376668e+01 -96.673101
              [,7]          [,8]        [,9]       [,10]       [,11]
 [1,]   -22.782012 -1.087703e+02   24.329572   267.93925  -518.85286
 [2,]   -34.732802 -3.176486e+01    8.828959   146.11095  -158.50560
 [3,]   -80.792187  1.936188e+01    9.035617   112.83894   162.08935
 [4,]    41.785528  7.435141e+01 -169.099705   209.56767   480.77685
 [5,]     2.206118 -1.497299e-09   -3.384585    15.52219   -46.14965
 [6,]   102.432818  1.863829e+00  -79.377269   -63.16592   -33.16316
 [7,]   606.904485  5.018399e+01 -168.019517 -1039.63071  -102.36385
 [8,]    50.183994  2.305259e+02  -59.818748  -564.62453  1085.30127
 [9,]  -168.019517 -5.981875e+01  126.665360   229.18538  -238.58227
[10,] -1039.630714 -5.646245e+02  229.185377  3566.32214 -2056.42375
[11,]  -102.363848  1.085301e+03 -238.582275 -2056.42375  5818.02923
[12,]   339.736065  1.564604e+03 -358.375397 -3837.07114  7730.67239
            [,12]
 [1,]  -777.28513
 [2,]  -247.05901
 [3,]   151.58894
 [4,]   492.30521
 [5,]   -33.76668
 [6,]   -96.67310
 [7,]   339.73606
 [8,]  1564.60417
 [9,]  -358.37540
[10,] -3837.07114
[11,]  7730.67239
[12,] 11748.24893
```

Eigenvalues:

  λ1 = 1.865383e+04 (> 0 ✓)
  λ2 = 2.910895e+03 (> 0 ✓)
  λ3 = 6.041756e+02 (> 0 ✓)
  λ4 = 4.055270e+02 (> 0 ✓)
  λ5 = 5.723605e+01 (> 0 ✓)
  λ6 = 4.394605e+01 (> 0 ✓)
  λ7 = 1.495620e+01 (> 0 ✓)
  λ8 = 5.395382e+00 (> 0 ✓)
  λ9 = 2.882164e+00 (> 0 ✓)
  λ10 = 1.678145e-01 (> 0 ✓)
  λ11 = 1.344947e-01 (> 0 ✓)
  λ12 = 5.710150e-02 (> 0 ✓)

- **All eigenvalues > 1e-8:** ✓
- **Condition number:** 3.27e+05
- **Condition number < 1e6:** ✓
- **Flag B:** Positive definite (✓) AND cond < 1e6 (✓) → **LIKELY WELL-BEHAVED**

#### Verdict

- **Flag A:** TRUE | **Flag B:** TRUE → **WELL-BEHAVED ✓**

---

**>>> SELECTED as M_Omega: T2_T3_P3__bd_pd1_sigR2 (pBIC = 808.4)**

**Omega (first real BIC):** 808.4
**M_Omega:** T2_T3_P3__bd_pd1_sigR2

## Phase 5: L4 — Boundary models of mid-tier L1

Models in L1 with pBIC ∈ [best_L1 + tau, Omega + tau]:
- Lower bound (best_L1 + tau) = 817.1 + 25.9324 = **843.0369**
- Upper bound (Omega + tau) = 808.4 + 25.9324 = **834.3341**

**Eligible L1 models for L4:** 0

**No models eligible for L4.**


## Final selected model: T2_T3_P3__bd_pd1_sigR2

- **pBIC (Omega):** 808.4
- **Variables:** T2, T3, P3

## Phase 7: Profile likelihood

*Profile likelihood skipped by --skip_profile; proceeding to save and map.*

## Final Summary

- **Species:** Acris blanchardi
- **Selected model:** T2_T3_P3__bd_pd1_sigR2
- **pBIC:** 808.4
- **logLik:** -365.3022
- **Variables:** T2, T3, P3
- **Type:** boundary
- **n:** 654, **n_free:** 12
- **Input units:** T in Kelvin, P in mm
- **Scale factors:** T1=1, T2=1, T3=1, P1=1/100, P2=1/100, P3=1/100
- **Arcs passing:** skipped (--skip_profile)
- **Total pipeline time:** 115.6 min


## Model fit — True Skill Statistic (TSS)

- **Estimate:** in-sample (resubstitution); optimistic upper bound on performance.
- **TSS:** 0.2497
- **Threshold:** 0.5695
- **Sensitivity:** 0.7882
- **Specificity:** 0.4615
- **Presences / pseudo-absences:** 291 / 195
- **Prevalence:** 0.5963



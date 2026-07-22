# Virtual species parametric bootstrap — Stage A

**Species:** *Acris blanchardi*  
**Smoke data:** 10 % of full dataset  
**Method:** `xsdm::vsp` on the fitted model over `M_buffer`, then refit the same model to the surrogate sample.  
**B = 10** replicates per method.

## Files

- `v7ring_params.csv` — surrogate parameter trace for `v7ring` final model (`T3_P3`).
- `v7ring_CI.csv` — 95 % percentile CI vs. the original estimate.
- `centroid_params.csv` — surrogate parameter trace for `centroid_exp` final model (`T2_P1__bd_pd1_sigL1`).
- `centroid_CI.csv` — 95 % percentile CI vs. the original estimate.

## v7ring (`T3_P3`) — 10/10 fits succeeded

| parameter | original | 95 % CI lower | 95 % CI upper | inside 95 % |
|-----------|----------|---------------|---------------|-------------|
| mu1       | -2.461   | -3.290        | -1.949        | TRUE        |
| mu2       | 14.052   | 12.234        | 14.887        | TRUE        |
| sigltil1  | 1.547    | -0.331        | 1.528         | FALSE       |
| sigltil2  | 0.952    | -0.164        | 1.350         | TRUE        |
| sigrtil1  | -0.120   | -0.330        | 1.629         | TRUE        |
| sigrtil2  | 0.400    | 0.068         | 1.658         | TRUE        |
| ctil      | -9.591   | -13.000       | -7.836        | TRUE        |
| pd        | 1.929    | 1.459         | 2.338         | TRUE        |
| o_par1    | -3.397   | -9.298        | 8.800         | TRUE        |

Only `sigltil1` (log left-sigma of `T3`, the coldest-quarter mean temperature) lies marginally above the upper CI limit (1.547 vs. 1.528).

## centroid_exp (`T2_P1__bd_pd1_sigL1`) — 10/10 fits succeeded

| parameter | original | 95 % CI lower | 95 % CI upper | inside 95 % |
|-----------|----------|---------------|---------------|-------------|
| mu1       | 23.385   | 22.577        | 24.027        | TRUE        |
| mu2       | 13.285   | 11.196        | 14.685        | TRUE        |
| sigltil1  | Inf      | Inf           | Inf           | TRUE*       |
| sigltil2  | 0.524    | 0.153         | 0.918         | TRUE        |
| sigrtil1  | -0.263   | -0.619        | -0.083        | TRUE        |
| sigrtil2  | 1.206    | 0.817         | 1.470         | TRUE        |
| ctil      | -1.680   | -2.090        | -1.308        | TRUE        |
| pd        | Inf      | Inf           | Inf           | TRUE*       |
| o_par1    | -2.831   | -9.158        | 9.751         | TRUE        |

\* `sigltil1` and `pd` are fixed to `Inf` by the boundary mask (`__bd_pd1` and `__sigL1`), so every surrogate fit also returns `Inf`. This is a fixed-value check, not a distributional one.

## Interpretation (Stage A)

Stage A is an **auto-consistency** check: if the fitted model is the true data-generating process, do repeated samples from it reproduce the original parameter estimates? With B=10:

- `centroid_exp` is fully consistent.
- `v7ring` is almost fully consistent, with one borderline parameter (`sigltil1`) just outside the noisy 10-replicate CI. A larger B would clarify whether this is sampling noise or a real tension.

This does **not** yet test whether the pseudo-absence design itself is biased; it tests whether the fitted model is self-consistent. Stage B (simulate presences, then re-apply the original pseudo-absence sampling rule) would directly test the design.

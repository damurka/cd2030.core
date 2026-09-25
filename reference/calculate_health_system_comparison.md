# Compare Health System Metrics Across Levels

Returns a merged dataset of health coverage and system metrics at
district and admin level 1 for the latest year.

## Usage

``` r
calculate_health_system_comparison(
  .data,
  sbr = 0.02,
  nmr = 0.025,
  pnmr = 0.024,
  anc1survey = 0.98,
  dpt1survey = 0.97,
  survey_year = 2019,
  twin = 0.015,
  preg_loss = 0.03
)
```

## Arguments

- .data:

  A data frame containing raw health system inputs including year,
  population, coverage, and facility indicators.

- sbr:

  Numeric. The stillbirth rate (default: 0.02).

- nmr:

  Numeric. The neonatal mortality rate (default: 0.025).

- pnmr:

  Numeric. The post-neonatal mortality rate (default: 0.024).

- anc1survey:

  Numeric. Survey-based ANC-1 coverage rate (default: 0.98).

- dpt1survey:

  Numeric. Survey-based Penta-1 coverage rate (default: 0.97).

- survey_year:

  Integer. The year of Penta-1 survey provided

- twin:

  Numeric. The twin birth rate (default: 0.015).

- preg_loss:

  Numeric. The pregnancy loss rate (default: 0.03).

## Value

A data frame with admin 1 and district metrics joined side by side for
comparison.

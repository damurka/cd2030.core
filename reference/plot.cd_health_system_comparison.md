# Compare District vs Admin 1 Health Metrics

Generates scatterplots with linear fit and identity line comparing
district to admin 1 metrics or coverage vs density.

## Usage

``` r
# S3 method for class 'cd_health_system_comparison'
plot(
  x,
  indicator = c("cov_instdeliveries_hstaff", "ratio_opd_u5_hstaff", "ratio_ipd_u5_hos",
    "ratio_ipd_u5_bed"),
  denominator = NULL
)
```

## Arguments

- x:

  A data frame from
  [`calculate_health_system_comparison()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/calculate_health_system_comparison.md).

- indicator:

  One of ratio\_\* or cov_instdeliveries\_\* (requires `denominator`).

- denominator:

  Optional for cov\_ indicators. Must be one of 'dhis2', 'anc1',
  'penta1'.

## Value

A ggplot object.

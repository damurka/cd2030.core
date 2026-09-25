# Analyze Subnational Health Coverage Data with Inequality Metrics

`calculate_inequality` computes subnational health coverage metrics and
evaluates disparities compared to national averages. The function
provides metrics such as:

## Usage

``` r
calculate_inequality(
  .data,
  admin_level = c("adminlevel_1", "district"),
  un_estimates,
  region = NULL,
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

  A data frame containing subnational health coverage data.

- admin_level:

  A character string specifying the administrative level for analysis.
  Options: `"adminlevel_1"` (e.g., regions) or `"district"`.

- un_estimates:

  (Optional) A data frame with UN population estimates for national
  population-level calculations. Required if using population-based
  metrics.

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

A tibble (`cd_inequality` object) containing:

- Subnational health coverage metrics.

- Population shares.

- MADM, MRDM, and related disparity metrics.

## Details

- **Mean Absolute Difference to the Mean (MADM)**: Average absolute
  deviation from the national mean.

- **Weighted MADM**: MADM weighted by population share.

- **Mean Relative Difference to the Mean (MRDM)**: MADM as a percentage
  of the national mean.

- **Weighted MRDM**: MRDM weighted by population share.

- **Relative Difference Max (RD Max)**: Adjusted maximum difference
  metric.

The function allows analysis of specific health indicators at
subnational levels (`adminlevel_1` or `district`) and compares them with
national-level data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example analysis for district-level data
inequality_metrics <- calculate_inequality(
  .data = health_data,
  admin_level = "district",
  un_estimates = un_data
)
} # }
```

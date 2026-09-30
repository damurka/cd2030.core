# Compare Health System Metrics Across Levels

Returns a merged dataset of health coverage and system metrics at
district and admin level 1 for the latest year.

## Usage

``` r
calculate_health_system_comparison(
  .data,
  admin1_coverage_data,
  admin2_coverage_data
)
```

## Arguments

- .data:

  A `cd_data` object containing raw health system inputs including year,
  population, and facility indicators.

- admin1_coverage_data:

  A coverage data frame at admin level 1 (with `year`, `adminlevel_1`
  and `cov_*` columns), such as the output of
  [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)
  for `admin_level = "adminlevel_1"`. Its latest year defines the year
  kept in the result.

- admin2_coverage_data:

  A coverage data frame at district level (with `year`, `adminlevel_1`,
  `district` and `cov_*` columns), such as the output of
  [`calculate_indicator_coverage()`](calculate_indicator_coverage.md)
  for `admin_level = "district"`.

## Value

A data frame with admin 1 and district metrics joined side by side for
comparison.

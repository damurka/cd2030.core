# Generate Coverage Data with Derived Denominators

Calculates trend-adjusted and subnationally-redistributed coverage
estimates using the DTP1-derived denominator logic described in CD2030.
It estimates coverage over time based on changes in DHIS2 population
counts, while preserving subnational proportions from the base year.

## Usage

``` r
calculate_derived_coverage(.data, indicator, base_year, region = NULL)
```

## Arguments

- .data:

  A `cd_population_metrics` object containing indicator values and DHIS2
  population.

- indicator:

  A character string specifying the indicator to calculate coverage for.

- base_year:

  Integer. The year from which denominator proportions are derived.

## Value

A `cd_derived_coverage` tibble with columns for old and new coverage
estimates.

## Details

This allows estimating:

- Trends over time in coverage

- Subnational inequities

## Examples

``` r
calculate_derived_coverage(dhis_data, "penta1", 2019)
#> Error in calculate_derived_coverage(dhis_data, "penta1", 2019): unused argument (2019)
```

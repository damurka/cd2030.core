# Generate Coverage Data with Derived Denominators

Calculates trend-adjusted and subnationally-redistributed coverage
estimates using the DTP1-derived denominator logic described in CD2030.
It estimates coverage over time based on changes in DHIS2 population
counts, while preserving subnational proportions from the base year.

## Usage

``` r
calculate_derived_coverage(.data, indicator)
```

## Arguments

- .data:

  A `cd_population_metrics` object containing indicator values and DHIS2
  population.

- indicator:

  A character string specifying the indicator to calculate coverage for.

## Value

A `cd_derived_coverage` tibble with columns for old and new coverage
estimates.

## Details

This allows estimating:

- Trends over time in coverage

- Subnational inequities

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_derived_coverage(population_metrics, "penta1")
} # }
```

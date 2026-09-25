# Filter Subnational Inequality Metrics

`filter_inequality` refines the output of `calculate_inequality` by
selecting specific indicators and denominators for analysis. It extracts
and renames relevant columns to streamline further analyses.

## Usage

``` r
filter_inequality(
  .data,
  indicator,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived")
)
```

## Arguments

- .data:

  A `cd_inequality` tibble created by `calculate_inequality`.

- indicator:

  A character vector of health indicators to include (e.g., `"penta3"`,
  `"measles1"`).

- denominator:

  A character vector of denominators to filter by (e.g., `"dhis2"`,
  `"anc1"`).

- ...:

  Not used

## Value

A tibble containing filtered subnational inequality metrics for the
specified indicators and denominators.

## Examples

``` r
if (FALSE) { # \dontrun{
# Filter for Penta-3 coverage using DHIS-2 denominator
filtered_data <- inequality_metrics %>%
  filter_inequality(indicator = "penta3", denominator = "dhis2")
} # }
```

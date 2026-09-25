# District-Level Completeness Summary

Calculates yearly % of districts with complete data for each indicator.

## Usage

``` r
calculate_district_completeness_summary(.data, region = NULL)
```

## Arguments

- .data:

  A `cd_data` object.

## Value

A `cd_district_completeness_summary` tibble:

- One row per year

- `% non-missing` per indicator

- `mean_mis_all`, `mean_mis_four` summaries

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_district_completeness_summary(data)
} # }
```

# District-Level Outlier Summary by Year

Calculates the yearly percentage of districts without extreme outliers
for each health indicator. Flags are based on the Hampel X84 method
(beyond 5 MAD from median).

## Usage

``` r
calculate_district_outlier_summary(.data, region = NULL)
```

## Arguments

- .data:

  A `cd_data` object with outlier flags (`_outlier5std` columns).

- region:

  Optional. Filter results to a specific `adminlevel_1`.

## Value

A `cd_district_outliers_summary` tibble.

## Details

- Aggregates by `district` and `year`, using the max flag per group.

- Computes percent of non-outliers per indicator.

- Returns yearly summaries including:

  - Per-indicator non-outlier rates

  - `mean_out_all`: all indicators

  - `mean_out_four`: excludes IPD

All results are rounded to two decimals.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_district_outlier_summary(data)
} # }
```

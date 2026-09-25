# Summarize Data Completeness by Year

Computes yearly percentage of non-missing values for each indicator,
along with overall completeness summaries.

## Usage

``` r
calculate_completeness_summary(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  region = NULL
)
```

## Arguments

- .data:

  A `cd_data` object.

- admin_level:

  One of `'national'`, `'adminlevel_1'`, or `'district'`.

## Value

A `cd_completeness_summary` tibble:

- One row per year and group

- `mis_<indicator>` columns with % non-missing values

- `mean_mis_all` summarizing all indicators

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_completeness_summary(data)
} # }
```

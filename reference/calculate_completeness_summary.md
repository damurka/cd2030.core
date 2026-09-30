# Summarize Data Completeness by Year

Computes yearly percentage of non-missing values for each indicator,
along with overall completeness summaries.

## Usage

``` r
calculate_completeness_summary(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  threshold = .cd_method$data_quality$reporting_threshold,
  region = NULL
)
```

## Arguments

- .data:

  A `cd_data` object.

- admin_level:

  One of `'national'`, `'adminlevel_1'`, or `'district'`.

- threshold:

  Integer. Completeness threshold (in percent) stored as an attribute on
  the result and used when plotting. Default is `90`.

- region:

  Optional name of an `adminlevel_1` region. If supplied, only that
  region's rows are kept and results are shown by district. Only valid
  with `admin_level = 'adminlevel_1'`. Default is `NULL`.

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

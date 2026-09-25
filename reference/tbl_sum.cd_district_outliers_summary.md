# Summary for `cd_district_outliers_summary`

Provides a summary for the `cd_district_outliers_summary` object,
indicating the percentage of districts without extreme outliers for each
indicator by year. This summary supports monitoring data quality across
districts by showing the proportion of non-extreme values across all
indicators.

## Usage

``` r
# S3 method for class 'cd_district_outliers_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_outliers_summary` object containing the percentage of
  districts without extreme outliers for each indicator and year.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector describing the purpose and content of the data,
highlighting the percentage of districts with no extreme outliers for
each indicator annually.

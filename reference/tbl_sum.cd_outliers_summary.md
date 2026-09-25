# Summary for `cd_outliers_summary`

Provides a custom summary for the `cd_outliers_summary` object,
displaying the percentage of monthly indicator values not considered
extreme outliers, aggregated by year. This summary is essential for
assessing data quality and trends across indicators.

## Usage

``` r
# S3 method for class 'cd_outliers_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_outliers_summary` object containing aggregated data quality
  metrics for monthly values.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector summarizing the content and purpose of the data,
indicating the proportion of values meeting the criteria for
non-outliers by year.

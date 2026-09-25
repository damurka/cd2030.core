# Summary for `cd_completeness_summary`

This function provides a custom summary for `cd_completeness_summary`
objects, offering an overview of the percentage of data completeness
(non-missing values) for each indicator, aggregated by year. The summary
output helps users quickly identify data completeness trends across
indicators and time points, giving insight into potential gaps in data
collection.

## Usage

``` r
# S3 method for class 'cd_completeness_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_completeness_summary` object containing yearly data completeness
  metrics.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector that summarizes the data content and purpose,
specifically indicating the proportion of values that are complete
across years.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate a summary of data completeness by year
tbl_sum(cd_completeness_summary_object)
} # }
```

# Summary for `cd_completeness_summary`

Provides the header shown when a `cd_completeness_summary` object is
printed. It labels the table as the percentage of monthly values with
complete (non-missing) data, by year, ahead of the usual tibble header.

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

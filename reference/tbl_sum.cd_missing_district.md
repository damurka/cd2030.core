# Summary for `cd_missing_district`

Provides a custom summary for the `cd_missing_district` object, showing
the percentage of districts with complete (non-missing) data aggregated
by year. This summary helps users understand the distribution of data
completeness at the district level across time.

## Usage

``` r
# S3 method for class 'cd_missing_district'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_missing_district` object containing yearly district-level data
  completeness metrics.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector that summarizes the data content and purpose,
indicating the percentage of districts with complete data across years.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate a summary of district-level data completeness by year
tbl_sum(calculate_district_completeness_summary(data))
} # }
```

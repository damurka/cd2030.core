# Summary for `cd_district_completeness_summary`

Provides a custom summary for the `cd_district_completeness_summary`
object, showing the percentage of districts with complete (non-missing)
data aggregated by year. This summary helps users understand the
distribution of data completeness at the district level across time.

## Usage

``` r
# S3 method for class 'cd_district_completeness_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_completeness_summary` object containing yearly
  district-level data completeness metrics.

- ...:

  Additional arguments for compatibility with S3 methods.

## Value

A character vector that summarizes the data content and purpose,
indicating the percentage of districts with complete data across years.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate a summary of district-level data completeness by year
tbl_sum(cd_district_completeness_summary_object)
} # }
```

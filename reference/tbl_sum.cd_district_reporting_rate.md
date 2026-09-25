# Summary for District-Level Reporting Rates by Year

Provides a custom summary for the `cd_district_reporting_rate` object,
displaying a message with the threshold used in calculating
district-level reporting rates by year. This summary serves to validate
which districts meet the defined threshold for reporting completeness.

## Usage

``` r
# S3 method for class 'cd_district_reporting_rate'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_reporting_rate` object containing district-level
  reporting rates.

- ...:

  Additional arguments for compatibility with the S3 method.

## Value

A character vector describing the reporting threshold applied and
summarizing district reporting rates by year.

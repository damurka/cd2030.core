# Summarize National Denominators Data

Provides a filtered summary of the `cd_national_denominators` object,
displaying total population and live birth data from DHIS-2 and UN
sources for the selected country.

## Usage

``` r
# S3 method for class 'cd_national_denominators'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_national_denominators` object containing national-level
  demographic data.

- ...:

  Additional arguments (not used in this function).

## Value

A character vector summarizing the table's title, country, and key
demographic columns.

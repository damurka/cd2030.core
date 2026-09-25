# Summary for `cd_district_ratios_summary` Object

Provides a customized summary for a `cd_district_ratios_summary` object,
which includes the percentage of districts meeting the adequacy criteria
(e.g., ratios within the range of 1.0 to 1.5) across specified indicator
pairs by year. This summary aids in monitoring health indicator
alignment at a district level over time.

## Usage

``` r
# S3 method for class 'cd_district_ratios_summary'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_district_ratios_summary` object, typically created by the
  `calculate_district_ratios_summary` function, containing adequacy
  checks for district-level indicator ratios by year.

- ...:

  Additional arguments to support S3 method compatibility.

## Value

A character vector providing a descriptive title indicating the
percentage of districts with indicator ratios that meet adequacy
criteria, aiding in data quality interpretation.

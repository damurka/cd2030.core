# District-Level Reporting Rates by Year

`calculate_district_reporting_rate` Calculates the percentage of
districts that meet or exceed a specified reporting rate threshold for
each indicator, by year. Also computes a yearly average across all
indicators.

## Usage

``` r
calculate_district_reporting_rate(.data, threshold = 90, region = NULL)
```

## Arguments

- .data:

  A tibble of class `cd_data`.

- threshold:

  Minimum reporting rate (%) for a district to be considered compliant.
  Default is 90.

- region:

  Optional. Filter results for a specific region (admin level 1 name).

## Value

A tibble of class `cd_district_reporting_rate`.

## Examples

``` r
if (FALSE) { # \dontrun{
  calculate_district_reporting_rate(data, threshold = 90)
  calculate_district_reporting_rate(data, threshold = 85, region = "Eastern")
} # }
```

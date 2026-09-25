# Reporting Rate Summary by Administrative Level

`calculate_average_reporting_rate()` computes the average reporting rate
for each indicator by year and administrative level. For `adminlevel_1`,
you can limit the results to a single region.

## Usage

``` r
calculate_average_reporting_rate(
  .data,
  admin_level = c("national", "adminlevel_1", "district"),
  region = NULL
)
```

## Arguments

- .data:

  A tibble of class `cd_data`.

- admin_level:

  Character. One of `"national"`, `"adminlevel_1"`, or `"district"`.

- region:

  Optional. Name of a specific region (`adminlevel_1`) to filter
  results. Only used when `admin_level = "adminlevel_1"`.

## Value

A tibble of class `cd_average_reporting_rate`.

## Examples

``` r
if (FALSE) { # \dontrun{
calculate_average_reporting_rate(data, admin_level = "adminlevel_1")
calculate_average_reporting_rate(data, admin_level = "adminlevel_1", region = "Nairobi")
} # }
```

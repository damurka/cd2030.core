# Plot Derived vs Traditional Coverage Over Time

This function generates a line plot comparing traditional
(`coverage_old`) and derived (`coverage_new`) coverage estimates over
time for a single indicator. It supports both national and subnational
views.

## Usage

``` r
# S3 method for class 'cd_derived_coverage'
plot(x, region = NULL, ...)
```

## Arguments

- x:

  A `cd_coverage_trends` object returned by `generate_coverage_data()`.

- region:

  (Optional) A region or district name. Required for subnational data,
  must be `NULL` for national data.

- ...:

  Additional arguments passed to `ggplot2` layers (not used).

## Value

A ggplot object showing coverage trends.

## Details

The plot title and y-axis labels are automatically generated from the
indicator metadata stored in the input object attributes.

## Examples

``` r
if (FALSE) { # \dontrun{
generate_coverage_data(dhis_data, "penta1", 2019) %>%
  plot(region = "Nairobi")

generate_coverage_data(dhis_data, "rota1", 2019) %>%
  plot()
} # }
```

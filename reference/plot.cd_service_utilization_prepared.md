# Plot Filtered Service Utilization Indicators

Generates a faceted map of service utilization metrics across
subnational units (admin level 1) for each available year. Uses spatial
polygons filled by the selected indicator.

## Usage

``` r
# S3 method for class 'cd_service_utilization_prepared'
plot(x, labels = NULL, ..., options = NULL)
```

## Arguments

- x:

  A `cd_service_utilization_prepared` object returned by
  [`prepare_mapping_service_utlization()`](prepare_mapping_service_utlization.md).

- labels:

  (Optional) A named list to override the default English text, e.g.
  with translations. Valid keys: `title` and `legend` (the legend
  title). Defaults to `NULL`.

- ...:

  Additional arguments (currently unused).

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `ggplot2` object representing faceted service utilization maps by
year.

## Details

This function:

- Extracts the appropriate indicator (`ratio_opd_u5_pop` or
  `ratio_ipd_u5_pop`)

- Projects the data to WGS84 for map consistency

- Renders the spatial data using `geom_sf()` with a sequential purple
  color scale

- Facets by year and applies the package's custom plot theme

## Examples

``` r
if (FALSE) { # \dontrun{
plot(filtered)
} # }
```

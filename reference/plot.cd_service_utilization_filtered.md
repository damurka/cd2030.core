# Plot Filtered Service Utilization Indicators

Generates a faceted map of service utilization metrics across
subnational units (admin level 1) for each available year. Uses spatial
polygons filled by the selected indicator.

## Usage

``` r
# S3 method for class 'cd_service_utilization_filtered'
plot(x, ...)
```

## Arguments

- x:

  A `cd_service_utilization_filtered` object returned by
  [`filter_service_utilization()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_service_utilization.md).

- ...:

  Additional arguments (currently unused).

## Value

A `ggplot2` object representing faceted service utilization maps by
year.

## Details

This function:

- Extracts the appropriate indicator (`mean_opd_under5` or
  `mean_ipd_under5`)

- Projects the data to WGS84 for map consistency

- Renders the spatial data using `geom_sf()` with a sequential purple
  color scale

- Facets by year and applies the package's custom plot theme

## Examples

``` r
if (FALSE) { # \dontrun{
filtered <- filter_service_utilization(service_data, "UGA", indicator = "opd", plot_years = 2019:2022)
plot(filtered)
} # }
```

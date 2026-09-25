# Filter and Prepare Service Utilization Data for Mapping

Filters a `cd_service_utilization` object by country, indicator, and
year. Joins spatial data for subnational mapping and renames geometry
for use with
[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).

## Usage

``` r
filter_service_utilization(
  .data,
  country_iso,
  indicator = c("ipd", "opd"),
  plot_years = NULL,
  subnational_map = NULL
)
```

## Arguments

- .data:

  A `cd_service_utilization` object returned by
  [`compute_service_utilization()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/compute_service_utilization.md).

- country_iso:

  Character. ISO3 country code.

- indicator:

  Character. Service indicator to map, either `"ipd"` or `"opd"`.
  Defaults to `"ipd"`.

- plot_years:

  Optional. Integer or vector of years to include.

- subnational_map:

  Optional. A mapping data frame to link `NAME_1` from the shapefile to
  internal admin labels.

## Value

A tibble of class `cd_service_utilization_filtered`, ready for faceted
spatial plotting.

## Details

This function:

- Selects the under-five service indicator (`mean_opd_under5` or
  `mean_ipd_under5`)

- Joins the appropriate admin level 1 shapefile using the specified
  country ISO

- Filters to specified `plot_years` if provided

- Renames the geometry column for compatibility with `geom_sf()`

Only `adminlevel_1` data is currently supported for mapping.

## Examples

``` r
if (FALSE) { # \dontrun{
filtered <- filter_service_utilization(service_data, "UGA", indicator = "opd", plot_years = 2019:2022)
plot(filtered)
} # }
```

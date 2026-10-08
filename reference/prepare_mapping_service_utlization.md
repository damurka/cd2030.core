# Filter and Prepare Service Utilization Data for Mapping

Filters a `cd_service_utilization` object by country, indicator, and
year. Joins spatial data for subnational mapping and renames geometry
for use with
[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).

## Usage

``` r
prepare_mapping_service_utlization(
  .data,
  indicator = c("ipd", "opd"),
  plot_years = NULL,
  subnational_map = NULL,
  palette = c("Purples", "Blues", "Greens", "Reds", "YlGnBu")
)
```

## Arguments

- .data:

  A `cd_service_utilization` object returned by
  [`compute_service_utilization()`](compute_service_utilization.md).

- indicator:

  Character. Service indicator to map, either `"ipd"` or `"opd"`.
  Defaults to `"ipd"`.

- plot_years:

  Optional. Integer or vector of years to include.

- subnational_map:

  Optional. A mapping data frame to link `NAME_1` from the shapefile to
  internal admin labels.

- palette:

  Character. RColorBrewer palette name stored on the result for the map
  fill: one of `"Purples"` (default), `"Blues"`, `"Greens"`, `"Reds"` or
  `"YlGnBu"`.

## Value

A tibble of class `cd_service_utilization_prepared`, ready for faceted
spatial plotting.

## Details

This function:

- Selects the under-five service indicator (`ratio_ipd_u5_pop` or
  `ratio_opd_u5_pop`)

- Joins the appropriate admin level 1 shapefile using the specified
  country ISO

- Filters to specified `plot_years` if provided

- Renames the geometry column for compatibility with
  [`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)

Only `adminlevel_1` data is currently supported for mapping.

## Examples

``` r
if (FALSE) { # \dontrun{
prepare_service_utlization_mapping(service_data, "UGA", indicator = "opd", plot_years = 2019:2022)
} # }
```

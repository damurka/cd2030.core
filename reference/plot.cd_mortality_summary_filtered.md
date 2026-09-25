# Plot Filtered Institutional Mortality Rates

Visualizes institutional mortality rates (`MMR` or `SBR`) across regions
using filled geographic polygons. Facets the map by year and applies a
color gradient by value.

## Usage

``` r
# S3 method for class 'cd_mortality_summary_filtered'
plot(x, ...)
```

## Arguments

- x:

  A `cd_mortality_summary_filtered` object returned by
  `filter_mortality_rate()`.

- ...:

  Additional arguments (not used).

## Value

A `ggplot2` object. This function is called for its side effect of
rendering a map.

## Details

The function:

- Determines the appropriate plot title and legend based on the
  `indicator` attribute

- Projects the geometry to WGS84 for consistent map rendering

- Facets by year and uses `geom_sf()` to draw filled polygons

- Applies a sequential `Reds` color scale with gray for missing values

## Examples

``` r
if (FALSE) { # \dontrun{
filtered <- filter_mortality_summary(mortality_data, "UGA", indicator = "mmr", plot_year = 2020:2022)
plot(filtered)
} # }
```

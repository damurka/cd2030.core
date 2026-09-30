# Plot Filtered Institutional Mortality Rates

Visualizes institutional mortality rates (`MMR` or `SBR`) across regions
using filled geographic polygons. Facets the map by year and applies a
color gradient by value.

## Usage

``` r
# S3 method for class 'cd_mortality_summary_filtered'
plot(x, labels = NULL, ..., options = NULL)
```

## Arguments

- x:

  A `cd_mortality_summary_filtered` object.

- labels:

  (Optional) A named list to override the default English text, e.g.
  with translations. Valid keys: `title` and `legend` (the legend
  title). Defaults to `NULL`.

- ...:

  Additional arguments (not used).

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

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
filtered <- filter_mortality_summary(mortality_data, "UGA", indicator = "mmr",
                                     plot_year = 2020:2022)
plot(filtered)
} # }
```

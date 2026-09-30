# Plot Subnational Coverage Maps by Indicator

Creates a faceted `ggplot2` map showing subnational coverage levels of a
health indicator, colored using a gradient palette. Coverage values are
drawn from a `cd_mapping_filtered` object, typically filtered for a
specific indicator and denominator.

## Usage

``` r
# S3 method for class 'cd_mapping_filtered'
plot(x, title = NULL, caption = NULL, legend = NULL, ..., options = NULL)
```

## Arguments

- x:

  A `cd_mapping_filtered` object. Created using
  [`filter_mapping_data()`](filter_mapping_data.md), and must include
  spatial geometry and metadata attributes (`indicator`, `palette`,
  `column`).

- title:

  (Optional) A scalar character string to override the default plot
  title. Defaults to `NULL`.

- caption:

  (Optional) A scalar character string to override the default plot
  caption. Defaults to `NULL`.

- legend:

  (Optional) A scalar character string to override the default legend
  title. Defaults to `NULL`.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html));
  other arguments are ignored.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes the user changed. Applied last,
  so it wins over `title` and the other arguments above. Any chart
  option can also be given by name in `...`.

## Value

A `ggplot` object visualizing the spatial distribution of the selected
indicator by region and year.

## See also

[`filter_mapping_data()`](filter_mapping_data.md),
[`get_mapping_data()`](get_mapping_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming `map_data` is filtered with filter_mapping_data()
plot(
  map_data,
  title = "Penta 1 Coverage by Region",
  legend = "Coverage (%)",
  caption = "Source: DHIS2 2024"
)
} # }
```

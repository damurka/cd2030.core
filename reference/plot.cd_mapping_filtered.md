# Plot Subnational Coverage Maps by Indicator

Creates a faceted `ggplot2` map showing subnational coverage levels of a
health indicator, colored using a gradient palette. Coverage values are
drawn from a `cd_mapping_filtered` object, typically filtered for a
specific indicator and denominator.

## Usage

``` r
# S3 method for class 'cd_mapping_filtered'
plot(x, ...)
```

## Arguments

- x:

  A `cd_mapping_filtered` object. Created using
  [`filter_mapping_data()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_mapping_data.md),
  and must include spatial geometry and metadata attributes
  (`indicator`, `palette`, `column`).

- ...:

  Additional arguments (currently unused).

## Value

A `ggplot` object visualizing the spatial distribution of the selected
indicator by region and year.

## See also

[`filter_mapping_data()`](https://aphrcwaro.github.io/cd2030.core/reference/filter_mapping_data.md),
[`get_mapping_data()`](https://aphrcwaro.github.io/cd2030.core/reference/get_mapping_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming `map_data` is filtered with filter_mapping_data()
plot(map_data)
} # }
```

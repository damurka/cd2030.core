# Filter Mapping Data for Specific Indicator and Denominator

Extracts and filters indicator coverage data by year, denominator type,
and color palette for visualization.

## Usage

``` r
filter_mapping_data(
  .data,
  indicator,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived"),
  palette = c("Reds", "Blues", "Greens", "Purples", "YlGnBu"),
  plot_year = NULL
)
```

## Arguments

- .data:

  A `cd_mapping` object returned by
  [`get_mapping_data()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/get_mapping_data.md).

- indicator:

  Character. Indicator name (e.g., `"anc4"`, `"penta1"`).

- denominator:

  Character. One of: `"dhis2"`, `"anc1"`, `"penta1"`, `"penta1derived"`.

- palette:

  Character. Color palette for mapping. One of: `"Reds"`, `"Blues"`,
  `"Greens"`, `"Purples"`, `"YlGnBu"`.

- plot_year:

  Optional integer or vector of years to filter.

## Value

A `tibble` of class `"cd_mapping_filtered"`.

## Examples

``` r
if (FALSE) { # \dontrun{
filtered <- filter_mapping_data(
  data, indicator = "anc4", denominator = "anc1", palette = "Blues", plot_year = 2021
)
} # }
```

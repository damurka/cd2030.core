# Filter one indicator’s adjustment values

Keeps `year` and the two columns for a single indicator’s raw and
adjusted values, e.g. `anc1_raw` and `anc1_adj`.

## Usage

``` r
filter_adjustment_value(.data, indicator)
```

## Arguments

- .data:

  A tibble of class `cd_adjustment_values`.

- indicator:

  A single indicator name. Must be one of
  [`get_all_indicators()`](https://aphrcwaro.github.io/cd2030.core/reference/get_all_indicators.md).

## Value

A tibble with class `cd_adjustment_values_filtered` containing:

- `year`

- `<indicator>_raw`

- `<indicator>_adj`

The result carries an attribute `indicator` with the selected indicator.

## Examples

``` r
if (FALSE) { # \dontrun{
x <- filter_adjustment_value(adj_values, "anc1")
attr(x, "indicator")   # "anc1"
} # }
```

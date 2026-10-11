# Functions under their former names

The functions that take one indicator out of a computed table, ready to
plot, were named `filter_*()`. They are `select_*()` now (they choose an
indicator and reshape; they do not filter rows as
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
does). The former names still work and say once per session what to call
instead; they will be removed in a later version.

## Usage

``` r
filter_adjustment_value(...)

filter_coverage(...)

filter_inequality(...)

filter_mapping_data(...)

filter_mortality_summary(...)

filter_service_utilization(...)
```

## Arguments

- ...:

  Passed to the function under its present name.

## Value

What the function under its present name returns.

## Details

|  |  |
|----|----|
| Former name | Now |
| `filter_adjustment_value()` | [`select_adjustment_value()`](select_adjustment_value.md) |
| `filter_coverage()` | [`select_coverage()`](select_coverage.md) |
| `filter_inequality()` | [`select_inequality()`](select_inequality.md) |
| `filter_mapping_data()` | [`select_mapping_data()`](select_mapping_data.md) |
| `filter_mortality_summary()` | [`select_mortality_summary()`](select_mortality_summary.md) |
| `filter_service_utilization()` | [`select_service_utilization()`](select_service_utilization.md) |

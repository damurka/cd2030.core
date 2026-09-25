# Plot Coverage by Denominator Source with Survey Reference

Generates a bar plot comparing DHIS2-based coverage using various
denominator sources against national survey coverage.

## Usage

``` r
# S3 method for class 'cd_indicator_coverage_filtered'
plot(x, ...)
```

## Arguments

- x:

  A data frame of class `'cd_indicator_coverage_filtered'` as returned
  by
  [`filter_indicator_coverage()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/filter_indicator_coverage.md).

- ...:

  Additional arguments (not used).

## Value

A `ggplot2` object showing coverage by denominator type and national
survey line.

## Details

The function visualizes discrepancies in coverage estimates derived from
different denominators: DHIS2 population, ANC1, Penta1, UN projections,
and optionally others. The horizontal line indicates national survey
coverage for the selected year, aiding in identifying possible under- or
over-estimation.

## See also

[`filter_indicator_coverage()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/filter_indicator_coverage.md)

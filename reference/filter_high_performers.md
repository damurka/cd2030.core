# Filter High-Performing Areas by Coverage

Filters a dataset to retain administrative areas with coverage values
above a specified threshold for a given indicator and denominator.

## Usage

``` r
filter_high_performers(
  .data,
  indicator,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
  threshold = 90
)
```

## Arguments

- .data:

  An object of class `cd_indicator_coverage`.

- indicator:

  A string specifying the indicator.

- denominator:

  A string. The denominator used in coverage calculation.

- threshold:

  Numeric. Minimum coverage (in percent, compared after rounding) an
  area must reach to be kept. Default is `90`.

## Value

A filtered data frame retaining regions meeting the threshold.

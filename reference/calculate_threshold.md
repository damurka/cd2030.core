# Calculate Coverage/Dropout Threshold Attainment

Evaluates administrative regions to determine the percentage that meet
specific coverage targets or fall below specific dropout thresholds for
a given year.

## Usage

``` r
calculate_threshold(
  .data,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived", "anc1derived"),
  indicator = c("anc4", "instlivebirths", "vaccine", "dropout")
)
```

## Arguments

- .data:

  A tibble of class `cd_indicator_coverage`.

- denominator:

  Character. The denominator used (e.g., `'dhis2'`, `'anc1'`).

- indicator:

  Character. The health indicator group to evaluate (`'anc4'`,
  `'ideliv'`, `'vaccine'`, `'dropout'`).

## Value

A `cd_threshold` object summarizing the percentage of regions meeting
the criteria by year.

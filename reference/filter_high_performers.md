# Filter High-Performing Areas by Coverage

Filters a dataset to retain administrative areas with coverage values
above a specified threshold for a given indicator and denominator.

## Usage

``` r
filter_high_performers(
  .data,
  indicator,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived"),
  threshold = 90
)
```

## Arguments

- .data:

  An object of class `cd_indicator_coverage`.

- indicator:

  A string specifying the indicator.

- denominator:

  A string. The denominator used in coverage calculation. One of:
  `"dhis2"`, `"anc1"`, `"penta1"`, `"penta1derived"`.

- threshold:

  A numeric threshold for filtering. Default is `90`.

## Value

A filtered data frame with the following columns: `adminlevel_1`,
`district`, `year`, and the selected coverage column.

## Examples

``` r
if (FALSE) { # \dontrun{
filter_high_performers(
  .data = survey_data,
  indicator = "penta3",
  denominator = "penta1",
  threshold = 85
)
} # }
```

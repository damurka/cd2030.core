# Calculate Dropout Coverage for Health Indicators Below a Threshold

This function filters health indicator data to identify the percentage
of administrative regions where the coverage for a specified indicator
falls below a 10% threshold for a given year. If no regions meet the
criteria (i.e., all values are below the threshold), a default output is
returned.

## Usage

``` r
calculate_threshold(
  .data,
  denominator = c("dhis2", "anc1", "penta1", "penta1derived"),
  indicator = c("anc4", "instdeliveries", "vaccine")
)
```

## Arguments

- .data:

  A tibble of class `cd_data`.

- indicator:

  Character. The specific health indicator to evaluate. Options are:

  - `"coverage"`:coverage indicators.

  - `"dropout"`: dropout indicators.

- admin_level:

  The level of analysis.

- sbr:

  Numeric. The stillbirth rate. Default is `0.02`.

- nmr:

  Numeric. Neonatal mortality rate. Default is `0.025`.

- pnmr:

  Numeric. Post-neonatal mortality rate. Default is `0.024`.

- anc1survey:

  Numeric. Survey-derived coverage rate for ANC-1 (antenatal care, first
  visit). Default is `0.98`.

- dpt1survey:

  Numeric. Survey-derived coverage rate for Penta-1 (DPT1 vaccination).
  Default is `0.97`.

- survey_year:

  Integer. The year of Penta-1 survey provided

- preg_loss:

  Numeric. Pregnancy loss rate

- twin:

  Numeric. Twin birth rate. Default is `0.015`.

## Value

A tibble with the selected administrative level and coverage value for
regions that do not meet the below-10% threshold for the specified
indicator and year. If no regions meet the criteria, a default row is
returned with "None" and 0 as values.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
result <- calculate_threshold(data, filter_year = 2023, indicator = "zerodose", source = "dhis2")
result
} # }
```

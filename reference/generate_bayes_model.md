# Generate Bayesian Coverage Model Object

Generate Bayesian Coverage Model Object

## Usage

``` r
generate_bayes_model(
  coverage_data,
  overall_score,
  indicator = c("anc4", "anc_1trimester", "ideliv", "measles1", "penta3"),
  denominator = c("anc1", "dhis2", "penta1", "penta1derived", "anc1derived")
)
```

## Arguments

- coverage_data:

  Survey data frame of class 'cd_coverage'.

- overall_score:

  DHIS2 data frame of class 'cd_overall_score'.

- indicator:

  Indicator character code (e.g., 'anc4', 'penta3').

- denominator:

  The denominator type to use from DHIS2 (e.g., 'penta1', 'dhis2').

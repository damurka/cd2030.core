# Generate Bayesian Coverage Model Object

Generate Bayesian Coverage Model Object

## Usage

``` r
generate_bayes_model(
  coverage_data,
  overall_score,
  indicator = c("anc4", "anc_1trimester", "ideliv", "measles1", "penta3"),
  denominator = c("anc1", "dhis2", "penta1", "penta1derived", "anc1derived"),
  keep_samples = FALSE
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

- keep_samples:

  Whether the model keeps the sampler's draws and the compiled Stan
  model (`samples`, `stan_model`). Default `FALSE`: the charts and
  [`bayes_model_estimates()`](bayes_model_estimates.md) read the summary
  of the draws, which is kept either way, and without the draws a model
  is some 30 KB (national) to 170 KB (sub-national) where it was 13 MB
  to 41 MB. A model that size was brought back from the worker that
  fitted it, kept in the dataset and written to its file with every
  later change, each of which held the app up for seconds.

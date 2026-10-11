# Generate Bayesian coverage model object

Fits a Bayesian coverage model for one indicator, combining the survey
estimates and the routine (DHIS2) coverage in `coverage_data` with the
yearly data quality score in `overall_score`. The model is national or
sub-national (admin level 1), following the admin level of
`coverage_data`.

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
  of the draws, which is kept either way, and a model without the draws
  is much smaller (tens to hundreds of KB instead of tens of MB), so it
  is quicker to save and to pass between processes.

## Value

An object of class `cd_bayes_model`: the fitted model returned by
[`bayescoveragedeploy::fit_local_model()`](https://rdrr.io/pkg/bayescoveragedeploy/man/fit_local_model.html)
(a list, with its `posteriors` summary), without `samples` and
`stan_model` unless `keep_samples = TRUE`. It carries the attributes
`indicator`, `model_indicator` (the name the model uses for the
indicator), `iso` and `is_national`.

## Examples

``` r
if (FALSE) { # \dontrun{
# needs the Bayesian model packages (see cd_bayes_packages_missing()); a fit takes minutes
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()

model <- generate_bayes_model(
  coverage_data = cache$calculate_coverage("national"),
  overall_score = cache$overall_score,
  indicator = "penta3",
  denominator = "penta1"
)
bayes_model_estimates(model)
plot(model)
} # }
```

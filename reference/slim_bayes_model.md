# A Bayesian model without the sampler's draws and the compiled Stan model

What makes a fitted model large (`samples`, `stan_model`) and no chart
or table reads: see
[`generate_bayes_model()`](generate_bayes_model.md)'s `keep_samples`. A
model that has neither is returned as it is.

## Usage

``` r
slim_bayes_model(model)
```

## Arguments

- model:

  A fitted model.

## Value

The model without them, its class and attributes kept.

## Examples

``` r
# a stand-in for a model fitted with keep_samples = TRUE
model <- structure(
  list(posteriors = list(), samples = matrix(0, 1000, 50), stan_model = "the compiled model"),
  class = c("cd_bayes_model", "list"),
  indicator = "penta3"
)
slim <- slim_bayes_model(model)
names(slim)
#> [1] "posteriors"
attr(slim, "indicator")
#> [1] "penta3"
object.size(slim) < object.size(model)
#> [1] TRUE
```

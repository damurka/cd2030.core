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

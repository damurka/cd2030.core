# Fit one Bayesian coverage model in a background worker

Hands one fit to a `future` worker and returns at once. The worker runs
[`generate_bayes_model()`](generate_bayes_model.md) on the coverage
data, overall score, indicator and denominator in `inputs`, with
`cd2030.core` attached and a parallel-safe random seed. The Bayesian
page uses this function as the task of its
[`shiny::ExtendedTask`](https://rdrr.io/pkg/shiny/man/ExtendedTask.html).
With the default `sequential` plan the fit runs in the calling process;
see [`cd_start_bayes_workers()`](cd_start_bayes_workers.md).

## Usage

``` r
cd_bayes_fit_task(inputs)
```

## Arguments

- inputs:

  A list with `key`, `coverage_data`, `overall_score`, `indicator` and
  `denominator`, as the dataset's `bayes_model_inputs()` method returns
  ([CacheConnection](CacheConnection.md)).

## Value

A promise of a list with two elements: `key`, which is `inputs$key`
unchanged, and `model`, the fitted model. The key lets the caller keep
the model for the request it was fitted for.

## Examples

``` r
if (FALSE) { # \dontrun{
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()

# one fit, kept in the dataset when it ends (it takes minutes)
inputs <- cache$bayes_model_inputs("national", "penta3")
promises::then(cd_bayes_fit_task(inputs), function(out) cache$keep_bayes_model(out$key, out$model))

# in a Shiny server: the task of an ExtendedTask
fit <- ExtendedTask$new(cd_bayes_fit_task)
fit$invoke(inputs)
} # }
```

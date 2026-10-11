# A Bayesian model's estimates as a table

The fitted coverage by year (2010 to 2030), in percent like the other
coverage tables: the median with its 95% and 80% intervals. A
sub-national model gives a row per region and year.

## Usage

``` r
bayes_model_estimates(model)
```

## Arguments

- model:

  A model from [`generate_bayes_model()`](generate_bayes_model.md).

## Value

A tibble: `indicator`, `adminlevel_1` (a sub-national model only),
`year`, `estimate`, `lower` and `upper` (95%), `lower_80` and
`upper_80`.

## Examples

``` r
if (FALSE) { # \dontrun{
# `cache` is a dataset with adjusted data; fitting needs the Bayesian model packages
model <- cache$get_bayes_model("national", "penta3")
estimates <- bayes_model_estimates(model)
estimates[estimates$year >= 2020, c("year", "estimate", "lower", "upper")]

# a sub-national model has a row per region and year
regions <- bayes_model_estimates(cache$get_bayes_model("adminlevel_1", "penta3"))
regions[regions$year == 2023, ]
} # }
```

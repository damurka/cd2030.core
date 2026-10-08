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

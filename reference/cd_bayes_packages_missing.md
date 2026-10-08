# The Bayesian model's packages that are not installed

Checks without loading them (loading brings in Stan).

## Usage

``` r
cd_bayes_packages_missing()
```

## Value

A character vector: the packages
[`generate_bayes_model()`](generate_bayes_model.md) needs and that are
not installed, empty when the model can run.

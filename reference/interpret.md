# Generic interpretation method

A generic method to extract narrative interpretation from structured
data objects.

## Usage

``` r
interpret(x, ...)
```

## Arguments

- x:

  An object.

- ...:

  Additional arguments passed to methods.

## Value

What the method for the class of `x` returns. The method for
`cd_fpet_data` ([`interpret.cd_fpet_data()`](interpret.cd_fpet_data.md))
returns a character string.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

# the family planning estimates that come with the dataset
interpret(cache$fpet_data)
#> [1] "In Kenya, between 2020 and 2024:\nprevalence: increased by 0.005\ndemand: decreased by 0.005\n\nThe graphs also include FPET projections with credible intervals through 2030."
```

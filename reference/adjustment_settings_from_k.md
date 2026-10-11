# Adjustment settings from the older k-factors and excluded years

A dataset saved before the settings existed has only its k per group and
its removed years: they become the settings, everything else as the
default.

## Usage

``` r
adjustment_settings_from_k(k_factors = NULL, excluded_years = numeric())
```

## Arguments

- k_factors:

  Named numeric k per group.

- excluded_years:

  Numeric years removed.

## Value

The settings list.

## Examples

``` r
settings <- adjustment_settings_from_k(c(anc = 0.1, vacc = 0), excluded_years = 2020)
settings$everywhere$group_k
#> $anc
#> [1] 0.1
#> 
#> $idelv
#> [1] 0.25
#> 
#> $vacc
#> [1] 0
#> 
#> $opd
#> [1] 0.25
#> 
settings$removed_years
#> [1] 2020
```

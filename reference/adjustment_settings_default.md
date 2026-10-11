# The Countdown default adjustment settings

Every indicator group adjusted for completeness with the method's k
(0.25), outliers corrected and missing values filled everywhere, no year
or area removed.

## Usage

``` r
adjustment_settings_default(k = .cd_method$adjustment$k, groups = NULL)
```

## Arguments

- k:

  The k of every group (by default the method's, `0.25`).

- groups:

  The groups that have a k (by default the app's, `cd_cfg("k_factors")`,
  else the method's).

## Value

The settings list (see
[`adjust_service_data()`](adjust_service_data.md)).

## Examples

``` r
settings <- adjustment_settings_default()
str(settings)
#> List of 4
#>  $ removed_years: num(0) 
#>  $ removals     : list()
#>  $ everywhere   :List of 4
#>   ..$ group_k    :List of 4
#>   .. ..$ anc  : num 0.25
#>   .. ..$ idelv: num 0.25
#>   .. ..$ vacc : num 0.25
#>   .. ..$ opd  : num 0.25
#>   ..$ indicator_k: list()
#>   ..$ outliers   : list()
#>   ..$ missing    : list()
#>  $ areas        : list()

# No completeness adjustment for any group
adjustment_settings_default(k = 0)$everywhere$group_k
#> $anc
#> [1] 0
#> 
#> $idelv
#> [1] 0
#> 
#> $vacc
#> [1] 0
#> 
#> $opd
#> [1] 0
#> 
```

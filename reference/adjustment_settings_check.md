# Check and tidy adjustment settings

Validates settings as the Data Adjustment page sends them (JSON read
with `simplifyVector = FALSE`) and returns them in one shape: numbers as
numbers, flags as logicals, empty maps as empty lists, unknown groups,
indicators and levels refused.

## Usage

``` r
adjustment_settings_check(settings)
```

## Arguments

- settings:

  The settings list.

## Value

The settings, tidied. An error says what is wrong.

## Examples

``` r
# Settings as they arrive from JSON: numbers and flags inside lists
settings <- list(
  removed_years = list(2020, 2021),
  everywhere = list(group_k = list(anc = 0.1), outliers = list(penta3 = list(FALSE))),
  areas = list(list(area = "Coast", level = "adminlevel_1", all_missing = list(FALSE)))
)
str(adjustment_settings_check(settings))
#> List of 4
#>  $ removed_years: num [1:2] 2020 2021
#>  $ removals     : list()
#>  $ everywhere   :List of 4
#>   ..$ group_k    :List of 1
#>   .. ..$ anc: num 0.1
#>   ..$ indicator_k: list()
#>   ..$ outliers   :List of 1
#>   .. ..$ penta3: logi FALSE
#>   ..$ missing    : list()
#>  $ areas        :List of 1
#>   ..$ :List of 10
#>   .. ..$ area        : chr "Coast"
#>   .. ..$ level       : chr "adminlevel_1"
#>   .. ..$ region      : NULL
#>   .. ..$ group_k     : list()
#>   .. ..$ indicator_k : list()
#>   .. ..$ outliers    : list()
#>   .. ..$ missing     : list()
#>   .. ..$ all_outliers: NULL
#>   .. ..$ all_missing : logi FALSE
#>   .. ..$ reported    : logi FALSE

# What is wrong is refused with an error
try(adjustment_settings_check(list(everywhere = list(group_k = list(anc = 2)))))
#> Error in kmap(x$group_k, groups, paste(what, "group k"), drop_unknown = TRUE) : 
#>   ✖ A k-factor must be one number between 0 and 1.
```

# Load WUENIC immunization data

Loads and processes WUENIC estimates, computes dropout and zero-dose
indicators, and standardizes naming conventions.

## Usage

``` r
load_wuenic_data(path = NULL, .data = NULL, country_iso)
```

## Arguments

- path:

  Optional. File path to a `.dta` file.

- .data:

  Optional. A preloaded data frame.

- country_iso:

  Character. ISO3 country code.

## Value

A tibble of class `cd_wuenic_data`.

## Examples

``` r
if (FALSE) { # \dontrun{
wuenic <- load_wuenic_data(path = "wuenic.dta", country_iso = "KEN")
wuenic[c("year", "cov_penta3_wuenic", "cov_dropout_penta13_wuenic")]
cache$set_wuenic_estimates(wuenic)
} # }
```

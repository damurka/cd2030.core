# Load WUENIC Immunization Data

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

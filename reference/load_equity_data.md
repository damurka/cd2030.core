# Load and filter equity data

Loads survey equity data, removes unnecessary variables, and filters by
country.

## Usage

``` r
load_equity_data(path = NULL, .data = NULL, country_iso)
```

## Arguments

- path:

  Optional. File path to a `.dta` file.

- .data:

  Optional. A preloaded data frame.

- country_iso:

  Character. ISO3 country code to filter by.

## Value

A tibble of class `cd_equity_data`.

## Examples

``` r
if (FALSE) { # \dontrun{
wealth <- load_equity_data(path = "wiq_data.dta", country_iso = "KEN")
cache$set_wiq_survey(wealth)

# The same for the survey by area of residence and by mother's education
cache$set_area_survey(load_equity_data(path = "area_data.dta", country_iso = "KEN"))
cache$set_education_survey(load_equity_data(path = "meduc_data.dta", country_iso = "KEN"))
} # }
```

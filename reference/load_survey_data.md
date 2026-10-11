# Load and process survey data

Loads national or subnational survey data, cleans labels and codes, and
applies country-specific adjustments for admin-level naming.

## Usage

``` r
load_survey_data(
  path = NULL,
  .data = NULL,
  country_iso,
  admin_level = c("national", "adminlevel_1")
)
```

## Arguments

- path:

  Optional. File path to a `.dta` file.

- .data:

  Optional. A preloaded data frame.

- country_iso:

  Character. Country ISO3 code.

- admin_level:

  Character. One of `'national'` or `'adminlevel_1'`.

## Value

A tibble of class `cd_survey_data`.

## Examples

``` r
if (FALSE) { # \dontrun{
national <- load_survey_data(path = "all_data.dta", country_iso = "KEN")
cache$set_national_survey(national)

# The survey by region
regional <- load_survey_data(
  path = "gregion_data.dta", country_iso = "KEN", admin_level = "adminlevel_1"
)
cache$set_regional_survey(regional)
} # }
```

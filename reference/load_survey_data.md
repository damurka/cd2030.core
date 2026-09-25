# Load and Process Survey Data

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

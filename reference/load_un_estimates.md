# Load UN Estimates

Loads and processes UN estimates from a `.dta` file or in-memory data.
Filters by country and year, renames columns, and assigns a custom
class.

## Usage

``` r
load_un_estimates(path = NULL, .data = NULL, country_iso, start_year, end_year)
```

## Arguments

- path:

  Optional. File path to a `.dta` file.

- .data:

  Optional. A preloaded data frame.

- country_iso:

  Character. ISO3 code of the country.

- start_year, :

  end_year Integers. Year range to include.

## Value

A tibble of class `cd_un_estimates`.

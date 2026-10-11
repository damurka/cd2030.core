# Load UN estimates

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

- start_year, end_year:

  Integers. First and last year (inclusive) to include.

## Value

A tibble of class `cd_un_estimates`.

## Examples

``` r
if (FALSE) { # \dontrun{
un <- load_un_estimates(
  path = "un_estimates.dta", country_iso = "KEN", start_year = 2019, end_year = 2023
)

# From data already read, then kept with the dataset
un <- load_un_estimates(.data = all_un, country_iso = "KEN", start_year = 2019, end_year = 2023)
cache$set_un_estimates(un)
} # }
```

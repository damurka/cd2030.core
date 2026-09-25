# Load and Filter Equity Data

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

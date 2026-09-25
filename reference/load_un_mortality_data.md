# Load and Filter UN Mortality Estimates

Loads UN mortality data from a file path or existing data frame, filters
it by the given country ISO3 code, and returns cleaned mortality data
sorted by year.

## Usage

``` r
load_un_mortality_data(path = NULL, .data = NULL, country_iso)
```

## Arguments

- path:

  Optional. Path to an Excel or CSV file containing UN mortality
  estimates.

- .data:

  Optional. A pre-loaded data frame with UN mortality estimates.

- country_iso:

  Required. A 3-letter ISO country code used to filter the dataset.

## Value

A tibble of class `cd_un_mortality`.

## Examples

``` r
if (FALSE) { # \dontrun{
  load_un_mortality_data("data/un_mortality.csv", country_iso = "KEN")
  load_un_mortality_data(.data = df, country_iso = "UGA")
} # }
```

# Extract Latest Mortality Ratios for UN Comparison

Joins computed national mortality indicators with UN estimates, returns
latest value per indicator.

## Usage

``` r
create_mortality_ratios(.data, mortality_data)
```

## Arguments

- .data:

  The main mortality dataset.

- mortality_data:

  A `cd_un_mortality` object.

## Value

A tibble of class `cd_mortality_ratio` with latest available values and
UN means.

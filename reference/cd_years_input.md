# The years a years chip means

Turns the value of a years chip (see
[`cd_years_sync()`](cd_years_sync.md)) into the years to use. An empty
chip means "all years", and this returns every year for it, so the
result can be saved in the dataset and used to filter data as it is.

## Usage

``` r
cd_years_input(value, all_years)
```

## Arguments

- value:

  The chip's value (`input$years`): a character vector of years, or `""`
  when nothing is chosen. Entries that are empty or not a number are
  dropped.

- all_years:

  What "all years" is: the years in the dataset.

## Value

An integer vector: the years in `value`, or `all_years` (as integers)
when `value` holds no year.

## Examples

``` r
cd_years_input(c("2021", "2023"), all_years = 2019:2023)
#> [1] 2021 2023
cd_years_input("", all_years = 2019:2023)
#> [1] 2019 2020 2021 2022 2023
```

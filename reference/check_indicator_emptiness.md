# Flag indicators that have no data

Finds the indicators of the selected indicator group whose column is
missing in every row of the dataset. An indicator with no data cannot be
analysed.

## Usage

``` r
check_indicator_emptiness(.data)
```

## Arguments

- .data:

  A data frame. The merged dataset, with one column per indicator.

## Value

A character vector of the names of the empty indicators. It has length
zero if there are none.

## Details

Only indicator columns that are present in `.data` are examined. An
indicator whose column is absent is not reported here.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
check_indicator_emptiness(data)
#> [1] "anc_1trimester"

# An indicator that was never reported
data$penta3 <- NA_real_
check_indicator_emptiness(data)
#> [1] "anc_1trimester" "penta3"        
```

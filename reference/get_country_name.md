# Get country name

Reads the name of the country a Countdown dataset is for. The name is
stored with the data when it is loaded.

## Usage

``` r
get_country_name(.data)
```

## Arguments

- .data:

  A `cd_data` object

## Value

The country name as a character string

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

get_country_name(data)
#> [1] "Kenya"
```

# Extract latest mortality ratios for UN comparison

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

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

mortality <- create_mortality_summary(cache$countdown_data)
ratios <- create_mortality_ratios(mortality, cache$un_mortality_estimates)
ratios
#> # A tibble: 6 × 7
#>    year iso3  country indicator values mean_mmr mean_sbr
#>   <dbl> <chr> <chr>   <chr>      <dbl>    <dbl>    <dbl>
#> 1  2023 KEN   Kenya   mmr        441.      90.7     18.0
#> 2  2023 KEN   Kenya   mmr_lb     335.      90.7     18.0
#> 3  2023 KEN   Kenya   mmr_ub     573.      90.7     18.0
#> 4  2023 KEN   Kenya   sbr         16.3     90.7     18.0
#> 5  2023 KEN   Kenya   sbr_lb      15.3     90.7     18.0
#> 6  2023 KEN   Kenya   sbr_ub      17.4     90.7     18.0

# the institutional ratio against the UN estimate, by assumed completeness
summarise_completeness_ratio(ratios, plot_type = "mmr")
#> # A tibble: 4 × 4
#>   ciratio `UN MMR lower bound` `UN MMR best estimate` `UN MMR upper bound`
#>     <dbl>                <dbl>                  <dbl>                <dbl>
#> 1     0.5                 13.6                   10.3                  7.9
#> 2     1                   27.1                   20.6                 15.8
#> 3     1.5                 40.7                   30.9                 23.7
#> 4     2                   54.2                   41.2                 31.7
```

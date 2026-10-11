# Summary for `cd_population_metrics`

The print header of the population table
[`prepare_population_metrics()`](prepare_population_metrics.md) gives:
the population, births and under-ones from DHIS2, beside the UN's at
national level.

## Usage

``` r
# S3 method for class 'cd_population_metrics'
tbl_sum(x, ...)
```

## Arguments

- x:

  A `cd_population_metrics` object.

- ...:

  Additional arguments (not used).

## Value

A character vector: the table's title, the country and the default
header.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()

# the summary is the header printed above the table
cache$denominator_metrics
#> # Table 2a: Total Population and Live Birth by Source
#> # Country:  Kenya
#> # A tibble: 5 × 10
#>   iso3   year un_population totpop_dhis2 un_births totbirths_dhis2
#>   <chr> <dbl>         <dbl>        <dbl>     <dbl>           <dbl>
#> 1 KEN    2019        51203.       52363.     1445.           1719.
#> 2 KEN    2020        52217.       53528.     1451.           1507.
#> 3 KEN    2021        53219.       54699.     1469.           1565.
#> 4 KEN    2022        54252.       55879.     1483.           1618.
#> 5 KEN    2023        55339.       51526.     1500.           1199.
#> # ℹ 4 more variables: totlivebirths_dhis2 <dbl>, un_under1 <dbl>,
#> #   totunder1_dhis2 <dbl>, un_popgrowth <dbl>
```

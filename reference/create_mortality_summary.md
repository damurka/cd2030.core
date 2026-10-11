# Create mortality summary object

Combines national and admin level 1 summaries and formats as a custom
class for plotting.

## Usage

``` r
create_mortality_summary(.data)
```

## Arguments

- .data:

  An object of class `cd_data`.

## Value

A `cd_mortality_summary` tibble.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

mortality <- create_mortality_summary(data)
mortality
#> # A tibble: 45 × 16
#>    adminlevel_1  year instlivebirths total_stillbirth stillbirth_f
#>    <chr>        <int>          <dbl>            <dbl>        <dbl>
#>  1 Rift Valley   2019         250707             5677         3284
#>  2 Rift Valley   2020         261922             5350         2845
#>  3 Rift Valley   2021         275959             5010         2576
#>  4 Rift Valley   2022         278204             4475         2319
#>  5 Rift Valley   2023         289469             4569         2387
#>  6 Western       2019         188258             3233         1603
#>  7 Western       2020         189809             3254         1664
#>  8 Western       2021         193461             3145         1555
#>  9 Western       2022         203239             3109         1510
#> 10 Western       2023         201220             2853         1441
#> # ℹ 35 more rows
#> # ℹ 11 more variables: maternal_deaths <dbl>, neonatal_deaths <dbl>,
#> #   sbr_inst <dbl>, mmr_inst <dbl>, nn_inst <dbl>, pnr_inst <dbl>,
#> #   ratio_md_sb <dbl>, ratio_md_nd <dbl>, fresh_total_sb <dbl>, mmr_low <dbl>,
#> #   sbr_low <dbl>

# the national rates
mortality[mortality$adminlevel_1 == "National", c("year", "mmr_inst", "sbr_inst", "nn_inst")]
#> # A tibble: 5 × 4
#>    year mmr_inst sbr_inst nn_inst
#>   <int>    <dbl>    <dbl>   <dbl>
#> 1  2019     98.7     19.6   10.4 
#> 2  2020     93.3     19.3    9.00
#> 3  2021     93.0     18.2   10.3 
#> 4  2022    121.      16.9   13.1 
#> 5  2023     48.0     15.8    6.51
```

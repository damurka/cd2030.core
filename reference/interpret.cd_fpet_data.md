# Interpret FPET results with emphasis on current estimates

Summarizes 2020 and 2024 estimates, and briefly mentions FPET
projections to 2030.

## Usage

``` r
# S3 method for class 'cd_fpet_data'
interpret(x, ...)
```

## Arguments

- x:

  A `cd_fpet_data` object.

- ...:

  Unused.

## Value

A character string with interpretation summary.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

text <- interpret(cache$fpet_data)
cat(text)
#> In Kenya, between 2020 and 2024:
#> prevalence: increased by 0.005
#> demand: decreased by 0.005
#> 
#> The graphs also include FPET projections with credible intervals through 2030.
```

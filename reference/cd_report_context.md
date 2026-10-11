# The report context of a dataset

What the report builder (datasuite.ui) needs from a Countdown dataset:
its charts and tables drawn in the report's look, the pictures and
templates kept in it, its saved chart options, its fields (country,
coverage values), years, regions and flag. Every report function accepts
the dataset itself too
([`datasuite.ui::as_report_context()`](https://rdrr.io/pkg/datasuite.ui/man/as_report_context.html)).

## Usage

``` r
cd_report_context(cache)
```

## Arguments

- cache:

  A [CacheConnection](CacheConnection.md).

## Value

A report context
([`datasuite.ui::report_context()`](https://rdrr.io/pkg/datasuite.ui/man/report_context.html)).

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

context <- cd_report_context(cache)
context$years()
#> [1] 2019 2020 2021 2022 2023
context$fields(NULL, "en")$country
#> [1] "Kenya"
```

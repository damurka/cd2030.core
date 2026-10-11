# The charts that have saved options

A table of every chart with options saved in a dataset's cache: which
chart (its [`cd_chart_id()`](cd_chart_id.md), or for the screen the
chart's place in the app), whether they are for the screen or for
reports, how many options are set, and the group it belongs to (the
first two parts of its id, e.g. `coverage_filtered.national`). Use it to
see which chart ids a report will pick options up for.

## Usage

``` r
cd_chart_catalog(cache)
```

## Arguments

- cache:

  A [CacheConnection](CacheConnection.md).

## Value

A tibble with `id`, `target` (`"screen"`, `"report"` or `"dataset"`),
`group`, `n_options` and `options` (a one-line summary).

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$set_chart_options("default", cd_chart_options(legend_position = "bottom"))
cache$set_chart_options(
  "report/coverage_filtered.national.penta3",
  cd_chart_options(title = "Penta3 coverage")
)

cd_chart_catalog(cache)
#> # A tibble: 2 × 5
#>   id                                target  group              n_options options
#>   <chr>                             <chr>   <chr>                  <int> <chr>  
#> 1 default                           dataset default                    1 legend…
#> 2 coverage_filtered.national.penta3 report  coverage_filtered…         1 title  
```

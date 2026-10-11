# Tabulate data quality results

Turns the results of
[`run_all_quality_checks()`](run_all_quality_checks.md) into two tables:
a summary with one row per check, and a list with one row per issue
found.

## Usage

``` r
quality_issues_table(results, labels = NULL)
```

## Arguments

- results:

  A named list. What
  [`run_all_quality_checks()`](run_all_quality_checks.md) returns.

- labels:

  An optional named character vector that maps a check's key
  (`names(results)`) to the name to show for it, for example a
  translated name. A check without a label gets a plain English name.

## Value

A list of two tibbles. `summary` has columns `check`, `severity`,
`status` (`"passed"` or `"issue"`) and `issues` (the number of issues).
`issues` has columns `check`, `severity` and `issue`, with one row for
each thing a check found (each district-year, each name, each message)
and nothing shortened.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
results <- run_all_quality_checks(cache)
tables <- quality_issues_table(results)
tables$summary
#> # A tibble: 7 × 4
#>   check                                      severity      status issues
#>   <chr>                                      <chr>         <chr>   <int>
#> 1 District consistency                       blocking      passed      0
#> 2 Months present                             blocking      passed      0
#> 3 Month names                                blocking      passed      0
#> 4 Service data mixed up with population data informational passed      0
#> 5 Empty indicators                           informational issue       1
#> 6 Survey admin names                         mapping       passed      0
#> 7 Shapefile admin names                      mapping       issue       6
tables$issues
#> # A tibble: 7 × 3
#>   check                 severity      issue                                     
#>   <chr>                 <chr>         <chr>                                     
#> 1 Empty indicators      informational anc_1trimester                            
#> 2 Shapefile admin names mapping       name: Central      ; suggestion: Mandera …
#> 3 Shapefile admin names mapping       name: Coast        ; suggestion: Mombasa …
#> 4 Shapefile admin names mapping       name: Eastern      ; suggestion: Makueni …
#> 5 Shapefile admin names mapping       name: North Eastern; suggestion: Tana Riv…
#> 6 Shapefile admin names mapping       name: Rift Valley  ; suggestion: Garissa …
#> 7 Shapefile admin names mapping       name: Western      ; suggestion: West Pok…

# A check under a name of your own
quality_issues_table(results, labels = c(indicator_emptiness = "Indicators without data"))$summary
#> # A tibble: 7 × 4
#>   check                                      severity      status issues
#>   <chr>                                      <chr>         <chr>   <int>
#> 1 District consistency                       blocking      passed      0
#> 2 Months present                             blocking      passed      0
#> 3 Month names                                blocking      passed      0
#> 4 Service data mixed up with population data informational passed      0
#> 5 Indicators without data                    informational issue       1
#> 6 Survey admin names                         mapping       passed      0
#> 7 Shapefile admin names                      mapping       issue       6
```

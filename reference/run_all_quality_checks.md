# Run all data quality checks and report every result

Runs the data quality checks on the data held in a cache and returns the
result of each one, whether it passed or not. It does not stop on a
problem, so a caller can show the whole report.

## Usage

``` r
run_all_quality_checks(cache)
```

## Arguments

- cache:

  A `CacheConnection`, or an object with the same `wizard_parts`,
  `wizard_quality_results` and `countdown_data` fields and
  [`check_survey_admin_names()`](check_survey_admin_names.md) and
  [`check_shapefile_admin_names()`](check_shapefile_admin_names.md)
  methods.

## Value

A named list with one element per check. Each element is a list with:

- `ok`: `TRUE` if the check passed.

- `severity`: `"blocking"` (the caller should not go on until the
  problem is fixed), `"informational"` (shown, but does not block) or
  `"mapping"` (an admin level 1 name with no match in the survey or the
  shapefile; shown, but does not block).

- `detail`: what the check returned, which is `NULL`, a character vector
  or a tibble, depending on the check.

## Details

Which checks run depends on what the cache holds:

- If it holds unmerged sheets (`cache$wizard_parts`), the checks run on
  the separate sheets, so a problem can be traced to the sheet it comes
  from.

- Otherwise, if it holds results saved when the sheets were merged
  (`cache$wizard_quality_results`), those saved results are returned and
  no check is run.

- Otherwise the checks run on the merged dataset
  (`cache$countdown_data`). This set has fewer checks than the one for
  unmerged sheets.

## See also

[`quality_issues_table()`](quality_issues_table.md) and
[`write_quality_issues()`](write_quality_issues.md) to tabulate or save
the result.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")

# On a loaded dataset
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
results <- run_all_quality_checks(cache)
names(results)
#> [1] "district_consistency"         "month_presence"              
#> [3] "month_validity"               "population_service_collision"
#> [5] "indicator_emptiness"          "survey_admin_names"          
#> [7] "shapefile_admin_names"       
results$indicator_emptiness
#> $ok
#> [1] FALSE
#> 
#> $severity
#> [1] "informational"
#> 
#> $detail
#> [1] "anc_1trimester"
#> 

# On the sheets of a workbook, before they are merged
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
results <- run_all_quality_checks(init_CacheConnection(wizard_parts = sheets))
Filter(function(result) !result$ok, results)
#> $population_vs_births
#> $population_vs_births$ok
#> [1] FALSE
#> 
#> $population_vs_births$severity
#> [1] "informational"
#> 
#> $population_vs_births$detail
#>                                                                                                                                                                                                                                x 
#> "District-year(s) where estimated population live births is lower than reported institutional counts, beyond a 10% margin: Kiambu 2019 (population: 56265, reported: 68964); Baringo 2023 (population: 15133, reported: 22639)." 
#> attr(,"rows")
#> # A tibble: 2 × 4
#>   district  year live_births total_delivered
#>   <chr>    <int>       <dbl>           <dbl>
#> 1 Kiambu    2019      56265.           68964
#> 2 Baringo   2023      15133            22639
#> 
#> 
#> $indicator_emptiness
#> $indicator_emptiness$ok
#> [1] FALSE
#> 
#> $indicator_emptiness$severity
#> [1] "informational"
#> 
#> $indicator_emptiness$detail
#> [1] "anc_1trimester"
#> 
#> 
```

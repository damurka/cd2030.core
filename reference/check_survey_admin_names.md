# Flag admin level 1 names with no matching survey region

Finds the admin level 1 names in the dataset that have no close match
among the regions of the regional survey. A dataset region without a
survey match cannot get a regional or equity estimate.

## Usage

``` r
check_survey_admin_names(regional_survey, countdown_data)
```

## Arguments

- regional_survey:

  A data frame of regional survey data with an `adminlevel_1` column, or
  `NULL`.

- countdown_data:

  A data frame. The dataset, with an `adminlevel_1` column.

## Value

A tibble with one row per unmatched dataset name and columns `name` (the
dataset name), `suggestion` (the closest survey name) and `distance`
(the distance between them). It has no rows if every name matches, or if
`regional_survey` is `NULL` or has no `adminlevel_1` column.

## Details

Names are compared without regard to case or accents, using the
Jaro-Winkler distance. A name is unmatched when its distance to the
closest survey name is 0.25 or more. Survey regions that match no
dataset name are not reported.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
data <- cache$countdown_data
check_survey_admin_names(cache$regional_survey, data)
#> # A tibble: 0 × 3
#> # ℹ 3 variables: name <chr>, suggestion <chr>, distance <dbl>

# A region the survey calls something else
data$adminlevel_1[data$adminlevel_1 == "Coast"] <- "Pwani"
check_survey_admin_names(cache$regional_survey, data)
#> # A tibble: 1 × 3
#>   name  suggestion distance
#>   <chr> <chr>         <dbl>
#> 1 Pwani Nandi         0.267
```

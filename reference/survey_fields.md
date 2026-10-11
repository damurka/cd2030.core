# The dataset fields of the five survey files

The names of the dataset fields the Survey Files step fills, one per
survey file. Each has built-in data for the dataset's country, so
`cache()$is_default(field)` is the way to tell whether the user has
uploaded a file for it.

## Usage

``` r
survey_fields
```

## Format

A character vector of five field names: `"national_survey"`,
`"regional_survey"`, `"wiq_survey"` (wealth index quintiles),
`"area_survey"` and `"education_survey"`.

## Examples

``` r
survey_fields
#> [1] "national_survey"  "regional_survey"  "wiq_survey"       "area_survey"     
#> [5] "education_survey"

# which survey files the user has uploaded
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
vapply(survey_fields, function(f) !cache$is_default(f), logical(1))
#>  national_survey  regional_survey       wiq_survey      area_survey 
#>            FALSE            FALSE            FALSE            FALSE 
#> education_survey 
#>            FALSE 
```

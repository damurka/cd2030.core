# Tests of whether a Load Data wizard step is complete

Each function looks at a dataset and says whether one step of the Load
Data wizard is done. The wizard uses them, through
[wizard_step_defs](wizard_step_defs.md) and
[`compute_step_states()`](compute_step_states.md), to decide which steps
are open and when Continue is enabled. `step_shapefile_touched()` is not
a completion test: it says whether the user has done anything on the
Shapefile step, which decides whether that step's button reads "Skip" or
"Continue".

## Usage

``` r
step_upload_complete(cd)

step_quality_complete(cd)

step_national_rates_complete(cd)

step_survey_files_complete(cd)

step_shapefile_complete(cd)

step_shapefile_touched(cd)

step_survey_mapping_complete(cd)

step_map_mapping_complete(cd)
```

## Arguments

- cd:

  The dataset, a [CacheConnection](CacheConnection.md) object (the value
  of `cache()`, not the reactive), or `NULL` when no dataset is loaded.

## Value

`TRUE` or `FALSE`. Every function returns `FALSE` for a `NULL` dataset,
except `step_shapefile_complete()`, which returns `TRUE`. Otherwise each
returns `TRUE` when:

- `step_upload_complete()`: the dataset holds unmerged sheets
  (`cd$wizard_parts`) or merged data with at least one row
  (`cd$countdown_data`).

- `step_quality_complete()`: the upload is complete and every check of
  severity `"blocking"` in
  [`run_all_quality_checks()`](run_all_quality_checks.md) has passed.

- `step_national_rates_complete()`: every national rate named by
  [`national_rates_required_fields()`](national_rates_required_fields.md)
  and every survey estimate named by
  [`survey_estimates_required_fields()`](national_rates_required_fields.md)
  has a value, and `cd$survey_year` is set.

- `step_survey_files_complete()`: the user has uploaded all five survey
  files ([survey_fields](survey_fields.md)).

- `step_shapefile_complete()`: the built-in shapefile is in use, or the
  user has uploaded one and `cd$shapefile_name_field` is set.

- `step_shapefile_touched()`: the user has uploaded a shapefile.

- `step_survey_mapping_complete()`: a survey name mapping is saved
  (`cd$survey_mapping`).

- `step_map_mapping_complete()`: a shapefile name mapping is saved
  (`cd$map_mapping`).

## Details

The survey files, the reference estimates and the shapefile have
built-in data for the dataset's country, so reading them from the
dataset never gives `NULL`. The tests for those steps therefore use
`cd$is_default()`, which says whether the user has uploaded something.
The two name mappings have no built-in data, so their tests check for
`NULL`: a mapping exists only after the user has saved the matching
dialog at least once.

## Examples

``` r
old <- options(cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_national_rate_fields()
  )
)))
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah

step_upload_complete(cache)
#> [1] TRUE
step_quality_complete(cache)
#> [1] TRUE
step_national_rates_complete(cache)
#> [1] FALSE
step_survey_files_complete(cache)
#> [1] FALSE
step_shapefile_complete(cache)
#> [1] TRUE
step_shapefile_touched(cache)
#> [1] FALSE
step_survey_mapping_complete(cache)
#> [1] FALSE
step_map_mapping_complete(cache)
#> [1] FALSE

# no dataset loaded
step_upload_complete(NULL)
#> [1] FALSE

options(old)
```

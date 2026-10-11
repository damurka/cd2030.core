# The steps of the Load Data wizard

The definition of the wizard's seven steps, in the order the user goes
through them: Upload Data, Data Quality, Survey Files, National Rates,
Shapefile, Map Survey Files and Map Shapefile Names.
[`compute_step_states()`](compute_step_states.md) turns it into the
state of each step for a dataset. Survey Files and Shapefile are
optional; the other five are required.

## Usage

``` r
wizard_step_defs
```

## Format

A list of seven lists, one per step. Each has:

- `key`: the step's key, a string: `"upload"`, `"quality"`,
  `"survey_files"`, `"national_rates"`, `"shapefile"`,
  `"survey_mapping"` or `"map_mapping"`.

- `title_key`: the translation key of the step's title.

- `required`: `TRUE` when the step must be complete before the user can
  go on.

- `complete_fn`: a function of the dataset that returns `TRUE` when the
  step is complete (see
  [`step_upload_complete()`](step_upload_complete.md)).

- `touched_fn` (the Shapefile step only): a function of the dataset that
  returns `TRUE` when the user has done something on the step.

- `relevant_fn` (the two mapping steps only): a function of the dataset
  whose result [`compute_step_states()`](compute_step_states.md) reports
  as `relevant`.

## Details

Survey Files comes before National Rates because an uploaded national
survey fills in most of the National Rates fields; the user then only
has to check them.

## Examples

``` r
vapply(wizard_step_defs, function(s) s$key, character(1))
#> [1] "upload"         "quality"        "survey_files"   "national_rates"
#> [5] "shapefile"      "survey_mapping" "map_mapping"   
vapply(wizard_step_defs, function(s) s$required, logical(1))
#> [1]  TRUE  TRUE FALSE  TRUE FALSE  TRUE  TRUE

# test one step on a dataset
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
wizard_step_defs[[1]]$complete_fn(cache)
#> [1] TRUE
```

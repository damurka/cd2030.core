# Survey files step of the Load Data wizard

An optional step where the user can upload the country's survey data in
place of the built-in survey data. It has one upload zone per file, each
a Stata file (`.dta`): national, regional, area, maternal education and
wealth index quintile. The files can be uploaded one at a time, and a
file is recognised by the zone it is dropped into, not by its name. Each
file is read for the dataset's country and saved with
`cache()$set_national_survey()`, `cache()$set_regional_survey()`,
`cache()$set_area_survey()`, `cache()$set_education_survey()` or
`cache()$set_wiq_survey()`. A zone's reset button goes back to the
built-in data (`cache()$clear_national_survey()` and so on). The step
counts as complete when all five files are uploaded (see
[`step_survey_files_complete()`](step_upload_complete.md)); being
optional, it can be skipped.

## Usage

``` r
survey_upload_ui(id, i18n)

survey_upload_server(id, cache, i18n)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

## Value

`survey_upload_ui()` returns the UI as Shiny tags: a card with the five
upload zones. `survey_upload_server()` is called for its side effects
and returns nothing useful.

## Details

The national and regional files are read with
[`load_survey_data()`](load_survey_data.md), the other three with
[`load_equity_data()`](load_equity_data.md). A file that cannot be read
shows an error banner under its zone. When the user has uploaded a
regional survey whose region names do not all match the dataset's admin
level 1 names (`cache()$check_survey_admin_names()`), a warning under
the zones gives the number of names that do not match; the Map Survey
Files step resolves them.

## Examples

``` r
if (FALSE) { # \dontrun{
# in the server of the Load Data screen, where `cache` is a reactive holding the dataset:
# the step's page, for wizard_steps_server(), and its server
panel <- list(key = "survey_files", ui = survey_upload_ui(ns("survey_upload"), i18n))
survey_upload_server("survey_upload", cache, i18n)
} # }
```

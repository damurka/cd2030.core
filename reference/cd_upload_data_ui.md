# The Load Data screen

The whole Load Data screen of a Countdown app: the page header, with its
help button, and the Load Data wizard with all seven steps. The server
starts every step's server, builds the steps' pages and hands them to
[`wizard_steps_server()`](wizard_steps_ui.md). The screen is the same
for every app. What differs between apps (the fields of the National
Rates step and the reference-data upload zones) comes from the app's
`options(cd2030.wizard = ...)`, which must be set before the screen is
used (see [`cd_wizard_config()`](cd_wizard_config.md)).
[`cd_app()`](cd_app.md) uses this screen unless the app passes its own
`upload_ui` and `upload_server`.

## Usage

``` r
cd_upload_data_ui(id, i18n, is_electron = FALSE)

cd_upload_data_server(id, i18n, cdsuite_file, active)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- is_electron:

  `TRUE` when the app was started with a file to load (the desktop app),
  `FALSE` (the default) when the user picks the file in the page. The ui
  function does not use it: the server works it out from `cdsuite_file`.

- cdsuite_file:

  The path of the file the app was started with, a string, or
  `NA_character_` when it was started without one. With a path, the file
  is loaded at startup and the Upload Data step shows no upload zone.

- active:

  A reactive that returns `TRUE` while the Load Data screen is the page
  shown.

## Value

`cd_upload_data_ui()` returns the UI as Shiny tags: the page header and
the wizard. `cd_upload_data_server()` returns a list with two elements:

- `cache`: a reactive value that holds the dataset, a
  [CacheConnection](CacheConnection.md), or `NULL` when none is loaded;

- `requires_walkthrough`: a reactive value that is `TRUE` when the
  wizard must be walked through step by step, and `FALSE` when a saved
  dataset (`.rds`) was loaded.

## Details

The steps and their modules, in wizard order: Upload Data
([`upload_box_ui()`](upload_box_ui.md) and
[`reference_estimates_ui()`](reference_estimates_ui.md) in one card),
Data Quality ([`data_quality_ui()`](data_quality_ui.md)), Survey Files
([`survey_upload_ui()`](survey_upload_ui.md)), National Rates
([`national_rates_ui()`](national_rates_ui.md)), Shapefile
([`shapefile_step_ui()`](shapefile_step_ui.md)), Map Survey Files
([`map_survey_ui()`](map_survey_ui.md)) and Map Shapefile Names
([`map_shapefile_ui()`](map_shapefile_ui.md)).

## Examples

``` r
if (FALSE) { # \dontrun{
# the app describes its part of the wizard once, before the screen is used
options(cd2030.app_group = "rmncah", cd2030.wizard = list(national_rates_groups = list(
  cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
    cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
    cd_wizard_national_rate_fields()
  )
)))

# in the app's ui
cd_upload_data_ui("upload_data", i18n = i18n)

# in the app's server: the dataset every page reads
loaded <- cd_upload_data_server("upload_data", i18n, NA_character_,
  active = reactive(identical(input$tabs, "upload_data"))
)
cache <- loaded$cache

# cd_app() does both when it is given the pair
cd_app(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
  upload_ui = cd_upload_data_ui, upload_server = cd_upload_data_server
)
} # }
```

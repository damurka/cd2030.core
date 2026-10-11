# Map Survey Files step of the Load Data wizard

The user matches each admin level 1 name of the dataset to the name the
regional survey uses for the same area. A button opens the matching
dialog ([`mapping_modal_ui()`](mapping_modal_ui.md)); saving it stores
the mapping with `cache()$set_survey_mapping()`. The regional survey is
the one the user uploaded, or the built-in one for the country, so the
step can always be done. Once a mapping is saved, a "clear mapping"
button removes it (`cache()$clear_survey_mapping()`) and a banner says
how the names were matched
([`mapping_provenance_banner()`](mapping_provenance_banner.md)). The
step counts as complete when a mapping is saved (see
[`step_survey_mapping_complete()`](step_upload_complete.md)), which
needs the user to save the dialog at least once.

## Usage

``` r
map_survey_ui(id, i18n)

map_survey_server(id, cache, i18n)
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

`map_survey_ui()` returns the UI as Shiny tags: a card.
`map_survey_server()` is called for its side effects and returns nothing
useful.

## Examples

``` r
if (FALSE) { # \dontrun{
# in the server of the Load Data screen, where `cache` is a reactive holding the dataset:
# the step's page, for wizard_steps_server(), and its server
panel <- list(key = "survey_mapping", ui = map_survey_ui(ns("map_survey"), i18n))
map_survey_server("map_survey", cache, i18n)
} # }
```

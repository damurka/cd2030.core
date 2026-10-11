# Dialog that matches the dataset's region names to another source

A button that opens a dialog with one row per admin level 1 name of the
dataset (`cache()$subnational_regions`). In each row the user picks the
matching name from another source: the regional survey or the shapefile.
The dialog suggests matches itself and keeps the matches saved before.
When the user saves, the server stores the mapping in the dataset with
`cache()$set_survey_mapping()` or `cache()$set_map_mapping()`, depending
on `type`. The two mapping steps of the wizard use it
([`map_survey_ui()`](map_survey_ui.md),
[`map_shapefile_ui()`](map_shapefile_ui.md)).

## Usage

``` r
mapping_modal_ui(id)

mapping_modal_server(
  id,
  cache,
  survey_data,
  survey_map,
  label,
  title,
  show_col,
  type,
  i18n
)
```

## Arguments

- id:

  The module's id.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- survey_data:

  A reactive that returns the other source, a data frame (the regional
  survey, or the shapefile). Its `show_col` column holds the names the
  user chooses from.

- survey_map:

  A reactive that returns the mapping saved so far (a data frame as
  described in Details), or `NULL` when none is saved.

- label:

  The translation key of the button's text, a string.

- title:

  The translation key of the dialog's title, a string.

- show_col:

  The column of `survey_data()` that holds the names to match: a string,
  or a function without arguments (or a reactive) that returns one. A
  function is called each time the value is needed, so the column can
  change while the app runs, as an uploaded shapefile's name column
  does.

- type:

  Where the mapping is saved: `"survey_mapping"` (with
  `cache()$set_survey_mapping()`) or `"map_mapping"` (with
  `cache()$set_map_mapping()`). Any other value saves nothing.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

## Value

`mapping_modal_ui()` returns the UI as Shiny tags: the placeholder the
server fills with the button and its dialog. `mapping_modal_server()` is
called for its side effects and returns nothing useful.

## Details

The saved mapping is a tibble with one row per matched name and three
columns: `admin_level_1` (the dataset's name), a column named after
`show_col` (the matching name in the other source) and `source`
(`"auto"` when the row is the dialog's own suggestion, left unchanged,
and `"user"` otherwise). Rows the user left without a match are not
saved.

The button and dialog appear once the dataset has its admin level 1
names and `survey_data()` has a value.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's ui
mapping_modal_ui(ns("survey_data"))

# in its server: match the dataset's names to the regional survey's
mapping_modal_server(
  id = "survey_data",
  cache = cache,
  survey_data = reactive(cache()$regional_survey),
  survey_map = reactive(cache()$survey_mapping),
  label = "btn_upload_map_survey",
  title = "msg_upload_manual_mapping",
  show_col = "adminlevel_1",
  type = "survey_mapping",
  i18n = i18n
)
} # }
```

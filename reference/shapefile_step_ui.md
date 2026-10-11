# Shapefile step of the Load Data wizard

An optional step where the user can replace the built-in map of the
country with their own shapefile. The user uploads the shapefile's
folder (its `.shp`, `.dbf`, `.shx` and `.prj` files), picks the column
that holds the admin level 1 names (`NAME_1` is preselected when the
file has it), and confirms. Confirming saves the shapefile with
`cache()$set_shapefile()` and the column with
`cache()$set_shapefile_name_field()`; nothing is saved before that. The
zone's reset button goes back to the built-in shapefile
(`cache()$clear_shapefile()`). The step never blocks the wizard while
the built-in shapefile is in use (see
[`step_shapefile_complete()`](step_upload_complete.md)).

## Usage

``` r
shapefile_step_ui(id, i18n)

shapefile_step_server(id, cache, i18n)
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

`shapefile_step_ui()` returns the UI as Shiny tags: a card with the
upload zone. `shapefile_step_server()` is called for its side effects
and returns nothing useful.

## Details

Under the upload zone the step shows: an error banner when the folder
cannot be read; a banner that says whether the built-in or a custom
shapefile is in use; and a warning with the number of admin level 1
names of the dataset that do not match the shapefile
(`cache()$check_shapefile_admin_names()`), which the Map Shapefile Names
step resolves.

## Examples

``` r
if (FALSE) { # \dontrun{
# in the server of the Load Data screen, where `cache` is a reactive holding the dataset:
# the step's page, for wizard_steps_server(), and its server
panel <- list(key = "shapefile", ui = shapefile_step_ui(ns("shapefile_step"), i18n))
shapefile_step_server("shapefile_step", cache, i18n)
} # }
```

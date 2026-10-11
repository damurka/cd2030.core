# Main dataset upload of the Load Data wizard

The upload zone of the wizard's Upload Data step, where the user gives
the health facility data the whole analysis runs on: an Excel file
(`.xls`, `.xlsx`), a Stata file (`.dta`) or a saved dataset (`.rds`).
The server reads the file and makes the dataset (a
[CacheConnection](CacheConnection.md)) that every other step works on. A
file that cannot be read shows an error banner under the zone. The
zone's reset button removes the dataset, which locks the later steps
again. A button downloads the merged data as a Stata file. The Upload
Data step counts as complete once a dataset is loaded (see
[`step_upload_complete()`](step_upload_complete.md)).

## Usage

``` r
upload_box_ui(id, i18n, is_electron = FALSE)

upload_box_server(id, i18n, cdsuite_file, is_electron = FALSE)
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
  and the server must be given the same value.

- cdsuite_file:

  The path of the file the app was started with, a string, or
  `NA_character_` when it was started without one.

## Value

`upload_box_ui()` returns the UI as Shiny tags: the upload zone (left
out when `is_electron` is `TRUE`), the placeholder for the status banner
and the download button. It has no card of its own.
`upload_box_server()` returns a list with three elements:

- `cache`: a reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md), or `NULL` when none is loaded;

- `requires_walkthrough`: a reactive value that is `TRUE` when the
  wizard must be walked through step by step, and `FALSE` when a saved
  dataset (`.rds`) was loaded;

- `source_path`: a reactive value that holds the path Finish saves the
  dataset next to (the dataset folder and the file's name), or `NULL`
  when a saved dataset was loaded or nothing is loaded.

## Details

How a file is loaded depends on its type:

- Excel: the sheets are read with
  [`load_excel_parts()`](load_excel_parts.md) and kept unmerged in the
  dataset (`wizard_parts`) until the user presses Finish. The country is
  worked out from the admin sheet and stored with
  `set_wizard_country()`.

- Stata: the file is loaded with
  [`load_cache_data()`](load_cache_data.md), without validation. A copy
  is saved when the user presses Finish, as for Excel.

- `.rds`: a saved dataset is loaded with
  [`load_cache_data()`](load_cache_data.md) too, and needs no
  walkthrough.

A Stata file or a saved dataset built for another indicator group than
the app's is refused
([`cd_wizard_check_group()`](cd_wizard_check_group.md)).

An Excel or Stata file that has a saved copy from an earlier Finish
(named by [`cd_saved_copy_name()`](cd_saved_copy_name.md), in the
dataset folder) loads that copy in its place, so the user does not go
through the walkthrough again. When the copy cannot be read, the
original file is loaded. The dataset folder is the folder of
`cdsuite_file` when the app was started with a file, and otherwise
`datasets` under `tools::R_user_dir("cd2030", "data")`.

When the app is started with a file (`is_electron = TRUE`) there is no
upload zone: the server loads `cdsuite_file` once at startup and shows a
success or an error banner.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's ui: the user picks the file in the page
upload_box_ui(ns("upload_box"), i18n)

# in its server
upload <- upload_box_server("upload_box", i18n, cdsuite_file = NA_character_)
observe({
  req(upload$cache())
  message("Loaded ", upload$cache()$country, "; walkthrough: ", upload$requires_walkthrough())
})

# an app started with a file to load: no upload zone, the file is loaded at startup
upload_box_ui(ns("upload_box"), i18n, is_electron = TRUE)
upload <- upload_box_server("upload_box", i18n, "C:/data/Kenya.xlsx", is_electron = TRUE)
} # }
```

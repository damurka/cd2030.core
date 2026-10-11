# Keep an upload zone showing the file the dataset already holds

Sets up, inside a module server, an observer that puts a file upload
zone back in its "uploaded" state each time the zone appears on the
page, when the dataset holds something the user uploaded for the zone's
field (`cache()$is_default(field)` is `FALSE`). The zone shows the name
of the file uploaded in this session, or a general "file on record"
label when the name is not known (for example after loading a saved
dataset).

## Usage

``` r
push_upload_on_remount(
  input,
  session,
  i18n,
  input_id,
  field,
  cache,
  filename_val
)
```

## Arguments

- input, session:

  The `input` and `session` objects of the calling module server.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for the label
  shown when the file's name is not known.

- input_id:

  The input id of the upload zone, without the namespace, a string.

- field:

  The name of the dataset field the zone fills, a string (for example
  `"un_estimates"`), as `cache()$is_default()` takes it.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- filename_val:

  A reactive value (`reactiveVal()`) that holds the name of the file
  uploaded in this session, or `NULL`. The caller sets it after an
  upload and sets it to `NULL` when the zone is reset.

## Value

Nothing useful. The function is called for its side effect of
registering the observer.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's ui: the upload zone
cd_file_upload(ns("un_data"), label = "title_upload_un_estimates", accept = ".dta", i18n = i18n)

# in its server: remember the uploaded file's name, and show it when the zone comes back
un_filename <- reactiveVal(NULL)
observeEvent(input$un_data, un_filename(input$un_data$name))
observeEvent(input$un_data_reset, un_filename(NULL))
push_upload_on_remount(input, session, i18n, "un_data", "un_estimates", cache, un_filename)
} # }
```

# A link that clears something the user set in the dataset

Sets up, inside a module server, a link button that shows only while a
field of the dataset holds something the user set
(`cache()$is_default(field)` is `FALSE`), and that calls `clear_fn()`
when pressed. The two mapping steps use it for their "clear mapping"
link. The module's UI needs `uiOutput(ns(output_id))` where the link
goes.

## Usage

``` r
restore_default_control(
  ns,
  output,
  input,
  output_id,
  field,
  cache,
  clear_fn,
  label_key,
  i18n
)
```

## Arguments

- ns:

  The namespace function of the calling module (`session$ns`).

- output, input:

  The `output` and `input` objects of the calling module server.

- output_id:

  The id of the output that shows the link, a string. The button's own
  input id is the same.

- field:

  The name of the dataset field to watch, a string (for example
  `"survey_mapping"`), as `cache()$is_default()` takes it.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- clear_fn:

  A function without arguments that clears the field, for example
  `function() cache()$clear_survey_mapping()`.

- label_key:

  The translation key of the link's text, a string.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

## Value

Nothing useful. The function is called for its side effects: it sets
`output[[output_id]]` and registers an observer.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's ui: where the link goes
uiOutput(ns("survey_map_restore"))

# in its server: a "clear mapping" link that shows while a survey mapping is saved
restore_default_control(
  session$ns, output, input, "survey_map_restore", "survey_mapping", cache,
  clear_fn = function() cache()$clear_survey_mapping(),
  label_key = "btn_upload_clear_mapping", i18n = i18n
)
} # }
```

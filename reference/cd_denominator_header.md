# Draw the denominator row in a page header

What a Countdown app adds to the server of every page header: it fills
the header's `denominator` output with
[`cd_denominator_row()`](cd_denominator_row.md) for the denominators the
dataset uses. [`cd_app()`](cd_app.md) passes it to the app frame
(`app_frame(page_header_extra = )`), which runs it inside each page
header's module, so a page never calls it itself.

## Usage

``` r
cd_denominator_header(input, output, session, cache, i18n)
```

## Arguments

- input, output, session:

  The `input`, `output` and `session` of the page header's module.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

## Value

Nothing useful. It is called for what it does.

## Details

It reads `cache()$denominator` and, when the app has a maternal
denominator ([`cd_has_maternal()`](cd_has_maternal.md)),
`cache()$maternal_denominator`. The row is drawn once the values it
needs are set, and again when one of them changes.

## Examples

``` r
if (FALSE) { # \dontrun{
# cd_app() gives it to the app frame, which calls it in each page header's module
app_frame(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
  data_server = data_server, page_header_extra = cd_denominator_header
)

# the call the frame makes, where the header has uiOutput(ns("denominator"))
moduleServer("header", function(input, output, session) {
  cd_denominator_header(input, output, session, cache = cache, i18n = i18n)
})
} # }
```

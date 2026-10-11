# Banner that says how a saved name mapping was matched

Builds the information banner the two mapping steps show under their
status message once a mapping is saved. It says how many of the saved
matches were made automatically and how many the user chose, from the
mapping's `source` column (`"auto"` or `"user"` per row, written by
[`mapping_modal_server()`](mapping_modal_ui.md)).

## Usage

``` r
mapping_provenance_banner(mapping_df, i18n)
```

## Arguments

- mapping_df:

  The saved mapping, a data frame with a `source` column, or `NULL`.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

## Value

The banner as Shiny tags, or `NULL` when `mapping_df` is `NULL`, has no
rows or has no `source` column.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a module's server: under the mapping's button, say how the saved names were matched
output$survey_map_summary <- renderUI(mapping_provenance_banner(cache()$survey_mapping, i18n))

# the banner for a mapping of three names, two matched by the dialog and one by the user
mapping <- data.frame(
  admin_level_1 = c("Nairobi", "Mombasa", "Kisumu"),
  adminlevel_1 = c("Nairobi", "Mombasa", "Kisumu"),
  source = c("auto", "auto", "user")
)
mapping_provenance_banner(mapping, i18n)
} # }
```

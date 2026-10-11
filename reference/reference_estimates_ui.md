# Reference-data uploads of the wizard's Upload Data step

Optional upload zones for the reference estimates the analysis uses: UN
estimates, WUENIC estimates and UN mortality estimates, each a Stata
file (`.dta`). Which zones show is set by the app
(`cd_wizard_config()$reference_uploads`). The dataset uses built-in
estimates for its country until the user uploads a file. An uploaded
file is read for the dataset's country and saved with
`cache()$set_un_estimates()`, `cache()$set_wuenic_estimates()` or
`cache()$set_un_mortality_estimates()`. A zone's reset button goes back
to the built-in estimates (`cache()$clear_un_estimates()` and so on). A
file that cannot be read shows an error banner under its zone. These
uploads do not affect whether the Upload Data step counts as complete.

## Usage

``` r
reference_estimates_ui(id, i18n)

reference_estimates_server(id, cache, i18n)
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

`reference_estimates_ui()` returns the UI as Shiny tags: a divider and a
group of upload zones. `reference_estimates_server()` is called for its
side effects and returns nothing useful.

## Details

The UI has no card of its own: it is a divided section meant to sit in
the same card as [`upload_box_ui()`](upload_box_ui.md). UN estimates are
read for the years of the dataset (`cache()$data_years`), so that zone
does nothing until the dataset has years.

## Examples

``` r
if (FALSE) { # \dontrun{
# in the server of the Load Data screen: the Upload Data step's page is one card
# holding the dataset's upload zone and these reference-data zones
panel <- list(key = "upload", ui = cd_card(
  title = i18n$t("title_upload_dataset_card"), width = 12,
  upload_box_ui(ns("upload_box"), i18n),
  reference_estimates_ui(ns("reference_estimates"), i18n)
))
reference_estimates_server("reference_estimates", cache, i18n)
} # }
```

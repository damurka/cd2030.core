# Build a Countdown app

Puts a whole Countdown app together and returns it as a Shiny app: the
frame every app shares (header, sidebar, language picker), the
Introduction and Load Data screens, and the app's own pages. An app's
`run_app()` sets its options, builds its translator, lists its pages and
its nav tree, and then calls `cd_app()`. See `cd2030.rmncah::run_app()`
for a complete one.

## Usage

``` r
cd_app(
  app_name,
  app_version,
  theme,
  nav_sections,
  registry,
  i18n,
  language,
  selected_file,
  upload_ui = get0("upload_data_ui", envir = parent.frame()) %||% cd_upload_data_ui,
  upload_server = get0("upload_data_server", envir = parent.frame()) %||%
    cd_upload_data_server
)
```

## Arguments

- app_name:

  The app's name, shown in the header.

- app_version:

  The app's version, shown in the header.

- theme:

  The app's colour theme: `"rmncah"` or `NULL` (maroon), `"vaccine"`
  (blue) or `"pooled"` (green).

- nav_sections:

  The sidebar's nav tree: a list of nav sections, made with
  [`cd_nav_start()`](cd_nav_start.md) and the functions beside it, and
  with the kit's `cd_nav_section()` and `cd_nav_item()`.

- registry:

  The app's pages: a list of page definitions made with the kit's
  `cd_page_def()`, the same list the app gives to `cd_use_pages()`.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- language:

  The language the app starts in, for example `"en"`, `"fr"` or `"pt"`.

- selected_file:

  The path of a dataset to open when the app starts, or `NA` for none.
  DataSuite gives it when the app is started on a file.

- upload_ui:

  The ui function of the Load Data screen, called as
  `upload_ui("upload_data", i18n = i18n, is_electron = )`, where
  `is_electron` is `TRUE` when `selected_file` is given. By default it
  is the function named `upload_data_ui` where `cd_app()` is called
  from, when there is one, and otherwise the shared screen,
  [`cd_upload_data_ui()`](cd_upload_data_ui.md), which the app sets up
  with `options(cd2030.wizard = )`.

- upload_server:

  The server function of the Load Data screen, called as
  `upload_server("upload_data", i18n, selected_file, active = )`. It
  must return a list with `cache` (a reactive that returns the dataset,
  a [CacheConnection](CacheConnection.md), or `NULL` before one is
  loaded) and `requires_walkthrough` (a reactive that is `TRUE` for a
  new upload and `FALSE` for a dataset opened again). By default it is
  the function named `upload_data_server` where `cd_app()` is called
  from, when there is one, and otherwise
  [`cd_upload_data_server()`](cd_upload_data_ui.md).

## Value

A Shiny app object. Printing it, or passing it to
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), runs the
app.

## Details

`cd_app()` calls the kit's
[`datasuite.ui::app_frame()`](https://rdrr.io/pkg/datasuite.ui/man/interface-kit.html)
and adds what is the same in every Countdown app:

- The Introduction screen and the Load Data screen. The app opens on
  Load Data, and these two screens are never locked.

- The dataset. It is the reactive the Load Data screen returns, and
  every page receives it as `cache`. The pages unlock once the dataset
  holds Countdown data. The nav items marked
  `requires_adjustment = TRUE` unlock once the data is also adjusted.

- The row naming the denominators in use, in every page header
  ([`cd_denominator_header()`](cd_denominator_header.md)).

- The language. A dataset that has just been uploaded takes the language
  on screen, and a dataset that is opened again shows the language it
  was saved with.

- The reports' colours, which follow `theme`.

- What DataSuite's chat can read and do in the app: the filters of the
  page on show, the dataset, and actions that set filters and save,
  read, change and write reports.

Before calling it, the app registers its translator with `cd_use_i18n()`
and its pages with `cd_use_pages()`.

## Examples

``` r
if (FALSE) { # \dontrun{
i18n <- shiny.i18n::init_i18n(translation_json_path = cd_translations("translation.json"))
cd_use_i18n(i18n)

pages <- my_pages()
cd_use_pages(pages)

cd_app(
  app_name = "My Countdown app", app_version = "1.0.0", theme = "vaccine",
  nav_sections = list(cd_nav_start(), cd_nav_quality(), cd_nav_denominators()),
  registry = pages, i18n = i18n, language = "en", selected_file = NA
)
} # }
```

# Chart with its tools and downloads

One chart with the tools every Countdown chart has: a panel to customize
how it looks, a download of the chart as a picture, and a download of
its data as an Excel workbook. The page gives the data and says how to
draw it, and this module does the rest. It is the chart that goes in the
tabs of [`cd_tabbed_charts_ui()`](cd_tabbed_charts_ui.md), and it works
as well on its own in a card.

## Usage

``` r
cd_coverage_plot_ui(id, toolbar_inline = FALSE)

cd_coverage_plot_toolbar_ui(id)

cd_coverage_plot_server(
  id,
  filename,
  data_fn,
  ...,
  sheet_name,
  i18n,
  plot_fun = NULL,
  about = NULL
)
```

## Arguments

- id:

  The module's id.

- toolbar_inline:

  Logical. `FALSE` (the default) draws the tools over the chart. `TRUE`
  leaves them out, for a page that places them with
  `cd_coverage_plot_toolbar_ui()`.

- filename:

  A reactive that returns the first part of the downloaded files' name.
  The date and time and the extension are added to it.

- data_fn:

  A reactive that returns the data the chart draws. It is also what the
  Excel download holds.

- ...:

  Arguments for
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html), used only
  when `plot_fun` is `NULL`.

- sheet_name:

  A reactive that returns the name of the sheet in the Excel download.
  It comes after `...`, so it must be given by name, as must `i18n`,
  `plot_fun` and `about`.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- plot_fun:

  A function `function(d)` that takes the data and draws the chart or
  returns a ggplot. `NULL` (the default) draws `plot(d, ...)`.

- about:

  What the chart is, for the app's AI: `NULL` (the default), a list, or
  a function that returns a list. See
  [`datasuite.ui::ai_register_component()`](https://rdrr.io/pkg/datasuite.ui/man/ai_register_component.html).

## Value

`cd_coverage_plot_ui()` returns the UI as Shiny tags: the chart, with
its tools unless `toolbar_inline` is `TRUE`.

`cd_coverage_plot_toolbar_ui()` returns the chart's tools alone, as
Shiny tags.

`cd_coverage_plot_server()` returns nothing useful. It is called for
what it does.

## Details

The chart is drawn with `plot_fun(data_fn())` once `data_fn()` has a
value. When `plot_fun` is `NULL` it is drawn with
`plot(data_fn(), ...)`, so the data must then have a
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method.

The Excel download holds `data_fn()` on one sheet named `sheet_name()`.
The picture is the chart as it is on screen, as a PNG file. Both files
are named `filename()` followed by the date and time.

In an app made with [`cd_app()`](cd_app.md), what the reader changes in
the customize panel is kept in the dataset. The chart is also registered
with the app's AI bridge, which can then list it and read its data.

By default the tools sit over a corner of the chart. With
`toolbar_inline = TRUE`, `cd_coverage_plot_ui()` leaves them out, and
the page puts them somewhere else (a card's header, for example) with
`cd_coverage_plot_toolbar_ui()`, called with the same `id`.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_coverage_plot_ui(ns("coverage"))

# in the page's server
cd_coverage_plot_server("coverage",
  filename = reactive("penta3_coverage"),
  data_fn = reactive(my_coverage_data(cache())),
  sheet_name = reactive(i18n$t("opt_penta3")),
  i18n = i18n,
  plot_fun = function(d) plot(d, title = "Penta3 coverage")
)
} # }
```

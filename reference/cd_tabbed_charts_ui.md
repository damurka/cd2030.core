# Chart card with one tab for each indicator

A card that shows the same chart for several indicators, one tab each,
with a "Custom" tab where the reader chooses any other indicator. The
page says how one chart is drawn (`uiInput` and `serverInput`), and this
module makes the tabs, switches between them and puts the chart tools of
the tab on show in the card's header. Many analysis pages are built from
it.

## Usage

``` r
cd_tabbed_charts_ui(
  id,
  i18n,
  title_key,
  uiInput,
  indicators = NULL,
  customIndicators = get_analysis_indicators(),
  showCustom = TRUE,
  width = 12
)

cd_tabbed_charts_server(
  id,
  serverInput,
  indicators = NULL,
  customIndicators = get_analysis_indicators(),
  showCustom = TRUE,
  selected_tab = reactive(NULL),
  i18n = cd_i18n()
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label. In `cd_tabbed_charts_server()` it is the last argument and
  defaults to the translator the app registered with `cd_use_i18n()`.

- title_key:

  The translation key of the card's title.

- uiInput:

  A function `function(id, toolbar_inline)` that returns the UI of one
  tab's chart (see Details).

- indicators:

  A character vector of indicator codes, one tab each, in this order.
  `NULL` (the default) uses
  [`cd_default_indicator_set()`](cd_default_indicator_set.md).

- customIndicators:

  The indicators the Custom tab's chip offers, as
  [`cd_indicator_ui()`](cd_indicator_ui.md) takes them. Default
  [`get_analysis_indicators()`](get_analysis_indicators.md). Only the ui
  uses it. The server accepts it and ignores it.

- showCustom:

  Logical. `TRUE` (the default) adds the Custom tab after the
  indicators' tabs.

- width:

  The card's width, passed to the kit's `cd_chart_card()`. Default `12`.
  The kit's card takes a width and ignores it: a card is as wide as the
  place it is put in.

- serverInput:

  A function `function(id, indicator)` that starts the server of one
  tab's chart (see Details).

- selected_tab:

  A reactive that returns the key of a tab to show (an indicator's code
  or `"custom"`), or `NULL`. When its value changes to a key, the card
  switches to that tab. It lets another card's tabs drive this card's.
  Default `reactive(NULL)`, which never switches.

## Value

`cd_tabbed_charts_ui()` returns the UI as Shiny tags (the card).

`cd_tabbed_charts_server()` returns a reactive holding the key of the
tab on show: an indicator's code, or `"custom"`.

## Details

`uiInput` and `serverInput` are the two halves of one chart, usually
[`cd_coverage_plot_ui()`](cd_coverage_plot_ui.md) and a function that
calls [`cd_coverage_plot_server()`](cd_coverage_plot_ui.md):

- `uiInput(id, toolbar_inline = TRUE)` is called once for each tab and
  returns that tab's chart. It must leave the chart's tools out when
  `toolbar_inline` is `TRUE`, because the card's header shows them. The
  header draws the tools with
  [`cd_coverage_plot_toolbar_ui()`](cd_coverage_plot_ui.md), so the
  chart must be a [`cd_coverage_plot_ui()`](cd_coverage_plot_ui.md) or
  use the same ids.

- `serverInput(id, indicator)` starts the chart of one tab. It is called
  once for each indicator, with the indicator's code as both arguments.
  For the Custom tab it is called once, with the id `"custom"` and a
  reactive that returns the indicator the reader chose; read either with
  [`cd_tab_indicator()`](cd_tab_indicator.md). It runs inside this
  module, so `id` is used as it is, without `ns()`.

A tab's label is the translation of `opt_` followed by the indicator's
code. The tabs that are not on show are hidden, and Shiny does not draw
a hidden chart.

Give `indicators` and `showCustom` the same values in the ui and the
server call.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_tabbed_charts_ui(ns("panel"), i18n, "title_coverage_national", cd_coverage_plot_ui,
  indicators = c("penta3", "measles1")
)

# in the page's server
cd_tabbed_charts_server("panel",
  serverInput = function(id, indicator) {
    cd_coverage_plot_server(
      id = id,
      filename = reactive(paste0(indicator, "_coverage")),
      data_fn = reactive(my_coverage_data(cache(), indicator)),
      sheet_name = reactive(i18n$t(paste0("opt_", indicator))),
      i18n = i18n
    )
  },
  indicators = c("penta3", "measles1")
)
} # }
```

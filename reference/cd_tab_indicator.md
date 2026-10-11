# The indicator of a tab of charts

The `serverInput` function given to
[`cd_tabbed_charts_server()`](cd_tabbed_charts_ui.md) receives the
indicator of its tab as a string, and for the Custom tab as a reactive
that returns the indicator the reader chose. `cd_tab_indicator()` gives
one way to read both.

## Usage

``` r
cd_tab_indicator(indicator)
```

## Arguments

- indicator:

  What `serverInput` received: an indicator's code, or a reactive that
  returns one.

## Value

A function with no arguments that returns the indicator's code. For the
Custom tab it must be called where a reactive can be read (in a
`reactive()`, a render function or a `plot_fun`).

## Examples

``` r
ind <- cd_tab_indicator("penta3")
ind()
#> [1] "penta3"

if (FALSE) { # \dontrun{
# in a page's server: one serverInput for the indicators' tabs and the Custom tab
cd_tabbed_charts_server("panel",
  serverInput = function(id, current_indicator) {
    ind <- cd_tab_indicator(current_indicator)
    cd_coverage_plot_server(
      id = id,
      filename = reactive(paste0(ind(), "_coverage")),
      data_fn = reactive(cache()$get_filtered_coverage(ind(), "national")),
      sheet_name = reactive(i18n$t(paste0("opt_", ind()))),
      i18n = i18n
    )
  }
)
} # }
```

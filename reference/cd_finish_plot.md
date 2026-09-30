# Finish a plot: apply the chart options

The last step of every plot method:
[`resolve_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/resolve_chart_options.html)
then
[`apply_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/apply_chart_options.html).
While a report renders
([`export_report()`](https://rdrr.io/pkg/datasuite.ui/man/export_report.html))
the report's saved options sit underneath: the dataset-wide ones, then
those saved for this type of graph
([`cd_chart_type()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_type.html)),
then those saved for this very chart
([`cd_chart_id()`](cd_chart_id.md)); what the plot method or the
template passes wins over all of them.

## Usage

``` r
cd_finish_plot(p, options = NULL, ..., .source = NULL)
```

## Arguments

- p:

  A ggplot.

- options, ...:

  See
  [`resolve_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/resolve_chart_options.html).

- .source:

  The data the plot was made from; its [`cd_chart_id()`](cd_chart_id.md)
  says which chart this is.

## Value

The ggplot with the options applied.

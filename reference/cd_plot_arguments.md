# Arguments every chart shares

Every chart in the package (each
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method, the
equiplots and [`plot_comparison()`](internal_consistency.md)) changes
its text and its look in the same way, with the arguments below. They
come after the arguments that say what to draw, and they have the same
names as the chart options
([`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)),
so what is given for one chart can be given for any other.

## Arguments

- title:

  The chart's title.

- subtitle:

  The line under the title.

- caption:

  The note under the chart.

- x_title:

  The title of the horizontal axis.

- y_title:

  The title of the vertical axis.

- legend_title:

  The title of the legend.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)):
  background, fonts, sizes, axes, grid, legend, colours. Other arguments
  are ignored.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Text

`title`, `subtitle`, `caption`, `x_title`, `y_title` and `legend_title`
replace a chart's own text. `NULL`, the default, keeps the text the
chart writes itself. To remove a text, hide it: `show_title = FALSE`,
`show_x_title = FALSE`, `show_legend_title = FALSE`.

## Look

Everything else is a chart option, given by name in `...`: the
background (`background_color`, `panel_color`), fonts and sizes
(`font_family`, `text_scale`, `title_size`, `axis_text_size`), the axes
(`x_limits`, `y_limits`, `x_text_angle`, `flip`), the grid (`grid`,
`grid_color`), the legend (`legend_position`, `legend_labels`,
`show_legend`) and the colours (`colors`).
[`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
lists them all.

## One look for several charts

Make the options once and give them to each chart as `options`. A chart
option named in the call wins over `options`.

## Which text is used

The six text arguments say what the chart should read; `options` holds
what someone changed afterwards (in the apps, with the chart's customize
panel), so a text in `options` wins over the text argument. From least
to most: the chart's own text, the text arguments, `options`, and a
chart option named in `...`.

## Names that are gone

`x_axis` and `x_label` were other names for `x_title`, `y_axis` and
`y_label` for `y_title`, and `legend` and `fill_label` for
`legend_title`. They are no longer accepted: a chart given one stops and
names the argument to use.

## Examples

``` r
if (FALSE) { # \dontrun{
rates <- calculate_average_reporting_rate(data, admin_level = "adminlevel_1")

# the same arguments on any chart
plot(rates, title = "Reporting by region", y_title = "Region", legend_title = "Rate")
plot(calculate_district_reporting_rate(data, 90), title = "Districts reporting", y_title = "Percent")

# background and fonts
plot(rates, background_color = "grey95", font_family = "serif", text_scale = 1.2)

# one look for several charts
look <- cd_chart_options(font_family = "serif", background_color = "grey95", legend_position = "right")
plot(rates, options = look)
plot(calculate_district_reporting_rate(data, 90), options = look)
} # }
```

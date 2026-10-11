#' Arguments every chart shares
#'
#' Every chart in the package (each `plot()` method, the equiplots and [plot_comparison()]) changes its text and its
#' look in the same way, with the arguments below. They come after the arguments that say what to draw, and they
#' have the same names as the chart options ([cd_chart_options()]), so what is given for one chart can be given for
#' any other.
#'
#' @section Text:
#' `title`, `subtitle`, `caption`, `x_title`, `y_title` and `legend_title` replace a chart's own text. `NULL`, the
#' default, keeps the text the chart writes itself. To remove a text, hide it: `show_title = FALSE`,
#' `show_x_title = FALSE`, `show_legend_title = FALSE`.
#'
#' @section Look:
#' Everything else is a chart option, given by name in `...`: the background (`background_color`, `panel_color`),
#' fonts and sizes (`font_family`, `text_scale`, `title_size`, `axis_text_size`), the axes (`x_limits`, `y_limits`,
#' `x_text_angle`, `flip`), the grid (`grid`, `grid_color`), the legend (`legend_position`, `legend_labels`,
#' `show_legend`) and the colours (`colors`). [cd_chart_options()] lists them all.
#'
#' @section One look for several charts:
#' Make the options once and give them to each chart as `options`. A chart option named in the call wins over
#' `options`.
#'
#' @section Which text is used:
#' The six text arguments say what the chart should read; `options` holds what someone changed afterwards (in the
#' apps, with the chart's customize panel), so a text in `options` wins over the text argument. From least to most:
#' the chart's own text, the text arguments, `options`, and a chart option named in `...`.
#'
#' @section Names that are gone:
#' `x_axis` and `x_label` were other names for `x_title`, `y_axis` and `y_label` for `y_title`, and `legend` and
#' `fill_label` for `legend_title`. They are no longer accepted: a chart given one stops and names the argument to
#' use.
#'
#' @param title The chart's title.
#' @param subtitle The line under the title.
#' @param caption The note under the chart.
#' @param x_title The title of the horizontal axis.
#' @param y_title The title of the vertical axis.
#' @param legend_title The title of the legend.
#' @param ... Chart options by name (see [cd_chart_options()]): background, fonts, sizes, axes, grid, legend,
#'   colours. Other arguments are ignored.
#' @param options A [cd_chart_options()] object or a list of chart options: a look made once, to give to several
#'   charts. Applied after the text arguments, so a text it holds wins over them.
#'
#' @examples
#' \dontrun{
#' rates <- calculate_average_reporting_rate(data, admin_level = "adminlevel_1")
#'
#' # the same arguments on any chart
#' plot(rates, title = "Reporting by region", y_title = "Region", legend_title = "Rate")
#' plot(calculate_district_reporting_rate(data, 90), title = "Districts reporting", y_title = "Percent")
#'
#' # background and fonts
#' plot(rates, background_color = "grey95", font_family = "serif", text_scale = 1.2)
#'
#' # one look for several charts
#' look <- cd_chart_options(font_family = "serif", background_color = "grey95", legend_position = "right")
#' plot(rates, options = look)
#' plot(calculate_district_reporting_rate(data, 90), options = look)
#' }
#'
#' @name cd_plot_arguments
#' @aliases cd-plot-arguments
NULL

# The text arguments every chart takes, named as the chart options are.
.cd_text_args <- c("title", "subtitle", "caption", "x_title", "y_title", "legend_title")

# The names charts had for three of them before. They are refused, not ignored: an argument a chart does not know is
# dropped without a word (it may be a chart option for another chart), which would leave the text unchanged.
.cd_text_gone <- c(x_axis = "x_title", x_label = "x_title", y_axis = "y_title", y_label = "y_title",
                   legend = "legend_title", fill_label = "legend_title")

# What every chart function ends with: draw the chart and apply the chart options.
#
# `impl` draws the chart from `x`, `own` (the arguments that say what to draw) and whichever of the shared text
# arguments it has an argument for. The text it has no argument for is written on the chart it returns, before
# `options`, so every chart takes all six and `options` wins over each. `...` holds chart options by name. The six
# are read from the calling function's arguments unless given as `text`; `defaults` are the texts to write when the
# caller gives none.
.cd_draw <- function(impl, x, own = list(), ..., options = NULL, text = NULL, defaults = list()) {
  text <- text %||% mget(.cd_text_args, envir = parent.frame())
  dots <- list(...)
  gone <- intersect(names(.cd_text_gone), names(dots))
  if (length(gone)) {
    cd_abort(c("x" = "{.arg {gone}} {?is/are} no longer {?an argument/arguments} of the charts.",
               "i" = "Use {.arg {unique(.cd_text_gone[gone])}}. See {.code ?cd_plot_arguments}."), call = caller_env())
  }
  for (name in names(defaults)) text[[name]] <- text[[name]] %||% defaults[[name]]
  text <- Filter(Negate(is.null), text)

  accepts <- names(formals(impl))
  to_impl <- list()
  to_chart <- list()
  for (name in names(text)) {
    if (name %in% accepts) to_impl[[name]] <- text[[name]] else to_chart[[name]] <- text[[name]]
  }

  drawn <- inject(impl(x, !!!c(own, to_impl, if ("..." %in% accepts) dots)))
  if (length(to_chart)) drawn <- apply_chart_options(drawn, inject(cd_chart_options(!!!to_chart)))
  inject(cd_finish_plot(drawn, options, !!!dots, .source = x))
}

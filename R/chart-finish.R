# Finishing a plot with its chart options (datasuite.ui::apply_chart_options()), the id of the chart a plot draws,
# and the charts that have options saved in a dataset. The options themselves are datasuite.ui's.

#' Finish a plot: apply the chart options
#'
#' The last step of every plot method: `resolve_chart_options()` then [apply_chart_options()]. While a report renders
#' ([export_report()]) the report's saved options sit underneath: the dataset-wide ones, then those saved for this type of
#' graph ([cd_chart_type()]), then those saved for this very chart ([cd_chart_id()]); what the plot method or the template
#' passes wins over all of them.
#'
#' @param p A ggplot.
#' @param options,... See [resolve_chart_options()].
#' @param .source The data the plot was made from; its [cd_chart_id()] says which chart this is.
#'
#' @return The ggplot with the options applied.
#' @export
cd_finish_plot <- function(p, options = NULL, ..., .source = NULL) {
  merged <- merge_chart_options(.report_options_for(p, .source), resolve_chart_options(options, ...))
  finished <- apply_chart_options(p, merged)
  # kept on the plot so cd_report_theme(), which a report adds afterwards, can put them back over its own theme
  if (inherits(finished, "ggplot") && length(merged)) attr(finished, "cd_chart_options") <- merged
  finished
}

#' The id of a chart
#'
#' A stable, readable name for the chart a plot draws, made from the data it is drawn from: the kind of data, the admin level
#' and the indicator (`"coverage_filtered.national.anc4"`). The app's customize panel and the reports build it the same way, so
#' options saved for a chart in the app (`"report/<id>"`) reach the same chart in a generated report. Ids are grouped by their
#' parts: everything under `coverage_filtered.national` is the national coverage charts.
#'
#' @param x The data a plot method was given.
#'
#' @return A string, or `NULL` when the data does not say what it is.
#' @export
cd_chart_id <- function(x) {
  generic <- c("tbl_df", "tbl", "data.frame", "data.table", "list", "numeric", "character", "integer", "double", "logical", "factor")
  kind <- setdiff(class(x), generic)
  if (!length(kind)) return(NULL)
  scalar <- function(name) {
    value <- attr(x, name, exact = TRUE)
    if (is.character(value) && length(value) == 1 && !is.na(value) && nzchar(value)) value
  }
  parts <- c(sub("^cd_", "", kind[[1]]), scalar("admin_level") %||% scalar("level"), scalar("indicator"))
  paste(parts, collapse = ".")
}

# What a report renders charts with: set by export_report() (with_report_chart_options()) as option datasuite.report_chart_options =
# list(default = <options>, types = list(<cd_chart_id() or cd_chart_type()> = <options>)). NULL outside a report.
# Most general first: dataset-wide, then the type of graph, then the chart itself.
.report_options_for <- function(p, source = NULL) {
  report <- getOption("datasuite.report_chart_options")
  if (is.null(report)) return(NULL)
  type <- cd_chart_type(p)
  id <- cd_chart_id(source)
  merge_chart_options(report$default, if (!is.null(type)) report$types[[type]], if (!is.null(id)) report$types[[id]])
}

#' The charts that have saved options
#'
#' A table of every chart with options saved in a dataset's cache: which chart (its [cd_chart_id()], or for the screen the
#' chart's place in the app), whether they are for the screen or for reports, how many options are set, and the group it
#' belongs to (the first two parts of its id, e.g. `coverage_filtered.national`). Use it to see which chart ids a report will
#' pick options up for.
#'
#' @param cache A [CacheConnection].
#'
#' @return A tibble with `id`, `target` (`"screen"`, `"report"` or `"dataset"`), `group`, `n_options` and `options` (a
#'   one-line summary).
#' @export
cd_chart_catalog <- function(cache) {
  saved <- cache$chart_options
  if (!length(saved)) {
    return(tibble::tibble(id = character(), target = character(), group = character(), n_options = integer(), options = character()))
  }
  ids <- names(saved)
  target <- ifelse(ids == "default", "dataset", ifelse(startsWith(ids, "report/"), "report", "screen"))
  chart <- sub("^report/", "", ids)
  group <- vapply(strsplit(chart, ".", fixed = TRUE), function(p) paste(utils::head(p, 2), collapse = "."), character(1))
  summary <- vapply(saved, function(o) paste(names(o), collapse = ", "), character(1))
  tibble::tibble(id = chart, target = target, group = group, n_options = unname(vapply(saved, length, integer(1))), options = unname(summary))
}

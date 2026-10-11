#' Plot S3 method for overall score
#'
#' Draws the overall data quality score as a formatted table, with the metrics grouped by type and a
#' column for each year. Percentage scores are shaded green at or above the threshold stored with
#' the scores, yellow from 70 up to the threshold and red below 70.
#'
#' @param x The score dataframe (class `cd_overall_score`), as returned by
#'   [calculate_overall_score()].
#' @param years Vector of years to display. Required: each must be a year column of `x`.
#' @param title (Optional) Custom title for the table
#' @param width (Optional) Total width in inches. If NULL, autofit is used.
#' @param ... Additional arguments
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#'
#' @return A `flextable` object (from the flextable package), not a ggplot. Chart options change
#'   ggplots only, so `options` has no effect on this table.
#'
#' @examples
#' data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' score <- calculate_overall_score(data, threshold = 90)
#'
#' plot(score, years = 2019:2023)
#' plot(score, years = 2021:2023, title = "Data quality, last three years", width = 7)
#'
#' @export
plot.cd_overall_score <- function(x, years = NULL, title = NULL, width = NULL, ..., options = NULL) {
  cd_finish_plot(.plot_cd_overall_score_impl(x, years = years, title = title, width = width, ...), options, ..., .source = x)
}

.plot_cd_overall_score_impl <- function(x, years = NULL, title = NULL, width = NULL, ...) {
  # by default every year the table has a column for
  if (is.null(years)) years <- as.integer(grep("^[0-9]{4}$", names(x), value = TRUE))
  if (!length(years) || !is_integerish(years)) {
    cd_abort(c("x" = "{.arg years} cannot be null"))
  }
  threshold <- attr_or_abort(x, "threshold")
  main_title <- title %||% "Data Quality Metrics"

  num_years <- length(years)

  base_font <- if (!is.null(width) && width < 5) {
    8
  } else {
    9
  }

  ft <- x %>%
    as_grouped_data(groups = "type") %>%
    as_flextable() %>%
    set_header_labels(no = "", `Data Quality Metrics` = main_title) %>%
    compose(
      i = ~ !is.na(type),
      j = 1,
      value = as_paragraph(as_chunk(type))
    ) %>%
    # the look every formatted table has; the score's own row stands out as a section row does
    .cd_table_style(section = ~ !is.na(type), base_font = base_font, centre = as.character(years)) %>%
    bold(i = ~ is.na(type) & no == "4", bold = TRUE, part = "body") %>%
    bg(i = ~ is.na(type) & no == "4", j = 1:2, part = "body", bg = .cd_table_colours$section) %>%
    colformat_double(i = ~ is.na(type) & !no %in% c("3a", "3b"), j = as.character(years), digits = 0, big.mark = ",") %>%
    colformat_double(i = ~ is.na(type) & no %in% c("3a", "3b"), j = as.character(years), digits = 2) %>%
    .cd_table_status(i = ~ is.na(type) & !no %in% c("3a", "3b"), j = as.character(years), threshold = threshold)

  if (!is.null(width)) {
    if (width < 5) {
      w_col1 <- 0.25
      w_year <- 0.25
    } else {
      w_col1 <- 0.40
      w_year <- 0.55
    }

    # Calculate remaining width for the text description column
    w_col2 <- max(1.0, width - w_col1 - (num_years * w_year))

    ft <- ft %>%
      width(j = 1, width = w_col1) %>%
      width(j = 2, width = w_col2) %>%
      width(j = as.character(years), width = w_year) %>%
      set_table_properties(layout = "fixed")
  } else {
    # FOR HTML/WEB: Let the browser organically size the columns
    ft <- ft %>%
      autofit()
  }

  return(ft)
}

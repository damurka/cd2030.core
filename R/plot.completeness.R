#' Plot Missing Summary
#'
#' This method visualizes missing results for immunization indicators
#'
#' @param x A `cd_outlier` object containing pre-processed outlier data.
#' @param indicator Optional. One of the supported indicators (`'opv1'`, `'penta3'`, etc.)
#'   to visualize in the plot. If `NULL` all indicators will be shown.
#' @param ... Reserved for future use.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @return A `ggplot` or `plotly` object depending on the selection type.
#'
#' @examples
#' \dontrun{
#' # Region-level summary
#' plot(missing_data, indicator = "penta3")
#' }
#'
#' @export
plot.cd_completeness_summary <- function(x,
                                         plot_type = c("heat_map", "trend"),
                                         indicator = NULL,
                                         title = NULL,
                                         x_axis = NULL,
                                         y_axis = NULL,
                                         legend = NULL,
                                         ..., options = NULL) {
  cd_finish_plot(.plot_cd_completeness_summary_impl(x, plot_type = plot_type, indicator = indicator, title = title, x_axis = x_axis, y_axis = y_axis, legend = legend, ...), options, ..., .source = x)
}

.plot_cd_completeness_summary_impl <- function(x,
                                         plot_type = c("heat_map", "trend"),
                                         indicator = NULL,
                                         title = NULL,
                                         x_axis = NULL,
                                         y_axis = NULL,
                                         legend = NULL,
                                         ...) {
  plot_type <- arg_match(plot_type)
  threshold <- attr_or_abort(x, "threshold")

  admin_level <- attr_or_abort(x, "admin_level")
  region <- attr_or_null(x, "region")
  admin_level_col <- get_plot_admin_column(admin_level, region)

  indicator <- if (is.null(indicator) || indicator == "") {
    NULL
  } else {
    arg_match(indicator, get_all_indicators())
  }

  labels <- list(
    heat_map_all = list(
      title = if (!is.null(region) && nzchar(region)) {
        paste0("Average reporting missingness (%) by ", admin_level_col, " in ", region)
      } else {
        paste0("Average reporting missingness (%) by ", admin_level_col)
      }
    ),
    heat_map_one = list(
      title = if (!is.null(region) && nzchar(region)) {
        paste0("Proportion of missing reports (%) for ", indicator, " by year and ", admin_level_col, " in ", region)
      } else {
        paste0("Proportion of missing reports (%) for ", indicator, " by year and ", admin_level_col)
      }
    ),
    trend = list(
      title = paste0("Trend in reporting completeness (%) for ", indicator, " by ", admin_level_col)
    )
  )

  label <- if (plot_type == "heat_map") {
    if (is.null(indicator)) labels$heat_map_all else labels$heat_map_one
  } else {
    labels$trend
  }

  plot_title <- if (!is.null(title)) title else label$title
  plot_x <- if (!is.null(x_axis)) x_axis else label$x
  plot_y <- if (!is.null(y_axis)) y_axis else label$y
  plot_leg <- if (!is.null(legend)) legend else label$legend

  if (plot_type == "heat_map") {
    d <- x %>%
      mutate(across(starts_with("mis_"), ~ 100 - .x))

    if (is.null(indicator)) {
      hm <- d %>%
        summarise(across(starts_with("mis_"), ~ round(mean(.x, na.rm = TRUE))), .by = all_of(admin_level_col)) %>%
        pivot_longer(cols = starts_with("mis_"), names_to = "indicator") %>%
        mutate(indicator = str_remove(indicator, "mis_"))

      cd_categorized_heatmap(
        data = hm,
        x_col = admin_level_col,
        y_col = "indicator",
        value_col = "value",
        threshold = threshold,
        x_lab = plot_x,
        y_lab = plot_y,
        legend_lab = plot_leg,
        title = plot_title,
        reverse = TRUE
      )
    } else {
      hm <- d %>%
        mutate(
          year = factor(year, levels = sort(unique(year))),
          value = round(!!sym(paste0("mis_", indicator)))
        )
      cd_categorized_heatmap(
        data = hm,
        x_col = admin_level_col,
        y_col = "year",
        value_col = "value",
        threshold = threshold,
        x_lab = plot_x,
        y_lab = plot_y,
        legend_lab = plot_leg,
        title = plot_title,
        reverse = TRUE
      )
    }
  } else {
    if (is.null(indicator)) {
      cd_abort(c("indicator" = "For plot_type = 'trend', please provide a single indicator."))
    }

    x %>%
      mutate(across(starts_with("mis_"), ~ round(.x))) %>%
      group_by(!!sym(admin_level_col)) %>%
      select(year, any_of(admin_level_col), where(~ any(.x < 100, na.rm = TRUE))) %>%
      pivot_longer(
        cols = starts_with("mis_"),
        names_prefix = "mis_",
        names_to = "indicator",
        values_to = "value"
      ) %>%
      filter(indicator == !!indicator) %>%
      mutate(facet_label = !!sym(admin_level_col)) %>%
      ggplot(aes(y = value, x = year, colour = indicator)) +
      geom_line() +
      geom_point() +
      facet_wrap(~facet_label) +
      scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0.05, 0.1))) +
      cd_plot_theme(
        title = plot_title,
        x_axis = plot_x,
        y_axis = plot_y
      ) +
      theme(legend.position = "none")
  }
}

#' Plot Percent of Districts with Complete Data
#'
#' Visualizes the percentage of districts with complete data for a selected
#' indicator over time.
#'
#' @param x A `cd_missing_district` (or compatible) object containing
#'   district-level completeness summaries. Must include a `year` column and
#'   corresponding `mis_{indicator}` columns.
#' @param indicator A character string specifying the indicator to plot.
#'   Must be one of the values returned by `get_all_indicators()`.
#' @param title Optional character string to override the default plot title.
#' @param x_axis Optional character string to override the x-axis label.
#' @param y_axis Optional character string to override the y-axis label.
#' @param ... Additional arguments reserved for future use.
#'
#' @details
#' The function produces a column chart showing the percent of districts
#' with complete data for the selected indicator by year.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' plot(missing_summary, indicator = "penta1")
#' }
#'
#' @export
plot.cd_missing_district <- function(x,
                                     indicator = NULL,
                                     title = NULL,
                                     x_axis = NULL,
                                     y_axis = NULL,
                                     ..., options = NULL) {
  cd_finish_plot(.plot_cd_missing_district_impl(x, indicator = indicator, title = title, x_axis = x_axis, y_axis = y_axis, ...), options, ..., .source = x)
}

.plot_cd_missing_district_impl <- function(x,
                                     indicator = NULL,
                                     title = NULL,
                                     x_axis = NULL,
                                     y_axis = NULL,
                                     ...) {
  indicator <- arg_match(indicator, get_all_indicators())

  plot_title <- if (!is.null(title)) title else "Percent of districts with complete data by vaccine"
  plot_y <- if (!is.null(x_axis)) y_axis else "Completeness (%)"
  plot_x <- if (!is.null(y_axis)) x_axis else "Year"

  x %>%
    ggplot(aes(x = year, y = !!sym(paste0("mis_", indicator)))) +
    geom_col(fill = "lightblue", width = 0.6) +
    geom_text(
      aes(label = paste0(round(!!sym(paste0("mis_", indicator)), 0), "%")),
      vjust = -0.3,
      size = 4
    ) +
    scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.1))) +
    cd_plot_theme(
      title = plot_title,
      x_axis = plot_x,
      y_axis = plot_y
    )
}

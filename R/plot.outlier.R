#' Visualize Summary of Outlier Detection
#'
#' Plots annual trends or heat maps of non-outlier rates for immunization indicators
#' at subnational levels.
#'
#' @param x A `cd_outlier` object with precomputed outlier flags.
#' @param selection_type One of `"region"`, `"indicator"`, or `"heat_map"`:
#'   - `"region"`: Non-outlier rates by year and region.
#'   - `"indicator"`: Yearly average non-outlier rate per indicator.
#'   - `"heat_map"`: Year-by-unit heat map of all or selected indicators.
#' @param indicator Optional. Specific indicator name (e.g., `"penta3"`). Required
#'    for `"region"` view.
#' @param threshold Numeric. Upper cut-off (in percent) of the middle colour
#'   band; values above it are shown as good. Default is `90`.
#' @param title Optional plot title. Defaults to a title based on
#'   `selection_type`.
#' @param x_axis,y_axis Optional x- and y-axis titles. Default to `"Year"` and
#'   a "Percent non-outliers" label.
#' @param legend Optional legend title. Defaults to a "Percent non-outliers"
#'   label.
#' @param ... Not used.
#'
#' @details
#' - Values are assumed to be percentages of non-outliers (i.e., 100 = no outliers).
#' - `"region"` and `"indicator"` use bar plots with gradient fill.
#' - `"heat_map"` shows indicator values by year and region.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' plot(outlier_data, selection_type = "region", indicator = "penta3")
#' plot(outlier_data, selection_type = "heat_map")
#' }
#' @export
plot.cd_outlier <- function(x,
                            selection_type = c("region", "indicator", "heat_map"),
                            indicator = NULL,
                            threshold = .cd_method$data_quality$reporting_threshold,
                            title = NULL,
                            x_axis = NULL,
                            y_axis = NULL,
                            legend = NULL,
                            ..., options = NULL) {
  cd_finish_plot(.plot_cd_outlier_impl(x, selection_type = selection_type, indicator = indicator, threshold = threshold, title = title, x_axis = x_axis, y_axis = y_axis, legend = legend, ...), options, ..., .source = x)
}

.plot_cd_outlier_impl <- function(x,
                            selection_type = c("region", "indicator", "heat_map"),
                            indicator = NULL,
                            threshold = .cd_method$data_quality$reporting_threshold,
                            title = NULL,
                            x_axis = NULL,
                            y_axis = NULL,
                            legend = NULL,
                            ...) {
  check_scalar_integerish(threshold)

  admin_level <- attr_or_abort(x, "admin_level")
  region <- attr_or_null(x, "region")
  admin_level_col <- get_plot_admin_column(admin_level, region)

  indicator <- if (is.null(indicator) || indicator == "") {
    NULL
  } else {
    arg_match(indicator, get_all_indicators())
  }

  selection_type <- arg_match(selection_type)

  default_title <- switch(selection_type,
    region = paste("Percent non-outliers by year and", admin_level_col),
    indicator = "Percent non-outliers by year and indicator",
    heat_map = if (is.null(indicator)) {
      paste("Average percent non-outliers by", admin_level_col)
    } else {
      paste("Percent non-outliers for", indicator, "by year and", admin_level_col)
    }
  )

  plot_title <- if (!is.null(title)) title else default_title
  plot_x <- if (!is.null(x_axis)) x_axis else "Year"
  plot_y <- if (!is.null(y_axis)) y_axis else "Percent non-outliers (%)"
  plot_leg <- if (!is.null(legend)) legend else "Percent non-outliers (%)"

  if (selection_type %in% c("region", "indicator")) {
    cut_low <- 70
    cut_high <- threshold

    low <- paste0("< ", cut_low)
    mid <- paste0("\u2265 ", cut_low, " and < ", threshold)
    greater <- paste0("\u2265 ", threshold)
    lvl <- c(low, mid, greater)


    data_prepared <- if (selection_type == "region") {
      if (is.null(indicator) || !nzchar(indicator)) {
        cd_abort(c("indicator" = "Indicator must be provided for region view."))
      }

      x %>%
        mutate(
          category = !!sym(admin_level_col),
          value = !!sym(paste0(indicator, "_outlier5std"))
        )
    } else {
      x %>%
        pivot_longer(
          cols = ends_with("_outlier5std"),
          names_to = "category",
          names_pattern = "^(.*)_outlier5std"
        ) %>%
        summarise(value = mean(value, na.rm = TRUE), .by = c(year, category))
    }

    data_prepared <- data_prepared %>%
      mutate(
        value_round = round(value),
        color_category = case_when(
          value <= cut_low ~ low,
          value > cut_low & value <= cut_high ~ mid,
          .default = greater,
          .ptype = factor(levels = lvl)
        )
      )

    ggplot(data_prepared, aes(x = factor(year), y = value, fill = color_category)) +
      geom_col(show.legend = TRUE) +
      facet_wrap(~category) +
      scale_fill_manual(
        values = set_names(c("red", "orange", "forestgreen"), lvl),
        limits = lvl,
        breaks = lvl,
        drop = FALSE
      ) +
      cd_plot_theme(
        title = plot_title,
        x_axis = plot_x,
        y_axis = plot_y,
        legend = plot_leg
      ) +
      # theme_minimal() +
      theme(
        panel.background = element_blank(),
        plot.background = element_blank(),
        panel.border = element_blank(),
        axis.line = element_blank(),
        panel.grid.major = element_line(color = "gray95"),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        strip.background = element_blank(),
        strip.placement = "outside",
        legend.title = element_text(size = 13)
      )
  } else if (selection_type == "heat_map") {
    if (is.null(indicator)) {
      hm <- x %>%
        summarise(across(ends_with("_outlier5std"), ~ round(mean(.x, na.rm = TRUE))), .by = all_of(admin_level_col)) %>%
        pivot_longer(cols = ends_with("_outlier5std"), names_to = "indicator") %>%
        mutate(indicator = str_remove(indicator, "_outlier5std"))

      cd_categorized_heatmap(
        data = hm,
        x_col = admin_level_col,
        y_col = "indicator",
        value_col = "value",
        threshold = threshold,
        title = plot_title,
        x_lab = plot_x,
        y_lab = plot_y,
        legend_lab = plot_leg,
      )
    } else {
      column_name <- paste0(indicator, "_outlier5std")

      hm <- x %>%
        mutate(
          year = factor(year, levels = sort(unique(year))),
          value = round(!!sym(column_name))
        )

      cd_categorized_heatmap(
        data = hm,
        x_col = admin_level_col,
        y_col = "year",
        value_col = "value",
        threshold = threshold,
        title = plot_title,
        x_lab = plot_x,
        y_lab = plot_y,
        legend_lab = plot_leg
      )
    }
  }
}

#' Plot Outlier Time Series for a Region
#'
#' Displays a time-series plot of one indicator for a single region or district,
#' with outlier highlights.
#'
#' @param x A `cd_outlier_list` object from `list_outlier_units()`.
#' @param indicator The indicator to plot (for example `"penta1"`).
#' @param year Optional single year to plot. If `NULL` (the default), all
#'   years are shown.
#' @param region The name of the unit to plot.
#' @param title Optional plot title. Defaults to a title naming the indicator,
#'   unit and year.
#' @param x_axis,y_axis Optional x- and y-axis titles. Default to `"Month"` and
#'   the indicator name.
#' @param legend Optional legend title. Default is `NULL` (no title).
#' @param label Optional named character vector overriding the legend labels.
#'   Recognised names are `reported`, `median`, `bounds` and `outliers`.
#' @param ... Not used.
#'
#' @details
#' - Plots observed values, median trend, and 5xMAD range.
#' - Flags outliers in red.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' list_outlier_units(cd_data, "penta1") %>%
#'   plot(region_name = "Nakuru")
#' }
#' @export
plot.cd_outlier_list <- function(x,
                                 indicator = NULL,
                                 year = NULL,
                                 region = NULL,
                                 title = NULL,
                                 x_axis = NULL,
                                 y_axis = NULL,
                                 legend = NULL,
                                 label = NULL,
                                 ..., options = NULL) {
  cd_finish_plot(.plot_cd_outlier_list_impl(x, indicator = indicator, year = year, region = region, title = title, x_axis = x_axis, y_axis = y_axis, legend = legend, label = label, ...), options, ..., .source = x)
}

.plot_cd_outlier_list_impl <- function(x,
                                 indicator = NULL,
                                 year = NULL,
                                 region = NULL,
                                 title = NULL,
                                 x_axis = NULL,
                                 y_axis = NULL,
                                 legend = NULL,
                                 label = NULL,
                                 ...) {
  admin_level <- attr_or_abort(x, "admin_level")
  indicator <- arg_match(indicator, get_all_indicators())
  year_val <- if (!is.null(year)) {
    check_scalar_integerish(year)
    year
  } else {
    NULL
  }

  if (is.null(region) || !nzchar(region)) {
    cd_abort(c("x" = "{.arg region} must be a scalar string"))
  }

  admin_level_col <- get_plot_admin_column(admin_level)

  med <- paste0(indicator, "_med")
  mad <- paste0(indicator, "_mad")

  default_title <- if (is.null(year_val)) {
    str_glue("{indicator} trend for {region}")
  } else {
    str_glue("{indicator} trend for {region} in {year_val}")
  }

  plot_title <- title %||% default_title
  plot_x <- x_axis %||% "Month"
  plot_y <- y_axis %||% indicator
  plot_leg <- legend %||% NULL

  default_labels <- c(
    reported = "Reported value",
    median   = "Median",
    bounds   = "Median \u00b1 5\u00d7MAD",
    outliers = "Outliers"
  )

  labels_map <- default_labels
  if (!is.null(label)) {
    # label should be a named character vector, e.g.
    # c(reported="Valeur rapport?e", median="M?diane", bounds="M?diane ? 5xMAD", outliers="Valeurs extr?mes")
    labels_map[names(label)] <- label
  }

  x %>%
    select(any_of(c(admin_level_col, "year", "month", indicator, paste0(indicator, c("_med", "_mad", "_outlier5std"))))) %>%
    filter(district == region, if (is.null(year_val)) TRUE else year == year_val) %>%
    mutate(
      date = ym(paste(year, month, sep = "-")),
      upper_bound = !!sym(med) + !!sym(mad) * .cd_method$data_quality$outlier_mad_multiplier,
      lower_bound = !!sym(med) - !!sym(mad) * .cd_method$data_quality$outlier_mad_multiplier,
      outlier_flag = !!sym(indicator) > upper_bound | !!sym(indicator) < lower_bound
    ) %>%
    ggplot(aes(date)) +
    geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound, fill = "bounds"), alpha = 0.5) +
    geom_line(aes(y = !!sym(indicator), colour = "reported")) +
    geom_point(aes(y = !!sym(indicator), colour = "reported")) +
    geom_line(aes(y = !!sym(med), colour = "median"), linetype = "dashed") +
    geom_point(
      data = function(df) filter(df, outlier_flag),
      aes(y = !!sym(indicator), color = "outliers"), size = 2
    ) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 10), expand = expansion(mult = c(0, 0.05))) +
    coord_cartesian(ylim = c(0, NA)) +
    scale_x_date(date_breaks = if (is.null(year_val)) "3 months" else "1 months", date_labels = if (is.null(year_val)) "%b-%Y" else "%b") +
    scale_colour_manual(
      name = plot_leg,
      values = c(reported = "forestgreen", median = "cyan", outliers = "red"),
      breaks = c("reported", "median", "outliers"),
      labels = labels_map[c("reported", "median", "outliers")]
    ) +
    scale_fill_manual(
      name = plot_leg,
      values = c(bounds = "gray80"),
      breaks = "bounds",
      labels = labels_map["bounds"]
    ) +
    cd_plot_theme(
      title = plot_title,
      x_axis = plot_x,
      y_axis = plot_y,
      legend = plot_leg
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(hjust = 0.5, size = 16),
      legend.title = element_text(size = 13)
    )
}

#' Plot comparison with linear fit and R-squared
#'
#' Creates a scatter plot to compare two indicators over multiple years, including
#' a linear regression line and a diagonal reference line. The plot is faceted by year,
#' and displays R-squared values for each year to assess the relationship between indicators.
#'
#' @param .data A `cd_data` object containing merged data for the specified indicators.
#' @param x_var Character. Name of the variable to plot on the x-axis (e.g., 'anc1').
#' @param y_var Character. Name of the variable to plot on the y-axis (e.g., 'penta1').
#' @param legend_labels Optional named list or vector overriding the legend labels.
#'   Recognised names are `district`, `linear_fit` and `diagonale`; unnamed
#'   entries keep their defaults. Default is `NULL`.
#' @param call The calling environment.
#' @inheritParams cd_plot_arguments
#'
#' @details
#' This function calculates R-squared values for each year and displays them in each facet,
#' helping assess the relationship between the two indicators over time. The diagonal reference line
#' is added to aid in visualizing deviations from a perfect 1:1 relationship.
#'
#' Common indicator comparisons include:
#' - ANC1 vs PENTA1
#' - PENTA1 vs PENTA3
#' - OPV1 vs OPV3
#'
#' @return A ggplot2 object showing the comparison plot of two indicators with linear regression and R-squared values.
#'
#' @examples
#' \dontrun{
#' plot_comparison(cd_data, x_var = "anc1", y_var = "penta1")
#' }
#'
#' @export
plot_comparison.cd_data <- function(
    .data, x_var, y_var, title = NULL, subtitle = NULL, caption = NULL, x_title = NULL, y_title = NULL,
    legend_title = NULL, ..., legend_labels = NULL, call = caller_env(), options = NULL) {
  .cd_draw(.plot_comparison_cd_data_impl, .data, list(x_var = x_var, y_var = y_var, legend_labels = legend_labels, call = call), ...,
           options = options)
}

.plot_comparison_cd_data_impl <- function(
    .data, x_var, y_var, title = NULL,
    x_title = NULL, y_title = NULL, legend_labels = NULL,
    call = caller_env(), ...) {
  district <- year <- min_x <- max_x <- r_squared <- NULL

  check_cd_data(.data)
  local_data_group(.data)
  check_required(x_var)
  check_required(y_var)

  # Check if specified indicators exist in the data
  if (!(x_var %in% names(.data)) || !(y_var %in% names(.data))) {
    cd_abort(c("x" = "{.val {x_var}} or {.val {y_var}} is not a column of {.arg .data}."))
  }

  # Filter data and calculate yearly sums
  data_filtered <- .data %>%
    summarize(
      across(all_of(c(x_var, y_var)), ~ sum(.x, na.rm = TRUE)),
      .by = c(district, year)
    ) %>%
    # Add min and max for the diagonal line
    mutate(
      min_x = min(!!sym(x_var), na.rm = TRUE),
      max_x = robust_max(!!sym(x_var)),
      .by = year
    )

  # Calculate R-squared values by year
  r_squared_value <- data_filtered %>%
    summarize(
      r_squared = round(summary(stats::lm(stats::as.formula(paste(y_var, "~", x_var)), data = pick(everything())))$r.squared, 4),
      .by = year
    ) %>%
    mutate(label = paste0("R\u00b2 = ", r_squared))


  # Set default title and labels if not provided
  plot_title <- title %||% paste("Comparison of", x_var, "and", y_var, "by Year")
  plot_x <- x_title %||% x_var
  plot_y <- y_title %||% y_var

  legend_default <- c(
    district = "District",
    linear_fit = "Linear  Fit",
    diagonale = "Diagonale"
  )

  legend_user <- if (is.null(legend_labels)) NULL else unlist(legend_labels)

  # merge: user values override defaults
  legend_labels <- utils::modifyList(as.list(legend_default), as.list(legend_user)) |> unlist()

  # Ensure consistent order
  legend_order <- c("district", "linear_fit", "diagonale")
  legend_labels <- legend_labels[legend_order]

  # Create the plot
  plot <- data_filtered %>%
    ggplot(aes(x = !!sym(x_var), y = !!sym(y_var))) +
    geom_point(aes(colour = "district"), size = 1.5) +
    geom_smooth(aes(color = "linear_fit"), method = "lm", formula = y ~ x, linetype = "solid", se = FALSE, linewidth = 0.8) +
    geom_segment(aes(x = min_x, y = min_x, xend = max_x, yend = max_x, colour = "diagonale"),
      linetype = "dashed", linewidth = 0.8
    ) +
    facet_wrap(~year, scales = "free_y", ncol = 3) +
    geom_text(
      data = r_squared_value,
      aes(x = Inf, y = Inf, label = label),
      inherit.aes = FALSE,
      hjust = 1.1, vjust = 1.1,
      size = 3
    ) +
    coord_cartesian(clip = "off") +
    scale_x_continuous(labels = scales::label_number()) +
    scale_y_continuous(labels = scales::label_number()) +
    cd_plot_theme(
      title = plot_title,
      x_title = plot_x,
      y_title = plot_y
    ) +
    scale_color_manual(
      values = c(
        district = "navy",
        linear_fit = "black",
        diagonale = "red"
      ),
      breaks = legend_order,
      labels = legend_labels
    )

  return(plot)
}

#' Internal consistency plot functions for indicator comparisons
#'
#' These functions generate scatter plots that compare two health indicators across years, assessing internal consistency
#' through visualization of linear regression fits and R-squared values by year. Each function is designed to compare a specific
#' pair of indicators, with options for customizing plot titles, axis labels, and the inclusion of trend information.
#'
#' @param .data A data frame of class `cd_data` that includes the relevant indicators for comparison.
#' @param x_var Character. The name of the indicator variable to plot on the x-axis.
#' @param y_var Character. The name of the indicator variable to plot on the y-axis.
#' @param legend_labels Optional named list or vector overriding the legend labels.
#'   Recognised names are `district`, `linear_fit` and `diagonale`. Default is
#'   `NULL`.
#' @param call The calling environment, used for error handling. Default is `caller_env()`.
#' @param options A [cd_chart_options()] object; see [cd_plot_arguments].
#' @inheritParams cd_plot_arguments
#'
#' @details
#' - The scatter plot displays the relationship between the two specified indicators over multiple years,
#'   with each year presented in a separate facet.
#' - A linear regression line is added to each year's plot to help visualize the trend.
#' - R-squared values, calculated per year, are optionally displayed on each facet, indicating the strength
#'   of the linear relationship between the indicators for that year.
#' - A diagonal reference line is also provided for visual comparison to a 1:1 relationship, where applicable.
#'
#' This function is commonly used for consistency checks between indicators such as:
#' - ANC1 vs PENTA1
#' - PENTA1 vs PENTA3
#' - OPV1 vs OPV3
#'
#' @return A `ggplot2` object, comprising:
#' - A scatter plot comparing two specified indicators over multiple years.
#' - A linear regression line for each year, indicating the trend between the indicators.
#' - Optional display of R-squared values per facet, summarizing the correlation strength.
#' - Faceting by year to facilitate a detailed comparison of trends across years.
#'
#' Users can render this `ggplot2` object directly, save it, or further modify it using the `+` operator.
#'
#' @examples
#' \dontrun{
#' # Plot a comparison between ANC1 and PENTA1 indicators
#' plot_comparison(cd_data, x_var = "anc1", y_var = "penta1")
#'
#' # Dedicated function for comparing ANC1 and PENTA1 over time
#' plot_comparison_penta1_anc1(cd_data)
#' }
#'
#' @rdname internal_consistency
#' @export
plot_comparison <- function(.data, x_var, y_var, title = NULL, subtitle = NULL, caption = NULL, x_title = NULL,
                            y_title = NULL, legend_title = NULL, ..., legend_labels = NULL, call = caller_env()) {
  check_cd_data(.data, call = call)
  local_data_group(.data)
  check_required(x_var, call = call)
  check_required(y_var, call = call)
  UseMethod("plot_comparison")
}

#' Plot comparison of ANC1 and Penta1
#'
#' `plot_comparison_anc1_penta1()` compares ANC1 and Penta1. Its title is "Comparison of numbers of ANC1 and Penta1 by year" and its axes are titled "ANC1" and "Penta1" unless others are given; the two functions below are the same for their pairs.
#'
#' @rdname internal_consistency
#'
#' @export
plot_comparison_anc1_penta1 <- function(
    .data,
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    x_title = NULL,
    y_title = NULL,
    legend_title = NULL,
    ...,
    legend_labels = NULL,
    options = NULL) {
  .cd_comparison(.data, "anc1", "penta1", text = mget(.cd_text_args), ..., legend_labels = legend_labels, options = options,
                 defaults = list(title = "Comparison of numbers of ANC1 and Penta1 by year", x_title = "ANC1", y_title = "Penta1"))
}

#' Plot comparison of Penta1 and Penta3
#'
#' `plot_comparison_penta1_penta3()` compares Penta1 and Penta3.
#'
#' @rdname internal_consistency
#'
#' @export
plot_comparison_penta1_penta3 <- function(
    .data,
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    x_title = NULL,
    y_title = NULL,
    legend_title = NULL,
    ...,
    legend_labels = NULL,
    options = NULL) {
  .cd_comparison(.data, "penta1", "penta3", text = mget(.cd_text_args), ..., legend_labels = legend_labels, options = options,
                 defaults = list(title = "Comparison of numbers of Penta1 and Penta3 by year", x_title = "Penta1", y_title = "Penta3"))
}

#' Plot comparison of OPV1 and OPV3
#'
#' `plot_comparison_opv1_opv3()` compares OPV1 and OPV3.
#'
#' @rdname internal_consistency
#'
#' @export
plot_comparison_opv1_opv3 <- function(
    .data,
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    x_title = NULL,
    y_title = NULL,
    legend_title = NULL,
    ...,
    legend_labels = NULL,
    options = NULL) {
  .cd_comparison(.data, "opv1", "opv3", text = mget(.cd_text_args), ..., legend_labels = legend_labels, options = options,
                 defaults = list(title = "Comparison of numbers of OPV1 and OPV3 by year", x_title = "OPV1", y_title = "OPV3"))
}

# What the three functions above end with: the comparison chart of two indicators, with the texts they give it when
# the caller gives none.
.cd_comparison <- function(.data, x_var, y_var, text, defaults, ..., legend_labels = NULL, options = NULL) {
  .cd_draw(.plot_comparison_cd_data_impl, .data, list(x_var = x_var, y_var = y_var, legend_labels = legend_labels), ...,
           options = options, text = text, defaults = defaults)
}

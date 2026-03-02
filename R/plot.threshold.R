#' Plot Target Threshold Attainment Over Time
#'
#' Generates a grouped bar chart showing the percentage of administrative regions
#' that meet specific health coverage or dropout thresholds over time.
#'
#' @param x A `cd_threshold` object returned by [calculate_threshold()].
#' @param title (Optional) A scalar character string to override the default plot title. Defaults to `NULL`.
#' @param x_axis (Optional) A scalar character string to override the default x-axis label. Defaults to `NULL`.
#' @param y_axis (Optional) A scalar character string to override the default y-axis label. Defaults to `NULL`.
#' @param legend_title (Optional) A scalar character string to override the default legend title. Defaults to `NULL`.
#' @param x_labels (Optional) A named list or vector to translate the raw indicator names
#'   on the x-axis (e.g., `list(penta1 = "Penta 1", dropout_penta13 = "Penta 1-3 Dropout")`).
#' @param ... Additional arguments passed to the plotting function.
#'
#' @return A `ggplot` object displaying a grouped bar chart of threshold attainment.
#'
#' @export
plot.cd_threshold <- function(x, title = NULL, x_axis = NULL, y_axis = NULL, legend_title = NULL, x_labels = NULL, ...) {
  indicator = value = year = NULL

  # Extract attributes
  indicator_group <- attr_or_abort(x, "indicator")
  admin_level_raw <- attr_or_abort(x, "admin_level")
  region <- attr_or_null(x, 'region')
  coverage <- attr_or_abort(x, 'threshold')

  # Validate scalar character inputs for custom labels
  if (!is.null(title) && !is_scalar_character(title)) cd_abort("x" = "{.arg title} must be a scalar character or NULL.")
  if (!is.null(x_axis) && !is_scalar_character(x_axis)) cd_abort("x" = "{.arg x_axis} must be a scalar character or NULL.")
  if (!is.null(y_axis) && !is_scalar_character(y_axis)) cd_abort("x" = "{.arg y_axis} must be a scalar character or NULL.")
  if (!is.null(legend_title) && !is_scalar_character(legend_title)) cd_abort("x" = "{.arg legend_title} must be a scalar character or NULL.")

  # 1. Resolve Default Texts
  pretty_group <- switch(indicator_group,
                         vaccine = 'Vaccines',
                         dropout = 'Dropout',
                         anc4 = 'ANC 4',
                         instdeliveries = 'Institutional Delivery',
                         str_to_title(indicator_group)
  )

  pretty_admin <- switch(admin_level_raw,
                         adminlevel_1 = if (is.null(region)) "Admin Level 1" else 'Districts',
                         district = "Districts"
  )

  rate <- if (indicator_group == 'dropout') 'rate' else 'coverage'
  sign <- if (indicator_group == 'dropout') '<' else '≥'

  default_title <- if (is.null(region)) {
    str_glue('Percentage of {pretty_admin} with {pretty_group} {rate} {sign} {coverage}%')
  } else {
    str_glue('Percentage of {pretty_admin} in {region} with {pretty_group} {rate} {sign} {coverage}%')
  }

  final_title <- title %||% default_title
  final_x_axis <- x_axis %||% ""
  final_y_axis <- y_axis %||% "Percentage of Subnational Units (%)"
  final_legend_title <- legend_title %||% "Year"

  # Process data
  plot_data <- x %>%
    pivot_longer(
      cols = starts_with('cov_'),
      names_prefix = 'cov_',
      names_sep = '_(?=[^_]+$)',
      names_to = c('indicator', NA)
    )

  # Map custom x-axis labels if provided
  if (!is.null(x_labels)) {
    lbl_map <- unlist(x_labels)
    plot_data <- plot_data %>%
      mutate(indicator = ifelse(indicator %in% names(lbl_map), lbl_map[indicator], indicator))
  }

  plot_data %>%
    ggplot(aes(indicator, value, fill = factor(year))) +
    geom_col(position = "dodge") +
    geom_hline(yintercept = 80, colour = "red", linewidth = 1.5) +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 11), expand = expansion(mult = c(0,0.1))) +
    scale_fill_manual(
      values = c("darkgreen", "darkgoldenrod3", "firebrick4", "springgreen3", "darkolivegreen3", "steelblue2"),
      name = final_legend_title
    ) +
    cd_plot_theme(
      title = final_title,
      x_axis = final_x_axis,
      y_axis = final_y_axis
    )
}

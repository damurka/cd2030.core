#' Plot target threshold attainment over time
#'
#' Generates a grouped bar chart showing the percentage of administrative regions
#' that meet specific health coverage or dropout thresholds over time.
#'
#' @param x A `cd_threshold` object returned by [calculate_threshold()].
#' @inheritParams cd_plot_arguments
#' @param x_labels (Optional) A named list or vector to translate the raw indicator names
#'   on the x-axis (e.g., `list(penta1 = "Penta 1", dropout_penta13 = "Penta 1-3 Dropout")`).
#'
#' @return A `ggplot` object displaying a grouped bar chart of threshold attainment.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' reached <- cache$get_filtered_threshold("vaccine", "district")
#'
#' plot(reached)
#' plot(reached, x_labels = list(bcg = "BCG", penta3 = "Penta 3", measles1 = "Measles 1"),
#'      title = "Districts reaching the vaccination target", y_title = "Districts (%)", legend_title = "Year")
#'
#' @export
plot.cd_threshold <- function(x,
                              x_labels = NULL,
                              title = NULL,
                              subtitle = NULL,
                              caption = NULL,
                              x_title = NULL,
                              y_title = NULL,
                              legend_title = NULL,
                              ...,
                              options = NULL) {
  .cd_draw(.plot_cd_threshold_impl, x, list(x_labels = x_labels), ..., options = options)
}

.plot_cd_threshold_impl <- function(x, title = NULL, x_title = NULL, y_title = NULL, legend_title = NULL, x_labels = NULL, ...) {
  indicator = value = year = NULL

  # Extract attributes
  indicator_group <- attr_or_abort(x, "indicator")
  admin_level_raw <- attr_or_abort(x, "admin_level")
  region <- attr_or_null(x, 'region')
  coverage <- attr_or_abort(x, 'threshold')

  # Validate scalar character inputs for custom labels
  if (!is.null(title) && !is_scalar_character(title)) cd_abort(c("x" = "{.arg title} must be a scalar character or NULL."))
  if (!is.null(x_title) && !is_scalar_character(x_title)) cd_abort(c("x" = "{.arg x_title} must be a scalar character or NULL."))
  if (!is.null(y_title) && !is_scalar_character(y_title)) cd_abort(c("x" = "{.arg y_title} must be a scalar character or NULL."))
  if (!is.null(legend_title) && !is_scalar_character(legend_title)) cd_abort(c("x" = "{.arg legend_title} must be a scalar character or NULL."))

  # 1. Resolve Default Texts
  pretty_group <- switch(indicator_group,
                         vaccine = 'Vaccines',
                         dropout = 'Dropout',
                         anc4 = 'ANC 4',
                         ideliv = 'Institutional Delivery',
                         str_to_title(indicator_group)
  )

  pretty_admin <- switch(admin_level_raw,
                         adminlevel_1 = if (is.null(region)) "Admin Level 1" else 'Districts',
                         district = "Districts"
  )

  rate <- if (indicator_group == 'dropout') 'rate' else 'coverage'
  sign <- if (indicator_group == 'dropout') '<' else '\u2265'

  default_title <- if (is.null(region)) {
    str_glue('Percentage of {pretty_admin} with {pretty_group} {rate} {sign} {coverage}%')
  } else {
    str_glue('Percentage of {pretty_admin} in {region} with {pretty_group} {rate} {sign} {coverage}%')
  }

  final_title <- title %||% default_title
  final_x_axis <- x_title %||% ""
  final_y_axis <- y_title %||% "Percentage of Subnational Units (%)"
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
      values = .cd_palette$years,
      name = final_legend_title
    ) +
    cd_plot_theme(
      title = final_title,
      x_title = final_x_axis,
      y_title = final_y_axis
    )
}

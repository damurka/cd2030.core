#' Plot ratios summary for indicator ratios summary object
#'
#' Generates a bar plot for a `cd_ratios_summary` object,
#' displaying the calculated indicator ratios for each year. It allows
#' for visual comparison across years, showing how each indicator ratio
#' changes over time.
#'
#' @param x A `cd_ratios_summary` object created by the `calculate_ratios_summary` function.
#'   It should contain a `year` column and one or more columns with names starting with `"Ratio"`,
#'   representing the calculated indicator ratios.
#' @inheritParams cd_plot_arguments
#' @param x_labels Optional named list or vector of x-axis category labels,
#'   keyed by ratio name (`anc1_penta1`, `opv1_opv3`, `penta1_penta3`).
#'   Supplied entries replace the defaults.
#'
#' @return A `ggplot` object representing a bar plot of indicator ratios by year.
#'
#' @details
#' This function provides a visual summary of indicator ratios, with each ratio displayed
#' as a bar for each year. The `Expected Ratio` row is included if available, allowing
#' for easy comparison of actual ratios against expected values. The bars are grouped
#' by year, with distinct colors representing each year for clear differentiation.
#'
#' @examples
#' \dontrun{
#' # Assuming `cd_ratios_summary` is the object returned by `calculate_ratios_summary`
#' plot(cd_ratios_summary)
#' }
#'
#' @export
plot.cd_ratios_summary <- function(x,
                                   x_labels = NULL,
                                   title = NULL,
                                   subtitle = NULL,
                                   caption = NULL,
                                   x_title = NULL,
                                   y_title = NULL,
                                   legend_title = NULL,
                                   ...,
                                   options = NULL) {
  .cd_draw(.plot_cd_ratios_summary_impl, x, list(x_labels = x_labels), ..., options = options)
}

.plot_cd_ratios_summary_impl <- function(x, title = NULL,
                                   x_title = NULL,
                                   y_title = NULL,
                                   x_labels = NULL,
                                   ...) {
  year <- name <- value <- NULL

  plot_data <- x %>%
    select(year, starts_with("Ratio ")) %>%
    rename_with(~ str_replace(str_remove(.x, "Ratio "), "/", "_")) %>%
    pivot_longer(cols = -year) %>%
    mutate(year = factor(year, levels = sort(unique(year))))

  # Generate color palette with unique colors for each combination of name and year
  # unique_names <- unique(plot_data$year)
  # colors <- c('darkgreen', 'darkgoldenrod3', 'firebrick4', 'springgreen3', 'darkolivegreen3', 'steelblue2')
  # color_mapping <- set_names(colors, unique_names)

  years <- x %>%
    distinct(year) %>%
    pull(year)

  x_labels_default <- c(
    "anc1_penta1"   = "Ratio ANC1 / Penta1",
    "opv1_opv3"     = "Ratio OPV1 / OPV3",
    "penta1_penta3" = "Ratio Penta1 / Penta3"
  )

  x_labels_used <- if (is.null(x_labels)) {
    x_labels_default
  } else {
    # allow list or vector
    x_labels <- unlist(x_labels)
    out <- x_labels_default
    out[names(x_labels)] <- x_labels
    out
  }

  plot_title <- if (!is.null(title)) title else "Ratio of number of facility reported ANC1 to penta1, and penta1 to penta3 compared to expected ratios"
  plot_x <- if (!is.null(x_title)) x_title else NULL
  plot_y <- if (!is.null(y_title)) y_title else NULL

  color_mapping <- cd_year_colours(years)

  plot_data %>%
    ggplot(aes(name, value, fill = year)) +
    geom_col(position = position_dodge2(), width = 0.6) +
    geom_text(
      aes(label = round(value, 2)),
      position = position_dodge2(width = 0.6),
      vjust = -0.5,
      size = 3
    ) +
    geom_hline(yintercept = .cd_method$data_quality$ratio_adequate_range[1], linetype = "dashed", color = "red") +
    geom_hline(yintercept = .cd_method$data_quality$ratio_adequate_range[2], linetype = "dashed", color = "blue") +
    scale_y_continuous(breaks = scales::pretty_breaks(n = 6)) +
    scale_fill_manual(values = color_mapping) +
    scale_x_discrete(labels = x_labels_used) +
    cd_plot_theme(
      title = plot_title,
      x_title = plot_x,
      y_title = plot_y
    ) +
    cd_dashed_grid_theme(x = FALSE) +
    theme(plot.title = element_text(size = 14, hjust = 0.5))
}

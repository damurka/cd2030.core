#' Plot National Coverage Data
#'
#' This function generates a line plot to visualize immunization coverage
#' data across years, allowing comparison between different estimates (e.g., DHIS2
#' estimates, WUENIC estimates, and Survey estimates).
#'
#' @param x A data frame of type `cd_coverage_filtered`, containing year-wise
#'   coverage data for the specified indicator.
#' @param title (Optional) A scalar character string to override the default plot title. Defaults to `NULL`.
#' @param x_axis (Optional) A scalar character string to override the default x-axis label. Defaults to `NULL`.
#' @param y_axis (Optional) A scalar character string to override the default y-axis label. Defaults to `NULL`.
#' @param caption (Optional) A scalar character string to override the default denominator caption. Defaults to `NULL`.
#' @param labels (Optional) A named list or vector to override the legend keys for translation.
#'   Valid keys: `dhis2`, `wuenic`, `survey`, `ci`. Defaults to `NULL`.
#' @param ... Additional arguments passed to or from other methods (currently unused).
#'
#' @return A `ggplot` object displaying a line plot of the coverage data.
#'
#' @export
plot.cd_coverage_filtered <- function(x, title = NULL, x_axis = NULL, y_axis = NULL, caption = NULL, labels = NULL, ...) {
  estimates = year = value = `Survey estimates` = `DHIS2 estimate` = `WUENIC estimates` =
    `95% CI LL` = `95% CI UL` = NULL

  admin_level <- attr_or_abort(x, "admin_level")
  denominator <- attr_or_abort(x, 'denominator')
  indicator <- attr_or_abort(x, 'indicator')
  region <- attr_or_null(x, 'region')

  if (ncol(x) <= 1) {
    cd_abort(c("x" = "The columns data is empty."))
  }

  if (!is.null(title) && !is_scalar_character(title)) {
    cd_abort("x" = "{.arg title} must be a scalar character or NULL.")
  }
  if (!is.null(x_axis) && !is_scalar_character(x_axis)) {
    cd_abort("x" = "{.arg x_axis} must be a scalar character or NULL.")
  }
  if (!is.null(y_axis) && !is_scalar_character(y_axis)) {
    cd_abort("x" = "{.arg y_axis} must be a scalar character or NULL.")
  }
  if (!is.null(caption) && !is_scalar_character(caption)) {
    cd_abort("x" = "{.arg caption} must be a scalar character or NULL.")
  }

  # 1. Resolve Final Plot Text
  indicator_pretty <- str_to_title(indicator)
  default_title <- if (admin_level == "national") {
    str_glue("National {indicator_pretty} Coverage Estimates")
  } else {
    str_glue("{region} {indicator_pretty} Coverage Estimates")
  }

  final_title <- title %||% default_title
  final_x_axis <- x_axis %||% "Year"
  final_y_axis <- y_axis %||% "Coverage (%)"
  final_caption <- caption %||% paste0("Denominators derived from ", denominator, " estimates")

  # 2. Setup Legend Labels for Translation
  default_labels <- list(
    dhis2  = "DHIS2 estimate",
    wuenic = "WUENIC estimate",
    survey = "Survey estimate",
    ci     = "95% CI"
  )

  user_labels <- if (is.null(labels)) list() else as.list(labels)
  final_labels <- utils::modifyList(default_labels, user_labels)

  # Extract labels to clean variables for ggplot aes()
  lbl_dhis2  <- final_labels$dhis2
  lbl_wuenic <- final_labels$wuenic
  lbl_survey <- final_labels$survey
  lbl_ci     <- final_labels$ci

  data_long <- x %>%
    pivot_longer(cols = -estimates, names_to = "year") %>%
    mutate(year = as.integer(year))

  min_y <- min(data_long$value, na.rm = TRUE)
  min_y <- if (min_y < 0) min_y * 1.05 else 0
  max_y <- robust_max(data_long$value) * 1.05

  data_long <- data_long %>%
    pivot_wider(
      names_from = estimates,
      values_from = value,
      names_repair = "minimal"
    )

  surv_data <- data_long %>%
    filter(!is.na(`Survey estimates`))

  # 3. Build the Plot (Mapping aesthetic colors to the translated labels)
  plot <- data_long %>%
    ggplot(aes(x = year)) +
    geom_line(aes(y = `DHIS2 estimate`, color = lbl_dhis2), linewidth = 1) +
    geom_point(aes(y = `DHIS2 estimate`, color = lbl_dhis2), size = 2)

  if (admin_level == "national") {
    plot <- plot +
      geom_line(aes(y = `WUENIC estimates`, color = lbl_wuenic), linewidth = 1) +
      geom_point(aes(y = `WUENIC estimates`, color = lbl_wuenic), size = 2)
  }

  plot <- plot +
    geom_line(data = surv_data, aes(y = `Survey estimates`, color = lbl_survey), linewidth = 1) +
    geom_point(aes(y = `Survey estimates`, color = lbl_survey), size = 2) +
    geom_errorbar(
      aes(ymin = `95% CI LL`, ymax = `95% CI UL`, y = `Survey estimates`, color = lbl_ci),
      width = 0.2,
      na.rm = TRUE
    ) +
    scale_y_continuous(expand = c(0, 0), limits = c(min_y, max_y), breaks = scales::pretty_breaks(11)) +
    scale_x_continuous(breaks = scales::pretty_breaks(5))

  # 4. Map the exact translated strings to their respective colors
  legend_colors <- set_names(
    c("royalblue1", "royalblue1", "forestgreen", "gold"),
    c(lbl_survey, lbl_ci, lbl_dhis2, lbl_wuenic)
  )

  plot +
    scale_color_manual(values = legend_colors, name = NULL) +
    cd_plot_theme(
      title = final_title,
      x_axis = final_x_axis,
      y_axis = final_y_axis,
      caption = final_caption
    ) +
    theme(
      panel.grid.major.y = element_line(colour = "lightblue1", linetype = "dashed"),
      panel.grid.major.x = element_line(colour = "gray90", linetype = "dashed")
    )
}


#' Plot Coverage by Region
#'
#' Generates a bar chart comparing indicator coverage across regions, highlighting
#' a specific region and categorizing performance as lower, average, or higher.
#'
#' @param x Data frame containing the coverage data.
#' @param indicator Character string specifying the indicator (e.g., 'penta1').
#' @param denominator Character string specifying the denominator ('penta1', 'anc1', 'dhis2', 'penta1derived').
#' @param year Integer representing the year to plot.
#' @param region Character string for the specific region to highlight in yellow.
#' @param title (Optional) Scalar character for a custom plot title.
#' @param x_axis (Optional) Scalar character for a custom x-axis label.
#' @param y_axis (Optional) Scalar character for a custom y-axis label.
#' @param caption (Optional) Scalar character for a custom plot caption.
#' @param labels (Optional) Named list to override the default category labels
#'   (e.g., `list(lower = "Low", average = "Avg", higher = "High")`).
#' @param ... Additional arguments.
#'
#' @export
plot.cd_coverage <- function(x, indicator = NULL, denominator = NULL, year = NULL, region = NULL,
                             title = NULL, x_axis = NULL, y_axis = NULL, caption = NULL, labels = NULL, ...) {

  # 1. Input Validation
  check_required(region)
  check_required(year)

  indicator <- arg_match(indicator, get_analysis_indicators())
  denominator <- arg_match(denominator, c('penta1', 'anc1', 'dhis2', 'penta1derived'))

  if (!is.null(title) && !is_scalar_character(title)) {
    cd_abort(c("x" = "{.arg title} must be a scalar character or NULL."))
  }
  if (!is.null(x_axis) && !is_scalar_character(x_axis)) {
    cd_abort(c("x" = "{.arg x_axis} must be a scalar character or NULL."))
  }
  if (!is.null(y_axis) && !is_scalar_character(y_axis)) {
    cd_abort(c("x" = "{.arg y_axis} must be a scalar character or NULL."))
  }
  if (!is.null(caption) && !is_scalar_character(caption)) {
    cd_abort(c("x" = "{.arg caption} must be a scalar character or NULL."))
  }

  indicator_col <- paste0('cov_', indicator, '_', denominator)
  admin_level <- attr_or_abort(x, 'admin_level')
  admin_level_cols <- get_admin_columns(admin_level, region)
  selected_year <- year

  # 2. Resolve Text and Labels (Allows for Translation/Customization)
  default_labels <- list(
    lower = "Lower than average",
    average = "Average",
    higher = "Higher than average"
  )

  user_labels <- if (is.null(labels)) list() else as.list(labels)
  final_labels <- utils::modifyList(default_labels, user_labels)

  lbl_lower <- final_labels$lower
  lbl_avg <- final_labels$average
  lbl_higher <- final_labels$higher

  indicator_pretty <- str_to_title(indicator)
  default_title <- str_glue("{indicator_pretty} immunization, by region, {selected_year} (HMIS)")

  final_title <- title %||% default_title
  final_x_axis <- x_axis %||% NULL
  final_y_axis <- y_axis %||% NULL
  final_caption <- caption %||% NULL

  # 3. Map Colors to the Dynamic Labels
  category_colors <- set_names(
    c("#145374", "#45A9E3", "#A9DCFA"),
    c(lbl_lower, lbl_avg, lbl_higher)
  )

  # 4. Process Data
  df <- x %>%
    filter(year == selected_year) %>%
    select(any_of(c(admin_level_cols, indicator_col))) %>%
    arrange(!!sym(indicator_col)) %>%
    mutate(
      category = case_when(
        !!sym(indicator_col) <= quantile(!!sym(indicator_col), 0.33, na.rm = TRUE) ~ lbl_lower,
        !!sym(indicator_col) <= quantile(!!sym(indicator_col), 0.66, na.rm = TRUE) ~ lbl_avg,
        .default = lbl_higher
      ),
      # Enforce factor levels so they plot in the correct order even with custom names
      category = factor(category, levels = c(lbl_lower, lbl_avg, lbl_higher))
    )

  # Calculate x-axis label placement based on the sorted order
  cat_positions <- df %>%
    mutate(x = as.numeric(factor(!!sym(admin_level), levels = unique(!!sym(admin_level))))) %>%
    summarise(x = mean(x, na.rm = TRUE), .by = category)

  # 5. Build the Plot
  df %>%
    ggplot(aes(x = factor(!!sym(admin_level), levels = unique(!!sym(admin_level))),
               y = !!sym(indicator_col),
               fill = category)) +
    geom_col(width = 1) +

    # Highlight the specific region
    geom_col(
      data = filter(df, !!sym(admin_level) == region),
      aes(x = !!sym(admin_level), y = !!sym(indicator_col)),
      fill = "yellow", color = "black", width = 1
    ) +

    # Add vertical text for the highlighted region
    geom_text(
      data = filter(df, !!sym(admin_level) == region),
      aes(x = !!sym(admin_level), y = !!sym(indicator_col) / 2, label = region),
      vjust = 0.5, angle = 90, hjust = 0.5,
      fontface = "bold", color = "black",
      size = 3
    ) +

    # Add the lower/average/higher labels at the bottom of the bars
    geom_label(
      data = cat_positions,
      aes(x = x, y = 10, label = category),
      inherit.aes = FALSE,
      size = 3,
      fill = "white",
      color = "black",
      label.size = 0
    ) +

    scale_fill_manual(values = category_colors) +
    scale_y_continuous(limits = c(0, 105), expand = c(0, 0)) +
    cd_plot_theme(
      title = final_title,
      x_axis = final_x_axis,
      y_axis = final_y_axis,
      caption = final_caption
    ) +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      legend.position = "none"
    )
}

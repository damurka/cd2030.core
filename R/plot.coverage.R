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

#' Create Dot Plots for Equity Analysis
#'
#' `equiplot` generates a dot plot to visualize the distribution of variables across
#' different groups (e.g., countries, regions, or interventions). It is designed for
#' equity analysis by plotting values for variables like health intervention coverage
#' across subgroups, allowing insights into disparities.
#'
#' @export
equiplot <- function(.data, variables, group_by,
                     title = NULL, subtitle = NULL, caption = NULL,
                     x_title = NULL, legend_title = NULL, legend_labels = NULL,
                     reverse_y_axis = FALSE, connect_dots = TRUE, dot_size = NULL) {
  Variable <- Value <- over_factor <- NULL

  # Input checks and data preparation
  if (!is.data.frame(.data)) {
    cd_abort(c("x" = "{.arg .data} must be a data frame."))
  }
  if (!all(variables %in% names(.data))) {
    cd_abort(c("x" = "The following variables are not found in the data provided: {.arg {variables}}."))
  }

  # Validate text inputs
  if (!is.null(title) && !rlang::is_scalar_character(title)) cd_abort(c("x" = "{.arg title} must be a scalar character or NULL."))
  if (!is.null(subtitle) && !rlang::is_scalar_character(subtitle)) cd_abort(c("x" = "{.arg subtitle} must be a scalar character or NULL."))
  if (!is.null(caption) && !rlang::is_scalar_character(caption)) cd_abort(c("x" = "{.arg caption} must be a scalar character or NULL."))

  group_by <- as.character(ensym(group_by))
  if (!(group_by %in% names(.data))) {
    cd_abort(c("x" = "{.arg group_by} variable not found in data."))
  }

  # Handle over variable
  .data <- .data %>%
    mutate(over_factor = fct_inorder(as.character(!!sym(group_by))))

  nlevels <- length(variables)

  # Color palettes
  colors <- switch(as.character(nlevels),
                   "2" = c("#15353B", "#FFB300"),
                   "3" = c("#15353B", "#46919D", "#FFB300"),
                   "4" = c("#15353B", "#005866", "#46919D", "#FFDA83"),
                   "5" = c("#15353B", "#005866", "#46919D", "#FFDA83", "#FFB300"),
                   "6" = c("#814374", "#51A39D", "#B7695C", "#CDBB79", "#D4D4D4", "#06425C"),
                   "7" = c("#814374", "#51A39D", "#B7695C", "#CDBB79", "#D4D4D4", "#06425C", "#968989"),
                   "10" = c("#201E1E", "#0C444E", "#415B61", "#196975", "#39767F", "#73A0A7", "#FFE7AB", "#FFCD58", "#D5B670", "#C38B09"),
                   grDevices::rainbow(nlevels)
  )

  dot_size_scale <- ifelse(is.null(dot_size), 4, pmin(pmax(dot_size, 1), 5))

  # Reshape data
  p_data <- .data %>%
    pivot_longer(cols = all_of(variables), names_to = "Variable", values_to = "Value")

  # Apply translated labels if provided (e.g., c("Rural" = "Rural (fr)"))
  if (!is.null(legend_labels)) {
    lbl_map <- unlist(legend_labels)
    p_data <- p_data %>%
      mutate(Variable = ifelse(Variable %in% names(lbl_map), lbl_map[Variable], Variable))

    # Update factors to match the new translated names while preserving order
    variables <- ifelse(variables %in% names(lbl_map), lbl_map[variables], variables)
  }

  p <- p_data %>%
    mutate(Variable = fct_inorder(factor(Variable, levels = variables))) %>%
    ggplot(aes(x = Value, y = over_factor, color = Variable)) +
    geom_point(size = dot_size_scale) +
    scale_x_continuous(breaks = scales::pretty_breaks(n = 10), limits = c(0, 100)) +
    scale_color_manual(values = colors, name = legend_title) +
    cd_plot_theme(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x_axis = x_title %||% "Percentage (%)",
      y_axis = ""
    ) +
    theme(
      panel.border = element_blank(),
      panel.grid.major.y = element_line(colour = "lightblue1", linetype = "dashed"),
      panel.grid.major.x = element_line(colour = "gray90", linetype = "dashed"),
      legend.background = element_blank(),
      legend.title = element_text(color = "#005866", hjust = 0.5),
      legend.position = "top",
      legend.title.position = "top",
      axis.text = element_text(color = "#005866"),
      axis.line = element_line(color = "#005866"),
      axis.ticks = element_line(color = "#005866")
    )

  if (connect_dots) {
    p <- p + geom_line(aes(group = over_factor), color = "dodgerblue")
  }
  if (reverse_y_axis) {
    p <- p + scale_y_discrete(limits = rev)
  }

  p
}

#' A Specialized Dot Plot for Area of Residence Analysis
#' @export
equiplot_area <- function(.data, indicator,
                          title = NULL, subtitle = NULL, caption = NULL,
                          x_title = NULL, legend_title = NULL, legend_labels = NULL,
                          dot_size = NULL) {
  year <- NULL
  check_equity_data(.data)
  indicator_arg <- arg_match(indicator, get_all_indicators())

  indicator_col <- paste0("r_", indicator_arg)

  .data %>%
    select(year, level, !!sym(indicator_col)) %>%
    mutate(level = str_to_title(level)) %>%
    pivot_wider(names_from = level, values_from = !!sym(indicator_col)) %>%
    equiplot(
      variables = c("Rural", "Urban"),
      group_by = year,
      title = title,
      subtitle = subtitle,
      caption = caption,
      x_title = x_title %||% paste0(indicator_arg, " Coverage (%)"),
      legend_title = legend_title %||% "Area of residence",
      legend_labels = legend_labels,
      reverse_y_axis = TRUE,
      dot_size = dot_size
    )
}

#' A Specialized Dot Plot for Maternal Education Analysis
#' @export
equiplot_education <- function(.data, indicator,
                               title = NULL, subtitle = NULL, caption = NULL,
                               x_title = NULL, legend_title = NULL, legend_labels = NULL,
                               dot_size = NULL) {
  year <- NULL
  check_equity_data(.data)
  indicator_arg <- arg_match(indicator, get_all_indicators())

  indicator_col <- paste0("r_", indicator_arg)

  .data %>%
    select(year, level, !!sym(indicator_col)) %>%
    mutate(
      level = case_match(
        level,
        "none" ~ "No education",
        "primary" ~ "Primary",
        "secondary+" ~ "Secondary or higher"
      )
    ) %>%
    pivot_wider(names_from = level, values_from = !!sym(indicator_col)) %>%
    equiplot(
      variables = c("No education", "Primary", "Secondary or higher"),
      group_by = year,
      title = title,
      subtitle = subtitle,
      caption = caption,
      x_title = x_title %||% paste0(indicator_arg, " Coverage (%)"),
      legend_title = legend_title %||% "Maternal Education",
      legend_labels = legend_labels,
      reverse_y_axis = TRUE,
      dot_size = dot_size
    )
}

#' A Specialized Dot Plot for Wealth Quintile Analysis
#' @export
equiplot_wealth <- function(.data, indicator,
                            title = NULL, subtitle = NULL, caption = NULL,
                            x_title = NULL, legend_title = NULL, legend_labels = NULL,
                            dot_size = NULL) {
  year <- NULL
  check_equity_data(.data)
  indicator_arg <- arg_match(indicator, get_all_indicators())

  indicator_col <- paste0("r_", indicator_arg)

  .data %>%
    select(year, level, !!sym(indicator_col)) %>%
    mutate(level = str_to_title(level)) %>%
    pivot_wider(names_from = level, values_from = !!sym(indicator_col)) %>%
    equiplot(
      variables = c("Q1", "Q2", "Q3", "Q4", "Q5"),
      group_by = year,
      title = title,
      subtitle = subtitle,
      caption = caption,
      x_title = x_title %||% paste0(indicator_arg, " Coverage (%)"),
      legend_title = legend_title %||% "Wealth quintiles",
      legend_labels = legend_labels,
      reverse_y_axis = TRUE,
      dot_size = dot_size
    )
}

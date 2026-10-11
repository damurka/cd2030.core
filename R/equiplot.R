#' Create dot plots for equity analysis
#'
#' `equiplot` generates a dot plot to visualize the distribution of variables across
#' different groups (e.g., countries, regions, or interventions). It is designed for
#' equity analysis by plotting values for variables like health intervention coverage
#' across subgroups, allowing insights into disparities.
#'
#' @param .data A data frame with one row per group and one column per variable
#'   (values in percent, plotted on a 0-100 scale).
#' @param variables Character vector of the column names to plot as dots; each
#'   becomes a coloured series.
#' @param group_by The column (unquoted or as a string) whose values form the
#'   rows of the plot (y axis).
#' @param title,subtitle,caption Optional plot title, subtitle and caption.
#'   Each must be a single string or `NULL`.
#' @param x_title Optional x-axis title. Defaults to a percentage label.
#' @param legend_title Optional title of the colour legend.
#' @param legend_labels Optional named vector or list mapping variable names to
#'   display labels (for example translated labels).
#' @param reverse_y_axis Logical. Whether to reverse the order of the groups on
#'   the y axis. Default is `FALSE`.
#' @param connect_dots Logical. Whether to draw a line connecting the dots of
#'   each group. Default is `TRUE`.
#' @param dot_size Optional dot size, clamped to 1-5. Defaults to 4.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' coverage <- data.frame(
#'   region = c("North", "Centre", "South"),
#'   poorest = c(42, 55, 61),
#'   richest = c(78, 83, 90)
#' )
#' equiplot(coverage, variables = c("poorest", "richest"), group_by = region)
#'
#' equiplot(coverage, c("poorest", "richest"), group_by = region,
#'          title = "Skilled birth attendance by wealth", legend_title = "Wealth quintile",
#'          legend_labels = c(poorest = "Poorest", richest = "Richest"), connect_dots = FALSE)
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
      x_title = x_title %||% "Percentage (%)",
      y_title = ""
    ) +
    cd_dashed_grid_theme() +
    theme(
      panel.border = element_blank(),
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

#' A specialized dot plot for area of residence analysis
#'
#' Plots rural and urban survey estimates of an indicator by year.
#'
#' @param .data Equity survey data with `year`, `level` and `r_<indicator>`
#'   columns.
#' @param indicator Character. The indicator to plot; its `r_<indicator>` column
#'   is used.
#' @inheritParams cd_plot_arguments
#' @param legend_labels Optional named vector or list mapping group names to
#'   display labels.
#' @param dot_size Optional dot size, clamped to 1-5. Defaults to 4.
#'
#' @return A `ggplot` object: the dot plot drawn by [equiplot()], with one row per survey year and one
#'   dot each for rural and urban, and the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' # the dataset object gives the package's survey estimates for the country, by residence
#' equiplot_area(cache$area_survey, "anc4")
#'
#' equiplot_area(cache$area_survey, "anc4", title = "Four antenatal visits by residence",
#'               legend_title = "Residence", legend_labels = list(Rural = "Rural areas", Urban = "Towns"))
#'
#' @export
equiplot_area <- function(.data,
                          indicator,
                          dot_size = NULL,
                          title = NULL,
                          subtitle = NULL,
                          caption = NULL,
                          x_title = NULL,
                          y_title = NULL,
                          legend_title = NULL,
                          ...,
                          legend_labels = NULL,
                          options = NULL) {
  .cd_draw(.equiplot_area_impl, .data, list(indicator = indicator, legend_labels = legend_labels, dot_size = dot_size), ..., options = options)
}

.equiplot_area_impl <- function(.data, indicator,
                          title = NULL, subtitle = NULL, caption = NULL,
                          x_title = NULL, legend_title = NULL, legend_labels = NULL,
                          dot_size = NULL) {
  year <- NULL
  check_cd_equity_data(.data)
  indicator_arg <- arg_match(indicator, unique(c(get_all_indicators(), get_analysis_indicators())))

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

#' A specialized dot plot for maternal education analysis
#'
#' Plots survey estimates of an indicator by year for each level of maternal
#' education.
#'
#' @inheritParams equiplot_area
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot` object: the dot plot drawn by [equiplot()], with one row per survey year and one
#'   dot for each level of maternal education, and the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' # the dataset object gives the package's survey estimates for the country, by maternal education
#' equiplot_education(cache$education_survey, "penta3")
#'
#' equiplot_education(cache$education_survey, "penta3", title = "Penta3 by education of the mother",
#'                    x_title = "Penta3 coverage (%)", dot_size = 3, legend_position = "bottom")
#'
#' @export
equiplot_education <- function(.data,
                               indicator,
                               dot_size = NULL,
                               title = NULL,
                               subtitle = NULL,
                               caption = NULL,
                               x_title = NULL,
                               y_title = NULL,
                               legend_title = NULL,
                               ...,
                               legend_labels = NULL,
                               options = NULL) {
  .cd_draw(.equiplot_education_impl, .data, list(indicator = indicator, legend_labels = legend_labels, dot_size = dot_size), ..., options = options)
}

.equiplot_education_impl <- function(.data, indicator,
                               title = NULL, subtitle = NULL, caption = NULL,
                               x_title = NULL, legend_title = NULL, legend_labels = NULL,
                               dot_size = NULL) {
  year <- NULL
  check_cd_equity_data(.data)
  indicator_arg <- arg_match(indicator, unique(c(get_all_indicators(), get_analysis_indicators())))

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

#' A specialized dot plot for wealth quintile analysis
#'
#' Plots survey estimates of an indicator by year for each wealth quintile.
#'
#' @inheritParams equiplot_area
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot` object: the dot plot drawn by [equiplot()], with one row per survey year and one
#'   dot for each wealth quintile (Q1 to Q5), and the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#'
#' # the dataset object gives the package's survey estimates for the country, by wealth quintile
#' equiplot_wealth(cache$wiq_survey, "instlivebirths")
#'
#' equiplot_wealth(cache$wiq_survey, "instlivebirths", title = "Institutional live births by wealth",
#'                 legend_title = "Quintile", caption = "Source: household surveys")
#'
#' @export
equiplot_wealth <- function(.data,
                            indicator,
                            dot_size = NULL,
                            title = NULL,
                            subtitle = NULL,
                            caption = NULL,
                            x_title = NULL,
                            y_title = NULL,
                            legend_title = NULL,
                            ...,
                            legend_labels = NULL,
                            options = NULL) {
  .cd_draw(.equiplot_wealth_impl, .data, list(indicator = indicator, legend_labels = legend_labels, dot_size = dot_size), ..., options = options)
}

.equiplot_wealth_impl <- function(.data, indicator,
                            title = NULL, subtitle = NULL, caption = NULL,
                            x_title = NULL, legend_title = NULL, legend_labels = NULL,
                            dot_size = NULL) {
  year <- NULL
  check_cd_equity_data(.data)
  indicator_arg <- arg_match(indicator, unique(c(get_all_indicators(), get_analysis_indicators())))

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

#' Load and Generate FPET Output
#'
#' Processes raw FPET data (e.g., from Track20 or UNFPA) into a structured tibble
#' for visualization and interpretation of modern contraceptive prevalence and
#' demand satisfied.
#'
#' @param .data An object of class `cd_fpet_data`.
#'
#' @return A `cd_fpet_data` object.
#'
#' @export
generate_fpet_summary <- function(.data) {
  check_cd_class(.data, 'cd_fpet_data')

  country <- .data %>%
    distinct(country) %>%
    pull(country)

  .data %>%
    filter(`Marital status` == "married") %>%
    select(
      Year, Percentile,
      `Prevalence of Modern Methods (mCPR) (%)`,
      `Demand Satisfied with a Modern Method (%)`
    ) %>%
    pivot_longer(
      cols = c(
        `Prevalence of Modern Methods (mCPR) (%)`,
        `Demand Satisfied with a Modern Method (%)`
      ),
      names_to = "indicator",
      values_to = "value"
    ) %>%
    pivot_wider(
      names_from = Percentile,
      values_from = value
    ) %>%
    filter(Year > 1999) %>%
    rename(
      year = Year,
      lower = `0.025`,
      median = `median`,
      upper = `0.975`
    ) %>%
    new_tibble(class = 'cd_fpet_data', country = country)
}


#' Plot Family Planning Estimation Tool (FPET) Data
#'
#' Generates a line and ribbon plot for FPET indicators (e.g., mCPR, Demand Satisfied) 
#' displaying median estimates and 95% credible intervals.
#'
#' @param x An object of class `cd_fpet_data`.
#' @param title (Optional) Custom translated title.
#' @param x_axis (Optional) Custom translated x-axis label.
#' @param y_axis (Optional) Custom translated y-axis label.
#' @param caption (Optional) Custom translated caption.
#' @param indicator_labels (Optional) A named list mapping raw indicator names to translated legend labels.
#' @param ... Additional arguments.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @export
plot.cd_fpet_data <- function(x,
                         title = NULL,
                         x_axis = NULL,
                         y_axis = NULL,
                         caption = NULL,
                         indicator_labels = NULL,
                         ..., options = NULL) {
  cd_finish_plot(.plot_cd_fpet_data_impl(x, title = title, x_axis = x_axis, y_axis = y_axis, caption = caption, indicator_labels = indicator_labels, ...), options, ..., .source = x)
}

.plot_cd_fpet_data_impl <- function(x,
                         title = NULL,
                         x_axis = NULL,
                         y_axis = NULL,
                         caption = NULL,
                         indicator_labels = NULL,
                         ...) {

  country_name <- attr_or_abort(x, 'country')
  default_title <- str_glue('Family planning among currently married women 15-49 years, {country_name}')

  t_title <- title %||% default_title
  t_x     <- x_axis %||% 'Year'
  t_y     <- y_axis %||% 'Percent of currently married women 15-49'
  t_cap   <- caption %||% 'Lines show the median estimates. Shaded bands represent the 95% credible interval.\nSource: FPET Track20 modeling'

  # 2. Translate Indicator labels for the legend safely
  if (!is.null(indicator_labels)) {
    lbl_map <- unlist(indicator_labels)
    x <- x %>%
      mutate(
        # Use recode to swap the raw DB names for the translated ones
        indicator = recode(indicator, !!!lbl_map, .default = indicator),
        # Convert to factor to lock in the legend order
        indicator = factor(indicator, levels = unique(lbl_map))
      )
  }

  x %>%
    # filter(year >= 2010) %>% 
    ggplot(aes(x = year, color = indicator, fill = indicator)) +
      geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.2, colour = NA) +
      geom_line(aes(y = median), linewidth = 1.2) +
      geom_point(aes(y = median), size = 2) +
      scale_y_continuous(labels = scales::percent, limits = c(0, NA)) +
      labs(color = NULL, fill = NULL) +
      cd_plot_theme(
        title = t_title,
        x_axis = t_x,
        y_axis = t_y,
        caption = t_cap
      ) +
      theme(
        legend.position = "bottom",
        legend.title = element_blank()
      )
}

#' Generic Interpretation Method
#'
#' A generic method to extract narrative interpretation from structured data objects.
#'
#' @param x An object.
#' @param ... Additional arguments passed to methods.
#'
#' @export
interpret <- function(x, ...) {
  UseMethod("interpret")
}

#' Interpret FPET Results with Emphasis on Current Estimates
#'
#' Summarizes 2020 and 2024 estimates, and briefly mentions FPET projections to 2030.
#'
#' @param x A `cd_fpet_data` object.
#' @param ... Unused.
#'
#' @return A character string with interpretation summary.
#'
#' @export
interpret.cd_fpet_data <- function(x, ...) {
  check_cd_fpet(x)
  country <- attr_or_abort(x, "country")

  focus_years <- c(2020, 2024)

  summary_df <- x %>%
    filter(year %in% focus_years) %>%
    select(indicator, year, median) %>%
    pivot_wider(names_from = year, values_from = median, names_prefix = "y") %>%
    mutate(
      change = y2024 - y2020,
      direction = case_when(
        change > 0 ~ "increased",
        change < 0 ~ "decreased",
        TRUE ~ "remained stable"
      ),
      change = round(change, 3)
    )

  # Summary text
  trend_text <- paste0(
    summary_df$indicator, ": ", summary_df$direction,
    " by ", summary_df$change, " points"
  )

  str_glue(
    "In {country}, between 2020 and 2024:\n",
    "{paste(trend_text, collapse = '\n')}\n\n",
    "The graphs also include FPET projections with credible intervals through 2030."
  ) %>%
    as.character()
}

#' Load and generate FPET output
#'
#' Processes raw FPET data (e.g., from Track20 or UNFPA) into a structured tibble
#' for visualization and interpretation of modern contraceptive prevalence and
#' demand satisfied.
#'
#' @param .data An object of class `cd_fpet_data`.
#'
#' @return A `cd_fpet_data` object.
#'
#' @examples
#' \dontrun{
#' # an FPET results file (.csv) for the country
#' fpet <- load_fpet_data(path = "fpet_kenya.csv", country_iso = "KEN")
#'
#' summary <- generate_fpet_summary(fpet)
#' plot(summary)
#' interpret(summary)
#' }
#'
#' @export
generate_fpet_summary <- function(.data) {
  check_cd_fpet_data(.data)

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


#' Plot family planning estimation tool (FPET) data
#'
#' Generates a line and ribbon plot for FPET indicators (e.g., mCPR, Demand Satisfied) 
#' displaying median estimates and 95% credible intervals.
#'
#' @param x An object of class `cd_fpet_data`.
#' @inheritParams cd_plot_arguments
#' @param indicator_labels (Optional) A named list mapping raw indicator names to translated legend labels.
#'
#'
#' @return A `ggplot` object with the chart options applied: one line per indicator by year, with a
#'   shaded band for the credible interval.
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#' fpet <- cache$fpet_data
#'
#' plot(fpet)
#' plot(
#'   fpet,
#'   indicator_labels = list(prevalence = "Modern contraceptive prevalence", demand = "Demand satisfied"),
#'   title = "Family planning in Kenya"
#' )
#' @export
plot.cd_fpet_data <- function(x,
                              indicator_labels = NULL,
                              title = NULL,
                              subtitle = NULL,
                              caption = NULL,
                              x_title = NULL,
                              y_title = NULL,
                              legend_title = NULL,
                              ...,
                              options = NULL) {
  .cd_draw(.plot_cd_fpet_data_impl, x, list(indicator_labels = indicator_labels), ..., options = options)
}

.plot_cd_fpet_data_impl <- function(x,
                         title = NULL,
                         x_title = NULL,
                         y_title = NULL,
                         caption = NULL,
                         indicator_labels = NULL,
                         ...) {

  country_name <- attr_or_abort(x, 'country')
  default_title <- str_glue('Family planning among currently married women 15-49 years, {country_name}')

  t_title <- title %||% default_title
  t_x     <- x_title %||% 'Year'
  t_y     <- y_title %||% 'Percent of currently married women 15-49'
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
        x_title = t_x,
        y_title = t_y,
        caption = t_cap
      ) +
      theme(
        legend.position = "bottom",
        legend.title = element_blank()
      )
}

#' Generic interpretation method
#'
#' A generic method to extract narrative interpretation from structured data objects.
#'
#' @param x An object.
#' @param ... Additional arguments passed to methods.
#'
#' @return What the method for the class of `x` returns. The method for `cd_fpet_data`
#'   ([interpret.cd_fpet_data()]) returns a character string.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#'
#' # the family planning estimates that come with the dataset
#' interpret(cache$fpet_data)
#'
#' @export
interpret <-function(x, ...) {
  UseMethod("interpret")
}

#' Interpret FPET results with emphasis on current estimates
#'
#' Summarizes 2020 and 2024 estimates, and briefly mentions FPET projections to 2030.
#'
#' @param x A `cd_fpet_data` object.
#' @param ... Unused.
#'
#' @return A character string with interpretation summary.
#'
#' @examples
#' path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
#' cache <- load_cache_data(path)
#'
#' text <- interpret(cache$fpet_data)
#' cat(text)
#'
#' @export
interpret.cd_fpet_data <- function(x, ...) {
  check_cd_fpet_data(x)
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
    # the size of the change: its direction is said already ("decreased by -0.005" said it twice)
    ifelse(summary_df$change == 0, "", paste0(" by ", abs(summary_df$change)))
  )

  str_glue(
    "In {country}, between 2020 and 2024:\n",
    "{paste(trend_text, collapse = '\n')}\n\n",
    "The graphs also include FPET projections with credible intervals through 2030."
  ) %>%
    as.character()
}

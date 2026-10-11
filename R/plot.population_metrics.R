#' Plot national population or births metrics
#'
#' Generates a line graph to visualize national-level demographic data, comparing
#' DHIS-2 data/projections against UN estimates. This function is restricted to
#' national-level data.
#'
#' @param x A `cd_population_metrics` object containing national-level demographic data.
#' @param metric A character string specifying the type of data to plot. Must be one of:
#'   - **'population'**: Total population estimates (in thousands).
#'   - **'births'**: Total live births (in thousands).
#'   - **'under1'**: Population under 1 year of age (in thousands).
#' @inheritParams cd_plot_arguments
#' @param legend_labels Optional. A character vector of custom labels for the legend items.
#'   Must match the number of lines plotted for the selected metric:
#'   - 'population': 2 labels
#'   - 'births': 3 labels
#'   - 'under1': 2 labels
#'
#' @details
#' The function compares local Health Management Information System (DHIS-2) data
#' with United Nations (UN) estimates.
#'
#' **Default Configuration:**
#' * **Population**: Compares `un_population` vs `totpop_dhis2`.
#' * **Births**: Compares `un_births` vs `totlivebirths_dhis2` vs `totbirths_dhis2`.
#' * **Under 1**: Compares `un_under1` vs `totunder1_dhis2`.
#'
#' @return A ggplot object.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' population <- cache$denominator_metrics
#'
#' plot(population, metric = "population")
#' plot(population, metric = "births", title = "Births: DHIS2 and the UN", y_title = "Thousands",
#'      legend_labels = c("UN live births", "DHIS2 live births", "DHIS2 births"))
#'
#' @export
plot.cd_population_metrics <- function(x,
                                       metric = c("population", "births", "under1"),
                                       title = NULL,
                                       subtitle = NULL,
                                       caption = NULL,
                                       x_title = NULL,
                                       y_title = NULL,
                                       legend_title = NULL,
                                       ...,
                                       legend_labels = NULL,
                                       options = NULL) {
  .cd_draw(.plot_cd_population_metrics_impl, x, list(metric = metric, legend_labels = legend_labels), ..., options = options)
}

.plot_cd_population_metrics_impl <- function(x, metric = c("population", "births", "under1"),
                                       title = NULL,
                                       x_title = NULL,
                                       y_title = NULL,
                                       legend_labels = NULL,
                                       ...) {
  year <- un_population <- totpop_dhis2 <- un_births <- totlivebirths_dhis2 <- NULL

  # 1. Validate arguments
  metric <- arg_match(metric)

  admin_level <- attr_or_abort(x, "admin_level")
  if (admin_level != "national") {
    cd_abort(c("x" = "This plot supports only national-level data due to the requirement of UN estimates."))
  }

  # 2. Define Defaults Configuration
  # This list maps each metric to its specific data columns and text
  defaults <- list(
    population = list(
      y_vars = c("un_population", "totpop_dhis2"),
      legend_labels = c("UN Population (in 1000)", "DHIS-2 Population Projection (in 1000)"),
      title = "Total Population (in thousands), DHIS2 and UN projections"
    ),
    births = list(
      y_vars = c("un_births", "totlivebirths_dhis2", "totbirths_dhis2"),
      legend_labels = c("UN Live Births (in 1000)", "DHIS-2 Live Births Projection (in 1000)", "DHIS-2 Total Births Projection (in 1000)"),
      title = "Total Live Births (in thousands), DHIS2 and UN projections"
    ),
    under1 = list(
      y_vars = c("un_under1", "totunder1_dhis2"),
      legend_labels = c("UN Under 1 (in 1000)", "DHIS-2 Under 1 Projection (in 1000)"),
      title = "Under 1 (in thousands), DHIS2 and UN projections"
    )
  )

  # 3. Retrieve the specific config for the selected metric
  config <- defaults[[metric]]

  # 4. Resolve final values (User input takes priority over defaults)
  # Uses the %||% operator (from rlang/purrr) to check for NULL
  final_title <- title %||% config$title
  final_labels <- legend_labels %||% config$legend_labels
  x_title <- x_title %||% "Year"
  y_title <- y_title %||% "population"

  # 5. Call the plotting function once
  plot_line_graph(
    .data = x,
    x = "year",
    y_vars = config$y_vars,
    title = final_title,
    y_title = y_title,
    x_title = x_title,
    legend_labels = final_labels,
  )
}

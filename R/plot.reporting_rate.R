#' Plot sub-national reporting rates by year and unit
#'
#' Visualizes reporting rates for selected health service indicators at sub-national levels,
#' using heat maps or bar plots. Intended for use with outputs from
#' `calculate_average_reporting_rate()` at `"adminlevel_1"` or `"district"` level.
#'
#' @param x A `cd_average_reporting_rate` object, typically the output from
#'   `calculate_average_reporting_rate()`. Must contain subnational data.
#' @param plot_type Either `"heat_map"` or `"bar"`:
#'   - `"heat_map"`: Shows reporting rates using color-coded tiles by year and unit.
#'   - `"bar"`: Displays reporting rates as bars, grouped by year and faceted by unit.
#' @param indicator One of the following:
#'   - `"anc_rr"`: Antenatal care
#'   - `"idelv_rr"`: Institutional deliveries
#'   - `"vacc_rr"`: Vaccination
#'   - `"opd_rr"`: Outpatient visits
#'   - `"ipd_rr"`: Inpatient admissions
#' @param threshold Numeric value (default = 90). Used only in `"heat_map"` mode to define
#'   the boundary for high reporting rates.
#' @inheritParams cd_plot_arguments
#'
#' @details
#' Only subnational objects are accepted. If the data was computed at `"adminlevel_1"` with a
#' `region` argument, the object is automatically treated as `"district"` level and plotted
#' by district name.
#'
#' **Heat Map Mode**:
#' - Each tile represents a reporting rate for a unit and year.
#' - Colors:
#'   - Green: `>= threshold`
#'   - Orange: `70 <= value < threshold`
#'   - Red: `< 70`
#' - Labels display the actual percentage.
#'
#' **Bar Mode**:
#' - Bars show values per year.
#' - Units (regions or districts) appear as facets.
#' - Color gradient shows low to high reporting.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' # Heat map for vaccination at district level
#' x <- calculate_average_reporting_rate(data, admin_level = "district")
#' plot(x, plot_type = "heat_map", indicator = "vacc_rr")
#'
#' # Bar chart by district in selected region
#' x <- calculate_average_reporting_rate(data, admin_level = "adminlevel_1", region = "Nairobi")
#' plot(x, plot_type = "bar", indicator = "idelv_rr")
#' }
#'
#' @export

plot.cd_average_reporting_rate <- function(x,
                                           plot_type = c("heat_map", "bar"),
                                           indicator = c("anc_rr", "idelv_rr", "vacc_rr", "opd_rr", "ipd_rr"),
                                           threshold = .cd_method$data_quality$reporting_threshold,
                                           title = NULL,
                                           subtitle = NULL,
                                           caption = NULL,
                                           x_title = NULL,
                                           y_title = NULL,
                                           legend_title = NULL,
                                           ...,
                                           options = NULL) {
  .cd_draw(.plot_cd_average_reporting_rate_impl, x, list(plot_type = plot_type, indicator = indicator, threshold = threshold), ..., options = options)
}

.plot_cd_average_reporting_rate_impl <- function(x,
                                           plot_type = c("heat_map", "bar"),
                                           indicator = c("anc_rr", "idelv_rr", "vacc_rr", "opd_rr", "ipd_rr"),
                                           threshold = .cd_method$data_quality$reporting_threshold,
                                           title = NULL,
                                           x_title = NULL,
                                           y_title = NULL,
                                           legend_title = NULL,
                                           ...) {
  check_scalar_integerish(threshold)

  plot_type <- arg_match(plot_type)
  indicator <- arg_match(indicator)

  admin_level <- attr_or_abort(x, "admin_level")
  if (admin_level == "national") {
    cd_abort(c("x" = "{.fun plot.cd_average_reporting_rate} does not support national-level data."))
  }

  region <- attr_or_null(x, "region")
  admin_level_col <- get_plot_admin_column(admin_level, region)

  labels <- list(
    heat_map = list(
      legend_title = str_glue("{indicator} Category"),
      x = if (admin_level_col == "district") "District" else "Admin Level 1",
      y = "Year",
      title = str_glue("Reporting rates by years and {str_to_title(admin_level_col)} in {region}")
    ),
    bar = list(
      legend_title = "Reporting Rate",
      x = "Year",
      y = "Reporting Rate",
      title = str_glue("Reporting rates by years and {str_to_title(admin_level_col)} in {region}")
    )
  )
  label <- labels[[plot_type]]

  plot_title <- if (!is.null(title)) title else label$title
  plot_x <- if (!is.null(x_title)) x_title else label$x
  plot_y <- if (!is.null(y_title)) y_title else label$y
  plot_leg <- if (!is.null(legend_title)) legend_title else label$legend_title

  all_years <- sort(unique(x$year))

  greater <- paste0("\u2265 ", threshold)
  mid <- paste0("\u2265 70 and < ", threshold)
  low <- "< 70"

  lvl <- c(low, mid, greater)

  dt <- x %>%
    mutate(
      year = factor(year, levels = all_years),
      color_category = case_when(
        !!sym(indicator) >= threshold ~ greater,
        !!sym(indicator) >= 70 & !!sym(indicator) < threshold ~ mid,
        .default = low,
        .ptype = factor(levels = lvl)
      )
    )

  if (plot_type == "heat_map") {
    ggplot(dt, aes(x = !!sym(admin_level_col), y = year, fill = color_category)) +
      geom_tile(color = "white", show.legend = TRUE) +
      .cd_category_fill(lvl) +
      scale_x_discrete(expand = expansion(mult = 0)) +
      scale_y_discrete(expand = expansion(mult = 0)) +
      geom_text(aes(label = !!sym(indicator)), color = "black", size = 4, vjust = 0.5) +
      cd_heatmap_theme(
        title = plot_title,
        x_title = plot_x,
        y_title = plot_y,
        legend_title = plot_leg
      )
  } else {
    ggplot(dt, aes(year, !!sym(indicator), fill = color_category)) +
      geom_col(show.legend = TRUE) +
      facet_wrap(as.formula(paste0("~", admin_level_col))) +
      .cd_category_fill(lvl) +
      scale_x_discrete( drop = FALSE, expand = expansion(mult = c(0, 0.05))) +
      cd_bar_theme(
        title = plot_title,
        x_title = plot_x,
        y_title = plot_y,
        legend_title = plot_leg
      )
  }
}

#' Plot district reporting rate summary
#'
#' Generates a bar plot displaying the percentage of districts with reporting rates below
#' the defined threshold for multiple indicators across various years. This plot provides
#' a quick visual assessment of district-level reporting compliance across indicators
#' like ANC, Institutional Delivery, PNC, Vaccination, OPD, and IPD.
#'
#' @param x A `cd_district_reporting_rate` data frame containing reporting rate data,
#'   processed by [calculate_district_reporting_rate()].
#' @inheritParams cd_plot_arguments
#' @param indicator_labels Optional named character vector of panel titles,
#'   keyed by short indicator name (`anc`, `idelv`, `vacc`, `pnc`, `opd`,
#'   `ipd`). Supplied entries replace the defaults.
#'
#' @details
#' Inverts the percentages in `x` (the percentage of districts at or above the threshold) to
#' display the percentage of districts with rates below the threshold for each indicator (e.g.,
#' if 95% of districts reach the threshold, 5% are shown as below it). Each indicator is visualized
#' in a separate panel with data grouped by year, providing an overview of performance
#' trends over time.
#'
#' Indicators plotted include:
#' * **Antenatal Care (ANC)** - Percentage of districts meeting or exceeding target rates
#' * **Institutional Delivery** - Institutional delivery compliance over time
#' * **Postnatal Care (PNC)** - Districts' PNC service rates against thresholds
#' * **Vaccination** - Vaccination service coverage at district level
#' * **Outpatient Department (OPD)** - OPD reporting rates in districts
#' * **Inpatient Department (IPD)** - IPD reporting compliance by district
#'
#' The plot output includes a title, axis labels, and a legend for year, allowing
#' users to identify service areas with low reporting compliance.
#'
#' @return A ggplot object visualizing reporting rates across indicators and years.
#'
#' @examples
#' \dontrun{
#' # Generate a plot of district reporting rates below a threshold of 90%
#' plot(cd_district_reporting_rate(data), threshold = 90)
#' }
#' @param facet_ncol Integer. The number of columns the service panels are laid out in. Default is `3`,
#'   so four services are drawn as a row of three and a row of one.
#' @export
plot.cd_district_reporting_rate <- function(x,
                                            indicator_labels = NULL,
                                            facet_ncol = 3,
                                            title = NULL,
                                            subtitle = NULL,
                                            caption = NULL,
                                            x_title = NULL,
                                            y_title = NULL,
                                            legend_title = NULL,
                                            ...,
                                            options = NULL) {
  .cd_draw(.plot_cd_district_reporting_rate_impl, x, list(indicator_labels = indicator_labels, facet_ncol = facet_ncol), ..., options = options)
}

.plot_cd_district_reporting_rate_impl <- function(x,
                                            title = NULL,
                                            x_title = NULL,
                                            y_title = NULL,
                                            caption = NULL,
                                            indicator_labels = NULL,
                                            facet_ncol = 3,
                                            ...) {
  # facet_ncol = 3 is the layout from before the argument existed: callers that do not pass it are unchanged.
  year = value = indicator = low_mean_rr = NULL

  threshold <- attr(x, "threshold")

  years <- x %>%
    distinct(year) %>%
    pull(year)
  colors <- cd_year_colours(years, .cd_palette$years_reporting)

  plot_title <- if (!is.null(title)) title else paste("Percentage of districts with low reporting rate (<", threshold, "%) by service and by year")
  plot_x <- if (!is.null(x_title)) x_title else NULL
  plot_y <- if (!is.null(y_title)) y_title else "%"
  plot_cap <- if (!is.null(caption)) caption else paste("Low reporting rate (<", threshold, "%)")

  default_labels <- c(
    anc   = "Antenatal Care",
    idelv = "Institutional Delivery",
    vacc  = "Vaccination",
    pnc   = "Postnatal Care",
    opd   = "OPD",
    ipd   = "IPD"
  )

  labels_map <- default_labels
  labels_map[names(indicator_labels)] <- indicator_labels

  # Invert the reporting rates and reshape for plotting
  x %>%
    select(-starts_with("low_mean_")) %>%
    mutate(across(starts_with("low_"), ~ 100 - ., .names = "inv_{col}")) %>%
    pivot_longer(cols = starts_with("inv_low_"), names_to = "indicator") %>%
    # Define indicator names and corresponding titles
    mutate(
      short_indicator = str_remove(indicator, "^inv_low_"),
      short_indicator = str_remove(short_indicator, "_rr$"),
      title = recode(short_indicator, !!!labels_map, .default = short_indicator)
    ) %>%
    # Create the plot with facet_wrap
    ggplot(aes(x = as.factor(year), y = value, fill = as.factor(year))) +
    geom_col(position = "dodge") +
    geom_text(aes(label = round(value, 0)), position = position_dodge(width = 0.9), vjust = -1.5, color = "black", size = 3) +
    facet_wrap(~title, scales = "free_y", ncol = facet_ncol) +
    scale_fill_manual(values = colors) +
    scale_y_continuous(
      limits = c(0, 100),
      breaks = scales::pretty_breaks(n = 6),
      expand = c(0, 0)
    ) +
    cd_plot_theme(
      title = plot_title,
      x_title = plot_x,
      y_title = plot_y,
      caption = plot_cap
    ) +
    theme(
      panel.grid.major.y = element_line(colour = "gray90", linewidth = 0.5),
      axis.text.x = element_blank(),
      axis.ticks = element_blank()
    )
}

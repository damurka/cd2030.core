#' Plot mortality rate indicators
#'
#' Produces line plots for national mortality indicators with regional points for comparison.
#'
#' @param x A `cd_mortality_summary` object.
#' @param indicator One of `"mmr_inst"`, `"ratio_md_sb"`, `"sbr_inst"`, or `"nn_inst"`.
#' @param legend_labels (Optional) A named list to override the legend's entries, e.g. with translations: `national` (the
#'   national line) and `regions` (the regional points). Defaults to `NULL`.
#' @inheritParams cd_plot_arguments
#'
#' @return A ggplot object.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' mortality <- cache$mortality_summary
#'
#' plot(mortality, indicator = "mmr_inst")
#' plot(mortality, indicator = "sbr_inst", title = "Institutional stillbirth rate",
#'      legend_labels = list(national = "Kenya", regions = "Regions"), legend_position = "bottom")
#'
#' @export
plot.cd_mortality_summary <- function(x,
                                      indicator = c("mmr_inst", "ratio_md_sb", "sbr_inst", "nn_inst"),
                                      title = NULL,
                                      subtitle = NULL,
                                      caption = NULL,
                                      x_title = NULL,
                                      y_title = NULL,
                                      legend_title = NULL,
                                      ...,
                                      legend_labels = NULL,
                                      options = NULL) {
  .cd_draw(.plot_cd_mortality_summary_impl, x, list(indicator = indicator, legend_labels = legend_labels), ..., options = options)
}

.plot_cd_mortality_summary_impl <- function(x, indicator = c('mmr_inst', 'ratio_md_sb', 'sbr_inst', 'nn_inst'), title = NULL, legend_labels = NULL, ...) {
  indicator <- arg_match(indicator)
  labels <- as.list(legend_labels)[intersect(names(legend_labels), c('national', 'regions'))]

  default_labels <- list(
    title = switch(
      indicator,
      mmr_inst = 'Maternal mortality per 100,000 live births in health facilities',
      ratio_md_sb = 'Ratio number of stillbirths to maternal deaths in health facilities',
      sbr_inst = 'Stillbirths per 1,000 births in health facilities',
      nn_inst = 'Neonatal deaths before discharge per 1,000 live births in health facilities'
    ),
    national = switch(
      indicator,
      mmr_inst = 'National inst. MMR',
      nn_inst = 'National NN',
      sbr_inst = 'National inst. SBR',
      ratio_md_sb = 'National SB/MM ratio'
    ),
    regions = 'Regions'
  )
  final_labels <- utils::modifyList(default_labels, if (is.null(labels)) list() else as.list(labels))

  label <- final_labels$national
  title <- title %||% final_labels$title
  lbl_regions <- final_labels$regions

  national <- x %>% filter(adminlevel_1 == 'National')
  regional <- x %>% filter(adminlevel_1 != 'National')

  max_y <- robust_max(x[[indicator]], 100)
  limits <- c(0, max_y)
  breaks <- scales::pretty_breaks(n = 11)(limits)

  ggplot() +
    geom_point(data = regional, aes(x = year, y = !!sym(indicator), color = lbl_regions), size = 2, alpha = 0.7) +
    geom_line(data = national, aes(x = year, y = !!sym(indicator), color = label), linewidth = 1.2) +
    geom_point(data = national, aes(x = year, y = !!sym(indicator), color = label), size = 2) +
    geom_text(
      data = national,
      aes(x = year, y = !!sym(indicator), label = round(!!sym(indicator), 1)),
      color = 'black', vjust = -0.5, hjust = -0.1, size = 3
    ) +
    scale_y_continuous(limits = limits, breaks = breaks, expand = expansion(mult = c(0, 0.05))) +
    scale_color_manual(values = set_names(.cd_palette$regions_national, c(lbl_regions, label)), breaks = c(label, lbl_regions)) +
    cd_plot_theme(
      title = title
    ) +
    # the legend's entries say what they are; without this its title would be the name of a variable in this code
    labs(color = NULL)
}


#' Plot completeness of facility reporting ratios
#'
#' Calculates and plots the estimated completeness of facility reporting
#' for maternal deaths or stillbirths based on UN estimates and assumed
#' community-to-institution ratios.
#'
#' @param x A `cd_mortality_ratio_summarised ` object from completeness estimation.
#' @param legend_labels (Optional) A named list to override the legend's entries, e.g. with translations: `lower`, `best`
#'   and `upper` (the UN lower bound, best estimate and upper bound). Defaults to `NULL`.
#' @inheritParams cd_plot_arguments
#'
#' @return A ggplot object with ratio lines, labels, and reference points.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' completeness <- cache$summarise_completeness_ratio("mmr")
#'
#' plot(completeness)
#' plot(completeness, title = "Completeness of maternal death reporting", y_title = "Completeness (%)",
#'      legend_labels = list(lower = "UN lower bound", best = "UN best estimate", upper = "UN upper bound"))
#'
#' @export
plot.cd_mortality_ratio_summarised <- function(x,
                                               title = NULL,
                                               subtitle = NULL,
                                               caption = NULL,
                                               x_title = NULL,
                                               y_title = NULL,
                                               legend_title = NULL,
                                               ...,
                                               legend_labels = NULL,
                                               options = NULL) {
  .cd_draw(.plot_cd_mortality_ratio_summarised_impl, x, list(legend_labels = legend_labels), ..., options = options)
}

.plot_cd_mortality_ratio_summarised_impl <- function(x, title = NULL, x_title = NULL, y_title = NULL, legend_labels = NULL, ...) {

  plot_type <- attr_or_abort(x, 'plot_type')
  user_labels <- as.list(legend_labels)[intersect(names(legend_labels), c('lower', 'best', 'upper'))]

  lower_bound <- paste0('UN ', str_to_upper(plot_type),' lower bound')
  upper_bound <- paste0('UN ', str_to_upper(plot_type),' upper bound')
  best_estimates <- paste0('UN ', str_to_upper(plot_type),' best estimate')

  labels <- list(
    sbr = list(
      title = 'Completeness of facility stillbirth reporting (%), based on UN stillbirth estimates and community to institutional ratio',
      x = 'Ratio Community SBR to Institutional SBR',
      y = 'Completeness stillbirth reporting by facilities (%)'
    ),
    mmr = list(
      title = 'Completeness of facility maternal death reporting (%), based on UN MMR estimates and community to institutional ratio',
      x = 'Ratio Community MMR to Institutional MMR',
      y = 'Completeness maternal deaths reporting by facilities (%)'
    )
  )

  label_values <- labels[[plot_type]]
  label_values$title <- title %||% label_values$title
  label_values$x_title <- x_title %||% label_values$x
  label_values$y_title <- y_title %||% label_values$y
  label_values <- utils::modifyList(
    c(label_values, list(lower = lower_bound, best = best_estimates, upper = upper_bound)),
    user_labels
  )

  data <- x %>%
    pivot_longer(cols = -ciratio, values_to = 'rat', names_to = 'name') %>%
    mutate(name = factor(name, levels = c(lower_bound, best_estimates, upper_bound),
                         labels = c(label_values$lower, label_values$best, label_values$upper)))

  max_y <- robust_max(data$rat)
  max_y <- if (max_y < 100) 100 else max_y * 1.05

  data %>%
    ggplot(aes(x = ciratio, y = rat, colour = name)) +
    geom_line(linewidth = 2) +
    geom_point(size = 13) +
    geom_text(aes(label = rat), color = "black", size = 4) +
    scale_y_continuous(limits = c(0, max_y), breaks = scales::pretty_breaks(n = 10), expand = expansion(mult = c(0,0.05))) +
    cd_plot_theme(
      title = label_values$title,
      x_title = label_values$x_title,
      y_title = label_values$y_title
    )
}

#' Plot filtered institutional mortality rates
#'
#' Visualizes institutional mortality rates (`MMR` or `SBR`) across regions using filled
#' geographic polygons. Facets the map by year and applies a color gradient by value.
#'
#' @param x A `cd_mortality_summary_filtered` object.
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot2` object: the map, with the chart options applied.
#'
#' @details
#' Takes the default title and legend title from the `indicator` attribute of `x` and sets the
#' geometry to WGS84 coordinates. Draws the regions as filled polygons with `geom_sf()`, one panel
#' per year, on a sequential colour scale from the palette stored on `x` (`Reds` by default), with
#' gray for missing values.
#'
#' @examples
#' \dontrun{
#' filtered <- select_mortality_summary(mortality_data, "UGA", indicator = "mmr",
#'                                      plot_year = 2020:2022)
#' plot(filtered)
#' }
#'
#' @export
plot.cd_mortality_summary_filtered <- function(x,
                                               title = NULL,
                                               subtitle = NULL,
                                               caption = NULL,
                                               x_title = NULL,
                                               y_title = NULL,
                                               legend_title = NULL,
                                               ...,
                                               options = NULL) {
  .cd_draw(.plot_cd_mortality_summary_filtered_impl, x, list(), ..., options = options)
}

.plot_cd_mortality_summary_filtered_impl <- function(x, title = NULL, legend_title = NULL, ...) {
  indicator <- attr_or_abort(x, 'indicator')

  title <- title %||% switch (
    indicator,
    mmr_inst = 'Institutional MMR by Region',
    sbr_inst = 'Institutional SBR by Region'
  )

  legend_title <- legend_title %||% switch (
    indicator,
    mmr_inst = 'Institutional MMR per 100,000 livebirths',
    sbr_inst = 'Institutional SBR per 1000'
  )

  x %>%
    .cd_as_map() %>%
    ggplot() +
      geom_sf(aes(fill = !!sym(indicator)), colour = 'white') +
      facet_wrap(~ year, scales = 'fixed', ncol = 5) +
      scale_fill_gradientn(
        colours = brewer.pal(9, attr_or_null(x, 'palette') %||% 'Reds'),
        na.value = 'gray90',
        name = legend_title
      ) +
      cd_plot_theme(title = title) +
      cd_map_theme() +
      theme(legend.key.size = unit(6, "mm"), legend.text = element_text(size = 9))
}

#' Plot subnational mortality plausibility
#'
#' Draws one institutional mortality indicator by year, with a point for each admin level 1 unit,
#' the median of the units in each year and the range of values considered plausible for the
#' indicator. Use it to see whether subnational values are realistic.
#'
#' @param x A `cd_mortality_summary` object.
#' @param indicator One of `"fresh_total_sb"` (fresh stillbirths as a percentage of all
#'   stillbirths), `"ratio_md_sb"` (stillbirths per maternal death) or `"ratio_md_nd"` (neonatal
#'   deaths per maternal death).
#' @param title (Optional) Custom translated title.
#' @param y_title (Optional) Custom translated y-axis label.
#' @param x_title (Optional) Custom translated x-axis label.
#' @param caption (Optional) Custom translated footnote.
#' @param legend_labels (Optional) A named list to override default legend labels (keys: 'median', 'plausible').
#'
#' @return A `ggplot` object. The function stops with an error when `x` has no subnational values
#'   for the indicator.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' mortality <- cache$mortality_summary
#'
#' plot_mortality_plausibility(mortality, indicator = "fresh_total_sb")
#' plot_mortality_plausibility(mortality, indicator = "ratio_md_sb", title = "Stillbirths per maternal death",
#'                             x_title = "Year", legend_labels = list(median = "Median of the regions"))
#'
#' @export
plot_mortality_plausibility <- function(x,
                                        indicator = c("fresh_total_sb", "ratio_md_sb", "ratio_md_nd"),
                                        title = NULL,
                                        y_title = NULL,
                                        x_title = NULL,
                                        caption = NULL,
                                        legend_labels = NULL) {
  # Made for the CAM 2026 subnational mortality analysis.

  check_cd_mortality_summary(x)

  indicator <- arg_match(indicator)

  country_name <- attr_or_abort(x, 'country')

  # Filter out National data to only plot the Admin-1 points
  plot_data <- x %>%
    filter(adminlevel_1 != "National", !is.na(!!sym(indicator)))

  if (nrow(plot_data) == 0) cd_abort(c('x' = "No subnational data available for this indicator."))

  min_year <- min(plot_data$year, na.rm = TRUE)
  max_year <- max(plot_data$year, na.rm = TRUE)

  # 1. Plot defaults based on the indicator selected
  cfg <- switch(
    indicator,
    fresh_total_sb = list(
      y_title = "Fresh stillbirths (%)",
      title = paste0("Institutional fresh stillbirths as % of total stillbirths, ", country_name, ", ", min_year, "-", max_year, "."),
      p_min = 30,
      p_max = 55,
      note  = "Note: Plausible range (30-55) is the range of values considered realistic and expected."
    ),
    ratio_md_sb = list(
      y_title = "Stillbirths per maternal death",
      title = paste0("Institutional stillbirth-to-maternal death ratio, ", country_name, ", ", min_year, "-", max_year, "."),
      p_min = 6,
      p_max = 15,
      note  = "Note: Plausible range (6-15) is the range of values considered realistic and expected."
    ),
    ratio_md_nd = list(
      y_title = "Neonatal death per maternal death",
      title = paste0("Institutional neonatal death-to-maternal death ratio, ", country_name, ", ", min_year, "-", max_year, "."),
      p_min = 5,
      p_max = 10,
      note  = "Note: Institutional neonatal deaths are deaths among live-born infants before discharge from the health facility.\nPlausible range (5-10) is the range of values considered realistic and expected."
    )
  )

  # Apply translations if provided
  t_title <- title %||% cfg$title
  t_y     <- y_title %||% cfg$y_title
  t_x     <- x_title %||% 'Year'
  t_note  <- caption %||% cfg$note

  # Setup Legend Overrides safely
  default_leg <- list(median = 'Median', plausible = 'Plausible range')
  if (!is.null(legend_labels)) default_leg <- modifyList(default_leg, as.list(legend_labels))

  lbl_median <- default_leg$median
  lbl_plausible <- default_leg$plausible

  # 2. Calculate Annual Medians for the Thick Red Segments
  medians <- plot_data %>%
    summarise(med_val = median(!!sym(indicator), na.rm = TRUE), .by = year) %>%
    mutate(
      year_left = year - 0.15,
      year_right = year + 0.15
    )

  # 3. Build the ggplot
  ggplot() +
    # Plausible Range (Blue dashed lines)
    geom_hline(aes(yintercept = cfg$p_min, color = lbl_plausible, linetype = lbl_plausible), linewidth = 0.5) +
    geom_hline(aes(yintercept = cfg$p_max, color = lbl_plausible, linetype = lbl_plausible), linewidth = 0.5) +

    # Subnational Points (Grey circles)
    geom_point(data = plot_data, aes(x = year, y = !!sym(indicator)), 
               shape = 21, fill = "gray60", color = "gray40", alpha = 0.6, size = 2.5) +

    # Medians (Thick Red horizontal segments)
    geom_segment(data = medians, aes(x = year_left, xend = year_right, y = med_val, yend = med_val, 
                                     color = lbl_median, linetype = lbl_median), linewidth = 2) +
    
    geom_text(data = medians, aes(x = (year_left + year_right) / 2, y = med_val, label = round(med_val, 1), color = lbl_median),
                                  vjust = -0.5,  show.legend = FALSE) +

    # Scales
    scale_color_manual(name = NULL, values = setNames(.cd_palette$median_range, c(lbl_median, lbl_plausible))) +
    scale_linetype_manual(name = NULL, values = setNames(c("solid", "dashed"), c(lbl_median, lbl_plausible))) +
    scale_x_continuous(breaks = min_year:max_year) +
    cd_plot_theme(
      title = t_title, x_title = t_x, y_title = t_y, caption = t_note
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, margin = margin(b = 15)),
      plot.caption = element_text(hjust = 0, size = 9, color = "black", margin = margin(t = 15)),
      legend.position = "bottom",
      legend.title = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.title.x = element_text(margin = margin(t = 10)),
      axis.title.y = element_text(margin = margin(r = 10))
    )
}

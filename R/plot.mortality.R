#' Plot Mortality Rate Indicators
#'
#' Produces line plots for national mortality indicators with regional points for comparison.
#'
#' @param x A `cd_mortality_summary` object.
#' @param indicator One of `"mmr_inst"`, `"ratio_md_sb"`, `"sbr_inst"`, or `"nn_inst"`.
#' @param ... Additional arguments passed to methods.
#'
#' @return A ggplot object.
#'
#' @export
plot.cd_mortality_summary <- function(x, indicator = c('mmr_inst', 'ratio_md_sb', 'sbr_inst', 'nn_inst'), ...) {
  indicator <- arg_match(indicator)

  label <- switch(
    indicator,
    mmr_inst = 'National inst. MMR',
    nn_inst = 'National NN',
    sbr_inst = 'National inst. SBR',
    ratio_md_sb = 'National SB/MM ratio'
  )

  title <- switch(
    indicator,
    mmr_inst = 'Maternal mortality per 100,000 live births in health facilities',
    ratio_md_sb = 'Ratio number of stillbirths to maternal deaths in health facilities',
    sbr_inst = 'Stillbirths per 1,000 births in health facilities',
    nn_inst = 'Neonatal deaths before discharge per 1,000 live births in health facilities'
  )

  national <- x %>% filter(adminlevel_1 == 'National')
  regional <- x %>% filter(adminlevel_1 != 'National')

  max_y <- robust_max(x[[indicator]], 100)
  limits <- c(0, max_y)
  breaks <- scales::pretty_breaks(n = 11)(limits)

  ggplot() +
    geom_point(data = regional, aes(x = year, y = !!sym(indicator), color = 'Regions'), size = 2, alpha = 0.7) +
    geom_line(data = national, aes(x = year, y = !!sym(indicator), color = label), linewidth = 1.2) +
    geom_point(data = national, aes(x = year, y = !!sym(indicator), color = label), size = 2) +
    geom_text(
      data = national,
      aes(x = year, y = !!sym(indicator), label = round(!!sym(indicator), 1)),
      color = 'black', vjust = -0.5, hjust = -0.1, size = 3
    ) +
    scale_y_continuous(limits = limits, breaks = breaks, expand = expansion(mult = c(0, 0.05))) +
    scale_color_manual(values = set_names(c('forestgreen', 'orangered'), c('Regions', label))) +
    cd_plot_theme(
      title = title
    )
}


#' Plot Completeness of Facility Reporting Ratios
#'
#' Calculates and plots the estimated completeness of facility reporting
#' for maternal deaths or stillbirths based on UN estimates and assumed
#' community-to-institution ratios.
#'
#' @param x A `cd_mortality_ratio_summarised ` object from completeness estimation.
#' @param ... Additional arguments (not used).
#'
#' @return A ggplot object with ratio lines, labels, and reference points.
#'
#' @export
plot.cd_mortality_ratio_summarised <- function(x, ...) {

  plot_type <- attr_or_abort(x, 'plot_type')

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

  data <- x %>%
    pivot_longer(cols = -ciratio, values_to = 'rat', names_to = 'name') %>%
    mutate(name = factor(name, levels = c(lower_bound, best_estimates, upper_bound)))

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
      x_axis = label_values$x,
      y_axis = label_values$y
    )
}

#' Plot Filtered Institutional Mortality Rates
#'
#' Visualizes institutional mortality rates (`MMR` or `SBR`) across regions using filled
#' geographic polygons. Facets the map by year and applies a color gradient by value.
#'
#' @param x A `cd_mortality_summary_filtered` object.
#' @param ... Additional arguments (not used).
#'
#' @return A `ggplot2` object. This function is called for its side effect of rendering a map.
#'
#' @details
#' The function:
#' - Determines the appropriate plot title and legend based on the `indicator` attribute
#' - Projects the geometry to WGS84 for consistent map rendering
#' - Facets by year and uses `geom_sf()` to draw filled polygons
#' - Applies a sequential `Reds` color scale with gray for missing values
#'
#' @examples
#' \dontrun{
#' filtered <- filter_mortality_summary(mortality_data, "UGA", indicator = "mmr", plot_year = 2020:2022)
#' plot(filtered)
#' }
#'
#' @export
plot.cd_mortality_summary_filtered <- function(x, ...) {
  indicator <- attr_or_abort(x, 'indicator')

  title <- switch (
    indicator,
    mmr_inst = 'Institutional MMR by Region',
    sbr_inst = 'Institutional SBR by Region'
  )

  legend <- switch (
    indicator,
    mmr_inst = 'Institutional MMR per 100,000 livebirths',
    sbr_inst = 'Institutional SBR per 1000'
  )

  x %>%
    st_set_geometry('geometry') %>%
    st_as_sf() %>%
    st_set_crs(4326) %>%
    st_transform(crs = 4326) %>%
    ggplot() +
      geom_sf(aes(fill = !!sym(indicator)), colour = 'white') +
      facet_wrap(~ year, scales = 'fixed', ncol = 5) +
      scale_fill_gradientn(
        colours = brewer.pal(9, 'Reds'),
        na.value = 'gray90',
        name = legend
      ) +
      cd_plot_theme(title = title) +
      theme(
        panel.border = element_blank(),
        panel.spacing = unit(1, "lines"),
        legend.key.size = unit(6, "mm"),
        legend.background = element_blank(),
        legend.title = element_text(size = 11),
        legend.text = element_text(size = 9),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        axis.line = element_blank(),
        strip.text = element_text(size = 12, face = "bold"),
        aspect.ratio = 1
      )
}

#' Plot Subnational Mortality Plausibility
#'
#' Generates subnational scatter plots with annual medians and plausible ranges
#' as requested for the CAM 2026 subnational mortality analysis.
#'
#' @param x A `cd_mortality_summary` object.
#' @param indicator One of `"fresh_total_sb"`, `"ratio_md_sb"`, `"ratio_md_nd"`.
#' @param title (Optional) Custom translated title.
#' @param y_axis (Optional) Custom translated y-axis label.
#' @param x_axis (Optional) Custom translated x-axis label.
#' @param note (Optional) Custom translated footnote caption.
#' @param legend_labels (Optional) A named list to override default legend labels (keys: 'median', 'plausible').
#'
#' @export
plot_mortality_plausibility <- function(x,
                                        indicator = c("fresh_total_sb", "ratio_md_sb", "ratio_md_nd"),
                                        title = NULL,
                                        y_axis = NULL,
                                        x_axis = NULL,
                                        note = NULL,
                                        legend_labels = NULL) {
  
  check_cd_class(x, 'cd_mortality_summary')

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
      y_lab = "Fresh stillbirths (%)",
      title = paste0("Institutional fresh stillbirths as % of total stillbirths, ", country_name, ", ", min_year, "-", max_year, "."),
      p_min = 30,
      p_max = 55,
      note  = "Note: Plausible range (30-55) is the range of values considered realistic and expected."
    ),
    ratio_md_sb = list(
      y_lab = "Stillbirths per maternal death",
      title = paste0("Institutional stillbirth-to-maternal death ratio, ", country_name, ", ", min_year, "-", max_year, "."),
      p_min = 6,
      p_max = 15,
      note  = "Note: Plausible range (6-15) is the range of values considered realistic and expected."
    ),
    ratio_md_nd = list(
      y_lab = "Neonatal death per maternal death",
      title = paste0("Institutional neonatal death-to-maternal death ratio, ", country_name, ", ", min_year, "-", max_year, "."),
      p_min = 5,
      p_max = 10,
      note  = "Note: Institutional neonatal deaths are deaths among live-born infants before discharge from the health facility.\nPlausible range (5-10) is the range of values considered realistic and expected."
    )
  )

  # Apply translations if provided
  t_title <- title %||% cfg$title
  t_y     <- y_axis %||% cfg$y_lab
  t_x     <- x_axis %||% 'Year'
  t_note  <- note %||% cfg$note

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
    scale_color_manual(name = NULL, values = setNames(c("red", "blue"), c(lbl_median, lbl_plausible))) +
    scale_linetype_manual(name = NULL, values = setNames(c("solid", "dashed"), c(lbl_median, lbl_plausible))) +
    scale_x_continuous(breaks = min_year:max_year) +
    cd_plot_theme(
      title = t_title, x_axis = t_x, y_axis = t_y, caption = t_note
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
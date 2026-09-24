#' Plot Service Utilization Indicators
#'
#' Visualizes service utilization over time from a `cd_service_utilization_filtered` object.
#'
#' @param x A `cd_service_utilization_filtered` object created by [filter_service_utilization()].
#' @param ... not used
#'
#' @return A `ggplot2` plot object.
#'
#' @examples
#' \dontrun{
#' plot(filter_service_utilization(dat, indicator = 'opd'))
#' }
#'
#' @export
plot.cd_service_utilization_filtered <- function(x, ...) {

  indicator <- attr_or_abort(x, 'indicator')

  labels <- list(
    opd = list(
      y1 = 'ratio_opd_pop',
      y2 = 'ratio_opd_u5_pop',
      y1_label = 'Under-5',
      y2_label = 'All ages',
      title = 'OPD per person per year',
      y_label = 'OPD Utilization Trends'
    ),
    ipd = list(
      y1 = 'ratio_ipd_u5_pop',
      y2 = 'ratio_ipd_pop',
      y1_label = 'Under-5',
      y2_label = 'All ages',
      title = 'IPD admissions',
      y_label = 'Mean # of IPD admissions per 100 persons'
    ),
    under5 = list(
      y1 = 'perc_opd_under5',
      y2 = 'perc_ipd_under5',
      y1_label = 'OPD visits',
      y2_label = 'IPD admissions',
      title = 'Percentage of under-5 OPD visits and IPD admissions',
      y_label = 'Percentage'
    ),
    cfr = list(
      y1 = 'cfr_under5',
      y2 = 'cfr_total',
      y1_label = 'CFR: Under-5',
      y2_label = 'CFR: All ages',
      title = 'Case fatality rate (%)',
      y_label = 'Percentage'
    ),
    deaths = list(
      y1 = 'prop_death',
      y2 = 'prop_death',
      y1_label = NULL,
      y2_label = NULL,
      title = 'Proportion of deaths (%): under-5 to all-age',
      y_label = 'Percentage'
    )
  )

  labels_val <- labels[[indicator]]

  max_y <- robust_max(c(x[[labels_val$y1]], x[[labels_val$y2]]))
  limits <- c(0, max_y)
  breaks <- scales::pretty_breaks(n = 11)(limits)

  x %>%
    ggplot(aes(x = year)) +
    geom_point(aes(y = !!sym(labels_val$y1), color = labels_val$y1_label), size = 2) +
    geom_line(aes(y = !!sym(labels_val$y1), color = labels_val$y1_label), linewidth = 1) +
    geom_point(aes(y = !!sym(labels_val$y2), color = labels_val$y2_label), size = 2) +
    geom_line(aes(y = !!sym(labels_val$y2), color = labels_val$y2_label), linewidth = 1) +
    scale_y_continuous(limits = limits, breaks = breaks, expand = expansion(mult = c(0, 0.1))) +
    cd_plot_theme(
      title = labels_val$title,
      x_axis = 'Year',
      y_axis = labels_val$y_label
    )
}

#' Plot Filtered Service Utilization Indicators
#'
#' Generates a faceted map of service utilization metrics across subnational units
#' (admin level 1) for each available year. Uses spatial polygons filled by the selected indicator.
#'
#' @param x A `cd_service_utilization_prepared` object returned by [prepare_mapping_service_utlization()].
#' @param ... Additional arguments (currently unused).
#'
#' @return A `ggplot2` object representing faceted service utilization maps by year.
#'
#' @details
#' This function:
#' - Extracts the appropriate indicator (`ratio_opd_u5_pop` or `ratio_ipd_u5_pop`)
#' - Projects the data to WGS84 for map consistency
#' - Renders the spatial data using `geom_sf()` with a sequential purple color scale
#' - Facets by year and applies the package's custom plot theme
#'
#' @examples
#' \dontrun{
#' plot(filtered)
#' }
#'
#' @export
plot.cd_service_utilization_prepared <- function(x, ...) {

  indicator <- attr_or_abort(x, 'indicator')

  title <- switch (indicator,
                   ratio_opd_u5_pop = 'OPD under-five by Region',
                   ratio_ipd_u5_pop = 'IPD under-five by Region'
  )

  legend <- switch (indicator,
                    ratio_opd_u5_pop = 'Mean OPD per child per year',
                    ratio_ipd_u5_pop = 'Mean IPD per 100 children per year'
  )

  x %>%
    st_set_geometry('geometry') %>%
    st_as_sf() %>%
    st_set_crs(4326) %>%
    st_transform(crs = 4326) %>%
    ggplot() +
    geom_sf(aes(fill = !!sym(indicator)), color = "white") +
    facet_wrap(~ year, scales = "fixed", ncol = 5) +
    scale_fill_gradientn(
      colours = brewer.pal(9, attr_or_null(x, "palette") %||% "Purples"),
      na.value = "grey90",
      name =  legend
    ) +
    cd_plot_theme(title = title) +
    labs(title = title) +
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

#' Plot S3 method for Service Utilization Admin1
#'
#' @param x Object of class cd_service_utilization_admin1.
#' @param title Character. Optional translated title.
#' @param x_axis Character. Optional translated x-axis label.
#' @param legend Character. Optional translated legend label.
#' @param ... Additional arguments.
#' @export
plot.cd_service_utilization_admin1 <- function(x, title = NULL, x_axis = NULL, legend = NULL, ...) {

  metric_type <- attr_or_abort(x, "metric_type")

  # 1. FIXED: Differentiated IPD vs OPD text
  default_title <- switch(
    metric_type,
    ipd = 'Sub-National IPD Distribution',
    opd = 'Sub-National OPD Distribution',
    cd_abort(c('x' = '{.arg metric_type} can only be {.val opd} or {.val ipd}'))
  )

  default_x <- switch(
    metric_type,
    ipd = 'IPD per 100 children under5, by adminlevel1',
    opd = 'OPD per capita under5, by adminlevel1',
    cd_abort(c('x' = '{.arg metric_type} can only be {.val opd} or {.val ipd}'))
  )

  default_legend <- switch(
    metric_type,
    ipd = 'IPD Under 5',
    opd = 'OPD Under 5',
    cd_abort(c('x' = '{.arg metric_type} can only be {.val opd} or {.val ipd}'))
  )

  # 2. FIXED: metric_title -> legend
  title  <- if (is.null(title)) default_title else title
  x_axis <- if (is.null(x_axis)) default_x else x_axis
  legend <- if (is.null(legend)) default_legend else legend

  # 3. FIXED: Add the metric column to the data so the fill mapping works
  x$metric <- legend

  # 4. FIXED: Define fill_colors dynamically based on the metric type
  base_color <- if (metric_type == "opd") "darkorange" else "orangered"
  fill_colors <- setNames(base_color, legend)

  x_value <- sym(paste0('ratio_', metric_type, '_u5_pop'))
  
  ggplot(x, aes(y = reorder(adminlevel_1, !!x_value), 
                x = !!x_value, 
                fill = metric)) +
    geom_col(width = 0.8) +
    geom_text(aes(label = round(!!x_value, 1)), 
              hjust = -0.2, 
              size = 3) +
    scale_fill_manual(values = fill_colors) +
    cd_plot_theme(
      title = title,
      x_axis = x_axis,
      legend = legend
    ) +
    coord_cartesian(clip = "off")
}

#' Plot S3 method for MCH vs Curative Index
#'
#' @param x Object of class cd_mch_curative_index.
#' @param labels List. Optional translations containing axes, title, and quadrant labels.
#' @param ... Additional arguments.
#' @export
plot.cd_mch_curative_index <- function(x, labels = NULL, ...) {
  
  # 1. Calculate Mid-points
  x_mid <- median(x$mch_prev_services_index, na.rm = TRUE)
  y_mid <- median(x$curative_services_index, na.rm = TRUE)
  
  # 2. Identify Outliers for Labeling
  labels_data <- x %>%
    filter(
      curative_services_index == max(curative_services_index, na.rm = TRUE) |
      curative_services_index == min(curative_services_index, na.rm = TRUE) |
      mch_prev_services_index == max(mch_prev_services_index, na.rm = TRUE) |
      mch_prev_services_index == min(mch_prev_services_index, na.rm = TRUE)
    )
  
  # 3. Safely Extract Translations (with fallbacks)
  lbl_title <- if (!is.null(labels$title)) labels$title else "MCH preventive index compared to curative service index, under5"
  lbl_x     <- if (!is.null(labels$x_axis)) labels$x_axis else "MCH Preventive services index"
  lbl_y     <- if (!is.null(labels$y_axis)) labels$y_axis else "Curative service use index"
  
  q_tl <- if (!is.null(labels$q_top_left)) labels$q_top_left else "Low preventive\nHigh curative"
  q_tr <- if (!is.null(labels$q_top_right)) labels$q_top_right else "High preventive\nHigh curative"
  q_bl <- if (!is.null(labels$q_bottom_left)) labels$q_bottom_left else "Low preventive\nLow curative"
  q_br <- if (!is.null(labels$q_bottom_right)) labels$q_bottom_right else "High preventive\nLow curative"
  
  # 4. Generate Plot
  ggplot(x, aes(x = mch_prev_services_index, y = curative_services_index)) +
    geom_point(size = 3, colour = "steelblue4") +
    
    # Quadrant lines
    geom_vline(xintercept = x_mid, linetype = "dashed", colour = "grey40") +
    geom_hline(yintercept = y_mid, linetype = "dashed", colour = "grey40") +
    
    # Label only selected regions
    geom_text(data = labels_data, aes(label = adminlevel_1), nudge_x = 0.08, size = 4) +
    
    # Quadrant labels (Anchored to the absolute corners of the plot)
    annotate("text", x = -Inf, y = Inf,  label = q_tl, hjust = -0.05, vjust = 1.2, size = 4, fontface = "bold", color = "grey30") +
    annotate("text", x = Inf,  y = Inf,  label = q_tr, hjust = 1.05,  vjust = 1.2, size = 4, fontface = "bold", color = "grey30") +
    annotate("text", x = -Inf, y = -Inf, label = q_bl, hjust = -0.05, vjust = -0.2, size = 4, fontface = "bold", color = "grey30") +
    annotate("text", x = Inf,  y = -Inf, label = q_br, hjust = 1.05,  vjust = -0.2, size = 4, fontface = "bold", color = "grey30") +
    
    scale_x_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
    scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
    
    coord_equal(clip = "off") +
    
    cd_plot_theme(
      title = lbl_title,
      x_axis = lbl_x,
      y_axis = lbl_y
    )
}

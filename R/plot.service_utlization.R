#' Plot service utilization indicators
#'
#' Visualizes service utilization over time from a `cd_service_utilization_filtered` object.
#'
#' @param x A `cd_service_utilization_filtered` object created by [select_service_utilization()].
#' @param legend_labels (Optional) A named list to override the legend's entries, e.g. with translations: `y1` and `y2`, the
#'   chart's two series (for `opd` and `ipd`: under-5 and all ages). Defaults to `NULL`.
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot2` plot object.
#'
#' @examples
#' \dontrun{
#' plot(select_service_utilization(dat, indicator = 'opd'))
#' }
#'
#' @export
plot.cd_service_utilization_filtered <- function(x,
                                                 title = NULL,
                                                 subtitle = NULL,
                                                 caption = NULL,
                                                 x_title = NULL,
                                                 y_title = NULL,
                                                 legend_title = NULL,
                                                 ...,
                                                 legend_labels = NULL,
                                                 options = NULL) {
  .cd_draw(.plot_cd_service_utilization_filtered_impl, x, list(legend_labels = legend_labels), ..., options = options)
}

.plot_cd_service_utilization_filtered_impl <- function(x, title = NULL, x_title = NULL, y_title = NULL, legend_labels = NULL, ...) {
  labels <- legend_labels
  user_labels <- as.list(labels)

  indicator <- attr_or_abort(x, 'indicator')

  labels <- list(
    opd = list(
      y1 = 'ratio_opd_u5_pop',
      y2 = 'ratio_opd_pop',
      y1_label = 'Under-5',
      y2_label = 'All ages',
      title = 'OPD per person per year',
      y_title = 'OPD Utilization Trends'
    ),
    ipd = list(
      y1 = 'ratio_ipd_u5_pop',
      y2 = 'ratio_ipd_pop',
      y1_label = 'Under-5',
      y2_label = 'All ages',
      title = 'IPD admissions',
      y_title = 'Mean # of IPD admissions per 100 persons'
    ),
    under5 = list(
      y1 = 'perc_opd_under5',
      y2 = 'perc_ipd_under5',
      y1_label = 'OPD visits',
      y2_label = 'IPD admissions',
      title = 'Percentage of under-5 OPD visits and IPD admissions',
      y_title = 'Percentage'
    ),
    cfr = list(
      y1 = 'cfr_under5',
      y2 = 'cfr_total',
      y1_label = 'CFR: Under-5',
      y2_label = 'CFR: All ages',
      title = 'Case fatality rate (%)',
      y_title = 'Percentage'
    ),
    deaths = list(
      y1 = 'prop_death',
      y2 = 'prop_death',
      y1_label = NULL,
      y2_label = NULL,
      title = 'Proportion of deaths (%): under-5 to all-age',
      y_title = 'Percentage'
    )
  )

  labels_val <- labels[[indicator]]
  if (!is.null(user_labels$y1)) labels_val$y1_label <- user_labels$y1
  if (!is.null(user_labels$y2)) labels_val$y2_label <- user_labels$y2
  if (!is.null(title)) labels_val$title <- title
  if (!is.null(y_title)) labels_val$y_title <- y_title
  x_title <- x_title %||% 'Year'

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
      x_title = x_title,
      y_title = labels_val$y_title
    )
}

#' Plot filtered service utilization indicators
#'
#' Generates a faceted map of service utilization metrics across subnational units
#' (admin level 1) for each available year. Uses spatial polygons filled by the selected indicator.
#'
#' @param x A `cd_service_utilization_prepared` object returned by [prepare_mapping_service_utlization()].
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot2` object representing faceted service utilization maps by year.
#'
#' @details
#' Reads the indicator stored on `x` (`ratio_opd_u5_pop` or `ratio_ipd_u5_pop`) and sets the data to
#' WGS84 coordinates. Draws the units with `geom_sf()`, filled on a sequential colour scale from the
#' palette stored on `x` (purple by default), with one panel per year and the package's map theme.
#'
#' @examples
#' \dontrun{
#' plot(filtered)
#' }
#'
#' @export
plot.cd_service_utilization_prepared <- function(x,
                                                 title = NULL,
                                                 subtitle = NULL,
                                                 caption = NULL,
                                                 x_title = NULL,
                                                 y_title = NULL,
                                                 legend_title = NULL,
                                                 ...,
                                                 options = NULL) {
  .cd_draw(.plot_cd_service_utilization_prepared_impl, x, list(), ..., options = options)
}

.plot_cd_service_utilization_prepared_impl <- function(x, title = NULL, legend_title = NULL, ...) {

  indicator <- attr_or_abort(x, 'indicator')

  title <- title %||% switch (indicator,
                   ratio_opd_u5_pop = 'OPD under-five by Region',
                   ratio_ipd_u5_pop = 'IPD under-five by Region'
  )

  legend_title <- legend_title %||% switch (indicator,
                    ratio_opd_u5_pop = 'Mean OPD per child per year',
                    ratio_ipd_u5_pop = 'Mean IPD per 100 children per year'
  )


  x %>%
    .cd_as_map() %>%
    ggplot() +
    geom_sf(aes(fill = !!sym(indicator)), color = "white") +
    facet_wrap(~ year, scales = "fixed", ncol = 5) +
    scale_fill_gradientn(
      colours = brewer.pal(9, attr_or_null(x, "palette") %||% "Purples"),
      na.value = "grey90",
      name =  legend_title
    ) +
    cd_plot_theme(title = title) +
    labs(title = title) +
    cd_map_theme() +
    theme(legend.key.size = unit(6, "mm"))
}

#' Plot S3 method for service utilization at admin level 1
#'
#' Draws a horizontal bar for each admin level 1 unit showing its under-five OPD visits per child or
#' IPD admissions per 100 children in the latest year. The bars are ordered by value and labelled
#' with it.
#'
#' @param x Object of class cd_service_utilization_admin1, as returned by
#'   [generate_admin1_service_utilization()].
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot` object, with the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#'
#' plot(cache$generate_admin1_service_utilization("opd"))
#' plot(cache$generate_admin1_service_utilization("ipd"), title = "Admissions of children under five",
#'      x_title = "Admissions per 100 children", show_legend = FALSE)
#'
#' @export
plot.cd_service_utilization_admin1 <- function(x,
                                               title = NULL,
                                               subtitle = NULL,
                                               caption = NULL,
                                               x_title = NULL,
                                               y_title = NULL,
                                               legend_title = NULL,
                                               ...,
                                               options = NULL) {
  .cd_draw(.plot_cd_service_utilization_admin1_impl, x, list(), ..., options = options)
}

.plot_cd_service_utilization_admin1_impl <- function(x, title = NULL, x_title = NULL, legend_title = NULL, ...) {

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
  x_title <- if (is.null(x_title)) default_x else x_title
  legend_title <- if (is.null(legend_title)) default_legend else legend_title

  # 3. FIXED: Add the metric column to the data so the fill mapping works
  x$metric <- legend_title

  # 4. FIXED: Define fill_colors dynamically based on the metric type
  base_color <- if (metric_type == "opd") "darkorange" else "orangered"
  fill_colors <- setNames(base_color, legend_title)

  x_value <- sym(paste0('ratio_', metric_type, '_u5_pop'))
  
  ggplot(x, aes(y = reorder(adminlevel_1, !!x_value), 
                x = !!x_value, 
                fill = metric)) +
    geom_col(width = 0.8) +
    geom_text(aes(label = round(!!x_value, 1)), 
              hjust = -0.2, 
              size = .cd_type$label_small) +
    scale_fill_manual(values = fill_colors) +
    cd_plot_theme(
      title = title,
      x_title = x_title,
      legend_title = legend_title
    ) +
    coord_cartesian(clip = "off")
}

#' Plot S3 method for MCH vs curative index
#'
#' Draws a scatter plot of the curative services index against the MCH preventive services index,
#' with one point per admin level 1 unit. Dashed lines at the two medians split the plot into four
#' labelled quadrants, and the units with the highest and lowest value of either index are named.
#'
#' @param x Object of class cd_mch_curative_index, as returned by
#'   [generate_admin1_mch_curative_index()].
#' @param quad_labels (Optional) A named list of the texts written in the four quadrants: `q_top_left`,
#'   `q_top_right`, `q_bottom_left` and `q_bottom_right`.
#' @inheritParams cd_plot_arguments
#'
#' @return A `ggplot` object, with the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' index <- cache$generate_admin1_mch_curative_index()
#'
#' plot(index)
#' plot(index, title = "Preventive and curative care", x_title = "Preventive index", y_title = "Curative index",
#'      quad_labels = list(q_top_right = "High on both", q_bottom_left = "Low on both"))
#'
#' @export
plot.cd_mch_curative_index <- function(x,
                                       title = NULL,
                                       subtitle = NULL,
                                       caption = NULL,
                                       x_title = NULL,
                                       y_title = NULL,
                                       legend_title = NULL,
                                       ...,
                                       quad_labels = NULL,
                                       options = NULL) {
  .cd_draw(.plot_cd_mch_curative_index_impl, x, list(quad_labels = quad_labels), ..., options = options)
}

.plot_cd_mch_curative_index_impl <- function(x, title = NULL, x_title = NULL, y_title = NULL, quad_labels = NULL, ...) {
  labels <- quad_labels
  
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
  lbl_title <- if (!is.null(title)) title else "MCH preventive index compared to curative service index, under5"
  lbl_x     <- if (!is.null(x_title)) x_title else "MCH Preventive services index"
  lbl_y     <- if (!is.null(y_title)) y_title else "Curative service use index"
  
  q_tl <- if (!is.null(labels$q_top_left)) labels$q_top_left else "Low preventive\nHigh curative"
  q_tr <- if (!is.null(labels$q_top_right)) labels$q_top_right else "High preventive\nHigh curative"
  q_bl <- if (!is.null(labels$q_bottom_left)) labels$q_bottom_left else "Low preventive\nLow curative"
  q_br <- if (!is.null(labels$q_bottom_right)) labels$q_bottom_right else "High preventive\nLow curative"
  
  # 4. Generate Plot
  ggplot(x, aes(x = mch_prev_services_index, y = curative_services_index)) +
    # the quadrants (medians), under the points: the same on every chart that has them (.cd_quadrants())
    .cd_quadrants(x_mid, y_mid, top_left = q_tl, top_right = q_tr, bottom_left = q_bl, bottom_right = q_br) +
    geom_point(size = 3, colour = "steelblue4") +

    # Label only selected regions
    geom_text(data = labels_data, aes(label = adminlevel_1), nudge_x = 0.08, size = .cd_type$label, colour = "grey15") +

    scale_x_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
    scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
    
    coord_equal(clip = "off") +
    
    cd_plot_theme(
      title = lbl_title,
      x_title = lbl_x,
      y_title = lbl_y
    )
}

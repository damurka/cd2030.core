#' Compare district vs admin level 1 health metrics
#'
#' Generates scatterplots with linear fit and identity line comparing district to admin level 1 metrics or coverage vs density.
#'
#' @param x A data frame from `calculate_health_system_comparison()`.
#' @param indicator One of ratio_* or cov_instdeliveries_* (requires `denominator`).
#' @param denominator Optional for cov_ indicators. Must be one of 'dhis2', 'anc1', 'penta1'.
#' @inheritParams cd_plot_arguments
#' @param legend_labels (Optional) A named list to override default legend labels (keys: 'admin', 'linear').
#'
#' @return A ggplot object.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#' comparison <- cache$health_system_comparison
#'
#' plot(comparison, indicator = "ratio_opd_u5_hstaff")
#' plot(comparison, indicator = "ratio_ipd_u5_bed", title = "Admissions of children and hospital beds",
#'      legend_labels = list(admin = "Regions", linear = "Trend"))
#'
#' @export
plot.cd_health_system_comparison <- function(x,
                                             indicator = c("cov_instdeliveries_hstaff", "ratio_opd_u5_hstaff", "ratio_ipd_u5_hos", "ratio_ipd_u5_bed"),
                                             denominator = NULL,
                                             title = NULL,
                                             subtitle = NULL,
                                             caption = NULL,
                                             x_title = NULL,
                                             y_title = NULL,
                                             legend_title = NULL,
                                             ...,
                                             legend_labels = NULL,
                                             options = NULL) {
  .cd_draw(.plot_cd_health_system_comparison_impl, x, list(indicator = indicator, denominator = denominator, legend_labels = legend_labels), ..., options = options)
}

.plot_cd_health_system_comparison_impl <- function(x,
                                              indicator = c(
                                                'cov_instdeliveries_hstaff',
                                                'ratio_opd_u5_hstaff',
                                                'ratio_ipd_u5_hos',
                                                'ratio_ipd_u5_bed'),
                                              denominator = NULL,
                                              title = NULL,
                                              x_title = NULL,
                                              y_title = NULL,
                                              caption = NULL,
                                              legend_labels = NULL) {

  indicator <- arg_match(indicator)

  if (str_detect(indicator, 'cov_')) {
    denominator <- arg_match(denominator, c('dhis2', 'anc1', 'penta1'))
  }

  # 1. Map dynamic columns based on indicator
  col_x <- switch(indicator,
    cov_instdeliveries_hstaff = paste0('ad1_cov_instdeliveries_', denominator),
    ratio_opd_u5_hstaff       = 'ad1_ratio_opd_u5_pop',
    ratio_ipd_u5_hos          = 'ad1_ratio_ipd_u5_pop',
    ratio_ipd_u5_bed          = 'ad1_ratio_ipd_u5_pop'
  )
  
  col_y <- switch(indicator,
    cov_instdeliveries_hstaff = 'ad1_ratio_hstaff_pop',
    ratio_opd_u5_hstaff       = 'ad1_ratio_hstaff_pop',
    ratio_ipd_u5_hos          = 'ad1_ratio_hos_pop',
    ratio_ipd_u5_bed          = 'ad1_ratio_bed_pop'
  )

  # 2. Setup text defaults and fallbacks
  t_title <- title %||% switch(indicator,
    cov_instdeliveries_hstaff = 'Institutional delivery coverage rate (%) by health workforce density by admin level 1',
    ratio_opd_u5_hstaff       = 'Under-5 OPD Visits by health workforce density by admin level 1',
    ratio_ipd_u5_hos          = 'Under-5 IPD Admission by hospital density by admin level 1',
    ratio_ipd_u5_bed          = 'Under-5 IPD Admission by hospital beds density by admin level 1'
  )
  
  t_x <- x_title %||% switch(indicator,
    cov_instdeliveries_hstaff = 'Institutional delivery coverage rate (%)',
    ratio_opd_u5_hstaff       = 'Number of under-5 OPD visits per child per year',
    ratio_ipd_u5_hos          = 'Number of under-5 IPD Admissions per child per year',
    ratio_ipd_u5_bed          = 'Number of Under-5 IPD Admission per 100 children per year'
  )
  
  t_y <- y_title %||% switch(indicator,
    cov_instdeliveries_hstaff = "Number of core health workforce per 10,000 population",
    ratio_opd_u5_hstaff       = "Number of core health workforce per 10,000 population",
    ratio_ipd_u5_hos          = "Number of Hospitals per 100,000 population",
    ratio_ipd_u5_bed          = "Number of hospital beds per 10,000 population"
  )
  
  t_cap <- caption %||% if (indicator == 'cov_instdeliveries_hstaff') paste0('Denominator derived from ', denominator, ' data') else NULL

  # Setup Legend Overrides
  default_leg <- list(admin = 'Admin1 units', linear = 'Linear fit')
  if (!is.null(legend_labels)) default_leg <- modifyList(default_leg, as.list(legend_labels))

  lbl_admin <- default_leg$admin
  lbl_linear <- default_leg$linear

  # 3. Calculate R-Squared and prepend to caption
  r2 <- summary(lm(as.formula(paste0(col_y, ' ~ ', col_x)), data = x))$r.squared
  final_caption <- paste0("R-squared = ", round(r2, 4), if (!is.null(t_cap)) paste0("\n", t_cap) else "")

  # 4. Plot
  x %>%
    ggplot(aes(x = !!sym(col_x), y = !!sym(col_y))) +
      geom_point(aes(colour = lbl_admin), size = 2) +
      geom_smooth(aes(colour = lbl_linear), method = "lm", se = FALSE, formula = y ~ x) +
      scale_x_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.1))) +
      scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.1))) +
      
      # Dynamically map the selected labels to the standard colors
      scale_colour_manual(
        values = setNames(c('#045a8d', 'black'), c(lbl_admin, lbl_linear)), 
        name = ""
      ) +
      
      cd_plot_theme(
        title = t_title,
        x_title = t_x,
        y_title = t_y,
        caption = final_caption
      ) +
      theme(
        plot.caption = element_text(color = "gray40")
      )
}

#' Plot health metrics for admin level 1 units
#'
#' Plots individual health system indicators by admin level 1 and compares with national value or target.
#'
#' @param x Data frame containing admin level 1 indicators.
#' @param indicator A single metric to plot. Options include ratio_fac_pop, ratio_hos_pop, ratio_bed_pop, ratio_hstaff_pop, skill_mix.
#' @param national_value A numeric value representing the national average to plot as a vertical line. Can be NA.
#' @inheritParams cd_plot_arguments
#' @param legend_labels (Optional) A named list to override default legend labels (e.g. for translation).
#'
#' @return A ggplot object.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' regions <- cache$health_system_metrics_admin1
#' national <- cache$health_system_metrics_national
#'
#' plot(regions, indicator = "ratio_fac_pop", national_value = national$ratio_fac_pop)
#' plot(regions, indicator = "ratio_hstaff_pop", national_value = national$ratio_hstaff_pop,
#'      title = "Health workers per 10,000 people", x_title = "Health workers",
#'      legend_labels = list(threshold_line = "Benchmark (44.5)"))
#'
#' @export
plot.cd_health_system_metric <- function(x,
                                         indicator = c("ratio_fac_pop", "ratio_hos_pop", "ratio_bed_pop", "ratio_hstaff_pop", "skill_mix"),
                                         national_value = NA_real_,
                                         title = NULL,
                                         subtitle = NULL,
                                         caption = NULL,
                                         x_title = NULL,
                                         y_title = NULL,
                                         legend_title = NULL,
                                         ...,
                                         legend_labels = NULL,
                                         options = NULL) {
  .cd_draw(.plot_cd_health_system_metric_impl, x, list(indicator = indicator, national_value = national_value, legend_labels = legend_labels), ..., options = options)
}

.plot_cd_health_system_metric_impl <- function(x,
                                         indicator = c(
                                           'ratio_fac_pop',
                                           'ratio_hos_pop',
                                           'ratio_bed_pop',
                                           'ratio_hstaff_pop',
                                           'skill_mix'
                                         ),
                                         national_value = NA_real_,
                                         title = NULL,
                                         x_title = NULL,
                                         y_title = NULL,
                                         legend_labels = NULL) {

  indicator <- arg_match(indicator)
  
  # 1. Map indicators to their respective benchmarks
  threshold <- switch(
    indicator,
    ratio_fac_pop = 2,
    ratio_bed_pop = 25,
    ratio_hstaff_pop = 44.5,
    NA
  )

  # 2. Map indicators without benchmarks to their specific static fill colors
  static_fill <- switch(
    indicator, 
    ratio_hos_pop = "#7570b3", 
    skill_mix = "pink", 
    NA
  )

  # 3. Setup Default Legend Text
  default_leg <- list(
    "FALSE" = "Below benchmark", 
    "TRUE" = "Meets benchmark",
    "threshold_line" = "Target benchmark",
    "national_line" = "National average"
  )
  
  if (!is.null(legend_labels)) {
    default_leg <- modifyList(default_leg, as.list(legend_labels))
  }

  # 4. Create unified fill column
  plot_data <- x %>% 
    mutate(
      benchmark_flag = if (!is.na(threshold)) as.character(!!sym(indicator) >= threshold) else "STATIC"
    )

  # 5. Determine palettes
  fill_colors <- if (!is.na(threshold)) {
    c("TRUE" = "#1b9e77", "FALSE" = "#d95f02")
  } else {
    setNames(static_fill, "STATIC")
  }

  # 6. Setup default labels
  t_title <- title %||% switch(indicator,
    ratio_fac_pop = "Facility Density per 10,000 population",
    ratio_hos_pop = "Hospital Density per 100,000 population",
    ratio_bed_pop = "Inpatient Bed Density per 10,000 population",
    ratio_hstaff_pop = "Health workforce density per 10,000 population",
    skill_mix = "Skill mix ratio (Nurse/Physician)"
  )
  
  t_x <- x_title %||% switch(indicator,
    ratio_fac_pop = "Facility density",
    ratio_hos_pop = "Hospital density",
    ratio_bed_pop = "Bed density",
    ratio_hstaff_pop = "Health workforce density",
    skill_mix = "Skill mix ratio"
  )
  
  t_y <- y_title %||% ""

  # 7. Build the Base Plot
  p <- plot_data %>%
    ggplot(aes(y = reorder(adminlevel_1, !!sym(indicator)), x = !!sym(indicator))) +
    geom_col(aes(fill = benchmark_flag)) +
    geom_text(aes(label = round(!!sym(indicator), 1)), hjust = -0.1, size = .cd_type$label_small) +
    scale_fill_manual(
      values = fill_colors,
      labels = function(x) unlist(default_leg[x]), 
      name = '',
      guide = if (is.na(threshold)) 'none' else guide_legend(order = 1)
    )

  # 8. Add Vertical Lines (Vectorized implementation without rbind)
  # Create a dataframe with both lines, then simply filter out the NAs.
  lines_df <- data.frame(
    xintercept = c(threshold, national_value),
    line_type_id = c("threshold_line", "national_line")
  ) %>%
    filter(!is.na(xintercept))

  if (nrow(lines_df) > 0) {
    p <- p + 
      geom_vline(
        data = lines_df, 
        aes(xintercept = xintercept, color = line_type_id, linetype = line_type_id),
        linewidth = 1
      ) +
      scale_color_manual(
        name = "",
        values = c("threshold_line" = "black", "national_line" = "#377eb8"),
        labels = function(x) unlist(default_leg[x]),
        guide = guide_legend(order = 2)
      ) +
      scale_linetype_manual(
        name = "",
        values = c("threshold_line" = "dashed", "national_line" = "solid"),
        labels = function(x) unlist(default_leg[x]),
        guide = guide_legend(order = 2)
      )
  }

  # 9. Apply the theme
  p + 
    cd_plot_theme(
      title = t_title,
      x_title = t_x,
      y_title = t_y
    ) +
    theme(
      plot.caption = element_text(color = "gray40"),
      legend.box = "horizontal",
      legend.position = "bottom"
    )
}

#' Plot national health system metrics
#'
#' Creates a horizontal bar plot for either health system performance or density
#' metrics at national level.
#'
#' @param .data A one-row data frame containing national-level metrics.
#' @param metric Either 'performance' or 'density'.
#'
#' @return A ggplot object.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' national <- cache$health_system_metrics_national
#'
#' plot_national_health_metric(national, metric = "performance")
#' plot_national_health_metric(national, metric = "density")
#'
#' @export
plot_national_health_metric <- function(.data, metric = c('performance', 'density')) {

  metric <- arg_match(metric)

  metric_labels <- list(
    performance = list(
      columns = c('score_total', 'score_infrastructure', 'score_workforce', 'score_utilization'),
      labels = c("Total score", "Score infrastructure*", "Score workforce**", "Score service utilization***"),
      title = 'Health system performance at national level',
      caption = paste0(
        "* Score facility density & bed density\n",
        "** Score health workforce density (physicians, non-clinique physicians, nurses & midwives)\n",
        "*** Score outpatient service utilization & inpatient service utilization"
      )
    ),
    density = list(
      # columns = c('ratio_fac_pop', 'ratio_hstaff_pop', 'ratio_bed_pop', 'ratio_opd_pop', 'ratio_ipd_pop'),
      # labels = c("Density of Facilities *", "Density of core health workforce *", "Density of beds *", "Ratio OPD/Population **", "Ratio IPD/Population ***"),
      columns = c('ratio_fac_pop', 'ratio_hstaff_pop', 'ratio_bed_pop'),
      labels = c("Health Facility Density *", "Health workforce density (Core health professionals) *", "Hospital Beds Density *"),
      title = 'Health system density at national level',
      # caption = '* per 10,000 population\n** per person per year\n*** per 100 population per year'
      caption = '* per 10,000 population'
    )
  )

  labels <- metric_labels[[metric]]

  data <- .data %>%
    select(all_of(labels$columns)) %>%
    pivot_longer(cols = everything(), names_to = 'indicator', values_to = 'value') %>%
    mutate(indicator = factor(indicator, levels = rev(labels$columns), labels = rev(labels$labels)))

  y_max <- robust_max(data$value)
  limits <- c(0, y_max)
  breaks <- scales::pretty_breaks(n = 11)(limits)

  data %>%
    ggplot(aes(x = indicator, y =value)) +
    geom_col(fill = '#2c7fb8', width = 0.6) +
    coord_flip() +
    geom_text(aes(label = sprintf("%.1f", value)), hjust = -0.1, size = .cd_type$label) +
    scale_y_continuous(limits = limits, breaks = breaks, expand = expansion(mult = c(0, 0.1))) +
    cd_plot_theme(title = labels$title, y_title = NULL, x_title = NULL, caption = labels$caption)
}

#' Plot S3 method for health system metrics
#'
#' Draws the national health system metrics as a formatted table. The indicators are grouped under
#' their section, each with its value and unit, and the year is shown in a line above the column
#' headers.
#'
#' @param x An object of class `cd_health_system_table`, as returned by
#'   [generate_health_system_table()].
#' @param year The year to display in the header (defaults to 2024)
#' @param width (Optional) Total width in inches. If NULL, autofit is used.
#' @param indicator_label (Optional) Translated label for the Indicator column header
#' @param value_label (Optional) Translated label for the Value column header
#' @param unit_label (Optional) Translated label for the Unit column header
#' @param ... Additional arguments
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#'
#' @return A `flextable` object (from the flextable package), not a ggplot. Chart options change
#'   ggplots only, so `options` has no effect on this table.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' metrics <- cache$generate_health_system_table()
#'
#' plot(metrics, year = 2023)
#' plot(metrics, year = 2023, width = 6, indicator_label = "Indicateur", value_label = "Valeur",
#'      unit_label = "Unite")
#'
#' @export
plot.cd_health_system_table <- function(x, 
                                        year = 2024, 
                                        width = NULL, 
                                        indicator_label = "Indicator", 
                                        value_label = "Value", 
                                        unit_label = "Unit", 
                                        ..., options = NULL) {
  cd_finish_plot(.plot_cd_health_system_table_impl(x, year = year, width = width, indicator_label = indicator_label, value_label = value_label, unit_label = unit_label, ...), options, ..., .source = x)
}

.plot_cd_health_system_table_impl <- function(x, 
                                        year = 2024, 
                                        width = NULL, 
                                        indicator_label = "Indicator", 
                                        value_label = "Value", 
                                        unit_label = "Unit", 
                                        ...) {
  
  base_font <- if (!is.null(width) && width < 5) 8 else 9

  ft <- x %>%
    # Automatically group by 'section' to create header rows
    as_grouped_data(groups = "section") %>%
    as_flextable() %>%
    
    # 1. Headers & Titles
    set_header_labels(
      # FIX 2: Removed 'section = ""' since the column no longer exists
      indicator = indicator_label,
      value = value_label,
      unit = unit_label
    ) %>%
    add_header_lines(values = as.character(year)) %>%
    # the look every formatted table has
    .cd_table_style(section = ~ !is.na(section), base_font = base_font, centre = c("value", "unit")) %>%
    align(i = 1, align = "center", part = "header") %>%
    
    # 2. Style the Section Group Headers
    compose(
      i = ~ !is.na(section),
      j = 1,
      value = as_paragraph(as_chunk(section))
    ) %>%
    merge_h(i = ~ !is.na(section), part = "body") %>%
    
    # 3. Format Data & Indents
    colformat_double(j = "value", digits = 1, na_str = "") %>%
    colformat_char(j = "unit", na_str = "") %>%
    # the indicators of a section are set in from its title
    padding(i = ~ is.na(section), j = "indicator", padding.left = 15, part = "body")

  # 5. Handle Sizing
  if (!is.null(width)) {
    # FIX 4: Only 3 columns remain visible, adjust width ratios accordingly
    w_ind <- width * 0.6
    w_val <- width * 0.2
    w_unit <- width * 0.2
    
    ft <- ft %>%
      width(j = "indicator", width = w_ind) %>%
      width(j = "value", width = w_val) %>%
      width(j = "unit", width = w_unit) %>%
      set_table_properties(layout = "fixed")
  } else {
    ft <- ft %>% autofit()
  }

  return(ft)
}

#' Plot S3 method for PHC performance scatter
#'
#' Draws a scatter plot of the service coverage index against facility density or health workforce
#' density, with one point per admin level 1 unit. Dashed lines at the two medians split the plot
#' into four labelled quadrants, and the units flagged as outliers are named.
#'
#' @param x An object of class `cd_phc_scatter`, as returned by [generate_phc_scatter_data()].
#' @inheritParams cd_plot_arguments
#' @param quad_labels (Optional) Named list to override quadrant text.
#'   Expected keys: `high_high`, `low_high`, `high_low`, `low_low`.
#'
#'
#' @return A `ggplot` object, with the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' scatter <- cache$generate_phc_scatter_data("ratio_fac_pop")
#'
#' plot(scatter)
#' plot(scatter, title = "Facilities and services by region", y_title = "Service index",
#'      quad_labels = list(low_low = "Few facilities, few services"))
#'
#' @export
plot.cd_phc_scatter <- function(x,
                                quad_labels = NULL,
                                title = NULL,
                                subtitle = NULL,
                                caption = NULL,
                                x_title = NULL,
                                y_title = NULL,
                                legend_title = NULL,
                                ...,
                                options = NULL) {
  .cd_draw(.plot_cd_phc_scatter_impl, x, list(quad_labels = quad_labels), ..., options = options)
}

.plot_cd_phc_scatter_impl <- function(x,
                                title = NULL,
                                x_title = NULL,
                                y_title = NULL,
                                quad_labels = NULL,
                                ...) {
  
  # Retrieve attributes saved during data generation
  x_indicator <- attr_or_abort(x, "indicator")
  # lbl_mch <- attr(x, "lbl_mch")
  # lbl_cur <- attr(x, "lbl_cur")

  # 1. Setup Defaults
  default_x_lab <- switch(x_indicator,
    ratio_fac_pop = "Facility density",
    ratio_hstaff_pop = "Health workforce density"
  )

  default_x_prefix <- switch(x_indicator,
    ratio_fac_pop = "facility density",
    ratio_hstaff_pop = "workforce density"
  )

  t_title <- title %||% paste(default_x_lab, "vs MCH & Curative Service Index")
  t_x <- x_title %||% default_x_lab
  t_y <- y_title %||% "MCH & Curative Service Index"

  # Setup default quadrant labels dynamically
  default_quads <- list(
    high_high = paste("High", default_x_prefix, "\nHigh service index"),
    low_high  = paste("Low", default_x_prefix, "\nHigh service index"),
    high_low  = paste("High", default_x_prefix, "\nLow service index"),
    low_low   = paste("Low", default_x_prefix, "\nLow service index")
  )

 # Safely merge user translations if provided
  if (!is.null(quad_labels)) {
    default_quads <- modifyList(default_quads, as.list(quad_labels))
  }

  # 2. Calculate Medians to draw the lines
  med_x <- median(x[[x_indicator]], na.rm = TRUE)
  med_y <- median(x$service_coverage, na.rm = TRUE)

  # 3. Subset outliers for labels
  outliers <- x %>% filter(is_outlier == TRUE)

  # 2. The SINGLE ggplot Block
  ggplot(x, aes(x = !!sym(x_indicator), y = service_coverage)) +
    # the quadrants (medians), as on the preventive against curative chart: under the points
    .cd_quadrants(med_x, med_y, top_left = default_quads$low_high, top_right = default_quads$high_high,
                  bottom_left = default_quads$low_low, bottom_right = default_quads$high_low) +
    geom_point(size = 3, colour = "steelblue4") +

    # the units far from the others, named
    ggrepel::geom_text_repel(data = outliers, aes(label = adminlevel_1), size = .cd_type$label, colour = "grey15") +

    # room above and below for the texts in the corners
    scale_x_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
    scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.15))) +
    
    # Theming
    cd_plot_theme(
      title = t_title,
      x_title = t_x,
      y_title = t_y
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.margin = margin(10, 20, 10, 20)
    )
}

#' Plot S3 method for private sector ownership
#'
#' Draws a stacked bar for each admin level 1 unit showing the percentage of health facilities that
#' are private, NGO and public, with the percentage written inside each segment.
#'
#' @param x An object of class `cd_private_sector`, as returned by [generate_private_sector_data()].
#' @inheritParams cd_plot_arguments
#'
#'
#' @return A `ggplot` object, with the chart options applied.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' ownership <- cache$generate_private_sector_data()
#'
#' plot(ownership)
#' plot(ownership, title = "Who owns the health facilities", y_title = "Facilities (%)",
#'      legend_title = "Owner", legend_position = "right")
#'
#' @export
plot.cd_private_sector <- function(x,
                                   title = NULL,
                                   subtitle = NULL,
                                   caption = NULL,
                                   x_title = NULL,
                                   y_title = NULL,
                                   legend_title = NULL,
                                   ...,
                                   options = NULL) {
  .cd_draw(.plot_cd_private_sector_impl, x, list(), ..., options = options)
}

.plot_cd_private_sector_impl <- function(x,
                                   title = NULL,
                                   x_title = NULL,
                                   y_title = NULL,
                                   ...) {
  
  # Retrieve attributes saved during data generation
  lbl_prv <- attr(x, "lbl_prv")
  lbl_ngo <- attr(x, "lbl_ngo")
  lbl_pub <- attr(x, "lbl_pub")
  
  # 1. Setup default titles and axes
  t_title <- title %||% "Ownership of health facilities, 2024 (DHIS2)"
  t_x <- x_title %||% ""
  t_y <- y_title %||% "Percent of facilities"
  
  # Dynamically map your specific colors to whatever the translated labels are
  fill_colors <- setNames(c("#b3d7ea", "#f4a641", "#dfe8df"), c(lbl_prv, lbl_ngo, lbl_pub))
  
  # 2. Generate Plot
  ggplot(x, aes(x = adminlevel_1, y = share, fill = facility_type)) +
    
    geom_col(width = 0.85) +
    
    # Text Labels inside the stacked bars
    geom_text(
      aes(label = round(share, 0)),
      position = position_stack(vjust = 0.5),
      size = .cd_type$label,
      color = "black"
    ) +
    
    # Dynamic Fill scale
    scale_fill_manual(values = fill_colors) +
    
    # Y-axis scaling (0 to 100 with % symbol)
    scale_y_continuous(
      limits = c(0, 100),
      breaks = seq(0, 100, 20),
      labels = function(v) paste0(v, "%")
    ) +
    
    # Theming
    cd_plot_theme(
      title = t_title,
      x_title = t_x,
      y_title = t_y
    ) +
    theme(
      legend.position = "bottom",
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
}

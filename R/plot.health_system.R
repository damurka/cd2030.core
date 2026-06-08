#' Compare District vs Admin 1 Health Metrics
#'
#' Generates scatterplots with linear fit and identity line comparing district to admin 1 metrics or coverage vs density.
#'
#' @param x A data frame from `calculate_health_system_comparison()`.
#' @param indicator One of ratio_* or cov_instdeliveries_* (requires `denominator`).
#' @param denominator Optional for cov_ indicators. Must be one of 'dhis2', 'anc1', 'penta1'.
#' @param title (Optional) Custom title for the plot.
#' @param x_axis (Optional) Custom label for the x-axis.
#' @param y_axis (Optional) Custom label for the y-axis.
#' @param caption (Optional) Custom caption text (R-squared will automatically be prepended to this).
#' @param legend_labels (Optional) A named list to override default legend labels (keys: 'admin', 'linear').
#'
#' @return A ggplot object.
#'
#' @export
plot.cd_health_system_comparison <- function(x,
                                              indicator = c(
                                                'cov_instdeliveries_hstaff',
                                                'ratio_opd_u5_hstaff',
                                                'ratio_ipd_u5_hos',
                                                'ratio_ipd_u5_bed'),
                                              denominator = NULL,
                                              title = NULL,
                                              x_axis = NULL,
                                              y_axis = NULL,
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
  
  t_x <- x_axis %||% switch(indicator,
    cov_instdeliveries_hstaff = 'Institutional delivery coverage rate (%)',
    ratio_opd_u5_hstaff       = 'Number of under-5 OPD visits per child per year',
    ratio_ipd_u5_hos          = 'Number of under-5 IPD Admissions per child per year',
    ratio_ipd_u5_bed          = 'Number of Under-5 IPD Admission per 100 children per year'
  )
  
  t_y <- y_axis %||% switch(indicator,
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
        x_axis = t_x,
        y_axis = t_y,
        caption = final_caption
      ) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5),
        plot.caption = element_text(size = 9, color = "gray40"),
        axis.title.x = element_text(size = 11),
        axis.title.y = element_text(size = 11),
        axis.text = element_text(size = 10)
      )
}

#' Plot Health Metrics for Admin 1 Units
#'
#' Plots individual health system indicators by admin 1 level and compares with national value or target.
#'
#' @param x Data frame containing admin 1 level indicators.
#' @param indicator A single metric to plot. Options include ratio_fac_pop, ratio_hos_pop, ratio_bed_pop, ratio_hstaff_pop, skill_mix.
#' @param title (Optional) Custom title for the plot.
#' @param x_axis (Optional) Custom label for the x-axis.
#' @param y_axis (Optional) Custom label for the y-axis.
#' @param legend_labels (Optional) A named list to override default legend labels.
#'
#' @return A ggplot object.
#'
#' @export
plot.cd_health_system_metric <- function(x,
                                         indicator = c(
                                           'ratio_fac_pop',
                                           'ratio_hos_pop',
                                           'ratio_bed_pop',
                                           'ratio_hstaff_pop',
                                           'skill_mix'
                                         ),
                                        title = NULL,
                                        x_axis = NULL,
                                        y_axis = NULL,
                                        legend_labels = NULL) {

  indicator <- arg_match(indicator)
  # Map indicators to their respective benchmarks (NA if they don't have one)
  threshold <- switch(
    indicator,
    ratio_fac_pop = 2,
    ratio_bed_pop = 25,
    ratio_hstaff_pop = 44.5,
    NA
  )

  # Map indicators without benchmarks to their specific static fill colors
  static_fill <- switch(
    indicator, 
    ratio_hos_pop = "#7570b3", 
    skill_mix = "pink", 
    NA
  )

  # Setup default legend and apply user overrides if provided
  default_leg <- list("FALSE" = "Below benchmark", "TRUE" = "Meets benchmark")
  if (!is.null(legend_labels)) {
    default_leg <- modifyList(default_leg, as.list(legend_labels))
  }

  # Create a unified fill column: TRUE/FALSE if there's a threshold, or "STATIC" if there isn't
  plot_data <- x %>% 
    mutate(
      benchmark_flag = if (!is.na(threshold)) as.character(!!sym(indicator) >= threshold) else "STATIC"
    )

  # Create a unified color palette based on whether a threshold exists
  palette_colors <- if (!is.na(threshold)) {
    c("TRUE" = "#1b9e77", "FALSE" = "#d95f02")
  } else {
    setNames(static_fill, "STATIC")
  }

  # Setup default labels (overridden by user args if provided)
  t_title <- title %||% switch(indicator,
    ratio_fac_pop = "Facility Density per 10,000 population",
    ratio_hos_pop = "Hospital Density per 100,000 population",
    ratio_bed_pop = "Inpatient Bed Density per 10,000 population",
    ratio_hstaff_pop = "Health workforce density per 10,000 population",
    skill_mix = "Skill mix ratio (Nurse/Physician)"
  )
  
  t_x <- x_axis %||% switch(indicator,
    ratio_fac_pop = "Facility density",
    ratio_hos_pop = "Hospital density",
    ratio_bed_pop = "Bed density",
    ratio_hstaff_pop = "Health workforce density",
    skill_mix = "Skill mix ratio"
  )
  
  t_y <- y_axis %||% ""

  plot_data %>%
    ggplot(aes(y = reorder(adminlevel_1, !!sym(indicator)), x = !!sym(indicator))) +
    geom_col(aes(fill = benchmark_flag)) +
    geom_vline(
      xintercept = if (is.na(threshold)) 0 else threshold, 
      linetype = if (is.na(threshold)) 'blank' else "dashed", 
      linewidth = 1
    ) +
    geom_text(aes(label = round(!!sym(indicator), 1)), hjust = -0.1, size = 3) +
    scale_fill_manual(
      values = palette_colors,
      labels = unlist(default_leg),
      name = '',
      guide = if (is.na(threshold)) 'none' else 'legend'
    ) +
    cd_plot_theme(
      title = t_title,
      x_axis = t_x,
      y_axis = t_y
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.caption = element_text(size = 9, color = "gray40"),
      axis.text.y = element_text(size = 9)
    )
}

#' Plot National Health System Metrics
#'
#' Creates a horizontal bar plot for either health system performance or density
#' metrics at national level.
#'
#' @param .data A one-row data frame containing national-level metrics.
#' @param metric Either 'performance' or 'density'.
#'
#' @return A ggplot object.
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
    geom_text(aes(label = sprintf("%.1f", value)), hjust = -0.1, size = 4) +
    scale_y_continuous(limits = limits, breaks = breaks, expand = expansion(mult = c(0, 0.1))) +
    cd_plot_theme(title = labels$title, y_axis = NULL, x_axis = NULL, caption = labels$caption)
}

#' Plot S3 method for Health System Metrics
#'
#' @param x An object of class `cd_health_system_table`
#' @param year The year to display in the header (defaults to 2024)
#' @param width (Optional) Total width in inches. If NULL, autofit is used.
#' @param indicator_label (Optional) Translated label for the Indicator column header
#' @param value_label (Optional) Translated label for the Value column header
#' @param unit_label (Optional) Translated label for the Unit column header
#' @param ... Additional arguments
#'
#' @export
plot.cd_health_system_table <- function(x, 
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
    
    # FIX 1: Move theme_vanilla() UP so it doesn't wipe out custom padding/borders
    theme_vanilla() %>%
    
    font(fontname = "sans", part = "all") %>%
    fontsize(size = base_font, part = "all") %>%
    bg(part = "all", bg = "white") %>%
    
    # 1. Headers & Titles
    set_header_labels(
      # FIX 2: Removed 'section = ""' since the column no longer exists
      indicator = indicator_label,
      value = value_label,
      unit = unit_label
    ) %>%
    add_header_lines(values = as.character(year)) %>%
    bold(i = 1, part = "header", bold = TRUE) %>%
    align(i = 1, align = "center", part = "header") %>%
    
    # 2. Style the Section Group Headers
    compose(
      i = ~ !is.na(section),
      j = 1,
      value = as_paragraph(as_chunk(section))
    ) %>%
    bold(i = ~ !is.na(section), bold = TRUE, part = "body") %>%
    bg(i = ~ !is.na(section), part = "body", bg = "#D9EAF7") %>%
    merge_h(i = ~ !is.na(section), part = "body") %>% 
    
    # 3. Format Data & Indents
    colformat_double(j = "value", digits = 1, na_str = "") %>%
    colformat_char(j = "unit", na_str = "") %>%
    align(j = c("value", "unit"), align = "center", part = "all") %>%
    
    # FIX 3: Removed "section" from j, only aligning the indicator column
    align(j = "indicator", align = "left", part = "all") %>%
    padding(i = ~ is.na(section), j = "indicator", padding.left = 15, part = "body") %>%
    
    # 4. Apply Table Borders (Steelblue)
    border_inner_h(border = officer::fp_border(color = "steelblue"), part = "body") # %>%
    # border_top(border = officer::fp_border(color = "steelblue", width = 1.5), part = "all") # %>%
    # border_bottom(border = officer::fp_border(color = "steelblue", width = 1.5), part = "all")

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

#' Plot S3 method for PHC Performance Scatter
#'
#' @param x An object of class `cd_phc_scatter`
#' @param title (Optional) Custom title for the entire plot.
#' @param x_axis (Optional) Custom label for the x-axis.
#' @param y_axis (Optional) Custom label for the y-axis.
#' @param ... Additional arguments
#'
#' @export
plot.cd_phc_scatter <- function(x,
                                title = NULL,
                                x_axis = NULL,
                                y_axis = NULL,
                                ...) {
  
  # Retrieve attributes saved during data generation
  x_indicator <- attr(x, "x_indicator")
  lbl_mch <- attr(x, "lbl_mch")
  lbl_cur <- attr(x, "lbl_cur")

  # 1. Setup Defaults
  default_x_lab <- switch(x_indicator,
    ratio_fac_pop = "Facility density",
    ratio_hstaff_pop = "Health workforce density"
  )
  
  t_title <- title %||% paste(default_x_lab, "vs PHC Indices")
  t_x <- x_axis %||% default_x_lab
  t_y <- y_axis %||% "Index Value"

  # Create dynamic color mapping using the translated labels
  idx_colors <- setNames(c("#2c7fb8", "#d95f02"), c(lbl_mch, lbl_cur))

  # Subset outliers for ggrepel
  outliers <- x %>% filter(is_outlier == TRUE)

  # 2. The SINGLE ggplot Block
  ggplot(x, aes(x = !!sym(x_indicator), y = index_value, color = index_name)) +
    
    # Facet side-by-side (MCH | Curative)
    facet_wrap(~ index_name, scales = "free_y", ncol = 2) +
    
    # Scatter Points
    geom_point(size = 3) +
    
    # Trendline (force color to black so it doesn't inherit the point color)
    geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
    
    # Outlier Labels (force text color to black)
    ggrepel::geom_text_repel(data = outliers, aes(label = adminlevel_1), size = 3, color = "black") +
    
    # Axes
    scale_x_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.05))) +
    scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.05))) +
    
    # Apply custom distinct colors and hide the redundant legend
    scale_color_manual(values = idx_colors, guide = "none") +
    
    # Theming
    cd_plot_theme(
      title = t_title,
      x_axis = t_x,
      y_axis = t_y
    ) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      strip.text = element_text(face = "bold", size = 11),
      plot.margin = margin(10, 20, 10, 20)
    )
}

#' Plot S3 method for Private Sector Ownership
#'
#' @param x An object of class `cd_private_sector`
#' @param title (Optional) Custom title for the plot.
#' @param x_axis (Optional) Custom label for the x-axis.
#' @param y_axis (Optional) Custom label for the y-axis.
#' @param ... Additional arguments
#'
#' @export
plot.cd_private_sector <- function(x,
                                   title = NULL,
                                   x_axis = NULL,
                                   y_axis = NULL,
                                   ...) {
  
  # Retrieve attributes saved during data generation
  lbl_prv <- attr(x, "lbl_prv")
  lbl_ngo <- attr(x, "lbl_ngo")
  lbl_pub <- attr(x, "lbl_pub")
  
  # 1. Setup default titles and axes
  t_title <- title %||% "Ownership of health facilities, 2024 (DHIS2)"
  t_x <- x_axis %||% ""
  t_y <- y_axis %||% "Percent of facilities"
  
  # Dynamically map your specific colors to whatever the translated labels are
  fill_colors <- setNames(c("#b3d7ea", "#f4a641", "#dfe8df"), c(lbl_prv, lbl_ngo, lbl_pub))
  
  # 2. Generate Plot
  ggplot(x, aes(x = adminlevel_1, y = share, fill = facility_type)) +
    
    geom_col(width = 0.85) +
    
    # Text Labels inside the stacked bars
    geom_text(
      aes(label = round(share, 0)),
      position = position_stack(vjust = 0.5),
      size = 4,
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
      x_axis = t_x,
      y_axis = t_y
    ) +
    theme(
      legend.position = "bottom",
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
}
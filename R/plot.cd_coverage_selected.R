#' Plot S3 method for coverage data
#'
#' Draws the latest coverage of a set of indicators. National data, or the data of one region, is
#' drawn as a profile (bars by indicator and source) or as the gap between the facility and the
#' survey estimate. Subnational data is drawn as dots by unit, one panel per indicator, or as a
#' heatmap of units by indicator.
#'
#' @param x An object of class `cd_coverage_selected`.
#' @param type "profile" or "gap" (for national), "dot" or "heatmap" (for subnational).
#' @inheritParams cd_plot_arguments
#' @param source_labels (Optional) Named list to translate 'facility', 'survey', 'wuenic'.
#' @param indicator_labels (Optional) Named list to translate indicator names (e.g. 'anc4').
#'
#'
#' @return A `ggplot` object with the chart options applied. Which chart it is depends on `type`
#'   and on the admin level of `x`.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$set_national_estimates(list(sbr = 0.02))
#' cache$adjust_data()
#'
#' # national: a profile of the indicators, or the gap between facility data and the survey
#' national <- cache$generate_coverage_data("national", "maternal")
#' plot(national, type = "profile")
#' plot(national, type = "gap", title = "Facility data against the survey", legend_position = "bottom")
#'
#' # by region: a heatmap (or "dot")
#' regions <- cache$generate_coverage_data("adminlevel_1", "child")
#' plot(regions, type = "heatmap", legend_title = "Coverage (%)")
#'
#' @export
plot.cd_coverage_selected <- function(x,
                                      type = NULL,
                                      source_labels = NULL,
                                      indicator_labels = NULL,
                                      title = NULL,
                                      subtitle = NULL,
                                      caption = NULL,
                                      x_title = NULL,
                                      y_title = NULL,
                                      legend_title = NULL,
                                      ...,
                                      options = NULL) {
  .cd_draw(.plot_cd_coverage_selected_impl, x, list(type = type, source_labels = source_labels, indicator_labels = indicator_labels), ..., options = options)
}

.plot_cd_coverage_selected_impl <- function(x,
                                      type = NULL,
                                      title = NULL,
                                      subtitle = NULL,
                                      x_title = NULL,
                                      y_title = NULL,
                                      legend_title = NULL,
                                      source_labels = NULL,
                                      indicator_labels = NULL) {
  
  admin_level <- attr_or_abort(x, "admin_level")
  region <- attr_or_null(x, 'region')
  admin_col <- get_admin_columns(admin_level, region)
  
  # --- 1. Apply Indicator Translations Safely ---
  # This translates the text without breaking the underlying factor order!
  if (!is.null(indicator_labels)) {
    lvl <- levels(x$indicator)
    new_lvl <- sapply(lvl, function(l) if (!is.null(indicator_labels[[l]])) indicator_labels[[l]] else l)
    levels(x$indicator) <- new_lvl
  }

  # --- 2. Setup Source Legend Overrides ---
  default_src <- list(facility = "Facility", survey = "Survey", wuenic = "WUENIC")
  if (!is.null(source_labels)) {
    default_src <- modifyList(default_src, as.list(source_labels))
  }

  # =====================================================
  # NATIONAL PLOTS (Profile & Gap)
  # =====================================================
  if (admin_level == "national" || !is.null(region)) {
    
    type <- type %||% "profile"
    type <- arg_match(type, c("profile", "gap"))
    
    if (type == "profile") {
      t_title <- title %||% "National continuum-of-care profile"
      t_sub   <- subtitle %||% "Latest facility, latest survey, and WUENIC where relevant"
      t_y     <- y_title %||% "Coverage"
      
      ggplot(x, aes(x = indicator, y = value, fill = source)) +
        geom_col(position = position_dodge(width = 0.8), width = 0.7) +
        scale_y_continuous(limits = c(0, 105), labels = scales::label_number(suffix = "%")) +
        scale_fill_discrete(
          labels = setNames(unlist(default_src), names(default_src)), 
          name = ""
        ) +
        cd_plot_theme(title = t_title, subtitle = t_sub, x_title = x_title, y_title = t_y)
        
    } else if (type == "gap") {
      t_title <- title %||% "Source comparison"
      t_sub   <- subtitle %||% "Latest facility estimate minus latest survey estimate"
      t_x     <- x_title %||% "Percentage-point difference"
      
      plot_data <- x %>% 
        select(-year, -name) %>% 
        pivot_wider(names_from = source, values_from = value) %>% 
        mutate(gap_facility_minus_survey = facility - survey)
      
      ggplot(plot_data, aes(x = gap_facility_minus_survey, y = indicator)) +
        geom_vline(xintercept = 0) +
        geom_segment(aes(x = 0, xend = gap_facility_minus_survey, yend = indicator)) +
        geom_point(size = 2) +
        cd_plot_theme(title = t_title, subtitle = t_sub, x_title = t_x, y_title = y_title)
    }
    
  # =====================================================
  # SUBNATIONAL PLOTS (Dot & Heatmap)
  # =====================================================
  } else {
    
    type <- type %||% "dot"
    type <- arg_match(type, c("dot", "heatmap"))
    
    latest_yr <- max(x$year, na.rm = TRUE)
    
    if (type == "dot") {
      t_title <- title %||% paste0("Subnational latest coverage (", latest_yr, ")")
      t_x     <- x_title %||% "Coverage"
      
      ggplot(x, aes(x = value, y = fct_reorder(!!sym(admin_col), value))) +
        geom_point() +
        # FIX: Facet by indicator so the translated labels are used!
        facet_wrap(~indicator, scales = "free_y", ncol = 2) +
        scale_x_continuous(limits = c(0, 105), labels = scales::label_number(suffix = "%")) +
        labs(title = t_title, x = t_x, y = y_title) +
        cd_minimal_theme(base_size = 8)

    } else if (type == "heatmap") {
      t_title <- title %||% paste0("Subnational continuum heatmap (", latest_yr, ")")
      t_fill  <- legend_title %||% "Coverage"
      
      ggplot(x, aes(x = indicator, y = fct_reorder(!!sym(admin_col), value, .fun = mean, na.rm = TRUE), fill = value)) +
        # Added color and linewidth to create clean grid lines between the tiles
        geom_tile(color = "white", linewidth = 0.5) +
        scale_fill_stepsn(
          # 5 colors transitioning from Green to Red
          colours = c("#d73027", "#fc8d59", "#ffffbf", "#91cf60", "#1a9850"),
          # 20% step thresholds separating the 5 colors
          breaks = c(20, 40, 60, 80),                                
          limits = c(0, 100), 
          na.value = "grey90", 
          labels = scales::label_number(suffix = "%")
        ) +
        labs(title = t_title, x = x_title, y = y_title, fill = t_fill) +
        # no grid lines, so the tile borders stand out sharply
        cd_minimal_theme(base_size = 10, grid = "none") +
        theme(axis.text.x = element_text(angle = 30, hjust = 1))
    }
  }
}

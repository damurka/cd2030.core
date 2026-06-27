#' Plot Derived vs Traditional Coverage Over Time
#'
#' This function generates a line plot comparing traditional (`coverage_old`)
#' and derived (`coverage_new`) coverage estimates over time for a single indicator.
#' It supports both national and subnational views.
#'
#' @param x A `cd_derived_coverage` object.
#' @param type A character string specifying the plot type: `"bar"` or `"trend"`. 
#'   `"trend"` can only be applied nationally or to a specific region. Defaults to `"bar"`.
#' @param title (Optional) A scalar character string to override the default plot title. Defaults to `NULL`.
#' @param x_label (Optional) A scalar character string to override the default x-axis label. Defaults to `NULL`.
#' @param y_label (Optional) A scalar character string to override the default y-axis label. Defaults to `NULL`.
#' @param legend_labels (Optional) A named list of character strings to override specific
#'   default legend labels (e.g., `list(penta1derived = "Custom Penta1")`).
#' @param ... Additional arguments passed to `ggplot2` layers (not used).
#'
#' @return A `ggplot` object showing coverage trends over time.
#' @export
plot.cd_derived_coverage <- function(x, type = c('bar', 'trend'), title = NULL, x_label = NULL, y_label = NULL, legend_labels = list(), ...) {
  
  # 1. Metadata Extraction & Validation
  admin_level <- attr_or_abort(x, "admin_level")
  indicator <- attr_or_abort(x, "indicator")
  indicator_title <- str_to_title(indicator) 
  region <- attr_or_null(x, 'region')
  survey_year <- attr_or_abort(x, 'survey_year')
  
  type <- arg_match(type)

  admin_level_cols <- get_admin_columns(admin_level)
  cov_indicator <- paste0('cov_', indicator)
  
  is_dot_plot <- admin_level != 'national' && is.null(region)

  if (is_dot_plot && type == 'trend') {
    cd_abort(c(
      "x" = "Trend plots can only be used with national or region-specific data.",
      "i" = "Subnational comparison data across multiple regions must use {.code type = 'bar'}."
    ))
  }

  # Extract max year globally so it can be used in titles
  hfd_data <- x %>%
    filter(!is.na(!!sym(paste0('cov_', indicator, '_penta1'))), !is.na(!!sym(paste0('cov_', indicator, '_anc1'))))
  min_yr <- min(hfd_data$year, na.rm = TRUE)
  max_yr <- max(hfd_data$year, na.rm = TRUE)

  if (survey_year > max_yr) {
    cd_abort(c("x" = "The requested {.arg survey_year} ({survey_year}) cannot be greater than the maximum available year in the data ({max_yr})."))
  }

  data_year <- case_when(
    survey_year < min_yr ~ min_yr,
    .default =  survey_year
  )

  if (admin_level == "national" && !is.null(region)) {
    cd_abort(c("x" = "{.arg region} must be null in national data."))
  }

  if (!is.null(title) && (!is.character(title) || length(title) != 1)) {
    cd_abort(c("x" = "{.arg title} must be a scalar character or NULL."))
  }
  if (!is.null(x_label) && (!is.character(x_label) || length(x_label) != 1)) {
    cd_abort(c("x" = "{.arg x_label} must be a scalar character or NULL."))
  }
  if (!is.null(y_label) && (!is.character(y_label) || length(y_label) != 1)) {
    cd_abort(c("x" = "{.arg y_label} must be a scalar character or NULL."))
  }

  # 2. Setup Legend Mapping
  default_legend <- list(
    "un"              = "UN",
    "dhis2"           = "DHIS2",
    "anc1"            = "ANC1",
    "penta1"          = "Penta1",
    "penta1derived"   = "Penta1 Population Growth",
    "anc1derived"     = "ANC1 Population Growth",
    "survey"          = "Survey Estimate",
    "survey_year"     = "Survey Year",
    "facility"        = "Facility-based coverage (%)",
    "survey_national" = "Coverage survey, national"
  )
  final_legend <- modifyList(default_legend, as.list(unlist(legend_labels)))
  ordered_keys <- names(final_legend)
  ordered_labels <- unname(unlist(final_legend)) 

  # 3. Create a Stable Color Palette 
  internal_colors <- c(
    "anc1"          = "#E41A1C", 
    "anc1derived"   = "#377EB8", 
    "dhis2"         = "#4DAF4A", 
    "penta1derived" = "#984EA3", 
    "penta1"        = "#FF7F00", 
    "un"            = "#A65628", 
    "survey"        = "black",
    "survey_year"   = "black"
  )
  pal <- set_names(internal_colors[intersect(ordered_keys, names(internal_colors))], ordered_labels[ordered_keys %in% names(internal_colors)])

  # 4. Set Labels based on the plot type
  surv_indicator <- paste0('r_', indicator)
  ll_indicator <- paste0('ll_', indicator)
  ul_indicator <- paste0('ul_', indicator)

  title_text <- if (type == "trend") {
    str_glue("{region %||% 'National'} Coverage Over Time by Denominator")
  } else if (is_dot_plot) {
    paste("Comparison of", toupper(indicator), "Coverage Estimates by Region (", data_year, ")")
  } else {
    str_glue("{indicator_title} Coverage, DHIS2-based with different denominators, and survey coverage for {data_year}")
  }

  final_title <- title %||% title_text
  
  if (type == "bar") {
    final_x_label <- x_label %||% if (is_dot_plot) 'Coverage (%)' else NULL
    final_y_label <- y_label %||% if (is_dot_plot) 'Region/Location' else "Coverage (%)"
  } else {
    final_x_label <- x_label %||% "Year"
    final_y_label <- y_label %||% str_glue("{indicator_title} Coverage (%)")
  }

  # 5. Generate the Plot
  if (type == "bar") {

    data <- x %>%
        mutate(year = if_else(year == survey_year, data_year, year)) %>%
        filter(year == data_year) %>%
        summarise(
          across(everything(), ~ if (all(is.na(.))) NA else first(na.omit(.))),
          .by = any_of(admin_level_cols)
        ) %>%
        select(any_of(admin_level_cols), starts_with('cov'), starts_with('r'), starts_with('ll'), starts_with('ul')) %>%
        pivot_longer(
          cols = starts_with(cov_indicator),
          names_to = "coverage_type",
          values_to = "coverage_value"
        ) %>%
        mutate(
          method = sub(paste0("^", cov_indicator, "_?"), "", coverage_type),
          method_lbl = factor(
            recode(method, !!!final_legend, .default = method),
            levels = unique(ordered_labels)
          )
        ) %>% 
        filter(!is.na(coverage_value))
    
    if (is_dot_plot) {
      # --- SUBNATIONAL (HORIZONTAL FACETED BAR GRAPH) ---      
      ggplot(data, aes(x = coverage_value, y = reorder(!!sym(admin_level), coverage_value), fill = method_lbl)) +
        geom_col(alpha = 0.8) +
        geom_errorbarh(aes(xmin = !!sym(ll_indicator), xmax = !!sym(ul_indicator)), height = 0.2, colour = "black", na.rm = TRUE) +
        geom_point(aes(x = !!sym(surv_indicator), shape = "survey_point"),  color = "black", size = 3, na.rm = TRUE) +
        scale_shape_manual(name = NULL, values = c("survey_point" = 18), labels = final_legend[["survey"]]) +
        geom_vline(xintercept = 100, linetype = "dashed", color = "grey50") +
        facet_wrap(~ method_lbl, ncol = 3) +
        cd_plot_theme(
          title = final_title,
          x_axis = final_x_label,
          y_axis = final_y_label
        ) +
        theme(legend.position = "none")
        
    } else {
      # --- NATIONAL (VERTICAL BAR GRAPH) ---      
      survey_val <- first(na.omit(data[[surv_indicator]]))
      survey_ll  <- first(na.omit(data[[ll_indicator]]))
      survey_ul  <- first(na.omit(data[[ul_indicator]]))

      max_y <- max(100, max(data$coverage_value, na.rm = TRUE), survey_val, survey_ul, na.rm = TRUE)
      
      lbl_facility <- final_legend$facility
      lbl_survey <- final_legend$survey_national
      legend_colors <- stats::setNames(c("darkgoldenrod3", "darkgreen"), c(lbl_facility, lbl_survey))
      
      ggplot(data, aes(x = method_lbl, y = coverage_value)) +
        geom_col(aes(color = lbl_facility), fill = "darkgoldenrod3", width = 0.6) +
        geom_text(aes(label = round(coverage_value, 1)), vjust = -0.5, size = 4, color = "black") +
        geom_hline(aes(yintercept = survey_val, color = lbl_survey), linewidth = 1, na.rm = TRUE) +
        geom_hline(yintercept = survey_ll, color = "darkgreen", linetype = "dashed", alpha = 0.5, na.rm = TRUE) +
        geom_hline(yintercept = survey_ul, color = "darkgreen", linetype = "dashed", alpha = 0.5, na.rm = TRUE) +
        scale_y_continuous(limits = c(0, max_y), breaks = scales::pretty_breaks(n = 11), expand = expansion(mult = c(0, 0.1))) +
        scale_color_manual(values = legend_colors, name = NULL) +
        cd_plot_theme(
          title = final_title,
          x_axis = final_x_label,
          y_axis = final_y_label
        )
    }
      
  } else if (type == "trend") {
    
    cols <- x %>%
      select(year, starts_with(cov_indicator)) %>%
      filter(year >= 2020) %>% 
      pivot_longer(cols = -year, names_to = "series", values_to = "value") %>%
      mutate(
        suffix = gsub(paste0("^", cov_indicator, "_?"), "", series),
        series_label = factor(unlist(final_legend)[suffix], levels = ordered_labels)
      )

    max_val <- robust_max(cols$value, fallback = 100)
    y_max <- max(100, ceiling(max_val / 10) * 10)

    line_df <- data.frame(x_val = data_year, line_type = "survey_year")

    ggplot(cols, aes(x = year, y = value, colour = series_label, group = series_label)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      geom_hline(yintercept = 100, linetype = "dashed", colour = "gray70") +
      geom_vline(data = line_df, aes(xintercept = x_val, linetype = line_type), color = "black", linewidth = 1, show.legend = TRUE) +
      scale_linetype_manual(name = NULL, values = c("survey_year" = "dotdash"),  labels = final_legend[["survey_year"]]) +
      scale_y_continuous(
        breaks = scales::pretty_breaks(n = 13),
        expand = expansion(mult = c(0, 0.05)),
        limits = c(0, y_max),
        labels = scales::label_number(accuracy = 1)
      ) +
      scale_color_manual(values = pal, name = NULL) +
      cd_plot_theme(
        title = final_title,
        x_axis = final_x_label, 
        y_axis = final_y_label  
      )
  }
}
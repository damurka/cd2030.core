#' Plot Derived vs Traditional Coverage Over Time
#'
#' This function generates a line plot comparing traditional (`coverage_old`)
#' and derived (`coverage_new`) coverage estimates over time for a single indicator.
#' It supports both national and subnational views.
#'
#' @param x A `cd_coverage_trends` object.
#' @param year (optional) An integer for the year to plot the dot plot
#' @param region (Optional) A character string of the region or district name.
#'   Required for subnational data, must be `NULL` for national data.
#' @param title (Optional) A scalar character string to override the default plot title. Defaults to `NULL`.
#' @param x_label (Optional) A scalar character string to override the default x-axis label. Defaults to `NULL`.
#' @param y_label (Optional) A scalar character string to override the default y-axis label. Defaults to `NULL`.
#' @param legend_labels (Optional) A named list of character strings to override specific
#'   default legend labels (e.g., `list(penta1derived = "Custom Penta1")`).
#' @param ... Additional arguments passed to `ggplot2` layers (not used).
#'
#' @return A `ggplot` object showing coverage trends over time.
#' @export
plot.cd_derived_coverage <- function(x, year = NULL, title = NULL, x_label = NULL, y_label = NULL, legend_labels = list(), ...) {
  
  # 1. Metadata Extraction & Validation
  admin_level <- attr_or_abort(x, "admin_level")
  indicator <- attr_or_abort(x, "indicator")
  indicator_title <- str_to_title(indicator) 
  region <- attr_or_null(x, 'region')
  
  # Extract max year globally so it can be used in titles
  min_yr <- min(x$year, na.rm = TRUE)
  max_yr <- max(x$year, na.rm = TRUE)

  data_year <- if (!is.null(year)) {
    # Validate that it is a single integer
    if (!is.numeric(year) || length(year) != 1 || year %% 1 != 0) {
      cd_abort(c("x" = "{.arg year} must be a single integer."))
    }
    
    # Clamp the year so it is never less than min or greater than max
    if (year < min_yr) {
      min_yr
    } else if (year > max_yr) {
      cd_abort(c("x" = "The requested {.arg year} ({year}) cannot be greater than the maximum available year in the data ({max_yr})."))
    } else {
      year
    }
  } else {
    # Fallback to survey_year attribute, or max year if attribute doesn't exist
    attr_or_null(x, 'survey_year')
  }

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
    "un"            = "UN",
    "dhis2"         = "DHIS2",
    "anc1"          = "ANC1",
    "penta1"        = "Penta1",
    "penta1derived" = "Penta1 Population Growth",
    "anc1derived"   = "ANC1 Population Growth"
  )
  final_legend <- modifyList(default_legend, as.list(unlist(legend_labels)))
  ordered_keys <- names(final_legend)
  ordered_labels <- unname(unlist(final_legend)) # Locks in the exact order for the legend

  # 3. Create a Stable Color Palette matching the image (Set1 Hex Codes)
  internal_colors <- c(
    "anc1"          = "#E41A1C", # Red
    "anc1derived"   = "#377EB8", # Blue
    "dhis2"         = "#4DAF4A", # Green
    "penta1derived" = "#984EA3", # Purple
    "penta1"        = "#FF7F00", # Orange
    "un"            = "#A65628"  # Brown (added a distinct color for UN)
  )
  
  # Map the internal colors to the translated display labels dynamically
  pal <- set_names(internal_colors[ordered_keys], ordered_labels)

  # 4. Determine Plot Type and Set Labels
  cov_indicator <- paste0('cov_', indicator)
  is_dot_plot <- admin_level != 'national' && is.null(region)

  title_text <- if (admin_level == "national") {
    "National Coverage Over Time by Denominator"
  } else if (is_dot_plot) {
    paste("Comparison of", toupper(indicator), "Coverage Estimates by Region (", data_year, ")")
  } else {
    str_glue("{region} Coverage Over Time by Denominator")
  }

  final_title <- title %||% title_text
  final_x_label <- x_label %||% if (is_dot_plot) 'Coverage (%)' else "Year"
  final_y_label <- y_label %||% if (is_dot_plot) 'Region' else str_glue("{indicator_title} Coverage (%)")

  # 5. Generate the Respective Plot
  if (is_dot_plot) {
    
    # Data wrangling for dot plot
    data <- x %>%
      filter(year == data_year) %>%
      select(all_of(admin_level), starts_with('cov')) %>%
      pivot_longer(
        cols = starts_with(cov_indicator),
        names_to = "coverage_type",
        values_to = "coverage_value"
      ) %>%
      mutate(
        method = sub(paste0("^", cov_indicator, "_?"), "", coverage_type),
        # Use dplyr::recode safely
        method_lbl = factor(
          recode(method, !!!final_legend, .default = method),
          levels = ordered_labels
        )
      ) %>% 
      filter(!is.na(coverage_value))
    
    ggplot(data, aes(x = coverage_value, y = reorder(!!sym(admin_level), coverage_value), fill = method_lbl)) +
      # geom_point(size = 3, alpha = 0.8) +
      geom_col(alpha = 0.8) +
      geom_vline(xintercept = 100, linetype = "dashed", color = "grey50") +
      facet_wrap(~ method_lbl, ncol = 3) +
      # scale_color_manual(values = pal, breaks = ordered_labels) +
      cd_plot_theme(
        title = final_title,
        x_axis = final_x_label,
        y_axis = final_y_label,
        # legend = ""
      ) +
      theme(
        # panel.grid.major.y = element_line(color = "grey90", linetype = "dotted"),
        legend.position = "none"
      )
      
  } else {
    
    # Data wrangling for trend line
    cols <- x %>%
      select(year, starts_with(cov_indicator)) %>%
      pivot_longer(cols = -year, names_to = "series", values_to = "value") %>%
      mutate(
        suffix = gsub(paste0("^", cov_indicator, "_?"), "", series),
        series_label = factor(unlist(final_legend)[suffix], levels = ordered_labels)
      )

    max_val <- robust_max(cols$value, fallback = 100)
    y_max <- max(100, ceiling(max_val / 10) * 10)

    ggplot(cols, aes(x = year, y = value, colour = series_label, group = series_label)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      geom_hline(yintercept = 100, linetype = "dashed", colour = "gray70") +
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
#' Plot National Denominators and Coverage Indicators
#'
#' Generates specific plots for national denominators and health coverage indicators.
#' It supports dynamic customization of titles and labels.
#'
#' @param x A `cd_indicator_coverage` object containing the calculated indicators.
#' @param plot_type Character. The specific indicator set to plot. Valid options include:
#'   - **DHIS2 Denominators**: `"anc_coverage_dhis2"`, `"delivery_coverage_dhis2"`, `"immunization_coverage_dhis2"`
#'   - **UN Denominators**: `"anc_coverage_un"`, `"delivery_coverage_un"`, `"immunization_coverage_un"`
#'   - **ANC1 Derived**: `"anc_coverage_anc1"`, `"delivery_coverage_anc1"`, `"immunization_coverage_anc1"`
#'   - **Penta1 Derived**: `"anc_coverage_penta1"`, `"delivery_coverage_penta1"`, `"immunization_coverage_penta1"`
#' @param admin_name Optional character. The specific admin area to filter by (required if data is subnational).
#' @param title Optional character. Custom plot title.
#' @param x_label Optional character. Custom x-axis label (default "Year").
#' @param y_label Optional character. Custom y-axis label (default "%").
#' @param legend_labels Optional character vector. Custom labels for the legend items. Must match the number of lines in the selected plot type.
#' @param ... Additional arguments passed to the plotting function.
#'
#' @return A ggplot object.
#' @export
plot.cd_indicator_coverage <- function(x,
                                       plot_type = c(
                                         "anc_coverage_dhis2", "delivery_coverage_dhis2", "immunization_coverage_dhis2",
                                         "anc_coverage_un", "delivery_coverage_un", "immunization_coverage_un",
                                         "anc_coverage_anc1", "delivery_coverage_anc1", "immunization_coverage_anc1",
                                         "anc_coverage_penta1", "delivery_coverage_penta1", "immunization_coverage_penta1"
                                       ),
                                       admin_name = NULL,
                                       title = NULL,
                                       x_label = NULL,
                                       y_label = NULL,
                                       legend_labels = NULL,
                                       ...) {
  # --- 1. Validation & Setup ---
  plot_type <- arg_match(plot_type)
  admin_level <- attr(x, "admin_level")

  # Check Admin Level Logic
  if (admin_level == "national" && !is.null(admin_name)) {
    cd_abort(c("x" = "{.arg admin_name} should be null when the coverage data is national"))
  }
  if (admin_level != "national" && is.null(admin_name)) {
    cd_abort(c("x" = "{.arg admin_name} should be not null when the coverage data is subnational"))
  }
  if (admin_level != "national" && endsWith(plot_type, "_un")) {
    cd_abort(c("x" = "{.arg {plot_type}} cannot be plotted at subnational level"))
  }

  # Filtering
  if (!is.null(admin_level) && admin_level != "national") {
    x <- x %>% filter(!!sym(admin_level) == admin_name)
  }

  if (NROW(x) == 0) {
    cd_abort(c("x" = "{.arg {admin_name}} does not exist in the data."))
  }

  # --- 2. Configuration Defaults ---
  # Define standard labels for reuse
  lbl_anc <- c("Coverage ANC-1", "Inst'l birth coverage")
  lbl_del <- c("Zerodose children (Penta1) %", "Underimmunized children %", "Penta 1 to 3 dropout rate", "Measles 1 to 2 dropout rate")
  lbl_imm <- c("Coverage of Penta-1", "Coverage of Penta-3", "Coverage of opv-3", "Coverage of ipv-1", "Coverage of BCG", "Measles1 vacc coverage", "Measles2 vacc coverage")
  # UN immunzation has slightly different columns/labels (no ipv-1 usually in the source provided)
  lbl_imm_un <- c("Coverage of Penta-1", "Coverage of Penta-3", "Coverage of opv-3", "Coverage of BCG", "Measles1 vacc coverage", "Measles2 vacc coverage")

  defaults <- list(
    # DHIS2 Based
    anc_coverage_dhis2 = list(
      y_vars = c("cov_anc1_dhis2", "cov_instlivebirths_dhis2"),
      legend_labels = lbl_anc,
      title = "ANC Coverage indicators, based on projected live births in DHIS-2"
    ),
    delivery_coverage_dhis2 = list(
      y_vars = c("cov_zerodose_dhis2", "cov_undervax_dhis2", "cov_dropout_penta13_dhis2", "cov_dropout_measles12_dhis2"),
      legend_labels = lbl_del,
      title = "Delivery Coverage indicators, based on projected live births in DHIS-2"
    ),
    immunization_coverage_dhis2 = list(
      y_vars = c("cov_penta1_dhis2", "cov_penta3_dhis2", "cov_opv3_dhis2", "cov_ipv1_dhis2", "cov_bcg_dhis2", "cov_measles1_dhis2", "cov_measles2_dhis2"),
      legend_labels = lbl_imm,
      title = "Immunization coverage indicators, DHIS-2 data, NATIONAL, based on projected births in DHIS-2"
    ),

    # UN Based
    anc_coverage_un = list(
      y_vars = c("cov_anc1_un", "cov_instlivebirths_un"),
      legend_labels = lbl_anc,
      title = "ANC Coverage indicators, based on UN projections"
    ),
    delivery_coverage_un = list(
      y_vars = c("cov_zerodose_un", "cov_undervax_un", "cov_dropout_penta13_un", "cov_dropout_measles12_un"),
      legend_labels = lbl_del,
      title = "Delivery Coverage indicators, based on UN projections"
    ),
    immunization_coverage_un = list(
      y_vars = c("cov_penta1_un", "cov_penta3_un", "cov_opv3_un", "cov_bcg_un", "cov_measles1_un", "cov_measles2_un"),
      legend_labels = lbl_imm_un,
      title = "Immunization coverage indicators, DHIS-2 data, NATIONAL, based on UN projections"
    ),

    # ANC1 Derived
    anc_coverage_anc1 = list(
      y_vars = c("cov_anc1_anc1", "cov_instlivebirths_anc1"),
      legend_labels = lbl_anc,
      title = "ANC Coverage indicators, based on ANC1 derived denominator"
    ),
    delivery_coverage_anc1 = list(
      y_vars = c("cov_zerodose_anc1", "cov_undervax_anc1", "cov_dropout_penta13_anc1", "cov_dropout_measles12_anc1"),
      legend_labels = lbl_del,
      title = "Delivery Coverage indicators, based on ANC1 derived denominator"
    ),
    immunization_coverage_anc1 = list(
      y_vars = c("cov_penta1_anc1", "cov_penta3_anc1", "cov_opv3_anc1", "cov_ipv1_anc1", "cov_bcg_anc1", "cov_measles1_anc1", "cov_measles2_anc1"),
      legend_labels = lbl_imm,
      title = "Immunization coverage indicators, DHIS-2 data, NATIONAL, based on ANC1 derived denominator"
    ),

    # Penta1 Derived
    anc_coverage_penta1 = list(
      y_vars = c("cov_anc1_penta1", "cov_instlivebirths_penta1"),
      legend_labels = lbl_anc,
      title = "ANC Coverage indicators, based Penta1 derived denominator"
    ),
    delivery_coverage_penta1 = list(
      y_vars = c("cov_zerodose_penta1", "cov_undervax_penta1", "cov_dropout_penta13_penta1", "cov_dropout_measles12_penta1"),
      legend_labels = lbl_del,
      title = "Delivery Coverage indicators, based on Penta1 derived denominator"
    ),
    immunization_coverage_penta1 = list(
      y_vars = c("cov_penta1_penta1", "cov_penta3_penta1", "cov_opv3_penta1", "cov_ipv1_penta1", "cov_bcg_penta1", "cov_measles1_penta1", "cov_measles2_penta1"),
      legend_labels = lbl_imm,
      title = "Immunization coverage indicators, DHIS-2 data, NATIONAL, based on Penta1 derived denominator"
    )
  )

  # --- 3. Execute Plot ---
  config <- defaults[[plot_type]]

  plot_line_graph(
    .data = x,
    x = "year",
    y_vars = config$y_vars,
    legend_labels = legend_labels %||% config$lgend_labels, # User overrides or default
    title = title %||% config$title, # User overrides or default
    y_axis = y_label %||% "%",
    x_axis = x_label %||% "Year"
  )
}

#' Plot Coverage by Denominator Source with Survey Reference
#'
#' Generates a bar plot comparing DHIS2-based coverage using various denominator sources
#' against national survey coverage.
#'
#' @param x A data frame of class `'cd_indicator_coverage_filtered'` as returned by [filter_indicator_coverage()].
#' @param title (Optional) A scalar character string to override the default plot title.
#' @param x_label (Optional) A scalar character string to override the default x-axis label.
#' @param y_label (Optional) A scalar character string to override the default y-axis label.
#' @param category_labels (Optional) A named list to override the x-axis bar categories
#'   (keys: `dhis2`, `anc1`, `penta1`, `un`, `penta1derived`, `anc1derived`).
#' @param legend_labels (Optional) A named list to override the legend keys
#'   (keys: `facility`, `survey`).
#' @param ... Additional arguments (not used).
#'
#' @return A `ggplot2` object showing coverage by denominator type and national survey line.
#'
#' @export
plot.cd_indicator_coverage_filtered <- function(x, title = NULL, x_label = NULL, y_label = NULL, category_labels = list(), legend_labels = list(), ...) {
  # Validate scalar character inputs for custom labels
  if (!is.null(title) && (!is.character(title) || length(title) != 1)) {
    cd_abort("x" = "{.arg title} must be a scalar character or NULL.")
  }
  if (!is.null(x_label) && (!is.character(x_label) || length(x_label) != 1)) {
    cd_abort("x" = "{.arg x_label} must be a scalar character or NULL.")
  }
  if (!is.null(y_label) && (!is.character(y_label) || length(y_label) != 1)) {
    cd_abort("x" = "{.arg y_label} must be a scalar character or NULL.")
  }

  # Extract attributes
  indicator <- attr_or_abort(x, "indicator")
  coverage <- attr_or_abort(x, "coverage")
  year <- unique(x$year)
  indicator_raw <- unique(x$indicator_name)

  # Pretty indicator name
  indicator_pretty <- switch(indicator_raw,
                             instdeliveries = "Institutional Delivery",
                             anc4 = "ANC 4",
                             low_bweight = "Low Birth Weight",
                             penta3 = "Penta 3",
                             measles1 = "Measles 1",
                             bcg = "BCG",
                             str_to_title(indicator_raw)
  )

  # 1. Resolve Final Plot Text
  title_default <- str_glue("{indicator_pretty} Coverage, DHIS2-based with different denominators, and survey coverage for {year}")

  final_title <- title %||% title_default
  final_x_label <- x_label # Leaving default as NULL per original code
  final_y_label <- y_label %||% "Coverage (%)"

  # 2. Setup Legend Labels
  default_legend <- list(
    "facility" = "Facility-based coverage (%)",
    "survey"   = "Coverage survey, national"
  )
  final_legend <- utils::modifyList(default_legend, as.list(legend_labels))

  # 3. Setup Category (X-axis) Labels
  default_categories <- list(
    un            = "UN projection",
    dhis2         = "DHIS2 projection",
    anc1          = "ANC1-derived",
    penta1        = "Penta1-derived",
    penta1derived = "Penta 1 population Growth",
    anc1derived   = 'ANC1 Population Growth'
  )
  final_categories <- utils::modifyList(default_categories, as.list(category_labels))
  cat_map <- unlist(final_categories)

  # 4. Map the labels and format as a factor (using unique() to prevent duplicate level crashes!)
  x <- x %>%
    mutate(
      category_label = factor(cat_map[category], levels = unique(cat_map))
    )

  # Determine upper y-axis limit
  max_y <- robust_max(c(x$value, coverage))
  max_y <- max(100, max_y)
  limits <- c(0, max_y)
  breaks <- scales::pretty_breaks(n = 11)(limits)

  # Extract mapped legend names to use in scale_color_manual
  lbl_facility <- final_legend$facility
  lbl_survey <- final_legend$survey

  legend_colors <- stats::setNames(
    c("darkgoldenrod3", "darkgreen"),
    c(lbl_facility, lbl_survey)
  )

  # Plot
  ggplot(x, aes(x = category_label, y = value)) +
    geom_col(aes(color = lbl_facility), fill = "darkgoldenrod3", width = 0.6) +
    geom_hline(aes(yintercept = coverage, color = lbl_survey), linewidth = 1) +
    scale_y_continuous(limits = limits, breaks = breaks, expand = expansion(mult = c(0, 0.1))) +
    scale_color_manual(values = legend_colors, name = NULL) +
    cd_plot_theme(
      title = final_title,
      x_axis = final_x_label,
      y_axis = final_y_label
    )
}

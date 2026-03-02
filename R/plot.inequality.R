#' Plot Subnational Health Coverage Analysis
#'
#' Generates a plot to visualize health coverage data across subnational units,
#' distinguishing between the national mean and subnational coverage. The Mean
#' Absolute Difference to the Mean (MADM) is displayed as an indicator on the
#' y-axis.
#'
#' @param x A `cd_inequality_filtered` object returned by [filter_inequality()].
#' @param title (Optional) A scalar character string to override the default plot title. Defaults to `NULL`.
#' @param subtitle (Optional) A scalar character string to override the default plot subtitle. Defaults to `NULL`.
#' @param x_axis (Optional) A scalar character string to override the default x-axis label. Defaults to `NULL`.
#' @param y_axis (Optional) A scalar character string to override the default y-axis label. Defaults to `NULL`.
#' @param caption (Optional) A scalar character string to override the default denominator caption. Defaults to `NULL`.
#' @param legend_labels (Optional) A named list or vector to override the legend keys and MADM label for translation.
#'   Valid keys: `subnational`, `national`, `madm`. Defaults to `NULL`.
#' @param ... Additional arguments passed to the plotting function.
#'
#' @return A `ggplot` object displaying the subnational health coverage plot.
#'
#' @export
plot.cd_inequality_filtered <- function(x, title = NULL, subtitle = NULL, x_axis = NULL, y_axis = NULL, caption = NULL, legend_labels = NULL, ...) {
  year = nat = madm = NULL

  admin_level <- attr_or_abort(x, "admin_level")
  region <- attr_or_null(x, 'region')
  indicator <- attr_or_abort(x, 'indicator')
  denominator <- attr_or_abort(x, 'denominator')

  # Validate scalar character inputs for custom labels
  if (!is.null(title) && !is_scalar_character(title)) {
    cd_abort("x" = "{.arg title} must be a scalar character or NULL.")
  }
  if (!is.null(subtitle) && !is_scalar_character(subtitle)) {
    cd_abort("x" = "{.arg subtitle} must be a scalar character or NULL.")
  }
  if (!is.null(x_axis) && !is_scalar_character(x_axis)) {
    cd_abort("x" = "{.arg x_axis} must be a scalar character or NULL.")
  }
  if (!is.null(y_axis) && !is_scalar_character(y_axis)) {
    cd_abort("x" = "{.arg y_axis} must be a scalar character or NULL.")
  }
  if (!is.null(caption) && !is_scalar_character(caption)) {
    cd_abort("x" = "{.arg caption} must be a scalar character or NULL.")
  }

  # 1. Resolve Default Texts
  default_title <- switch(indicator,
                          anc1 = "Antenatal care 1+ visits",
                          anc4 = "Antenatal care 4+ visits",
                          instdeliveries = "Institutional deliveries",
                          instlivebirths = "Institutional live births",
                          bcg = "BCG vaccine",
                          penta1 = "Penta vaccine - 1st dose",
                          penta3 = "Penta vaccine - 3rd dose",
                          measles1 = "Measles vaccine - 1st dose",
                          measles2 = "Measles vaccine - 2nd dose",
                          sba = "Skilled attendant at birth",
                          opv1 = "Polio vaccine - 1st dose",
                          opv2 = "Polio vaccine - 2nd dose",
                          opv3 = "Polio vaccine - 3rd dose",
                          penta2 = "Penta vaccine - 2nd dose",
                          pcv1 = "Pneumococcal vaccine - 1st dose",
                          pcv2 = "Pneumococcal vaccine - 2nd dose",
                          pcv3 = "Pneumococcal vaccine - 3rd dose",
                          rota1 = "Rota vaccine - 1st dose",
                          rota2 = "Rota vaccine - 2nd dose",
                          ipv1 = "IPV vaccine - 1st dose",
                          ipv2 = "IPV vaccine - 2nd dose",
                          str_to_title(indicator) # Fallback
  )

  default_subtitle <- switch(admin_level,
                             district = "Subnational unit: district level",
                             adminlevel_1 = str_glue("Subnational unit: {if (is.null(region)) 'admin 1 level' else region}")
  )

  default_caption <- switch(denominator,
                            dhis2 = "Denominators derived from projected live births (DHIS2)",
                            anc1 = "Denominators derived from ANC1 estimates",
                            penta1 = "Denominators derived from Penta 1 estimates",
                            paste0("Denominators derived from ", denominator, " estimates") # Fallback
  )

  default_y_axis <- ifelse(indicator == "low_bweight", "Prevalence (%)", "Coverage (%)")

  # 2. Assign Final Texts
  final_title <- title %||% default_title
  final_subtitle <- subtitle %||% default_subtitle
  final_caption <- caption %||% default_caption
  final_x_axis <- x_axis %||% "Year"
  final_y_axis <- y_axis %||% default_y_axis

  # 3. Handle Legend Labels
  default_legend <- list(
    subnational = "Coverage at subnational unit",
    national = if (is.null(region)) "National coverage" else str_glue("{region} Coverage"),
    madm = "MADM"
  )

  user_labels <- if (is.null(legend_labels)) list() else as.list(legend_labels)
  final_legend <- utils::modifyList(default_legend, user_labels)

  lbl_subnat <- final_legend$subnational
  lbl_nat <- final_legend$national
  lbl_madm <- final_legend$madm

  # Setup Y-axis properties
  max_y <- robust_max(x$rd_max, 100)
  limits <- c(0, max_y)
  breaks <- scales::pretty_breaks(n = 11)(limits)
  second_last_break <- sort(breaks, decreasing = TRUE)[2]
  max_break <- robust_max(breaks, 0)

  # 4. Build Plot
  ggplot(x) +
    geom_point(
      aes(x = year, y = !!sym(paste0("cov_", indicator, "_", denominator)), color = lbl_subnat),
      size = 3
    ) +
    geom_point(aes(x = year, y = nat, color = lbl_nat), size = 1.5, shape = 3, stroke = 1.5) +
    geom_text(
      aes(x = year, y = second_last_break, label = round(madm, 2)),
      color = "black", fontface = "bold", vjust = 0.5, size = 4
    ) +
    geom_hline(yintercept = 100, linetype = "dashed", color = "gray60") +
    scale_y_continuous(
      expand = expansion(mult = c(0, 0.05)),
      limits = range(c(limits, max_break), na.rm = TRUE),
      breaks = breaks,
      labels = function(y) ifelse(y == second_last_break, lbl_madm, ifelse(y == max_break, "", as.character(y))) # Replace max_y - 10 with "MADM"
    ) +
    scale_color_manual(values = set_names(c('skyblue3', 'red1'), c(lbl_subnat, lbl_nat))) +
    cd_plot_theme(
      title = final_title,
      y_axis = final_y_axis,
      x_axis = final_x_axis,
      subtitle = final_subtitle,
      caption = final_caption
    ) +
    theme(
      panel.border = element_blank(),
      panel.grid.major.y = element_line(colour = "lightblue1", linetype = "dashed"),
      panel.grid.major.x = element_line(colour = "gray90", linetype = "dashed"),
      plot.title = element_text(size = 16),
      plot.subtitle = element_text(size = 12),
      axis.line = element_line(),
      legend.position = "right",
      legend.background = element_blank()
    )
}

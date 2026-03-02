#' Plot Derived vs Traditional Coverage Over Time
#'
#' This function generates a line plot comparing traditional (`coverage_old`)
#' and derived (`coverage_new`) coverage estimates over time for a single indicator.
#' It supports both national and subnational views.
#'
#' @param x A `cd_coverage_trends` object.
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
#'
#' @examples
#' \dontrun{
#' # Basic usage (uses all defaults)
#' generate_coverage_data(dhis_data, "penta1", 2019) %>%
#'   plot(region = "Nairobi")
#'
#' # Customizing title, axes, and specific legend labels
#' generate_coverage_data(dhis_data, "penta1", 2019) %>%
#'   plot(
#'     region = "Nairobi",
#'     title = "Nairobi: Penta1 Coverage Trends",
#'     x_label = "Reporting Year",
#'     legend_labels = list(penta1derived = "Penta1 (Derived Estimate)")
#'   )
#' }
#'
#' @export
plot.cd_derived_coverage <- function(x, region = NULL, title = NULL, x_label = NULL, y_label = NULL, legend_labels = list(), ...) {
  admin_level <- attr_or_abort(x, "admin_level")
  indicator <- attr_or_abort(x, "indicator")
  indicator_title <- str_to_title(indicator) # Makes the default y_label look nicer (e.g., "Penta1" instead of "penta1")

  # Validate region input logic
  if (admin_level == "national" && !is.null(region)) {
    cd_abort("x" = "{.arg region} must be null in national data.")
  }

  if (admin_level != "national" && is.null(region)) {
    cd_abort("x" = "{.arg region} must not be null in subnational data.")
  }

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

  # Filter for specified region if applicable
  data <- if (admin_level != "national") {
    x %>% filter(!!sym(admin_level) == region)
  } else {
    x
  }

  # Dynamic title based on admin level
  title_text <- if (admin_level == "national") {
    "National Coverage Over Time by Denominator"
  } else {
    str_glue("{region} Coverage Over Time by Denominator")
  }

  final_title <- title %||% title_text
  final_x_label <- x_label %||% "Year"
  final_y_label <- y_label %||% str_glue("{indicator_title} Coverage (%)")

  # suffix -> pretty name map
  default_legend <- list(
    "un"            = "UN",
    "dhis2"         = "DHIS2",
    "anc1"          = "ANC1",
    "penta1"        = "Penta1",
    "penta1derived" = "Penta1-derived"
  )
  final_legend <- modifyList(default_legend, as.list(unlist(legend_labels)))

  cov_indicator <- paste0('cov_', indicator)
  legend_map <- unlist(final_legend)

  cols <- data %>%
    select(year, starts_with(cov_indicator)) %>%
    pivot_longer(cols = -year, names_to = "series", values_to = "value") %>%
    mutate(
      suffix = gsub(paste0("^", cov_indicator, "_?"), "", series),
      series_label = factor(legend_map[suffix], levels = unique(legend_map))
    )

  present_labels <- unique(cols$series_label)

  # Determine upper y-axis limit using rounded max
  max_val <- robust_max(cols$value, fallback = 100)
  y_max <- ceiling(max_val / 10) * 10
  y_max <- max(100, y_max)   # ensure at least 100

  base_pal <- c("#009E73","#E69F00","#0072B2","#8A2BE2","#D55E00","#CC79A7","#F0E442","#000000")
  pal <- set_names(base_pal[seq_along(present_labels)], present_labels)

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
      x_axis = final_x_label, # Assuming cd_plot_theme takes x_axis
      y_axis = final_y_label  # Assuming cd_plot_theme takes y_axis
    )
}

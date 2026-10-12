# ---- one type scale ---------------------------------------------------------------------------------------------
# The sizes of the text of every chart on the pages, in one place, so the charts read as one family: a chart sets
# no size of its own. In points, but for the text drawn on a chart (a number on a bar or a tile, a name beside a
# point), which geom_text() sizes in millimetres. A report gives its charts cd_report_theme(), whose sizes are in
# the same proportions from the report's own base size. The font is the device's sans serif (Arial on Windows): a
# report's charts are drawn in the report's font, and a chart's own options (font_family, text_scale) still apply.
.cd_type <- list(
  title = 15,        # the chart's title (bold, centred)
  subtitle = 12,
  axis_title = 12,
  axis_text = 11,
  legend = 11,       # a legend's entries and its title
  strip = 11,        # the name above each panel (bold)
  caption = 10,
  label = 3.5,       # text drawn on the chart
  label_small = 3    # the same where there is much of it (a number on each of many bars)
)

#' The sizes of the text of a chart
#'
#' The one scale the charts of the Countdown apps are written in, for a chart drawn outside the package that is to
#' look like them.
#'
#' @return A named list: `title`, `subtitle`, `axis_title`, `axis_text`, `legend`, `strip` and `caption` in points
#'   (for [ggplot2::element_text()]); `label` and `label_small` in millimetres (the `size` of
#'   [ggplot2::geom_text()]).
#' @examples
#' cd_type_scale()$title
#' @export
cd_type_scale <- function() .cd_type

# The scale as a theme: the size and weight of each text. `scale` multiplies the sizes.
.cd_type_theme <- function(scale = 1) {
  size <- function(name) .cd_type[[name]] * scale
  theme(
    plot.title = element_text(size = size("title"), face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = size("subtitle"), hjust = 0.5),
    plot.caption = element_text(size = size("caption"), hjust = 0),
    axis.title = element_text(size = size("axis_title")),
    axis.text = element_text(size = size("axis_text")),
    legend.text = element_text(size = size("legend")),
    legend.title = element_text(size = size("legend")),
    strip.text = element_text(size = size("strip"), face = "bold")
  )
}

cd_plot_theme <- function(title = NULL, subtitle = NULL, x_title = NULL, y_title = NULL, legend_title = NULL, caption = NULL) {
  list(
    labs(
      title = title,
      subtitle = subtitle,
      x = x_title,
      y = y_title,
      caption = caption,
      fill = legend_title
    ),
    .cd_type_theme(),
    theme(
      panel.background = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
      legend.background = element_rect(color = "black", linewidth = 0.5),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.key.size = unit(7, "mm"),
      legend.box.spacing = unit(0.5, "cm"),
      strip.background = element_blank()
    )
  )
}

# The theme report charts are given (`plot(...) + cd_report_theme()`). It also carries a marker that puts back the chart options
# saved for the chart (see cd_finish_plot()), which the theme would otherwise overwrite: fonts, sizes, grid, colours.
cd_report_theme <- function(base_size = 10, base_family = "",
                            base_line_size = base_size / 22,
                            base_rect_size = base_size / 22) {
  list(
    .cd_report_theme_base(base_size, base_family, base_line_size, base_rect_size),
    structure(list(), class = "cd_chart_options_reapply")
  )
}

.cd_report_theme_base <- function(base_size = 10, base_family = "",
                                  base_line_size = base_size / 22,
                                  base_rect_size = base_size / 22) {
  # theme(
  #   panel.background = element_blank(),
  #   panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
  #
  #   legend.background = element_rect(color = "black", linewidth = 0.5),
  #   legend.position = "bottom",
  #   legend.title = element_blank(),
  #   legend.text = element_text(size = 8),
  #   # legend.text = element_text(size = 13),
  #   # legend.key.size = unit(8, "mm"),
  #
  #   plot.title = element_text(size = 10, hjust = 0.5),
  #   plot.subtitle = element_text(size = 10, hjust = 0.5),
  #   plot.caption = element_text(hjust = 0),
  #
  #   # plot.title = element_text(size = 16, hjust = 0.5),
  #   # plot.subtitle = element_text(size = 12, hjust = 0.5),
  #   # plot.caption = element_text(size = 12, hjust = 0),
  #
  #   axis.text = element_text(size = 8),
  #   # axis.text = element_text(size = 14),
  #   axis.title = element_text(size = 10),
  #   # axis.title = element_text(size = 18),
  #
  #   strip.background = element_blank(),
  #   strip.text = element_text(size = 10),
  #   # strip.text = element_text(size = 12)
  # )

  half_line <- base_size / 2
  small_rel <- 0.85
  # the sizes of the pages' charts (.cd_type), in the same proportions, from the report's base size (its axis titles)
  type <- function(name) .cd_type[[name]] * base_size / .cd_type$axis_title
  theme_bw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  ) %>%
    theme(
      line = element_line(
        colour = "black", linewidth = base_line_size,
        linetype = 1, lineend = "butt"
      ),
      rect = element_rect(
        fill = NA, colour = "black",
        linewidth = base_rect_size, linetype = 1
      ),
      text = element_text(
        family = base_family, face = "plain",
        colour = "black", size = base_size,
        lineheight = 0.9, hjust = 0.5, vjust = 0.5,
        angle = 0, margin = margin(), debug = FALSE
      ),
      axis.line = element_line(colour = "black", linewidth = base_line_size),
      axis.line.x = element_line(colour = "black", linewidth = base_line_size),
      axis.line.y = element_line(colour = "black", linewidth = base_line_size),
      axis.text = element_text(size = type("axis_text")),
      axis.text.x = element_text(margin = margin(t = small_rel / 2), vjust = 1),
      axis.text.y = element_text(margin = margin(r = small_rel / 2), hjust = 1),
      # no tick marks, as the charts on the app's pages have none: the axis lines and the labels are enough. A
      # chart's own "Tick marks" option (cd_chart_options(axis_ticks = TRUE)) still draws them for that chart.
      axis.ticks = element_blank(),
      axis.title = element_text(size = type("axis_title")),
      axis.title.x = element_text(margin = margin(t = half_line)),
      axis.title.y = element_text(angle = 90L, margin = margin(r = half_line)),
      legend.key = element_rect(fill = "white", colour = NA),
      legend.key.size = unit(0.8, "lines"),
      legend.background = element_rect(fill = alpha("white", 0)), # Transparent background
      legend.position = "bottom", # or "bottom"
      legend.text = element_text(size = type("legend")),
      legend.title = element_text(size = type("legend")),
      panel.background = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
      panel.grid = element_blank(),

      # plot.background = element_rect(fill = NA, colour = NA),
      # the title is bold as on a page, but no larger than the axis titles: a report's chart is narrow (a column of
      # the page), and a long title at the page's proportion ran off its edge
      plot.title = element_text(
        size = base_size, face = "bold", hjust = 0.5,
        margin = margin(b = half_line)
      ),
      plot.subtitle = element_text(
        size = type("subtitle"), hjust = 0.5,
        margin = margin(b = half_line)
      ),
      plot.caption = element_text(
        size = type("caption"), hjust = 0,
        margin = margin(t = half_line)
      ),
      strip.background = element_blank(),
      strip.text = element_text(colour = "black", size = type("strip"), face = "bold")
    )
}

#' Plot a line graph of several series
#'
#' Draws one line with points for each of several columns of a data frame against a shared x
#' column, in the package's plot theme. The y axis is scaled to the data: it starts at zero when
#' all values are positive and leaves some room above the highest value.
#'
#' @param .data A data frame.
#' @param x The column name for the x-axis (e.g., "year").
#' @param y_vars Vector of column names for the y-axis data.
#' @param title Plot title.
#' @param y_title Label for the y-axis.
#' @param x_title Label for the x-axis.
#' @param legend_labels Vector of labels for the legend (must match y_vars length).
#' @param hline Optional numeric value for a horizontal reference line.
#' @param hline_style Style of the horizontal line.
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts
#'   and sizes a user changed. Applied last, so it wins over the arguments
#'   above. Default is `NULL`.
#' @param ... Chart options (see [cd_chart_options()]) given by name, applied as
#'   with `options`.
#'
#' @return A ggplot object.
#'
#' @examples
#' births <- data.frame(
#'   year = 2019:2023,
#'   un = c(1445, 1451, 1469, 1483, 1500),
#'   dhis2 = c(1390, 1402, 1455, 1478, 1461)
#' )
#' plot_line_graph(births, x = "year", y_vars = c("un", "dhis2"), title = "Live births (thousands)",
#'                 y_title = "Live births", x_title = "Year", legend_labels = c("UN estimate", "DHIS2"))
#'
#' plot_line_graph(births, x = "year", y_vars = c("un", "dhis2"), title = "Live births (thousands)",
#'                 y_title = "Live births", x_title = "Year", legend_labels = c("UN estimate", "DHIS2"),
#'                 hline = 1500, legend_position = "right")
#'
#' @export
plot_line_graph <- function(.data, x, y_vars, title, y_title, x_title, legend_labels, hline = NULL, hline_style = "dashed", options = NULL, ...) {
  variable <- value <- NULL

  # 1. Validation
  if (length(y_vars) != length(legend_labels)) {
    cd_abort(c("x" = "`y_vars` and `legend_labels` must have the same length."))
  }

  # 2. Dynamic Scaling Logic
  # Get global max/min across all y columns
  y_max <- robust_max(sapply(y_vars, function(var) robust_max(.data[[var]])))
  y_min <- min(sapply(y_vars, function(var) min(.data[[var]], na.rm = TRUE)), na.rm = TRUE)

  # Normalize min to 0 if data is positive
  if (y_min > 0) y_min <- 0

  # Round limits for cleaner axis
  y_max <- ceiling(y_max) * 1.05 # +5% headroom
  y_min <- floor(y_min)


  # 3. Reshape Data
  # We convert wide data (multiple columns) to long format for ggplot
  .data_long <- .data %>%
    select(all_of(c(x, y_vars))) %>%
    pivot_longer(cols = all_of(y_vars), names_to = "variable", values_to = "value") %>%
    mutate(
      variable = factor(variable, levels = y_vars, labels = legend_labels),
      value = value
    )

  # 4. Generate Plot
  p <- .data_long %>%
    ggplot(aes(x = !!sym(x), y = value, colour = variable, group = variable)) +
    geom_point(size = 4) +
    geom_line(linewidth = 1) +
    scale_y_continuous(
      limits = c(y_min, y_max),
      breaks = scales::pretty_breaks(10),
      labels = scales::label_number(accuracy = 1, big.mark = ",")
      # expand = c(0, 0)
    ) +
    scale_color_manual(values = set_names(.cd_palette$series[1:length(y_vars)], legend_labels)) +
    cd_plot_theme(
      title = title,
      x_title = x_title,
      y_title = y_title
    )

  # Add horizontal line if specified
  if (!is.null(hline)) {
    p <- p +
      geom_hline(yintercept = hline, linetype = hline_style, color = "grey40")
  }

  cd_finish_plot(p, options, ...)
}


cd_heatmap_theme <- function(title = NULL, x_title = NULL, y_title = NULL, legend_title = NULL) {
  list(
    cd_plot_theme(
      title = title,
      x_title = x_title,
      y_title = y_title,
      legend_title = legend_title
    ),
    theme(
      panel.border = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.ticks = element_blank(),
      axis.ticks.length = unit(0, "pt"),
      legend.title = element_text(size = .cd_type$legend)
    )
  )
}

cd_bar_theme <- function(title = NULL, x_title = NULL, y_title = NULL, legend_title = NULL) {
  list(
    cd_plot_theme(
      title = title,
      x_title = x_title,
      y_title = y_title,
      legend_title = legend_title
    ),
    theme(
      panel.grid.major = element_line(colour = "gray95"),
      axis.ticks = element_blank(),
      legend.title = element_text(size = .cd_type$legend)
    )
  )
}

# ---- shared palettes and theme pieces -------------------------------------------------------------------------------
# The colours more than one chart uses, and the theme tweaks they repeat, live here so a chart's look changes in one
# place.

.cd_palette <- list(
  # a value against a threshold, worst first: below the lower cut, between the cuts, at or above the threshold (the
  # data quality heat maps and bars; see .cd_category_fill())
  traffic_light = c("#D73027", "#FDAE61", "#1A9850"),
  # one colour per year, for bars dodged by year (see cd_year_colours())
  years = c("darkgreen", "darkgoldenrod3", "firebrick4", "springgreen3", "darkolivegreen3", "steelblue2"),
  # the same for the district reporting-rate bars
  years_reporting = c("darkgreen", "orangered", "royalblue4", "indianred4", "darkslategray4"),
  # one colour per line (plot_line_graph())
  series = c("darkgreen", "orange", "blue", "purple", "red2", "brown"),
  # Data Adjustment, the stacked chart: the reported count and what each step adds to it
  adjustment_parts = c(raw = "#c9ced3", completeness = "#9b5758", outliers = "#cfaa50", missing = "#2f6db5"),
  # Data Adjustment, the change and totals charts: the counts before, between and after the steps
  adjustment_steps = c(raw = "darkgreen", completeness = "#9b5758", outliers = "#3f88c5", missing = "#cfaa50", adjusted = "darkgoldenrod3"),
  # public against private providers
  public_private = c(Public = "#2196F3", Private = "#E91E63"),
  # an area's values against the national value (inequality), and the regions against the nation (mortality)
  subnational_national = c("skyblue3", "red1"),
  regions_national = c("forestgreen", "orangered"),
  # the median and the plausible range (subnational mortality)
  median_range = c("red", "blue")
)

# The fill for three categories `levels` (worst first) in the traffic-light colours: every category is in the legend,
# even one no value falls in.
.cd_category_fill <- function(levels, colours = .cd_palette$traffic_light) {
  scale_fill_manual(values = set_names(colours, levels), limits = levels, breaks = levels, drop = FALSE)
}

# One colour per year: `base` first, then as many more as there are years (scales::hue_pal()), named by year.
cd_year_colours <- function(years, base = .cd_palette$years) {
  extra_needed <- robust_max(c(0, length(years) - length(base)), 0)
  colours <- c(base, if (extra_needed > 0) scales::hue_pal()(extra_needed))
  names(colours) <- years
  colours
}

# Dashed major grid lines: light blue across the chart, and light grey down it unless `x = FALSE`.
cd_dashed_grid_theme <- function(x = TRUE) {
  out <- theme(panel.grid.major.y = element_line(colour = "lightblue1", linetype = "dashed"))
  if (x) out <- out + theme(panel.grid.major.x = element_line(colour = "gray90", linetype = "dashed"))
  out
}

# Maps drawn one per year (facet_wrap()): no axes, grid or border, square panels. Each map adds its own legend sizes.
cd_map_theme <- function() {
  theme(
    panel.border = element_blank(),
    panel.spacing = unit(1, "lines"),
    legend.background = element_blank(),
    legend.title = element_text(size = .cd_type$legend),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    axis.line = element_blank(),
    aspect.ratio = 1
  )
}

# A data frame with a `geometry` column as an sf object on WGS 84, ready for geom_sf(). sf is used through `sf::` (not
# imported), so it is loaded only when a map is drawn or a shapefile read.
.cd_as_map <- function(x) {
  x %>%
    sf::st_set_geometry("geometry") %>%
    sf::st_as_sf() %>%
    sf::st_set_crs(4326) %>%
    sf::st_transform(crs = 4326)
}

#' A minimal chart theme
#'
#' [ggplot2::theme_minimal()] with a choice of grid lines, for the apps' light charts (cd2030.pooled's charts, the
#' subnational coverage dot plot and heat map).
#'
#' @param base_size The base font size, in points. The default is the size the charts of the apps are written in
#'   (see [cd_type_scale()]): another size makes every text of the chart larger or smaller by the same ratio.
#' @param grid Which grid lines to keep: `"all"` (the theme's own), `"major"` (no minor lines), `"x"` (only the
#'   vertical major lines, for horizontal bars and dot plots), `"y"` (only the horizontal major lines) or `"none"`.
#' @param grid_colour The colour of the lines `"x"` or `"y"` keeps, or `NULL` for the theme's own.
#'
#' @return A ggplot2 theme.
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, factor(cyl))) +
#'   geom_point() +
#'   cd_minimal_theme(grid = "x")
#' @export
cd_minimal_theme <- function(base_size = 11, grid = c("all", "major", "x", "y", "none"), grid_colour = NULL) {
  grid <- arg_match(grid)
  # the same sizes of text as every other chart (theme_minimal() has its own proportions)
  out <- theme_minimal(base_size = base_size) + .cd_type_theme(scale = base_size / 11)
  # the lines kept along one axis, in their own colour if one is given
  only <- function(kept, dropped) {
    elements <- list(panel.grid.minor = element_blank())
    elements[[dropped]] <- element_blank()
    if (!is.null(grid_colour)) elements[[kept]] <- element_line(colour = grid_colour)
    out + do.call(theme, elements)
  }
  switch(grid,
    all = out,
    major = out + theme(panel.grid.minor = element_blank()),
    x = only("panel.grid.major.x", "panel.grid.major.y"),
    y = only("panel.grid.major.y", "panel.grid.major.x"),
    none = out + theme(panel.grid = element_blank())
  )
}

cd_categorized_heatmap <- function(data,
                                   x_col,
                                   y_col,
                                   value_col,
                                   threshold = 90,
                                   title = NULL,
                                   x_title = NULL,
                                   y_title = NULL,
                                   legend_title = NULL,
                                   reverse = FALSE,
                                   text_size = NULL,
                                   labels = NULL) {
  check_scalar_integerish(threshold)

  colors <- .cd_palette$traffic_light
  if (reverse) colors <- rev(colors)

  cut_low <- if (reverse) 100 - threshold else 70
  cut_high <- if (reverse) 30 else threshold

  low <- if (reverse) paste0("\u2264 ", cut_low) else "< 70"
  mid <- if (reverse) paste0("> ", cut_low, " and \u2264 ", cut_high) else paste0("\u2265 70 and < ", threshold)
  greater <- if (reverse) paste0("> ", cut_high) else paste0("\u2265 ", threshold)

  lvl <- c(low, mid, greater)

  dt <- data %>%
    mutate(
      .value_round = round(!!sym(value_col)),
      color_category = case_when(
        !!sym(value_col) <= cut_low ~ low,
        !!sym(value_col) > cut_low & !!sym(value_col) <= cut_high ~ mid,
        .default = greater,
        .ptype = factor(levels = lvl)
      )
    )

  # the numbers get smaller as the columns get many, and are read on any of the three colours
  columns <- length(unique(dt[[x_col]]))
  text_size <- text_size %||% if (columns > 24) 2.8 else if (columns > 14) .cd_type$label_small else .cd_type$label
  # not wrapped: the names on the horizontal axis are slanted, and those on the vertical one have a row each
  axis_labels <- .cd_axis_labels(labels, width = Inf)
  # an axis with no title given is named for what it holds, not after the column
  axis_name <- function(column) {
    switch(column, adminlevel_1 = "Admin level 1", district = "District", indicator = "Indicator", year = "Year", column)
  }

  ggplot(dt, aes(x = !!sym(x_col), y = !!sym(y_col), fill = color_category)) +
    geom_tile(color = "white", linewidth = 0.6, show.legend = TRUE) +
    geom_text(aes(label = .value_round, colour = color_category), size = text_size, vjust = 0.5, show.legend = FALSE) +
    .cd_category_fill(lvl, colors) +
    scale_colour_manual(values = set_names(.cd_text_on(colors), lvl), guide = "none") +
    scale_x_discrete(expand = expansion(mult = 0), labels = axis_labels) +
    scale_y_discrete(expand = expansion(mult = 0), labels = axis_labels) +
    cd_heatmap_theme(
      title = title,
      x_title = x_title %||% axis_name(x_col),
      y_title = y_title %||% axis_name(y_col),
      legend_title = legend_title %||% if (reverse) "Missing (%)" else "Percent (%)"
    )
}

# Adding the marker to a plot applies the options the plot was finished with once more, on top of the theme just added.
#' @exportS3Method ggplot2::ggplot_add
ggplot_add.cd_chart_options_reapply <- function(object, plot, ...) {
  options <- attr(plot, "cd_chart_options", exact = TRUE)
  if (is.null(options)) return(plot)
  plot <- apply_chart_options(plot, options)
  attr(plot, "cd_chart_options") <- options
  plot
}

# The four quadrants of a scatter chart, cut at `x_mid` and `y_mid` (the medians): a faint tint on the quadrant that
# is high on both axes and on the one that is low on both, the two dashed lines, and a text in each corner. One look
# for every such chart. The layers go under the points: add them to the plot before the points are drawn.
.cd_quadrants <- function(x_mid, y_mid, top_left, top_right, bottom_left, bottom_right) {
  corner <- function(x, y, label, hjust, vjust) {
    annotate("text", x = x, y = y, label = label, hjust = hjust, vjust = vjust, size = .cd_type$label, fontface = "bold",
             colour = "grey35", lineheight = 0.95)
  }
  list(
    annotate("rect", xmin = x_mid, xmax = Inf, ymin = y_mid, ymax = Inf, fill = "#1a9850", alpha = 0.07),
    annotate("rect", xmin = -Inf, xmax = x_mid, ymin = -Inf, ymax = y_mid, fill = "#d73027", alpha = 0.07),
    geom_vline(xintercept = x_mid, linetype = "dashed", colour = "grey45", linewidth = 0.4),
    geom_hline(yintercept = y_mid, linetype = "dashed", colour = "grey45", linewidth = 0.4),
    corner(-Inf, Inf, top_left, -0.05, 1.3),
    corner(Inf, Inf, top_right, 1.05, 1.3),
    corner(-Inf, -Inf, bottom_left, -0.05, -0.3),
    corner(Inf, -Inf, bottom_right, 1.05, -0.3)
  )
}

# The labels of a discrete axis that holds indicator codes: each code's label (cd_indicator_labels(), or the labels
# given, a named vector or list code -> label), wrapped. A value that is not a code (a region, a year) stays as it is.
.cd_axis_labels <- function(labels = NULL, width = 18) {
  known <- cd_indicator_labels()
  if (length(labels)) known[names(labels)] <- unlist(labels)
  function(values) {
    values <- as.character(values)
    out <- ifelse(values %in% names(known), unname(known[values]), values)
    if (is.finite(width)) stringr::str_wrap(out, width) else out
  }
}

# The colour of a text drawn on each of `fills`: black on a light fill, white on a dark one.
.cd_text_on <- function(fills) {
  rgb <- grDevices::col2rgb(fills)
  ifelse(0.299 * rgb[1, ] + 0.587 * rgb[2, ] + 0.114 * rgb[3, ] > 150, "grey10", "white")
}

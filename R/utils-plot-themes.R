cd_plot_theme <- function(title = NULL, subtitle = NULL, x_axis = NULL, y_axis = NULL, legend = NULL, caption = NULL) {
  list(
    labs(
      title = title,
      subtitle = subtitle,
      x = x_axis,
      y = y_axis,
      caption = caption,
      fill = legend
    ),
    theme(
      panel.background = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
      legend.background = element_rect(color = "black", linewidth = 0.5),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = 13),
      legend.key.size = unit(8, "mm"),
      legend.box.spacing = unit(0.5, "cm"),
      plot.title = element_text(size = 16, hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
      plot.caption = element_text(size = 12, hjust = 0),
      axis.text = element_text(size = 12),
      axis.title = element_text(size = 16),
      strip.background = element_blank(),
      strip.text = element_text(size = 12)
    )
  )
}

cd_report_theme <- function(base_size = 10, base_family = "",
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
  small_size <- base_size * small_rel
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
        size = base_rect_size, linetype = 1
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
      axis.text = element_text(size = small_size),
      axis.text.x = element_text(margin = margin(t = small_rel / 2), vjust = 1),
      axis.text.y = element_text(margin = margin(r = small_rel / 2), hjust = 1),
      axis.ticks = element_line(colour = "black", linewidth = base_line_size),
      axis.title = element_text(size = base_size),
      axis.title.x = element_text(margin = margin(t = half_line)),
      axis.title.y = element_text(angle = 90L, margin = margin(r = half_line)),
      legend.key = element_rect(fill = "white", colour = NA),
      legend.key.size = unit(0.8, "lines"),
      legend.background = element_rect(fill = alpha("white", 0)), # Transparent background
      legend.position = "bottom", # or "bottom"
      legend.text = element_text(size = small_size),
      legend.title = element_text(size = small_size),
      panel.background = element_blank(),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
      panel.grid = element_blank(),

      # plot.background = element_rect(fill = NA, colour = NA),
      plot.title = element_text(
        size = base_size, hjust = 0.5,
        margin = margin(b = half_line)
      ),
      plot.subtitle = element_text(
        size = base_size * 0.95, hjust = 0.5,
        margin = margin(b = half_line)
      ),
      plot.caption = element_text(
        size = small_size, hjust = 0,
        margin = margin(t = half_line)
      ),
      strip.background = element_blank(),
      strip.text = element_text(colour = "black", size = small_size)
    )
}

#' Plot Line Graph for Multiple Series with Dynamic Y-axis Scaling
#'
#' @param .data A data frame.
#' @param x The column name for the x-axis (e.g., "year").
#' @param y_vars Vector of column names for the y-axis data.
#' @param title Plot title.
#' @param y_axis Label for the y-axis.
#' @param x_axis Label for the x-axis.
#' @param legend_labels Vector of labels for the legend (must match y_vars length).
#' @param hline Optional numeric value for a horizontal reference line.
#' @param hline_style Style of the horizontal line.
#'
#' @return A ggplot object.
#' @export
plot_line_graph <- function(.data, x, y_vars, title, y_axis, x_axis, legend_labels, hline = NULL, hline_style = "dashed", options = NULL, ...) {
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
    scale_color_manual(values = set_names(c("darkgreen", "orange", "blue", "purple", "red2", "brown")[1:length(y_vars)], legend_labels)) +
    cd_plot_theme(
      title = title,
      x_axis = x_axis,
      y_axis = y_axis
    )

  # Add horizontal line if specified
  if (!is.null(hline)) {
    p <- p +
      geom_hline(yintercept = hline, linetype = hline_style, color = "grey40")
  }

  cd_finish_plot(p, options, ...)
}


cd_heatmap_theme <- function(title = NULL, x_axis = NULL, y_axis = NULL, legend = NULL) {
  list(
    cd_plot_theme(
      title = title,
      x = x_axis,
      y = y_axis,
      legend = legend
    ),
    theme(
      panel.border = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.ticks = element_blank(),
      axis.ticks.length = unit(0, "pt"),
      legend.title = element_text(size = 13)
    )
  )
}

cd_bar_theme <- function(title = NULL, x_axis = NULL, y_axis = NULL, legend = NULL) {
  list(
    cd_plot_theme(
      title = title,
      x = x_axis,
      y = y_axis,
      legend = legend
    ),
    theme(
      panel.grid.major = element_line(colour = "gray95"),
      axis.ticks = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.title = element_text(face = "bold"),
      legend.title = element_text(face = "bold")
    )
  )
}

cd_categorized_heatmap <- function(data,
                                   x_col,
                                   y_col,
                                   value_col,
                                   threshold = 90,
                                   title = NULL,
                                   x_lab = NULL,
                                   y_lab = NULL,
                                   legend_lab = NULL,
                                   reverse = FALSE,
                                   text_size = 4) {
  check_scalar_integerish(threshold)

  colors <- c("red", "orange", "forestgreen")
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

  ggplot(dt, aes(x = !!sym(x_col), y = !!sym(y_col), fill = color_category)) +
    geom_tile(color = "white", show.legend = TRUE) +
    geom_text(aes(label = .value_round), color = "black", size = text_size, vjust = 0.5) +
    scale_fill_manual(
      values = set_names(colors, lvl),
      limits = lvl,
      breaks = lvl,
      drop = FALSE
    ) +
    scale_x_discrete(expand = expansion(mult = 0)) +
    scale_y_discrete(expand = expansion(mult = 0)) +
    cd_heatmap_theme(
      title = title,
      x_axis = x_lab %||% x_col,
      y_axis = y_lab %||% y_col,
      legend = legend_lab %||% paste0(value_col, " Category")
    )
}

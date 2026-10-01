#' Plot Adjusted vs. Unadjusted Data for Health Indicators
#'
#' `plot.cd_adjustment_values_filtered` creates a bar plot to compare the unadjusted (raw)
#' and adjusted values of health indicators over time. It allows users to specify
#' the indicator prefix and customize legend labels for flexibility across different
#' health data.
#'
#' @param x A data frame containing the `year` column and columns for the raw
#'   and adjusted values of health indicators (e.g., `ideliv_raw`, `ideliv_adj`).
#'   The indicator plotted is taken from its `indicator` attribute.
#' @param title A character string for the plot title. If `NULL`, a default title
#'   based on the indicator is generated.
#' @param x_axis,y_axis Optional x- and y-axis titles. Default is `NULL`.
#' @param legend_labels A named list or vector of custom legend labels, with
#'   names `raw` (unadjusted data) and/or `adjusted`. Supplied entries replace
#'   the defaults ("N of `indicator` before adjustment" and "N of `indicator`
#'   after adjustment"). Default is `NULL`.
#' @param ... Additional arguments (currently not used).
#' @param type With the adjustment's steps in `x` ([generate_adjustment_values()] with `settings`): `"stacked"` (the
#'   default) draws, each year, the reported count beside the adjusted count made of its parts -- the reported count,
#'   what completeness added, what filling missing values added, and the outliers' correction (a correction that lowers
#'   the total drawn faded above the bar: the part taken away); `"change"` what each step changed, labelled with its
#'   share of the reported count; `"totals"` the counts side by side. Legend labels: `raw`, `completeness`,
#'   `outliers`, `missing` (and `adjusted` for `"totals"`).
#' @param zoom `"stacked"`: `TRUE` starts the axis near the smallest bar, so changes of a few percent can be seen (a
#'   note says where it starts); `FALSE` from zero.
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#' @return A ggplot2 object showing the comparison of unadjusted and adjusted data
#'   for the specified indicator over time.
#'
#' @details
#' This function helps visualize the difference between raw and adjusted values
#' of a given health indicator, aiding in the assessment of data completeness and
#' adjustments. The difference and percentage difference are calculated within
#' the function but are not directly shown on the plot. Instead, the plot shows
#' the actual unadjusted and adjusted values side-by-side for each year.
#'
#' @examples
#' \dontrun{
#' # Using default legend labels and title
#' plot.cd_adjustment_values_filtered(adjustments, indicator = "ideliv")
#'
#' # Custom legend labels and title
#' plot.cd_adjustment_values_filtered(adjustments,
#'   indicator = "instlivebirths",
#'   title = "Customized Title",
#'   legend_labels = c("Original", "Modified")
#' )
#' }
#'
#' @export
plot.cd_adjustment_values_filtered <- function(x,
                                               title = NULL,
                                               x_axis = NULL,
                                               y_axis = NULL,
                                               legend_labels = NULL,
                                               ..., type = c("stacked", "change", "totals"), zoom = TRUE, options = NULL) {
  type <- match.arg(type)
  cd_finish_plot(.plot_cd_adjustment_values_filtered_impl(x, title = title, x_axis = x_axis, y_axis = y_axis, legend_labels = legend_labels, type = type, zoom = zoom, ...), options, ..., .source = x)
}

.plot_cd_adjustment_values_filtered_impl <- function(x,
                                               title = NULL,
                                               x_axis = NULL,
                                               y_axis = NULL,
                                               legend_labels = NULL,
                                               ..., type = c("stacked", "change", "totals"), zoom = TRUE) {
  year <- perc_diff <- value <- step <- change <- share <- NULL
  xmin <- xmax <- ymin <- ymax <- part <- removed <- NULL
  type <- match.arg(type)

  indicator <- attr_or_abort(x, "indicator")
  raw_col <- paste0(indicator, "_raw")
  adj_col <- paste0(indicator, "_adj")
  # with the steps (the settings' adjustment): the counts after completeness and after outliers between them
  steps <- all(paste0(indicator, c("_completeness", "_outliers")) %in% names(x))
  cols <- if (steps) paste0(indicator, c("_raw", "_completeness", "_outliers", "_adj")) else c(raw_col, adj_col)
  keys <- if (steps) c("raw", "completeness", "outliers", "adjusted") else c("raw", "adjusted")

  # each year: the reported count, and beside it the adjusted count made of its parts
  if (steps && identical(type, "stacked")) {
    lab <- utils::modifyList(list(raw = "Reported", completeness = "Completeness", outliers = "Outliers", missing = "Missing values"),
                             as.list(legend_labels %||% list())[intersect(names(legend_labels %||% list()), c("raw", "completeness", "outliers", "missing"))])
    v <- function(suffix) x[[paste0(indicator, suffix)]]
    reported <- v("_raw")
    comp <- v("_completeness") - reported
    outl <- v("_outliers") - v("_completeness")
    miss <- v("_adj") - v("_outliers")
    n <- length(reported)
    at <- seq_len(n)
    w <- 0.34
    seg <- function(x0, lo, hi, what, gone = FALSE) data.frame(xmin = x0 - w / 2, xmax = x0 + w / 2, ymin = lo, ymax = hi, part = what, removed = gone)
    base <- reported + pmin(outl, 0)
    rects <- do.call(rbind, lapply(at, function(i) rbind(
      seg(i - 0.19, 0, reported[i], "raw"),
      seg(i + 0.19, 0, base[i], "raw"),
      seg(i + 0.19, base[i], base[i] + comp[i], "completeness"),
      seg(i + 0.19, base[i] + comp[i], base[i] + comp[i] + miss[i], "missing"),
      if (outl[i] > 0) seg(i + 0.19, base[i] + comp[i] + miss[i], base[i] + comp[i] + miss[i] + outl[i], "outliers"),
      # outliers that lowered the total: the part taken away, faded above the bar
      if (outl[i] < 0) seg(i + 0.19, base[i] + comp[i] + miss[i], base[i] + comp[i] + miss[i] - outl[i], "outliers", TRUE)
    )))
    rects <- rects[rects$ymax > rects$ymin, , drop = FALSE]
    # a part that changed nothing here still has its key: an empty bar of no height
    absent <- setdiff(c("raw", "completeness", "outliers", "missing"), unique(rects$part))
    if (length(absent)) rects <- rbind(rects, do.call(rbind, lapply(absent, function(a) seg(1, reported[1], reported[1], a))))
    rects$part <- factor(rects$part, levels = c("raw", "completeness", "outliers", "missing"))
    top <- max(rects$ymax, na.rm = TRUE)
    lower <- 0
    if (isTRUE(zoom)) {
      # 90% of the smallest bar, rounded down to two significant figures
      lower <- 0.9 * min(c(reported, base), na.rm = TRUE)
      mag <- 10^(floor(log10(max(lower, 1))) - 1)
      lower <- floor(lower / mag) * mag
    }
    if (is.null(title)) title <- paste(indicator, ": reported and adjusted, by year")
    p <- ggplot(rects) +
      geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = part, alpha = removed, linetype = removed),
                colour = ifelse(rects$removed, "#b57f0c", NA), linewidth = 0.4) +
      scale_alpha_manual(values = c(`FALSE` = 1, `TRUE` = 0.35), guide = "none") +
      scale_linetype_manual(values = c(`FALSE` = "solid", `TRUE` = "22"), guide = "none") +
      scale_fill_manual(values = .cd_palette$adjustment_parts,
                        labels = unlist(lab[c("raw", "completeness", "outliers", "missing")]), name = NULL, drop = FALSE) +
      scale_x_continuous(breaks = at, labels = as.character(x$year), expand = ggplot2::expansion(add = 0.3)) +
      scale_y_continuous(labels = scales::number_format(), breaks = scales::pretty_breaks(n = 6)) +
      ggplot2::coord_cartesian(ylim = c(lower, top * 1.01)) +
      # every step in the legend, drawn plainly, even one that changed nothing here
      ggplot2::guides(fill = ggplot2::guide_legend(override.aes = list(alpha = 1, colour = NA, linetype = "solid"))) +
      cd_plot_theme(title = title, x_axis = x_axis, y_axis = y_axis)
    if (lower > 0) p <- p + ggplot2::labs(caption = paste0("The axis starts at ", format(lower, big.mark = ",", scientific = FALSE), ", so the changes can be seen."))
    return(p)
  }

  # what each step changed, each year: the step's count minus the one before it (outliers can take some away)
  if (steps && identical(type, "change")) {
    step_labels <- utils::modifyList(list(completeness = "Completeness", outliers = "Outliers", missing = "Missing values"),
                                     as.list(legend_labels %||% list())[intersect(names(legend_labels %||% list()), c("completeness", "outliers", "missing"))])
    v <- function(suffix) x[[paste0(indicator, suffix)]]
    changes <- tibble::tibble(
      year = factor(x$year),
      reported = v("_raw"),
      completeness = v("_completeness") - v("_raw"),
      outliers = v("_outliers") - v("_completeness"),
      missing = v("_adj") - v("_outliers")
    ) %>%
      pivot_longer(c("completeness", "outliers", "missing"), names_to = "step", values_to = "change") %>%
      mutate(
        step = factor(step, levels = c("completeness", "outliers", "missing")),
        share = ifelse(is.finite(reported) & reported != 0, change / reported * 100, NA_real_),
        # nothing changed: no label; a small change with two decimals (+0.05%, not +0.0%)
        label = ifelse(is.na(share) | change == 0, "", ifelse(abs(share) < 1, sprintf("%+.2f%%", share), sprintf("%+.1f%%", share)))
      )
    if (is.null(title)) title <- paste("What each adjustment step changed in the number of", indicator)
    dodge <- ggplot2::position_dodge(width = 0.8)
    return(
      ggplot(changes, aes(x = year, y = change, fill = step)) +
        geom_hline(yintercept = 0, colour = "grey40") +
        geom_col(position = dodge, width = 0.75) +
        geom_text(aes(label = label, vjust = ifelse(change >= 0, -0.4, 1.3)), position = dodge, size = 3) +
        scale_y_continuous(labels = scales::number_format(), expand = ggplot2::expansion(mult = 0.12)) +
        scale_fill_manual(values = .cd_palette$adjustment_steps[c("completeness", "outliers", "missing")],
                          labels = unlist(step_labels[c("completeness", "outliers", "missing")]), name = NULL, drop = FALSE) +
        cd_plot_theme(title = title, x_axis = x_axis, y_axis = y_axis %||% "Change from the reported number")
    )
  }

  default_labels <- list(
    raw = paste("N of", indicator, "before adjustment"),
    completeness = "After completeness",
    outliers = "After outliers",
    adjusted = paste("N of", indicator, "after adjustment")
  )

  final_labels <- default_labels
  if (!is.null(legend_labels)) {
    # Merge: Convert to list (if vector) and merge into defaults
    # modifyList updates the values in 'default_labels' with those in 'legend_labels' by name
    final_labels <- modifyList(default_labels, as.list(legend_labels))
  }

  # Set default title if not provided
  if (is.null(title)) {
    title <- paste("Comparison of number of", indicator, "before and after adjustment for completeness and outliers")
  }

  fill_colors <- .cd_palette$adjustment_steps[keys]


  # Prepare data with absolute and percentage difference columns
  x %>%
    select(year, all_of(cols)) %>%
    pivot_longer(-year, names_to = "type", values_to = "value") %>%
    mutate(
      type = factor(type, levels = cols, labels = keys)
    ) %>%
    ggplot(aes(x = factor(year), y = value, fill = type)) +
    geom_col(position = "dodge", width = 0.6) +
    scale_y_continuous(labels = scales::number_format(), breaks = scales::pretty_breaks(n = 10)) +
    scale_fill_manual(values = fill_colors, label = unlist(final_labels[keys]), name = "Data Type") +
    cd_plot_theme(
      title = title,
      x_axis = x_axis,
      y_axis = y_axis
    )
}

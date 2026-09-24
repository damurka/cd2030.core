# Marks part of the chart options: line width, point size, transparency and the text drawn by geom_text()/geom_label().

.apply_layer_options <- function(p, o) {
  if (is.null(o$line_scale) && is.null(o$point_scale) && is.null(o$alpha) &&
      is.null(o$label_size) && is.null(o$label_angle) && is.null(o$label_color)) {
    return(p)
  }

  scaled <- function(layer, aesthetic, factor, fallback) {
    if (!is.null(layer$mapping[[aesthetic]])) return(layer)
    current <- layer$aes_params[[aesthetic]]
    if (is.null(current)) {
      default <- layer$geom$default_aes[[aesthetic]]
      current <- if (is.numeric(default) && length(default) == 1) default else fallback
    }
    layer$aes_params[[aesthetic]] <- current * factor
    layer
  }

  # the lines that draw data; reference lines (hline, vline, abline) are left as the plot drew them
  line_geoms <- c("GeomPath", "GeomSmooth", "GeomSegment", "GeomErrorbar", "GeomLinerange", "GeomCrossbar", "GeomStep")
  for (i in seq_along(p$layers)) {
    layer <- p$layers[[i]]
    geom <- layer$geom
    is_text <- inherits(geom, c("GeomText", "GeomLabel"))
    if (!is.null(o$line_scale) && inherits(geom, line_geoms)) layer <- scaled(layer, "linewidth", o$line_scale, 0.5)
    if (!is.null(o$point_scale) && inherits(geom, c("GeomPoint", "GeomPointrange"))) layer <- scaled(layer, "size", o$point_scale, 1.5)
    if (!is.null(o$alpha) && !is_text) layer$aes_params$alpha <- o$alpha
    if (is_text) {
      if (!is.null(o$label_size)) layer$aes_params$size <- o$label_size / ggplot2::.pt
      if (!is.null(o$label_angle)) layer$aes_params$angle <- o$label_angle
      if (!is.null(o$label_color)) layer$aes_params$colour <- o$label_color
    }
    p$layers[[i]] <- layer
  }
  p
}

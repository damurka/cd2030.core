library(ggplot2)

simple_plot <- function() {
  df <- data.frame(year = rep(2020:2022, 2), value = c(1, 2, 3, 2, 3, 4), source = rep(c("dhis2", "survey"), each = 3))
  ggplot(df, aes(year, value, colour = source)) +
    geom_line() +
    scale_colour_manual(values = c(dhis2 = "forestgreen", survey = "royalblue"), name = NULL) +
    labs(title = "Own title", x = "Year", y = "Value") +
    theme(plot.title = element_text(size = 16), axis.text = element_text(size = 12))
}

test_that("cd_chart_options keeps only what is set and understands the older names", {
  expect_length(cd_chart_options(), 0)
  o <- cd_chart_options(title = "T", x_axis = "Year", y_label = "Coverage", legend = "Source", legend_position = "bottom")
  expect_s3_class(o, "cd_chart_options")
  expect_identical(o$x_title, "Year")
  expect_identical(o$y_title, "Coverage")
  expect_identical(o$legend_title, "Source")
  expect_named(o, c("title", "x_title", "y_title", "legend_title", "legend_position"), ignore.order = TRUE)
  # an explicit field wins over its alias
  expect_identical(cd_chart_options(x_title = "A", x_axis = "B")$x_title, "A")
  expect_identical(cd_chart_options(title_align = "centre")$title_align, "center")
})

test_that("cd_chart_options validates its fields", {
  expect_error(cd_chart_options(title = 1), class = "cd2030_error")
  expect_error(cd_chart_options(legend_position = "middle"), class = "cd2030_error")
  expect_error(cd_chart_options(text_scale = -1), class = "cd2030_error")
  expect_error(cd_chart_options(title_size = "big"), class = "cd2030_error")
  expect_error(cd_chart_options(flip = "yes"), class = "cd2030_error")
  expect_error(cd_chart_options(legend_labels = c("a", "b")), class = "cd2030_error")
  expect_error(cd_chart_options(nonsense = 1), class = "cd2030_error")
})

test_that("merge_chart_options layers later over earlier and merges the named vectors by name", {
  m <- merge_chart_options(
    cd_chart_options(font_family = "serif", title = "A", legend_labels = c(dhis2 = "Routine", survey = "Survey")),
    NULL,
    list(title = "B", legend_labels = c(survey = "Household survey"))
  )
  expect_identical(m$title, "B")
  expect_identical(m$font_family, "serif")
  expect_identical(m$legend_labels[["dhis2"]], "Routine")
  expect_identical(m$legend_labels[["survey"]], "Household survey")
})

test_that("resolve_chart_options takes options plus fields named in ..., and ignores unrelated arguments", {
  r <- resolve_chart_options(cd_chart_options(title = "From options"), subtitle = "S", x_axis = "X", region = "Zou", unrelated = 1)
  expect_identical(r$title, "From options")
  expect_identical(r$subtitle, "S")
  expect_identical(r$x_title, "X")
  expect_false("region" %in% names(r))
  # a field named in ... wins over the object
  expect_identical(resolve_chart_options(cd_chart_options(title = "A"), title = "B")$title, "B")
})

test_that("apply_chart_options changes texts, legend, position, sizes, font and orientation, and only those", {
  p <- simple_plot()
  expect_identical(apply_chart_options(p, NULL), p)
  expect_identical(apply_chart_options("not a plot", cd_chart_options(title = "x")), "not a plot")

  q <- apply_chart_options(p, cd_chart_options(
    title = "New title", subtitle = "Sub", caption = "Cap", x_title = "When", y_title = "How much",
    legend_title = "Where from", legend_position = "bottom", font_family = "serif",
    title_size = 20, axis_text_size = 9, title_face = "bold", title_align = "left"
  ))
  labs <- ggplot2::get_labs(q)
  expect_identical(labs$title, "New title")
  expect_identical(labs$subtitle, "Sub")
  expect_identical(labs$caption, "Cap")
  expect_identical(labs$x, "When")
  expect_identical(labs$y, "How much")
  expect_identical(q$scales$get_scales("colour")$name, "Where from")

  th <- ggplot2::theme_get() + q$theme
  expect_identical(th$legend.position, "bottom")
  expect_identical(ggplot2::calc_element("plot.title", th)$size, 20)
  expect_identical(ggplot2::calc_element("plot.title", th)$face, "bold")
  expect_identical(ggplot2::calc_element("plot.title", th)$hjust, 0)
  expect_identical(ggplot2::calc_element("axis.text", th)$size, 9)
  expect_identical(th$text$family, "serif")

  # untouched things stay as the plot drew them
  expect_identical(ggplot2::get_labs(apply_chart_options(p, cd_chart_options(title = "Only")))$x, "Year")
})

test_that("text_scale multiplies the sizes a plot already has, and explicit sizes override it", {
  q <- apply_chart_options(simple_plot(), cd_chart_options(text_scale = 1.5, axis_text_size = 10))
  th <- ggplot2::theme_get() + q$theme
  expect_equal(ggplot2::calc_element("plot.title", th)$size, 24)
  expect_equal(ggplot2::calc_element("axis.text", th)$size, 10)
})

test_that("legend_labels relabel a legend by key or by shown text; category_labels relabel a discrete axis", {
  q <- apply_chart_options(simple_plot(), cd_chart_options(legend_labels = c(dhis2 = "Routine data")))
  built <- ggplot2::ggplot_build(q)
  shown <- built$plot$scales$get_scales("colour")$get_labels(c("dhis2", "survey"))
  expect_identical(shown, c("Routine data", "survey"))

  bars <- ggplot(data.frame(k = c("a", "b"), v = 1:2), aes(k, v)) + geom_col()
  b <- apply_chart_options(bars, cd_chart_options(category_labels = c(a = "Alpha")))
  scale_x <- ggplot2::ggplot_build(b)$layout$panel_scales_x[[1]]
  expect_identical(scale_x$get_labels(c("a", "b")), c("Alpha", "b"))
})

test_that("flip swaps the axes and FALSE keeps a plot that is already flipped as drawn", {
  bars <- ggplot(data.frame(k = c("a", "b"), v = 1:2), aes(k, v)) + geom_col()
  expect_s3_class(apply_chart_options(bars, cd_chart_options(flip = TRUE))$coordinates, "CoordFlip")
  flipped <- bars + coord_flip()
  expect_false(inherits(apply_chart_options(flipped, cd_chart_options(flip = FALSE))$coordinates, "CoordFlip"))
})

test_that("the coverage plot methods take options, and named chart options in ...", {
  x <- structure(
    tibble::tibble(estimates = c("DHIS2 estimate", "Survey estimates", "95% CI LL", "95% CI UL"),
                   `2020` = c(50, 55, 50, 60), `2021` = c(60, NA, NA, NA)),
    class = c("cd_coverage_filtered", "tbl_df", "tbl", "data.frame"),
    admin_level = "national", denominator = "penta1", indicator = "penta3"
  )
  p <- plot(x, options = cd_chart_options(title = "Custom title", legend_position = "bottom"))
  expect_identical(ggplot2::get_labs(p)$title, "Custom title")
  expect_identical((ggplot2::theme_get() + p$theme)$legend.position, "bottom")

  # the older argument still works, and a chart option in ... beats it
  expect_identical(ggplot2::get_labs(plot(x, title = "Old style"))$title, "Old style")
  expect_identical(ggplot2::get_labs(plot(x, title = "Old style", subtitle = "Added"))$subtitle, "Added")
})

test_that("CacheConnection stores chart options per chart and as dataset defaults, and saves them", {
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  cache <- CacheConnection$new(wizard_parts = list(parts = list()))
  cache$set_cache_path(path)

  expect_length(cache$get_chart_options("national_coverage/anc4"), 0)

  cache$set_chart_options("default", cd_chart_options(font_family = "serif", text_scale = 1.1))
  cache$set_chart_options("national_coverage/anc4", cd_chart_options(title = "ANC4 in Benin", text_scale = 1.3))

  one <- cache$get_chart_options("national_coverage/anc4")
  expect_s3_class(one, "cd_chart_options")
  expect_identical(one$title, "ANC4 in Benin")
  expect_identical(one$font_family, "serif")   # from the dataset defaults
  expect_identical(one$text_scale, 1.3)        # the chart's own wins
  expect_identical(cache$get_chart_options("national_coverage/other")$text_scale, 1.1)
  expect_named(cache$chart_options, c("default", "national_coverage/anc4"), ignore.order = TRUE)

  # written to the saved dataset
  saved <- readRDS(path)
  expect_identical(saved$chart_options[["national_coverage/anc4"]]$title, "ANC4 in Benin")

  cache$reset_chart_options("national_coverage/anc4")
  expect_named(cache$chart_options, "default")
  cache$reset_chart_options()
  expect_length(cache$chart_options, 0)

  expect_error(cache$set_chart_options("", cd_chart_options(title = "x")), class = "cd2030_error")
  expect_error(cache$set_chart_options("x", list(title = 1)), class = "cd2030_error")
})

marks_plot <- function() {
  df <- data.frame(year = rep(2020:2022, 2), value = c(1, 2, 3, 2, 3, 4) / 10, source = rep(c("dhis2", "survey"), each = 3))
  ggplot(df, aes(year, value, colour = source)) + geom_line(linewidth = 1) + geom_point(size = 3) + geom_text(aes(label = value)) +
    scale_colour_manual(values = c(dhis2 = "forestgreen", survey = "royalblue"), name = NULL) + labs(x = "Year", y = "Value")
}

test_that("options are matched exactly, so title does not pick up title_size", {
  o <- cd_chart_options(title_size = 20)
  expect_null(o$title)
  expect_identical(get_labs <- ggplot2::get_labs(apply_chart_options(marks_plot(), cd_chart_options(x_title_size = 20)))$x, "Year")
})

test_that("new fields are validated", {
  expect_error(cd_chart_options(grid_color = "notacolour"), class = "cd2030_error")
  expect_error(cd_chart_options(x_labels = "x"), class = "cd2030_error")
  expect_error(cd_chart_options(alpha = 2), class = "cd2030_error")
  expect_error(cd_chart_options(plot_margin = c(1, 2)), class = "cd2030_error")
  expect_error(cd_chart_options(legend_ncol = 1.5), class = "cd2030_error")
  expect_error(cd_chart_options(colors = c("red")), class = "cd2030_error")
  expect_identical(cd_chart_options(colours = c(a = "red"))$colors, c(a = "red"))
})

test_that("applying options leaves the original plot alone", {
  p <- marks_plot()
  apply_chart_options(p, cd_chart_options(colors = c(dhis2 = "black"), legend_title = "S", line_scale = 3, font_family = "serif"))
  expect_identical(unique(ggplot2::ggplot_build(p)$data[[1]]$colour), c("forestgreen", "royalblue"))
  expect_null(p$scales$scales[[1]]$name)
  expect_identical(unique(ggplot2::ggplot_build(p)$data[[1]]$linewidth), 1)
})

test_that("angle, axes, grid, panel and background options reach the theme", {
  q <- apply_chart_options(marks_plot(), cd_chart_options(
    x_text_angle = 90, y_text_size = 9, x_title_size = 18, grid = "horizontal", grid_minor = FALSE, grid_color = "red",
    axis_line = TRUE, axis_ticks = FALSE, panel_border = TRUE, background_color = "grey90", plot_margin = 12,
    title_position = "plot", legend_direction = "vertical", legend_key_size = 5, text_color = "navy", axis_text_color = "red"
  ))
  th <- ggplot2::theme_get() + q$theme
  expect_identical(ggplot2::calc_element("axis.text.x", th)$angle, 90)
  expect_identical(ggplot2::calc_element("axis.text.y", th)$size, 9)
  expect_identical(ggplot2::calc_element("axis.title.x", th)$size, 18)
  expect_s3_class(th$panel.grid.major.x, "ggplot2::element_blank")
  expect_identical(th$panel.grid.major.y@colour, "red")
  expect_s3_class(th$panel.grid.minor.y, "ggplot2::element_blank")
  expect_s3_class(th$axis.ticks, "ggplot2::element_blank")
  expect_identical(th$plot.background@fill, "grey90")
  expect_identical(th$plot.title.position, "plot")
  expect_identical(ggplot2::calc_element("axis.text.x", th)$colour, "red")
  expect_identical(ggplot2::calc_element("plot.title", th)$colour, "navy")
})

test_that("in a flipped chart x_ options follow the data, not the screen", {
  q <- apply_chart_options(marks_plot(), cd_chart_options(flip = TRUE, x_text_size = 7, y_text_size = 11, x_title_size = 20))
  th <- ggplot2::theme_get() + q$theme
  expect_identical(ggplot2::calc_element("axis.text.y", th)$size, 7)     # x is up the side now
  expect_identical(ggplot2::calc_element("axis.text.x", th)$size, 11)
  expect_identical(ggplot2::calc_element("axis.title.y", th)$size, 20)
})

test_that("colours, formats, limits, legend layout and marks change what is drawn", {
  q <- apply_chart_options(marks_plot(), cd_chart_options(
    colors = c(dhis2 = "black"), y_labels = "percent", x_limits = c(2020, 2021), legend_reverse = TRUE, legend_ncol = 2,
    line_scale = 2, point_scale = 2, alpha = 0.5, label_size = 8, label_color = "blue", label_angle = 30
  ))
  b <- ggplot2::ggplot_build(q)
  expect_identical(unique(b$data[[1]]$colour), c("black", "royalblue"))
  expect_identical(unique(b$data[[1]]$linewidth), 2)
  expect_identical(unique(b$data[[2]]$size), 6)
  expect_equal(unique(b$data[[3]]$size), 8 / ggplot2::.pt)
  expect_identical(unique(b$data[[3]]$colour), "blue")
  expect_identical(b$layout$panel_scales_y[[1]]$get_labels(c(0.1, 0.2)), c("10%", "20%"))
  expect_equal(b$layout$coord$limits$x, c(2020, 2021))

  # colours also work for a plot with no scale of its own
  plain <- ggplot(data.frame(k = c("a", "b"), v = 1:2), aes(k, v, fill = k)) + geom_col()
  cols <- ggplot2::ggplot_build(apply_chart_options(plain, cd_chart_options(colors = c(a = "red"))))$data[[1]]$fill
  expect_identical(cols[[1]], "red")
})

test_that("wrapping and presets", {
  q <- apply_chart_options(marks_plot(), cd_chart_options(title = "a b c d e f", title_wrap = 6, theme_preset = "classic"))
  expect_identical(ggplot2::get_labs(q)$title, "a b c\nd e f")
  bars <- ggplot(data.frame(k = "one two three", v = 1), aes(k, v)) + geom_col()
  b <- ggplot2::ggplot_build(apply_chart_options(bars, cd_chart_options(category_label_wrap = 4)))
  expect_identical(b$layout$panel_scales_x[[1]]$get_labels("one two three"), "one\ntwo\nthree")
})

test_that("a report renders charts with the options saved for reports, then for their type of graph", {
  p <- marks_plot()
  type <- cd_chart_type(p)
  expect_match(type, "^geom:")
  expect_null(cd_chart_type("not a plot"))

  withr::local_options(cd2030.report_chart_options = list(
    default = cd_chart_options(title = "Report default", font_family = "serif"),
    types = stats::setNames(list(cd_chart_options(title = "For this type", alpha = 0.5)), type)
  ))
  q <- cd_finish_plot(p)
  expect_identical(ggplot2::get_labs(q)$title, "For this type")                    # the type beats the dataset-wide
  expect_identical((ggplot2::theme_get() + q$theme)$text@family, "serif")           # dataset-wide still there
  expect_identical(ggplot2::get_labs(cd_finish_plot(p, title = "Template"))$title, "Template")   # the template beats both

  # a different type of graph only gets the dataset-wide options
  bars <- ggplot(data.frame(k = "a", v = 1), aes(k, v)) + geom_col()
  expect_identical(ggplot2::get_labs(cd_finish_plot(bars))$title, "Report default")
})

test_that("a chart has an id made from the data it draws, and report options can be saved for that one chart", {
  x <- structure(tibble::tibble(a = 1), class = c("cd_coverage_filtered", "tbl_df", "tbl", "data.frame"),
                 admin_level = "national", indicator = "anc4", denominator = "penta1")
  expect_identical(cd_chart_id(x), "coverage_filtered.national.anc4")
  expect_null(cd_chart_id(tibble::tibble(a = 1)))
  expect_identical(cd_chart_id(structure(list(), class = "cd_thing")), "thing")

  p <- marks_plot()
  withr::local_options(cd2030.report_chart_options = list(
    default = cd_chart_options(title = "Default"),
    types = list("coverage_filtered.national.anc4" = cd_chart_options(title = "This chart"))
  ))
  expect_identical(ggplot2::get_labs(cd_finish_plot(p, .source = x))$title, "This chart")
  expect_identical(ggplot2::get_labs(cd_finish_plot(p))$title, "Default")   # no id: only the general options
})

test_that("cd_chart_catalog lists the charts with saved options", {
  cache <- CacheConnection$new(wizard_parts = list(parts = list()))
  cache$set_cache_path(tempfile(fileext = ".rds"))
  expect_equal(nrow(cd_chart_catalog(cache)), 0)

  cache$set_chart_options("report/coverage_filtered.national.anc4", cd_chart_options(title = "T", alpha = 0.5))
  cache$set_chart_options("national_coverage-body-panel-anc4-plot", cd_chart_options(x_text_angle = 45))
  cache$set_chart_options("default", cd_chart_options(font_family = "serif"))
  catalog <- cd_chart_catalog(cache)
  expect_setequal(catalog$target, c("report", "screen", "dataset"))
  row <- catalog[catalog$target == "report", ]
  expect_identical(row$id, "coverage_filtered.national.anc4")
  expect_identical(row$group, "coverage_filtered.national")
  expect_identical(row$n_options, 2L)
})

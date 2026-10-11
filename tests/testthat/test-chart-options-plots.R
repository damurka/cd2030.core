# Every plot method takes `options` (see cd_chart_options()) and is a thin wrapper over an implementation with the
# same arguments and defaults, so a plot with no options set is exactly the plot it always was.

plot_wrappers <- function() {
  ns <- asNamespace("cd2030.core")
  registered <- getNamespaceInfo("cd2030.core", "S3methods")
  plot_methods <- registered[registered[, 1] == "plot" & startsWith(registered[, 2], "cd_"), 2]
  wrappers <- lapply(plot_methods, function(cls) getS3method("plot", cls, envir = ns))
  names(wrappers) <- paste0("plot.", plot_methods)
  wrappers$equiplot_area <- equiplot_area
  wrappers$equiplot_wealth <- equiplot_wealth
  wrappers$equiplot_education <- equiplot_education
  wrappers$plot_comparison.cd_data <- getS3method("plot_comparison", "cd_data", envir = ns)
  wrappers
}

test_that("every plot method and equiplot takes `options`", {
  for (name in names(plot_wrappers())) {
    expect_true("options" %in% names(formals(plot_wrappers()[[name]])), info = name)
  }
  expect_gte(length(plot_wrappers()), 38)
})

# The charts change their text and look the same way (?cd_plot_arguments): the six text arguments, named as the chart
# options are, then `...` (chart options by name), then `options`. Three "plots" are tables (flextables) and have no axes.
plot_tables <- c("plot.cd_overall_score", "plot.cd_utilization_dqa", "plot.cd_health_system_table")
shared_text <- c("title", "subtitle", "caption", "x_title", "y_title", "legend_title")
gone_text <- c("x_axis", "y_axis", "x_label", "y_label", "legend", "fill_label")

test_that("every chart takes the same text arguments, in the same place", {
  charts <- plot_wrappers()[setdiff(names(plot_wrappers()), plot_tables)]
  for (name in names(charts)) {
    args <- names(formals(charts[[name]]))
    expect_true(all(shared_text %in% args), info = paste(name, "lacks", paste(setdiff(shared_text, args), collapse = ", ")))
    expect_identical(args[match("title", args) + 0:6], c(shared_text, "..."), info = paste(name, "order"))
    expect_identical(args[[length(args)]], "options", info = name)
    expect_false(any(gone_text %in% args), info = paste(name, "still has a name that is gone"))
    for (arg in shared_text) expect_null(formals(charts[[name]])[[arg]], info = paste(name, arg))
  }
})

test_that("a chart keeps the arguments that say what to draw, with their defaults", {
  ns <- asNamespace("cd2030.core")
  for (name in setdiff(names(plot_wrappers()), plot_tables)) {
    impl_name <- paste0(".", gsub(".", "_", name, fixed = TRUE), "_impl")
    expect_true(exists(impl_name, envir = ns), info = impl_name)
    wrapper <- formals(plot_wrappers()[[name]])
    impl <- formals(get(impl_name, envir = ns))
    expect_false(any(gone_text %in% names(impl)), info = paste(impl_name, "still has a name that is gone"))
    own <- setdiff(names(impl), c(shared_text, "..."))
    expect_true(all(own %in% names(wrapper)), info = paste(name, "drops", paste(setdiff(own, names(wrapper)), collapse = ", ")))
    for (arg in own) expect_identical(wrapper[[arg]], impl[[arg]], info = paste(name, arg, "default differs"))
  }
})

chart_labels <- function(p) ggplot2::get_labs(p)

test_that("the shared arguments change any chart, whether or not it has an argument of its own for the text", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  data <- suppressMessages(load_data(path))
  rates <- calculate_average_reporting_rate(data, "adminlevel_1")      # its own: title, x_title, y_title, legend_title
  districts <- calculate_district_reporting_rate(data, 90)              # no legend, no subtitle of its own

  for (x in list(rates, districts)) {
    p <- plot(x, title = "T", subtitle = "S", caption = "C", x_title = "X", y_title = "Y")
    labels <- chart_labels(p)
    expect_identical(c(labels$title, labels$subtitle, labels$caption, labels$x, labels$y), c("T", "S", "C", "X", "Y"))
  }
  expect_identical(chart_labels(plot(rates, legend_title = "L"))$fill, "L")

  # the look: by name, or made once and given as `options`. A text in `options` (what a user changed in the app) wins
  # over the text argument on every chart; a chart option by name wins over `options`
  look <- cd_chart_options(background_color = "#EEEEEE", font_family = "serif", title = "From the options")
  for (x in list(rates, districts)) {
    p <- plot(x, options = look)
    expect_identical(p$theme$plot.background$fill, "#EEEEEE")
    expect_identical(p$theme$text$family, "serif")
    expect_identical(chart_labels(p)$title, "From the options")
    expect_identical(chart_labels(plot(x, title = "Named", subtitle = "Sub", options = look))$title, "From the options")
    expect_identical(chart_labels(plot(x, title = "Named", subtitle = "Sub", options = look))$subtitle, "Sub")
    expect_identical(plot(x, background_color = "#DDDDDD", options = look)$theme$plot.background$fill, "#DDDDDD")
    expect_identical(plot(x, background_color = "#DDDDDD")$theme$plot.background$fill, "#DDDDDD")
  }
})

test_that("the names the charts had before are refused, with the name to use", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  data <- suppressMessages(load_data(path))
  rates <- calculate_average_reporting_rate(data, "adminlevel_1")
  expect_error(plot(rates, x_axis = "X"), "x_title")
  expect_error(plot(rates, y_label = "Y"), "y_title")
  expect_error(plot(rates, fill_label = "L"), "legend_title")
  expect_error(plot_comparison_anc1_penta1(data, x_label = "First visit"), "x_title")
  expect_error(cd_chart_options(x_axis = "Year"), "Unknown chart option")
  # no function of the package, exported or not, has an argument under one of those names
  ns <- asNamespace("cd2030.core")
  for (name in ls(ns, all.names = TRUE)) {
    f <- get(name, envir = ns)
    if (is.function(f)) expect_false(any(gone_text %in% names(formals(f))), info = name)
  }
})

test_that("the comparison charts write their own texts unless given others; their legend entries are legend_labels", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  data <- suppressMessages(load_data(path))
  p <- plot_comparison_anc1_penta1(data)
  expect_identical(c(chart_labels(p)$title, chart_labels(p)$x, chart_labels(p)$y), c("Comparison of numbers of ANC1 and Penta1 by year", "ANC1", "Penta1"))
  expect_identical(chart_labels(plot_comparison_anc1_penta1(data, x_title = "First visit"))$x, "First visit")
  p <- plot_comparison(data, "anc1", "penta1", x_title = "A", legend_labels = list(district = "Each district"))
  expect_identical(chart_labels(p)$x, "A")
  entries <- unlist(lapply(ggplot2::ggplot_build(p)$plot$scales$scales, function(scale) scale$labels))
  expect_true("Each district" %in% entries)
})

test_that("a legend title is not written on an aesthetic the chart does not use", {
  path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
  data <- suppressMessages(load_data(path))
  p <- plot_comparison(data, "anc1", "penta1", legend_title = "L")
  expect_no_message(ggplot2::ggplot_build(p), message = "unknown labels")
})

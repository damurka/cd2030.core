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

test_that("each wrapper keeps its implementation's arguments and defaults", {
  ns <- asNamespace("cd2030.core")
  for (name in names(plot_wrappers())) {
    impl_name <- paste0(".", gsub(".", "_", name, fixed = TRUE), "_impl")
    if (!exists(impl_name, envir = ns)) next   # the four plots that apply the options inline
    wrapper <- formals(plot_wrappers()[[name]])
    impl <- formals(get(impl_name, envir = ns))
    expect_true(all(names(impl) %in% names(wrapper)), info = paste(name, "drops an argument"))
    expect_true(all(setdiff(names(wrapper), names(impl)) %in% c("options", "...")), info = paste(name, "adds an unexpected argument"))
    for (arg in intersect(names(wrapper), names(impl))) {
      expect_identical(wrapper[[arg]], impl[[arg]], info = paste(name, arg, "default differs"))
    }
  }
})

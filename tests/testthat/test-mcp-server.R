test_that("mcp_tool_list builds one ellmer tool per exposed CacheConnection read method, uniquely named", {
  skip_if_not_installed("mcptools")
  skip_if_not_installed("ellmer")

  tools <- mcp_tool_list(max_sessions = 3L)
  names <- vapply(tools, function(t) t@name, character(1))

  expect_identical(anyDuplicated(names), 0L)
  expect_identical(length(names), 41L)
  expect_true(all(c(
    "load_cache", "get_data_overview", "generate_report", "get_coverage_plot",
    "get_equiplot_area", "get_equiplot_wealth", "get_equiplot_education"
  ) %in% names))
})

test_that("mcp_tool_list never exposes a CacheConnection setter or other mutating/non-data method", {
  skip_if_not_installed("mcptools")
  skip_if_not_installed("ellmer")

  # Every worker dispatches through mcp_call_cache_method() with a hardcoded
  # method name -- this checks that none of those hardcoded names are a
  # setter or one of the other methods deliberately excluded (see
  # mcp_call_cache_method()'s @describeIn).
  ns <- asNamespace("cd2030.core")
  all_names <- ls(ns, all.names = TRUE)
  worker_names <- all_names[grepl("^mcp_get_|^mcp_load_cache$|^mcp_generate_report$|^mcp_render_coverage_plot$|^mcp_render_equiplot_", all_names)]
  worker_body_text <- vapply(
    mget(worker_names, envir = ns),
    function(f) paste(deparse(body(f)), collapse = "\n"),
    character(1)
  )
  all_methods <- setdiff(names(CacheConnection$public_methods), "clone")
  setters <- grep("^set_", all_methods, value = TRUE)
  exempt <- c("initialize", "adjust_data", "save_to_disk", "load_from_disk", "reactive", "get_bayes_model")

  for (forbidden in c(setters, exempt)) {
    hit <- grepl(paste0('"', forbidden, '"'), worker_body_text, fixed = TRUE)
    expect_false(any(hit), info = paste("forbidden method referenced:", forbidden))
  }
})

test_that("cd2030_mcp_server errors clearly when mcptools/ellmer aren't installed", {
  skip_if(requireNamespace("mcptools", quietly = TRUE) && requireNamespace("ellmer", quietly = TRUE),
    "mcptools and ellmer are installed; can't exercise the missing-dependency path"
  )
  expect_error(cd2030_mcp_server(), class = "rlib_error_package_not_found")
})

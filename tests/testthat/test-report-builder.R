test_that("every standard report uses known block kinds and complete blocks", {
  kinds <- report_block_kinds()
  for (name in names(report_presets())) {
    preset <- report_presets()[[name]]
    expect_true(is.character(preset$name) && nzchar(preset$name), info = name)
    blocks <- report_project_blocks(preset)
    expect_true(length(blocks) > 0, info = name)
    ids <- vapply(blocks, function(b) b$id, character(1))
    expect_false(anyDuplicated(ids) > 0, info = name)
    for (b in blocks) {
      expect_true(b$type %in% c("heading", "paragraph", "note", "pagebreak", "chart", "table", "image"), info = name)
      if (b$type %in% c("chart", "table")) {
        expect_true(b$kind %in% names(kinds), info = paste(name, b$kind))
        expect_identical(kinds[[b$kind]]$type, b$type, info = paste(name, b$kind))
      }
    }
  }
})

test_that("CacheConnection keeps report projects", {
  cache <- CacheConnection$new(wizard_parts = list(parts = list()))
  cache$set_cache_path(tempfile(fileext = ".rds"))
  cache$set_report_project("r1", list(name = "A", blocks = list(list(id = "b1", type = "heading", text = "Hi"))))
  expect_identical(cache$report_projects$r1$name, "A")
  cache$set_report_project("r1", NULL)
  expect_length(cache$report_projects, 0)
})

test_that("the one-pager's blocks use the report's region, and page sizes are known", {
  p <- report_presets()$one_pager
  blocks <- report_project_blocks(p)
  uses <- vapply(blocks, function(b) identical(b$region, "@report"), logical(1))
  expect_true(any(uses))
  b <- report_resolve_block(blocks[[which(uses)[1]]], list(region = "Zou"), c("Alibori", "Zou"))
  expect_identical(b$region, "Zou")
  # a report without a region is national: the block is drawn for the country (not the first region)
  b <- report_resolve_block(blocks[[which(uses)[1]]], list(), c("Alibori", "Zou"))
  expect_null(b$region)
  b <- report_resolve_block(blocks[[which(uses)[1]]], list(region = ""), c("Alibori", "Zou"))
  expect_null(b$region)
  poster <- utils::modifyList(report_default_design(), list(size = "poster", orientation = "landscape", margins = "narrow"))
  expect_equal(unname(unlist(report_page(poster)[c("width", "height")])), c(22, 17))
  expect_equal(report_block_size(list(type = "chart", size = "third"), poster), c(6.777, 3.7))
})

test_that("the standard reports exist in the three languages for each group, with kinds of that group", {
  for (group in c("rmncah", "vaccine")) {
    kinds <- report_block_kinds(group)
    ids <- NULL
    for (lang in c("en", "fr", "pt")) {
      presets <- report_presets(lang, group)
      expect_identical(names(presets), .rb_standard_ids(group), info = paste(group, lang))
      if (is.null(ids)) ids <- lapply(presets, function(p) length(report_project_blocks(p)))
      for (id in names(presets)) {
        p <- presets[[id]]
        expect_true(is.character(p$name) && nzchar(p$name), info = paste(group, lang, id))
        expect_true(p$kind %in% c("document", "deck"), info = paste(group, lang, id))
        expect_identical(length(report_project_blocks(p)), ids[[id]], info = paste(group, lang, id))
        for (b in report_project_blocks(p)) {
          expect_false(inherits(b$text, "rb_tx"), info = paste(group, lang, id))
          if (b$type %in% c("chart", "table")) expect_true(b$kind %in% names(kinds), info = paste(group, lang, id, b$kind))
        }
      }
    }
  }
  # French text is French
  expect_false(identical(report_presets("fr", "rmncah")$mortality$name, report_presets("en", "rmncah")$mortality$name))
})

test_that("the national coverage titles name the chart under them with {chart_indicator}", {
  blocks <- report_presets("en", "rmncah")$national_coverage$blocks
  templated <- which(vapply(blocks, function(b) {
    b$type %in% c("heading", "paragraph") && grepl("{chart_indicator}", b$text, fixed = TRUE)
  }, logical(1)))
  expect_gt(length(templated), 0)
  expect_true(any(vapply(templated, function(i) i < length(blocks) && identical(blocks[[i + 1]]$type, "chart"), logical(1))))
})

test_that("the Countdown report theme takes the app's colour", {
  maroon <- .cd_report_theme_for(NULL)
  expect_identical(maroon, .cd_report_theme_countdown)
  expect_identical(.cd_report_theme_for("rmncah"), .cd_report_theme_countdown)

  blue <- .cd_report_theme_for("vaccine")
  expect_equal(blue$accent, "#2f6db5")
  expect_equal(blue$heading_color, "#1f4f86")
  # only the colour: its fonts, palette and footer are the Countdown theme's
  same <- setdiff(names(maroon), c("accent", "heading_color"))
  expect_identical(blue[same], maroon[same])

  expect_equal(.cd_report_theme_for("pooled")$accent, "#1f8a5f")

  # what an app registers is what a new report starts from
  withr::defer(datasuite.ui::report_register(themes = list(countdown = .cd_report_theme_countdown)))
  datasuite.ui::report_register(themes = list(countdown = blue))
  expect_equal(datasuite.ui::report_default_design()$accent, "#2f6db5")
  datasuite.ui::report_register(themes = list(countdown = .cd_report_theme_countdown))
  expect_equal(datasuite.ui::report_default_design()$accent, "#7d3f40")
})

test_that("a report's charts have no tick marks, unless the chart asks for them", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point() + cd_report_theme()
  expect_s3_class(ggplot2::calc_element("axis.ticks", ggplot2::ggplot_build(p)$plot$theme), "element_blank")
  expect_s3_class(ggplot2::calc_element("axis.ticks.x", ggplot2::ggplot_build(p)$plot$theme), "element_blank")
  # the axis lines stay
  expect_s3_class(ggplot2::calc_element("axis.line.x", ggplot2::ggplot_build(p)$plot$theme), "element_line")

  asked <- datasuite.ui::apply_chart_options(p, datasuite.ui::cd_chart_options(axis_ticks = TRUE))
  expect_s3_class(ggplot2::calc_element("axis.ticks", ggplot2::ggplot_build(asked)$plot$theme), "element_line")
})

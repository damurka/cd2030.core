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

test_that("pictures are kept once in the dataset and embedded in the Word file", {
  skip_if_not_installed("magick")
  cache <- CacheConnection$new(wizard_parts = list(parts = list()))
  png <- tempfile(fileext = ".png")
  magick::image_write(magick::image_blank(400, 200, "#2f6db5"), png)
  src <- paste0("data:image/png;base64,", jsonlite::base64_enc(readBin(png, "raw", file.info(png)$size)))
  stored <- report_store_asset(cache, "a1", src)
  expect_equal(stored$ratio, 0.5)
  expect_true(startsWith(report_asset_data_url(cache, "asset:a1"), "data:image/png;base64,"))
  expect_null(report_asset_data_url(cache, "missing"))
  expect_error(report_store_asset(cache, "a2", "data:text/plain;base64,aGVsbG8="))
  # a picture wider than 4000 pixels is made smaller
  big <- tempfile(fileext = ".png")
  magick::image_write(magick::image_blank(5000, 1000, "white"), big)
  report_store_asset(cache, "a3", paste0("data:image/png;base64,", jsonlite::base64_enc(readBin(big, "raw", file.info(big)$size))))
  expect_equal(magick::image_info(magick::image_read(cache$report_assets$a3$data))$width, 4000)

  file <- .rb_asset_file(cache, "asset:a1", tempfile())
  expect_true(file.exists(file))
  r <- .rb_image_file(list(type = "image", src = "asset:a1", src_file = file), tempfile(), c(3, 1.5))
  expect_equal(r$type, "image")
})

test_that("the national coverage titles name the chart under them with {chart_indicator}", {
  blocks <- report_presets("en", "rmncah")$national_coverage$blocks
  templated <- which(vapply(blocks, function(b) {
    b$type %in% c("heading", "paragraph") && grepl("{chart_indicator}", b$text, fixed = TRUE)
  }, logical(1)))
  expect_gt(length(templated), 0)
  expect_true(any(vapply(templated, function(i) i < length(blocks) && identical(blocks[[i + 1]]$type, "chart"), logical(1))))
})

test_that("the slide layouts are PowerPoint's, their boxes inside the slide", {
  layouts <- report_deck_layouts()
  expect_length(layouts, 12)
  expect_identical(vapply(layouts, function(l) l$id, ""),
                   c("title", "title_content", "two_content", "three_content", "comparison", "title_only", "section", "blank",
                     "picture_caption", "content_caption", "picture_left", "full_picture"))
  for (l in layouts) {
    expect_true(all(c("en", "fr", "pt") %in% names(l$name)), info = l$id)
    for (it in l$items) {
      expect_true(it$role %in% c("title", "subtitle", "heading", "body", "picture"), info = l$id)
      expect_true(it$type %in% c("text", "content"), info = l$id)
      expect_true(it$x >= 0 && it$y >= 0 && it$w > 0 && it$h > 0, info = l$id)
      expect_true(it$x + it$w <= 1 + 1e-9 && it$y + it$h <= 1 + 1e-9, info = l$id)
    }
  }
  expect_length(layouts[[8]]$items, 0)
  expect_identical(report_deck_layouts("fr")[[1]]$name, "Diapositive de titre")
  # the picture layouts, as the editor has them
  box <- function(it) c(it$x, it$y, it$w, it$h)
  by_id <- stats::setNames(layouts, vapply(layouts, function(l) l$id, ""))
  pc <- by_id$picture_caption$items
  expect_identical(vapply(pc, function(i) i$role, ""), c("title", "picture", "body"))
  expect_equal(box(pc[[2]]), c(0.4688, 0.1111, 0.4625, 0.7778))
  expect_identical(pc[[2]]$type, "content")
  expect_identical(vapply(by_id$content_caption$items, function(i) i$role, ""), c("title", "body", "body"))
  expect_equal(box(by_id$picture_left$items[[1]]), c(0, 0, 0.5, 1))
  expect_equal(box(by_id$full_picture$items[[1]]), c(0, 0, 1, 1))
  expect_equal(box(by_id$full_picture$items[[2]]), c(0.05, 0.72, 0.9, 0.18))
  expect_identical(by_id$full_picture$name$en, "Full Picture with Title")
})

test_that("slides are 16:9 unless 4:3, and a block on a slide is drawn at its box", {
  expect_equal(report_slide_size(NULL), c(13.333, 7.5))
  expect_equal(report_slide_size(report_default_design()), c(13.333, 7.5))
  expect_equal(report_slide_size(list(slide_size = "4:3")), c(10, 7.5))
  expect_identical(report_default_design()$slide_size, "16:9")
  expect_identical(.rb_design(list(slide_size = "4:3"))$slide_size, "4:3")
  expect_equal(report_block_size(list(type = "chart", kind = "coverage", box = c(3.2, 5.1))), c(3.2, 5.1))
  expect_equal(report_block_size(list(type = "image", ratio = 2, box = list(4, 1))), c(4, 1))
  # without a box, as before
  expect_equal(report_block_size(list(type = "chart", size = "full", kind = "coverage"))[1], 6.5, tolerance = 0.01)
})

test_that("the one-pager is a one-slide deck for both groups, its items inside the slide", {
  for (group in c("rmncah", "vaccine")) {
    for (lang in c("en", "fr")) {
      p <- report_presets(lang, group)$one_pager
      expect_identical(p$kind, "deck")
      expect_identical(p$design$slide_size, "16:9")
      expect_length(p$slides, 1)
      size <- report_slide_size(p$design)
      items <- p$slides[[1]]$items
      ids <- vapply(items, function(it) it$id, "")
      expect_false(anyDuplicated(ids) > 0)
      for (it in items) {
        expect_true(it$x >= 0 && it$y >= 0 && it$x + it$w <= size[1] + 1e-6 && it$y + it$h <= size[2] + 1e-6, info = paste(group, it$id))
        expect_true(is.character(it$block$id) && nzchar(it$block$id), info = it$id)
        if (it$block$type %in% c("chart", "table")) expect_identical(it$block$region, "@report", info = it$id)
        expect_false(inherits(it$block$text, "rb_tx"))
      }
      expect_identical(items[[1]]$role, "title")
      expect_match(items[[1]]$block$text, "{region}", fixed = TRUE)
    }
    # the other standard reports are documents
    expect_identical(report_presets("en", group)$data_quality$kind, "document")
  }
})

test_that("report_project_blocks gives a document's blocks and a deck's items' blocks with their boxes", {
  doc <- list(blocks = list(list(id = "b1", type = "heading", text = "Hi")))
  expect_identical(report_project_blocks(doc), doc$blocks)
  deck <- list(kind = "deck", slides = list(
    list(id = "s1", items = list(list(id = "i1", x = 1, y = 1, w = 4, h = 3, block = list(id = "x", type = "chart", kind = "coverage")))),
    list(id = "s2", items = list(list(id = "i2", x = 0, y = 0, w = 2, h = 1, role = "title", block = list(type = "paragraph", text = "<p>T</p>"))))
  ))
  blocks <- report_project_blocks(deck)
  expect_length(blocks, 2)
  expect_identical(blocks[[1]]$id, "i1")
  expect_equal(blocks[[1]]$box, c(4, 3))
  expect_equal(report_block_size(blocks[[1]]), c(4, 3))
  expect_identical(blocks[[2]]$type, "paragraph")
})

test_that("slide text keeps paragraphs' alignment, headings and empty lines", {
  lines <- .rb_lines('<p style="text-align: center">Hi <strong>b</strong></p><p></p><h2>Sub</h2><ul><li><p>one</p></li></ul>', keep_empty = TRUE)
  expect_length(lines, 4)
  expect_identical(attr(lines[[1]], "align"), "center")
  expect_length(lines[[2]], 0)
  expect_identical(attr(lines[[3]], "heading"), 2L)
  expect_identical(attr(lines[[4]], "list"), "bullet")
  # documents drop empty paragraphs, as before
  expect_length(.rb_lines("<p>a</p><p></p><p>b</p>"), 2)
  expect_match(.rb_deck_bullet("number", 1, 3), 'startAt="3"', fixed = TRUE)
  expect_match(.rb_deck_bullet("bullet", 2, 1), "buChar", fixed = TRUE)
})

test_that("a deck asks for PowerPoint, a document for Word", {
  deck <- list(kind = "deck", slides = list())
  expect_error(export_report(NULL, deck, tempfile(fileext = ".docx"), "docx"), "PowerPoint")
  expect_error(export_report(NULL, list(blocks = list()), tempfile(fileext = ".pptx"), "pptx"), "slide decks")
})

test_that("a deck is written as PowerPoint with its slides, size, notes and editable charts", {
  skip_on_cran()
  sp <- "C:/Users/Murage/AppData/Local/Temp/claude/C--Users-Murage-Documents-Dev-JS-datasuite-infrastructure-countdown-analytics/0171e636-25cb-4a27-8a73-f0564ba0f0e6/scratchpad"
  src <- file.path(sp, "benin_rb_copy.rds")
  skip_if_not(file.exists(src), "No Benin test data")
  skip_if_not_installed("rvg")
  skip_if_not_installed("zip")
  rds <- tempfile(fileext = ".rds")
  file.copy(src, rds)
  cache <- suppressWarnings(CacheConnection$new(rds_path = rds))
  old <- get_selected_group()
  set_selected_group("rmncah")
  on.exit(set_selected_group(old), add = TRUE)

  deck <- list(
    id = "d", name = "Test deck", lang = "en", kind = "deck", design = utils::modifyList(report_default_design(), list(slide_size = "4:3")),
    slides = list(
      list(id = "s1", layout = "title_content", notes = "First line\nSecond line", items = list(
        list(id = "t", x = 0.5, y = 0.3, w = 9, h = 1, role = "title", block = list(type = "paragraph", text = "<p>{chart_indicator} in {country}</p>")),
        list(id = "c", x = 0.5, y = 1.5, w = 9, h = 5.5, block = list(type = "chart", kind = "coverage", indicator = "penta3", admin_level = "national"))
      )),
      list(id = "s2", layout = "two_content", items = list(
        list(id = "b", x = 0.5, y = 1.5, w = 4.3, h = 5, role = "body", block = list(type = "paragraph", text = "<ul><li><p>one</p></li></ul>")),
        list(id = "tb", x = 5, y = 1.5, w = 4.5, h = 5, block = list(type = "table", kind = "coverage_table")),
        list(id = "bad", x = 0.5, y = 6.6, w = 4, h = 0.5, block = list(type = "chart", kind = "region_coverage", indicator = "penta3", region = "@report"))
      ))
    )
  )
  file <- tempfile(fileext = ".pptx")
  suppressWarnings(export_report(cache, deck, file, "pptx"))
  expect_true(file.exists(file))
  x <- officer::read_pptx(file)
  expect_identical(length(x), 2L)

  dir <- tempfile()
  utils::unzip(file, exdir = dir)
  pres <- paste(readLines(file.path(dir, "ppt", "presentation.xml"), warn = FALSE), collapse = "")
  expect_match(pres, '<p:sldSz cx="9144000" cy="6858000"/>', fixed = TRUE)
  s1 <- paste(readLines(file.path(dir, "ppt", "slides", "slide1.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  s2 <- paste(readLines(file.path(dir, "ppt", "slides", "slide2.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  # the chart is a group of shapes (editable), not a picture
  expect_match(s1, "<p:grpSp", fixed = TRUE)
  expect_false(grepl("<p:pic", s1, fixed = TRUE))
  # the title is the slide's title, its fields filled from the slide's chart
  expect_match(s1, '<p:ph type="title"/>', fixed = TRUE)
  expect_match(s1, "penta3 in Benin", fixed = TRUE)
  # the table is a PowerPoint table; the list has a bullet; a chart that needs a region says so
  expect_match(s2, "<a:tbl>", fixed = TRUE)
  expect_match(s2, "<a:buChar", fixed = TRUE)
  expect_match(s2, "could not be drawn", fixed = TRUE)
  notes <- list.files(file.path(dir, "ppt", "notesSlides"), pattern = "\\.xml$")
  expect_length(notes, 1)
  n1 <- paste(readLines(file.path(dir, "ppt", "notesSlides", notes[1]), warn = FALSE), collapse = "")
  expect_match(n1, "Second line", fixed = TRUE)

  # the one-pager, for a region
  one <- report_presets("en", "rmncah")$one_pager
  one$region <- sort(unique(cache$subnational_regions$adminlevel_1))[1]
  file2 <- tempfile(fileext = ".pptx")
  suppressWarnings(export_report(cache, one, file2))
  expect_identical(length(officer::read_pptx(file2)), 1L)
  dir2 <- tempfile()
  utils::unzip(file2, exdir = dir2)
  pres2 <- paste(readLines(file.path(dir2, "ppt", "presentation.xml"), warn = FALSE), collapse = "")
  expect_match(pres2, '<p:sldSz cx="12192000" cy="6858000"/>', fixed = TRUE)
})

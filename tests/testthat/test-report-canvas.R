test_that("a free-layout page is a page of floating objects in Word and in the PDF made from it", {
  skip_on_cran()
  sp <- "C:/Users/Murage/AppData/Local/Temp/claude/C--Users-Murage-Documents-Dev-JS-datasuite-infrastructure-countdown-analytics/0171e636-25cb-4a27-8a73-f0564ba0f0e6/scratchpad"
  src <- file.path(sp, "benin_rb_copy.rds")
  skip_if_not(file.exists(src), "No Benin test data")
  skip_if_not_installed("magick")
  skip_if_not_installed("zip")
  rds <- tempfile(fileext = ".rds")
  file.copy(src, rds)
  cache <- suppressWarnings(CacheConnection$new(rds_path = rds))
  old <- get_selected_group()
  set_selected_group("rmncah")
  on.exit(set_selected_group(old), add = TRUE)

  p <- .rb_test_canvas_project()
  docx <- tempfile(fileext = ".docx")
  suppressWarnings(export_report(cache, p, docx, "docx", converter = "browser"))
  expect_true(file.exists(docx))
  expect_s3_class(officer::read_docx(docx), "rdocx")
  dir <- tempfile()
  utils::unzip(docx, exdir = dir)
  body <- readChar(file.path(dir, "word", "document.xml"), 1e8, useBytes = TRUE)
  rels <- readChar(file.path(dir, "word", "_rels", "document.xml.rels"), 1e7, useBytes = TRUE)
  expect_false(grepl("@@RBCI:", body, fixed = TRUE))
  # six floating objects, placed from the margins, stacked in the items' order
  anchors <- regmatches(body, gregexpr("<wp:anchor .*?</wp:anchor>", body))[[1]]
  expect_length(anchors, 6)
  offsets <- function(a) as.numeric(regmatches(a, gregexpr("(?<=<wp:posOffset>)[0-9]+", a, perl = TRUE))[[1]])
  emu <- function(v) round(v * 914400)
  expect_equal(offsets(anchors[[2]]), emu(c(0, 1)))
  expect_equal(offsets(anchors[[3]]), emu(c(4.4, 1)))
  expect_equal(offsets(anchors[[4]]), emu(c(0, 4.5)))
  expect_equal(offsets(anchors[[6]]), emu(c(0.5, 8.5)))
  expect_true(all(grepl('relativeFrom="margin"', anchors)))
  z <- as.numeric(sub('relativeHeight="([0-9]+)"', "\\1", regmatches(anchors, regexpr('relativeHeight="[0-9]+"', anchors))))
  expect_false(is.unsorted(z, strictly = TRUE))
  expect_match(anchors[[2]], '<wp:extent cx="3840480" cy="2926080"/>', fixed = TRUE)
  # the chart is an SVG with its PNG copy; the picture is a picture; text and the table are text boxes
  expect_match(anchors[[2]], "svgBlip", fixed = TRUE)
  expect_match(anchors[[5]], "<pic:pic", fixed = TRUE)
  expect_match(anchors[[1]], "penta3 in Benin", fixed = TRUE)
  expect_match(anchors[[3]], "<w:txbxContent>", fixed = TRUE)
  expect_match(anchors[[3]], "\u2022", fixed = TRUE)
  # a link in a text box points to its address
  link <- regmatches(anchors[[3]], regexpr('(?<=<w:hyperlink r:id=")[^"]+', anchors[[3]], perl = TRUE))
  expect_match(link, "^rId[0-9]+$")
  expect_match(rels, sprintf('Id="%s"[^>]*Target="https://example.org/\\?a=1&amp;b=2" TargetMode="External"', link))
  expect_match(anchors[[4]], "<w:tbl>", fixed = TRUE)
  expect_match(anchors[[6]], '<w:color w:val="FFFFFF"/>', fixed = TRUE)
  for (id in unlist(regmatches(anchors, gregexpr('(?<=r:embed=")rId[0-9]+', anchors, perl = TRUE)))) {
    target <- sub(".*Target=\"([^\"]+)\".*", "\\1", regmatches(rels, regexpr(sprintf('<Relationship Id="%s"[^>]*>', id), rels)))
    expect_true(file.exists(file.path(dir, "word", target)), info = id)
  }
  # the canvas starts a new page and the paragraph after it starts another
  expect_identical(lengths(regmatches(body, gregexpr("<w:pageBreakBefore/>", body))), 2L)

  skip_if_not(identical(report_converter(), "word"), "Microsoft Word is not installed")
  skip_if_not_installed("pdftools")
  pdf <- tempfile(fileext = ".pdf")
  suppressWarnings(export_report(cache, p, pdf, "pdf"))
  # cover, contents, the page before, the canvas, the page after
  expect_identical(pdftools::pdf_info(pdf)$pages, 5L)
  text <- pdftools::pdf_text(pdf)
  expect_match(text[[3]], "page before", fixed = TRUE)
  expect_match(text[[5]], "page after", fixed = TRUE)
  expect_false(grepl("page after", text[[4]], fixed = TRUE))
  words <- pdftools::pdf_data(pdf)[[4]]
  at <- function(w) words[words$text == w, , drop = FALSE][1, ]
  page <- report_page(p$design)
  # the text area's top-left corner, in points
  x0 <- page$left * 72
  y0 <- page$top * 72
  near <- function(value, target, tol = 12) expect_true(abs(value - target) <= tol, info = paste(value, "vs", target))
  # the title, in the middle of its box
  near(at("penta3")$y + at("penta3")$height / 2, y0 + 0.4 * 72)
  near(at("penta3")$x, x0 + 0.1 * 72)
  # the list beside the chart: after the box's inset and the bullet's indent
  near(at("First")$x, x0 + 4.4 * 72 + 0.1 * 72 + 13)
  near(at("First")$y, y0 + 1 * 72 + 0.05 * 72)
  # the table at its box, the label centred on the picture in front of it
  near(at("Indicator")$y, y0 + 4.5 * 72)
  near(at("Indicator")$x, x0, 6)
  near((at("On")$x + at("top")$x + at("top")$width) / 2, x0 + 1.5 * 72)
  near(at("On")$y + at("On")$height / 2, y0 + 8.8 * 72)
})

test_that("a free-layout page first or last in a document adds no blank page", {
  skip_on_cran()
  sp <- "C:/Users/Murage/AppData/Local/Temp/claude/C--Users-Murage-Documents-Dev-JS-datasuite-infrastructure-countdown-analytics/0171e636-25cb-4a27-8a73-f0564ba0f0e6/scratchpad"
  src <- file.path(sp, "benin_rb_copy.rds")
  skip_if_not(file.exists(src), "No Benin test data")
  skip_if_not_installed("magick")
  skip_if_not(identical(report_converter(), "word"), "Microsoft Word is not installed")
  skip_if_not_installed("pdftools")
  rds <- tempfile(fileext = ".rds")
  file.copy(src, rds)
  cache <- suppressWarnings(CacheConnection$new(rds_path = rds))
  old <- get_selected_group()
  set_selected_group("rmncah")
  on.exit(set_selected_group(old), add = TRUE)

  p <- .rb_test_canvas_project()
  p$design$cover <- FALSE
  p$design$contents <- FALSE
  canvas <- p$blocks[[2]]
  # canvas, canvas, text: three pages; text, canvas: two
  p$blocks <- list(canvas, canvas, p$blocks[[3]])
  pdf <- tempfile(fileext = ".pdf")
  suppressWarnings(export_report(cache, p, pdf, "pdf"))
  expect_identical(pdftools::pdf_info(pdf)$pages, 3L)
  expect_match(pdftools::pdf_text(pdf)[[3]], "page after", fixed = TRUE)
  p$blocks <- list(list(id = "p", type = "paragraph", text = "<p>Before</p>"), canvas)
  suppressWarnings(export_report(cache, p, pdf, "pdf"))
  expect_identical(pdftools::pdf_info(pdf)$pages, 2L)
})

test_that("without Word, the HTML places a canvas's items at their boxes", {
  skip_on_cran()
  sp <- "C:/Users/Murage/AppData/Local/Temp/claude/C--Users-Murage-Documents-Dev-JS-datasuite-infrastructure-countdown-analytics/0171e636-25cb-4a27-8a73-f0564ba0f0e6/scratchpad"
  src <- file.path(sp, "benin_rb_copy.rds")
  skip_if_not(file.exists(src), "No Benin test data")
  skip_if_not_installed("magick")
  rds <- tempfile(fileext = ".rds")
  file.copy(src, rds)
  cache <- suppressWarnings(CacheConnection$new(rds_path = rds))
  old <- get_selected_group()
  set_selected_group("rmncah")
  on.exit(set_selected_group(old), add = TRUE)

  dir <- tempfile()
  dir.create(dir)
  parts <- suppressWarnings(.rb_prepare(cache, .rb_test_canvas_project(), dir, NULL, function(x) NULL))
  r <- parts$rendered[[2]]
  expect_identical(r$type, "canvas")
  expect_length(r$items, 6)
  html <- .rb_html(parts, NULL)
  expect_match(html, '<div class="canvas" style="width:', fixed = TRUE)
  expect_match(html, "left:4.4in;top:1in;width:2.3in;height:3.2in", fixed = TRUE)
  expect_match(html, "penta3 in Benin", fixed = TRUE)
})

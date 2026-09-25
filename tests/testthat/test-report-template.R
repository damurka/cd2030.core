test_that("a deck and a document are written on top of their templates", {
  skip_on_cran()
  sp <- "C:/Users/Murage/AppData/Local/Temp/claude/C--Users-Murage-Documents-Dev-JS-datasuite-infrastructure-countdown-analytics/0171e636-25cb-4a27-8a73-f0564ba0f0e6/scratchpad"
  src <- file.path(sp, "benin_rb_copy.rds")
  skip_if_not(file.exists(src), "No Benin test data")
  skip_if_not_installed("zip")
  skip_if_not_installed("magick")
  rds <- tempfile(fileext = ".rds")
  file.copy(src, rds)
  cache <- suppressWarnings(CacheConnection$new(rds_path = rds))
  old <- get_selected_group()
  set_selected_group("rmncah")
  on.exit(set_selected_group(old), add = TRUE)
  pic <- .rb_test_picture(tempfile(fileext = ".png"))
  data_url <- paste0("data:image/png;base64,", jsonlite::base64_enc(readBin(pic, "raw", file.info(pic)$size)))

  # a 4:3 template: its slide size is kept (the design's own is not written), its master and background too
  potx <- .rb_test_pptx_template(tempfile(fileext = ".potx"), size = "4:3")
  design <- report_theme_from_file(potx)
  design$template <- potx
  deck <- list(kind = "deck", name = "T", lang = "en", design = design, slides = list(
    list(id = "s1", layout = "full_picture", items = list(
      list(id = "pic", x = 0, y = 0, w = 10, h = 7.5, role = "picture", block = list(type = "image", src = data_url, ratio = 2 / 3, pic_style = "soft")),
      list(id = "title", x = 0.5, y = 5.4, w = 9, h = 1.35, role = "title", fill = "#000000", fill_opacity = 0.45, outline = "#ffffff",
           block = list(type = "paragraph", text = "<p>Over the picture</p>", color = "#ffffff"))
    )),
    list(id = "s2", layout = "picture_left", items = list(
      list(id = "empty", x = 0, y = 0, w = 5, h = 7.5, role = "picture", block = list(type = "image")),
      list(id = "t2", x = 5.4, y = 0.6, w = 4.2, h = 1.35, role = "title", block = list(type = "paragraph", text = "<p>Beside</p>"))
    ))
  ))
  file <- tempfile(fileext = ".pptx")
  suppressWarnings(export_report(cache, deck, file, "pptx"))
  dir <- tempfile()
  utils::unzip(file, exdir = dir)
  pres <- paste(readLines(file.path(dir, "ppt", "presentation.xml"), warn = FALSE), collapse = "")
  expect_match(pres, '<p:sldSz cx="9144000" cy="6858000"/>', fixed = TRUE)
  master <- paste(readLines(file.path(dir, "ppt", "slideMasters", "slideMaster1.xml"), warn = FALSE), collapse = "")
  expect_match(master, 'val="F3EEE4"', fixed = TRUE)
  expect_match(master, "Template band", fixed = TRUE)
  theme <- paste(readLines(file.path(dir, "ppt", "theme", "theme1.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  expect_match(theme, '<a:latin typeface="Georgia"', fixed = TRUE)
  s1 <- gsub(">\\s+<", "><", paste(readLines(file.path(dir, "ppt", "slides", "slide1.xml"), warn = FALSE, encoding = "UTF-8"), collapse = ""))
  s2 <- gsub(">\\s+<", "><", paste(readLines(file.path(dir, "ppt", "slides", "slide2.xml"), warn = FALSE, encoding = "UTF-8"), collapse = ""))
  # the title's fill, 45% opaque, and its outline; it comes after the picture, so it is in front of it
  expect_match(s1, '<a:srgbClr val="000000"><a:alpha val="45000"/></a:srgbClr>', fixed = TRUE)
  expect_match(s1, '<a:ln w="12700"><a:solidFill><a:srgbClr val="FFFFFF"/>', fixed = TRUE)
  expect_lt(regexpr("<p:pic", s1, fixed = TRUE), regexpr("Over the picture", s1, fixed = TRUE))
  # the empty placeholder writes nothing
  expect_false(grepl("<p:pic", s2, fixed = TRUE))
  expect_false(grepl("could not", s2, fixed = TRUE))
  expect_identical(length(officer::read_pptx(file)), 2L)

  # a Word template: its header, its page, the report's styles; a free page with a filled text box over a picture
  dotx <- .rb_test_docx_template(tempfile(fileext = ".dotx"))
  ddesign <- report_theme_from_file(dotx)
  ddesign$template <- dotx
  ddesign$cover <- FALSE
  doc <- list(name = "D", design = ddesign, blocks = list(
    list(id = "h", type = "heading", level = 1, text = "Heading"),
    list(id = "cv", type = "canvas", items = list(
      list(id = "pic", x = 0, y = 0, w = 5, h = 3.3, block = list(type = "image", src = data_url, ratio = 2 / 3, pic_style = "soft")),
      list(id = "label", x = 0.5, y = 2.2, w = 4, h = 0.8, fill = "#1f5c4a", fill_opacity = 0.6,
           block = list(type = "paragraph", text = "<p>Label</p>", color = "#ffffff"))
    ))
  ))
  wfile <- tempfile(fileext = ".docx")
  suppressWarnings(export_report(cache, doc, wfile, "docx", converter = "browser"))
  wdir <- tempfile()
  utils::unzip(wfile, exdir = wdir)
  body <- paste(readLines(file.path(wdir, "word", "document.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  expect_true(file.exists(file.path(wdir, "word", "header1.xml")))
  expect_match(body, "<w:headerReference", fixed = TRUE)
  expect_match(body, '<w:pgSz w:w="11900" w:h="16840"', fixed = TRUE)
  expect_match(body, '<a:srgbClr val="1F5C4A"><a:alpha val="60000"/></a:srgbClr>', fixed = TRUE)
  # stacked in order: the text box after the picture, and above it
  heights <- as.numeric(regmatches(body, gregexpr('(?<=relativeHeight=")[0-9]+', body, perl = TRUE))[[1]])
  expect_length(heights, 2)
  expect_lt(heights[1], heights[2])
  expect_lt(regexpr("<pic:pic", body, fixed = TRUE), regexpr("Label", body, fixed = TRUE))
  styles <- paste(readLines(file.path(wdir, "word", "styles.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  expect_match(styles, "1F5C4A", ignore.case = TRUE)
})

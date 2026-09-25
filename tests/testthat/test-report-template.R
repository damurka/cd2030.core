test_that("a PowerPoint file's theme becomes a report theme", {
  skip_if_not_installed("zip")
  potx <- .rb_test_pptx_template(tempfile("Brand ", fileext = ".potx"))
  th <- report_theme_from_file(potx, name = "Brand")
  # the fields of the ready-made themes, and what the file adds
  expect_setequal(setdiff(names(th), c("template_kind", "background", "slide_designs")), names(report_themes()$countdown))
  expect_named(th$slide_designs, c("title", "content"))
  expect_true("background" %in% names(th))
  expect_identical(th$template_kind, "pptx")
  expect_match(th$theme, "^custom_[0-9a-f]+$")
  expect_identical(th$name, list(en = "Brand", fr = "Brand", pt = "Brand"))
  expect_identical(th$accent, "#b5472b")
  expect_identical(th$text_color, "#1b1b1b")
  # the title colour of the master is the text colour: the second dark colour is the heading colour
  expect_identical(th$heading_color, "#243b55")
  expect_identical(th$palette, c("#b5472b", "#2e7d6b", "#e0a526", "#5b4c9a", "#3f88c5", "#7a8691"))
  expect_identical(th$heading_font, "Georgia")
  expect_identical(th$body_font, "Verdana")
  expect_identical(th$slide_size, "16:9")
  expect_identical(th$background, "#f3eee4")
  expect_match(th$note_fill, "^#[0-9a-f]{6}$")
  expect_gt(.rb_luminance(th$note_fill), .rb_luminance(th$note_border))
  expect_gt(.rb_luminance(th$muted_color), .rb_luminance(th$text_color))
  # sizes stay the default design's
  expect_identical(th$h1_size, report_default_design()$h1_size)
  # the design it makes is a complete one
  expect_identical(.rb_design(th)$heading_font, "Georgia")

  pptx <- .rb_test_pptx_template(tempfile(fileext = ".pptx"), size = "4:3", background = NULL)
  th2 <- report_theme_from_file(pptx)
  expect_identical(th2$slide_size, "4:3")
  expect_null(th2$background)
  expect_true("background" %in% names(th2))
  # the file's name (without its extension) is the theme's name
  expect_identical(th2$name$en, tools::file_path_sans_ext(basename(pptx)))
  expect_false(identical(th$theme, th2$theme))
})

test_that("a Word file's theme and styles become a report theme", {
  skip_if_not_installed("zip")
  dotx <- .rb_test_docx_template(tempfile(fileext = ".dotx"))
  th <- report_theme_from_file(dotx)
  expect_identical(th$template_kind, "docx")
  expect_false("background" %in% names(th))
  expect_identical(th$accent, "#2a7f62")
  # Heading 1's own colour and size, Normal's size, the theme's fonts the styles refer to
  expect_identical(th$heading_color, "#1f5c4a")
  expect_identical(th$h1_size, 20)
  expect_identical(th$body_size, 11)
  expect_identical(th$heading_font, "Cambria")
  expect_identical(th$body_font, "Corbel")
  expect_identical(th$text_color, "#202020")
  # the page: officer's blank document is A4 portrait
  expect_identical(th$size, "a4")
  expect_identical(th$orientation, "portrait")
})

test_that("a file that is not a PowerPoint or Word file is refused", {
  f <- tempfile(fileext = ".pptx")
  writeLines("not a zip", f)
  expect_error(report_theme_from_file(f), "PowerPoint or Word")
  expect_error(report_theme_from_file(tempfile()), "PowerPoint or Word")
})

test_that("theme colours follow Office's colour changes", {
  expect_identical(toupper(.rb_color_mods("#000000", lum_mod = 0.5, lum_off = 0.5)), "#808080")
  expect_identical(toupper(.rb_color_mods("#FFFFFF", shade = 0.5)), "#808080")
  expect_identical(toupper(.rb_mix("#000000", "#FFFFFF", 0.5)), "#808080")
  expect_identical(.rb_part_path("ppt/slideMasters", "../theme/theme1.xml"), "ppt/theme/theme1.xml")
})

test_that("a template that cannot be used is left out with a warning", {
  bad <- tempfile(fileext = ".pptx")
  writeLines("nope", bad)
  expect_null(.rb_deck_template(NULL))
  expect_null(.rb_docx_template(""))
  expect_warning(expect_null(.rb_deck_template(bad)), "could not be used")
  expect_warning(expect_null(.rb_docx_template(bad)), "could not be used")
  skip_if_not_installed("zip")
  # a Word file is not a PowerPoint template
  expect_warning(expect_null(.rb_deck_template(.rb_test_docx_template(tempfile(fileext = ".docx")))), "could not be used")
})

test_that("a PowerPoint template is opened without its slides, on its blank layout", {
  skip_if_not_installed("zip")
  potx <- .rb_test_pptx_template(tempfile(fileext = ".potx"))
  t <- .rb_deck_template(potx)
  expect_s3_class(t$x, "rpptx")
  expect_identical(length(t$x), 0L)
  expect_identical(t$layout, "Blank")
})

test_that("a Word template is emptied and given the styles the report writes with", {
  skip_if_not_installed("zip")
  dotx <- .rb_test_docx_template(tempfile(fileext = ".dotx"))
  t <- .rb_docx_template(dotx)
  expect_true(file.exists(t$file))
  expect_true(t$section$header_footer)
  expect_equal(t$section$width, 11900 / 1440)
  dir <- tempfile()
  utils::unzip(t$file, exdir = dir)
  types <- paste(readLines(file.path(dir, "[Content_Types].xml"), warn = FALSE), collapse = "")
  expect_match(types, "wordprocessingml.document.main+xml", fixed = TRUE)
  styles <- paste(readLines(file.path(dir, "word", "styles.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  expect_match(styles, 'w:val="Notes Box"', fixed = TRUE)
  expect_match(styles, 'w:val="TOC Heading"', fixed = TRUE)
  doc <- paste(readLines(file.path(dir, "word", "document.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  expect_match(doc, "<w:headerReference", fixed = TRUE)
  expect_false(grepl("<w:t>", doc, fixed = TRUE))
  settings <- paste(readLines(file.path(dir, "word", "settings.xml"), warn = FALSE), collapse = "")
  expect_false(grepl("evenAndOddHeaders", settings, fixed = TRUE))
})

test_that("picture styles are drawn into the picture, which keeps its size", {
  skip_if_not_installed("magick")
  pic <- .rb_test_picture(tempfile(fileext = ".png"), 600, 400)
  for (style in .rb_pic_styles) {
    for (shape in c("rect", "circle")) {
      r <- .rb_image_file(list(type = "image", src_file = pic, pic_style = style, shape = shape), tempfile(), c(4, 4 * 2 / 3))
      expect_identical(r$type, "image")
      expect_true(file.exists(r$file), info = style)
      expect_match(r$file, "_formatted\\.png$")
      dims <- .rb_image_dims(r$file)
      expect_equal(dims, if (shape == "circle") c(400, 400) else c(600, 400), info = paste(style, shape))
      px <- as.integer(magick::image_data(magick::image_read(r$file), "rgba"))
      # the corner is (nearly) transparent: the picture is smaller inside (shadow, frame), faded (soft) or cut (circle)
      if (style != "reflection" || shape == "circle") expect_lt(px[1, 1, 4], 60, label = paste(style, shape, "corner alpha"))
      if (style == "reflection") {
        # the reflection: faint at the bottom
        expect_lt(px[dims[2], dims[1] %/% 2, 4], 60)
        expect_gt(px[round(dims[2] * 0.4), dims[1] %/% 2, 4], 250)
      }
      # the middle is the picture
      expect_gt(px[dims[2] %/% 3, dims[1] %/% 2, 4], 250, label = paste(style, shape, "middle alpha"))
    }
  }
  expect_identical(.rb_pic_style_of(list(pic_style = "glow")), "")
  expect_true(.rb_chart_pictured(list(type = "chart", pic_style = "shadow")))
  expect_false(.rb_chart_pictured(list(type = "chart")))
})

test_that("text boxes can be filled and outlined", {
  expect_null(.rb_text_fill(list(), list()))
  f <- .rb_text_fill(list(fill = "#000000", fill_opacity = 0.45), list(type = "paragraph"))
  expect_identical(f$fill, "000000")
  expect_equal(f$opacity, 0.45)
  xml <- .rb_text_fill_xml(f)
  expect_match(xml, '<a:solidFill><a:srgbClr val="000000"><a:alpha val="45000"/></a:srgbClr></a:solidFill>', fixed = TRUE)
  expect_match(xml, "<a:ln><a:noFill/></a:ln>", fixed = TRUE)
  # on the block, opaque by default, with an outline
  g <- .rb_text_fill(list(), list(fill = "#FFCC00", outline = "#112233"))
  expect_equal(g$opacity, 1)
  expect_match(.rb_text_fill_xml(g), '<a:solidFill><a:srgbClr val="FFCC00"/></a:solidFill><a:ln w="12700"><a:solidFill><a:srgbClr val="112233"/></a:solidFill></a:ln>', fixed = TRUE)
  # an outline alone
  expect_match(.rb_text_fill_xml(.rb_text_fill(list(outline = "#112233"), list())), "^<a:noFill/><a:ln w=")
  # an empty picture placeholder writes nothing
  expect_true(.rb_empty_placeholder(list(role = "picture"), list(type = "image")))
  expect_true(.rb_empty_placeholder(list(role = "picture"), list()))
  expect_false(.rb_empty_placeholder(list(role = "picture"), list(type = "image", src = "data:image/png;base64,AA")))
  expect_false(.rb_empty_placeholder(list(role = "body"), list(type = "image")))
})

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

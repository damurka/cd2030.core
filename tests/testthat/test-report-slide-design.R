# Slide designs: the look a PowerPoint file's slides have (logos, bands, the title's box), read by report_theme_from_file()
# and drawn by export_deck()

.sd_user_file <- function() {
  src <- "C:/Users/Murage/Downloads/Data extraction ppt.pptx"
  if (!file.exists(src)) return(NULL)
  copy <- tempfile(fileext = ".pptx")
  file.copy(src, copy)
  copy
}

.sd_slide_xml <- function(dir, n) {
  gsub(">\\s+<", "><", paste(readLines(file.path(dir, "ppt", "slides", paste0("slide", n, ".xml")), warn = FALSE, encoding = "UTF-8"), collapse = ""))
}

# A stand-in for the dataset: a deck of texts only reads no data
.sd_cache <- function() list(chart_options = list(), get_chart_options = function(...) NULL)

.sd_png <- function(file, colour = "#c0392b") {
  grDevices::png(file, width = 120, height = 60)
  graphics::par(mar = c(0, 0, 0, 0))
  graphics::plot.new()
  graphics::rect(0, 0, 1, 1, col = colour, border = NA)
  grDevices::dev.off()
  file
}

test_that("a template without slides gives its designs from its title and content layouts, with the master's decor", {
  skip_if_not_installed("zip")
  potx <- .rb_test_pptx_template(tempfile(fileext = ".potx"))
  th <- report_theme_from_file(potx)
  expect_named(th$slide_designs, c("title", "content"))
  for (which in c("title", "content")) {
    d <- th$slide_designs[[which]]
    expect_false(is.null(d), info = which)
    expect_named(d, c("background", "decor", "title", "subtitle", "body"), info = which)
    # the band the master draws (accent1, along the bottom)
    rects <- Filter(function(x) identical(x$type, "rect"), d$decor)
    expect_length(rects, 1)
    expect_identical(rects[[1]]$fill, "#b5472b")
    expect_identical(rects[[1]]$from, "master")
    expect_equal(rects[[1]]$y, 7.2, tolerance = 0.01)
    expect_equal(rects[[1]]$w, 13.333, tolerance = 0.01)
    # the master's background
    expect_identical(d$background, "#f3eee4")
    # the title's font is the theme's heading font
    expect_identical(d$title$font, "Georgia")
    expect_true(d$title$font_size > 0)
    expect_true(d$title$align %in% c("left", "center", "right"))
  }
  expect_false(is.null(th$slide_designs$title$subtitle))
  expect_false(is.null(th$slide_designs$content$body))
  expect_identical(th$slide_designs$content$body$font, "Verdana")
})

test_that("the user's deck: logos on the title slide, a green title band on the content slides", {
  file <- .sd_user_file()
  skip_if(is.null(file), "The user's PowerPoint file is not on this computer")
  th <- report_theme_from_file(file)
  size <- c(13.333, 7.5)
  title <- th$slide_designs$title
  images <- Filter(function(x) identical(x$type, "image"), title$decor)
  expect_length(images, 2)
  for (im in images) {
    expect_true(file.exists(im$file))
    expect_identical(tolower(tools::file_ext(im$file)), "png")
    # logo-like: no big picture
    expect_lt(im$w * im$h, 0.2 * prod(size))
  }
  # the Countdown logo top left, the APHRC logo bottom right
  expect_lt(images[[1]]$x, 1)
  expect_lt(images[[1]]$y, 0.5)
  expect_gt(images[[2]]$x + images[[2]]$w, size[1] - 1)
  expect_gt(images[[2]]$y + images[[2]]$h, size[2] - 1)
  expect_identical(vapply(images, function(im) im$from, ""), c("slide", "slide"))
  # the title slide's title: the big bold text box
  expect_equal(title$title$font_size, 36)
  expect_true(title$title$bold)
  expect_identical(title$title$align, "center")
  expect_null(title$title$fill)
  expect_false(is.null(title$subtitle))

  content <- th$slide_designs$content
  expect_length(content$decor, 0)
  expect_identical(content$title$fill, "#4ea72e")
  expect_identical(content$title$color, "#ffffff")
  expect_equal(content$title$fill_opacity, 1)
  expect_identical(content$title$align, "left")
  expect_equal(content$title$y, 0.399, tolerance = 0.01)
  expect_false(is.null(content$body))
  expect_identical(content$body$color, "#000000")
})

test_that("a deck is drawn on its slide designs: background, then decor, behind the items", {
  skip_if_not_installed("zip")
  logo <- .sd_png(tempfile(fileext = ".png"))
  designs <- list(
    title = list(background = "#fdf6e3", decor = list(
      list(type = "image", file = logo, x = 0.5, y = 0.2, w = 2, h = 1),
      list(type = "image", file = file.path(tempdir(), "no-such-logo.png"), x = 1, y = 1, w = 1, h = 1)
    ), title = NULL, subtitle = NULL, body = NULL),
    content = list(background = NULL, decor = list(
      list(type = "rect", fill = "#4ea72e", fill_opacity = 0.5, outline = NULL, x = 0.9, y = 0.4, w = 11.5, h = 0.9)
    ), title = NULL, subtitle = NULL, body = NULL)
  )
  design <- utils::modifyList(report_default_design(), list(slide_designs = designs))
  text <- function(id, role, words) list(id = id, x = 1, y = 0.5, w = 10, h = 1, role = role, block = list(type = "paragraph", text = paste0("<p>", words, "</p>")))
  deck <- list(kind = "deck", name = "D", lang = "en", design = design, slides = list(
    list(id = "s1", layout = "title", items = list(text("t1", "title", "Cover title"))),
    list(id = "s2", layout = "title_content", items = list(text("t2", "title", "Content title"))),
    list(id = "s3", layout = "title_content", design = "title", items = list(text("t3", "title", "Forced title design"))),
    list(id = "s4", layout = "section", items = list(text("t4", "title", "Section")))
  ))
  file <- tempfile(fileext = ".pptx")
  suppressWarnings(export_deck(.sd_cache(), deck, file, "pptx"))
  dir <- tempfile()
  utils::unzip(file, exdir = dir)
  s1 <- .sd_slide_xml(dir, 1)
  s2 <- .sd_slide_xml(dir, 2)
  s3 <- .sd_slide_xml(dir, 3)
  s4 <- .sd_slide_xml(dir, 4)

  # slide 1 (title layout): the background, the logo (the missing picture left out), behind the title
  expect_match(s1, '<p:bg><p:bgPr><a:solidFill><a:srgbClr val="FDF6E3"/>', fixed = TRUE)
  expect_lt(regexpr("<p:bg>", s1, fixed = TRUE), regexpr("<p:spTree>", s1, fixed = TRUE))
  expect_identical(lengths(regmatches(s1, gregexpr("<p:pic>", s1, fixed = TRUE))), 1L)
  expect_lt(regexpr("<p:pic>", s1, fixed = TRUE), regexpr("Cover title", s1, fixed = TRUE))
  expect_match(s1, '<a:off x="457200" y="182880"/><a:ext cx="1828800" cy="914400"/>', fixed = TRUE)
  expect_true(any(grepl("\\.png$", list.files(file.path(dir, "ppt", "media")))))
  # slide 2 (content): the band, half opaque, behind the title; no background, no logo
  expect_false(grepl("<p:bg>", s2, fixed = TRUE))
  expect_false(grepl("<p:pic>", s2, fixed = TRUE))
  expect_match(s2, '<a:srgbClr val="4EA72E"><a:alpha val="50000"/></a:srgbClr>', fixed = TRUE)
  expect_match(s2, '<a:off x="822960" y="365760"/><a:ext cx="10515600" cy="822960"/>', fixed = TRUE)
  expect_lt(regexpr("4EA72E", s2, fixed = TRUE), regexpr("Content title", s2, fixed = TRUE))
  # slide 3 chose the title design; slide 4 (section) has it by default
  expect_match(s3, "<p:pic>", fixed = TRUE)
  expect_false(grepl("4EA72E", s3, fixed = TRUE))
  expect_match(s4, "<p:pic>", fixed = TRUE)
  expect_identical(length(officer::read_pptx(file)), 4L)

  # the slide design helpers
  expect_null(.rb_slide_design(list(layout = "title"), report_default_design()))
  expect_identical(.rb_slide_design(list(layout = "blank"), design), designs$content)
})

test_that("the user's designs are drawn on an exported deck, on top of the file as its template", {
  file <- .sd_user_file()
  skip_if(is.null(file), "The user's PowerPoint file is not on this computer")
  skip_if_not_installed("zip")
  design <- report_theme_from_file(file)
  logos <- vapply(Filter(function(x) identical(x$type, "image"), design$slide_designs$title$decor), function(x) x$file, "")
  # the content design as the app would give it: the title band drawn as a rectangle
  band <- design$slide_designs$content$title
  design$slide_designs$content$decor <- list(list(type = "rect", fill = band$fill, fill_opacity = 1, outline = NULL,
                                                  x = band$x, y = band$y, w = band$w, h = band$h))
  design$template <- file
  text <- function(id, role, words) list(id = id, x = 1, y = 2, w = 10, h = 1, role = role, block = list(type = "paragraph", text = paste0("<p>", words, "</p>")))
  deck <- list(kind = "deck", name = "D", lang = "en", design = design, slides = list(
    list(id = "s1", layout = "title", items = list(text("t1", "title", "Cover"))),
    list(id = "s2", layout = "title_content", items = list(text("t2", "title", "Inside")))
  ))
  out <- tempfile(fileext = ".pptx")
  suppressWarnings(export_deck(.sd_cache(), deck, out, "pptx"))
  dir <- tempfile()
  utils::unzip(out, exdir = dir)
  s1 <- .sd_slide_xml(dir, 1)
  s2 <- .sd_slide_xml(dir, 2)
  # two logos on the title slide, at their places, behind the title
  expect_identical(lengths(regmatches(s1, gregexpr("<p:pic>", s1, fixed = TRUE))), 2L)
  expect_lt(max(gregexpr("<p:pic>", s1, fixed = TRUE)[[1]]), regexpr("Cover", s1, fixed = TRUE))
  emu <- function(v) format(round(v * 914400), scientific = FALSE, trim = TRUE)
  first <- Filter(function(x) identical(x$type, "image"), design$slide_designs$title$decor)[[1]]
  expect_match(s1, sprintf('<a:off x="%s" y="%s"/>', emu(first$x), emu(first$y)), fixed = TRUE)
  # the green band on the content slide, behind its title
  expect_match(s2, '<a:srgbClr val="4EA72E"/>', fixed = TRUE)
  expect_lt(regexpr("4EA72E", s2, fixed = TRUE), regexpr("Inside", s2, fixed = TRUE))
  expect_false(grepl("<p:pic>", s2, fixed = TRUE))
  # officer reads the file back
  x <- officer::read_pptx(out)
  expect_identical(length(x), 2L)
  expect_true(nrow(officer::slide_summary(x, 1)) >= 3)
  expect_true(all(file.exists(logos)))
})

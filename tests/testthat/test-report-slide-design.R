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
  suppressWarnings(export_deck(cd_report_context(.sd_cache()), deck, out, "pptx"))
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

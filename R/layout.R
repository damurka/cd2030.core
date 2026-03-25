#' Create custom multi-column layout functions for officedown
#'
#' Generates a pair of functions (`start` and `stop`) that inject
#' continuous section breaks into a Word document while preserving
#' custom page dimensions and margins. This bypasses the strict A4
#' defaults introduced in officer 0.6.10+.
#'
#' @param width Page width in inches.
#' @param height Page height in inches.
#' @param orient Page orientation ("portrait" or "landscape").
#' @param margins Numeric vector of length 4: c(bottom, top, right, left).
#'
#' @return A list containing two functions: `start()` and `stop(widths, space, sep)`.
#' @export
cd_multicol_factory <- function(width, height, orient = "portrait", margins = c(0.5, 0.5, 0.5, 0.5)) {

  # Generate the static officer objects once
  page_sz <- page_size(width = width, height = height, orient = orient)
  page_mar <- page_mar(
    bottom = margins[1],
    top    = margins[2],
    right  = margins[3],
    left   = margins[4],
    gutter = 0
  )

  # Return the pre-configured functions
  list(
    start = function() {
      block_section(
        prop_section(
          type = "continuous",
          page_size = page_sz,
          page_margins = page_mar
        )
      )
    },
    stop = function(widths = c(8, 4), space = 0.2, sep = FALSE) {
      block_section(
        prop_section(
          type = "continuous",
          section_columns = section_columns(widths = widths, space = space, sep = sep),
          page_size = page_sz,
          page_margins = page_mar
        )
      )
    }
  )
}

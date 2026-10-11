# One look for the tables of the package, so they read as one family.
#
# Two kinds of table are drawn. The formatted ones (the overall data quality score, the service utilization data
# quality table, the national health system table) are flextables, the same in the app and in a report:
# .cd_table_style() gives them their header, section rows, lines and alignment, and .cd_table_status() the colours of a
# cell that is judged against a threshold. The data tables of the pages (units with low reporting, with outliers,
# with missing values, the adjustment's changes, the units meeting a target) are reactables: .cd_reactable() gives
# them their options and .cd_table_number() the way a number is written.

.cd_table_colours <- list(
  header = "#F3F4F6",    # the header row
  section = "#E8EEF4",   # a row that opens a section
  line = "#D5DAE1",      # the lines between rows
  strong = "#6B7280",    # the lines above and below the header, and the last line
  note = "#4B5563"       # footnotes
)

# The shared look of a formatted table.
#   ft        a flextable
#   section   a one-sided formula that is TRUE for the rows that open a section (~ !is.na(type)), or NULL
#   base_font the size of the text, in points
#   centre    the columns of figures (centred, header too); the others are left-aligned
.cd_table_style <- function(ft, section = NULL, base_font = 9, centre = NULL) {
  line <- officer::fp_border(color = .cd_table_colours$line, width = 0.75)
  strong <- officer::fp_border(color = .cd_table_colours$strong, width = 1.25)
  ft <- ft %>%
    border_remove() %>%
    font(fontname = "sans", part = "all") %>%
    fontsize(size = base_font, part = "all") %>%
    bg(part = "all", bg = "white") %>%
    bg(part = "header", bg = .cd_table_colours$header) %>%
    bold(part = "header", bold = TRUE) %>%
    align(align = "left", part = "all") %>%
    valign(valign = "center", part = "all") %>%
    padding(padding.top = 3, padding.bottom = 3, padding.left = 5, padding.right = 5, part = "all") %>%
    hline(border = line, part = "body") %>%
    hline_top(border = strong, part = "header") %>%
    hline_bottom(border = strong, part = "header") %>%
    hline_bottom(border = strong, part = "body")
  if (!is.null(centre)) ft <- align(ft, j = centre, align = "center", part = "all")
  if (!is.null(section)) {
    ft <- ft %>%
      bold(i = section, bold = TRUE, part = "body") %>%
      bg(i = section, bg = .cd_table_colours$section, part = "body")
  }
  ft
}

# The colours of the cells judged against a threshold: red below 70, amber from 70 to the threshold, green from
# the threshold (the charts' own three colours), with the text in the colour that reads on each.
.cd_table_status <- function(ft, i, j, threshold) {
  colours <- .cd_palette$traffic_light
  fill <- function(values) {
    vapply(as.list(values), function(v) {
      if (is.null(v) || is.na(v)) "transparent" else if (v >= threshold) colours[[3]] else if (v >= 70) colours[[2]] else colours[[1]]
    }, character(1))
  }
  text <- function(values) {
    filled <- fill(values)
    ifelse(filled == "transparent", "black", .cd_text_on(replace(filled, filled == "transparent", "white")))
  }
  ft %>%
    bg(i = i, j = j, bg = fill, part = "body") %>%
    color(i = i, j = j, color = text, part = "body")
}

# How a data table writes a number: a count whole with its thousands apart ("12,345"); a rate, a coverage or a
# percentage to one decimal; a year or a month as it is; nothing for a missing value.
.cd_table_number <- function(value, name = "") {
  if (is.null(value) || length(value) != 1 || is.na(value)) return("")
  if (!is.numeric(value)) return(value)
  if (name %in% c("year", "month")) return(as.character(value))
  rate <- grepl("^cov_|_rr$|^mis_|^r_|percent|share|rate$", name)
  whole <- !rate && (abs(value - round(value)) < 1e-9 || abs(value) >= 100)
  formatC(value, format = "f", digits = if (whole) 0 else 1, big.mark = ",")
}

# A data table: the same options on every page. `sortable` and `paginate` are for the tables that are a fixed
# list of rows (the adjustment's changes, one row a year).
.cd_reactable <- function(data, columns = list(), sortable = TRUE, paginate = NULL, ...) {
  rows <- NROW(data)
  paginate <- paginate %||% (rows > 10)
  reactable(
    data,
    columns = columns,
    compact = TRUE,
    highlight = TRUE,
    sortable = sortable,
    resizable = TRUE,
    pagination = paginate,
    defaultPageSize = 10,
    showPageSizeOptions = paginate && rows > 10,
    pageSizeOptions = c(10, 25, 50, 100),
    defaultColDef = colDef(
      minWidth = 110, # keeps a name from breaking mid-word; a wide table scrolls sideways instead
      cell = function(value, index, name) .cd_table_number(value, name)
    ),
    ...
  )
}

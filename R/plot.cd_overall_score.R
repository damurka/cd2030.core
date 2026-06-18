#' Plot S3 method for Overall Score
#'
#' @param x The score dataframe (class cs_overall_score)
#' @param years Vector of years to display
#' @param title (Optional) Custom title for the table
#' @param width (Optional) Total width in inches. If NULL, autofit is used.
#' @param ... Additional arguments
#'
#' @export
plot.cd_overall_score <- function(x, years = NULL, title = NULL, width = NULL, ...) {
  if (!is_integerish(years)) {
    cd_abort(c("x" = "{.arg years} cannot be null"))
  }
  threshold <- attr_or_abort(x, "threshold")
  main_title <- title %||% "Data Quality Metrics"

  num_years <- length(years)

  base_font <- if (!is.null(width) && width < 5) {
    8
  } else {
    9
  }

  ft <- x %>%
    as_grouped_data(groups = "type") %>%
    as_flextable() %>%
    font(fontname = "sans", part = "all") %>%
    fontsize(size = base_font, part = "all") %>%
    bg(part = "all", bg = "white") %>%
    set_header_labels(no = "", `Data Quality Metrics` = main_title) %>%
    compose(
      i = ~ !is.na(type),
      j = 1,
      value = as_paragraph(as_chunk(type))
    ) %>%
    bold(j = 1, i = ~ !is.na(type), bold = TRUE, part = "body") %>%
    bg(i = ~ !is.na(type), part = "body", bg = "lightgoldenrodyellow") %>%
    bold(i = ~ is.na(type) & no == "4", bold = TRUE, part = "body") %>%
    bg(i = ~ is.na(type) & no == "4", part = "body", bg = "lightgoldenrodyellow") %>%
    bold(part = "header", bold = TRUE) %>%
    colformat_double(i = ~ is.na(type) & !no %in% c("3a", "3b"), j = as.character(years), digits = 0, big.mark = ",") %>%
    colformat_double(i = ~ is.na(type) & no %in% c("3a", "3b"), j = as.character(years), digits = 2) %>%
    bg(
      i = ~ is.na(type) & !no %in% c("3a", "3b"),
      j = as.character(years),
      bg = function(x) {
        result <- map_chr(as.list(x), ~ {
          if (is.na(.x) || is.null(.x)) {
            return("transparent")
          } else if (.x >= threshold) {
            return("seagreen")
          } else if (.x >= 70 && .x < threshold) {
            return("yellow")
          } else if (.x < 70) {
            return("red")
          } else {
            return("transparent")
          }
        })
        return(result)
      },
      part = "body"
    ) %>%
    theme_vanilla()

  if (!is.null(width)) {
    if (width < 5) {
      w_col1 <- 0.25
      w_year <- 0.25
    } else {
      w_col1 <- 0.40
      w_year <- 0.55
    }

    # Calculate remaining width for the text description column
    w_col2 <- max(1.0, width - w_col1 - (num_years * w_year))

    ft <- ft %>%
      width(j = 1, width = w_col1) %>%
      width(j = 2, width = w_col2) %>%
      width(j = as.character(years), width = w_year) %>%
      set_table_properties(layout = "fixed")
  } else {
    # FOR HTML/WEB: Let the browser organically size the columns
    ft <- ft %>%
      autofit()
  }

  return(ft)
}

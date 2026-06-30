#' Plot S3 method for Service DQA Summary
#'
#' @param x The score dataframe (needs class 'cd_utilization_dqa')
#' @param years Vector of years to display (e.g., 2020:2024)
#' @param title (Optional) Custom title for the table
#' @param width (Optional) Total width in inches. If NULL, autofit is used.
#' @param ... Additional arguments
#'
#' @export
plot.cd_utilization_dqa <- function(x, years = NULL, title = NULL, width = NULL, ...) {
  if (is.null(years) || !is.numeric(years)) {
    cd_abort(c("x" = "{.arg years} cannot be null"))
  }
  
  # Allow overriding threshold from object attributes if it exists
  threshold <- attr_or_abort(x, "threshold")
  
  main_title <- if (!is.null(title)) title else "Service Utilization DQA"
  num_years <- length(years)
  
  base_font <- if (!is.null(width) && width < 5) 8 else 9
  
  ft <- x %>%
    # Group by the 'header' column created in the previous function
    as_grouped_data(groups = "header") %>%
    as_flextable() %>%
    font(fontname = "sans", part = "all") %>%
    fontsize(size = base_font, part = "all") %>%
    bg(part = "all", bg = "white") %>%
    # Update column mapping to match new column names
    set_header_labels(no = "", indicator_label = main_title) %>%
    compose(
      i = ~ !is.na(header),
      j = 1,
      value = as_paragraph(as_chunk(header))
    ) %>%
    # Format the section header rows
    bold(j = 1, i = ~ !is.na(header), bold = TRUE, part = "body") %>%
    bg(i = ~ !is.na(header), part = "body", bg = "lightgoldenrodyellow") %>%
    bold(part = "header", bold = TRUE) %>%
    
    # FORMATTING NUMBERS: 
    # percentages (0 digits) apply to all rows EXCEPT 3a (the ratio)
    colformat_double(
      i = ~ is.na(header) & no != "3a", 
      j = as.character(years), digits = 0, big.mark = ","
    ) %>%
    # ratios (2 digits) apply ONLY to 3a
    colformat_double(
      i = ~ is.na(header) & no == "3a", 
      j = as.character(years), digits = 2
    ) %>%
    
    # CONDITIONAL COLORING
    # Applied to all rows except 3a
    bg(
      i = ~ is.na(header) & !no %in% c("3a", '3b', '3c'),
      j = as.character(years),
      bg = function(val) {
        result <- map_chr(as.list(val), ~ {
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
    theme_vanilla() %>%
    add_footer_lines("Reference: \u25CB 3a 16-47   \u25CB 3b and 3c 15 - 45%") %>%
    fontsize(size = base_font - 1, part = "footer") %>%
    italic(part = "footer") %>%
    color(color = "gray30", part = "footer")
  
  # WIDTH SIZING LOGIC
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
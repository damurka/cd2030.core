#' Plot S3 method for service DQA summary
#'
#' Draws the service utilization data quality summary as a formatted table, with the indicators
#' grouped by section and a column for each year. Completeness and outlier percentages are shaded
#' green at or above the threshold stored with the summary, yellow from 70 up to the threshold and
#' red below 70.
#'
#' @param x The score dataframe (needs class 'cd_utilization_dqa'), as returned by
#'   [generate_service_dqa_summary()].
#' @param years Vector of years to display (e.g., 2020:2024). Required.
#' @param title (Optional) Custom title for the table
#' @param width (Optional) Total width in inches. If NULL, autofit is used.
#' @param ... Additional arguments
#'
#' @param options (Optional) A [cd_chart_options()] object: text, legend, fonts and sizes a user changed. Applied last, so it wins over the
#'   arguments above; the plot's own defaults are used for whatever it does not set. Any chart option can also be given by name in `...`.
#'
#' @return A `flextable` object (from the flextable package), not a ggplot. Chart options change
#'   ggplots only, so `options` has no effect on this table.
#'
#' @examples
#' cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#' cache$adjust_data()
#' dqa <- cache$calculate_service_dqa_summary("national")
#'
#' plot(dqa, years = cache$data_years)
#' plot(dqa, years = 2021:2023, title = "Quality of OPD and IPD data", width = 7)
#'
#' @export
plot.cd_utilization_dqa <- function(x, years = NULL, title = NULL, width = NULL, ..., options = NULL) {
  cd_finish_plot(.plot_cd_utilization_dqa_impl(x, years = years, title = title, width = width, ...), options, ..., .source = x)
}

.plot_cd_utilization_dqa_impl <- function(x, years = NULL, title = NULL, width = NULL, ...) {
  # by default every year the table has a column for
  if (is.null(years)) years <- as.integer(grep("^[0-9]{4}$", names(x), value = TRUE))
  if (!length(years) || !is.numeric(years)) {
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
    # Update column mapping to match new column names
    set_header_labels(no = "", indicator_label = main_title) %>%
    compose(
      i = ~ !is.na(header),
      j = 1,
      value = as_paragraph(as_chunk(header))
    ) %>%
    # Format the section header rows
    .cd_table_style(section = ~ !is.na(header), base_font = base_font, centre = as.character(years)) %>%
    
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
    .cd_table_status(i = ~ is.na(header) & !no %in% c("3a", '3b', '3c'), j = as.character(years), threshold = threshold) %>%
    add_footer_lines("Reference: \u25CB 3a 16-47   \u25CB 3b and 3c 15 - 45%") %>%
    fontsize(size = base_font - 1, part = "footer") %>%
    italic(part = "footer") %>%
    color(color = .cd_table_colours$note, part = "footer")
  
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
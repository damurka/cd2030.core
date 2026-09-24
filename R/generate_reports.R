#' Generate and Export Checks Report
#'
#' The `generate_report` function generates the final report based on a
#' specified dataset and parameters. The report is rendered using an RMarkdown
#' template and can be output in either Word, pdf of html formats.
#'
#' @param cache A data of class `CacheConnection`.
#' @param output_file A character string specifying the name and path of the output file.
#' @param report_name The name of report to generate
#' @param output_format A character vector specifying the output format, either
#'   `'html_document'` or `'officedown::rdocx_document'`.
#' @param use_chart_options If `TRUE` (the default) the chart options saved for reports in the cache are applied to the
#'   report's charts: the dataset-wide ones (`cache$set_chart_options("default", ...)`), then those saved for each type of
#'   graph (`"report/<cd_chart_type()>"`, set from the app's customize panel with *Report* or *Both*). Options a report
#'   template passes to a plot itself win.
#'
#' @return The function renders the report to the specified file in the chosen format.
#'
#' @examples
#' \dontrun{
#' # Generate a report for the dataset 'data' in Word format with a threshold of 85%
#' checks_report(data,
#'   output_file = "data_quality_report.docx",
#'   output_format = "word_document", threshold = 85
#' )
#' }
#' @export
generate_report <- function(cache,
                            output_file,
                            report_name,
                            adminlevel_1 = NULL,
                            i18n = NULL,
                            # language = NULL,
                            output_format = c("word_document", "pdf_document", "html_document"),
                            use_chart_options = TRUE) {
  # check_cd_data(.data)
  check_required(cache)
  check_required(output_file)
  check_required(report_name)

  format <- arg_match(output_format)
  format <- switch(format,
    word_document = "officedown::rdocx_document",
    format
  )

  # If output_file is just a file name, save it in the working directory
  if (!dirname(output_file) %in% c(".", "")) {
    output_path <- output_file # Use full path if provided
  } else {
    output_path <- file.path(getwd(), output_file) # Default to working directory
  }

  # Create a unique temporary directory for rendering
  temp_dir <- tempfile("report_render_")
  dir.create(temp_dir)

  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  analysis_type <- get_selected_group()

  i18n_func <- if (is.null(i18n)) {
    list(
      t = function(text, ...) { text }
    )
  } else {
    i18n
  }

  # if (!is.null(language)) {
  #   language <- arg_match(language, c('en', 'fr', 'pt'))
  # }

  # language <- language %||% cache$language
  language <- cache$language
  language_prefix <- switch(
    language,
    en = '',
    fr = '_fr',
    pt = '_pt'
  )

  # every chart drawn while the report renders starts from the options saved for reports: the dataset-wide ones, then those
  # saved for its type of graph (cache$set_chart_options("report/<cd_chart_type()>", ...), from the app's customize panel)
  if (isTRUE(use_chart_options)) {
    saved <- cache$chart_options
    types <- saved[startsWith(names(saved), "report/")]
    names(types) <- sub("^report/", "", names(types))
    old_options <- options(cd2030.report_chart_options = list(default = cache$get_chart_options("default"), types = types))
    on.exit(options(old_options), add = TRUE)
  }

  # Open the generated file automatically
  tryCatch(
    {
      render(
        input = file.path(system.file(package = "cd2030.core"), "rmd", paste0(report_name, language_prefix, "_", analysis_type, "_template.Rmd")),
        output_format = format,
        output_file = output_path,
        params = list(cache = cache, country = cache$country, adminlevel_1 = adminlevel_1, i18n = i18n_func),
        encoding = "UTF-8",
        runtime = "auto",
        intermediates_dir = temp_dir, # Set unique temp directory
        clean = TRUE # Clean up intermediate files
      )
      
      check_file_path(output_path)
      if (format == "html_document") {
        utils::browseURL(output_path)
      }
      # showNotification("Report generation Succeeded.", type = "message")
      cd_info(c('i' = 'Report generation Succeeded.'))
    },
    error = function(e) {
      error <- clean_error_message(e)
      # showNotification(paste0("Report generation failed: ", error), type = "error")
      cd_abort(c('x' = paste0("Report generation failed: ", error)))
    }
  )
}

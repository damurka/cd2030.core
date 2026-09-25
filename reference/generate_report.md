# Generate and Export Checks Report

The `generate_report` function generates the final report based on a
specified dataset and parameters. The report is rendered using an
RMarkdown template and can be output in either Word, pdf of html
formats.

## Usage

``` r
generate_report(
  cache,
  output_file,
  report_name,
  adminlevel_1 = NULL,
  output_format = c("word_document", "pdf_document", "html_document")
)
```

## Arguments

- cache:

  A data of class `CacheConnection`.

- output_file:

  A character string specifying the name and path of the output file.

- report_name:

  The name of report to generate

- output_format:

  A character vector specifying the output format, either
  `'html_document'` or `'officedown::rdocx_document'`.

## Value

The function renders the report to the specified file in the chosen
format.

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate a report for the dataset 'data' in Word format with a threshold of 85%
checks_report(data,
  output_file = "data_quality_report.docx",
  output_format = "word_document", threshold = 85
)
} # }
```

# Writes the data dictionary (cd_dictionary()) as the DataSuite docs' Reference page "Data dictionary" (MDX):
# what the ids and column names in the Countdown apps' data mean -- denominators, naming rules, target populations,
# indicators, reporting rates and fixed columns.
#
# Usage (with cd2030.core installed):
#
#   Rscript export-data-dictionary.R <output.mdx>
#   Rscript "$(Rscript -e 'cat(system.file("scripts", "export-data-dictionary.R", package = "cd2030.core"))')" \
#     docs-site/src/content/en/docs/reference/data-dictionary.mdx
#
# The page is generated: edit the dictionary in cd2030.core (R/data-dictionary.R), not the page.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript export-data-dictionary.R <output.mdx>", call. = FALSE)
}
out <- args[[1]]

d <- cd2030.core::cd_dictionary()
version <- as.character(utils::packageVersion("cd2030.core"))

# a Markdown table; `code` columns are shown as code, pipes escaped
md_table <- function(df, headers, code = character()) {
  cell <- function(x, col) {
    x <- ifelse(is.na(x), "", as.character(x))
    x <- gsub("|", "\\|", x, fixed = TRUE)
    if (col %in% code) return(ifelse(nzchar(x), paste0("`", x, "`"), x))
    # MDX reads <...> as a tag and {...} as an expression: in plain text they are entities
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    x <- gsub(">", "&gt;", x, fixed = TRUE)
    x <- gsub("{", "&#123;", x, fixed = TRUE)
    gsub("}", "&#125;", x, fixed = TRUE)
  }
  body <- vapply(seq_len(nrow(df)), function(i) {
    paste0("| ", paste(vapply(names(headers), function(col) cell(df[[col]][[i]], col), ""), collapse = " | "), " |")
  }, "")
  c(paste0("| ", paste(unname(headers), collapse = " | "), " |"),
    paste0("|", paste(rep(" --- ", length(headers)), collapse = "|"), "|"),
    body)
}

indicators <- d$indicators
indicators$kind <- ifelse(indicators$computed, "computed", "reported")

lines <- c(
  "---",
  "description: What the ids and column names in the Countdown apps' data mean -- the six denominator options, how column names are built, the target populations, indicators and reporting rates.",
  "title: Data dictionary",
  "---",
  "",
  paste0("{/* Generated from cd2030.core ", version, " (cd_dictionary()) by inst/scripts/export-data-dictionary.R. Edit the dictionary in cd2030.core, not this page. */}"),
  "",
  "# Data dictionary",
  "",
  "The apps' data names things with short ids -- an indicator (`penta1`), a denominator option (`anc1derived`), a target population (`totinftpenta`) -- combined into column names such as `cov_penta3_penta1derived`. This page says what each part means. Read the meaning here rather than from the spelling: **`anc1` and `penta1` are the ANC1-derived and Penta1-derived denominators, while `anc1derived` and `penta1derived` are the population-growth options.**",
  "",
  paste0("Generated from cd2030.core ", version, ". In R, `cd2030.core::cd_dictionary()` returns these tables and `cd2030.core::cd_describe_columns()` reads column names with them."),
  "",
  "## Denominators",
  "",
  "The six denominator options ([Denominator assessment and selection](/en/docs/methodology/denominators)).",
  "",
  md_table(d$denominators, c(id = "Id", label = "Label", meaning = "What it is", levels = "Levels"), code = "id"),
  "",
  "## How column names are built",
  "",
  md_table(d$grammar, c(pattern = "Pattern", meaning = "Meaning", example = "Example"), code = c("pattern", "example")),
  "",
  "## Target populations",
  "",
  "In thousands: coverage = 100 x count / (population x 1000).",
  "",
  md_table(d$populations, c(id = "Id", label = "Label", meaning = "What it is"), code = "id"),
  "",
  "## Indicators",
  "",
  "An indicator's id is also the column of its monthly count; `computed` indicators are calculated from the counts.",
  "",
  md_table(indicators, c(id = "Id", label = "Label", group = "Group", kind = "Reported or computed"), code = "id"),
  "",
  "## Reporting rates",
  "",
  md_table(d$reporting_rates, c(id = "Id", meaning = "Meaning"), code = "id"),
  "",
  "## Other columns",
  "",
  md_table(d$columns, c(id = "Column", meaning = "Meaning"), code = "id"),
  ""
)

writeLines(lines, out, useBytes = TRUE)
cat("Wrote", out, "\n")

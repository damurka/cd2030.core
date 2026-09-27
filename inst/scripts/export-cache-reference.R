# Writes the CacheConnection definitions (cache_definition()) as the DataSuite docs' Reference page
# "CacheConnection reference" (MDX): what each data point of a Countdown dataset is -- its grain and unit, its default,
# where it is set and shown in the app, what it is computed from and the methodology section it comes from.
#
# Usage (with cd2030.core installed):
#
#   Rscript export-cache-reference.R <output.mdx>
#   Rscript "$(Rscript -e 'cat(system.file("scripts", "export-cache-reference.R", package = "cd2030.core"))')" \
#     docs-site/src/content/en/docs/reference/cache-connection.mdx
#
# The page is generated: edit the definitions in cd2030.core (R/cache-definitions.R), not the page.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript export-cache-reference.R <output.mdx>", call. = FALSE)
}
out <- args[[1]]

defs <- cd2030.core::cache_definition()
defaults <- cd2030.core::cd_methodology_defaults()
version <- as.character(utils::packageVersion("cd2030.core"))

# MDX reads <...> as a tag and {...} as an expression: in plain text they are entities; pipes are escaped for tables
plain <- function(x) {
  x <- gsub("|", "\\|", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("{", "&#123;", x, fixed = TRUE)
  x <- gsub("}", "&#125;", x, fixed = TRUE)
  gsub("\n", " ", x, fixed = TRUE)
}
join <- function(x) if (length(x)) paste(x, collapse = ", ") else ""
code <- function(x) if (length(x)) paste0("`", x, "`", collapse = ", ") else ""

# a default given as a methodology-defaults id: its value and unit, as the Defaults page shows them
default_text <- function(id) {
  if (is.null(id) || !length(id)) return("")
  vapply(id, function(i) {
    row <- defaults[defaults$id == i, , drop = FALSE]
    if (!nrow(row)) return(paste0("`", i, "`"))
    value <- if ("value" %in% names(row)) paste(unlist(row$value[[1]]), collapse = ", ") else ""
    unit <- if ("unit" %in% names(row) && !is.na(row$unit[[1]])) paste0(" ", row$unit[[1]]) else ""
    paste0(value, unit, " (`", i, "`)")
  }, "") |> paste(collapse = "; ")
}

method_link <- function(url) {
  if (is.null(url) || !nzchar(url)) return("")
  section <- sub("^.*#", "", url)
  page <- sub("/?#.*$", "", sub("^.*/methodology/", "", url))
  label <- if (grepl("#", url, fixed = TRUE)) paste0(page, ": ", gsub("-", " ", section)) else page
  sprintf("[%s](%s)", label, url)
}

row_of <- function(name, d) {
  cells <- c(
    paste0("`", name, "`", if (identical(d$status, "draft")) " (draft)" else ""),
    plain(d$what %||% ""),
    plain(join(c(d$grain, if (length(d$unit)) paste0("unit: ", d$unit)))),
    plain(default_text(d$default)),
    plain(join(c(if (length(d$set_on)) paste0("set on ", join(d$set_on)), if (length(d$shown_on)) paste0("shown on ", join(d$shown_on))))),
    code(d$depends_on),
    method_link(d$method)
  )
  paste0("| ", paste(cells, collapse = " | "), " |")
}
`%||%` <- function(a, b) if (is.null(a)) b else a

sections <- list(
  list(kinds = "data", title = "Data", intro = "Tables the analysis produces or starts from. Their columns are explained in the [Data dictionary](/en/docs/reference/data-dictionary/)."),
  list(kinds = "method", title = "Calculations", intro = "Functions that compute a result for the options given (indicator, level, denominator, years)."),
  list(kinds = c("setting", "value"), title = "Settings and values", intro = "Choices and numbers the analysis uses, with their defaults (see [Defaults and thresholds](/en/docs/reference/defaults/))."),
  list(kinds = c("reference", "mapping"), title = "Reference data and mappings", intro = "Estimates, surveys, shapes and the name matching that connect them to the dataset."),
  list(kinds = c("state", "store", "check"), title = "State, stores and checks", intro = "What the dataset records about itself: saved reports and graphs, revision, checks.")
)
header <- c("| Member | What it is | Grain / unit | Default | In the app | Computed from | Methodology |",
            "| --- | --- | --- | --- | --- | --- | --- |")

kinds <- vapply(defs, function(d) d$kind %||% "", "")
lines <- c(
  "---",
  "description: Every data point of a Countdown dataset (the cd2030.core CacheConnection) -- what it is, its grain and unit, its default, where it is set and shown in the app, and the methodology section it comes from.",
  "title: CacheConnection reference",
  "---",
  "",
  paste0("{/* Generated from cd2030.core ", version, " (cache_definition()) by inst/scripts/export-cache-reference.R. Edit the definitions in cd2030.core, not this page. */}"),
  "",
  "# CacheConnection reference",
  "",
  "A Countdown dataset (the `.rds` file the RMNCAH and Vaxx apps save) is a `CacheConnection`: the data, the choices made on each page and everything computed from them. This page defines each of its data points. The Countdown AI reads the same definitions.",
  "",
  paste0("Generated from cd2030.core ", version, ". In R, `cd2030.core::cache_definition(\"adjusted_data\")` returns one definition; `cache_manifest()` lists every member with its arguments. Members marked *draft* are not yet fully described.")
)
for (s in sections) {
  names_in <- sort(names(defs)[kinds %in% s$kinds])
  if (!length(names_in)) next
  lines <- c(lines, "", paste0("## ", s$title), "", s$intro, "", header,
             vapply(names_in, function(n) row_of(n, defs[[n]]), ""))
}
actions <- sort(names(defs)[kinds == "action"])
if (length(actions)) {
  lines <- c(lines, "", "## Changing a value", "",
             "Each of these sets or clears the member it names (in the app, the page's control does it):", "",
             paste0("- ", vapply(actions, function(n) {
               d <- defs[[n]]
               paste0("`", n, "`", if (length(d$depends_on)) paste0(" -- changes ", code(d$depends_on)) else "")
             }, "")))
}

dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
writeLines(lines, out, useBytes = TRUE)
cat("Wrote", out, "(", length(defs), "members )\n")

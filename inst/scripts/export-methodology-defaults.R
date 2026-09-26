# Writes the constants of the Countdown methodology (cd_methodology_defaults()) as the JSON the DataSuite docs read:
#
#   { "package": "cd2030.core", "version": "...", "generatedAt": "...", "entries": [ { id, step, group, value, unit,
#     label, note, source }, ... ] }
#
# Usage (with cd2030.core and jsonlite installed):
#
#   Rscript export-methodology-defaults.R <output.json>
#   Rscript "$(Rscript -e 'cat(system.file("scripts", "export-methodology-defaults.R", package = "cd2030.core"))')" \
#     datasuite-docs/src/data/methodology-defaults.json
#
# The docs keep the file at src/data/methodology-defaults.json; .github/workflows/ai-guide-sync.yml regenerates it
# on every release and opens a pull request on the docs.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript export-methodology-defaults.R <output.json>", call. = FALSE)
}
out <- args[[1]]

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("The jsonlite package is needed to write the JSON.", call. = FALSE)
}

defaults <- cd2030.core::cd_methodology_defaults("all")

entries <- lapply(seq_len(nrow(defaults)), function(i) {
  list(
    id = defaults$id[[i]],
    step = defaults$step[[i]],
    group = defaults$group[[i]],
    # a single value is written as a scalar (auto_unbox), several as an array
    value = unname(defaults$value[[i]]),
    unit = defaults$unit[[i]],
    label = defaults$label[[i]],
    note = defaults$note[[i]],
    source = defaults$source[[i]]
  )
})

doc <- list(
  package = "cd2030.core",
  version = as.character(utils::packageVersion("cd2030.core")),
  generatedAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  entries = entries
)

dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
json <- jsonlite::toJSON(doc, auto_unbox = TRUE, pretty = TRUE, digits = NA, null = "null")
# binary mode: LF line endings on every platform
con <- file(out, open = "wb")
writeLines(json, con, useBytes = TRUE)
close(con)
message("Wrote ", length(entries), " entries to ", out)

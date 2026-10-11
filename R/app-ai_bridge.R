# What the Countdown apps add to datasuite.ui's AI bridge (datasuite.ui's docs/AI-BRIDGE.md, protocol 2): the filters in
# effect on the page the user is on and the dataset (path, country, revision), and the actions setFilters, saveReport,
# addGraph, generateReport, listReports, readReport and updateBlocks. cd_app() passes these to app_frame(). Data questions don't come through here: the AI
# reads the dataset in its own R session (countdown-analytics/docs/AI-PLAN.md); what it adds to the dataset does, so
# the app's own CacheConnection is the one that saves.
#
# The filters are the shared filter chips (R/filter-*.R) inside each page's modules, so their input ids are the page
# id, the module path and the chip's own id: "<page>-...-admin", "-region", "-years", "-indicator", "-denominator". The
# current page's are found by that shape in the session's inputs.

#' The filters the AI can read and set
#'
#' A named character vector. The names are the filters as the AI knows them, and the values are the
#' input ids of the filter chips that hold them.
#'
#' @noRd
.cd_ai_filter_names <- c(admin_level = "admin", region = "region", years = "years", indicator = "indicator",
                         denominator = "denominator")

#' Input ids of one kind of filter chip on a page
#'
#' @param input_names The names of the session's inputs.
#' @param page The page's id.
#' @param chip The chip's own input id, for example `"years"`.
#' @return A sorted character vector of the input ids on `page` that end with `chip`. It is empty
#'   when there are none, or when `page` is `NULL` or empty.
#' @noRd
.cd_ai_filter_ids <- function(input_names, page, chip) {
  if (is.null(page) || !nzchar(page)) return(character(0))
  pattern <- paste0("^", gsub("([.])", "\\\\\\1", page), "-(.+-)?", chip, "$")
  sort(grep(pattern, input_names, value = TRUE))
}

#' Filters in effect on a page
#'
#' Reads one value for each kind of filter, from the first chip of that kind on the page.
#'
#' @param values The session's inputs as a named list.
#' @param page The page's id.
#' @return A named list with an entry for each filter that has a value (see `.cd_ai_filter_names`),
#'   or `NULL` when there is none. Years are integers. An empty years chip means every year and is
#'   left out.
#' @noRd
.cd_ai_filters <- function(values, page) {
  out <- list()
  for (name in names(.cd_ai_filter_names)) {
    ids <- .cd_ai_filter_ids(names(values), page, .cd_ai_filter_names[[name]])
    if (!length(ids)) next
    value <- values[[ids[[1]]]]
    if (name == "years") {
      value <- suppressWarnings(as.integer(unlist(strsplit(paste(value, collapse = ","), ","))))
      value <- value[!is.na(value)]
      if (!length(value)) value <- NULL
    }
    if (!is.null(value) && !(is.character(value) && length(value) == 1 && !nzchar(value))) out[[name]] <- value
  }
  if (length(out)) out else NULL
}

#' What a Countdown app adds to the state the AI reads
#'
#' `cd_app()` passes it to `app_frame(ai_state = )`. It reads the dataset from
#' `session$userData$cd_cache`, where `app_frame()` keeps the dataset reactive.
#'
#' @param session The app's Shiny session.
#' @return A named list with `filters` (see `.cd_ai_filters()`) and `dataset` (its `path`,
#'   `country`, `revision` and whether it is `adjusted`). An element with nothing to say is left
#'   out.
#' @noRd
.cd_ai_state <- function(session) {
    input <- session$input
    page <- input$tabs
    values <- shiny::reactiveValuesToList(input)
    cache <- session$userData$cd_cache
    ds <- if (is.null(cache)) NULL else tryCatch(cache(), error = function(e) NULL)
    dataset <- if (!is.null(ds)) {
      Filter(Negate(is.null), list(
        path = tryCatch(ds$cache_path, error = function(e) NULL),
        country = tryCatch(ds$country, error = function(e) NULL),
        revision = tryCatch(ds$revision, error = function(e) NULL),
        adjusted = isTRUE(tryCatch(ds$adjusted_flag, error = function(e) FALSE))
      ))
    }
    Filter(Negate(is.null), list(filters = .cd_ai_filters(values, page), dataset = dataset))
}

#' Say what a chart or table is, for the AI
#'
#' Makes the `about` of a chart or table on a Countdown page: the report kind it matches and its
#' options as the report builder names them.
#'
#' @param kind The report kind the chart or table matches, or `NULL` when none does.
#' @param ... The options, named as the report builder names them (`indicator`, `admin_level`,
#'   `region`, `year`, `variant`). Each is a value or a reactive. Each is read on its own, so one
#'   that is not ready yet, or is `NULL` or an empty string, is left out.
#' @return A function with no arguments that returns `list(kind = , options = )`, without `kind`
#'   when it is `NULL`. The options are read only when the function is called, which is when the AI
#'   asks.
#' @noRd
.cd_about <- function(kind, ...) {
  options <- list(...)
  function() {
    values <- lapply(options, function(v) {
      value <- if (is.function(v)) tryCatch(shiny::isolate(v()), error = function(e) NULL) else v
      if (is.null(value) || (is.character(value) && length(value) == 1 && !nzchar(value))) NULL else value
    })
    values <- Filter(Negate(is.null), values)
    about <- list(options = if (length(values)) values else structure(list(), names = character(0)))
    if (!is.null(kind)) about <- c(list(kind = kind), about)
    about
  }
}

#' The dataset the app has open
#'
#' @param session The app's Shiny session.
#' @return The dataset, a [CacheConnection]. Stops with a message for the AI when no dataset with
#'   Countdown data is loaded.
#' @noRd
.cd_ai_cache <- function(session) {
  cache <- session$userData$cd_cache
  ds <- if (is.null(cache)) NULL else tryCatch(shiny::isolate(cache()), error = function(e) NULL)
  if (is.null(ds) || is.null(tryCatch(ds$countdown_data, error = function(e) NULL))) {
    stop("No dataset is loaded in the app yet.", call. = FALSE)
  }
  ds
}

#' Report kinds of this app's indicator group
#'
#' The group is `getOption("cd2030.app_group")`, or the selected group when that option is not set.
#'
#' @return A character vector of report kind names.
#' @noRd
.cd_ai_kinds <- function() names(report_block_kinds(getOption("cd2030.app_group", get_selected_group())))

#' A new id for something the AI adds
#'
#' @param prefix The start of the id, for example `"ai-report-"`.
#' @param existing The ids already in use.
#' @return `prefix` followed by a number, an id that is not in `existing`.
#' @noRd
.cd_ai_new_id <- function(prefix, existing) {
  i <- length(existing) + 1L
  while (paste0(prefix, i) %in% existing) i <- i + 1L
  paste0(prefix, i)
}

#' A file name from a report's name
#'
#' @param name The report's name, or `NULL`.
#' @return The name with every run of characters other than letters, digits, `_` and `-` turned into
#'   one `_`, without `_` at either end, cut to 60 characters. `"report"` when `name` is `NULL` or
#'   nothing is left. It has no extension.
#' @noRd
.cd_ai_file_stem <- function(name) {
  stem <- gsub("[^A-Za-z0-9_-]+", "_", name %||% "report")
  stem <- gsub("^_+|_+$", "", stem)
  if (!nzchar(stem)) "report" else substr(stem, 1, 60)
}

#' The actions a Countdown app gives the AI
#'
#' `cd_app()` passes them to `app_frame(ai_actions = )`. Each has a level that decides whether
#' DataSuite asks the user first (see datasuite.ui's `docs/AI-BRIDGE.md`):
#' * `setFilters` is `"view"`: it changes only what the app shows.
#' * `saveReport`, `addGraph` and `generateReport` are `"add"`, and `"replace"` when a call would
#'   overwrite a saved report, a saved graph or a file.
#' * `listReports` and `readReport` are `"read"`.
#' * `updateBlocks` is `"replace"`: it changes a saved report.
#'
#' @return A list of `ai_action` objects.
#' @noRd
.cd_ai_actions <- function() {
  list(.cd_ai_set_filters(), .cd_ai_save_report(), .cd_ai_add_graph(), .cd_ai_generate_report(), .cd_ai_list_reports(),
       .cd_ai_read_report(), .cd_ai_update_blocks())
}

#' The saveReport action
#'
#' Saves a report the AI wrote in the dataset, where the Reports page shows it. The report is
#' checked first, and the pictures it names are stored in the dataset (see
#' `.cd_ai_store_pictures()`). With the `reportId` of a saved report, the call replaces that report.
#'
#' @return An `ai_action` object. The action answers with the report's `reportId`, its `name` and
#'   its number of `blocks`.
#' @noRd
.cd_ai_save_report <- function() {
  datasuite.ui::ai_action(
    "saveReport",
    function(args, session) {
      ds <- .cd_ai_cache(session)
      project <- args$project
      if (!is.list(project)) stop("Give the report: project = list(name, blocks).", call. = FALSE)
      project$name <- project$name %||% "Report from the AI"
      project$blocks <- .cd_ai_store_pictures(ds, project$blocks)
      project <- datasuite.ui::report_validate_project(project, kinds = .cd_ai_kinds(), members = cd_chartable_members())
      id <- if (is.character(args$reportId) && length(args$reportId) == 1 && nzchar(args$reportId)) args$reportId
            else .cd_ai_new_id("ai-report-", names(ds$report_projects))
      # the report carries its own id, as the builder's reports do (the Reports page saves edits by it)
      project$id <- id
      ds$set_report_project(id, project)
      list(reportId = id, name = project$name, blocks = length(project$blocks))
    },
    kind = "add",
    classify = function(args, session) if (.cd_ai_saved(args$reportId, .cd_ai_cache(session)$report_projects)) "replace" else "add",
    summary = function(args, session) {
      ds <- .cd_ai_cache(session)
      project <- args$project
      what <- sprintf("\"%s\"%s", project$name %||% "Report from the AI", .cd_ai_block_counts(project$blocks))
      if (.cd_ai_saved(args$reportId, ds$report_projects)) {
        sprintf("Replace the saved report \"%s\" with %s in %s", ds$report_projects[[args$reportId]]$name %||% args$reportId,
                what, .cd_ai_dataset_name(ds))
      } else {
        sprintf("Save the report %s in %s", what, .cd_ai_dataset_name(ds))
      }
    },
    description = "Saves a report in the dataset; it opens in the Reports page, where the user can edit and export it.",
    args = list(project = "the report: list(name, blocks), blocks as in the report builder (report kinds, or custom_chart)",
                reportId = "optional: replace this saved report")
  )
}

#' Store the pictures a report's image blocks name
#'
#' An image block may name a figure the AI drew (`path` or `file`: a PNG or JPEG of at most 5 MB
#' that it saved in the dataset's analysis folder, `CDSUITE_SHINY_WORKSPACE_DIR`). The figure is
#' stored in the dataset as a picture, so the report keeps it when the folder is moved or shared. A
#' block that already has a `src` is left as it is.
#'
#' @param ds The dataset, a [CacheConnection].
#' @param blocks The report's blocks, a list.
#' @return `blocks`, where each image block that named a file has lost `path` and `file` and has
#'   `src = "asset:<id>"` and the picture's `ratio`. Stops with a message for the AI when a file
#'   does not exist, is outside the analysis folder, is not a PNG or JPEG, or is too large.
#' @noRd
.cd_ai_store_pictures <- function(ds, blocks) {
  # Only files in the analysis folder are taken, never other files on the computer.
  if (!is.list(blocks)) return(blocks)
  root <- Sys.getenv("CDSUITE_SHINY_WORKSPACE_DIR", unset = "")
  lapply(blocks, function(b) {
    if (!is.list(b) || !identical(b$type, "image") || is.null(b$path %||% b$file)) return(b)
    f <- b$path %||% b$file
    b$path <- NULL
    b$file <- NULL
    if (is.character(b$src) && nzchar(b$src)) return(b)
    if (!is.character(f) || length(f) != 1 || !file.exists(f)) {
      stop(sprintf("The picture %s does not exist.", f), call. = FALSE)
    }
    f <- normalizePath(f, winslash = "/")
    home <- if (nzchar(root)) normalizePath(root, winslash = "/", mustWork = FALSE) else ""
    if (!nzchar(home) || !startsWith(tolower(f), paste0(tolower(home), "/"))) {
      stop("An image block can only use a figure saved in the dataset's analysis folder.", call. = FALSE)
    }
    type <- switch(tolower(tools::file_ext(f)), png = "image/png", jpg = , jpeg = "image/jpeg",
                   stop("An image block needs a PNG or JPEG file.", call. = FALSE))
    if (file.info(f)$size > 5e6) stop("The picture is larger than 5 MB.", call. = FALSE)
    id <- .cd_ai_new_id("ai-picture-", names(ds$report_assets))
    # jsonlite comes with shiny, so it is always installed; it is only in Suggests here
    if (!requireNamespace("jsonlite", quietly = TRUE)) stop("The jsonlite package is needed to store pictures.", call. = FALSE)
    src <- paste0("data:", type, ";base64,", jsonlite::base64_enc(readBin(f, "raw", file.info(f)$size)))
    stored <- datasuite.ui::report_store_asset(ds, id, src)
    b$src <- paste0("asset:", stored$id)
    b$ratio <- b$ratio %||% stored$ratio
    b
  })
}

#' The addGraph action
#'
#' Saves a custom chart the AI specified in the dataset, where a report can use it. The chart's spec
#' is checked and the chart is built once before it is saved, so a chart that cannot be drawn is
#' refused. With the `graphId` of a saved graph, the call replaces that graph.
#'
#' @return An `ai_action` object. The action answers with the chart's `graphId` and the number of
#'   `rows` of its data.
#' @noRd
.cd_ai_add_graph <- function() {
  datasuite.ui::ai_action(
    "addGraph",
    function(args, session) {
      ds <- .cd_ai_cache(session)
      spec <- args$spec
      if (!is.list(spec)) stop("Give the chart: spec = list(title, data, transform, plot).", call. = FALSE)
      spec <- datasuite.ui::report_validate_spec(spec, members = cd_chartable_members())
      # drawn once now, so a chart that can't be drawn is refused rather than saved
      data <- cd_custom_chart_data(ds, spec)
      invisible(ggplot2::ggplot_build(datasuite.ui::report_plot_spec(data, spec$plot, title = spec$title)))
      id <- if (is.character(args$graphId) && length(args$graphId) == 1 && nzchar(args$graphId)) args$graphId
            else .cd_ai_new_id("graph-", names(ds$graphs))
      ds$set_graph(id, spec)
      list(graphId = id, rows = nrow(data))
    },
    kind = "add",
    classify = function(args, session) if (.cd_ai_saved(args$graphId, .cd_ai_cache(session)$graphs)) "replace" else "add",
    summary = function(args, session) {
      ds <- .cd_ai_cache(session)
      title <- args$spec$title %||% "a custom chart"
      if (.cd_ai_saved(args$graphId, ds$graphs)) {
        sprintf("Replace the saved chart \"%s\" with \"%s\" in %s", ds$graphs[[args$graphId]]$title %||% args$graphId, title,
                .cd_ai_dataset_name(ds))
      } else {
        sprintf("Save the chart \"%s\" in %s", title, .cd_ai_dataset_name(ds))
      }
    },
    description = "Saves a custom chart in the dataset; it redraws with the data and can be added to any report (a chart block with kind custom_chart and graph = its id).",
    args = list(spec = "the chart: list(title, data = list(member, args), transform, plot)", graphId = "optional: replace this saved graph")
  )
}

#' The generateReport action
#'
#' Writes a standard report or a saved one to a Word, PowerPoint or PDF file (see
#' `.cd_ai_report_target()` for which report and where). The call is `"replace"` when the file is
#' already there.
#'
#' @return An `ai_action` object. The action answers with the `file` it wrote and its `format`.
#' @noRd
.cd_ai_generate_report <- function() {
  datasuite.ui::ai_action(
    "generateReport",
    function(args, session) {
      ds <- .cd_ai_cache(session)
      target <- .cd_ai_report_target(args, session, ds)
      dir.create(dirname(target$file), recursive = TRUE, showWarnings = FALSE)
      if (target$deck) datasuite.ui::export_deck(ds, target$project, target$file, format = target$format)
      else datasuite.ui::export_report(ds, target$project, target$file, format = target$format)
      list(file = normalizePath(target$file, winslash = "/", mustWork = FALSE), format = target$format)
    },
    kind = "add",
    classify = function(args, session) {
      if (file.exists(.cd_ai_report_target(args, session, .cd_ai_cache(session))$file)) "replace" else "add"
    },
    summary = function(args, session) {
      target <- .cd_ai_report_target(args, session, .cd_ai_cache(session))
      sprintf("Write \"%s\" in %s%s", basename(target$file), dirname(normalizePath(target$file, winslash = "/", mustWork = FALSE)),
              if (file.exists(target$file)) ", replacing the existing file" else "")
    },
    description = "Writes a standard or saved report to a Word, PowerPoint or PDF file in the dataset's working folder.",
    args = list(preset = "a standard report id, e.g. national_coverage", reportId = "or a saved report's id",
                format = "docx or pdf (a document), pptx or pdf (a slide deck)")
  )
}

#' The report generateReport writes, and where
#'
#' The report is the standard report `args$preset`, in the language on screen, or else the saved
#' report `args$reportId`. The file goes in the `reports` folder of the dataset's analysis folder
#' (`CDSUITE_SHINY_WORKSPACE_DIR`), or in the session's temporary folder when there is no analysis
#' folder.
#'
#' @param args The arguments the AI sent: `preset` or `reportId`, and optionally `format`.
#' @param session The app's Shiny session.
#' @param ds The dataset, a [CacheConnection].
#' @return A list: `project` (the report), `deck` (`TRUE` for a slide deck), `format` (`"docx"` or
#'   `"pdf"` for a document, `"pptx"` or `"pdf"` for a deck; by default `"docx"` or `"pptx"`) and
#'   `file` (the path). Stops with a message for the AI when the report does not exist or the format
#'   does not fit it.
#' @noRd
.cd_ai_report_target <- function(args, session, ds) {
  lang <- shiny::isolate(session$input$selected_language) %||% "en"
  project <- NULL
  if (is.character(args$preset) && length(args$preset) == 1) {
    presets <- report_presets(lang, getOption("cd2030.app_group", get_selected_group()))
    project <- presets[[args$preset]]
    if (is.null(project)) stop(sprintf("There is no standard report %s. They are: %s.", dQuote(args$preset, FALSE), paste(names(presets), collapse = ", ")), call. = FALSE)
  } else if (is.character(args$reportId) && length(args$reportId) == 1) {
    project <- ds$report_projects[[args$reportId]]
    if (is.null(project)) stop(sprintf("There is no saved report %s.", dQuote(args$reportId, FALSE)), call. = FALSE)
  } else {
    stop("Say which report: preset (a standard report) or reportId (a saved one).", call. = FALSE)
  }
  deck <- identical(project$kind, "deck")
  format <- args$format %||% (if (deck) "pptx" else "docx")
  allowed <- if (deck) c("pptx", "pdf") else c("docx", "pdf")
  if (!format %in% allowed) stop(sprintf("This report can be written as %s.", paste(allowed, collapse = " or ")), call. = FALSE)
  # reports go in the dataset's analysis folder, reports/ (created when the first one is written)
  dir <- Sys.getenv("CDSUITE_SHINY_WORKSPACE_DIR", unset = "")
  dir <- if (nzchar(dir) && dir.exists(dir)) file.path(dir, "reports") else tempdir()
  list(project = project, deck = deck, format = format, file = file.path(dir, paste0(.cd_ai_file_stem(project$name), ".", format)))
}

# ---- reading and changing a saved report (datasuite.ui's report_list(), report_read(), report_update_blocks()) -----

#' A saved report, by its id
#'
#' @param ds The dataset, a [CacheConnection].
#' @param id The report's id, as the AI gave it.
#' @return The saved report (a list), with `id` set on it. Stops with a message for the AI, naming
#'   the saved reports there are, when `id` is not one string or names no saved report.
#' @noRd
.cd_ai_saved_report <- function(ds, id) {
  if (!is.character(id) || length(id) != 1 || !nzchar(id)) stop("Say which report: reportId, from listReports.", call. = FALSE)
  project <- ds$report_projects[[id]]
  if (!is.list(project)) {
    ids <- names(ds$report_projects)
    stop(sprintf("There is no saved report %s. %s", dQuote(id, FALSE),
                 if (length(ids)) sprintf("The saved reports: %s.", paste(ids, collapse = ", ")) else "The dataset has no saved reports."), call. = FALSE)
  }
  project$id <- id
  project
}

#' The listReports action
#'
#' Lists the reports saved in the dataset, as datasuite.ui's `report_list()` describes them.
#'
#' @return An `ai_action` object.
#' @noRd
.cd_ai_list_reports <- function() {
  datasuite.ui::ai_action(
    "listReports",
    function(args, session) datasuite.ui::report_list(.cd_ai_cache(session)$report_projects),
    kind = "read",
    description = "The reports saved in the dataset (the Reports page): id, name, kind (report or deck), language, number of blocks, last edited."
  )
}

#' The readReport action
#'
#' Gives the AI a saved report's blocks in order, as datasuite.ui's `report_read()` describes them,
#' with a short table of the data each chart and table shows. The AI's `maxRows` sets the rows of
#' each table (25 by default, 100 at most), and `data = FALSE` leaves the data out.
#'
#' @return An `ai_action` object.
#' @noRd
.cd_ai_read_report <- function() {
  datasuite.ui::ai_action(
    "readReport",
    function(args, session) {
      ds <- .cd_ai_cache(session)
      project <- .cd_ai_saved_report(ds, args$reportId)
      max_rows <- suppressWarnings(as.integer(args$maxRows %||% 25))
      if (is.na(max_rows) || max_rows < 1) max_rows <- 25L
      datasuite.ui::report_read(ds, project, id = args$reportId, lang = ds$language %||% "en", data = !isFALSE(args$data),
                                max_rows = min(max_rows, 100L))
    },
    kind = "read",
    description = "A saved report's blocks in order (id, type; the text of headings, paragraphs and notes; each chart's and table's kind, settings, options and a short table of the data it shows) and its language.",
    args = list(reportId = "a saved report's id, from listReports", maxRows = "rows of each chart's data (default 25, at most 100)",
                data = "false to leave out the charts' data")
  )
}

#' The updateBlocks action
#'
#' Changes blocks of a saved report and leaves the rest as it is (datasuite.ui's
#' `report_update_blocks()`). The saved report keeps its id and gets the time of the change. The
#' same changes are worked out, without saving anything, for the sentence the user confirms.
#'
#' @return An `ai_action` object. The action answers with the report's `reportId`, its `name` and
#'   the `changes` made.
#' @noRd
.cd_ai_update_blocks <- function() {
  # the changes as they would be made (nothing saved), for the action and for what the user confirms
  plan <- function(args, session) {
    ds <- .cd_ai_cache(session)
    project <- .cd_ai_saved_report(ds, args$reportId)
    changed <- datasuite.ui::report_update_blocks(project, args$changes, members = cd_chartable_members())
    list(ds = ds, project = project, changed = changed)
  }
  datasuite.ui::ai_action(
    "updateBlocks",
    function(args, session) {
      p <- plan(args, session)
      project <- p$changed$project
      # the report keeps its id (the Reports page saves edits by it) and says when it was last edited
      project$id <- args$reportId
      project$updated <- format(Sys.time(), "%Y-%m-%d %H:%M")
      p$ds$set_report_project(args$reportId, project)
      list(reportId = args$reportId, name = project$name, changes = p$changed$changes)
    },
    kind = "replace",
    summary = function(args, session) {
      p <- plan(args, session)
      .cd_ai_update_summary(p$project, p$changed$changes, .cd_ai_dataset_name(p$ds), args$changes)
    },
    description = "Changes blocks of a saved report, leaving the rest as it is: text (write or rewrite a paragraph, heading or note), a chart's or table's kind, settings, chart options and layout; inserts blocks after one, removes or moves blocks. The Reports page shows the change at once.",
    args = list(reportId = "a saved report's id, from listReports",
                changes = "a list, applied in order: { blockId, text | type | level | kind | indicator | admin_level | region | year | variant | options | size | title | caption | pageBreakBefore }, { afterBlockId, insert: { type, text | kind, ... } }, { blockId, delete: true }, { blockId, moveAfter }")
  )
}

#' The sentence the user confirms for updateBlocks
#'
#' When every change only writes text (a paragraph, a heading or a note), the sentence counts them:
#' "Write 5 paragraphs in the report "X"". Otherwise it lists the changes, six at most, and says how
#' many more there are.
#'
#' @param project The saved report, before the changes.
#' @param said The changes made, as `report_update_blocks()` reports them, one string for each.
#' @param dataset The dataset's name, as `.cd_ai_dataset_name()` gives it.
#' @param changes The changes as the AI sent them.
#' @return One string.
#' @noRd
.cd_ai_update_summary <- function(project, said, dataset, changes) {
  name <- project$name %||% project$id %||% "the report"
  types <- vapply(datasuite.ui::report_project_blocks(project), function(b) b$type %||% "", character(1))
  names(types) <- vapply(datasuite.ui::report_project_blocks(project), function(b) as.character(b$id %||% ""), character(1))
  written <- if (length(changes)) vapply(changes, function(ch) {
    if (!is.list(ch)) return(NA_character_)
    if (!is.null(ch$insert)) return(if (isTRUE(ch$insert$type %in% c("paragraph", "heading", "note"))) ch$insert$type else NA_character_)
    id <- as.character(unlist(ch$blockId %||% ch$id))[1]
    if (identical(setdiff(names(ch), c("blockId", "id")), "text") && isTRUE(types[id] %in% c("paragraph", "heading", "note"))) unname(types[id]) else NA_character_
  }, character(1)) else NA_character_
  if (length(written) && !anyNA(written)) {
    counts <- table(factor(written, levels = c("paragraph", "heading", "note")))
    counts <- counts[counts > 0]
    what <- vapply(names(counts), function(k) sprintf("%d %s%s", counts[[k]], k, if (counts[[k]] == 1) "" else "s"), "")
    return(sprintf("Write %s in the report \"%s\" (%s)", paste(what, collapse = " and "), name, dataset))
  }
  shown <- utils::head(said, 6)
  more <- length(said) - length(shown)
  sprintf("Change the report \"%s\" (%s): %s%s", name, dataset, paste(shown, collapse = "; "),
          if (more > 0) sprintf("; and %d more", more) else "")
}

#' Whether an id names something already saved
#'
#' @param id A `reportId` or `graphId` the AI gave.
#' @param saved What is saved, a named list.
#' @return `TRUE` when `id` is one non-empty string and a name of `saved`, `FALSE` otherwise.
#' @noRd
.cd_ai_saved <- function(id, saved) {
  is.character(id) && length(id) == 1 && nzchar(id) && id %in% names(saved)
}

#' The dataset's file name, for what the user confirms
#'
#' @param ds The dataset, a [CacheConnection].
#' @return The base name of the dataset's file, or `"the dataset"` when it has no path.
#' @noRd
.cd_ai_dataset_name <- function(ds) {
  path <- tryCatch(ds$cache_path, error = function(e) NULL)
  if (is.character(path) && length(path) == 1 && nzchar(path)) basename(path) else "the dataset"
}

#' Count a report's blocks, for what the user confirms
#'
#' @param blocks The report's blocks, a list.
#' @return A string such as `" (14 blocks: 5 charts, 1 picture)"`, which counts the charts, tables
#'   and pictures among the blocks, or `""` when there are no blocks.
#' @noRd
.cd_ai_block_counts <- function(blocks) {
  if (!is.list(blocks) || !length(blocks)) return("")
  types <- vapply(blocks, function(b) if (is.list(b) && is.character(b$type)) b$type[[1]] else "", character(1))
  count <- function(n, one, many) if (n) sprintf("%d %s", n, if (n == 1) one else many)
  parts <- Filter(Negate(is.null), list(count(sum(types == "chart"), "chart", "charts"), count(sum(types == "table"), "table", "tables"),
                                        count(sum(types == "image"), "picture", "pictures")))
  sprintf(" (%d %s%s)", length(blocks), if (length(blocks) == 1) "block" else "blocks",
          if (length(parts)) paste0(": ", paste(unlist(parts), collapse = ", ")) else "")
}

#' The setFilters action
#'
#' Sets the filters the AI names on the chips of the page on show. Every filter is checked before
#' any is set, so a request is done whole or not at all: it is refused when it names an unknown
#' filter, no filter, or a filter the page does not have. A filter is set on every chip of its kind
#' on the page.
#'
#' @return An `ai_action` object. The action answers with the page and its filters
#'   (`.cd_ai_state_result()`) once the browser has reported the new values.
#' @noRd
.cd_ai_set_filters <- function() {
  datasuite.ui::ai_action(
    "setFilters",
    function(args, session) {
      input <- session$input
      page <- shiny::isolate(input$tabs)
      input_names <- names(shiny::isolate(shiny::reactiveValuesToList(input)))
      unknown <- setdiff(names(args), names(.cd_ai_filter_names))
      if (length(unknown)) stop(sprintf("Unknown filter: %s. The filters are %s.", paste(unknown, collapse = ", "),
                                        paste(names(.cd_ai_filter_names), collapse = ", ")), call. = FALSE)
      if (!length(args)) stop("Say which filters to set, e.g. years = c(2020, 2023).", call. = FALSE)
      # every filter is checked before any is set, so a request is done whole or not at all
      found <- lapply(names(args), function(name) .cd_ai_filter_ids(input_names, page, .cd_ai_filter_names[[name]]))
      names(found) <- names(args)
      absent <- names(found)[lengths(found) == 0]
      if (length(absent)) stop(sprintf("This page has no %s filter.", paste(absent, collapse = " or ")), call. = FALSE)
      expected <- list()
      for (name in names(args)) {
        ids <- found[[name]]
        value <- args[[name]]
        value <- if (name == "years") paste(unlist(value), collapse = ",") else as.character(unlist(value))[1]
        for (id in ids) {
          cd_update_input(id, session, value = value)
          expected[[id]] <- value
        }
      }
      datasuite.ui::ai_reply_when(
        ready = function() all(vapply(names(expected), function(id) identical(paste(input[[id]], collapse = ","), expected[[id]]), NA)),
        result = function() .cd_ai_state_result(session)
      )
    },
    kind = "view",
    summary = function(args, session) {
      shown <- vapply(names(args), function(name) sprintf("%s = %s", name, paste(unlist(args[[name]]), collapse = ", ")), character(1))
      sprintf("Set the filters on this page: %s", paste(shown, collapse = "; "))
    },
    description = "Sets filters on the current page (only those the page has).",
    args = list(
      admin_level = "\"adminlevel_1\" or \"district\"",
      region = "a region name, as listed in the region chip",
      years = "years to show, e.g. [2020, 2021]; [] for all years",
      indicator = "an indicator code, e.g. \"penta3\"",
      denominator = "a denominator, e.g. \"dhis2\", \"anc1\", \"penta1\""
    )
  )
}

#' The page and its filters after a change, for the reply
#'
#' @param session The app's Shiny session.
#' @return A list with `page` (the id of the page on show) and `filters` (see `.cd_ai_filters()`).
#' @noRd
.cd_ai_state_result <- function(session) {
  input <- session$input
  page <- shiny::isolate(input$tabs)
  list(page = page, filters = .cd_ai_filters(shiny::isolate(shiny::reactiveValuesToList(input)), page))
}

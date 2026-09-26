# What the Countdown apps add to datasuite.ui's AI bridge (datasuite.ui's docs/AI-BRIDGE.md, protocol 2): the filters in
# effect on the page the user is on and the dataset (path, country, revision), and the actions setFilters, saveReport,
# addGraph and generateReport. cd_app() passes these to app_frame(). Data questions don't come through here: the AI
# reads the dataset in its own R session (countdown-analytics/docs/AI-PLAN.md); what it adds to the dataset does, so
# the app's own CacheConnection is the one that saves.
#
# The filters are the shared filter chips (R/ui-filters-*.R) inside each page's modules, so their input ids are the page
# id, the module path and the chip's own id: "<page>-...-admin", "-region", "-years", "-indicator", "-denominator". The
# current page's are found by that shape in the session's inputs.

.cd_ai_filter_names <- c(admin_level = "admin", region = "region", years = "years", indicator = "indicator",
                         denominator = "denominator")

# The input ids of filter `chip` (e.g. "years") on `page`, from the input names of the session.
.cd_ai_filter_ids <- function(input_names, page, chip) {
  if (is.null(page) || !nzchar(page)) return(character(0))
  pattern <- paste0("^", gsub("([.])", "\\\\\\1", page), "-(.+-)?", chip, "$")
  sort(grep(pattern, input_names, value = TRUE))
}

# The filters in effect on `page`: one value per filter (the first chip of each kind on the page), or NULL when the
# page has none. Years are integers, an empty years chip means every year (NULL).
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

# What cd_app() adds to the state (app_frame() keeps the dataset reactive in session$userData$cd_cache).
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

# What a chart or table on a Countdown page is, for the AI (its `about`): the report kind it matches (NULL when none
# does) and its options as the report builder names them (indicator, admin_level, region, year, variant). Options may be
# values or reactives; each is read on its own, so one not ready yet is just left out. Returns a function, so it is
# read when the AI asks, never computing anything.
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

# The dataset the app has open, or an error for the AI.
.cd_ai_cache <- function(session) {
  cache <- session$userData$cd_cache
  ds <- if (is.null(cache)) NULL else tryCatch(shiny::isolate(cache()), error = function(e) NULL)
  if (is.null(ds) || is.null(tryCatch(ds$countdown_data, error = function(e) NULL))) {
    stop("No dataset is loaded in the app yet.", call. = FALSE)
  }
  ds
}

# The report kinds of this app's indicator group.
.cd_ai_kinds <- function() names(report_block_kinds(getOption("cd2030.app_group", get_selected_group())))

# A new id for something the AI adds, not already in `existing`.
.cd_ai_new_id <- function(prefix, existing) {
  i <- length(existing) + 1L
  while (paste0(prefix, i) %in% existing) i <- i + 1L
  paste0(prefix, i)
}

# A file name from a report's name.
.cd_ai_file_stem <- function(name) {
  stem <- gsub("[^A-Za-z0-9_-]+", "_", name %||% "report")
  stem <- gsub("^_+|_+$", "", stem)
  if (!nzchar(stem)) "report" else substr(stem, 1, 60)
}

# The Countdown actions: setFilters (the view), and saveReport, addGraph, generateReport (what the AI adds). All
# "change": DataSuite asks the user first, or doesn't allow them, by the user's settings.
.cd_ai_actions <- function() {
  list(.cd_ai_set_filters(), .cd_ai_save_report(), .cd_ai_add_graph(), .cd_ai_generate_report())
}

.cd_ai_save_report <- function() {
  datasuite.ui::ai_action(
    "saveReport",
    function(args, session) {
      ds <- .cd_ai_cache(session)
      project <- args$project
      if (!is.list(project)) stop("Give the report: project = list(name, blocks).", call. = FALSE)
      project$name <- project$name %||% "Report from the AI"
      project <- datasuite.ui::report_validate_project(project, kinds = .cd_ai_kinds(), members = cd_chartable_members())
      id <- if (is.character(args$reportId) && length(args$reportId) == 1 && nzchar(args$reportId)) args$reportId
            else .cd_ai_new_id("ai-report-", names(ds$report_projects))
      ds$set_report_project(id, project)
      list(reportId = id, name = project$name, blocks = length(project$blocks))
    },
    kind = "change",
    description = "Saves a report in the dataset; it opens in the Reports page, where the user can edit and export it.",
    args = list(project = "the report: list(name, blocks), blocks as in the report builder (report kinds, or custom_chart)",
                reportId = "optional: replace this saved report")
  )
}

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
    kind = "change",
    description = "Saves a custom chart in the dataset; it redraws with the data and can be added to any report (a chart block with kind custom_chart and graph = its id).",
    args = list(spec = "the chart: list(title, data = list(member, args), transform, plot)", graphId = "optional: replace this saved graph")
  )
}

.cd_ai_generate_report <- function() {
  datasuite.ui::ai_action(
    "generateReport",
    function(args, session) {
      ds <- .cd_ai_cache(session)
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
      dir <- Sys.getenv("CDSUITE_SHINY_WORKSPACE_DIR", unset = "")
      if (!nzchar(dir) || !dir.exists(dir)) dir <- tempdir()
      file <- file.path(dir, paste0(.cd_ai_file_stem(project$name), ".", format))
      if (deck) datasuite.ui::export_deck(ds, project, file, format = format) else datasuite.ui::export_report(ds, project, file, format = format)
      list(file = normalizePath(file, winslash = "/", mustWork = FALSE), format = format)
    },
    kind = "change",
    description = "Writes a standard or saved report to a Word, PowerPoint or PDF file in the dataset's working folder.",
    args = list(preset = "a standard report id, e.g. national_coverage", reportId = "or a saved report's id",
                format = "docx or pdf (a document), pptx or pdf (a slide deck)")
  )
}

# setFilters: sets the given filters on the current page's chips; answers with the new state once the browser has them.
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
    kind = "change",
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

# The filters (and page) after a change, for the reply.
.cd_ai_state_result <- function(session) {
  input <- session$input
  page <- shiny::isolate(input$tabs)
  list(page = page, filters = .cd_ai_filters(shiny::isolate(shiny::reactiveValuesToList(input)), page))
}

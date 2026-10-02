# Notebook data: a folder's Countdown datasets for DataSuite's notebooks, by name, in R, Python and Stata.
#
# A folder holds each country's Excel file, the .rds an app saved from it (`<stem>_rmncah.rds`, `<stem>_vaccine.rds`)
# and that .rds's workspace (`<stem>_rmncah.shiny-workspace`: the project's notebooks, figures, reports). A notebook
# in a workspace gets the tables of its own .rds by their short names (`adjusted_data`), the folder's other datasets
# as `<stem>/<table>`, the package's reference data as `ref_<table>`, and what is saved in the workspace's `data/`.
#
# DataSuite calls notebook_data() (the apps declare it as their `notebookData`):
# - "list": the datasets and their tables, from the file names alone (no .rds is opened).
# - "prepare": Stata files of a dataset's tables in `<workspace>/data/` (another dataset's, and the reference
#   data, in `data/_others/`) for Python and Stata, made when a table is first asked for and again once its .rds has
#   changed -- checked at most once a `period`, or at once with `force`. `tables` says which: the usual ones when not
#   given (Python's), only those named otherwise (Stata asks for a table when a cell first uses it).
# - "attach": in a notebook's R session, the names themselves, read from the .rds (read-only) when first used and
#   again once it has changed, the same way; and ds_list(), ds_use(), ds_save(), ds_reload().
# Nothing here writes to an .xlsx or an .rds; only `data/` is written.

# The usual tables of a dataset (what Python notebooks get, and what "prepare" writes when not told which): the name
# notebooks use, and how it comes from the (read-only) CacheConnection.
.nb_tables <- list(
  countdown_data = function(cc) cc$countdown_data,
  kept_data = function(cc) cc$data_with_excluded_years,
  adjusted_data = function(cc) if (isTRUE(cc$adjusted_flag)) cc$adjusted_data,
  national_rates = function(cc) .nb_national_rates(cc),
  national_survey = function(cc) cc$national_survey,
  regional_survey = function(cc) cc$regional_survey,
  wealth_survey = function(cc) cc$wiq_survey,
  education_survey = function(cc) cc$education_survey,
  area_survey = function(cc) cc$area_survey,
  un_estimates = function(cc) cc$un_estimates,
  wuenic_estimates = function(cc) cc$wuenic_estimates,
  settings = function(cc) .nb_settings(cc)
)

# The CacheConnection member each usual table is (the others are members by their own names).
.nb_table_members <- c(kept_data = "data_with_excluded_years", wealth_survey = "wiq_survey")

# Every table of a dataset: the usual ones, then every other data and reference member of CacheConnection that is a
# table (cache_definition(); the map, `shapefile`, is not), computed only when a notebook uses it.
.nb_all_tables <- function() {
  defs <- cache_definition()
  members <- names(defs)[vapply(defs, function(d) isTRUE(d$kind %in% c("data", "reference")), logical(1))]
  members <- setdiff(members, c(names(.nb_tables), .nb_table_members, "shapefile"))
  c(.nb_tables, lapply(stats::setNames(members, members), function(m) function(cc) cc[[m]]))
}

# What a table holds, in a sentence (the first of its CacheConnection member's definition).
.nb_table_what <- function(table) {
  fixed <- c(
    national_rates = "The national rates the denominators use: the survey coverage, mortality and other rates.",
    settings = "The dataset's settings: country, denominators, survey year, excluded years and the adjustment."
  )
  if (table %in% names(fixed)) return(fixed[[table]])
  member <- if (table %in% names(.nb_table_members)) .nb_table_members[[table]] else table
  what <- tryCatch(cache_definition(member)$what, error = function(e) NULL)
  if (is.null(what) || !nzchar(what)) return(NA_character_)
  sub("^(.*?[.:])\\s.*$", "\\1", what, perl = TRUE)
}

# The package's reference data, as `ref_<name>`.
.nb_ref_tables <- c("un_estimates", "un_mortality", "wuenic", "fpet", "countries")

.nb_national_rates <- function(cc) {
  pick <- function(x, source) {
    x <- tryCatch(x, error = function(e) NULL)
    x <- Filter(function(v) length(v) == 1 && (is.numeric(v) || is.character(v)), as.list(x))
    if (!length(x)) return(NULL)
    data.frame(name = names(x), value = vapply(x, function(v) as.character(v), character(1)), source = source,
               stringsAsFactors = FALSE, row.names = NULL)
  }
  rows <- rbind(pick(cc$national_estimates, "national rates"), pick(cc$survey_estimates, "survey estimates"))
  if (is.null(rows)) return(NULL)
  num <- suppressWarnings(as.numeric(rows$value))
  if (!anyNA(num[!is.na(rows$value)])) rows$value <- num
  rows
}

.nb_settings <- function(cc) {
  get <- function(name) tryCatch(cc[[name]], error = function(e) NULL)
  one <- function(setting, value) {
    if (is.null(value) || !length(value)) return(NULL)
    data.frame(setting = setting, value = paste(format(value, trim = TRUE), collapse = ", "), stringsAsFactors = FALSE)
  }
  k <- get("k_factors")
  rows <- list(
    one("country", get("country")),
    one("revision", get("revision")),
    one("denominator", get("denominator")),
    one("maternal_denominator", get("maternal_denominator")),
    one("survey_year", get("survey_year")),
    one("performance_threshold", get("performance_threshold")),
    one("excluded_years", get("excluded_years")),
    one("adjusted", isTRUE(get("adjusted_flag")))
  )
  if (length(k)) rows <- c(rows, lapply(names(k), function(n) one(paste0("k_", n), k[[n]])))
  footnote <- tryCatch(adjustment_settings_footnote(cc$adjustment_settings), error = function(e) character())
  if (length(footnote)) rows <- c(rows, lapply(seq_along(footnote), function(i) one(paste0("adjustment_rule_", i), footnote[[i]])))
  do.call(rbind, Filter(Negate(is.null), rows))
}

#' Notebook data: a folder's Countdown datasets for DataSuite's notebooks
#'
#' What DataSuite's notebooks call (an app's `notebookData`): the datasets of a folder -- each app's saved `.rds`
#' next to its Excel file, and its workspace -- by name, in R, Python and Stata. Never writes to an `.xlsx` or an
#' `.rds`; only the workspace's `data/` folder.
#'
#' @param action `"list"` (the datasets and their tables, from the file names alone), `"prepare"` (Stata files of the
#'   tables of `datasets`, for Python and Stata, made or remade when their `.rds` changed) or `"attach"` (in a
#'   notebook's R session: the tables by name, and `ds_list()`, `ds_use()`, `ds_save()`, `ds_reload()`).
#' @param folder The folder holding the Excel files, the `.rds` files and their workspaces.
#' @param workspace The notebook's workspace (`<stem>.shiny-workspace`): its `.rds` is the notebook's own dataset.
#' @param datasets For `"prepare"`: the datasets (their `.rds` file names without `.rds`, or `"ref"`) to prepare;
#'   the workspace's own is always included.
#' @param force For `"prepare"`: check the `.rds` files now, not only when the last check is older than `period`.
#' @param period Seconds between checks of an `.rds` for changes (default 60).
#' @param tables For `"prepare"`: the tables to write (names from `"list"`); the usual ones when `NULL`. Tables
#'   already written are kept, and written again once their `.rds` has changed.
#' @return For `"list"` and `"prepare"`, a list (DataSuite reads it as JSON); for `"attach"`, invisibly the names
#'   attached.
#' @export
notebook_data <- function(action = c("list", "prepare", "attach"), folder, workspace = NULL, datasets = NULL,
                          force = FALSE, period = 60, tables = NULL) {
  action <- match.arg(action)
  folder <- normalizePath(folder, winslash = "/", mustWork = TRUE)
  if (!is.null(workspace)) workspace <- normalizePath(workspace, winslash = "/", mustWork = FALSE)
  switch(action,
    list = .nb_list(folder, workspace),
    prepare = .nb_prepare(folder, workspace, unique(c(.nb_own(workspace), as.character(unlist(datasets)))), isTRUE(force), as.numeric(period),
                          if (is.null(tables)) NULL else as.character(unlist(tables))),
    attach = .nb_attach(folder, workspace, as.numeric(period))
  )
}

# The workspace's own dataset: its folder's name without `.shiny-workspace`.
.nb_own <- function(workspace) {
  if (is.null(workspace)) return(NULL)
  sub("\\.shiny-workspace$", "", basename(workspace))
}

# A name as Stata files may have it: letters, digits and _, not starting with a digit, at most `max` characters.
.nb_stata_name <- function(x, max = 32) {
  x <- gsub("[^A-Za-z0-9_]", "_", x)
  x <- sub("^([0-9])", "v\\1", x)
  substr(x, 1, max)
}

.nb_data_dir <- function(workspace) file.path(workspace, "data")
.nb_others_dir <- function(workspace) file.path(workspace, "data", "_others")

# A path Windows opens even at 260 characters or more: its \\?\ form. R embedded in DataSuite's kernel is not
# long-path aware (Rscript is), and a workspace deep in a folder with another dataset's long file name gets there.
.nb_long <- function(path) {
  if (.Platform$OS.type != "windows" || nchar(path) < 248 || startsWith(path, "\\\\?\\")) return(path)
  paste0("\\\\?\\", gsub("/", "\\", path, fixed = TRUE))
}

# Where a table's Stata file goes: the own dataset's in data/, another's (and the reference data) in data/_others.
.nb_file <- function(workspace, dataset, table, own) {
  if (identical(dataset, own)) return(file.path(.nb_data_dir(workspace), paste0(table, ".dta")))
  prefix <- if (identical(dataset, "ref")) "ref_" else paste0(.nb_stata_name(dataset, 200), "__")
  file.path(.nb_others_dir(workspace), paste0(prefix, table, ".dta"))
}

# The folder's datasets, from its file names.
.nb_scan <- function(folder) {
  files <- list.files(folder, full.names = FALSE)
  rds <- files[grepl("\\.rds$", files, ignore.case = TRUE)]
  rds_stems <- sub("\\.rds$", "", rds, ignore.case = TRUE)
  workspaces <- sub("\\.shiny-workspace$", "", files[grepl("\\.shiny-workspace$", files)])
  excel <- files[grepl("\\.(xlsx|xls)$", files, ignore.case = TRUE)]
  excel_stems <- sub("\\.(xlsx|xls)$", "", excel, ignore.case = TRUE)
  list(rds = rds_stems, workspaces = workspaces, excel = excel_stems, excel_files = excel)
}

.nb_state_file <- function(workspace) file.path(.nb_data_dir(workspace), ".catalog.json")

.nb_read_state <- function(workspace) {
  file <- .nb_state_file(workspace)
  if (is.null(workspace) || !file.exists(file)) return(list(datasets = list()))
  tryCatch(jsonlite::fromJSON(file, simplifyVector = FALSE), error = function(e) list(datasets = list()))
}

.nb_write_state <- function(workspace, state) {
  dir.create(.nb_data_dir(workspace), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(state, .nb_state_file(workspace), auto_unbox = TRUE, pretty = TRUE, null = "null")
}

# The workspace's own saved tables: what is in data/ that no dataset was exported to (a notebook's ds_save()).
.nb_saved <- function(workspace, state) {
  if (is.null(workspace)) return(list())
  dir <- .nb_data_dir(workspace)
  if (!dir.exists(dir)) return(list())
  exported <- unlist(lapply(state$datasets, function(d) vapply(d$tables, function(t) basename(t$file), character(1))))
  files <- list.files(dir, pattern = "\\.(dta|rds)$", full.names = TRUE)
  files <- files[!basename(files) %in% exported]
  names <- unique(sub("\\.(dta|rds)$", "", basename(files)))
  lapply(names, function(n) {
    f <- files[sub("\\.(dta|rds)$", "", basename(files)) == n]
    list(name = n, source = "saved", files = as.list(basename(f)), saved = format(max(file.mtime(f)), "%Y-%m-%d %H:%M"))
  })
}

.nb_list <- function(folder, workspace) {
  scan <- .nb_scan(folder)
  own <- .nb_own(workspace)
  state <- .nb_read_state(workspace)
  all_tables <- names(.nb_all_tables())
  what <- vapply(all_tables, .nb_table_what, character(1))
  table_info <- function(stem) {
    d <- state$datasets[[stem]]
    exported <- d$tables
    # every table it may have, each with whether it is written and up to date (`ready`); one found empty when it
    # was asked for (a survey the dataset has none of) is left out
    names <- setdiff(all_tables, unlist(d$empty))
    lapply(names, function(t) {
      e <- exported[[t]]
      list(name = t, what = what[[t]], ready = !is.null(e), rows = e$rows %||% NA, cols = e$cols %||% NA,
           stata = sub("\\.dta$", "", basename(.nb_file(workspace %||% folder, stem, t, own))))
    })
  }
  datasets <- lapply(scan$rds, function(stem) {
    rds <- file.path(folder, paste0(stem, ".rds"))
    d <- state$datasets[[stem]]
    list(name = stem, own = identical(stem, own), status = "ok", rds = rds,
         workspace = if (stem %in% scan$workspaces) file.path(folder, paste0(stem, ".shiny-workspace")) else NULL,
         saved = format(file.mtime(rds), "%Y-%m-%d %H:%M"), revision = d$revision %||% NA, tables = table_info(stem))
  })
  # Excel files no app has saved an .rds from, and workspaces whose .rds is gone
  loaded <- vapply(scan$excel, function(s) any(startsWith(scan$rds, s)), logical(1))
  pending <- lapply(scan$excel_files[!loaded], function(f) list(name = sub("\\.(xlsx|xls)$", "", f, ignore.case = TRUE), status = "not-loaded", excel = file.path(folder, f),
                                                                message = "Open it in an app (RMNCAH, Vaccination) first: its tables come from the .rds the app saves."))
  orphans <- lapply(setdiff(scan$workspaces, scan$rds), function(w) list(name = w, status = "workspace-only", workspace = file.path(folder, paste0(w, ".shiny-workspace")),
                                                                         message = "Its .rds is not in this folder: only what is saved in its workspace."))
  list(
    folder = folder, workspace = workspace, own = own,
    datasets = c(datasets, pending, orphans),
    saved = .nb_saved(workspace, state),
    ref = list(version = as.character(utils::packageVersion("cd2030.core")),
               tables = lapply(.nb_ref_tables, function(t) list(name = paste0("ref_", t), stata = paste0("ref_", t))))
  )
}

# A table as a Stata file: Stata's names (the originals in the catalog when they changed), the data dictionary's
# descriptions as variable labels, the dataset's source as its label.
.nb_write_dta <- function(x, file, label) {
  x <- as.data.frame(dplyr::ungroup(x))
  x <- x[, !vapply(x, is.list, NA), drop = FALSE]
  attr(x, "class") <- "data.frame"
  original <- names(x)
  for (i in seq_along(x)) if (is.logical(x[[i]])) x[[i]] <- as.integer(x[[i]])
  labels <- tryCatch(cd_describe_columns(original)$description, error = function(e) rep(NA_character_, length(original)))
  for (i in seq_along(x)) if (!is.na(labels[[i]])) attr(x[[i]], "label") <- substr(labels[[i]], 1, 80)
  names(x) <- make.unique(.nb_stata_name(original), sep = "_")
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  # written in R's own (short) temporary folder, then copied into place: haven can't open a path of Windows' 260
  # characters or more (a workspace deep in a folder, another dataset's long file name); R's file.copy() can
  tmp <- tempfile(fileext = ".dta")
  on.exit(unlink(tmp), add = TRUE)
  haven::write_dta(x, tmp, label = substr(label, 1, 80))
  if (!file.copy(tmp, .nb_long(file), overwrite = TRUE)) stop("Could not write ", file, call. = FALSE)
  renamed <- original != names(x)
  list(rows = nrow(x), cols = ncol(x), renamed = if (any(renamed)) as.list(stats::setNames(original[renamed], names(x)[renamed])) else NULL)
}

.nb_prepare <- function(folder, workspace, datasets, force, period, tables = NULL) {
  if (is.null(workspace)) stop("A notebook's data needs its workspace (the notebook is not in a .shiny-workspace folder).")
  own <- .nb_own(workspace)
  state <- .nb_read_state(workspace)
  now <- Sys.time()
  refreshed <- list()
  problems <- list()
  for (stem in datasets) {
    if (identical(stem, "ref")) {
      version <- as.character(utils::packageVersion("cd2030.core"))
      if (identical(state$ref$version, version) && all(file.exists(vapply(.nb_ref_tables, function(t) .nb_long(.nb_file(workspace, "ref", t, own)), "")))) next
      for (t in .nb_ref_tables) {
        x <- tryCatch(get(t, envir = asNamespace("cd2030.core")), error = function(e) NULL)
        if (is.data.frame(x)) .nb_write_dta(x, .nb_file(workspace, "ref", t, own), paste0("cd2030.core ", version, " reference data: ", t))
      }
      state$ref <- list(version = version)
      refreshed[[length(refreshed) + 1]] <- list(dataset = "ref", revision = NA, saved = version, tables = as.list(paste0("ref_", .nb_ref_tables)))
      next
    }
    rds <- file.path(folder, paste0(stem, ".rds"))
    if (!file.exists(rds)) {
      problems[[length(problems) + 1]] <- list(dataset = stem, message = "No such .rds in the folder.")
      next
    }
    d <- state$datasets[[stem]] %||% list()
    defs <- .nb_all_tables()
    wanted <- intersect(if (is.null(tables)) names(.nb_tables) else tables, names(defs))
    # a table not written yet is written whatever the period; the ones written are checked once a period
    missing <- setdiff(wanted, c(names(d$tables), unlist(d$empty)))
    checked <- if (!is.null(d$checked)) as.POSIXct(d$checked, tz = "UTC") else NULL
    if (!force && !length(missing) && !is.null(checked) && as.numeric(difftime(now, checked, units = "secs")) < period) next
    info <- file.info(rds)
    stamp <- paste(format(info$mtime, "%Y-%m-%dT%H:%M:%OS3"), info$size)
    files_there <- all(file.exists(vapply(d$tables, function(t) .nb_long(t$file), "")))
    d$checked <- format(now, "%Y-%m-%dT%H:%M:%OS3", tz = "UTC")
    if (identical(d$stamp, stamp) && files_there && !length(missing)) {
      state$datasets[[stem]] <- d
      next
    }
    if (!identical(d$stamp, stamp) || !files_there) {
      # the .rds changed: what was written is out of date, and is written again (with what is asked for now)
      wanted <- union(wanted, names(d$tables))
      d$tables <- list()
      d$empty <- list()
    } else {
      wanted <- missing
    }
    cc <- tryCatch(suppressMessages(init_CacheConnection(rds_path = rds, read_only = TRUE)), error = function(e) e)
    if (inherits(cc, "error")) {
      problems[[length(problems) + 1]] <- list(dataset = stem, message = conditionMessage(cc))
      state$datasets[[stem]] <- d
      next
    }
    revision <- tryCatch(cc$revision, error = function(e) NA)
    saved <- format(info$mtime, "%Y-%m-%d %H:%M")
    written_now <- character()
    for (t in wanted) {
      x <- tryCatch(defs[[t]](cc), error = function(e) NULL)
      file <- .nb_file(workspace, stem, t, own)
      if (!is.data.frame(x) || !ncol(x)) {
        unlink(.nb_long(file))
        d$tables[[t]] <- NULL
        d$empty <- as.list(union(unlist(d$empty), t))
        next
      }
      written <- .nb_write_dta(x, file, sprintf("%s %s, revision %s, saved %s", stem, t, revision, saved))
      d$tables[[t]] <- c(list(file = file), written)
      written_now <- c(written_now, t)
    }
    d$stamp <- stamp
    d$revision <- revision
    d$saved <- saved
    state$datasets[[stem]] <- d
    refreshed[[length(refreshed) + 1]] <- list(dataset = stem, own = identical(stem, own), revision = revision, saved = saved, tables = as.list(written_now))
  }
  .nb_write_state(workspace, state)
  own_tables <- names(state$datasets[[own]]$tables %||% list())
  list(refreshed = refreshed, problems = problems, own = own, own_tables = as.list(own_tables),
       data = .nb_data_dir(workspace), others = .nb_others_dir(workspace))
}

# ---- R notebooks: the names themselves ----------------------------------------------------------------------------

.nb_attach <- function(folder, workspace, period) {
  own <- .nb_own(workspace)
  # attached empty, then filled: attach() copies an environment it is given, which would read every active binding
  while ("datasuite:data" %in% search()) detach("datasuite:data", character.only = TRUE)
  env <- attach(NULL, name = "datasuite:data", warn.conflicts = FALSE)
  loaded <- new.env(parent = emptyenv())   # dataset -> list(cc, stamp, checked)

  stamp_of <- function(rds) { i <- file.info(rds); paste(format(i$mtime, "%Y-%m-%dT%H:%M:%OS3"), i$size) }

  # The dataset's read-only CacheConnection, read when first used and again once its .rds has changed (checked at
  # most once a `period`, or now with `force`).
  dataset <- function(stem, force = FALSE) {
    rds <- file.path(folder, paste0(stem, ".rds"))
    if (!file.exists(rds)) stop("There is no ", stem, ".rds in ", folder, ". ds_list() shows what is there.", call. = FALSE)
    had <- loaded[[stem]]
    now <- Sys.time()
    if (!is.null(had) && !force && as.numeric(difftime(now, had$checked, units = "secs")) < period) return(had$cc)
    stamp <- stamp_of(rds)
    if (!is.null(had) && identical(had$stamp, stamp)) {
      had$checked <- now
      assign(stem, had, envir = loaded)
      return(had$cc)
    }
    cc <- suppressMessages(init_CacheConnection(rds_path = rds, read_only = TRUE))
    if (!is.null(had)) {
      message(sprintf("%s reloaded (revision %s, saved %s)", stem, tryCatch(cc$revision, error = function(e) "?"),
                      format(file.mtime(rds), "%Y-%m-%d %H:%M")))
    }
    assign(stem, list(cc = cc, stamp = stamp, checked = now), envir = loaded)
    cc
  }

  saved_file <- function(name) {
    rds <- file.path(.nb_data_dir(workspace), paste0(name, ".rds"))
    dta <- file.path(.nb_data_dir(workspace), paste0(name, ".dta"))
    if (file.exists(.nb_long(rds))) rds else if (file.exists(.nb_long(dta))) dta else NULL
  }

  # a long path is read from a copy in R's temporary folder (readRDS() and haven can't open the long form)
  read_saved <- function(file) {
    if (!identical(.nb_long(file), file)) {
      tmp <- tempfile(fileext = if (grepl("\\.rds$", file)) ".rds" else ".dta")
      on.exit(unlink(tmp), add = TRUE)
      file.copy(.nb_long(file), tmp)
      file <- tmp
    }
    if (grepl("\\.rds$", file)) readRDS(file) else haven::read_dta(file)
  }

  # A table by name: `adjusted_data` (the notebook's own dataset), `<stem>/adjusted_data` (another), `ref_wuenic`
  # (the reference data) or a saved table's name.
  use <- function(name) {
    if (grepl("/", name, fixed = TRUE)) {
      stem <- sub("/[^/]*$", "", name)
      table <- sub("^.*/", "", name)
    } else if (startsWith(name, "ref_") && sub("^ref_", "", name) %in% .nb_ref_tables) {
      return(get(sub("^ref_", "", name), envir = asNamespace("cd2030.core")))
    } else if (name %in% names(.nb_all_tables()) && !is.null(own)) {
      stem <- own
      table <- name
    } else {
      file <- saved_file(name)
      if (is.null(file)) stop("No table called ", name, ". ds_list() shows what there is.", call. = FALSE)
      return(read_saved(file))
    }
    defs <- .nb_all_tables()
    if (!table %in% names(defs)) stop(table, " is not one of a dataset's tables: ds_list() shows them.", call. = FALSE)
    defs[[table]](dataset(stem))
  }

  env$ds_use <- use
  env$ds_list <- function() {
    l <- .nb_list(folder, workspace)
    rows <- list()
    for (d in l$datasets) {
      if (!identical(d$status, "ok")) {
        rows[[length(rows) + 1]] <- data.frame(dataset = d$name, table = paste0("(", d$status, ")"), use = NA_character_, description = d$message %||% NA_character_, saved = NA_character_, stringsAsFactors = FALSE)
        next
      }
      for (t in d$tables) {
        rows[[length(rows) + 1]] <- data.frame(dataset = if (isTRUE(d$own)) paste0(d$name, " (this notebook)") else d$name, table = t$name,
                                               use = if (isTRUE(d$own)) t$name else paste0(d$name, "/", t$name), description = t$what %||% NA_character_, saved = d$saved, stringsAsFactors = FALSE)
      }
    }
    for (s in l$saved) rows[[length(rows) + 1]] <- data.frame(dataset = "(saved in this workspace)", table = s$name, use = s$name, description = "Saved from a notebook (ds_save).", saved = s$saved, stringsAsFactors = FALSE)
    for (t in l$ref$tables) rows[[length(rows) + 1]] <- data.frame(dataset = paste("cd2030.core", l$ref$version), table = t$name, use = t$name, description = "Reference data built into cd2030.core.", saved = NA_character_, stringsAsFactors = FALSE)
    do.call(rbind, rows)
  }
  env$ds_save <- function(x, name) {
    stopifnot(is.data.frame(x), is.character(name), length(name) == 1, nzchar(name))
    name <- .nb_stata_name(name)
    dir <- .nb_data_dir(workspace)
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    tmp <- tempfile(fileext = ".rds")
    saveRDS(x, tmp)
    file.copy(tmp, .nb_long(file.path(dir, paste0(name, ".rds"))), overwrite = TRUE)
    unlink(tmp)
    .nb_write_dta(x, file.path(dir, paste0(name, ".dta")), sprintf("%s, saved from R %s", name, format(Sys.time(), "%Y-%m-%d %H:%M")))
    bind(name, function() read_saved(saved_file(name)))
    message("Saved ", name, " in ", dir, " (R and Stata; ds_use(\"", name, "\") or sysuse ", name, ")")
    invisible(name)
  }
  env$ds_reload <- function(name = NULL) {
    stems <- if (is.null(name)) ls(loaded) else if (grepl("/", name, fixed = TRUE)) sub("/[^/]*$", "", name) else own
    for (s in stems) dataset(s, force = TRUE)
    invisible(stems)
  }

  bind <- function(name, getter) {
    if (exists(name, envir = env, inherits = FALSE)) rm(list = name, envir = env)
    makeActiveBinding(name, getter, env)
  }
  if (!is.null(own) && file.exists(file.path(folder, paste0(own, ".rds")))) {
    defs <- .nb_all_tables()
    for (t in names(defs)) local({
      table <- t
      bind(table, function() defs[[table]](dataset(own)))
    })
    bind("cache", function() dataset(own))
  }
  for (t in .nb_ref_tables) local({
    table <- t
    bind(paste0("ref_", table), function() get(table, envir = asNamespace("cd2030.core")))
  })
  for (s in .nb_saved(workspace, .nb_read_state(workspace))) local({
    name <- s$name
    if (!exists(name, envir = env, inherits = FALSE)) bind(name, function() read_saved(saved_file(name)))
  })

  invisible(ls(env))
}

# What the Countdown AI needs from the package, all of it around CacheConnection (countdown-analytics/docs/AI-PLAN.md):
#
# - cd_chartable_members() / cd_member_data(): which members a custom chart may draw from, and their table;
# - cd_custom_chart_data(): a custom chart's table (member + transforms);
# - .cd_decompose_change(): behind CacheConnection$decompose_change(), which units drive a change;
# - cache_manifest(): every public member of CacheConnection with its arguments and documentation, and the report
#   kinds, read from the installed package -- what countdown-analytics builds its guide from.

#' The CacheConnection members a custom chart may draw from
#'
#' Members that return a table: the precomputed results (active bindings such as `reporting_rate_district`) and the
#' methods that compute one (`calculate_coverage()`, `get_filtered_coverage()`, `decompose_change()`...). Raw data
#' (`countdown_data`, `adjusted_data`) and settings are left out.
#'
#' @return A character vector of member names.
#' @examples
#' head(cd_chartable_members())
#' @export
cd_chartable_members <- function() {
  c(
    # computed on call
    "calculate_indicator_coverage", "calculate_coverage", "calculate_inequality", "calculate_derived_coverage",
    "calculate_reporting_rate", "calculate_district_reporting_rate", "calculate_completeness_summary",
    "calculate_district_completeness_summary", "calculate_outliers_summary", "calculate_district_outlier_summary",
    "calculate_ratios_and_adequacy", "get_filtered_coverage", "get_filtered_inequality", "decompose_change",
    # precomputed
    "reporting_rate_national", "reporting_rate_admin1", "reporting_rate_district", "district_reporting_rate",
    "completeness_national", "completeness_admin1", "completeness_district", "district_completeness",
    "outliers_national", "outliers_admin1", "outliers_district", "district_outliers_summary",
    "ratios_summary", "adequacy_ratios", "denominator_metrics",
    "indicator_coverage_national", "indicator_coverage_admin1", "indicator_coverage_district", "admin1_estimates",
    "inequality_admin1", "inequality_district", "fpet_data", "un_estimates", "un_mortality_estimates",
    "wuenic_estimates", "national_survey", "regional_survey", "mortality_summary", "mortality_ratios",
    "service_utilization_national", "service_utilization_admin1", "health_system_comparison",
    "health_system_metrics_national", "health_system_metrics_admin1", "national_private_share", "area_private_share"
  )
}

#' The table a CacheConnection member gives
#'
#' Reads an active binding, or calls a method with `args` (arguments it doesn't take are left out), and returns the
#' result as a plain data frame (a map's geometry dropped).
#'
#' @param cache A `CacheConnection`.
#' @param member A member name, one of [cd_chartable_members()].
#' @param args A named list of arguments for a method.
#' @return A data frame.
#' @export
cd_member_data <- function(cache, member, args = list()) {
  if (!is_scalar_character(member) || !member %in% cd_chartable_members()) {
    cd_abort(c("x" = "{.val {member}} can't be charted.", "i" = "Members that can: {.val {cd_chartable_members()}}."))
  }
  cls <- get("CacheConnection", envir = asNamespace("cd2030.core"))
  if (member %in% names(cls$active)) {
    value <- cache[[member]]
  } else {
    fn <- cache[[member]]
    args <- as.list(args %||% list())
    keep <- intersect(names(args), names(formals(fn)))
    value <- do.call(fn, args[keep])
  }
  if (inherits(value, "sf")) value <- sf::st_drop_geometry(value)
  if (!is.data.frame(value)) cd_abort(c("x" = "{.val {member}} did not give a table."))
  as.data.frame(value, stringsAsFactors = FALSE)
}

#' The table a custom chart draws
#'
#' @param cache A `CacheConnection`.
#' @param spec A custom chart description (report kind `custom_chart`, see `datasuite.ui::report_validate_spec()`).
#' @return The data frame after the spec's transforms.
#' @export
cd_custom_chart_data <- function(cache, spec) {
  spec <- datasuite.ui::report_validate_spec(spec, members = cd_chartable_members())
  data <- cd_member_data(cache, spec$data$member, spec$data$args %||% list())
  datasuite.ui::report_apply_transforms(data, spec$transform)
}

# The reporting-rate column that goes with an indicator ("anc4" -> "anc_rr"), or "mean_rr".
.cd_rr_column <- function(indicator) {
  groups <- tryCatch(get_indicator_groups(), error = function(e) list())
  hit <- names(Filter(function(v) indicator %in% v, groups))
  if (length(hit)) paste0(hit[[1]], "_rr") else "mean_rr"
}

# Behind CacheConnection$decompose_change() (documented there).
.cd_decompose_change <- function(cache, indicator, from_year, to_year, admin_level = c("district", "adminlevel_1"),
                                 region = NULL, denominator = NULL) {
  admin_level <- arg_match(admin_level)
  if (!is_scalar_character(indicator)) cd_abort(c("x" = "{.arg indicator} must be one indicator, e.g. {.val anc4}."))
  denominator <- denominator %||% cache$get_denominator(indicator)
  data <- if (identical(admin_level, "district")) cache$indicator_coverage_district else cache$indicator_coverage_admin1
  cov_col <- paste0("cov_", indicator, "_", denominator)
  if (is.null(data) || !all(c(indicator, cov_col) %in% names(data))) {
    cd_abort(c("x" = "There is no {.val {indicator}} coverage with the {.val {denominator}} denominator at this level."))
  }
  data <- as.data.frame(data)
  if (!is.null(region)) data <- data[data$adminlevel_1 %in% region, , drop = FALSE]
  units <- if (identical(admin_level, "adminlevel_1")) "adminlevel_1" else intersect(c("adminlevel_1", "district"), names(data))
  years <- c(from_year, to_year)
  missing_years <- setdiff(years, data$year)
  if (length(missing_years)) {
    cd_abort(c("x" = "The data has no {.val {missing_years}}; its years are {.val {sort(unique(data$year))}}."))
  }

  # each unit's denominator, as the app's coverage uses it: count / coverage
  part <- data[data$year %in% years, c(units, "year", indicator, cov_col), drop = FALSE]
  names(part)[names(part) == indicator] <- "num"
  cov <- part[[cov_col]]
  part$den <- ifelse(is.finite(cov) & cov > 0, part$num / (cov / 100), NA_real_)
  a <- part[part$year == from_year, c(units, "num", "den"), drop = FALSE]
  b <- part[part$year == to_year, c(units, "num", "den"), drop = FALSE]
  names(a)[match(c("num", "den"), names(a))] <- c("num_from", "den_from")
  names(b)[match(c("num", "den"), names(b))] <- c("num_to", "den_to")
  out <- merge(a, b, by = units, all = TRUE)
  for (col in c("num_from", "den_from", "num_to", "den_to")) out[[col]][is.na(out[[col]])] <- 0

  N0 <- sum(out$num_from); D0 <- sum(out$den_from); N1 <- sum(out$num_to); D1 <- sum(out$den_to)
  C0 <- if (D0 > 0) N0 / D0 * 100 else NA_real_
  C1 <- if (D1 > 0) N1 / D1 * 100 else NA_real_
  out$cov_from <- ifelse(out$den_from > 0, out$num_from / out$den_from * 100, NA_real_)
  out$cov_to <- ifelse(out$den_to > 0, out$num_to / out$den_to * 100, NA_real_)
  out$cov_change <- out$cov_to - out$cov_from
  # C1 - C0 = the sum over units of: service delivery (their change in count, over the new total denominator) plus
  # their share of the denominator effect (the total denominator's change, shared by each unit's part in it)
  out$contribution_service <- if (D1 > 0) (out$num_to - out$num_from) / D1 * 100 else NA_real_
  den_effect <- if (D1 > 0 && D0 > 0) N0 * (1 / D1 - 1 / D0) * 100 else 0
  out$contribution_denominator <- if (D1 != D0) den_effect * (out$den_to - out$den_from) / (D1 - D0) else 0
  out$contribution <- out$contribution_service + out$contribution_denominator

  # reporting: a change may be missing reports rather than fewer services
  rr_col <- .cd_rr_column(indicator)
  rr <- tryCatch(if (identical(admin_level, "district")) cache$reporting_rate_district else cache$reporting_rate_admin1,
                 error = function(e) NULL)
  out$reporting_from <- NA_real_
  out$reporting_to <- NA_real_
  if (!is.null(rr) && rr_col %in% names(rr)) {
    rr <- as.data.frame(rr)
    key <- function(d) do.call(paste, c(unname(as.list(d[units])), sep = "\r"))
    pick <- function(y) {
      r <- rr[rr$year == y, , drop = FALSE]
      r[[rr_col]][match(key(out), key(r))]
    }
    out$reporting_from <- pick(from_year)
    out$reporting_to <- pick(to_year)
  }
  out$reporting_flag <- !is.na(out$reporting_to) &
    (out$reporting_to < 75 | (!is.na(out$reporting_from) & out$reporting_from - out$reporting_to >= 10))

  total_change <- C1 - C0
  out <- out[order(if (isTRUE(total_change < 0)) out$contribution else -out$contribution), , drop = FALSE]
  rownames(out) <- NULL
  attr(out, "total") <- list(indicator = indicator, denominator = denominator, admin_level = admin_level,
                             region = region, from_year = from_year, to_year = to_year,
                             coverage_from = C0, coverage_to = C1, change = total_change,
                             reporting_column = rr_col)
  out
}

# ---- the manifest ------------------------------------------------------------------------------------------------

# An Rd node as plain text (conditional HTML/LaTeX output, usage blocks and nested subsections dropped).
.rd_text <- function(x) {
  if (is.character(x)) return(paste(x, collapse = ""))
  tag <- attr(x, "Rd_tag")
  if (!is.null(tag) && tag %in% c("\\if", "\\out", "\\subsection", "\\preformatted")) return("")
  if (is.list(x)) paste(vapply(x, .rd_text, ""), collapse = "") else ""
}
.rd_squish <- function(x) trimws(gsub("[[:space:]]+", " ", x))

# Every node with `tag` under `x`, depth first.
.rd_find <- function(x, tag) {
  found <- list()
  walk <- function(n) {
    if (!is.list(n)) return()
    if (identical(attr(n, "Rd_tag"), tag)) found[[length(found) + 1]] <<- n
    for (child in n) walk(child)
  }
  walk(x)
  found
}

# \describe{\item{\code{name}}{text}} -> named character vector
.rd_items <- function(x) {
  items <- Filter(function(i) length(i) >= 2, .rd_find(x, "\\item"))
  if (!length(items)) return(character())
  stats::setNames(vapply(items, function(i) .rd_squish(.rd_text(i[[2]])), ""),
                  vapply(items, function(i) .rd_squish(.rd_text(i[[1]])), ""))
}

# The documentation of CacheConnection's members, from its Rd: list(bindings = named text, methods = list(name ->
# list(description, arguments, returns))).
.cd_cache_docs <- function(rd = NULL) {
  rd <- rd %||% tryCatch(tools::Rd_db("cd2030.core")[["CacheConnection.Rd"]], error = function(e) NULL)
  if (is.null(rd)) return(list(bindings = character(), methods = list()))
  bindings <- character()
  methods <- list()
  for (s in .rd_find(rd, "\\section")) {
    title <- .rd_squish(.rd_text(s[[1]]))
    if (identical(title, "Active bindings")) bindings <- .rd_items(s[[2]])
    if (identical(title, "Methods")) {
      for (sub in .rd_find(s[[2]], "\\subsection")) {
        heading <- .rd_squish(.rd_text(sub[[1]]))
        if (!startsWith(heading, "Method ")) next
        name <- sub("\\(\\)$", "", sub("^Method ", "", heading))
        body <- sub[[2]]
        inner <- .rd_find(body, "\\subsection")
        inner_title <- vapply(inner, function(i) .rd_squish(.rd_text(i[[1]])), "")
        args <- if ("Arguments" %in% inner_title) .rd_items(inner[[which(inner_title == "Arguments")[1]]][[2]]) else character()
        returns <- if ("Returns" %in% inner_title) .rd_squish(.rd_text(inner[[which(inner_title == "Returns")[1]]][[2]])) else ""
        methods[[name]] <- list(description = .rd_squish(.rd_text(body)), arguments = args, returns = returns)
      }
    }
  }
  list(bindings = bindings, methods = methods)
}

# The values an argument may take, when the code says: a character default (c("a", "b")) or arg_match(x, c(...)).
.cd_arg_choices <- function(fn, arg) {
  if (is.call(formals(fn)[[arg]]) && identical(formals(fn)[[arg]][[1]], as.name("c"))) {
    vals <- tryCatch(eval(formals(fn)[[arg]], baseenv()), error = function(e) NULL)
    if (is.character(vals) && length(vals) > 1) return(vals)
  }
  found <- NULL
  walk <- function(e) {
    if (!is.null(found) || !is.call(e)) return()
    head <- paste(deparse(e[[1]]), collapse = "")
    if (head %in% c("arg_match", "rlang::arg_match", "match.arg") && length(e) >= 3 &&
        identical(paste(deparse(e[[2]]), collapse = ""), arg) && is.call(e[[3]]) && identical(e[[3]][[1]], as.name("c"))) {
      vals <- tryCatch(eval(e[[3]], baseenv()), error = function(err) NULL)
      if (is.character(vals)) found <<- vals
      return()
    }
    for (part in as.list(e)[-1]) walk(part)
  }
  walk(body(fn))
  found
}

#' What the Countdown AI knows of CacheConnection
#'
#' Every public member of `CacheConnection` -- method or active binding -- with its arguments (defaults, and the
#' values an argument may take when the code says), its documentation, whether it writes to the dataset, and whether
#' a custom chart may draw from it; plus the report kinds. Read from the installed package, so it always matches the
#' code; countdown-analytics builds its guide for the AI from it.
#'
#' @return A list (JSON-able with `jsonlite::toJSON(auto_unbox = TRUE)`): `package`, `version`, `generatedAt`,
#'   `members` and `reportKinds`.
#' @examples
#' m <- cache_manifest()
#' length(m$members)
#' @export
cache_manifest <- function() {
  cls <- get("CacheConnection", envir = asNamespace("cd2030.core"))
  docs <- .cd_cache_docs()
  chartable <- cd_chartable_members()

  method_entry <- function(name) {
    fn <- cls$public_methods[[name]]
    f <- formals(fn)
    doc <- docs$methods[[name]]
    args <- lapply(names(f), function(a) {
      # an argument without a default holds the empty symbol, which can't be kept in a variable
      no_default <- is.name(f[[a]]) && !nzchar(as.character(f[[a]]))
      entry <- list(name = a, required = no_default && !identical(a, "..."))
      if (!no_default && !identical(a, "...")) entry$default <- paste(deparse(f[[a]]), collapse = " ")
      choices <- .cd_arg_choices(fn, a)
      if (!is.null(choices)) entry$choices <- choices
      d <- unname(doc$arguments[a])
      if (length(d) && !is.na(d)) entry$description <- d
      entry
    })
    list(name = name, kind = "method",
         writes = startsWith(name, "set_") || name %in% c("save_to_disk", "load_from_disk", "adjust_data"),
         chartable = name %in% chartable, args = args, description = doc$description %||% "", returns = doc$returns %||% "")
  }
  binding_entry <- function(name) {
    d <- unname(docs$bindings[name])
    list(name = name, kind = "binding", writes = FALSE, chartable = name %in% chartable, args = list(),
         description = if (length(d) && !is.na(d)) d else "", returns = "")
  }

  methods <- setdiff(names(cls$public_methods), c("clone", "initialize"))
  bindings <- names(cls$active)
  all_kinds <- c(report_block_kinds("rmncah"), report_block_kinds("vaccine"))
  kinds <- lapply(unique(names(all_kinds)), function(k) c(list(id = k), all_kinds[[k]]))
  list(
    package = "cd2030.core",
    version = as.character(utils::packageVersion("cd2030.core")),
    generatedAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    members = c(lapply(methods, method_entry), lapply(bindings, binding_entry)),
    reportKinds = kinds
  )
}

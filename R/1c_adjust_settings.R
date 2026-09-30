# The data adjustment's settings: what is kept for analysis (years removed everywhere, and an area's data removed for
# some or every year) and how each indicator is corrected -- completeness (its k), outliers and missing values --
# everywhere, or with a region's or district's own settings (a district's win over its region's; what an area does not
# set follows everywhere). The Data Adjustment page edits them; CacheConnection keeps them (`adjustment_settings`);
# adjust_service_data() applies them.
#
#   removed_years  numeric: years left out everywhere
#   removals       list of list(area, level = "adminlevel_1" | "district", region, years): an area's data removed
#                  (its services and its population) for those years, or every year when `years` is empty
#   everywhere     list(group_k = named k per group, indicator_k = named k per indicator, outliers = named TRUE/FALSE,
#                  missing = named TRUE/FALSE)
#   areas          list of list(area, level, region, group_k, indicator_k, outliers, missing, all_outliers,
#                  all_missing, reported): an area's own settings (`all_*`: for every indicator it does not name)

#' The Countdown default adjustment settings
#'
#' Every indicator group adjusted for completeness with the method's k (0.25), outliers corrected and missing values
#' filled everywhere, no year or area removed.
#'
#' @param k The k of every group (by default the method's, `0.25`).
#' @param groups The groups that have a k (by default the app's, `cd_cfg("k_factors")`, else the method's).
#' @return The settings list (see [adjust_service_data()]).
#' @export
adjustment_settings_default <- function(k = .cd_method$adjustment$k, groups = NULL) {
  groups <- groups %||% .adjust_k_groups()
  list(
    removed_years = numeric(),
    removals = list(),
    everywhere = list(group_k = as.list(set_names(rep(k, length(groups)), groups)), indicator_k = list(),
                      outliers = list(), missing = list()),
    areas = list()
  )
}

# The groups that have a k: the app's (cd_cfg("k_factors")), else the selected group's own
.adjust_k_groups <- function() {
  cfg <- tryCatch(names(cd_cfg("k_factors")), error = function(e) NULL)
  if (length(cfg)) return(cfg)
  groups <- names(get_indicator_groups())
  setdiff(groups, "ipd")
}

#' Adjustment settings from the older k-factors and excluded years
#'
#' A dataset saved before the settings existed has only its k per group and its removed years: they become the
#' settings, everything else as the default.
#'
#' @param k_factors Named numeric k per group.
#' @param excluded_years Numeric years removed.
#' @return The settings list.
#' @export
adjustment_settings_from_k <- function(k_factors = NULL, excluded_years = numeric()) {
  s <- adjustment_settings_default()
  if (length(k_factors)) s$everywhere$group_k <- utils::modifyList(s$everywhere$group_k, as.list(k_factors))
  s$removed_years <- as.numeric(excluded_years %||% numeric())
  s
}

#' Check and tidy adjustment settings
#'
#' Validates settings as the Data Adjustment page sends them (JSON read with `simplifyVector = FALSE`) and returns them
#' in one shape: numbers as numbers, flags as logicals, empty maps as empty lists, unknown groups, indicators and
#' levels refused.
#'
#' @param settings The settings list.
#' @return The settings, tidied. An error says what is wrong.
#' @export
adjustment_settings_check <- function(settings) {
  if (!is.list(settings)) cd_abort(c("x" = "The adjustment settings must be a list."))
  groups <- names(get_indicator_groups())
  indicators <- unique(c(unlist(get_indicator_groups(), use.names = FALSE)))
  num <- function(x, what) {
    v <- suppressWarnings(as.numeric(unlist(x)))
    if (length(v) && any(is.na(v))) cd_abort(c("x" = "{what} must be numbers."))
    v
  }
  kmap <- function(x, allowed, what, drop_unknown = FALSE) {
    x <- x %||% list()
    if (!length(x)) return(list())
    if (is.null(names(x)) || any(!nzchar(names(x)))) cd_abort(c("x" = "{what} must be named."))
    bad <- setdiff(names(x), allowed)
    # a group this indicator group does not have (the method lists every group any app has): left out
    if (length(bad) && drop_unknown) x <- x[setdiff(names(x), bad)] else if (length(bad)) cd_abort(c("x" = "Unknown {what}: {.val {bad}}."))
    if (!length(x)) return(list())
    out <- lapply(x, function(v) num(v, what))
    if (any(vapply(out, function(v) length(v) != 1 || v < 0 || v > 1, logical(1)))) {
      cd_abort(c("x" = "A k-factor must be one number between 0 and 1."))
    }
    out
  }
  flags <- function(x, what) {
    x <- x %||% list()
    if (!length(x)) return(list())
    bad <- setdiff(names(x), indicators)
    if (length(bad)) cd_abort(c("x" = "Unknown indicators in {what}: {.val {bad}}."))
    lapply(x, function(v) isTRUE(as.logical(unlist(v))))
  }
  flag_or_null <- function(v) if (is.null(v) || !length(unlist(v))) NULL else isTRUE(as.logical(unlist(v)))
  level_of <- function(v) {
    v <- as.character(unlist(v) %||% "")
    if (!v %in% c("adminlevel_1", "district")) cd_abort(c("x" = "An area's level is {.val adminlevel_1} or {.val district}."))
    v
  }
  scope <- function(x, what) {
    list(group_k = kmap(x$group_k, groups, paste(what, "group k"), drop_unknown = TRUE), indicator_k = kmap(x$indicator_k, indicators, paste(what, "indicator k")),
         outliers = flags(x$outliers, paste(what, "outliers")), missing = flags(x$missing, paste(what, "missing values")))
  }
  every <- scope(settings$everywhere %||% list(), "everywhere")
  areas <- lapply(settings$areas %||% list(), function(a) {
    name <- as.character(unlist(a$area) %||% "")
    if (!nzchar(name)) cd_abort(c("x" = "An area's settings need the area's name."))
    c(list(area = name, level = level_of(a$level), region = if (length(unlist(a$region))) as.character(unlist(a$region)) else NULL),
      scope(a, name),
      list(all_outliers = flag_or_null(a$all_outliers), all_missing = flag_or_null(a$all_missing), reported = isTRUE(as.logical(unlist(a$reported)))))
  })
  removals <- lapply(settings$removals %||% list(), function(r) {
    name <- as.character(unlist(r$area) %||% "")
    if (!nzchar(name)) cd_abort(c("x" = "A removal needs the area's name."))
    list(area = name, level = level_of(r$level), region = if (length(unlist(r$region))) as.character(unlist(r$region)) else NULL,
         years = num(r$years, "A removal's years"))
  })
  list(removed_years = num(settings$removed_years, "The removed years"), removals = removals, everywhere = every, areas = areas)
}

# Each district's k, outlier and missing-value switches for each indicator: a data frame by district, with
# k__<ind>, out__<ind>, miss__<ind> columns (the scopes resolved: the district's own, its region's, everywhere's).
.adjust_plan <- function(districts, settings, indicators, outlier_indicators) {
  groups <- get_indicator_groups()
  group_of <- function(ind) names(keep(groups, ~ ind %in% .x))[1] %||% NA_character_
  k_default <- .cd_method$adjustment$k
  by_area <- function(level) {
    a <- Filter(function(x) identical(x$level, level), settings$areas)
    set_names(a, vapply(a, function(x) x$area, character(1)))
  }
  district_scopes <- by_area("district")
  region_scopes <- by_area("adminlevel_1")
  every <- settings$everywhere

  first <- function(...) { for (v in list(...)) if (!is.null(v)) return(v); NULL }
  resolve <- function(scopes, ind) {
    g <- group_of(ind)
    k <- NULL
    out <- NULL
    miss <- NULL
    for (sc in scopes) {
      if (is.null(sc)) next
      if (is.null(k)) k <- first(sc$indicator_k[[ind]], if (!is.na(g)) sc$group_k[[g]])
      if (is.null(out)) out <- first(sc$outliers[[ind]], sc$all_outliers)
      if (is.null(miss)) miss <- first(sc$missing[[ind]], sc$all_missing)
    }
    list(k = k %||% k_default, out = out %||% TRUE, miss = miss %||% TRUE)
  }
  rows <- lapply(seq_len(nrow(districts)), function(i) {
    d <- districts$district[[i]]
    r <- districts$adminlevel_1[[i]]
    scopes <- list(district_scopes[[d]], region_scopes[[r]], every)
    vals <- list()
    for (ind in union(indicators, outlier_indicators)) {
      v <- resolve(scopes, ind)
      if (ind %in% indicators) {
        vals[[paste0("k__", ind)]] <- as.numeric(v$k)
        vals[[paste0("miss__", ind)]] <- isTRUE(v$miss)
      }
      vals[[paste0("out__", ind)]] <- isTRUE(v$out)
    }
    tibble::as_tibble(c(list(district = d), vals))
  })
  dplyr::bind_rows(rows)
}

# The data with the settings' removals taken out: the years removed everywhere, and each removal's area (a region's
# districts, or a district) for its years (every year when none are given). Its population goes with it, since the
# population is on the same rows.
.adjust_remove <- function(.data, settings) {
  adminlevel_1 <- district <- year <- NULL
  if (length(settings$removed_years)) .data <- .data %>% filter(!year %in% settings$removed_years)
  for (r in settings$removals) {
    in_area <- if (identical(r$level, "district")) .data$district == r$area else .data$adminlevel_1 == r$area
    in_years <- if (length(r$years)) .data$year %in% r$years else rep(TRUE, nrow(.data))
    .data <- .data[!(in_area & in_years), , drop = FALSE]
  }
  .data
}

#' What the adjustment settings say, as the reports' footnote
#'
#' @param settings The settings list.
#' @param group_labels,indicator_labels Named character: how groups and indicators are called (by default their ids).
#' @return A character vector, one sentence per rule (none for the Countdown default).
#' @export
adjustment_settings_footnote <- function(settings, group_labels = NULL, indicator_labels = NULL) {
  settings <- adjustment_settings_check(settings)
  glab <- function(g) (group_labels %||% list())[[g]] %||% g
  ilab <- function(i) (indicator_labels %||% list())[[i]] %||% i
  out <- character()
  if (length(settings$removed_years)) out <- c(out, paste0(paste(sort(settings$removed_years), collapse = ", "), " removed everywhere."))
  for (r in settings$removals) {
    out <- c(out, paste0(r$area, " removed for ", if (length(r$years)) paste(sort(r$years), collapse = ", ") else "every year", " (services and population)."))
  }
  describe <- function(sc) {
    if (isTRUE(sc$reported)) return("kept as reported (no completeness, outlier or missing-value correction)")
    parts <- c(
      vapply(names(sc$group_k), function(g) paste0(glab(g), " k ", sc$group_k[[g]]), character(1)),
      vapply(names(sc$indicator_k), function(i) paste0(ilab(i), " k ", sc$indicator_k[[i]]), character(1))
    )
    no_out <- names(Filter(isFALSE, sc$outliers))
    no_miss <- names(Filter(isFALSE, sc$missing))
    if (isFALSE(sc$all_outliers)) parts <- c(parts, "no outlier correction") else if (length(no_out)) parts <- c(parts, paste0("no outlier correction for ", paste(vapply(no_out, ilab, character(1)), collapse = ", ")))
    if (isFALSE(sc$all_missing)) parts <- c(parts, "missing values not filled") else if (length(no_miss)) parts <- c(parts, paste0("missing values not filled for ", paste(vapply(no_miss, ilab, character(1)), collapse = ", ")))
    paste(parts, collapse = "; ")
  }
  every <- describe(settings$everywhere)
  if (nzchar(every)) out <- c(out, paste0("Everywhere: ", every, "."))
  for (a in settings$areas) {
    d <- describe(a)
    out <- c(out, paste0(a$area, ": ", if (nzchar(d)) paste0(d, "; the rest as everywhere") else "as everywhere", "."))
  }
  out
}

#' Which adjustment steps an indicator gets
#'
#' Whether completeness (a k above 0), outlier correction and filling missing values apply to an indicator in at
#' least one district of the data (or of one area), with the settings: a step no district gets is off.
#'
#' @param settings The settings list.
#' @param .data A `cd_data` tibble (its districts and regions).
#' @param indicator The indicator.
#' @param area,level One area only (as [generate_adjustment_values()]); `NULL`, all.
#' @return A named logical: `completeness`, `outliers`, `missing`.
#' @export
adjustment_steps_used <- function(settings, .data, indicator, area = NULL, level = c("adminlevel_1", "district")) {
  level <- arg_match(level)
  settings <- adjustment_settings_check(settings)
  districts <- dplyr::distinct(as.data.frame(.data)[, c("adminlevel_1", "district")])
  if (!is.null(area)) districts <- districts[districts[[if (level == "district") "district" else "adminlevel_1"]] %in% area, , drop = FALSE]
  if (!nrow(districts)) return(c(completeness = FALSE, outliers = FALSE, missing = FALSE))
  adjusted <- indicator %in% get_adjustment_indicators()
  plan <- .adjust_plan(districts, settings, if (adjusted) indicator else character(), indicator)
  col <- function(prefix) plan[[paste0(prefix, "__", indicator)]]
  c(
    completeness = adjusted && any(col("k") > 0, na.rm = TRUE),
    outliers = any(col("out"), na.rm = TRUE),
    missing = adjusted && any(col("miss"), na.rm = TRUE)
  )
}

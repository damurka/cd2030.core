#' What the data quality checks found, for the Data Adjustment page
#'
#' The numbers the Data Adjustment page shows beside its settings, from the same computations as the check pages
#' (Reporting rate, Outlier detection, Data completeness): each indicator group's national reporting rate in `year`
#' and how many districts report below `threshold`; each indicator's outlier months (more than 5 x MAD from the
#' district's median) and empty months; each region's and district's lowest group reporting rate in `year`.
#'
#' @param .data A `cd_data` tibble (the data before adjustment, its removed years already left out).
#' @param threshold The reporting threshold (percent) of the Reporting rate page.
#' @param year The year of the reporting rates (by default the latest).
#' @return A list: `year`, `threshold`, `groups` (named by group: `rr`, `below`), `indicators` (named by indicator:
#'   `outliers`, `missing`, months), `areas` (a list of `list(region, rr, districts = list(list(name, rr)))`).
#' @export
adjustment_evidence <- function(.data, threshold = .cd_method$data_quality$reporting_threshold, year = NULL) {
  check_cd_data(.data)
  yr <- year %||% robust_max(.data$year)
  groups <- names(get_indicator_groups())
  rate_cols <- intersect(paste0(groups, "_rr"), names(.data))

  at_year <- function(level) {
    d <- tryCatch(calculate_average_reporting_rate(.data, level), error = function(e) NULL)
    if (is.null(d)) return(NULL)
    as.data.frame(d[d$year == yr, , drop = FALSE])
  }
  national <- at_year("national")
  district <- at_year("district")
  region <- at_year("adminlevel_1")
  num <- function(v) if (length(v) && is.finite(v[[1]])) as.numeric(v[[1]]) else NULL
  lowest <- function(row) {
    v <- suppressWarnings(as.numeric(unlist(row[intersect(rate_cols, names(row))])))
    v <- v[is.finite(v)]
    if (length(v)) min(v) else NULL
  }

  group_rr <- list()
  for (g in groups) {
    col <- paste0(g, "_rr")
    if (!col %in% rate_cols) next
    group_rr[[g]] <- list(
      rr = if (!is.null(national) && nrow(national)) num(national[[col]]),
      below = if (!is.null(district) && col %in% names(district)) sum(district[[col]] < threshold, na.rm = TRUE)
    )
  }

  inds <- intersect(c(get_adjustment_indicators(), "ipd_total", "ipd_under5"), names(.data))
  flagged <- tryCatch(add_outlier5std_column(.data, inds), error = function(e) NULL)
  indicators <- lapply(set_names(inds), function(ind) {
    out_col <- paste0(ind, "_outlier5std")
    list(
      outliers = if (!is.null(flagged) && out_col %in% names(flagged)) sum(flagged[[out_col]] == 1, na.rm = TRUE),
      missing = sum(is.na(.data[[ind]]))
    )
  })

  areas <- list()
  if (!is.null(region) && !is.null(district)) {
    for (r in sort(unique(as.character(.data$adminlevel_1)))) {
      rrow <- region[region$adminlevel_1 == r, , drop = FALSE]
      drows <- district[district$adminlevel_1 == r, , drop = FALSE]
      names_d <- sort(unique(as.character(.data$district[.data$adminlevel_1 == r])))
      areas[[length(areas) + 1]] <- list(
        region = r,
        rr = if (nrow(rrow)) lowest(rrow[1, , drop = FALSE]),
        districts = lapply(names_d, function(dn) {
          row <- drows[drows$district == dn, , drop = FALSE]
          list(name = dn, rr = if (nrow(row)) lowest(row[1, , drop = FALSE]))
        })
      )
    }
  }

  list(year = yr, threshold = threshold, groups = group_rr, indicators = indicators, areas = areas)
}

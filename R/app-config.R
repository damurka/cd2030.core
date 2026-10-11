#' Read one of the app's settings
#'
#' The shared pages are the same in every Countdown app, and what differs between apps is kept in
#' one list of settings. An app sets the list once, in its `run_app()`, with
#' `options(cd2030.config = list(...))`, and the pages read the setting they need with `cd_cfg()`.
#' This way an app (RMNCAH, vaccine, or one for a custom indicator group) says what is particular to
#' it, and no shared page depends on a group's name.
#'
#' @details A setting may be a value or a function with no arguments that returns one. A function is
#' called each time the setting is read, so its answer can follow something that is only known
#' later, such as the indicator group.
#'
#' The settings the shared pages read (each page gives its own `default`):
#' * `nat_cov_indicators`: the tabs of the national and sub-national coverage pages. It may include
#'   `"fpet"`, which adds the family planning chart.
#' * `bayes_indicators`: the tabs of the Bayesian coverage model pages.
#' * `target_indicators`: the tabs of the coverage target pages.
#' * `equity_indicators`: the tabs of the Equity Assessment page. `equity_custom_exclude`: the
#'   indicators its Custom tab leaves out.
#' * `cov_trend_indicators`, `sub_derived_indicators`, `survey_comp_indicators`: the tabs of the
#'   three cards of the Denominator Selection page.
#' * `adjustment_indicators`: the tabs of the Data Adjustment Changes page.
#' * `k_factors`: the adjustment factors, as `list(name = list(id, label))`.
#' * `reporting_rate_indicators`, `reporting_rate_facet_ncol`: the Reporting Rate page's service
#'   chips and the number of columns of its national chart.
#' * `consistency_pairs`: a list of `c(x, y)` pairs of indicators, one tab of the Consistency Checks
#'   card each.
#' * `has_maternal`: whether the indicator group has a maternal denominator (see
#'   [cd_has_maternal()]).
#'
#' @param key The setting's name, a string.
#' @param default What to return when the app has not set `key`, or has set it to `NULL`. Default
#'   `NULL`.
#'
#' @return The setting's value. When the setting is a function, the value that function returns.
#'   When the setting is not set, `default`.
#'
#' @examples
#' old <- options(cd2030.config = list(
#'   target_indicators = c("penta3", "measles1"),
#'   equity_indicators = function() c("anc4", "penta3")
#' ))
#'
#' cd_cfg("target_indicators")
#' cd_cfg("equity_indicators")
#' cd_cfg("consistency_pairs", default = list())
#'
#' options(old)
#'
#' @concept Countdown app frame
#' @export
cd_cfg <- function(key, default = NULL) {
  value <- getOption("cd2030.config")[[key]]
  if (is.null(value)) return(default)
  if (is.function(value)) value() else value
}

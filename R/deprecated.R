#' Functions under their former names
#'
#' The functions that take one indicator out of a computed table, ready to plot, were named `filter_*()`. They are
#' `select_*()` now (they choose an indicator and reshape; they do not filter rows as [dplyr::filter()] does). The
#' former names still work and say once per session what to call instead; they will be removed in a later version.
#'
#' | Former name | Now |
#' |---|---|
#' | `filter_adjustment_value()` | [select_adjustment_value()] |
#' | `filter_coverage()` | [select_coverage()] |
#' | `filter_inequality()` | [select_inequality()] |
#' | `filter_mapping_data()` | [select_mapping_data()] |
#' | `filter_mortality_summary()` | [select_mortality_summary()] |
#' | `filter_service_utilization()` | [select_service_utilization()] |
#'
#' @param ... Passed to the function under its present name.
#' @return What the function under its present name returns.
#' @name cd2030-deprecated
#' @keywords internal
NULL

# A function under its former name: says so once per session, then calls the present one.
.cd_renamed <- function(old, new) {
  force(old)
  force(new)
  function(...) {
    warn(
      c(paste0("`", old, "()` is now `", new, "()`."), "i" = "The former name will be removed in a later version."),
      class = "cd2030_deprecated", .frequency = "once", .frequency_id = paste0("cd2030.core-", old)
    )
    get(new, envir = asNamespace("cd2030.core"))(...)
  }
}

#' @rdname cd2030-deprecated
#' @export
filter_adjustment_value <- .cd_renamed("filter_adjustment_value", "select_adjustment_value")

#' @rdname cd2030-deprecated
#' @export
filter_coverage <- .cd_renamed("filter_coverage", "select_coverage")

#' @rdname cd2030-deprecated
#' @export
filter_inequality <- .cd_renamed("filter_inequality", "select_inequality")

#' @rdname cd2030-deprecated
#' @export
filter_mapping_data <- .cd_renamed("filter_mapping_data", "select_mapping_data")

#' @rdname cd2030-deprecated
#' @export
filter_mortality_summary <- .cd_renamed("filter_mortality_summary", "select_mortality_summary")

#' @rdname cd2030-deprecated
#' @export
filter_service_utilization <- .cd_renamed("filter_service_utilization", "select_service_utilization")

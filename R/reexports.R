# Chart options now live in datasuite.ui; cd2030.core imports them for its plots and re-exports them, so code that calls
# them through cd2030.core keeps working.

#' @importFrom datasuite.ui cd_chart_options apply_chart_options merge_chart_options resolve_chart_options
#' @importFrom datasuite.ui as_chart_options chart_facet_info cd_chart_type
#' @export
datasuite.ui::cd_chart_options

#' @export
datasuite.ui::apply_chart_options

#' @export
datasuite.ui::merge_chart_options

#' @export
datasuite.ui::resolve_chart_options

#' @export
datasuite.ui::as_chart_options

#' @export
datasuite.ui::chart_facet_info

#' @export
datasuite.ui::cd_chart_type

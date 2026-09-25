# Chart options and the report builder live in datasuite.ui; cd2030.core imports them for its plots and reports and
# re-exports them, so code that calls them through cd2030.core keeps working.

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

#' @importFrom datasuite.ui export_deck export_report render_report_block report_asset_data_url report_block_size report_chart_fields report_converter report_deck_converter report_deck_layouts
#' @importFrom datasuite.ui report_default_cover report_default_design report_field_catalog report_fields report_final_pages report_flag_file report_fonts report_page report_project_blocks
#' @importFrom datasuite.ui report_resolve_block report_slide_size report_store_asset report_theme_from_file report_themes save_report_chart with_report_chart_options
NULL

#' @export
datasuite.ui::export_deck

#' @export
datasuite.ui::export_report

#' @export
datasuite.ui::render_report_block

#' @export
datasuite.ui::report_asset_data_url

#' @export
datasuite.ui::report_block_size

#' @export
datasuite.ui::report_chart_fields

#' @export
datasuite.ui::report_converter

#' @export
datasuite.ui::report_deck_converter

#' @export
datasuite.ui::report_deck_layouts

#' @export
datasuite.ui::report_default_cover

#' @export
datasuite.ui::report_default_design

#' @export
datasuite.ui::report_field_catalog

#' @export
datasuite.ui::report_fields

#' @export
datasuite.ui::report_final_pages

#' @export
datasuite.ui::report_flag_file

#' @export
datasuite.ui::report_fonts

#' @export
datasuite.ui::report_page

#' @export
datasuite.ui::report_project_blocks

#' @export
datasuite.ui::report_resolve_block

#' @export
datasuite.ui::report_slide_size

#' @export
datasuite.ui::report_store_asset

#' @export
datasuite.ui::report_theme_from_file

#' @export
datasuite.ui::report_themes

#' @export
datasuite.ui::save_report_chart

#' @export
datasuite.ui::with_report_chart_options

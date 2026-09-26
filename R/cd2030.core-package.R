#' cd2030.core: Countdown to 2030 analysis of routine health facility data
#'
#' @description
#' Loads a country's routine facility data (the Countdown Excel workbook, or a Stata `.dta` master file), checks its
#' quality, adjusts it for incomplete reporting and outliers, chooses denominators, and computes coverage, inequality,
#' mortality, service utilization, health system and family planning indicators, with a chart (`plot()`) for each
#' result. The Countdown apps -- cd2030.rmncah, cd2030.vaxx and cd2030.pooled -- are Shiny front ends to it, built from
#' the pages, wizard and app frame it exports, on datasuite.ui's interface kit and report builder.
#'
#' @section Where to start:
#' * **A dataset:** [load_cache_data()] opens a workbook or a saved `.rds` as a [CacheConnection], the object that holds
#'   one dataset and every choice made about it (adjustments, denominators, surveys, mappings, chart options, saved
#'   reports) and saves them to the `.rds` next to the data file. [load_data()] gives just the checked data;
#'   [init_CacheConnection()] makes the object from data or an `.rds`.
#' * **Data quality:** [calculate_average_reporting_rate()], [calculate_completeness_summary()],
#'   [calculate_outliers_summary()], [calculate_ratios_summary()], [calculate_overall_score()]; the Load Data
#'   wizard's checks, [run_all_quality_checks()].
#' * **Adjustment:** [generate_adjustment_values()], [adjust_service_data()].
#' * **Denominators and coverage:** [prepare_population_metrics()], [calculate_indicator_coverage()],
#'   [calculate_coverage()], [calculate_inequality()].
#' * **Further analyses:** [create_mortality_summary()], [compute_service_utilization()],
#'   [calculate_health_system_metrics()], [generate_fpet_summary()], [generate_bayes_model()].
#' * **Reports:** [report_presets()] (the standard reports) and [export_report()] (Word, PDF, PowerPoint).
#' * **Indicator groups:** [list_indicator_groups()], [set_selected_group()], [register_indicator_group()].
#' * **Apps:** [countdown-pages] (`cd_app()` and the pages every Countdown app shares).
#' * **AI analysis:** [cd2030_mcp_server()].
#'
#' The README (<https://github.com/damurka/cd2030.core>) explains how the packages fit together, how an app is built on
#' this one, and how to develop and release it.
#'
#' @keywords internal
#' @import dplyr
#' @import flextable
#' @import ggplot2
#' @import officer
#' @import rlang
#' @import tidyr
#' @importFrom stats as.formula lm median na.omit quantile reorder setNames
#' @importFrom utils modifyList
"_PACKAGE"

## usethis namespace: start
#' @importFrom forcats fct_inorder
#' @importFrom forcats fct_reorder
#' @importFrom haven as_factor
#' @importFrom haven is.labelled
#' @importFrom haven read_dta
#' @importFrom haven write_dta
#' @importFrom htmltools HTML
#' @importFrom janitor make_clean_names
#' @importFrom lubridate month
#' @importFrom lubridate year
#' @importFrom lubridate ym
#' @importFrom lubridate ymd
#' @importFrom openxlsx addStyle
#' @importFrom openxlsx addWorksheet
#' @importFrom openxlsx createStyle
#' @importFrom openxlsx createWorkbook
#' @importFrom openxlsx freezePane
#' @importFrom openxlsx groupRows
#' @importFrom openxlsx mergeCells
#' @importFrom openxlsx saveWorkbook
#' @importFrom openxlsx setColWidths
#' @importFrom openxlsx setRowHeights
#' @importFrom openxlsx writeData
#' @importFrom purrr compact
#' @importFrom purrr imap
#' @importFrom purrr imap_chr
#' @importFrom purrr imap_dfc
#' @importFrom purrr keep
#' @importFrom purrr list_c
#' @importFrom purrr list_merge
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom purrr map_df
#' @importFrom purrr map_int
#' @importFrom purrr map_lgl
#' @importFrom purrr map2_dbl
#' @importFrom purrr pwalk
#' @importFrom purrr reduce
#' @importFrom purrr set_names
#' @importFrom purrr walk
#' @importFrom RColorBrewer brewer.pal
#' @importFrom readr read_csv
#' @importFrom readxl excel_sheets
#' @importFrom readxl read_excel
#' @importFrom sf st_as_sf
#' @importFrom sf st_make_valid
#' @importFrom sf st_read
#' @importFrom sf st_set_crs
#' @importFrom sf st_set_geometry
#' @importFrom sf st_transform
#' @importFrom stringr fixed
#' @importFrom stringr str_detect
#' @importFrom stringr str_ends
#' @importFrom stringr str_extract
#' @importFrom stringr str_glue
#' @importFrom stringr str_remove
#' @importFrom stringr str_replace
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_split
#' @importFrom stringr str_starts
#' @importFrom stringr str_to_lower
#' @importFrom stringr str_to_title
#' @importFrom stringr str_to_upper
#' @importFrom tibble new_tibble
#' @importFrom tibble tbl_sum
## usethis namespace: end
NULL

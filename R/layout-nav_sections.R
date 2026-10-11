#' The standard sidebar sections of a Countdown app
#'
#' The parts of the sidebar every Countdown app shares. An app builds its nav tree from them, adds
#' its own groups, and passes the list to [cd_app()] as `nav_sections`. Each link opens the screen
#' whose id is the link's tab name (the names are listed below), so the app must have a page with
#' that id.
#'
#' @details
#' * `cd_nav_start()`: the "start" section, with the Introduction (`introduction`) and Load Data
#'   (`upload_data`) screens.
#' * `cd_nav_quality()`: the data quality section. One group holds `reporting_rate`,
#'   `outlier_detection`, `data_completeness`, `internal_consistency` and `overall_score`. A second
#'   group holds `data_adjustment` and `data_adjustment_changes`.
#' * `cd_nav_denominators()`: the denominators section, with `denominator_assessment` and
#'   `denominator_selection`.
#' * `cd_nav_national()`: the National Analysis group, with `national_coverage`, `national_target`,
#'   the items in `extra`, and a group for inequality holding `national_inequality` and
#'   `equity_assessment`.
#' * `cd_nav_subnational()`: the Sub-National Analysis group, with `subnational_coverage`,
#'   `subnational_inequality` and `subnational_target`.
#'
#' The first three are whole sections. The last two are groups of links: put them inside a section
#' of the app's own, made with `cd_nav_section()`.
#'
#' Everything from the denominators down is marked `requires_adjustment = TRUE`: those links stay
#' locked until the data is adjusted.
#'
#' The labels are translated with the translator the app registered with `cd_use_i18n()`, so call
#' these after it.
#'
#' @return `cd_nav_start()`, `cd_nav_quality()` and `cd_nav_denominators()` each return a nav
#'   section, as `cd_nav_section()` makes one: a list with the section's `label` and its `items`.
#'
#'   `cd_nav_national()` and `cd_nav_subnational()` each return a nav item, as `cd_nav_item()` makes
#'   one: a group whose `children` are the links.
#'
#' @examples
#' \dontrun{
#' nav <- list(
#'   cd_nav_start(),
#'   cd_nav_quality(),
#'   cd_nav_denominators(),
#'   cd_nav_section("lbl_nav_section_analysis", cd_nav_national(), cd_nav_subnational())
#' )
#' }
#'
#' @concept Countdown app layout
#' @export
cd_nav_start <- function() {
  cd_nav_section("lbl_nav_section_start",
    cd_nav_item("title_global_intro", tabName = "introduction", icon = "info-circle"),
    cd_nav_item("title_nav_load_data", tabName = "upload_data", icon = "upload")
  )
}

#' @rdname cd_nav_start
#' @export
cd_nav_quality <- function() {
  cd_nav_section("lbl_nav_section_quality",
    cd_nav_item("title_nav_quality", icon = "check-circle", children = list(
      cd_nav_item("title_rr_main", tabName = "reporting_rate", icon = "chart-bar"),
      cd_nav_item("title_outlier_main", tabName = "outlier_detection", icon = "exclamation-triangle"),
      cd_nav_item("title_complete_main", tabName = "data_completeness", icon = "check-square"),
      # a balanced scale is what "internally consistent" looks like
      cd_nav_item("title_consist_main", tabName = "internal_consistency", icon = "scale-balanced"),
      cd_nav_item("title_score_main", tabName = "overall_score", icon = "star")
    )),
    # Sliders for the group, a pencil for applying an adjustment, a clock for the log of past ones -- they used to be
    # the same icon. (pen-to-square has an outline weight in Font Awesome Free, unlike toggle-on.)
    cd_nav_item("title_adjust_main", icon = "sliders", children = list(
      cd_nav_item("title_adjust_main", tabName = "data_adjustment", icon = "pen-to-square"),
      cd_nav_item("title_adjust_changes", tabName = "data_adjustment_changes", icon = "clock-rotate-left")
    ))
  )
}

#' @rdname cd_nav_start
#' @export
cd_nav_denominators <- function() {
  # requires_adjustment = TRUE on every item from here down: unadjusted data cannot drive the denominator and
  # analysis pages, so they stay locked (greyed out) until Data Adjustment has been run.
  cd_nav_section("lbl_nav_section_denominators",
    cd_nav_item("title_denom_pop_trend", tabName = "denominator_assessment", icon = "chart-line", requires_adjustment = TRUE),
    cd_nav_item("title_denom_selection", tabName = "denominator_selection", icon = "filter", requires_adjustment = TRUE)
  )
}

#' @rdname cd_nav_start
#' @param extra A list of more nav items (`cd_nav_item()`) for the National Analysis group, placed
#'   after the coverage target link and before the inequality group. The RMNCAH app adds its
#'   Continuum of Care page this way. Default `list()`, none.
#' @export
cd_nav_national <- function(extra = list()) {
  cd_nav_item("title_nav_national_analysis", icon = "flag", requires_adjustment = TRUE, children = c(
    list(
      # chart-area, not chart-line: chart-line is Population Trend's icon
      cd_nav_item("title_coverage_national", tabName = "national_coverage", icon = "chart-area"),
      cd_nav_item("title_nav_global_coverage", tabName = "national_target", icon = "bullseye")
    ),
    extra,
    list(
      cd_nav_item("title_inequ_national", icon = "scale-unbalanced", children = list(
        cd_nav_item("title_routine_data", tabName = "national_inequality", icon = "clipboard-list"),
        cd_nav_item("title_survey_data", tabName = "equity_assessment", icon = "users")
      ))
    )
  ))
}

#' @rdname cd_nav_start
#' @export
cd_nav_subnational <- function() {
  cd_nav_item("title_nav_subnational_analysis", icon = "map", requires_adjustment = TRUE, children = list(
    cd_nav_item("title_nav_subnational_coverage", tabName = "subnational_coverage", icon = "map-marked"),
    # scale-unbalanced-flip: the mirror image of National Inequality's scale-unbalanced
    cd_nav_item("title_inequ_subnational", tabName = "subnational_inequality", icon = "scale-unbalanced-flip"),
    cd_nav_item("title_nav_global_coverage", tabName = "subnational_target", icon = "bullseye")
  ))
}

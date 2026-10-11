#' Data quality step of the Load Data wizard
#'
#' Shows the result of every data quality check on the loaded dataset as a list of rows, each
#' marked as passed or as a warning, with an explanation in a tooltip. The checks come from
#' [run_all_quality_checks()]. The user enters nothing here and nothing is saved to the dataset.
#' A button in the card's toolbar downloads every issue found as an Excel workbook
#' ([write_quality_issues()]). The step counts as complete when every check of severity
#' `"blocking"` has passed (see [step_quality_complete()]).
#'
#' @details
#' The rows are in three parts:
#' * the blocking checks: the file and its sheets (always shown as passed, because the wizard
#'   cannot reach this step when the file could not be read), the admin sheet's columns, the
#'   required columns, a single country, a recognised country, districts across sheets, district
#'   consistency, and missing or invalid months;
#' * the informational checks, which never block: population against reported births, reported
#'   live births equal to the population's live births in every month, indicators with no data,
#'   and month names written in more than one way;
#' * the mapping checks, which never block: admin level 1 names that do not match the survey or
#'   the shapefile.
#'
#' A row is left out when the check did not run. A dataset loaded already merged (a Stata file,
#' or a saved copy without stored results) only has the checks that run on merged data.
#'
#' One check is not part of this step: that every indicator the group needs is present. It runs
#' when the user presses Finish, because it reads columns that only exist after the sheets are
#' merged.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @return `data_quality_ui()` returns the UI as Shiny tags: a card that holds the list of checks
#'   and the download button. `data_quality_server()` is called for its side effects and returns
#'   nothing useful.
#' @examples
#' \dontrun{
#' # in the server of the Load Data screen, where `cache` is a reactive holding the dataset:
#' # the step's page, for wizard_steps_server(), and its server
#' panel <- list(key = "quality", ui = data_quality_ui(ns("data_quality"), i18n))
#' data_quality_server("data_quality", cache, i18n)
#' }
#' @concept Countdown app wizard
#' @export
data_quality_ui <- function(id, i18n) {
  # The text of this step is translated on the server (i18n$t() with str_glue_data()): it is
  # rendered with renderUI(), which the page's translator re-translates on a language switch.
  ns <- NS(id)

  cd_card(
    title = i18n$t("title_upload_data_quality"),
    subtitle = i18n$t("sub_upload_data_quality"),
    status = "success",
    solidHeader = TRUE,
    width = 12,
    toolbar = cd_download_button_ui(ns("download_issues")),
    cd_spinner(uiOutput(ns("checklist")))
  )
}

#' @rdname data_quality_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @export
data_quality_server <- function(id, cache, i18n) {
  stopifnot(is.reactive(cache))

  moduleServer(
    id = id,
    module = function(input, output, session) {

      # A pass/warn row, shared shape for the dynamic sections below -- mirrors the static rows'
      # own icon-plus-text layout (cd-wizard-dq-row), just with a warning-state modifier and an
      # optional second line of detail instead of always being a plain pass. `info_key` (optional):
      # a translation key with a longer "what this measures and how" explanation. Rather than a
      # separate icon next to the text, the row's OWN pass/fail glyph doubles as the tooltip trigger
      # (cd_tooltip(status=...), Tooltip.tsx) -- hovering (or focusing/clicking, for keyboard and
      # touch) the tick/warning icon a user is already looking at reveals the explanation, instead of
      # adding a second interactive element to each row. Falls back to the plain, non-interactive
      # icon when no info_key is given.
      dq_row <- function(ok, pass_text, warn_text, info_key = NULL) {
        div(
          class = paste("cd-wizard-dq-row", if (!ok) "cd-wizard-dq-row--warn"),
          if (!is.null(info_key)) {
            cd_tooltip(info_key, i18n = i18n, status = if (ok) "pass" else "warn")
          } else {
            icon(if (ok) "circle-check" else "triangle-exclamation",
                 class = paste("cd-wizard-dq-row__icon", if (ok) "cd-wizard-dq-row__icon--pass" else "cd-wizard-dq-row__icon--warn"))
          },
          div(if (ok) pass_text else warn_text)
        )
      }

      # The blocking checks' own `detail` (0_data_quality_checks.R) is already a complete,
      # pre-formatted (English-only -- a real, accepted limitation, same as any R condition message
      # surfaced elsewhere in this app) sentence built server-side via cd_fmt(), not raw data --
      # shown directly, not run through i18n templating the way the other 4 checks' raw detail is.
      # `r` is NULL, not skipped by the caller, whenever run_all_quality_checks() took the OTHER
      # branch than the one this particular row belongs to (e.g. a resumed .rds/edit-mode cache,
      # where only the 3 original post-merge checks exist in `results` -- see this file's own header
      # comment) -- returning NULL here (nothing rendered) rather than a misleading always-red row.
      dq_prose_row <- function(r, pass_key, info_key = NULL) {
        if (is.null(r)) return(NULL)
        dq_row(isTRUE(r$ok), i18n$t(pass_key), paste(r$detail, collapse = " "), info_key)
      }

      # The other 4 checks return raw data (a tibble or a character vector of names) as their own
      # `detail` -- this fills {n}/{fields} into this step's own translated warn template.
      dq_data_row <- function(r, pass_key, warn_key, info_key = NULL) {
        detail <- r$detail
        n <- if (is.data.frame(detail)) nrow(detail) else length(detail)
        fields <- if (is.character(detail)) paste(detail, collapse = ", ") else NA
        dq_row(isTRUE(r$ok), i18n$t(pass_key), str_glue_data(list(n = n, fields = fields), i18n$t(warn_key)), info_key)
      }

      # check_month_language_consistency()'s own `detail` is a 2-column tibble (month, variants) --
      # not a plain data-frame-row-count or a flat character vector the way dq_data_row() above
      # expects, so it gets its own small formatter: one "January (Janvier, January)" style line per
      # affected month, comma-joined.
      dq_month_language_row <- function(r, pass_key, warn_key, info_key = NULL) {
        if (is.null(r)) return(NULL)
        detail <- r$detail
        n <- nrow(detail)
        fields <- if (n > 0) {
          paste(paste0(detail$month, " (", detail$variants, ")"), collapse = "; ")
        } else {
          NA
        }
        dq_row(isTRUE(r$ok), i18n$t(pass_key), str_glue_data(list(n = n, fields = fields), i18n$t(warn_key)), info_key)
      }

      # What every row below shows, and what the download writes
      quality_results <- reactive({
        req(cache())
        run_all_quality_checks(cache())
      })

      # Every issue, in full, as a workbook: a row of the list says how many districts or names a check found
      # and names the first of them; someone fixing the file needs them all (write_quality_issues()).
      cd_download_button_server(
        id = "download_issues",
        filename = reactive("data-quality-issues"),
        extension = reactive("xlsx"),
        data = quality_results,
        i18n = i18n,
        label = "btn_dq_download_issues",
        icon = "table",
        button_class = "cd-tool-btn",
        content = function(file, results) {
          keys <- c(
            admin_columns = "chk_dq_admin_columns", required_columns = "chk_dq_required_columns",
            single_country = "chk_dq_single_country", country_recognized = "chk_dq_country_match",
            district_cross_sheet = "chk_dq_district_cross_sheet", district_consistency = "chk_dq_district_consistency",
            month_presence = "chk_dq_month_presence", month_validity = "chk_dq_month_validity",
            population_vs_births = "chk_dq_population_vs_births"
          )
          write_quality_issues(results, file, labels = vapply(keys, function(k) i18n$t(k), character(1)))
        }
      )

      output$checklist <- renderUI({
        results <- quality_results()

        # The one check that's still a genuine, unconditional parse-time abort (see this file's own
        # header comment) -- reaching this screen at all already means it passed.
        passed_keys <- c("chk_dq_files_sheets")
        all_blocking_ok <- all(vapply(results, function(r) !identical(r$severity, "blocking") || isTRUE(r$ok), logical(1)))

        tagList(
          if (all_blocking_ok) {
            div(class = "cd-wizard-dq-banner", icon("circle-check"), i18n$t("msg_dq_all_passed"))
          } else {
            div(class = "cd-wizard-dq-banner cd-wizard-dq-banner--warn", icon("triangle-exclamation"), i18n$t("msg_dq_issues_found"))
          },
          div(
            class = "cd-wizard-dq-list",
            lapply(passed_keys, function(k) {
              div(
                class = "cd-wizard-dq-row",
                cd_tooltip("pop_dq_files_sheets", i18n = i18n, status = "pass"),
                div(i18n$t(k))
              )
            }),
            dq_prose_row(results$admin_columns, "chk_dq_admin_columns", "pop_dq_admin_columns"),
            dq_prose_row(results$required_columns, "chk_dq_required_columns", "pop_dq_required_columns"),
            dq_prose_row(results$single_country, "chk_dq_single_country", "pop_dq_single_country"),
            dq_prose_row(results$country_recognized, "chk_dq_country_match", "pop_dq_country_match"),
            dq_prose_row(results$district_cross_sheet, "chk_dq_district_cross_sheet", "pop_dq_district_cross_sheet"),
            dq_prose_row(results$district_consistency, "chk_dq_district_consistency", "pop_dq_district_consistency"),
            dq_prose_row(results$month_presence, "chk_dq_month_presence", "pop_dq_month_presence"),
            dq_prose_row(results$month_validity, "chk_dq_month_validity", "pop_dq_month_validity")
          ),
          div(
            class = "cd-wizard-dq-upcoming",
            tags$div(class = "cd-wizard-dq-upcoming__label", i18n$t("lbl_dq_informational")),
            div(
              class = "cd-wizard-dq-list",
              # Moved out of the blocking list above (severity is now "informational" in cd2030.core --
              # see check_population_vs_births()'s own call site there): a live population-vs-reported-births
              # gap can be a real problem, but can just as easily be legitimate (migration, cross-boundary
              # catchment areas, a stale population estimate), so it's the user's own call, not something
              # that should stop them finishing the wizard. Still dq_prose_row(), not dq_data_row() -- its
              # `detail` is the same pre-formatted sentence the blocking checks use, not a tibble/character
              # vector dq_data_row()'s {n}/{fields} template expects.
              dq_prose_row(results$population_vs_births, "chk_dq_population_vs_births", "pop_dq_population_vs_births"),
              dq_data_row(results$population_service_collision, "msg_dq_collision_pass", "msg_dq_collision_warn", "pop_dq_collision"),
              dq_data_row(results$indicator_emptiness, "msg_dq_emptiness_pass", "msg_dq_emptiness_warn", "pop_dq_emptiness"),
              dq_month_language_row(results$month_language_consistency, "msg_dq_month_language_pass", "msg_dq_month_language_warn", "pop_dq_month_language")
            )
          ),
          div(
            class = "cd-wizard-dq-upcoming",
            tags$div(class = "cd-wizard-dq-upcoming__label", i18n$t("lbl_dq_mapping")),
            div(
              class = "cd-wizard-dq-list",
              dq_data_row(results$survey_admin_names, "msg_dq_survey_names_pass", "msg_dq_survey_names_warn", "pop_dq_survey_names"),
              dq_data_row(results$shapefile_admin_names, "msg_dq_shapefile_names_pass", "msg_dq_shapefile_names_warn", "pop_dq_shapefile_names")
            )
          )
        )
      })
    }
  )
}

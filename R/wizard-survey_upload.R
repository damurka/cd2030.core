#' Survey files step of the Load Data wizard
#'
#' An optional step where the user can upload the country's survey data in place of the built-in
#' survey data. It has one upload zone per file, each a Stata file (`.dta`): national, regional,
#' area, maternal education and wealth index quintile. The files can be uploaded one at a time,
#' and a file is recognised by the zone it is dropped into, not by its name. Each file is read
#' for the dataset's country and saved with `cache()$set_national_survey()`,
#' `cache()$set_regional_survey()`, `cache()$set_area_survey()`,
#' `cache()$set_education_survey()` or `cache()$set_wiq_survey()`. A zone's reset button goes
#' back to the built-in data (`cache()$clear_national_survey()` and so on). The step counts as
#' complete when all five files are uploaded (see [step_survey_files_complete()]); being
#' optional, it can be skipped.
#'
#' @details
#' The national and regional files are read with [load_survey_data()], the other three with
#' [load_equity_data()]. A file that cannot be read shows an error banner under its zone. When
#' the user has uploaded a regional survey whose region names do not all match the dataset's
#' admin level 1 names (`cache()$check_survey_admin_names()`), a warning under the zones gives
#' the number of names that do not match; the Map Survey Files step resolves them.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @return `survey_upload_ui()` returns the UI as Shiny tags: a card with the five upload zones.
#'   `survey_upload_server()` is called for its side effects and returns nothing useful.
#' @examples
#' \dontrun{
#' # in the server of the Load Data screen, where `cache` is a reactive holding the dataset:
#' # the step's page, for wizard_steps_server(), and its server
#' panel <- list(key = "survey_files", ui = survey_upload_ui(ns("survey_upload"), i18n))
#' survey_upload_server("survey_upload", cache, i18n)
#' }
#' @concept Countdown app wizard
#' @export
survey_upload_ui <- function(id, i18n) {
  ns <- NS(id)

  cd_card(
    title = i18n$t("title_upload_group_survey_dir"),
    subtitle = i18n$t("sub_upload_group_survey_dir"),
    status = "success",
    solidHeader = TRUE,
    width = 12,
    div(
      class = "cd-field-grid",
      div(
        class = "cd-field-stack",
        cd_file_upload(ns("national_file"), label = "title_upload_req_national", hint = "hint_upload_dta_format", accept = ".dta", i18n = i18n),
        uiOutput(ns("national_error"))
      ),
      div(
        class = "cd-field-stack",
        cd_file_upload(ns("regional_file"), label = "title_upload_req_regional", hint = "hint_upload_dta_format", accept = ".dta", i18n = i18n),
        uiOutput(ns("regional_error"))
      ),
      div(
        class = "cd-field-stack",
        cd_file_upload(ns("area_file"), label = "title_upload_req_area", hint = "hint_upload_dta_format", accept = ".dta", i18n = i18n),
        uiOutput(ns("area_error"))
      ),
      div(
        class = "cd-field-stack",
        cd_file_upload(ns("education_file"), label = "title_upload_req_education", hint = "hint_upload_dta_format", accept = ".dta", i18n = i18n),
        uiOutput(ns("education_error"))
      ),
      div(
        class = "cd-field-stack",
        cd_file_upload(ns("wiq_file"), label = "title_upload_req_wealth", hint = "hint_upload_dta_format", accept = ".dta", i18n = i18n),
        uiOutput(ns("wiq_error"))
      )
    ),
    uiOutput(ns("name_mismatch_alert"))
  )
}

#' @rdname survey_upload_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @export
survey_upload_server <- function(id, cache, i18n) {
  stopifnot(is.reactive(cache))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      country_iso <- reactive({
        req(cache())
        cache()$country_iso
      })

      # The originally-uploaded filename for each field, THIS session only -- see reference_estimates.R's own
      # push_upload_on_remount() comment (sourced before this file, module load order in 0_upload_data.R) for
      # why these exist and what they fix: without them, a zone that's torn down and rebuilt mid-session (a
      # landing-page Edit link) has no way to show it already has a real, non-default file on it -- explicit
      # user report, "some survey files were uploaded but not visible when editing."
      national_filename <- reactiveVal(NULL)
      regional_filename <- reactiveVal(NULL)
      area_filename <- reactiveVal(NULL)
      education_filename <- reactiveVal(NULL)
      wiq_filename <- reactiveVal(NULL)

      # Error only, same convention reference_estimates.R's own zones settled on -- a successful upload is
      # shown by the zone itself switching to its "already uploaded" state (cd_set_file_upload()), not a
      # separate "Upload successful" banner underneath it.
      upload_error <- function(output_id, e) {
        output[[output_id]] <- renderUI({
          clean_message <- clean_error_message(e)
          cd_status_banner("error", "title_msg_error", str_glue_data(list(clean_message = clean_message), i18n$t("err_upload_failed_general")), i18n = i18n)
        })
      }

      # One observer per zone -- each identifies its own file by WHICH ZONE it landed in, not by matching a
      # filename pattern (the old single-folder upload's only way to tell the 5 files apart), so these are
      # deliberately not deduplicated into one parameterized helper: cd2030.core:::check_file_path()'s own
      # `call` argument wants the CALLING frame for a useful error location, and load_survey_data() (national/
      # regional) takes a different signature (admin_level) than load_equity_data() (area/education/wiq) --
      # collapsing that into one generic dispatcher would trade this file's own readability for not much.
      observeEvent(input$national_file, {
        req(cache(), input$national_file)
        file_path <- input$national_file$datapath
        file_name <- input$national_file$name
        output$national_error <- renderUI(NULL)

        tryCatch({
          check_file_path(file_path)
          survdata <- load_survey_data(path = file_path, country_iso = country_iso())
          cache()$set_national_survey(survdata)
          national_filename(file_name)
          cd_set_file_upload("national_file", file_name, session)
        },
        error = function(e) upload_error("national_error", e))
      })
      push_upload_on_remount(input, session, i18n, "national_file", "national_survey", cache, national_filename)

      observeEvent(input$national_file_reset, {
        req(cache())
        cache()$clear_national_survey()
        national_filename(NULL)
      })

      observeEvent(input$regional_file, {
        req(cache(), input$regional_file)
        file_path <- input$regional_file$datapath
        file_name <- input$regional_file$name
        output$regional_error <- renderUI(NULL)

        tryCatch({
          check_file_path(file_path)
          gregion <- load_survey_data(path = file_path, country_iso = country_iso(), admin_level = "adminlevel_1")
          cache()$set_regional_survey(gregion)
          regional_filename(file_name)
          cd_set_file_upload("regional_file", file_name, session)
        },
        error = function(e) upload_error("regional_error", e))
      })
      push_upload_on_remount(input, session, i18n, "regional_file", "regional_survey", cache, regional_filename)

      observeEvent(input$regional_file_reset, {
        req(cache())
        cache()$clear_regional_survey()
        regional_filename(NULL)
      })

      observeEvent(input$area_file, {
        req(cache(), input$area_file)
        file_path <- input$area_file$datapath
        file_name <- input$area_file$name
        output$area_error <- renderUI(NULL)

        tryCatch({
          check_file_path(file_path)
          area <- load_equity_data(path = file_path, country_iso = country_iso())
          cache()$set_area_survey(area)
          area_filename(file_name)
          cd_set_file_upload("area_file", file_name, session)
        },
        error = function(e) upload_error("area_error", e))
      })
      push_upload_on_remount(input, session, i18n, "area_file", "area_survey", cache, area_filename)

      observeEvent(input$area_file_reset, {
        req(cache())
        cache()$clear_area_survey()
        area_filename(NULL)
      })

      observeEvent(input$education_file, {
        req(cache(), input$education_file)
        file_path <- input$education_file$datapath
        file_name <- input$education_file$name
        output$education_error <- renderUI(NULL)

        tryCatch({
          check_file_path(file_path)
          educ <- load_equity_data(path = file_path, country_iso = country_iso())
          cache()$set_education_survey(educ)
          education_filename(file_name)
          cd_set_file_upload("education_file", file_name, session)
        },
        error = function(e) upload_error("education_error", e))
      })
      push_upload_on_remount(input, session, i18n, "education_file", "education_survey", cache, education_filename)

      observeEvent(input$education_file_reset, {
        req(cache())
        cache()$clear_education_survey()
        education_filename(NULL)
      })

      observeEvent(input$wiq_file, {
        req(cache(), input$wiq_file)
        file_path <- input$wiq_file$datapath
        file_name <- input$wiq_file$name
        output$wiq_error <- renderUI(NULL)

        tryCatch({
          check_file_path(file_path)
          wiq <- load_equity_data(path = file_path, country_iso = country_iso())
          cache()$set_wiq_survey(wiq)
          wiq_filename(file_name)
          cd_set_file_upload("wiq_file", file_name, session)
        },
        error = function(e) upload_error("wiq_error", e))
      })
      push_upload_on_remount(input, session, i18n, "wiq_file", "wiq_survey", cache, wiq_filename)

      observeEvent(input$wiq_file_reset, {
        req(cache())
        cache()$clear_wiq_survey()
        wiq_filename(NULL)
      })

      # cache(), not a data()-style reactive that reads countdown_data -- see reference_estimates.R's own
      # identical comment (the same bug, same fix, confirmed live there first): countdown_data stays NULL for
      # the whole wizard walkthrough, so a reactive built on it never fires during a fresh upload at all.
      # cache() itself changes exactly once per fresh upload/reset, and the is_default() guards below make any
      # redundant firing a no-op regardless.
      observeEvent(cache(), {
        req(cache())
        if (isTRUE(cache()$is_default("national_survey"))) cd_reset_file_upload("national_file")
        if (isTRUE(cache()$is_default("regional_survey"))) cd_reset_file_upload("regional_file")
        if (isTRUE(cache()$is_default("area_survey"))) cd_reset_file_upload("area_file")
        if (isTRUE(cache()$is_default("education_survey"))) cd_reset_file_upload("education_file")
        if (isTRUE(cache()$is_default("wiq_survey"))) cd_reset_file_upload("wiq_file")
      })

      # Proactive alert (point 3 of the wizard's progressive-validation design): rather than only surfacing
      # this once the user happens to reach Data Quality (or Map Survey Files itself), tell them right here,
      # the moment the regional survey they just uploaded turns out to use different region names than the
      # main dataset. A plain top-level renderUI(), not nested inside the regional_file observer above (the
      # old, single-folder version's own structure) -- reading cache()$is_default("regional_survey") here ties
      # this output directly to THAT field's own reactive dependency (CacheConnection's per-field depend()/
      # trigger(), cd2030.core), so it re-evaluates whenever set_regional_survey()/clear_regional_survey() is
      # called from anywhere, not just this module's own observer.
      output$name_mismatch_alert <- renderUI({
        req(cache())
        if (isTRUE(cache()$is_default("regional_survey"))) return(NULL)
        mismatched <- cache()$check_survey_admin_names()
        if (nrow(mismatched) == 0) return(NULL)
        cd_status_banner(
          "warning", "title_survey_names_mismatch",
          str_glue_data(list(n = nrow(mismatched)), i18n$t("sub_survey_names_mismatch")),
          i18n = i18n
        )
      })
    }
  )
}

# The reference-data uploads (UN estimates, WUENIC, UN mortality estimates) of the wizard's Upload
# Data step, shown under the main dataset upload (wizard-upload_box.R), and two helpers the
# wizard's upload zones and mapping steps share.

#' A link that clears something the user set in the dataset
#'
#' Sets up, inside a module server, a link button that shows only while a field of the dataset
#' holds something the user set (`cache()$is_default(field)` is `FALSE`), and that calls
#' `clear_fn()` when pressed. The two mapping steps use it for their "clear mapping" link. The
#' module's UI needs `uiOutput(ns(output_id))` where the link goes.
#'
#' @param ns The namespace function of the calling module (`session$ns`).
#' @param output,input The `output` and `input` objects of the calling module server.
#' @param output_id The id of the output that shows the link, a string. The button's own input
#'   id is the same.
#' @param field The name of the dataset field to watch, a string (for example
#'   `"survey_mapping"`), as `cache()$is_default()` takes it.
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param clear_fn A function without arguments that clears the field, for example
#'   `function() cache()$clear_survey_mapping()`.
#' @param label_key The translation key of the link's text, a string.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @return Nothing useful. The function is called for its side effects: it sets
#'   `output[[output_id]]` and registers an observer.
#' @examples
#' \dontrun{
#' # in a module's ui: where the link goes
#' uiOutput(ns("survey_map_restore"))
#'
#' # in its server: a "clear mapping" link that shows while a survey mapping is saved
#' restore_default_control(
#'   session$ns, output, input, "survey_map_restore", "survey_mapping", cache,
#'   clear_fn = function() cache()$clear_survey_mapping(),
#'   label_key = "btn_upload_clear_mapping", i18n = i18n
#' )
#' }
#' @concept Countdown app wizard
#' @export
restore_default_control <- function(ns, output, input, output_id, field, cache, clear_fn, label_key, i18n) {
  # is_default(), not is.null(): the fields with built-in data never read as NULL once a country
  # is set, so only is_default() tells whether the user set something.
  output[[output_id]] <- renderUI({
    req(cache())
    if (isTRUE(cache()$is_default(field))) return(NULL)
    cd_button(ns(output_id), label_key, i18n, icon = "rotate-left", variant = "link", class = "cd-restore-link")
  })
  observeEvent(input[[output_id]], {
    req(cache())
    clear_fn()
  })
}

#' Keep an upload zone showing the file the dataset already holds
#'
#' Sets up, inside a module server, an observer that puts a file upload zone back in its
#' "uploaded" state each time the zone appears on the page, when the dataset holds something the
#' user uploaded for the zone's field (`cache()$is_default(field)` is `FALSE`). The zone shows
#' the name of the file uploaded in this session, or a general "file on record" label when the
#' name is not known (for example after loading a saved dataset).
#'
#' @param input,session The `input` and `session` objects of the calling module server.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for the label shown when
#'   the file's name is not known.
#' @param input_id The input id of the upload zone, without the namespace, a string.
#' @param field The name of the dataset field the zone fills, a string (for example
#'   `"un_estimates"`), as `cache()$is_default()` takes it.
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param filename_val A reactive value (`reactiveVal()`) that holds the name of the file
#'   uploaded in this session, or `NULL`. The caller sets it after an upload and sets it to
#'   `NULL` when the zone is reset.
#' @return Nothing useful. The function is called for its side effect of registering the
#'   observer.
#' @examples
#' \dontrun{
#' # in a module's ui: the upload zone
#' cd_file_upload(ns("un_data"), label = "title_upload_un_estimates", accept = ".dta", i18n = i18n)
#'
#' # in its server: remember the uploaded file's name, and show it when the zone comes back
#' un_filename <- reactiveVal(NULL)
#' observeEvent(input$un_data, un_filename(input$un_data$name))
#' observeEvent(input$un_data_reset, un_filename(NULL))
#' push_upload_on_remount(input, session, i18n, "un_data", "un_estimates", cache, un_filename)
#' }
#' @concept Countdown app wizard
#' @export
push_upload_on_remount <- function(input, session, i18n, input_id, field, cache, filename_val) {
  # A step's page is rebuilt when the user opens it from the summary page, and a newly built
  # zone starts empty, so its state has to be sent again on every mount, not only the first.
  remounted <- cd_remounted(input, input_id)
  observe({
    req(remounted(), cache())
    if (!isTRUE(cache()$is_default(field))) {
      cd_set_file_upload(input_id, filename_val() %||% i18n$t("lbl_upload_file_on_record"), session)
    }
  })
}

#' Reference-data uploads of the wizard's Upload Data step
#'
#' Optional upload zones for the reference estimates the analysis uses: UN
#' estimates, WUENIC estimates and UN mortality estimates, each a Stata file (`.dta`). Which
#' zones show is set by the app (`cd_wizard_config()$reference_uploads`). The dataset uses
#' built-in estimates for its country until the user uploads a file. An uploaded file is read
#' for the dataset's country and saved with `cache()$set_un_estimates()`,
#' `cache()$set_wuenic_estimates()` or `cache()$set_un_mortality_estimates()`. A zone's reset
#' button goes back to the built-in estimates (`cache()$clear_un_estimates()` and so on). A file
#' that cannot be read shows an error banner under its zone. These uploads do not affect whether
#' the Upload Data step counts as complete.
#'
#' @details
#' The UI has no card of its own: it is a divided section meant to sit in the same card as
#' [upload_box_ui()]. UN estimates are read for the years of the dataset
#' (`cache()$data_years`), so that zone does nothing until the dataset has years.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @return `reference_estimates_ui()` returns the UI as Shiny tags: a divider and a group of
#'   upload zones. `reference_estimates_server()` is called for its side effects and returns
#'   nothing useful.
#' @examples
#' \dontrun{
#' # in the server of the Load Data screen: the Upload Data step's page is one card
#' # holding the dataset's upload zone and these reference-data zones
#' panel <- list(key = "upload", ui = cd_card(
#'   title = i18n$t("title_upload_dataset_card"), width = 12,
#'   upload_box_ui(ns("upload_box"), i18n),
#'   reference_estimates_ui(ns("reference_estimates"), i18n)
#' ))
#' reference_estimates_server("reference_estimates", cache, i18n)
#' }
#' @concept Countdown app wizard
#' @export
reference_estimates_ui <- function(id, i18n) {
  ns <- NS(id)
  uploads <- cd_wizard_config()$reference_uploads

  zone <- function(input_id, label_key, error_id) {
    div(
      class = "cd-field-stack",
      cd_file_upload(ns(input_id), label = label_key, hint = "hint_upload_dta_format", accept = ".dta", i18n = i18n),
      uiOutput(ns(error_id))
    )
  }

  tagList(
    tags$hr(class = "cd-card-divider"),
    nr_group(
      i18n, "title_upload_group_estimates", "sub_upload_group_estimates",
      cols = length(uploads),
      if ("un_estimates" %in% uploads) zone("un_data", "title_upload_un_estimates", "un_error"),
      if ("wuenic_estimates" %in% uploads) zone("wuenic_data", "title_upload_wuenic", "wuenic_error"),
      if ("un_mortality_estimates" %in% uploads) zone("un_mortality_data", "title_upload_un_mortality", "un_mortality_error")
    )
  )
}

#' @rdname reference_estimates_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @export
reference_estimates_server <- function(id, cache, i18n) {
  stopifnot(is.reactive(cache))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns
      uploads <- cd_wizard_config()$reference_uploads

      # cache()$data_years, not cache()$countdown_data directly -- Phase 3 of the wizard redesign
      # means countdown_data stays NULL for the whole walkthrough (a fresh Excel upload only gets
      # wizard_parts until Finish), but data_years already has its own wizard-mode fallback
      # (CacheConnection, cd2030.core) and gives exactly the min/max years set_un_estimates() below
      # actually needs either way. Confirmed live: reading countdown_data directly here meant
      # req(data(), input$un_data) never passed during a fresh upload, so "Upload UN Estimates data"
      # silently did nothing at all, the whole time the wizard's own Upload Data step is open.
      data_years <- reactive({
        req(cache())
        cache()$data_years
      })

      country_iso <- reactive({
        req(cache())
        cache()$country_iso
      })

      # The originally-uploaded filename for each field, THIS session only -- see push_upload_on_remount()'s
      # own comment above for why these exist at all (nothing else durably holds it once the upload observer
      # below exits).
      un_filename <- reactiveVal(NULL)
      wuenic_filename <- reactiveVal(NULL)
      un_mortality_filename <- reactiveVal(NULL)

      # Error only, same pattern as upload_box.R's own output$upload_status -- a successful upload is shown by
      # the zone itself switching to its "already uploaded" state (cd_set_file_upload(), same mechanism the main
      # Dataset zone uses), not a separate "Using default data"/"Upload successful" message box underneath it.
      # There's nothing to show for the default/no-override case any more either -- every field already defaults
      # to the app's own bundled data unless overridden, which doesn't need its own explicit notice.
      # The banner says what went wrong (the file's own error, cleaned), as the Survey Files step's does.
      upload_error <- function(output_id, e) {
        output[[output_id]] <- renderUI({
          clean_message <- clean_error_message(e)
          cd_status_banner("error", "title_msg_error", str_glue_data(list(clean_message = clean_message), i18n$t("err_upload_failed_general")), i18n = i18n)
        })
      }

      observeEvent(input$un_data, {
        req(data_years(), input$un_data)
        file_name <- input$un_data$name
        output$un_error <- renderUI(NULL)

        tryCatch({
          start_year <- min(data_years())
          end_year <- robust_max(data_years(), 2024)
          un <- load_un_estimates(path = input$un_data$datapath,
                                  country_iso = country_iso(),
                                  start_year = start_year,
                                  end_year = end_year)
          cache()$set_un_estimates(un)
          un_filename(file_name)
          cd_set_file_upload("un_data", file_name, session)
        },
        error = function(e) {
          upload_error("un_error", e)
        })
      })
      push_upload_on_remount(input, session, i18n, "un_data", "un_estimates", cache, un_filename)

      # cache(), not data()/data_years() -- this only needs to know "a (possibly new) cache exists",
      # not the years themselves, and cache() itself changes on both a fresh wizard upload and a
      # resumed .rds alike, unlike the old data() (broken the same way for this observer -- never
      # fired during the wizard at all). Safe to fire more often than strictly necessary: the
      # is_default() guards below make an extra, redundant reset a no-op.
      observeEvent(cache(), {
        req(cache())
        # cd_reset_file_upload() is a plain custom message (see its own comment, _shared/R/core (and components/)): a reset
        # sent to a zone that hasn't mounted yet just has no listener and does nothing, same as shinyjs::reset()
        # always behaved.
        if (isTRUE(cache()$is_default("un_estimates"))) {
          cd_reset_file_upload("un_data")
        }
        if (isTRUE(cache()$is_default("wuenic_estimates"))) {
          cd_reset_file_upload("wuenic_data")
        }
        if ("un_mortality_estimates" %in% uploads && isTRUE(cache()$is_default("un_mortality_estimates"))) {
          cd_reset_file_upload("un_mortality_data")
        }
      })

      # The zone's own "Reset" icon (FileUploadZone.tsx) fires this as a plain input value on click -- no
      # separate "Restore default" link sitting below the box any more (see its own comment for why this is a
      # SEPARATE event from input$un_data itself: clicking Reset clears the picker locally without picking a
      # new file, so it never produces a fresh file-input change event to hook). Already-cleared client-side by
      # the time this fires, so no cd_reset_file_upload() echo needed back.
      observeEvent(input$un_data_reset, {
        req(cache())
        cache()$clear_un_estimates()
        un_filename(NULL)
      })

      observeEvent(input$wuenic_data, {
        req(cache())
        file_name <- input$wuenic_data$name
        output$wuenic_error <- renderUI(NULL)

        tryCatch({
          wuenic <- load_wuenic_data(path = input$wuenic_data$datapath,
                                     country_iso = country_iso())
          cache()$set_wuenic_estimates(wuenic)
          wuenic_filename(file_name)
          cd_set_file_upload("wuenic_data", file_name, session)
        },
        error = function(e) {
          upload_error("wuenic_error", e)
        })
      })
      push_upload_on_remount(input, session, i18n, "wuenic_data", "wuenic_estimates", cache, wuenic_filename)

      observeEvent(input$wuenic_data_reset, {
        req(cache())
        cache()$clear_wuenic_estimates()
        wuenic_filename(NULL)
      })

      # UN Mortality Estimates -- mirrors un_data's own observer exactly (load_un_mortality_data() has a
      # simpler signature, no start_year/end_year needed).
      observeEvent(input$un_mortality_data, {
        req(cache())
        file_name <- input$un_mortality_data$name
        output$un_mortality_error <- renderUI(NULL)

        tryCatch({
          mortality <- load_un_mortality_data(path = input$un_mortality_data$datapath,
                                              country_iso = country_iso())
          cache()$set_un_mortality_estimates(mortality)
          un_mortality_filename(file_name)
          cd_set_file_upload("un_mortality_data", file_name, session)
        },
        error = function(e) {
          upload_error("un_mortality_error", e)
        })
      })
      push_upload_on_remount(input, session, i18n, "un_mortality_data", "un_mortality_estimates", cache, un_mortality_filename)

      observeEvent(input$un_mortality_data_reset, {
        req(cache())
        cache()$clear_un_mortality_estimates()
        un_mortality_filename(NULL)
      })
    }
  )
}

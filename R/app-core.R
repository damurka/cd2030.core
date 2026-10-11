#' Build a Countdown app
#'
#' Puts a whole Countdown app together and returns it as a Shiny app: the frame every app shares
#' (header, sidebar, language picker), the Introduction and Load Data screens, and the app's own
#' pages. An app's `run_app()` sets its options, builds its translator, lists its pages and its nav
#' tree, and then calls `cd_app()`. See `cd2030.rmncah::run_app()` for a complete one.
#'
#' @details `cd_app()` calls the kit's `datasuite.ui::app_frame()` and adds what is the same in
#' every Countdown app:
#' * The Introduction screen and the Load Data screen. The app opens on Load Data, and these two
#'   screens are never locked.
#' * The dataset. It is the reactive the Load Data screen returns, and every page receives it as
#'   `cache`. The pages unlock once the dataset holds Countdown data. The nav items marked
#'   `requires_adjustment = TRUE` unlock once the data is also adjusted.
#' * The row naming the denominators in use, in every page header ([cd_denominator_header()]).
#' * The language. A dataset that has just been uploaded takes the language on screen, and a dataset
#'   that is opened again shows the language it was saved with.
#' * The reports' colours, which follow `theme`.
#' * What DataSuite's chat can read and do in the app: the filters of the page on show, the dataset,
#'   and actions that set filters and save, read, change and write reports.
#'
#' Before calling it, the app registers its translator with `cd_use_i18n()` and its pages with
#' `cd_use_pages()`.
#'
#' @param app_name The app's name, shown in the header.
#' @param app_version The app's version, shown in the header.
#' @param theme The app's colour theme: `"rmncah"` or `NULL` (maroon), `"vaccine"` (blue) or
#'   `"pooled"` (green).
#' @param nav_sections The sidebar's nav tree: a list of nav sections, made with [cd_nav_start()]
#'   and the functions beside it, and with the kit's `cd_nav_section()` and `cd_nav_item()`.
#' @param registry The app's pages: a list of page definitions made with the kit's `cd_page_def()`,
#'   the same list the app gives to `cd_use_pages()`.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param language The language the app starts in, for example `"en"`, `"fr"` or `"pt"`.
#' @param selected_file The path of a dataset to open when the app starts, or `NA` for none.
#'   DataSuite gives it when the app is started on a file.
#' @param upload_ui The ui function of the Load Data screen, called as
#'   `upload_ui("upload_data", i18n = i18n, is_electron = )`, where `is_electron` is `TRUE` when
#'   `selected_file` is given. By default it is the function named `upload_data_ui` where `cd_app()`
#'   is called from, when there is one, and otherwise the shared screen, `cd_upload_data_ui()`,
#'   which the app sets up with `options(cd2030.wizard = )`.
#' @param upload_server The server function of the Load Data screen, called as
#'   `upload_server("upload_data", i18n, selected_file, active = )`. It must return a list with
#'   `cache` (a reactive that returns the dataset, a [CacheConnection], or `NULL` before one is
#'   loaded) and `requires_walkthrough` (a reactive that is `TRUE` for a new upload and `FALSE` for
#'   a dataset opened again). By default it is the function named `upload_data_server` where
#'   `cd_app()` is called from, when there is one, and otherwise `cd_upload_data_server()`.
#'
#' @return A Shiny app object. Printing it, or passing it to [shiny::runApp()], runs the app.
#'
#' @examples
#' \dontrun{
#' i18n <- shiny.i18n::init_i18n(translation_json_path = cd_translations("translation.json"))
#' cd_use_i18n(i18n)
#'
#' pages <- my_pages()
#' cd_use_pages(pages)
#'
#' cd_app(
#'   app_name = "My Countdown app", app_version = "1.0.0", theme = "vaccine",
#'   nav_sections = list(cd_nav_start(), cd_nav_quality(), cd_nav_denominators()),
#'   registry = pages, i18n = i18n, language = "en", selected_file = NA
#' )
#' }
#'
#' @concept Countdown app frame
#' @export
cd_app <- function(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
                   upload_ui = get0("upload_data_ui", envir = parent.frame()) %||% cd_upload_data_ui,
                   upload_server = get0("upload_data_server", envir = parent.frame()) %||% cd_upload_data_server) {
  if (!is.function(upload_ui) || !is.function(upload_server)) {
    stop("cd_app() needs the app's Load Data screen: upload_ui and upload_server.", call. = FALSE)
  }
  # the app's reports start in its colour, as its pages are (R/report-countdown.R)
  datasuite.ui::report_register(themes = list(countdown = .cd_report_theme_for(theme)))
  app_frame(
    app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
    start_screens = list(
      cd_screen(tabName = "introduction", introduction_ui("introduction", i18n = i18n)),
      cd_screen(tabName = "upload_data", upload_ui("upload_data", i18n = i18n, is_electron = !is.na(selected_file)))
    ),
    start_tab = "upload_data", open_tabs = c("introduction", "upload_data"),
    # every page header shows the denominators in use
    page_header_extra = cd_denominator_header,
    # DataSuite's chat reads the page's filters and the dataset, and can set the filters (R/app-ai_bridge.R)
    ai_state = .cd_ai_state, ai_actions = .cd_ai_actions(),
    data_server = function(input, output, session) {
      introduction_server("introduction", selected_language = reactive(input$selected_language))
      loaded <- upload_server("upload_data", i18n, selected_file, active = reactive(identical(input$tabs, "upload_data")))
      cache <- loaded$cache
      # ready once Countdown data is loaded (a .dta/.rds upload has it at once; an Excel upload after the wizard's Finish)
      data_ready <- reactive(isTruthy(cache()) && isTruthy(cache()$countdown_data))
      list(
        dataset = cache,
        ready = data_ready,
        # the analysis pages wait until the data is adjusted
        analysis_ready = reactive(isTRUE(data_ready()) && isTRUE(cache()$adjusted_flag)),
        # a fresh upload (walked through the wizard) takes the language on screen; a resumed file shows its own
        adopt_language = loaded$requires_walkthrough
      )
    }
  )
}

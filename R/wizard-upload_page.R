#' The Load Data screen
#'
#' The whole Load Data screen of a Countdown app: the page header, with its help button, and the
#' Load Data wizard with all seven steps. The server starts every step's server, builds the
#' steps' pages and hands them to [wizard_steps_server()]. The screen is the same for every app.
#' What differs between apps (the fields of the National Rates step and the reference-data
#' upload zones) comes from the app's `options(cd2030.wizard = ...)`, which must be set before
#' the screen is used (see [cd_wizard_config()]). `cd_app()` uses this screen unless the app
#' passes its own `upload_ui` and `upload_server`.
#'
#' @details
#' The steps and their modules, in wizard order: Upload Data ([upload_box_ui()] and
#' [reference_estimates_ui()] in one card), Data Quality ([data_quality_ui()]), Survey Files
#' ([survey_upload_ui()]), National Rates ([national_rates_ui()]), Shapefile
#' ([shapefile_step_ui()]), Map Survey Files ([map_survey_ui()]) and Map Shapefile Names
#' ([map_shapefile_ui()]).
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param is_electron `TRUE` when the app was started with a file to load (the desktop app),
#'   `FALSE` (the default) when the user picks the file in the page. The ui function does not
#'   use it: the server works it out from `cdsuite_file`.
#' @return `cd_upload_data_ui()` returns the UI as Shiny tags: the page header and the wizard.
#'   `cd_upload_data_server()` returns a list with two elements:
#'   * `cache`: a reactive value that holds the dataset, a [CacheConnection], or `NULL` when
#'     none is loaded;
#'   * `requires_walkthrough`: a reactive value that is `TRUE` when the wizard must be walked
#'     through step by step, and `FALSE` when a saved dataset (`.rds`) was loaded.
#' @examples
#' \dontrun{
#' # the app describes its part of the wizard once, before the screen is used
#' options(cd2030.app_group = "rmncah", cd2030.wizard = list(national_rates_groups = list(
#'   cd_wizard_field_group("title_upload_group_maternal", "sub_upload_group_maternal",
#'     cd_wizard_survey_field("anc4_prop", "anc4", "title_upload_anc4_survey"),
#'     cd_wizard_national_rate_fields()
#'   )
#' )))
#'
#' # in the app's ui
#' cd_upload_data_ui("upload_data", i18n = i18n)
#'
#' # in the app's server: the dataset every page reads
#' loaded <- cd_upload_data_server("upload_data", i18n, NA_character_,
#'   active = reactive(identical(input$tabs, "upload_data"))
#' )
#' cache <- loaded$cache
#'
#' # cd_app() does both when it is given the pair
#' cd_app(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
#'   upload_ui = cd_upload_data_ui, upload_server = cd_upload_data_server
#' )
#' }
#' @concept Countdown app wizard
#' @export
cd_upload_data_ui <- function(id, i18n, is_electron = FALSE) {
  ns <- NS(id)

  tagList(
    # No cd_page_body() here: this page has no filter bar (there's no dataset loaded yet to filter), just
    # the page header + the wizard shell.
    cd_page_header(
      id = ns("load_data"),
      title = i18n$t("title_nav_load_data"),
      i18n = i18n,
      eyebrow = "lbl_nav_section_start",
      subtitle = "sub_load_data_main",
      include_help = TRUE
    ),
    cd_page_content(
      wizard_steps_ui(ns("wizard"))
    )
  )
}

#' @rdname cd_upload_data_ui
#' @param cdsuite_file The path of the file the app was started with, a string, or
#'   `NA_character_` when it was started without one. With a path, the file is loaded at
#'   startup and the Upload Data step shows no upload zone.
#' @param active A reactive that returns `TRUE` while the Load Data screen is the page shown.
#' @export
cd_upload_data_server <- function(id, i18n, cdsuite_file, active) {
  stopifnot(is.reactive(active))
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      cache <- reactiveVal()
      # Mirrors upload_box.R's own reactiveVal(TRUE) default (see its own comment) -- stays TRUE (walkthrough)
      # until upload_dt$requires_walkthrough() reports otherwise, right when cache() itself first gets a value.
      requires_walkthrough <- reactiveVal(TRUE)

      cd_page_header_server("load_data", cache = cache, path = "apps/countdown/getting-started", i18n = i18n)

      is_electron <- !is.na(cdsuite_file)
      upload_dt <- upload_box_server("upload_box", i18n, cdsuite_file, is_electron = is_electron)

      # Neither req(upload_dt$cache()) NOR observeEvent()'s own default ignoreNULL=TRUE can gate this: both
      # silently skip the WHOLE observer whenever upload_dt$cache() is NULL, which is exactly the value a
      # cleared dataset (upload_box.R's own input$hfd_file_reset observer) needs to propagate. Confirmed live,
      # twice: with req() alone removed but ignoreNULL still defaulting TRUE, upload_box.R's own initial_cache
      # correctly went back to NULL (traced with a temporary cat()) but this observer never re-ran at all --
      # this page's own cache() reactiveVal, which every other step server actually reads, stayed stuck on the
      # old value forever. ignoreNULL = FALSE is required for a "the whole thing got cleared" signal to ever
      # reach here.
      observeEvent(upload_dt$cache(), {
        cache(upload_dt$cache())
        requires_walkthrough(upload_dt$requires_walkthrough())
      }, ignoreNULL = FALSE)

      # Every step server is instantiated here at startup, whether or not its own panel is the one currently
      # shown -- same "servers always run" convention app.R itself documents for full pages (each one's own
      # req(cache())/req(data()) guards keep it inert until there's something to react to).
      national_rates_server("national_rates", cache, i18n)
      reference_estimates_server("reference_estimates", cache, i18n)
      survey_upload_server("survey_upload", cache, i18n)
      shapefile_step_server("shapefile_step", cache, i18n)
      map_survey_server("map_survey", cache, i18n)
      map_shapefile_server("map_shapefile", cache, i18n)
      data_quality_server("data_quality", cache, i18n)

      # One panel per wizard_step_defs entry (step_status.R), same order -- built with THIS module's own ns(),
      # not wizard_steps_server()'s nested one: the markup just gets embedded inside its cd_tab_panes() wherever
      # that ends up in the DOM, the same way file_upload.R's old UI was already built with its caller's ns()
      # and simply placed inside cd_page_content() -- static UI content doesn't need to share a server module's
      # own namespace, only a *nested moduleServer() call* would.
      panels <- list(
        list(key = "upload", ui = cd_card(
          title = i18n$t("title_upload_dataset_card"),
          subtitle = i18n$t("sub_upload_dataset_card"),
          status = "success",
          solidHeader = TRUE,
          width = 12,
          upload_box_ui(ns("upload_box"), i18n, is_electron),
          reference_estimates_ui(ns("reference_estimates"), i18n)
        )),
        list(key = "quality", ui = data_quality_ui(ns("data_quality"), i18n)),
        list(key = "national_rates", ui = national_rates_ui(ns("national_rates"), i18n)),
        list(key = "survey_files", ui = survey_upload_ui(ns("survey_upload"), i18n)),
        list(key = "shapefile", ui = shapefile_step_ui(ns("shapefile_step"), i18n)),
        list(key = "survey_mapping", ui = map_survey_ui(ns("map_survey"), i18n)),
        list(key = "map_mapping", ui = map_shapefile_ui(ns("map_shapefile"), i18n))
      )

      wizard_steps_server(
        "wizard", i18n = i18n, cache = cache, requires_walkthrough = requires_walkthrough, panels = panels,
        source_path = upload_dt$source_path, active = active
      )

      # requires_walkthrough exposed alongside cache -- app.R's own language-sync observer needs it to tell a
      # fresh Excel/Stata upload (should adopt whatever language is already showing) apart from a resumed .rds
      # (should impose its own saved language instead). See app.R's own comment on that observer.
      list(cache = cache, requires_walkthrough = requires_walkthrough)
    }
  )
}

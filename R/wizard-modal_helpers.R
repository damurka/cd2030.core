#' Dialog that matches the dataset's region names to another source
#'
#' A button that opens a dialog with one row per admin level 1 name of the dataset
#' (`cache()$subnational_regions`). In each row the user picks the matching name from another
#' source: the regional survey or the shapefile. The dialog suggests matches itself and keeps
#' the matches saved before. When the user saves, the server stores the mapping in the dataset
#' with `cache()$set_survey_mapping()` or `cache()$set_map_mapping()`, depending on `type`. The
#' two mapping steps of the wizard use it ([map_survey_ui()], [map_shapefile_ui()]).
#'
#' @details
#' The saved mapping is a tibble with one row per matched name and three columns:
#' `admin_level_1` (the dataset's name), a column named after `show_col` (the matching name in
#' the other source) and `source` (`"auto"` when the row is the dialog's own suggestion, left
#' unchanged, and `"user"` otherwise). Rows the user left without a match are not saved.
#'
#' The button and dialog appear once the dataset has its admin level 1 names and `survey_data()`
#' has a value.
#'
#' @param id The module's id.
#' @return `mapping_modal_ui()` returns the UI as Shiny tags: the placeholder the server fills
#'   with the button and its dialog. `mapping_modal_server()` is called for its side effects and
#'   returns nothing useful.
#' @examples
#' \dontrun{
#' # in a module's ui
#' mapping_modal_ui(ns("survey_data"))
#'
#' # in its server: match the dataset's names to the regional survey's
#' mapping_modal_server(
#'   id = "survey_data",
#'   cache = cache,
#'   survey_data = reactive(cache()$regional_survey),
#'   survey_map = reactive(cache()$survey_mapping),
#'   label = "btn_upload_map_survey",
#'   title = "msg_upload_manual_mapping",
#'   show_col = "adminlevel_1",
#'   type = "survey_mapping",
#'   i18n = i18n
#' )
#' }
#' @concept Countdown app wizard
#' @export
mapping_modal_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("modal"))
}

#' @rdname mapping_modal_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param survey_data A reactive that returns the other source, a data frame (the regional
#'   survey, or the shapefile). Its `show_col` column holds the names the user chooses from.
#' @param survey_map A reactive that returns the mapping saved so far (a data frame as described
#'   in Details), or `NULL` when none is saved.
#' @param label The translation key of the button's text, a string.
#' @param title The translation key of the dialog's title, a string.
#' @param show_col The column of `survey_data()` that holds the names to match: a string, or a
#'   function without arguments (or a reactive) that returns one. A function is called each time
#'   the value is needed, so the column can change while the app runs, as an uploaded
#'   shapefile's name column does.
#' @param type Where the mapping is saved: `"survey_mapping"` (with `cache()$set_survey_mapping()`)
#'   or `"map_mapping"` (with `cache()$set_map_mapping()`). Any other value saves nothing.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @export
mapping_modal_server <- function(id, cache, survey_data, survey_map, label, title, show_col, type, i18n) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(survey_data))
  stopifnot(is.reactive(survey_map))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      show_col_now <- function() if (is.function(show_col)) show_col() else show_col

      # The canonical list every entry must be matched against -- unchanged from before. req()'s
      # first argument alone isn't enough any more (Phase 3 of the wizard redesign):
      # subnational_regions can now genuinely be NULL mid-wizard, before merge (its own pre-merge
      # fallback needs the admin sheet's first_admin_level/district columns specifically -- absent
      # or mid-read, it stays NULL rather than erroring) -- req() both, so this reactive simply
      # doesn't fire yet instead of crashing on a NULL %>% distinct() call.
      gregion_levels <- reactive({
        req(cache(), cache()$subnational_regions)

        cache()$subnational_regions %>%
          distinct(adminlevel_1) %>%
          arrange(adminlevel_1) %>%
          pull(adminlevel_1)
      })

      output$modal <- renderUI({
        req(gregion_levels(), survey_data())
        col <- show_col_now()

        choices <- survey_data() %>%
          distinct(!!rlang::sym(col)) %>%
          arrange(!!rlang::sym(col)) %>%
          pull(!!rlang::sym(col))

        # A named character vector (region -> its previously-saved match), the shape cd_mapping_modal()'s
        # `existing` prop expects -- NULL when nothing's been mapped yet, so MappingModal.tsx's auto-match runs
        # unconstrained on every region rather than treating an empty tibble as "everything already mapped to
        # nothing."
        existing_map <- survey_map()
        existing <- if (!is.null(existing_map) && nrow(existing_map) > 0 && col %in% colnames(existing_map)) {
          stats::setNames(as.character(existing_map[[col]]), existing_map$admin_level_1)
        } else {
          NULL
        }

        cd_mapping_modal(
          ns("mapping"), label = label, title = title,
          regions = gregion_levels(), choices = choices, existing = existing, i18n = i18n
        )
      })

      # One consolidated value on Save (a named list, region -> matched value) instead of looping over
      # gregion_levels() to read N separate selectize inputs -- req(input$mapping) also filters out
      # InputAdapter's own mount-time echo (shiny.react's useValue() sends the current -- here, always
      # NULL/undefined, since cd_mapping_modal() never passes an initial `value` -- prop back on every mount, and
      # output$modal above remounts this component each time gregion_levels()/survey_data()/survey_map()
      # change, including right after this very observer's own cache write; req() stops that echo from ever
      # reaching the body below, so it can't loop).
      observeEvent(input$mapping, {
        req(cache(), input$mapping)
        col <- show_col_now()

        # Each entry is now {value, source} (MappingModal.tsx's save()), not a bare string -- source is "auto"
        # when that row is still exactly autoMatch()'s own untouched suggestion, "user" otherwise (picked,
        # edited, or carried over from a previous save with no suggestion at all). Kept as its own `source`
        # column on the saved tibble, not a separate CacheConnection field, so it round-trips through
        # set_survey_mapping()/set_map_mapping() and a resumed .rds exactly like every other column here --
        # mapping_steps.R's mapping_provenance_banner() reads it back to tell the user how much of what's saved
        # was actually auto-matched vs their own review (explicit user request).
        mapping_list <- input$mapping
        mapping_result <- tibble(
          admin_level_1 = names(mapping_list),
          !!sym(col) := vapply(mapping_list, function(x) x$value, character(1)),
          source = vapply(mapping_list, function(x) x$source, character(1))
        ) %>%
          filter(!!sym(col) != "") # a row the user left unmapped (blank) despite the confirm step -- drop
                                    # it rather than save a blank match, same as no mapping existing at all

        if (type == 'map_mapping') {
          cache()$set_map_mapping(mapping_result)
        } else if (type == 'survey_mapping') {
          cache()$set_survey_mapping(mapping_result)
        }
      })
    }
  )
}

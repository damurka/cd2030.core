#' Population filter chip
#'
#' A filter chip that chooses the DHIS2 population the growth-projected denominators (ANC1 and
#' Penta1 population growth) are built from. The choice is kept in the dataset.
#'
#' @details
#' The choices are `"totlivebirths_dhis2"` (live births), `"totbirths_dhis2"` (total births),
#' `"totpop_dhis2"` (total population) and `"totunder1_dhis2"` (population under one year).
#'
#' Once the chip is on the page, the server sets it to the dataset's value,
#' `cache()$derivation_population`, when there is one, and does so again whenever `cache()` changes.
#' Each choice the chip reports is saved with the dataset's `set_derivation_population()`.
#'
#' The ui takes no translator: its labels are translated with the translator the app registered with
#' `cd_use_i18n()`.
#'
#' @param id The module's id.
#'
#' @return `cd_population_ui()` returns the UI as Shiny tags (the chip).
#'
#'   `cd_population_server()` returns a reactive holding the chosen population's id as a string
#'   (`NULL` until the chip has reported a value).
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_population_ui(ns("population"))
#'
#' # in the page's server
#' population <- cd_population_server("population", cache)
#' }
#'
#' @concept Countdown app filters
#' @export
cd_population_ui <- function(id) {
  ns <- NS(id)

  choices <- c(
    "opt_denom_live_births_dhis2" = "totlivebirths_dhis2",
    "opt_denom_total_births_dhis2" = "totbirths_dhis2",
    # "opt_denom_total_births_un" = "un_births",
    "opt_denom_total_pop_dhis2" = "totpop_dhis2",
    # "opt_denom_total_pop_un" = "un_population",
    "opt_denom_under1_dhis2" = "totunder1_dhis2"#,
    # "opt_denom_under1_un" = "un_under1"
  )
  cd_chip_select(
    ns("population"),
    label = "title_denom_pop_select",
    hint = "tt_denom_pop_select",
    choices = choices,
    # starts empty: the value comes from the cache, and an empty value is ignored below, so mounting never
    # overwrites the stored choice with the first option
    selected = ""
  )
}

#' @rdname cd_population_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @export
cd_population_server <- function(id, cache) {
  stopifnot(is.reactive(cache))

  moduleServer(id = id, module = function(input, output, session) {
    mounted <- cd_mounted(input, "population")

    # cache -> chip, once the chip exists. Guarded the same way updateI18nSelectizeInput() used to internally
    # (a NULL value was silently a no-op there): cache()$derivation_population can still be NULL this early.
    observeEvent(list(cache(), mounted()), {
      req(cache(), mounted())
      value <- cache()$derivation_population
      if (!is.null(value)) cd_update_input("population", session, value = as.character(value))
    })

    # chip -> cache
    observeEvent(input$population, {
      req(cache(), input$population)
      cache()$set_derivation_population(input$population)
    })

    return(reactive(input$population))
  })
}

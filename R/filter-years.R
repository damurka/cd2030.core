#' Keep a years chip in step with the dataset
#'
#' The server half of a filter chip that chooses several years. The chip itself is a multi-choice
#' chip the page draws (`cd_chip_multi()`). This function gives the chip its options, the years in
#' the data, and sets it to the years already chosen in the dataset. Choosing nothing in the chip
#' means "all years".
#'
#' @details Call it once inside a module server. It sends the options and the chosen years to the
#' chip once the chip is on the page, and again when `years()` or `selected()` changes. It does not
#' send the chip what the chip already holds.
#'
#' It only goes from the dataset to the chip. The page saves the reader's choice itself, with its
#' own `observeEvent(input$years, ...)`, where [cd_years_input()] turns the chip's value into the
#' years it means.
#'
#' @param input The module's `input`.
#' @param session The module's `session`.
#' @param id The chip's input id within the module. Default `"years"`.
#' @param years A reactive that returns the years the chip offers, the years in the data.
#' @param selected A reactive that returns the years chosen in the dataset. An empty or all-`NA`
#'   value means no choice, which leaves the chip empty ("all years").
#'
#' @return Nothing useful (the observer it creates). It is called for what it does.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_chip_multi(ns("years"), "title_global_select_years", i18n = i18n)
#'
#' # in the page's server
#' cd_years_sync(input, session, "years",
#'   years = reactive(cache()$data_years),
#'   selected = reactive(cache()$mapping_years)
#' )
#' observeEvent(input$years, {
#'   cache()$set_mapping_years(cd_years_input(input$years, cache()$data_years))
#' })
#' }
#'
#' @concept Countdown app filters
#' @export
cd_years_sync <- function(input, session, id = "years", years, selected) {
  # The observer depends only on the dataset's side and the mount, never on input[[id]]: a choice reaches the
  # dataset through the page's own writer, and an observer that also reacted to the input could run first and
  # push the old value back over the user's choice.
  stopifnot(is.reactive(years), is.reactive(selected))
  mounted <- cd_mounted(input, id)

  sent_years <- NULL
  observeEvent(list(years(), selected(), mounted()), {
    req(mounted(), years())
    chosen <- selected()
    # Not sent back what the chip itself has just chosen. The chip's change is saved (the page's own observer), which
    # changes selected(), and the update that followed told the chip to hold what it already held -- harmless alone,
    # but it reaches the browser after the reader's NEXT click: the chip went back to the earlier years, said so,
    # that was saved and answered in turn, and the two selections chased each other for good, the maps redrawn each
    # time. The chip is only told its years when they are not the ones it has (a dataset opened, its years changed).
    if (identical(sent_years, years()) && cd_years_held(isolate(input[[id]]), chosen, years())) {
      return()
    }
    sent_years <<- years()
    cd_update_input(
      id, session,
      options = cd_plain_options(years()),
      value = if (length(chosen) && !all(is.na(chosen))) as.character(chosen) else ""
    )
  })
}

#' Whether a years chip already holds the chosen years
#'
#' Compares what the chip holds with the years chosen in the dataset, in any order. An empty chip
#' and an empty choice both mean every year (see [cd_years_input()]).
#'
#' @param value The chip's value (`input$years`): a character vector of years, `""` or `NULL`.
#' @param chosen The years chosen in the dataset. Empty or all `NA` means every year.
#' @param all_years Every year the chip offers.
#'
#' @return `TRUE` when the two are the same set of years, `FALSE` otherwise.
#' @noRd
cd_years_held <- function(value, chosen, all_years) {
  held <- cd_years_input(as.character(value %||% ""), all_years)
  wanted <- if (length(chosen) && !all(is.na(chosen))) as.integer(chosen) else as.integer(all_years)
  setequal(held, wanted)
}

#' The years a years chip means
#'
#' Turns the value of a years chip (see [cd_years_sync()]) into the years to use. An empty chip
#' means "all years", and this returns every year for it, so the result can be saved in the dataset
#' and used to filter data as it is.
#'
#' @param value The chip's value (`input$years`): a character vector of years, or `""` when nothing
#'   is chosen. Entries that are empty or not a number are dropped.
#' @param all_years What "all years" is: the years in the dataset.
#'
#' @return An integer vector: the years in `value`, or `all_years` (as integers) when `value` holds
#'   no year.
#'
#' @examples
#' cd_years_input(c("2021", "2023"), all_years = 2019:2023)
#' cd_years_input("", all_years = 2019:2023)
#'
#' @concept Countdown app filters
#' @export
cd_years_input <- function(value, all_years) {
  # "All years" is returned as the years themselves, never NA: select_mapping_data() keeps only the rows whose
  # year is in the dataset's *_mapping_years field, so NA there plots nothing.
  years <- suppressWarnings(as.integer(value[nzchar(value)]))
  years <- years[!is.na(years)]
  if (length(years)) years else as.integer(all_years)
}

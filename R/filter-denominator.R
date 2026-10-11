#' The standard denominator choices
#'
#' Every denominator the denominator chip can offer, in the form a filter chip takes them. This is
#' the full set, which the RMNCAH app uses. An app with fewer denominators sets its own (see
#' [cd_denominator_options()]).
#'
#' @format A named character vector of length 5. The values are the denominator ids and the names
#'   are the translation keys of their labels:
#'   * `"dhis2"`: the DHIS2 population projection.
#'   * `"anc1"` and `"penta1"`: the denominators derived from ANC1 and from Penta1.
#'   * `"penta1derived"` and `"anc1derived"`: the growth-projected denominators (Penta1 and ANC1
#'     population growth).
#'
#' @examples
#' cd_denominator_choices
#'
#' @concept Countdown app filters
#' @export
cd_denominator_choices <- c(
  "lbl_denom_dhis2_proj" = "dhis2",
  "lbl_denom_anc1_derived" = "anc1",
  "lbl_denom_penta1_derived" = "penta1",
  "lbl_denom_penta1_growth" = "penta1derived",
  "lbl_denom_anc1_growth" = "anc1derived"
)

#' The denominators this app offers
#'
#' The choices the denominator chip shows in the running app. Use it wherever a page must list or
#' check the app's denominators, so that a page shared between apps never shows one the app does not
#' have.
#'
#' @details Reads `options(cd2030.denominator_choices = )`. An app whose indicator group has fewer
#' denominators sets that option to its own named vector (the vaccine app leaves out
#' `"anc1derived"`). When the option is not set, the result is [cd_denominator_choices].
#'
#' @return A named character vector: the values are the denominator ids and the names are the
#'   translation keys of their labels.
#'
#' @examples
#' cd_denominator_options()
#'
#' old <- options(cd2030.denominator_choices = c("lbl_denom_dhis2_proj" = "dhis2"))
#' cd_denominator_options()
#' options(old)
#'
#' @concept Countdown app filters
#' @export
cd_denominator_options <- function() getOption("cd2030.denominator_choices", cd_denominator_choices)

#' Whether this app has a maternal denominator
#'
#' Tells a shared page whether to show what belongs to the maternal denominator: its chip on the
#' Denominator Selection page and its entry in the page header's denominator row.
#'
#' @details The answer is the app's `has_maternal` setting (see [cd_cfg()]). When the app does not
#' set it, the answer is `TRUE` unless `getOption("cd2030.selected_group")` is `"vaccine"`.
#'
#' @return `TRUE` or `FALSE`.
#'
#' @examples
#' old <- options(cd2030.config = list(has_maternal = FALSE))
#' cd_has_maternal()
#' options(old)
#'
#' @concept Countdown app filters
#' @export
cd_has_maternal <- function() isTRUE(cd_cfg("has_maternal", !identical(getOption("cd2030.selected_group"), "vaccine")))

#' Keep only the denominators this app offers
#'
#' Filters a named list or vector, such as a chart's legend labels or category labels, down to the
#' entries named after a denominator the app offers. Labels are usually written for every
#' denominator, and one the app does not offer must not appear in a chart.
#'
#' @param x A list or vector named by denominator id.
#'
#' @return `x` without the entries whose name is neither `"un"` (the UN projection, always kept) nor
#'   one of the ids in [cd_denominator_options()]. The order and the type of `x` are kept.
#'
#' @examples
#' labels <- c(un = "UN projection", dhis2 = "DHIS2 projection", other = "Not a denominator")
#' cd_only_denominators(labels)
#'
#' @concept Countdown app filters
#' @export
cd_only_denominators <- function(x) x[names(x) %in% c("un", cd_denominator_options())]

#' Label and hint of a denominator chip
#'
#' The translation keys of the label and of the hint a denominator chip shows. [cd_denominator_ui()]
#' uses them, and a page that draws a denominator chip of its own can use them to match it.
#'
#' @param is_maternal Logical. `TRUE` for the maternal denominator's chip, `FALSE` for the
#'   vaccination denominator's.
#'
#' @return A list of two translation keys, `label` and `hint`.
#'
#' @examples
#' cd_denominator_chip_keys(is_maternal = TRUE)
#' cd_denominator_chip_keys(is_maternal = FALSE)
#'
#' @concept Countdown app filters
#' @export
cd_denominator_chip_keys <- function(is_maternal) {
  list(
    label = if (is_maternal) "lbl_chip_denom_mat" else "lbl_chip_denom_vacc",
    hint = if (is_maternal) "tt_denom_select_best_mat" else "tt_denom_select_best_vacc"
  )
}

#' Denominator filter chip
#'
#' A filter chip that chooses the denominator the dataset uses, either the vaccination denominator
#' or the maternal one. The choice is kept in the dataset, so every page that reads the denominator
#' follows it. The Denominator Selection page uses one chip for each.
#'
#' @details The chip starts empty and the server fills it from the dataset once the chip is on the
#' page: `cache()$denominator`, or `cache()$maternal_denominator` when `is_maternal` is `TRUE`. When
#' the value changes in the dataset, the chip follows. When the reader chooses a denominator, the
#' server saves it with the dataset's `set_denominator()` or `set_maternal_denominator()`. An empty
#' chip saves nothing.
#'
#' The chip is drawn, and the dataset kept in step, only when asked for: pass `allow_input = TRUE`
#' to the ui and `allowInput = TRUE` to the server (the two arguments are spelled differently). With
#' the defaults the ui is `NULL` and the server does nothing.
#'
#' The chip's choices are [cd_denominator_options()].
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label. The server
#'   does not use it.
#' @param allow_input Logical. `TRUE` draws the chip. Default `FALSE`, which draws nothing.
#' @param is_maternal Logical. `TRUE` for the maternal denominator, `FALSE` (the default) for the
#'   vaccination denominator. It decides the chip's label and hint, and which value of the dataset
#'   the server reads and saves.
#'
#' @return `cd_denominator_ui()` returns the UI as Shiny tags (the chip), or `NULL` when
#'   `allow_input` is `FALSE`.
#'
#'   `cd_denominator_server()` returns nothing useful. It is called for what it does.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_denominator_ui(ns("vaxx_denominator"), i18n, allow_input = TRUE)
#'
#' # in the page's server
#' cd_denominator_server("vaxx_denominator", cache, i18n, allowInput = TRUE)
#' }
#'
#' @concept Countdown app filters
#' @export
cd_denominator_ui <- function(id, i18n, allow_input = FALSE, is_maternal = FALSE) {
  ns <- NS(id)
  if (allow_input) {
    keys <- cd_denominator_chip_keys(is_maternal)
    # React filter chip (js/src/components/ChipSelect.tsx). It starts empty: the value comes from the
    # cache, and an empty value is ignored by the server below, so mounting never overwrites the cache.
    cd_chip_select(ns("denominator"), keys$label, cd_denominator_options(), i18n, selected = "", hint = keys$hint, allow_empty = TRUE)
  } else {
    NULL
  }
}

#' @rdname cd_denominator_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param label Not used.
#' @param allowInput Logical. `TRUE` keeps the chip and the dataset in step. Default `FALSE`, which
#'   does nothing. Give it the value the ui's `allow_input` has.
#' @param display_mode Not used.
#' @export
cd_denominator_server <- function(id, cache, i18n, label = 'title_denom_select_best', allowInput = FALSE, is_maternal = FALSE, display_mode = 'combined') {
  stopifnot(is.reactive(cache))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      # Only an instance that renders a dropdown has anything to keep in sync with the cache.
      # Read-only instances are just the renderUI below: no observers, and no messages sent to
      # an element that does not exist.
      if (allowInput) {
        denominator <- reactive({
          req(cache())
          if (is_maternal) {
            cache()$maternal_denominator
          } else {
            cache()$denominator
          }
        })

        # A message sent to a chip that has not mounted yet is lost, so wait for it to say it has.
        chip_mounted <- cd_mounted(input, "denominator")

        # cache -> chip. Runs when the CACHE value changes, or when the chip mounts. It must not depend on
        # input$denominator: when the user picks something, that change reaches the cache through the writer
        # below, and an observer that also reacted to the input could run first, see the old cache value, and
        # push it back over the user's choice. (Even reading the input in the event expression is enough:
        # observeEvent re-runs whenever anything it reads is invalidated, whether or not the value changed.)
        observeEvent(list(denominator(), chip_mounted()), {
          req(denominator(), chip_mounted())

          if (!identical(isolate(input$denominator), denominator())) {
            cd_update_input("denominator", session, value = denominator())
          }
        })

        # dropdown -> cache: the single writer for this value
        observeEvent(input$denominator, {
          req(cache(), input$denominator)
          if (input$denominator == "") return()

          if (is_maternal) {
            isolate(cache()$set_maternal_denominator(input$denominator))
          } else {
            isolate(cache()$set_denominator(input$denominator))
          }
        })
      }
    }
  )
}

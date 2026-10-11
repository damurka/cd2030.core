#' Choices of the admin level chip
#'
#' The admin levels a page can be shown at, in the form a filter chip takes them.
#' [cd_admin_level_ui()] builds its level chip from this, and a page can use it to offer the same
#' levels in a control of its own.
#'
#' @param include_national Logical. `TRUE` puts the national level first, before admin level 1 and
#'   district. Default `FALSE`.
#'
#' @return A named character vector. The values are the levels (`"national"` when asked for,
#'   `"adminlevel_1"`, `"district"`) and the names are the translation keys of their labels.
#'
#' @examples
#' cd_admin_level_choices()
#' cd_admin_level_choices(include_national = TRUE)
#'
#' @concept Countdown app filters
#' @export
cd_admin_level_choices <- function(include_national = FALSE) {
  c(
    if (include_national) c("opt_national" = "national") else NULL,
    "opt_adminlevel_1" = "adminlevel_1",
    "opt_district" = "district"
  )
}

#' Admin level and region filter chips
#'
#' Two filter chips for a page's filter bar: one chooses the admin level (admin level 1 or district,
#' and national when asked for), the other a single area at that level. A page puts
#' `cd_admin_level_ui()` in its filter bar, calls `cd_admin_level_server()` in its server, and reads
#' the chosen level and area from the reactive the server returns. [cd_admin_parts()] splits that
#' reactive into one reactive for the level and one for the area.
#'
#' @details The region chip is drawn by the server, so it appears only where there are areas to
#' choose from: never at the national level, never when `show_region` is `FALSE`, and at the
#' district level only when `show_district` is `TRUE`. Its options are the areas of
#' `cache()$subnational_regions` at the chosen level, and districts are listed under the admin level
#' 1 area they belong to. Changing the level draws a new region chip, so an area of the old level is
#' never kept. The list of areas is debounced by 300 milliseconds.
#'
#' With `allow_select_all = TRUE` the region chip starts on an "all" option, which the server
#' reports as a `NULL` region. Without it the chip starts on the first area in the list.
#'
#' When `show_admin_level` is `FALSE` there is no level chip, and the level is fixed: `"district"`
#' when `show_district` is `TRUE` (the default), `"adminlevel_1"` otherwise. Give `show_admin_level`
#' the same value in the ui and the server call.
#'
#' @param id The module's id.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param include_national Logical. `TRUE` adds the national level to the level chip, as its first
#'   choice and so the one it starts on. Default `FALSE`.
#' @param show_admin_level Logical. `FALSE` leaves the level chip out, for a page that only lets the
#'   reader choose an area. Default `TRUE`.
#'
#' @return `cd_admin_level_ui()` returns the UI as Shiny tags: the level chip (when shown) and the
#'   place where the server draws the region chip.
#'
#'   `cd_admin_level_server()` returns a reactive holding a list with two elements:
#'   * `admin_level`: `"national"`, `"adminlevel_1"` or `"district"`.
#'   * `region`: the name of the chosen area, or `NULL` when the region chip is not shown or "all"
#'     is chosen.
#'
#'   While the region chip is shown but has not yet reported a value, the reactive stops quietly (as
#'   [shiny::req()] does), so what depends on it waits.
#'
#' @examples
#' \dontrun{
#' # in a page's ui
#' cd_filter_bar(cd_admin_level_ui(ns("admin_level"), i18n))
#'
#' # in the page's server
#' admin <- cd_admin_level_server("admin_level", cache, i18n, allow_select_all = TRUE)
#' observe({
#'   admin()$admin_level
#'   admin()$region
#' })
#' }
#'
#' @concept Countdown app filters
#' @export
cd_admin_level_ui <- function(id, i18n, include_national = FALSE, show_admin_level = TRUE) {
  ns <- NS(id)
  choices <- cd_admin_level_choices(include_national)

  tagList(
    if (show_admin_level) {
      cd_chip_select(ns("admin"), "title_global_admin_level", choices, i18n, hint = "tt_global_admin_level",
                   default = unname(choices)[[1]])
    },
    shiny.react::reactOutput(ns("region_ui"))
  )
}

#' @rdname cd_admin_level_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param allow_select_all Logical. `TRUE` adds an "all" option to the region chip and starts the
#'   chip on it. Default `FALSE`.
#' @param show_district Logical. Whether an area can be chosen at the district level. With a level
#'   chip, `FALSE` hides the region chip while the level is district. Without a level chip, it sets
#'   the fixed level (see Details). Default `TRUE`.
#' @param show_region Logical. `FALSE` never shows the region chip, so `region` is always `NULL`.
#'   Default `TRUE`.
#' @param selected_admin1 A reactive that returns the name of an admin level 1 area, or `NULL`. When
#'   it returns a name and the level is district, the region chip lists only the districts of that
#'   area. Default `reactive(NULL)`, every district.
#' @export
cd_admin_level_server <- function(id, cache, i18n, allow_select_all = FALSE, show_district = TRUE, show_region = TRUE, show_admin_level = TRUE, selected_admin1 = reactive(NULL)) {
  stopifnot(is.reactive(cache))
  moduleServer(
    id = id,
    module = function(input, output, session) {
      ns <- session$ns

      admin_val <- reactive({
        if (show_admin_level) {
          req(input$admin)
          input$admin
        } else if (!show_district) {
          "adminlevel_1"
        } else {
          "district"
        }
      })

      region_is_visible <- reactive({
        current_admin <- admin_val()
        (current_admin != "national") &&
          show_region &&
          (current_admin != "district" || show_district)
      })

      observeEvent(admin_val(), {
        freezeReactiveValue(input, "region")
      })

      region <- reactive({
        if (!region_is_visible() || is.null(input$region) || input$region == "_all_" || !nzchar(input$region)) {
          return(NULL)
        }
        input$region
      })

      # every area at this level, grouped by admin 1 for districts. Debounced: cache()$subnational_regions can
      # settle over more than one update while the cache is first built, and cd_admin_level_server() runs once
      # per page -- most pages have one -- so an un-debounced re-render here fires a whole burst of outputs
      # across the app at once, right when the client is least able to keep up (the same race the download
      # button's enabled state hit; see _shared/R/charts/download-button.R).
      region_options <- shiny::debounce(reactive({
        req(cache())
        if (!region_is_visible()) return(NULL)

        admin_col <- admin_val()
        is_district <- admin_col == "district"

        region_data <- cache()$subnational_regions %>%
          filter(if (is_district && !is.null(selected_admin1())) adminlevel_1 == selected_admin1() else TRUE) %>%
          distinct(!!sym(admin_col), .keep_all = TRUE) %>%
          # districts are listed under their parent, so sort by parent first or each heading repeats
          arrange(if (is_district) adminlevel_1 else !!sym(admin_col), !!sym(admin_col))

        opts <- cd_plain_options(region_data[[admin_col]], if (is_district) region_data$adminlevel_1 else NULL)

        if (allow_select_all) {
          opts <- c(list(list(key = "_all_", text = cd_text(i18n, "opt_global_select_all"))), opts)
        }
        opts
      }), millis = 300)

      output$region_ui <- shiny.react::renderReact({
        opts <- region_options()
        if (is.null(opts)) return(NULL)

        admin_col <- admin_val()
        # `key` remounts the chip when the level changes, so a region from the old level is never kept
        cd_chip_select(ns("region"), paste0("opt_", admin_col), i18n = i18n, options = opts,
                     selected = if (allow_select_all) "_all_" else "", key = admin_col)
      })
      # the chip feeds input$region, which the whole page waits on, so it must render even while its page is hidden
      outputOptions(output, "region_ui", suspendWhenHidden = FALSE)

      reactive({
        if (region_is_visible()) {
          req(!is.null(input$region), nzchar(input$region))
        }
        list(
          admin_level = admin_val(),
          region = region()
        )
      })
    }
  )
}

#' Split the admin level filter's value into two reactives
#'
#' [cd_admin_level_server()] returns one reactive holding both the admin level and the region. Pages
#' usually hand the two to their charts and tables as separate reactives, and this gives one
#' reactive for each.
#'
#' @param admin The reactive [cd_admin_level_server()] returned.
#'
#' @return A list of two reactives:
#'   * `admin_level`: the chosen admin level.
#'   * `region`: the chosen area's name, or `NULL` when the region chip is not shown or "all" is
#'     chosen.
#'
#'   Both wait (as [shiny::req()] does) until `admin()` has a value.
#'
#' @examples
#' \dontrun{
#' admin <- cd_admin_level_server("admin_level", cache, i18n)
#' parts <- cd_admin_parts(admin)
#' parts$admin_level()
#' parts$region()
#' }
#'
#' @concept Countdown app filters
#' @export
cd_admin_parts <- function(admin) {
  list(
    admin_level = reactive({
      req(admin())
      admin()$admin_level
    }),
    region = reactive({
      req(admin())
      admin()$region
    })
  )
}

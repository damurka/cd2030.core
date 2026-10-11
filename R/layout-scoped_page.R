#' Define the scope of a scoped page
#'
#' A scope says at which geography a page runs its analysis: which admin level and region filters
#' the page shows, and what admin level and region it hands to the analysis. Pages that run the same
#' analysis at a different geography (national coverage and sub-national coverage, for example)
#' differ only in their scope. Pass the result to [cd_scoped_page_ui()] and
#' [cd_scoped_page_server()], or to [cd_scope_filters()] and [cd_scope_server()].
#'
#' @details
#' The kinds of scope:
#' * `"national"`: no filters. The analysis gets the admin level `"national"` and no region.
#' * `"level"`: an admin level chip only (admin level 1 or district). The analysis gets the chosen
#'   level and no region.
#' * `"region"`: a region chip only, listing the admin level 1 areas. The analysis gets the chosen
#'   area and the admin level `"adminlevel_1"`, or `fixed_level` when it is given.
#' * `"level_region"`: an admin level chip and a region chip. The region chip is shown at admin
#'   level 1, and also at the district level when `show_district` is `TRUE`.
#'
#' @param kind The kind of scope: `"national"` (the default), `"level"`, `"region"` or
#'   `"level_region"`.
#' @param fixed_level An admin level (for example `"district"`) handed to the analysis in place of
#'   the level of the filter bar. `NULL` (the default) hands over the level of the filter bar. A
#'   `"national"` scope ignores it.
#' @param show_district Logical. For `kind = "level_region"`, whether a district can be chosen as
#'   the region. Other kinds ignore it. Default `FALSE`.
#'
#' @return A list with the elements `kind`, `fixed_level` and `show_district`, as given.
#'
#' @examples
#' cd_scope()
#' cd_scope("region", fixed_level = "district")
#' cd_scope("level_region", show_district = TRUE)
#'
#' @concept Countdown app layout
#' @export
cd_scope <- function(kind = c("national", "level", "region", "level_region"), fixed_level = NULL, show_district = FALSE) {
  list(kind = match.arg(kind), fixed_level = fixed_level, show_district = show_district)
}

#' Filter bar of a scope
#'
#' The filter bar holding the admin level and region chips a scope asks for. [cd_scoped_page_ui()]
#' uses it. Call it yourself in a page that lays out its own body but still takes its geography from
#' a scope, and pair it with [cd_scope_server()].
#'
#' @details The chips are an admin level filter ([cd_admin_level_ui()]) with the id `ns("scope")`.
#' So in the page's module server, call `cd_scope_server("scope", ...)` with the same scope.
#'
#' @param ns The page's namespace function, `NS(id)`.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param scope The page's scope, from [cd_scope()].
#'
#' @return The UI as Shiny tags (a filter bar), or `NULL` for a `"national"` scope, which has no
#'   filters.
#'
#' @examples
#' \dontrun{
#' scope <- cd_scope("level_region")
#'
#' my_page_ui <- function(id, i18n) {
#'   ns <- NS(id)
#'   cd_page_ui(id, i18n, filters = cd_scope_filters(ns, i18n, scope), my_cards(ns))
#' }
#' }
#'
#' @concept Countdown app layout
#' @export
cd_scope_filters <- function(ns, i18n, scope) {
  if (scope$kind == "national") return(NULL)
  cd_filter_bar(cd_admin_level_ui(ns("scope"), i18n, show_admin_level = scope$kind %in% c("level", "level_region")))
}

#' Admin level and region of a scope
#'
#' The server half of [cd_scope_filters()]: it gives the admin level and the region a scope resolves
#' to, as two reactives ready to hand to an analysis. Call it inside the page's module server.
#' [cd_scoped_page_server()] does this for a whole scoped page.
#'
#' @details For a `"national"` scope nothing is read from the page. For the other kinds it runs the
#' admin level filter ([cd_admin_level_server()]) with the settings the scope asks for, so the two
#' reactives wait until that filter has a value.
#'
#' @param id The id of the scope's filter within the page's module. Use `"scope"`, the id
#'   [cd_scope_filters()] gives the chips.
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param scope The page's scope, from [cd_scope()].
#'
#' @return A list of two reactives:
#'   * `admin_level`: `"national"` for a national scope. Otherwise the scope's `fixed_level` when it
#'     has one, else the level of the filter (`"adminlevel_1"` or `"district"`).
#'   * `region`: the name of the chosen area, or `NULL` when the scope has no region chip.
#'
#' @examples
#' \dontrun{
#' my_page_server <- function(id, cache, i18n) {
#'   moduleServer(id, function(input, output, session) {
#'     geo <- cd_scope_server("scope", cache, i18n, cd_scope("level_region"))
#'     observe(print(list(geo$admin_level(), geo$region())))
#'   })
#' }
#' }
#'
#' @concept Countdown app layout
#' @export
cd_scope_server <- function(id, cache, i18n, scope) {
  if (scope$kind == "national") {
    return(list(admin_level = reactive("national"), region = reactive(NULL)))
  }

  admin <- cd_admin_level_server(
    id, cache, i18n,
    show_admin_level = scope$kind %in% c("level", "level_region"),
    show_region = scope$kind != "level",
    show_district = scope$kind == "level_region" && scope$show_district
  )

  list(
    admin_level = reactive({
      req(admin())
      scope$fixed_level %||% admin()$admin_level
    }),
    region = reactive({
      req(admin())
      admin()$region
    })
  )
}

#' A whole page that runs an analysis at a scope
#'
#' Builds a page from an analysis module and a scope: the page's header and body, the scope's filter
#' bar, and the analysis module inside. Pages that run the same analysis at a different geography
#' then differ only in the scope they pass (see [cd_scope()]), and the filter bar and its wiring are
#' written once.
#'
#' @details
#' The analysis module is the app's own pair of functions:
#' * `inner_ui(id, i18n, ...)` returns the page's cards.
#' * `inner_server(id, cache, i18n, admin_level, region, active = )` takes the admin level and the
#'   region as two reactives (see [cd_scope_server()] for what they hold).
#'
#' Both are called with the id `"body"` inside the page's namespace. The page's title, section and
#' subtitle come from the app's page registry, so `id` must be the id of a registered page.
#'
#' @param id The module's id, which is also the page's id in the app's page registry.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#' @param scope The page's scope, from [cd_scope()]. Give the ui and the server the same one.
#' @param inner_ui The analysis module's ui function, called as `inner_ui(id, i18n, ...)`.
#' @param ... More arguments for `inner_ui`.
#'
#' @return `cd_scoped_page_ui()` returns the page's UI as Shiny tags.
#'
#'   `cd_scoped_page_server()` returns what `inner_server` returns.
#'
#' @examples
#' \dontrun{
#' scope <- cd_scope("region", fixed_level = "district")
#'
#' subnational_target_ui <- function(id, i18n) {
#'   cd_scoped_page_ui(id, i18n, scope, target_ui)
#' }
#' subnational_target_server <- function(id, cache, i18n, active = reactive(TRUE)) {
#'   cd_scoped_page_server(id, cache, i18n, scope, target_server, active)
#' }
#' }
#'
#' @concept Countdown app layout
#' @export
cd_scoped_page_ui <- function(id, i18n, scope, inner_ui, ...) {
  ns <- NS(id)
  cd_page_ui(id, i18n, filters = cd_scope_filters(ns, i18n, scope), inner_ui(ns("body"), i18n, ...))
}

#' @rdname cd_scoped_page_ui
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param inner_server The analysis module's server function, called as
#'   `inner_server(id, cache, i18n, admin_level, region, active = active)`.
#' @param active A reactive that is `TRUE` once the page has been opened with data loaded. It is
#'   passed to `inner_server`, which is expected to do no work before that. Default
#'   `reactive(TRUE)`.
#' @export
cd_scoped_page_server <- function(id, cache, i18n, scope, inner_server, active = reactive(TRUE)) {
  stopifnot(is.reactive(cache))
  stopifnot(is.reactive(active))

  moduleServer(
    id = id,
    module = function(input, output, session) {
      geo <- cd_scope_server("scope", cache, i18n, scope)
      inner_server("body", cache, i18n, geo$admin_level, geo$region, active = active)
    }
  )
}

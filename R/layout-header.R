#' Row naming the denominators in use
#'
#' The row a Countdown page header shows under its title: a label, one chip naming the vaccination
#' denominator, one naming the maternal denominator when there is one, and a note saying where the
#' denominators are set. [cd_denominator_header()] draws it on every page. Call it directly to show
#' the same row somewhere else.
#'
#' @param vaccination The id of the vaccination denominator in use, for example `"penta1"`. The chip
#'   shows the translation of `opt_` followed by the id, or the id in capitals when there is no such
#'   translation.
#' @param maternal The id of the maternal denominator in use, shown the same way. `NULL` (the
#'   default) leaves its chip out, for an app with no maternal denominator.
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return The UI as Shiny tags (a `div`).
#'
#' @examples
#' \dontrun{
#' cd_denominator_row("penta1", "anc1", i18n)
#' cd_denominator_row("penta1", i18n = i18n)
#' }
#'
#' @concept Countdown app layout
#' @export
cd_denominator_row <- function(vaccination, maternal = NULL, i18n) {
  label <- function(code) {
    key <- paste0('opt_', code)
    val <- i18n$t(key)
    if (is.null(val) || identical(val, key)) toupper(code) else val
  }
  chip <- function(kind_key, code) {
    span(class = 'cd-denom-chip', span(class = 'cd-denom-chip__dot'),
         span(class = 'cd-denom-chip__kind', i18n$t(kind_key)), label(code))
  }
  div(
    class = 'cd-denominator-row',
    span(class = 'cd-denominator-row__label', i18n$t('lbl_denominator_row')),
    chip('opt_vacc', vaccination),
    if (!is.null(maternal)) chip('title_global_maternal', maternal),
    span(class = 'cd-denominator-row__note', i18n$t('msg_denominator_set_on'))
  )
}

#' Draw the denominator row in a page header
#'
#' What a Countdown app adds to the server of every page header: it fills the header's `denominator`
#' output with [cd_denominator_row()] for the denominators the dataset uses. [cd_app()] passes it to
#' the app frame (`app_frame(page_header_extra = )`), which runs it inside each page header's
#' module, so a page never calls it itself.
#'
#' @details It reads `cache()$denominator` and, when the app has a maternal denominator
#' ([cd_has_maternal()]), `cache()$maternal_denominator`. The row is drawn once the values it needs
#' are set, and again when one of them changes.
#'
#' @param input,output,session The `input`, `output` and `session` of the page header's module.
#' @param cache A reactive that returns the dataset, a [CacheConnection].
#' @param i18n The app's translator (a `shiny.i18n` translator), used for every label.
#'
#' @return Nothing useful. It is called for what it does.
#'
#' @examples
#' \dontrun{
#' # cd_app() gives it to the app frame, which calls it in each page header's module
#' app_frame(app_name, app_version, theme, nav_sections, registry, i18n, language, selected_file,
#'   data_server = data_server, page_header_extra = cd_denominator_header
#' )
#'
#' # the call the frame makes, where the header has uiOutput(ns("denominator"))
#' moduleServer("header", function(input, output, session) {
#'   cd_denominator_header(input, output, session, cache = cache, i18n = i18n)
#' })
#' }
#'
#' @concept Countdown app layout
#' @export
cd_denominator_header <- function(input, output, session, cache, i18n) {
  output$denominator <- renderUI({
    req(cache(), cache()$denominator)
    if (!cd_has_maternal()) return(cd_denominator_row(cache()$denominator, NULL, i18n))
    req(cache()$maternal_denominator)
    cd_denominator_row(cache()$denominator, cache()$maternal_denominator, i18n)
  })
}

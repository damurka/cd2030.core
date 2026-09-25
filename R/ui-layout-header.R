# The page header's Countdown row: the denominators in use (the header itself is datasuite.ui's).

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

# The page header's denominator row (datasuite.ui's cd_page_header_server() runs it on every page, see cd_app())
cd_denominator_header <- function(input, output, session, cache, i18n) {
  output$denominator <- renderUI({
    req(cache(), cache()$denominator)
    if (!cd_has_maternal()) return(cd_denominator_row(cache()$denominator, NULL, i18n))
    req(cache()$maternal_denominator)
    cd_denominator_row(cache()$denominator, cache()$maternal_denominator, i18n)
  })
}

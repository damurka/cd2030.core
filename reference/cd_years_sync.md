# Keep a years chip in step with the dataset

The server half of a filter chip that chooses several years. The chip
itself is a multi-choice chip the page draws (`cd_chip_multi()`). This
function gives the chip its options, the years in the data, and sets it
to the years already chosen in the dataset. Choosing nothing in the chip
means "all years".

## Usage

``` r
cd_years_sync(input, session, id = "years", years, selected)
```

## Arguments

- input:

  The module's `input`.

- session:

  The module's `session`.

- id:

  The chip's input id within the module. Default `"years"`.

- years:

  A reactive that returns the years the chip offers, the years in the
  data.

- selected:

  A reactive that returns the years chosen in the dataset. An empty or
  all-`NA` value means no choice, which leaves the chip empty ("all
  years").

## Value

Nothing useful (the observer it creates). It is called for what it does.

## Details

Call it once inside a module server. It sends the options and the chosen
years to the chip once the chip is on the page, and again when `years()`
or `selected()` changes. It does not send the chip what the chip already
holds.

It only goes from the dataset to the chip. The page saves the reader's
choice itself, with its own `observeEvent(input$years, ...)`, where
[`cd_years_input()`](cd_years_input.md) turns the chip's value into the
years it means.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_chip_multi(ns("years"), "title_global_select_years", i18n = i18n)

# in the page's server
cd_years_sync(input, session, "years",
  years = reactive(cache()$data_years),
  selected = reactive(cache()$mapping_years)
)
observeEvent(input$years, {
  cache()$set_mapping_years(cd_years_input(input$years, cache()$data_years))
})
} # }
```

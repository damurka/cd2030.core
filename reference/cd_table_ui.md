# Table card with a year or indicator control

A card that shows a data frame as a table, with a control above it (a
year chip or an indicator chip) and a download of the data as an Excel
workbook in the card's header. The module translates the column headings
it knows, rounds the numbers and aligns them. Use it for the table that
goes with a page's charts. For a formatted table (a flextable), use
[`cd_table_card_ui()`](cd_table_card_ui.md).

## Usage

``` r
cd_table_ui(
  id,
  i18n,
  title_key,
  control_type = c("year", "indicator"),
  width = 6
)

cd_table_server(
  id,
  cache,
  i18n,
  data,
  columns = NULL,
  control_type = c("year", "indicator"),
  filename = reactive("download"),
  label_key = "btn_global_download_data",
  extension = reactive("xlsx"),
  data_transform = NULL,
  excel_write_fun = NULL,
  excel_sheet = NULL,
  excel_title = NULL,
  about = NULL
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- title_key:

  The translation key of the card's title.

- control_type:

  The control above the table: `"year"` (the default) or `"indicator"`.

- width:

  The card's width, passed to the kit's `cd_table_card()`. Default `6`.
  The kit's card takes a width and ignores it: a card is as wide as the
  place it is put in.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- data:

  A reactive that returns the data frame the table shows.

- columns:

  A named list of
  [`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html),
  named by column. Each one replaces or adds to what the module sets for
  that column (heading, cell, alignment). Entries for columns the data
  does not have are dropped. `NULL` (the default) changes nothing.

- filename:

  A reactive that returns the first part of the downloaded file's name.
  Default `reactive("download")`.

- label_key:

  The translation key of the download button's label. Default
  `"btn_global_download_data"`.

- extension:

  A reactive that returns the downloaded file's extension. Default
  `reactive("xlsx")`. The file is an Excel workbook whatever the
  extension says.

- data_transform:

  A function `function(data)` applied to
  [`data()`](https://rdrr.io/r/utils/data.html) before the table is
  drawn, for example to choose or rename columns. `NULL` (the default)
  shows [`data()`](https://rdrr.io/r/utils/data.html) as it is.

- excel_write_fun:

  A function `function(wb, data)` that writes
  [`data()`](https://rdrr.io/r/utils/data.html) into the `openxlsx`
  workbook `wb`, adding the sheets it needs. `NULL` (the default) uses
  `excel_sheet`, or the plain download described in Details.

- excel_sheet:

  The translation key of the sheet's name, for a download that holds
  [`data()`](https://rdrr.io/r/utils/data.html) on one sheet. Used only
  when `excel_write_fun` is `NULL`. Default `NULL`.

- excel_title:

  The translation key of a title written above the data on that sheet.
  Used only with `excel_sheet`. Default `NULL`, no title.

- about:

  What the table is, for the app's AI: `NULL` (the default), a list, or
  a function that returns a list. See
  [`datasuite.ui::ai_register_component()`](https://rdrr.io/pkg/datasuite.ui/man/ai_register_component.html).

## Value

`cd_table_ui()` returns the UI as Shiny tags (the card).

`cd_table_server()` returns a reactive holding the control's value: the
chosen year as a string, or the chosen indicator's code.

## Details

**The control.** Give `control_type` the same value in the ui and the
server call.

- `"year"`: a chip listing the dataset's years (`cache()$data_years`),
  which starts on the first of them. When the data has a `year` column,
  the table shows only the rows of the chosen year.

- `"indicator"`: an indicator chip
  ([`cd_indicator_ui()`](cd_indicator_ui.md)) offering every indicator.
  The module does not filter by it. The page reads the chosen indicator
  from the reactive the server returns and builds `data` from it.

**The columns.** These headings are translated without the page doing
anything: `year`, `adminlevel_1`, `district` and `month`; columns whose
name starts with `cov_` (coverage); columns whose name ends with `_med`
or `_mad` (median and MAD of an indicator) and the indicator's own
column beside them; and, with the indicator control, the column named
after the chosen indicator. Every other column keeps its name unless
`columns` gives it a heading. Numbers are shown rounded to whole numbers
and aligned to the right, except `year` and `month`.

**The download.** The file is an Excel workbook named `filename()`, then
the control's value, then the date and time. What it holds depends on
the arguments:

- With `excel_write_fun`, that function writes the workbook from
  [`data()`](https://rdrr.io/r/utils/data.html).

- Else with `excel_sheet`, [`data()`](https://rdrr.io/r/utils/data.html)
  is written on one sheet with that name, under `excel_title` when it is
  given.

- With neither, the data the table is drawn from
  ([`data()`](https://rdrr.io/r/utils/data.html) after `data_transform`)
  is written on one sheet named "Data".

With a year control the download holds the year the control is on, as
the table does and as the file's name says.

The table is also registered with the app's AI bridge, which can then
list it and read its data.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_table_ui(ns("rates"), i18n, "title_rr_main", control_type = "year")

# in the page's server
year <- cd_table_server("rates", cache, i18n,
  data = reactive(my_rates(cache())),
  columns = list(anc_rr = reactable::colDef(name = "ANC", cell = cd_rate_status_cell)),
  filename = reactive("reporting_rate"),
  excel_sheet = "title_rr_main"
)
} # }
```

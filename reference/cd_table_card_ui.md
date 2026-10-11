# Flextable in a card with picture and Excel downloads

A card that shows a formatted table (a flextable) on screen, with two
downloads in the card's header: the table as a picture and its data as
an Excel workbook. Use it for a table whose layout matters, such as a
scorecard. The Overall Score page uses it. For a plain table of data,
use [`cd_table_ui()`](cd_table_ui.md).

## Usage

``` r
cd_table_card_ui(id, i18n, title, ..., width = 12)

cd_table_card_server(
  id,
  i18n,
  data,
  table_fun,
  filename,
  sheet = "lbl_score_metric_header",
  about = NULL
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- title:

  The card's title: text that is already translated (`i18n$t("...")`),
  or a tag.

- ...:

  More arguments for the kit's `cd_chart_card()`, which passes them to
  `cd_card()`: for example `status = "success"`.

- width:

  The card's width, passed to the kit's `cd_chart_card()`. Default `12`.
  The kit's card takes a width and ignores it: a card is as wide as the
  place it is put in.

- data:

  A reactive that returns what the table shows. It is given to
  `table_fun` and written to the Excel workbook.

- table_fun:

  A function `function(data)` that returns the flextable.

- filename:

  A reactive that returns the first part of the downloaded files' name.
  The date and time and the extension are added to it.

- sheet:

  The translation key of the workbook's sheet name. Default
  `"lbl_score_metric_header"`.

- about:

  What the table is, for the app's AI: `NULL` (the default), a list, or
  a function that returns a list. See
  [`datasuite.ui::ai_register_component()`](https://rdrr.io/pkg/datasuite.ui/man/ai_register_component.html).

## Value

`cd_table_card_ui()` returns the UI as Shiny tags (the card).

`cd_table_card_server()` returns nothing useful. It is called for what
it does.

## Details

The page gives the data and one function that turns it into a flextable.
The table on screen and the picture are drawn with the same function, so
they always match. The picture is a PNG file. The workbook holds
[`data()`](https://rdrr.io/r/utils/data.html) on one sheet. Both files
are named `filename()` followed by the date and time.

The table is drawn once [`data()`](https://rdrr.io/r/utils/data.html)
has a value. It is also registered with the app's AI bridge, which can
then list it and read its data.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_table_card_ui(ns("score"), i18n, i18n$t("title_score_main"), status = "success")

# in the page's server
cd_table_card_server("score", i18n,
  data = reactive(my_scores(cache())),
  table_fun = function(d) flextable::flextable(d),
  filename = reactive("overall_score")
)
} # }
```

# Denominator filter chip

A filter chip that chooses the denominator the dataset uses, either the
vaccination denominator or the maternal one. The choice is kept in the
dataset, so every page that reads the denominator follows it. The
Denominator Selection page uses one chip for each.

## Usage

``` r
cd_denominator_ui(id, i18n, allow_input = FALSE, is_maternal = FALSE)

cd_denominator_server(
  id,
  cache,
  i18n,
  label = "title_denom_select_best",
  allowInput = FALSE,
  is_maternal = FALSE,
  display_mode = "combined"
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label. The server does not use it.

- allow_input:

  Logical. `TRUE` draws the chip. Default `FALSE`, which draws nothing.

- is_maternal:

  Logical. `TRUE` for the maternal denominator, `FALSE` (the default)
  for the vaccination denominator. It decides the chip's label and hint,
  and which value of the dataset the server reads and saves.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- label:

  Not used.

- allowInput:

  Logical. `TRUE` keeps the chip and the dataset in step. Default
  `FALSE`, which does nothing. Give it the value the ui's `allow_input`
  has.

- display_mode:

  Not used.

## Value

`cd_denominator_ui()` returns the UI as Shiny tags (the chip), or `NULL`
when `allow_input` is `FALSE`.

`cd_denominator_server()` returns nothing useful. It is called for what
it does.

## Details

The chip starts empty and the server fills it from the dataset once the
chip is on the page: `cache()$denominator`, or
`cache()$maternal_denominator` when `is_maternal` is `TRUE`. When the
value changes in the dataset, the chip follows. When the reader chooses
a denominator, the server saves it with the dataset's
`set_denominator()` or `set_maternal_denominator()`. An empty chip saves
nothing.

The chip is drawn, and the dataset kept in step, only when asked for:
pass `allow_input = TRUE` to the ui and `allowInput = TRUE` to the
server (the two arguments are spelled differently). With the defaults
the ui is `NULL` and the server does nothing.

The chip's choices are
[`cd_denominator_options()`](cd_denominator_options.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_denominator_ui(ns("vaxx_denominator"), i18n, allow_input = TRUE)

# in the page's server
cd_denominator_server("vaxx_denominator", cache, i18n, allowInput = TRUE)
} # }
```

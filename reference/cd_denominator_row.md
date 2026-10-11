# Row naming the denominators in use

The row a Countdown page header shows under its title: a label, one chip
naming the vaccination denominator, one naming the maternal denominator
when there is one, and a note saying where the denominators are set.
[`cd_denominator_header()`](cd_denominator_header.md) draws it on every
page. Call it directly to show the same row somewhere else.

## Usage

``` r
cd_denominator_row(vaccination, maternal = NULL, i18n)
```

## Arguments

- vaccination:

  The id of the vaccination denominator in use, for example `"penta1"`.
  The chip shows the translation of `opt_` followed by the id, or the id
  in capitals when there is no such translation.

- maternal:

  The id of the maternal denominator in use, shown the same way. `NULL`
  (the default) leaves its chip out, for an app with no maternal
  denominator.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

## Value

The UI as Shiny tags (a `div`).

## Examples

``` r
if (FALSE) { # \dontrun{
cd_denominator_row("penta1", "anc1", i18n)
cd_denominator_row("penta1", i18n = i18n)
} # }
```

# Tab label of a consistency check pair

Gives the label of one indicator pair's tab on the Consistency checks
card ([`consistency_check_ui()`](consistency_check_ui.md)). The label is
the pair's translation (the key `opt_consist_<x>_<y>`) when the
translator has one. Otherwise it is the two indicator codes in capitals
joined by "and" (`"ANC1 and PENTA1"`).

## Usage

``` r
consistency_pair_label(i18n, pair)
```

## Arguments

- i18n:

  The app's translator (a `shiny.i18n` translator).

- pair:

  A character vector of two indicator codes, the first for the x axis
  and the second for the y axis (`c("anc1", "penta1")`).

## Value

The label: what `i18n$t()` gives for the pair's key when it is
translated, otherwise a character string.

## Examples

``` r
if (FALSE) { # \dontrun{
# i18n is the app's translator, as a page receives it
consistency_pair_label(i18n, c("anc1", "penta1"))

# the labels of every pair the app compares, named by tab key
pairs <- cd_cfg("consistency_pairs", list(c("anc1", "penta1"), c("penta1", "penta3")))
labels <- vapply(pairs, function(pair) consistency_pair_label(i18n, pair), character(1))
setNames(labels, consistency_pair_keys())
} # }
```

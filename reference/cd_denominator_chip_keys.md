# Label and hint of a denominator chip

The translation keys of the label and of the hint a denominator chip
shows. [`cd_denominator_ui()`](cd_denominator_ui.md) uses them, and a
page that draws a denominator chip of its own can use them to match it.

## Usage

``` r
cd_denominator_chip_keys(is_maternal)
```

## Arguments

- is_maternal:

  Logical. `TRUE` for the maternal denominator's chip, `FALSE` for the
  vaccination denominator's.

## Value

A list of two translation keys, `label` and `hint`.

## Examples

``` r
cd_denominator_chip_keys(is_maternal = TRUE)
#> $label
#> [1] "lbl_chip_denom_mat"
#> 
#> $hint
#> [1] "tt_denom_select_best_mat"
#> 
cd_denominator_chip_keys(is_maternal = FALSE)
#> $label
#> [1] "lbl_chip_denom_vacc"
#> 
#> $hint
#> [1] "tt_denom_select_best_vacc"
#> 
```

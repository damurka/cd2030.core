# Detemine if an indicator is maternal indicator

Default grouping of indicators used in CD2030 coverage framework

## Usage

``` r
is_maternal_indicator(indicator)
```

## Arguments

- indicator:

  Character. Indicator name(s) to check, for example `"anc1"`. Always
  `FALSE` unless the selected group is `"rmncah"`.

## Value

TRUE if and indicator is maternal

## Examples

``` r
is_maternal_indicator("anc4")
#> [1] TRUE
is_maternal_indicator(c("anc4", "ideliv", "penta3"))
#> [1]  TRUE  TRUE FALSE
```

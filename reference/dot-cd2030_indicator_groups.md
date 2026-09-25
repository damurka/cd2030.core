# Built-in indicator groups (defaults)

`.cd2030_indicator_groups` defines the built-in indicator groups (a.k.a.
*profiles*) shipped with the package. Users can **override or extend**
these via
[`register_indicator_group()`](https://aphrcwaro.github.io/cd2030.core/reference/register_indicator_group.md);
the live view used throughout the package is the merged result returned
by `.get_all_groups()`.

## Usage

``` r
.cd2030_indicator_groups
```

## Format

A named list. Top-level names are group names (e.g. `"rmncah"`,
`"vaccine"`). Each value is a named list of categories -\> character
vector of indicators.

## Details

Each group is a **named list of categories**, where each category
contains a character vector of indicator codes.

## Examples

``` r
names(.cd2030_indicator_groups)              # built-in groups
#> Error: object '.cd2030_indicator_groups' not found
.cd2030_indicator_groups$rmncah$anc          # RMNCAH ANC indicators
#> Error: object '.cd2030_indicator_groups' not found
```

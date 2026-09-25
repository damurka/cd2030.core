# Auto-detect the best-matching indicator group from a vector of indicators

Given a character vector of indicator codes present in the dataset,
selects the group whose **entire universe** is present in the data
(strict coverage: `group ⊆ data`). If multiple groups are fully covered,
the tie is broken by choosing the **largest** universe (most specific),
then alphabetically.

## Usage

``` r
detect_indicator_group(indicators)
```

## Arguments

- indicators:

  Character vector of indicator codes present in the data.

## Value

The detected group name (character scalar).

## Details

Detection considers the merged view from `.get_all_groups()` (i.e.,
built-ins plus any user overrides registered via
[`register_indicator_group()`](https://aphrcwaro.github.io/cd2030.core/reference/register_indicator_group.md)).

## Examples

``` r
if (FALSE) { # \dontrun{
inds <- c("anc1","penta1","penta3","measles1","measles2","bcg")
detect_indicator_group(inds)
} # }
```

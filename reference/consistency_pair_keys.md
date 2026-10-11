# Tab keys of the consistency check pairs

Gives the key of each indicator pair the Consistency checks card
([`consistency_check_ui()`](consistency_check_ui.md)) compares. The
pairs come from the app's `consistency_pairs` setting (see
[`cd_cfg()`](cd_cfg.md)). Without that setting they are ANC1 with Penta1
and Penta1 with Penta3. The card has one tab per key, followed by its
`"custom"` tab, which is not in this list.

## Usage

``` r
consistency_pair_keys()
```

## Value

A character vector with one key per pair, the two indicator codes joined
by an underscore (`"anc1_penta1"`).

## Examples

``` r
consistency_pair_keys()
#> [1] "anc1_penta1"   "penta1_penta3"

# the pairs an app sets
old <- options(cd2030.config = list(consistency_pairs = list(c("anc1", "penta1"), c("opv1", "opv3"))))
consistency_pair_keys()
#> [1] "anc1_penta1" "opv1_opv3"  
options(old)
```

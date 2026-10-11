# Get indicator group names

Lists the names of the categories (such as `anc`, `idelv` or `vacc`)
that the indicators of the selected indicator group are arranged in.
These are the names of
[`get_indicator_groups()`](get_indicator_groups.md).

## Usage

``` r
get_indicator_group_names()
```

## Value

Character vector of indicator group names

## Examples

``` r
get_indicator_group_names()
#> [1] "anc"   "idelv" "vacc"  "opd"   "ipd"  

# the indicators of one of them
get_indicator_groups()[["vacc"]]
#> [1] "penta1"   "penta3"   "measles1" "measles2" "bcg"     
```

# The charts and tables a report can contain

What each kind draws and which settings it takes. The builder offers
these;
[`render_report_block()`](https://rdrr.io/pkg/datasuite.ui/man/render_report_block.html)
draws them.

## Usage

``` r
report_block_kinds(group = get_selected_group())
```

## Arguments

- group:

  The indicator group; kinds that only make sense for one group
  (`groups`) are left out of the other.

## Value

A named list; each entry has `type` (`"chart"` or `"table"`), `group`,
`label`, `indicators` (`"analysis"`, a character vector, or `NULL` when
the kind has no indicator), `levels`, `variants` (named character vector
or `NULL`), `year` (whether a year is chosen), `regional` (whether it is
drawn for one region) and `groups` (the indicator groups it is for).

## Details

The kinds are listed in the order of the analysis (their `group`: data
quality, adjustment, denominators, national, sub-national, region,
mortality, service utilization, health system). The standard report
files add their own kinds (see the top of the standard reports section).

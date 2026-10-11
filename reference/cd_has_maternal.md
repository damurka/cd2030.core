# Whether this app has a maternal denominator

Tells a shared page whether to show what belongs to the maternal
denominator: its chip on the Denominator Selection page and its entry in
the page header's denominator row.

## Usage

``` r
cd_has_maternal()
```

## Value

`TRUE` or `FALSE`.

## Details

The answer is the app's `has_maternal` setting (see
[`cd_cfg()`](cd_cfg.md)). When the app does not set it, the answer is
`TRUE` unless `getOption("cd2030.selected_group")` is `"vaccine"`.

## Examples

``` r
old <- options(cd2030.config = list(has_maternal = FALSE))
cd_has_maternal()
#> [1] FALSE
options(old)
```

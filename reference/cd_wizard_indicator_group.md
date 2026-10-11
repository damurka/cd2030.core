# The indicator group the running app is for

Returns the indicator group of the app, from
`options(cd2030.app_group = ...)`. When that option is not set it falls
back to `getOption("cd2030.selected_group")`. The wizard uses it to
build a dataset for the app's group and to name the dataset's saved
copy.

## Usage

``` r
cd_wizard_indicator_group()
```

## Value

The indicator group, as the app set it (a string such as `"rmncah"` or
`"vaccine"`). The function stops with an error when neither option is
set.

## Examples

``` r
old <- options(cd2030.app_group = "rmncah")
cd_wizard_indicator_group()
#> [1] "rmncah"
options(old)
```

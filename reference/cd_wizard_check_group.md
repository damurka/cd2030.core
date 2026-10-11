# Check that a loaded dataset belongs to the app's indicator group

Sets the package's selected indicator group back to the app's group
(with [`set_selected_group()`](set_selected_group.md)), then stops with
an error when the dataset was built for a different group. The group a
dataset was built for is the `indicator_group` attribute of its
`countdown_data`. A dataset without that attribute, or a `NULL` dataset,
passes.

## Usage

``` r
cd_wizard_check_group(cache)
```

## Arguments

- cache:

  The dataset, a [CacheConnection](CacheConnection.md) object (not a
  reactive), or `NULL`.

## Value

`TRUE`, invisibly. The function stops with an error when the dataset was
built for another indicator group.

## Examples

``` r
old <- options(cd2030.app_group = "rmncah")
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cd_wizard_check_group(cache)

# no dataset passes too
cd_wizard_check_group(NULL)
options(old)
```

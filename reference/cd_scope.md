# Define the scope of a scoped page

A scope says at which geography a page runs its analysis: which admin
level and region filters the page shows, and what admin level and region
it hands to the analysis. Pages that run the same analysis at a
different geography (national coverage and sub-national coverage, for
example) differ only in their scope. Pass the result to
[`cd_scoped_page_ui()`](cd_scoped_page_ui.md) and
[`cd_scoped_page_server()`](cd_scoped_page_ui.md), or to
[`cd_scope_filters()`](cd_scope_filters.md) and
[`cd_scope_server()`](cd_scope_server.md).

## Usage

``` r
cd_scope(
  kind = c("national", "level", "region", "level_region"),
  fixed_level = NULL,
  show_district = FALSE
)
```

## Arguments

- kind:

  The kind of scope: `"national"` (the default), `"level"`, `"region"`
  or `"level_region"`.

- fixed_level:

  An admin level (for example `"district"`) handed to the analysis in
  place of the level of the filter bar. `NULL` (the default) hands over
  the level of the filter bar. A `"national"` scope ignores it.

- show_district:

  Logical. For `kind = "level_region"`, whether a district can be chosen
  as the region. Other kinds ignore it. Default `FALSE`.

## Value

A list with the elements `kind`, `fixed_level` and `show_district`, as
given.

## Details

The kinds of scope:

- `"national"`: no filters. The analysis gets the admin level
  `"national"` and no region.

- `"level"`: an admin level chip only (admin level 1 or district). The
  analysis gets the chosen level and no region.

- `"region"`: a region chip only, listing the admin level 1 areas. The
  analysis gets the chosen area and the admin level `"adminlevel_1"`, or
  `fixed_level` when it is given.

- `"level_region"`: an admin level chip and a region chip. The region
  chip is shown at admin level 1, and also at the district level when
  `show_district` is `TRUE`.

## Examples

``` r
cd_scope()
#> $kind
#> [1] "national"
#> 
#> $fixed_level
#> NULL
#> 
#> $show_district
#> [1] FALSE
#> 
cd_scope("region", fixed_level = "district")
#> $kind
#> [1] "region"
#> 
#> $fixed_level
#> [1] "district"
#> 
#> $show_district
#> [1] FALSE
#> 
cd_scope("level_region", show_district = TRUE)
#> $kind
#> [1] "level_region"
#> 
#> $fixed_level
#> NULL
#> 
#> $show_district
#> [1] TRUE
#> 
```

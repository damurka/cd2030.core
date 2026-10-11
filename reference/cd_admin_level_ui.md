# Admin level and region filter chips

Two filter chips for a page's filter bar: one chooses the admin level
(admin level 1 or district, and national when asked for), the other a
single area at that level. A page puts `cd_admin_level_ui()` in its
filter bar, calls `cd_admin_level_server()` in its server, and reads the
chosen level and area from the reactive the server returns.
[`cd_admin_parts()`](cd_admin_parts.md) splits that reactive into one
reactive for the level and one for the area.

## Usage

``` r
cd_admin_level_ui(id, i18n, include_national = FALSE, show_admin_level = TRUE)

cd_admin_level_server(
  id,
  cache,
  i18n,
  allow_select_all = FALSE,
  show_district = TRUE,
  show_region = TRUE,
  show_admin_level = TRUE,
  selected_admin1 = reactive(NULL)
)
```

## Arguments

- id:

  The module's id.

- i18n:

  The app's translator (a `shiny.i18n` translator), used for every
  label.

- include_national:

  Logical. `TRUE` adds the national level to the level chip, as its
  first choice and so the one it starts on. Default `FALSE`.

- show_admin_level:

  Logical. `FALSE` leaves the level chip out, for a page that only lets
  the reader choose an area. Default `TRUE`.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

- allow_select_all:

  Logical. `TRUE` adds an "all" option to the region chip and starts the
  chip on it. Default `FALSE`.

- show_district:

  Logical. Whether an area can be chosen at the district level. With a
  level chip, `FALSE` hides the region chip while the level is district.
  Without a level chip, it sets the fixed level (see Details). Default
  `TRUE`.

- show_region:

  Logical. `FALSE` never shows the region chip, so `region` is always
  `NULL`. Default `TRUE`.

- selected_admin1:

  A reactive that returns the name of an admin level 1 area, or `NULL`.
  When it returns a name and the level is district, the region chip
  lists only the districts of that area. Default `reactive(NULL)`, every
  district.

## Value

`cd_admin_level_ui()` returns the UI as Shiny tags: the level chip (when
shown) and the place where the server draws the region chip.

`cd_admin_level_server()` returns a reactive holding a list with two
elements:

- `admin_level`: `"national"`, `"adminlevel_1"` or `"district"`.

- `region`: the name of the chosen area, or `NULL` when the region chip
  is not shown or "all" is chosen.

While the region chip is shown but has not yet reported a value, the
reactive stops quietly (as
[`shiny::req()`](https://rdrr.io/pkg/shiny/man/req.html) does), so what
depends on it waits.

## Details

The region chip is drawn by the server, so it appears only where there
are areas to choose from: never at the national level, never when
`show_region` is `FALSE`, and at the district level only when
`show_district` is `TRUE`. Its options are the areas of
`cache()$subnational_regions` at the chosen level, and districts are
listed under the admin level 1 area they belong to. Changing the level
draws a new region chip, so an area of the old level is never kept. The
list of areas is debounced by 300 milliseconds.

With `allow_select_all = TRUE` the region chip starts on an "all"
option, which the server reports as a `NULL` region. Without it the chip
starts on the first area in the list.

When `show_admin_level` is `FALSE` there is no level chip, and the level
is fixed: `"district"` when `show_district` is `TRUE` (the default),
`"adminlevel_1"` otherwise. Give `show_admin_level` the same value in
the ui and the server call.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_filter_bar(cd_admin_level_ui(ns("admin_level"), i18n))

# in the page's server
admin <- cd_admin_level_server("admin_level", cache, i18n, allow_select_all = TRUE)
observe({
  admin()$admin_level
  admin()$region
})
} # }
```

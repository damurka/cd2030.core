# Define the Scope of a Scoped Page

What filters a scoped page shows.

- "national": none; the analysis gets admin_level "national" and no
  region

- "level": an admin-level chip only (no region chip)

- "region": a region chip only; the analysis gets `fixed_level` (default
  "adminlevel_1")

- "level_region": an admin-level chip and a region chip; `show_district`
  lets districts be picked as regions

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

  Character. The kind of scope: one of `"national"`, `"level"`,
  `"region"` or `"level_region"` (see above). Defaults to `"national"`.

- fixed_level:

  Optional admin level (for example `"district"`) handed to the analysis
  instead of the level chosen in the filter bar. Default is `NULL` (use
  the chosen level).

- show_district:

  Logical. For `kind = "level_region"`, whether districts can be picked
  as regions. Default is `FALSE`.

## Value

A list with elements `kind`, `fixed_level` and `show_district`.

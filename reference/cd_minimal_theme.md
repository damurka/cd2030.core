# A minimal chart theme

[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
with a choice of grid lines, for the apps' light charts (cd2030.pooled's
charts, the subnational coverage dot plot and heat map).

## Usage

``` r
cd_minimal_theme(
  base_size = 11,
  grid = c("all", "major", "x", "y", "none"),
  grid_colour = NULL
)
```

## Arguments

- base_size:

  The base font size, in points.

- grid:

  Which grid lines to keep: `"all"` (the theme's own), `"major"` (no
  minor lines), `"x"` (only the vertical major lines, for horizontal
  bars and dot plots), `"y"` (only the horizontal major lines) or
  `"none"`.

- grid_colour:

  The colour of the lines `"x"` or `"y"` keeps, or `NULL` for the
  theme's own.

## Value

A ggplot2 theme.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(mpg, factor(cyl))) +
  geom_point() +
  cd_minimal_theme(grid = "x")
```

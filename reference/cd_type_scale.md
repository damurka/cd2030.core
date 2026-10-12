# The sizes of the text of a chart

The one scale the charts of the Countdown apps are written in, for a
chart drawn outside the package that is to look like them.

## Usage

``` r
cd_type_scale()
```

## Value

A named list: `title`, `subtitle`, `axis_title`, `axis_text`, `legend`,
`strip` and `caption` in points (for
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html));
`label` and `label_small` in millimetres (the `size` of
[`ggplot2::geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html)).

## Examples

``` r
cd_type_scale()$title
#> [1] 15
```

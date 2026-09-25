# A Specialized Dot Plot for Maternal Education Analysis

`equiplot_education` generates a dot plot comparing coverage across
maternal education levels (no education, primary, and secondary or
higher) for a specific indicator across years.

## Usage

``` r
equiplot_education(.data, indicator, x_title = NULL, dot_size = NULL)
```

## Arguments

- .data:

  A data frame containing the data to be plotted.

- indicator:

  A string specifying the indicator to be analyzed (e.g., 'sba').

- x_title:

  Optional. A title for the x-axis. Defaults to ' Coverage (%)'.

## Value

A ggplot object representing the dot plot.

## Examples

``` r
if (FALSE) { # \dontrun{
equiplot_education(data, indicator = "sba")
} # }
```

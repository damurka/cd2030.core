# A Specialized Dot Plot for Area of Residence Analysis

`equiplot_area` generates a dot plot comparing rural and urban coverage
of a specific indicator across years.

## Usage

``` r
equiplot_area(.data, indicator, x_title = NULL, dot_size = NULL)
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
equiplot_area(data, indicator = "sba")
} # }
```

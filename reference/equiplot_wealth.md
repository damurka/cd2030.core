# A Specialized Dot Plot for Wealth Quintile Analysis

`equiplot_wealth` generates a dot plot comparing coverage across wealth
quintiles (Q1 to Q5) for a specific indicator across years.

## Usage

``` r
equiplot_wealth(.data, indicator, x_title = NULL, dot_size = NULL)
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
equiplot_wealth(data, indicator = "sba")
} # }
# Example Usage:
```

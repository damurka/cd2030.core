# Plot Missing Summary

This method visualizes missing results for immunization indicators

## Usage

``` r
# S3 method for class 'cd_completeness_summary'
plot(x, indicator = NULL, ...)
```

## Arguments

- x:

  A `cd_outlier` object containing pre-processed outlier data.

- indicator:

  Optional. One of the supported indicators (`'opv1'`, `'penta3'`, etc.)
  to visualize in the plot. If `NULL` all indicators will be shown.

- ...:

  Reserved for future use.

## Value

A `ggplot` or `plotly` object depending on the selection type.

## Examples

``` r
if (FALSE) { # \dontrun{
# Region-level summary
plot(missing_data, indicator = 'penta3')
} # }
```

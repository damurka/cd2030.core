# Plot Ratios Summary for Indicator Ratios Summary Object

This function generates a bar plot for a `cd_ratios_summary` object,
displaying the calculated indicator ratios for each year. It allows for
visual comparison across years, showing how each indicator ratio changes
over time.

## Usage

``` r
# S3 method for class 'cd_ratios_summary'
plot(
  x,
  title = NULL,
  x_axis = NULL,
  y_axis = NULL,
  x_labels = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_ratios_summary` object created by the `calculate_ratios_summary`
  function. It should contain a `year` column and one or more columns
  with names starting with `"Ratio"`, representing the calculated
  indicator ratios.

- title:

  Optional plot title. Defaults to a title describing the ANC1 to Penta1
  and Penta1 to Penta3 ratios.

- x_axis, y_axis:

  Optional x- and y-axis titles. Default is `NULL`.

- x_labels:

  Optional named list or vector of x-axis category labels, keyed by
  ratio name (`anc1_penta1`, `opv1_opv3`, `penta1_penta3`). Supplied
  entries replace the defaults.

- ...:

  Additional arguments passed to other methods (currently unused).

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `ggplot` object representing a bar plot of indicator ratios by year.

## Details

This function provides a visual summary of indicator ratios, with each
ratio displayed as a bar for each year. The `Expected Ratio` row is
included if available, allowing for easy comparison of actual ratios
against expected values. The bars are grouped by year, with distinct
colors representing each year for clear differentiation.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming `cd_ratios_summary` is the object returned by `calculate_ratios_summary`
plot(cd_ratios_summary)
} # }
```

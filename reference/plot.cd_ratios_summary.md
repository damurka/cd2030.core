# Plot Ratios Summary for Indicator Ratios Summary Object

This function generates a bar plot for a `cd_ratios_summary` object,
displaying the calculated indicator ratios for each year. It allows for
visual comparison across years, showing how each indicator ratio changes
over time.

## Usage

``` r
# S3 method for class 'cd_ratios_summary'
plot(x, ...)
```

## Arguments

- x:

  A `cd_ratios_summary` object created by the `calculate_ratios_summary`
  function. It should contain a `year` column and one or more columns
  with names starting with `"Ratio"`, representing the calculated
  indicator ratios.

- ...:

  Additional arguments passed to other methods (currently unused).

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

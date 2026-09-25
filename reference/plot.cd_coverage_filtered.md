# Plot National Coverage Data

This function generates a line plot to visualize national immunization
coverage data across years, allowing comparison between different
estimates (e.g., DHIS2 estimates, WUENIC estimates, and Survey
estimates).

## Usage

``` r
# S3 method for class 'cd_coverage_filtered'
plot(x, ...)
```

## Arguments

- x:

  A data frame of type `cd_coverage_filtered`, containing year-wise
  national coverage data for the specified country and indicator.

- ...:

  Additional arguments passed to or from other methods (currently
  unused).

## Value

A ggplot object displaying a line plot of the national coverage data by
year, with lines and points representing different estimate types.

## Details

This plot function transforms the coverage data into a long format
suitable for plotting with ggplot2, and extracts the denominator
information for display in the plot caption. It shows coverage values
for each year, with different lines and points for each estimate type.

The plot includes:

- **Y-axis**: Coverage percentage.

- **X-axis**: Year.

- **Line color**: Represents different estimates (e.g., DHIS2, Survey).

- **Caption**: Indicates the denominator used in the coverage
  calculation.

This function is meant to be used with the `cd_coverage_filtered` class,
which contains coverage values for different indicators and estimates.

## Examples

``` r
if (FALSE) { # \dontrun{
  plot(filter_coverage(dt_adj, indicator = "bcg", denominator = "anc1"))
} # }
```

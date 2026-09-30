# Plot Derived vs Traditional Coverage Over Time

This function generates a line plot comparing traditional
(`coverage_old`) and derived (`coverage_new`) coverage estimates over
time for a single indicator. It supports both national and subnational
views.

## Usage

``` r
# S3 method for class 'cd_derived_coverage'
plot(
  x,
  type = c("bar", "trend"),
  title = NULL,
  x_label = NULL,
  y_label = NULL,
  legend_labels = list(),
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_derived_coverage` object.

- type:

  A character string specifying the plot type: `"bar"` or `"trend"`.
  `"trend"` can only be applied nationally or to a specific region.
  Defaults to `"bar"`.

- title:

  (Optional) A scalar character string to override the default plot
  title. Defaults to `NULL`.

- x_label:

  (Optional) A scalar character string to override the default x-axis
  label. Defaults to `NULL`.

- y_label:

  (Optional) A scalar character string to override the default y-axis
  label. Defaults to `NULL`.

- legend_labels:

  (Optional) A named list of character strings to override specific
  default legend labels (e.g., `list(penta1derived = "Custom Penta1")`).

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html));
  other arguments are ignored.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes the user changed. Applied last,
  so it wins over `title` and the other arguments above. Any chart
  option can also be given by name in `...`.

## Value

A `ggplot` object showing coverage trends over time.

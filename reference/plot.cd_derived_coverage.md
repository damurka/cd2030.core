# Plot derived vs traditional coverage over time

Generates a line plot comparing traditional (`coverage_old`) and derived
(`coverage_new`) coverage estimates over time for a single indicator. It
supports both national and subnational views.

## Usage

``` r
# S3 method for class 'cd_derived_coverage'
plot(
  x,
  type = c("bar", "trend"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  legend_labels = list(),
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

  The chart's title.

- subtitle:

  The line under the title.

- caption:

  The note under the chart.

- x_title:

  The title of the horizontal axis.

- y_title:

  The title of the vertical axis.

- legend_title:

  The title of the legend.

- ...:

  Chart options by name (see
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)):
  background, fonts, sizes, axes, grid, legend, colours. Other arguments
  are ignored.

- legend_labels:

  (Optional) A named list of character strings to override specific
  default legend labels (e.g., `list(penta1derived = "Custom Penta1")`).

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object showing coverage trends over time.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$set_national_estimates(list(sbr = 0.02))
cache$adjust_data()
derived <- cache$calculate_derived_coverage("penta3", "national")

plot(derived)

plot(derived, type = "trend", title = "Penta3: usual and derived denominators",
     y_title = "Coverage (%)", legend_position = "bottom")

```

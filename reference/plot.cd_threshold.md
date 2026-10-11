# Plot target threshold attainment over time

Generates a grouped bar chart showing the percentage of administrative
regions that meet specific health coverage or dropout thresholds over
time.

## Usage

``` r
# S3 method for class 'cd_threshold'
plot(
  x,
  x_labels = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  options = NULL
)
```

## Arguments

- x:

  A `cd_threshold` object returned by
  [`calculate_threshold()`](calculate_threshold.md).

- x_labels:

  (Optional) A named list or vector to translate the raw indicator names
  on the x-axis (e.g.,
  `list(penta1 = "Penta 1", dropout_penta13 = "Penta 1-3 Dropout")`).

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

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object displaying a grouped bar chart of threshold
attainment.

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
reached <- cache$get_filtered_threshold("vaccine", "district")

plot(reached)

plot(reached, x_labels = list(bcg = "BCG", penta3 = "Penta 3", measles1 = "Measles 1"),
     title = "Districts reaching the vaccination target", y_title = "Districts (%)", legend_title = "Year")

```

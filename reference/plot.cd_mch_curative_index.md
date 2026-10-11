# Plot S3 method for MCH vs curative index

Draws a scatter plot of the curative services index against the MCH
preventive services index, with one point per admin level 1 unit. Dashed
lines at the two medians split the plot into four labelled quadrants,
and the units with the highest and lowest value of either index are
named.

## Usage

``` r
# S3 method for class 'cd_mch_curative_index'
plot(
  x,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  quad_labels = NULL,
  options = NULL
)
```

## Arguments

- x:

  Object of class cd_mch_curative_index, as returned by
  [`generate_admin1_mch_curative_index()`](generate_admin1_mch_curative_index.md).

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

- quad_labels:

  (Optional) A named list of the texts written in the four quadrants:
  `q_top_left`, `q_top_right`, `q_bottom_left` and `q_bottom_right`.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A `ggplot` object, with the chart options applied.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$adjust_data()
index <- cache$generate_admin1_mch_curative_index()

plot(index)

plot(index, title = "Preventive and curative care", x_title = "Preventive index", y_title = "Curative index",
     quad_labels = list(q_top_right = "High on both", q_bottom_left = "Low on both"))

```

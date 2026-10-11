# Plot national denominators and coverage indicators

Generates specific plots for national denominators and health coverage
indicators. It supports dynamic customization of titles and labels.

## Usage

``` r
# S3 method for class 'cd_indicator_coverage'
plot(
  x,
  plot_type = c("anc_coverage_dhis2", "delivery_coverage_dhis2",
    "immunization_coverage_dhis2", "anc_coverage_un", "delivery_coverage_un",
    "immunization_coverage_un", "anc_coverage_anc1", "delivery_coverage_anc1",
    "immunization_coverage_anc1", "anc_coverage_penta1", "delivery_coverage_penta1",
    "immunization_coverage_penta1"),
  admin_name = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  x_title = NULL,
  y_title = NULL,
  legend_title = NULL,
  ...,
  legend_labels = NULL,
  options = NULL
)
```

## Arguments

- x:

  A `cd_indicator_coverage` object containing the calculated indicators.

- plot_type:

  Character. The specific indicator set to plot. Valid options include:

  - **DHIS2 Denominators**: `"anc_coverage_dhis2"`,
    `"delivery_coverage_dhis2"`, `"immunization_coverage_dhis2"`

  - **UN Denominators**: `"anc_coverage_un"`, `"delivery_coverage_un"`,
    `"immunization_coverage_un"`

  - **ANC1 Derived**: `"anc_coverage_anc1"`, `"delivery_coverage_anc1"`,
    `"immunization_coverage_anc1"`

  - **Penta1 Derived**: `"anc_coverage_penta1"`,
    `"delivery_coverage_penta1"`, `"immunization_coverage_penta1"`

- admin_name:

  Optional character. The specific admin area to filter by (required if
  data is subnational).

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

  Optional character vector. Custom labels for the legend items. Must
  match the number of lines in the selected plot type.

- options:

  A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object or a list of chart options: a look made once, to give to
  several charts. Applied after the text arguments, so a text it holds
  wins over them.

## Value

A ggplot object.

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

plot(cache$indicator_coverage_national, plot_type = "anc_coverage_penta1")

plot(cache$indicator_coverage_national, plot_type = "immunization_coverage_dhis2",
     title = "Immunization coverage, DHIS2 population", y_title = "Coverage (%)", legend_position = "right")


# subnational data: name the unit
plot(cache$indicator_coverage_admin1, plot_type = "immunization_coverage_dhis2", admin_name = "Nairobi")

```

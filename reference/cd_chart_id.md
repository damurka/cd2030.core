# The id of a chart

A stable, readable name for the chart a plot draws, made from the data
it is drawn from: the kind of data, the admin level and the indicator
(`"coverage_filtered.national.anc4"`). The app's customize panel and the
reports build it the same way, so options saved for a chart in the app
(`"report/<id>"`) reach the same chart in a generated report. Ids are
grouped by their parts: everything under `coverage_filtered.national` is
the national coverage charts.

## Usage

``` r
cd_chart_id(x)
```

## Arguments

- x:

  The data a plot method was given.

## Value

A string, or `NULL` when the data does not say what it is.

## Examples

``` r
data <- load_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cd_chart_id(calculate_average_reporting_rate(data))
#> [1] "average_reporting_rate.national"

# plain data does not say what it is
cd_chart_id(mtcars)
#> NULL
```

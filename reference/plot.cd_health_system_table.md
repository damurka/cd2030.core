# Plot S3 method for health system metrics

Draws the national health system metrics as a formatted table. The
indicators are grouped under their section, each with its value and
unit, and the year is shown in a line above the column headers.

## Usage

``` r
# S3 method for class 'cd_health_system_table'
plot(
  x,
  year = 2024,
  width = NULL,
  indicator_label = "Indicator",
  value_label = "Value",
  unit_label = "Unit",
  ...,
  options = NULL
)
```

## Arguments

- x:

  An object of class `cd_health_system_table`, as returned by
  [`generate_health_system_table()`](generate_health_system_table.md).

- year:

  The year to display in the header (defaults to 2024)

- width:

  (Optional) Total width in inches. If NULL, autofit is used.

- indicator_label:

  (Optional) Translated label for the Indicator column header

- value_label:

  (Optional) Translated label for the Value column header

- unit_label:

  (Optional) Translated label for the Unit column header

- ...:

  Additional arguments

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A `flextable` object (from the flextable package), not a ggplot. Chart
options change ggplots only, so `options` has no effect on this table.

## Examples

``` r
cache <- load_cache_data(system.file("extdata", "kenya.xlsx", package = "cd2030.core"))
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$adjust_data()
metrics <- cache$generate_health_system_table()

plot(metrics, year = 2023)


.cl-d8bad469{}.cl-29d09b5c{font-family:'sans';font-size:9pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-e0c7d261{font-family:'sans';font-size:9pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6a6ee646{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-56907d49{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-4f475b07{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:15pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-34cfd99f{width:3.294in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1bea2028{width:0.683in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0a9dc0b8{width:1.049in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 1.25pt solid rgba(107, 114, 128, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0b365658{width:3.294in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-e776cb33{width:0.683in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b97fa500{width:1.049in;background-color:rgba(243, 244, 246, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-35eb73bb{width:3.294in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ad68f899{width:0.683in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4127e72a{width:1.049in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-61060ff0{width:3.294in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1770739a{width:0.683in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-de2de224{width:1.049in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c92f40de{width:3.294in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-882b3aec{width:0.683in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-67542360{width:1.049in;background-color:rgba(232, 238, 244, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(213, 218, 225, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-15519715{width:3.294in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-39c0b8bc{width:0.683in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a13b0276{width:1.049in;background-color:rgba(255, 255, 255, 1.00);vertical-align: middle;border-bottom: 1.25pt solid rgba(107, 114, 128, 1.00);border-top: 0.75pt solid rgba(213, 218, 225, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


2023
```

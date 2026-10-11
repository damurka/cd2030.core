# Which adjustment steps an indicator gets

Whether completeness (a k above 0), outlier correction and filling
missing values apply to an indicator in at least one district of the
data (or of one area), with the settings: a step no district gets is
off.

## Usage

``` r
adjustment_steps_used(
  settings,
  .data,
  indicator,
  area = NULL,
  level = c("adminlevel_1", "district")
)
```

## Arguments

- settings:

  The settings list.

- .data:

  A `cd_data` tibble (its districts and regions).

- indicator:

  The indicator.

- area, level:

  One area only (as
  [`generate_adjustment_values()`](generate_adjustment_values.md));
  `NULL`, all.

## Value

A named logical: `completeness`, `outliers`, `missing`.

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths,
#>   ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
settings <- adjustment_settings_default()
adjustment_steps_used(settings, data, "penta3")
#> completeness     outliers      missing 
#>         TRUE         TRUE         TRUE 

# A region with its own settings: no completeness adjustment, outliers left as they are
settings$areas <- list(
  list(area = "Coast", level = "adminlevel_1", group_k = list(vacc = 0), all_outliers = FALSE)
)
adjustment_steps_used(settings, data, "penta3", area = "Coast")
#> completeness     outliers      missing 
#>        FALSE        FALSE         TRUE 
adjustment_steps_used(settings, data, "penta3")
#> completeness     outliers      missing 
#>         TRUE         TRUE         TRUE 
```

# Plot National Denominators and Coverage Indicators

Generates specific plots for national denominators and health coverage
indicators based on the calculated denominators in the
`cd_indicator_coverage` object.

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
  ...
)
```

## Arguments

- x:

  A `cd_indicator_coverage` object containing the calculated indicators.

- plot_type:

  Character. Type of plot to generate. Options include:

  - `"population_dhis2"`: Population estimates from DHIS-2 data

  - `"births_dhis2"`: Live birth estimates from DHIS-2

  - `"population_un"`: Population estimates from UN data

  - `"births_un"`: Live birth estimates from UN

  - `"anc_coverage"`: ANC coverage indicators

  - `"immunization_coverage_dhis2"`: DHIS-2 based immunization coverage
    indicators

  - `"immunization_coverage_un"`: UN-based immunization coverage

  - `"immunization_coverage_anc1"`: ANC-1 based immunization coverage

- admin_name:

  Name of the area to plot

- ...:

  Additional arguments (currently not used).

## Value

A ggplot object for the selected plot type.

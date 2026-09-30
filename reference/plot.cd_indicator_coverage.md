# Plot National Denominators and Coverage Indicators

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
  x_label = NULL,
  y_label = NULL,
  legend_labels = NULL,
  ...,
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

  Optional character. Custom plot title.

- x_label:

  Optional character. Custom x-axis label (default "Year").

- y_label:

  Optional character. Custom y-axis label (default "%").

- legend_labels:

  Optional character vector. Custom labels for the legend items. Must
  match the number of lines in the selected plot type.

- ...:

  Additional arguments passed to the plotting function.

- options:

  (Optional) A
  [`cd_chart_options()`](https://rdrr.io/pkg/datasuite.ui/man/cd_chart_options.html)
  object: text, legend, fonts and sizes a user changed. Applied last, so
  it wins over the arguments above; the plot's own defaults are used for
  whatever it does not set. Any chart option can also be given by name
  in `...`.

## Value

A ggplot object.

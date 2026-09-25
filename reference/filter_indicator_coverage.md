# Filter Indicator Coverage for Plotting

Prepares a long-form data frame of coverage values across denominator
sources for a specific indicator and year, including a user-defined
national survey coverage value.

## Usage

``` r
filter_indicator_coverage(.data, indicator, survey_coverage = 88)
```

## Arguments

- .data:

  A `cd_indicator_coverage` object.

- indicator:

  A string. The target health indicator (e.g., `"penta3"`, `"bcg"`).

- survey_coverage:

  A scalar numeric. The national survey coverage to include as a
  reference. Default is `88`.

## Value

A `tibble` of class `'cd_indicator_coverage_filtered'`, enriched with
attributes for plotting.

## Details

The function reshapes wide coverage data into long format, classifies
each column by denominator type, and extracts the indicator name. It
selects only data for the most recent available year.

## See also

[`plot.cd_indicator_coverage_filtered()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/plot.cd_indicator_coverage_filtered.md)

## Examples

``` r
if (FALSE) { # \dontrun{
filtered <- filter_indicator_coverage(df, indicator = "penta3", survey_coverage = 90)
plot(filtered)
} # }
```

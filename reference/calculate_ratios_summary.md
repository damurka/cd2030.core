# Calculate Yearly Indicator Ratios Summary with Expected Ratios

This function computes yearly summaries for specified indicator ratios,
assessing trends across years and providing both actual and expected
ratios for each indicator. It evaluates specified indicator pairs to
calculate ratios and compares actual values with expected ratios, based
on predefined survey coverage values. The summary facilitates monitoring
consistency of key health indicators over time.

## Usage

``` r
calculate_ratios_summary(
  .data,
  survey_coverage = c(anc1 = 0.98, penta1 = 0.97, penta3 = 0.89, opv1 = 0.97, opv3 =
    0.78, pcv1 = 0.97, rota1 = 0.96),
  anc1_penta1_mortality = 1.07,
  ratio_pairs = list(ratioAP = c("anc1", "penta1"), ratioPP = c("penta1", "penta3")),
  adequate_range = c(1, 1.5),
  region = NULL
)
```

## Arguments

- .data:

  A data frame containing yearly data for specified indicators. Expected
  columns include `district`, `year`, and additional numeric columns for
  health indicators, such as `anc1` and `penta1`.

- survey_coverage:

  A named vector of assumed coverage rates for each indicator. Default
  is
  `c(anc1 = 0.98, penta1 = 0.97, penta3 = 0.89, opv1 = 0.97, opv3 = 0.78, pcv1 = 0.97, rota1 = 0.96)`.

- anc1_penta1_mortality:

  A numeric multiplier applied specifically to the `"ratioAP"` ratio of
  `anc1` to `penta1`, to account for assumed mortality between `anc1`
  and `penta1`. Default is `1.07`.

- ratio_pairs:

  A named list specifying indicator pairs for which ratios should be
  calculated. Format:
  `list("ratioName" = c("numerator", "denominator"))`. Default pairs
  include:

  - `"ratioAP"`: Ratio of `anc1` to `penta1`, adjusted with
    `anc1_penta1_mortality`.

  - `"ratioPP"`: Ratio of `penta1` to `penta3`.

  - `"ratioOO"`: Ratio of `opv1` to `opv3`.

  - `"ratioPPcv"`: Ratio of `penta1` to `pcv1`.

  - `"ratioPR"`: Ratio of `penta1` to `rota1`.

- adequate_range:

  A numeric vector of length 2 defining the acceptable range for
  adequacy checks. Ratios within this range are marked adequate; outside
  this range, inadequate. Default is `c(1, 1.5)`.

- region:

  Optional. Restrict analysis to one region (`adminlevel_1`).

## Value

A `cd_ratios_summary` object, a data frame containing:

- **`year`**: Year of each calculated ratio, with an additional row
  `"Expected Ratio"` to represent expected values for each indicator
  ratio based on `survey_coverage`.

- **Indicator Ratios**: Columns for each ratio, showing actual yearly
  values and an expected value row based on `survey_coverage`.

- **Additional Columns**: Health indicator values for each year.

## Details

The function provides insights into indicator relationships over time
and evaluates deviations from expected values. It enables data quality
checks and trend analysis by summarizing ratios yearly and including
expected values for comparison. The `"Expected Ratio"` row incorporates
predefined survey coverage and serves as a reference for assessing the
adequacy of each indicator's ratio.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Basic usage with default parameters
  calculate_ratios_summary(cd_data)

  # Custom survey coverage and mortality adjustments for "ratioAP"
  calculate_ratios_summary(cd_data,
    survey_coverage = c(anc1 = 0.95, penta1 = 0.92, penta3 = 0.85),
    anc1_penta1_mortality = 1.05
  )
} # }
```

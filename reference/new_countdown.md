# Create Countdown 2030 Data Object

The `new_countdown` function converts cleaned and processed data into a
tibble of class `cd_data`, with additional validation and metadata for
analysis within the Countdown 2030 framework.

## Usage

``` r
new_countdown(.data, class = NULL, call = caller_env())
```

## Arguments

- .data:

  A tibble. The cleaned and processed data to be converted to `cd_data`
  class.

- class:

  Optional. A character vector specifying additional classes to assign
  to the resulting tibble.

- call:

  The calling environment. Defaults to `caller_env()`.

## Value

A tibble of class `cd_data`, containing an `indicator_groups` attribute
that includes validated indicator groups available in the dataset,
categorized for analysis.

## Details

This function attaches metadata to the data for available indicator
groups by validating each group against the column names in the provided
tibble. Indicator groups represent categories of data relevant to
Countdown 2030 analysis:

- **`anc`**: Antenatal care indicators (e.g., `anc1`)

- **`idelv`**: Delivery and birth outcome indicators (e.g., `ideliv`,
  `instlivebirths`)

- **`vacc`**: Vaccination indicators (e.g., `opv1`, `penta1`,
  `measles1`)

Additionally, `tracers` are specified to track core indicators, such as
vaccination rates, within `cd_data`.

Any required columns missing from the input data will trigger an error,
with a message indicating which columns are missing.

## See also

[`adjust_service_data()`](https://aphrcwaro.github.io/cd2030.rmncah/reference/adjust_service_data.md)
for adjusting service data within the `cd_data` object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Convert processed data to `cd_data` class for Countdown 2030 analysis
cd_data <- new_countdown(final_data)
} # }
```

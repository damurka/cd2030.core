# Identify Monthly Outliers for a Single Indicator

Flags extreme monthly values for a given immunization indicator using
the Hampel method.

## Usage

``` r
list_outlier_units(
  .data,
  indicator,
  admin_level = c("adminlevel_1", "district"),
  region = NULL
)
```

## Arguments

- .data:

  A `cd_data` object with monthly data.

- indicator:

  A single indicator name to assess.

- admin_level:

  `'adminlevel_1'` or `'district'`.

- region:

  Optional. Filter results to a specific `adminlevel_1`.

## Value

A `cd_outlier_list` tibble with:

- Grouping columns

- Raw values for `indicator`

- Median (`<indicator>_med`)

- MAD (`<indicator>_mad`)

- Outlier flag (`<indicator>_outlier5std`)

## Details

- Aggregates by `year`, `month`, and administrative unit.

- Computes median and MAD (Median Absolute Deviation).

- Flags outliers when values are ±5×MAD from median.

## Examples

``` r
if (FALSE) { # \dontrun{
list_outlier_units(cd_data, indicator = 'penta1', admin_level = 'district')
} # }
```

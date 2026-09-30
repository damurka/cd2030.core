# Identify Monthly Outliers by District

Flags extreme monthly values for every indicator at district level using
the Hampel method.

## Usage

``` r
list_outlier_units(.data)
```

## Arguments

- .data:

  A `cd_data` object with monthly data.

## Value

A `cd_outlier_list` tibble with:

- Grouping columns

- Raw values for each indicator

- Median (`<indicator>_med`)

- MAD (`<indicator>_mad`)

- Outlier flag (`<indicator>_outlier5std`)

## Details

- Aggregates by `year`, `month`, and district.

- Computes median and MAD (Median Absolute Deviation).

- Flags outliers when values are more than 5 MAD from the median.

## Examples

``` r
if (FALSE) { # \dontrun{
list_outlier_units(cd_data)
} # }
```

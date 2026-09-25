# Summary for `cd_adjustment_values` Objects

Provides a custom summary for objects of class `cd_adjustment_values`,
typically displaying unadjusted and adjusted values in a structured
format.

## Usage

``` r
# S3 method for class 'cd_adjustment_values'
tbl_sum(x, ...)
```

## Arguments

- x:

  An object of class `cd_adjustment_values`, usually created by
  `generate_adjustment_values`, containing unadjusted and adjusted
  service counts.

- ...:

  Additional arguments passed to or from other methods.

## Value

A character vector with a custom table summary for
`cd_adjustment_values` objects.

## Details

This function overrides the default `tbl_sum` method for objects of
class `cd_adjustment_values`. It returns a named character vector
summarizing the table as "Unadjusted and adjusted values" along with any
additional details provided by the
[`NextMethod()`](https://rdrr.io/r/base/UseMethod.html) function.

## See also

[`generate_adjustment_values()`](https://aphrcwaro.github.io/cd2030.core/reference/generate_adjustment_values.md)
for generating the `cd_adjustment_values` object.

# Robust Maximum Value Calculation

`robust_max` calculates the maximum value of a numeric vector while
handling missing values. If all values in the vector are `NA`, the
function returns `NA` instead of raising an error.

## Usage

``` r
robust_max(x, fallback = NA)
```

## Arguments

- x:

  A numeric vector.

- fallback:

  argument allows you to specify a value to return when all elements are
  NA

## Value

The maximum value of `x`, or `NA` if all values are `NA`.

## Examples

``` r
# Example usage
robust_max(c(1, 2, 3, NA)) # Returns 3
#> [1] 3
robust_max(c(NA, NA)) # Returns NA
#> [1] NA
robust_max(c(-Inf, 0, 10)) # Returns 10
#> [1] 10
```

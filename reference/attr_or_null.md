# Retrieve Attribute or Return NULL if Missing

A safe variant of [`attr_or_abort()`](attr_or_abort.md) that returns
`NULL` instead of throwing an error when the specified attribute does
not exist.

## Usage

``` r
attr_or_null(.data, attr_name)
```

## Arguments

- .data:

  An object to inspect.

- attr_name:

  A string. The name of the attribute to retrieve.

## Value

The value of the specified attribute, or `NULL` if not present.

## Examples

``` r
obj <- structure(list(a = 1), my_attr = "value")
cd2030.core:::attr_or_null(obj, "my_attr")
#> [1] "value"
#> "value"

cd2030.core:::attr_or_null(obj, "missing")
#> NULL
#> NULL
```

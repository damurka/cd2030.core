# Retrieve an Attribute or Abort with Error

Safely retrieves a named attribute from an object. If the attribute is
missing, raises an error with a clear message. Intended for internal use
to enforce required metadata on structured objects.

## Usage

``` r
attr_or_abort(.data, attr_name)
```

## Arguments

- .data:

  An object to inspect.

- attr_name:

  A string. The name of the attribute to retrieve.

## Value

The value of the specified attribute.

## Examples

``` r
obj <- structure(list(a = 1), attr = list(my_attr = "value"))
attr_or_abort(obj, "my_attr")
#> Error in attr_or_abort(obj, "my_attr"): could not find function "attr_or_abort"
#> "value"

# attr_or_abort(obj, "missing") would throw an error
```

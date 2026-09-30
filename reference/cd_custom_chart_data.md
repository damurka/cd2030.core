# The table a custom chart draws

The table a custom chart draws

## Usage

``` r
cd_custom_chart_data(cache, spec)
```

## Arguments

- cache:

  A `CacheConnection`.

- spec:

  A custom chart description (report kind `custom_chart`, see
  [`datasuite.ui::report_validate_spec()`](https://rdrr.io/pkg/datasuite.ui/man/report_validate_spec.html)).

## Value

The data frame after the spec's transforms.

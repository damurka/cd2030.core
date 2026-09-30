# The report context of a dataset

What the report builder (datasuite.ui) needs from a Countdown dataset:
its charts and tables drawn in the report's look, the pictures and
templates kept in it, its saved chart options, its fields (country,
coverage values), years, regions and flag. Every report function accepts
the dataset itself too
([`datasuite.ui::as_report_context()`](https://rdrr.io/pkg/datasuite.ui/man/as_report_context.html)).

## Usage

``` r
cd_report_context(cache)
```

## Arguments

- cache:

  A [CacheConnection](CacheConnection.md).

## Value

A report context
([`datasuite.ui::report_context()`](https://rdrr.io/pkg/datasuite.ui/man/report_context.html)).

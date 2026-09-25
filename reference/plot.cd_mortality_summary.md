# Plot Mortality Rate Indicators

Produces line plots for national mortality indicators with regional
points for comparison.

## Usage

``` r
# S3 method for class 'cd_mortality_summary'
plot(x, indicator = c("mmr_inst", "ratio_md_sb", "sbr_inst", "nn_inst"), ...)
```

## Arguments

- x:

  A `cd_mortality_summary` object.

- indicator:

  One of `"mmr_inst"`, `"ratio_md_sb"`, `"sbr_inst"`, or `"nn_inst"`.

- ...:

  Additional arguments passed to methods.

## Value

A ggplot object.

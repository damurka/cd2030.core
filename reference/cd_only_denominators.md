# Keep only the denominators this app offers

Filters a named list or vector, such as a chart's legend labels or
category labels, down to the entries named after a denominator the app
offers. Labels are usually written for every denominator, and one the
app does not offer must not appear in a chart.

## Usage

``` r
cd_only_denominators(x)
```

## Arguments

- x:

  A list or vector named by denominator id.

## Value

`x` without the entries whose name is neither `"un"` (the UN projection,
always kept) nor one of the ids in
[`cd_denominator_options()`](cd_denominator_options.md). The order and
the type of `x` are kept.

## Examples

``` r
labels <- c(un = "UN projection", dhis2 = "DHIS2 projection", other = "Not a denominator")
cd_only_denominators(labels)
#>                 un              dhis2 
#>    "UN projection" "DHIS2 projection" 
```

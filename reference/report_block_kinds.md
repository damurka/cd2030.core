# The charts and tables a report can contain

What each kind draws and which settings it takes. The builder offers
these;
[`render_report_block()`](https://rdrr.io/pkg/datasuite.ui/man/render_report_block.html)
draws them.

## Usage

``` r
report_block_kinds(group = get_selected_group())
```

## Arguments

- group:

  The indicator group; kinds that only make sense for one group
  (`groups`) are left out of the other.

## Value

A named list; each entry has `type` (`"chart"` or `"table"`), `group`,
`label`, `indicators` (`"analysis"`, a character vector, or `NULL` when
the kind has no indicator), `levels`, `variants` (named character vector
or `NULL`), `year` (whether a year is chosen), `regional` (whether it is
drawn for one region) and `groups` (the indicator groups it is for).

## Details

The kinds are listed in the order of the analysis (their `group`: data
quality, adjustment, denominators, national, sub-national, region,
mortality, service utilization, health system). The standard report
files add their own kinds (see the top of the standard reports section).

## Examples

``` r
kinds <- report_block_kinds("rmncah")
head(names(kinds))
#> [1] "reporting_rate"        "overall_score"         "consistency"          
#> [4] "dq_ratios"             "dq_reporting_units"    "dq_completeness_units"
str(kinds$reporting_rate)
#> List of 10
#>  $ type      : chr "chart"
#>  $ group     : chr "quality"
#>  $ label     : chr "Reporting rate by district"
#>  $ indicators: NULL
#>  $ levels    : NULL
#>  $ variants  : NULL
#>  $ year      : logi FALSE
#>  $ regional  : logi TRUE
#>  $ groups    : chr [1:2] "rmncah" "vaccine"
#>  $ tall      : logi TRUE

# the kinds the vaccine group does not have
setdiff(names(kinds), names(report_block_kinds("vaccine")))
#>  [1] "continuum"               "continuum_gap"          
#>  [3] "bayes_coverage"          "natcov_fpet"            
#>  [5] "natcov_continuum_region" "continuum_units"        
#>  [7] "mortality_trend"         "mortality_region"       
#>  [9] "mortality_plausibility"  "mortality_ratio"        
#> [11] "mort_nn_trend"           "service_utilization"    
#> [13] "mch_index"               "su_region"              
#> [15] "su_dqa"                  "su_map"                 
#> [17] "health_system_table"     "health_system_region"   
#> [19] "phc_scatter"             "hs_comparison"          
#> [21] "hs_national"             "private_share"          
#> [23] "ps_ownership"           
```

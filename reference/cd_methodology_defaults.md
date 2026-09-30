# The Constants of the Countdown Methodology

Lists the constants the package's methodology uses (cutoffs, thresholds,
default rates and targets) with the values the code runs with, so the
documentation can be generated from them.

## Usage

``` r
cd_methodology_defaults(group = c("all", "rmncah", "vaccine"))
```

## Arguments

- group:

  Which entries to return: `"all"` (the default), or those that apply to
  the `"rmncah"` or the `"vaccine"` indicator group (entries for
  `"both"` are included in each).

## Value

A tibble with one row per constant and the columns:

- `id`: a stable snake_case identifier.

- `step`: one of `"data_quality"`, `"adjustment"`, `"denominators"`,
  `"coverage"`, `"subnational"`, `"mortality"`.

- `group`: `"both"`, `"rmncah"` or `"vaccine"`.

- `value`: a list column; each element is a number, a string or a
  vector.

- `unit`: for example `"%"`, `"x MAD"`, `"ratio"`, `"proportion"`, or
  `""`.

- `label`: a short English label.

- `note`: one English sentence on how the app uses it.

- `source`: the file of the package (within `R/`) that uses it.

## Examples

``` r
cd_methodology_defaults()
#> # A tibble: 41 × 8
#>    id                                step   group value unit  label note  source
#>    <chr>                             <chr>  <chr> <lis> <chr> <chr> <chr> <chr> 
#>  1 dq_reporting_threshold            data_… both  <dbl> "%"   Dist… Scor… R/1a_…
#>  2 dq_reporting_threshold_picks      data_… both  <dbl> "%"   Repo… The … R/ui-…
#>  3 dq_outlier_mad_multiplier         data_… both  <dbl> "x M… Extr… A mo… R/uti…
#>  4 dq_outlier_baseline               data_… both  <chr> ""    Outl… The … R/uti…
#>  5 dq_ratio_adequate_range           data_… both  <dbl> "rat… Adeq… A di… R/1a_…
#>  6 dq_ratio_pairs                    data_… both  <chr> ""    Cons… The … R/uti…
#>  7 dq_ratio_pairs_vaccine            data_… vacc… <chr> ""    Cons… The … R/uti…
#>  8 dq_ratio_anc1_penta1_mortality    data_… both  <dbl> "rat… ANC1… The … R/1a_…
#>  9 dq_ratio_expected_coverage_anc1   data_… both  <dbl> "pro… Assu… When… R/1a_…
#> 10 dq_ratio_expected_coverage_penta1 data_… both  <dbl> "pro… Assu… When… R/1a_…
#> # ℹ 31 more rows
cd_methodology_defaults("vaccine")
#> # A tibble: 35 × 8
#>    id                                step   group value unit  label note  source
#>    <chr>                             <chr>  <chr> <lis> <chr> <chr> <chr> <chr> 
#>  1 dq_reporting_threshold            data_… both  <dbl> "%"   Dist… Scor… R/1a_…
#>  2 dq_reporting_threshold_picks      data_… both  <dbl> "%"   Repo… The … R/ui-…
#>  3 dq_outlier_mad_multiplier         data_… both  <dbl> "x M… Extr… A mo… R/uti…
#>  4 dq_outlier_baseline               data_… both  <chr> ""    Outl… The … R/uti…
#>  5 dq_ratio_adequate_range           data_… both  <dbl> "rat… Adeq… A di… R/1a_…
#>  6 dq_ratio_pairs                    data_… both  <chr> ""    Cons… The … R/uti…
#>  7 dq_ratio_pairs_vaccine            data_… vacc… <chr> ""    Cons… The … R/uti…
#>  8 dq_ratio_anc1_penta1_mortality    data_… both  <dbl> "rat… ANC1… The … R/1a_…
#>  9 dq_ratio_expected_coverage_anc1   data_… both  <dbl> "pro… Assu… When… R/1a_…
#> 10 dq_ratio_expected_coverage_penta1 data_… both  <dbl> "pro… Assu… When… R/1a_…
#> # ℹ 25 more rows
```

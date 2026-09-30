# The data dictionary: what the ids and column names in the package's data mean

The package names its data from a few parts: an indicator (`penta1`), a
denominator option (`anc1derived`), a target population (`totinftpenta`)
and prefixes such as `cov_` (coverage) or `r_` (survey estimate). This
is what each part means, and how they combine. Read meanings from here,
not from the spelling: `anc1` and `penta1` are the **ANC1-derived** and
**Penta1-derived** denominators, while `anc1derived` and `penta1derived`
are the **population growth** ones.

## Usage

``` r
cd_dictionary()
```

## Value

A list of data frames: `denominators` (id, label, meaning, levels, key –
the label's translation key), `indicators` (id, label, group, computed),
`populations` (id, label, meaning, unit), `reporting_rates` (id,
meaning), `columns` (fixed column names: id, meaning) and `grammar`
(pattern, meaning, example).

## See also

[`cd_describe_columns()`](cd_describe_columns.md) to read column names
with it.

## Examples

``` r
cd_dictionary()$denominators[, c("id", "label")]
#>              id                    label
#> 1            un           UN projections
#> 2         dhis2        DHIS2 projections
#> 3          anc1             ANC1-derived
#> 4        penta1           Penta1-derived
#> 5   anc1derived   ANC1 population growth
#> 6 penta1derived Penta1 population growth
```

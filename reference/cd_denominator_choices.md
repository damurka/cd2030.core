# The standard denominator choices

Every denominator the denominator chip can offer, in the form a filter
chip takes them. This is the full set, which the RMNCAH app uses. An app
with fewer denominators sets its own (see
[`cd_denominator_options()`](cd_denominator_options.md)).

## Usage

``` r
cd_denominator_choices
```

## Format

A named character vector of length 5. The values are the denominator ids
and the names are the translation keys of their labels:

- `"dhis2"`: the DHIS2 population projection.

- `"anc1"` and `"penta1"`: the denominators derived from ANC1 and from
  Penta1.

- `"penta1derived"` and `"anc1derived"`: the growth-projected
  denominators (Penta1 and ANC1 population growth).

## Examples

``` r
cd_denominator_choices
#>     lbl_denom_dhis2_proj   lbl_denom_anc1_derived lbl_denom_penta1_derived 
#>                  "dhis2"                   "anc1"                 "penta1" 
#>  lbl_denom_penta1_growth    lbl_denom_anc1_growth 
#>          "penta1derived"            "anc1derived" 
```

# The denominator options' labels

The denominator options' labels

## Usage

``` r
cd_denominator_labels(i18n = NULL, ids = .cd_dict_denominators$id)
```

## Arguments

- i18n:

  Optional translator (`i18n$t(key)`); without it, the English labels.

- ids:

  Which denominators, in this order. Default: all six.

## Value

A named character vector, id -\> label.

## Examples

``` r
cd_denominator_labels()
#>                         un                      dhis2 
#>           "UN projections"        "DHIS2 projections" 
#>                       anc1                     penta1 
#>             "ANC1-derived"           "Penta1-derived" 
#>                anc1derived              penta1derived 
#>   "ANC1 population growth" "Penta1 population growth" 
```

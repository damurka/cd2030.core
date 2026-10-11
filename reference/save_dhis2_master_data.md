# Create a master dataset from DHIS2 data

Combines the service, completeness, population and admin data downloaded
from DHIS2 into one Countdown dataset, with a row per district, year and
month and a column per data element.

## Usage

``` r
save_dhis2_master_data(.data)
```

## Arguments

- .data:

  A list containing the structured DHIS2 data, including `admin`,
  `population`, `completeness`, and `service` datasets.

## Value

A tibble of class `cd_data` holding the combined and standardized DHIS2
dataset.

## Details

Pivots the service, completeness and population data to a wide format
and merges them on their common keys (`district`, `year` and, where
present, `month`), then adds the admin data by `district`. The merged
data is standardized and made into a `cd_data` object, which checks that
the required columns are present.

## Examples

``` r
if (FALSE) { # \dontrun{
master_dataset <- save_dhis2_master_data(data)
} # }
```

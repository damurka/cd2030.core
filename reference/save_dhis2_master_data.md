# Create a Master Dataset from DHIS2 Data

Create a Master Dataset from DHIS2 Data

## Usage

``` r
save_dhis2_master_data(.data)
```

## Arguments

- .data:

  A list containing the structured DHIS2 data, including `admin`,
  `population`, `completeness`, and `service` datasets.

## Value

A data frame representing the combined and cleaned DHIS2 dataset.

## Details

This function combines all DHIS2 data types into a single dataset. It
pivots data to a wide format, merges datasets on common keys, and
ensures completeness by filtering out rows with missing values in
critical columns. The final dataset is standardized for consistency and
usability.

## Examples

``` r
if (FALSE) { # \dontrun{
master_dataset <- create_master_dataset(data)
} # }
```

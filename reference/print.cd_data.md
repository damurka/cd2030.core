# Print Method for `cd_data` Class

This function provides a custom print method for objects of class
`cd_data`, displaying a summary of the dataset, including data
dimensions, available years, regions, variable groups, and any quality
metrics associated with the data. It uses the `cli` package for
enhanced, styled output.

## Usage

``` r
# S3 method for class 'cd_data'
print(x, ...)
```

## Arguments

- x:

  An object of class `cd_data`, which contains `merged_data` (a
  dataframe with demographic data) and optional `quality_metrics` (a
  dataframe or list of quality metrics).

- ...:

  Additional arguments (currently not used).

## Value

Invisibly returns `x`. This function is called for its side effect of
printing a formatted summary of the `cd_data` object.

## Details

This print method provides the following summary sections:

1.  **Data Summary**: Shows the number of observations and variables in
    `merged_data`.

2.  **Years Available**: Lists unique years present in `merged_data`.

3.  **Regions Available**: Lists unique regions in the `adminlevel_1`
    column.

4.  **Variable Groups**: Displays predefined groups of variables,
    including ANC, delivery, vaccination, PNC, OPD, and IPD groups.

5.  **Quality Metrics**: If present, prints `quality_metrics` for
    additional data insights.

## Variable Groups

- `ancvargroup`: Variables related to antenatal care.

- `idelvvargroup`: Variables related to delivery.

- `vaccvargroup`: Variables related to vaccinations.

- `pncvargroup`: Variables related to postnatal care.

- `opdvargroup`: Variables related to outpatient care.

- `ipdvargroup`: Variables related to inpatient care.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming `cd_data_obj` is an object of class `cd_data`:
print(cd_data_obj)
} # }
```

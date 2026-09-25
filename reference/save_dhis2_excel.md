# Save DHIS2 Data to an Excel Workbook

Save DHIS2 Data to an Excel Workbook

## Usage

``` r
save_dhis2_excel(.data, filename, last_org)
```

## Arguments

- .data:

  A list containing the structured DHIS2 data, including `admin`,
  `population`, `completeness`, and `service` datasets.

- filename:

  A string specifying the file path and name where the Excel workbook
  will be saved.

## Value

Saves the workbook to the specified filename.

## Details

This function generates an Excel workbook containing multiple sheets for
different types of DHIS2 data:

- **Admin Data**: Maps health districts to administrative units.

- **Population Data**: Contains official population data for
  denominators in health reporting.

- **Completeness Data**: Tracks reporting completeness metrics.

- **Service Data**: Records service delivery numbers.

Each sheet is styled, with column headers, instructions, and frozen
panes. Instructions are added to guide users on how to input or
interpret data.

## Examples

``` r
if (FALSE) { # \dontrun{
save_dhis2_excel(data, "dhis2_data.xlsx")
} # }
```

# Load and Clean Countdown 2030 Excel Data

`load_excel_data` reads specified sheets from an Excel file, cleans the
data, and outputs a tibble of class `cd_data`.

## Usage

``` r
load_excel_data(
  path,
  start_year = NULL,
  admin_sheet_name = "Admin_data",
  population_sheet_name = "Population_data",
  reporting_sheet_name = "Reporting_completeness",
  service_sheet_names = c("Service_data_1", "Service_data_2")
)
```

## Arguments

- path:

  A string. The path to the Excel file to be loaded.

- start_year:

  An integer. The minimum year to filter the data (default is NULL).

- admin_sheet_name:

  A string. The name of the sheet containing administrative data.
  Default is `"Admin_data"`.

- population_sheet_name:

  A string. The name of the sheet containing population data. Default is
  `"Population_data"`.

- reporting_sheet_name:

  A string. The name of the sheet containing reporting completeness
  data. Default is `"Reporting_completeness"`.

- service_sheet_names:

  A vector of strings. The names of the sheets containing service data.
  Default is `c("Service_data_1", "Service_data_2")`.

## Value

A tibble of class `cd_data`, containing cleaned and processed data.

## Details

This function is designed to handle Countdown 2030 data sheets by
ensuring each sheet is properly loaded, standardized, and merged into a
single tibble. It performs checks for duplicates, cleans up formatting
issues, and verifies the presence of expected columns.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load and clean data from a Countdown 2030 Excel file
data <- load_excel_data("countdown2030_data.xlsx")
} # }
```

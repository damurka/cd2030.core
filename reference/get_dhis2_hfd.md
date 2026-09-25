# Retrieve DHIS2 Health Facility Data

`get_dhis2_hfd` retrieves health facility data (HFD) from the DHIS2 API
for a specific country and date range. It collects completeness,
service, population, and administrative data.

`get_dhis2_hfd` retrieves health facility data (HFD) from the DHIS2 API
for a specific country and date range. It collects completeness,
service, population, and administrative data.

## Usage

``` r
get_dhis2_hfd(country_iso3, start_date, end_date, level = 3, timeout = 3600)

get_dhis2_hfd(country_iso3, start_date, end_date, level = 3, timeout = 3600)
```

## Arguments

- country_iso3:

  Character. ISO3 code of the country.

- start_date:

  Character. Start date in "YYYY-MM-DD" format.

- end_date:

  Character. End date in "YYYY-MM-DD" format.

- timeout:

  Numeric. Timeout for API calls in seconds. Default is 60.

## Value

A list of class `cd_dhis2_hfd` containing:

- **`completeness`**: Data frame of completeness data.

- **`service`**: Data frame of service data.

- **`population`**: Data frame of population data.

- **`admin`**: Data frame of administrative data.

A list of class `cd_dhis2_hfd` containing:

- **`completeness`**: Data frame of completeness data.

- **`service`**: Data frame of service data.

- **`population`**: Data frame of population data.

- **`admin`**: Data frame of administrative data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve data for Kenya from January 1, 2020, to January 1, 2024
hfd_data <- get_dhis2_hfd("KEN", "2020-01-01", "2024-01-01")
} # }

if (FALSE) { # \dontrun{
# Retrieve data for Kenya from January 1, 2020, to January 1, 2024
hfd_data <- get_dhis2_hfd("KEN", "2020-01-01", "2024-01-01")
} # }
```

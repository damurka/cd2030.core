# Load FPET Data from CSV File or Use Provided Data

`load_fpet_data` loads Family Planning Estimation Tool (FPET) data from
a `.csv` file, or uses a pre-supplied dataset. It assigns a country ISO
code if specified, and returns a tibble with a custom class
`cd_fpet_data`.

## Usage

``` r
load_fpet_data(path = NULL, .data = NULL, country_iso = NULL)
```

## Arguments

- path:

  Optional `character`. File path to a `.csv` file. If provided, data is
  read from the file.

- .data:

  Optional `data.frame` or `tibble`. Used directly if provided instead
  of loading from file.

- country_iso:

  Optional `character`. ISO3 country code. Used to tag or filter the
  dataset.

## Value

A tibble with class `cd_fpet_data`. If `country_iso` is provided, the
data is filtered by `iso3 == country_iso`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load FPET data from file
fpet <- load_fpet_data(path = "path/to/fpet.csv", country_iso = "NGA")

# Use existing data
fpet <- load_fpet_data(.data = some_fpet_data, country_iso = "ETH")
} # }
```

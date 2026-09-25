# Load Processed Countdown 2030 Data from RDS or DTA File

`load_data` loads processed Countdown 2030 data from a specified file,
either in RDS or DTA format, and returns a tibble of class `cd_data`.

## Usage

``` r
load_data(path)
```

## Arguments

- path:

  A string. The path to the file containing the processed data in either
  RDS or DTA format.

## Value

A tibble of class `cd_data` containing the loaded data.

## Details

This function first checks the file extension to determine the format,
then reads the data accordingly. It supports both RDS and Stata (DTA)
file formats commonly used for saving processed datasets.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load previously processed data from an RDS or DTA file
data <- load_data("processed_cd2030_data.rds")
data <- load_data("processed_cd2030_data.dta")
} # }
```

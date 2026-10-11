# Read and clean the sheets of a Countdown 2030 workbook

Reads and cleans each sheet of a Countdown 2030 Excel workbook and
returns the sheets separately, without merging them. Use it to run data
quality checks on each sheet before the merge, then pass the result to
[`merge_and_standardize()`](merge_and_standardize.md) to finish loading.

## Usage

``` r
load_excel_parts(
  path,
  start_year = NULL,
  admin_sheet_name = NULL,
  population_sheet_name = NULL,
  reporting_sheet_name = NULL,
  service_sheet_names = NULL
)
```

## Arguments

- path:

  Path to an `.xlsx` or `.xls` file.

- start_year:

  Optional integer filter for minimum year.

- admin_sheet_name:

  Excel sheet with admin data. Default `"Admin_data"`.

- population_sheet_name:

  Excel sheet with population data. Default `"Population_data"`.

- reporting_sheet_name:

  Excel sheet with reporting completeness. Default
  `"Reporting_completeness"`.

- service_sheet_names:

  Character vector of service-data sheets. Default: all sheets matching
  `"Service_data"` if not supplied.

## Value

A list with these elements:

- `parts`: a named list of cleaned tibbles, one per sheet, named by
  sheet.

- `sheet_names`: a character vector of the sheet names, in the order the
  sheets are merged.

- `sheet_ids`: a named list of the key columns of the Admin sheet, the
  Population sheet and (as `service_data`) every other sheet.

- `admin_sheet_name`, `population_sheet_name`, `reporting_sheet_name`,
  `service_sheet_names`: the sheet names used, with defaults filled in.

- `path`, `start_year`: the arguments as given.

## Details

Month names are standardized to English on every sheet that has a
`month` column, and the original text is kept in a `raw_month` column.
The sheets can then be joined on `month` even if they name the months in
different languages.

The function stops with an error if a named sheet is not in the
workbook, if a sheet is empty, or if a sheet lacks its key columns
(`district` for the Admin sheet, `district` and `year` for the
Population sheet, and `district`, `year` and `month` for the others).
Other problems with the data are left to the data quality checks.

## See also

[`merge_and_standardize()`](merge_and_standardize.md),
[`run_all_quality_checks()`](run_all_quality_checks.md)

## Examples

``` r
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
sheets <- load_excel_parts(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
names(sheets$parts)
#> [1] "Service_data_1"         "Service_data_2"         "Service_data_3"        
#> [4] "Reporting_completeness" "Population_data"        "Admin_data"            
sheets$service_sheet_names
#> [1] "Service_data_1" "Service_data_2" "Service_data_3"
sheets$parts[[sheets$population_sheet_name]]
#> # A tibble: 235 × 9
#>    district         year pop_growth_rate total_population population_under_5ye…¹
#>    <chr>           <int>           <dbl>            <dbl>                  <dbl>
#>  1 Baringo          2019             3.2           733263                125574 
#>  2 Bomet            2019             2.7           963020                211064.
#>  3 Bungoma          2019             3.2          1837022                283060.
#>  4 Busia            2019             2.2           982892                154759 
#>  5 Elgeyo Marakwet  2019             3.5           499671                 86954.
#>  6 Embu             2019             1.4           669523                 74487.
#>  7 Garissa          2019             3.9          1012690                126501.
#>  8 Homa Bay         2019             2.6          1245362                194920 
#>  9 Isiolo           2019             2.5           292740                 32510.
#> 10 Kajiado          2019             3.6          1223577                159056.
#> # ℹ 225 more rows
#> # ℹ abbreviated name: ¹​population_under_5years
#> # ℹ 4 more variables: population_under_1year <dbl>, live_births <dbl>,
#> #   total_births <dbl>, women_15_49_years <dbl>

# Month names are in English, the workbook's own text is kept beside them
unique(sheets$parts[[sheets$service_sheet_names[1]]][c("month", "raw_month")])
#> # A tibble: 12 × 2
#>    month     raw_month
#>    <chr>     <chr>    
#>  1 January   January  
#>  2 February  February 
#>  3 March     March    
#>  4 April     April    
#>  5 May       May      
#>  6 June      June     
#>  7 July      July     
#>  8 August    August   
#>  9 September September
#> 10 October   October  
#> 11 November  November 
#> 12 December  December 
```

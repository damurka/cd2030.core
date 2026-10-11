# Preparing your data

This guide describes the file cd2030.core reads, what happens to it when
it is loaded, and how to find out what is wrong with a file that does
not load.

``` r

library(cd2030.core)
path <- system.file("extdata", "kenya.xlsx", package = "cd2030.core")
```

## The three kinds of file

| File | What it is | Read with |
|----|----|----|
| `.xlsx`, `.xls` | The Countdown workbook, one sheet per kind of data | [`load_data()`](../reference/load_data.md), [`load_cache_data()`](../reference/load_cache_data.md) |
| `.dta` | A Stata master file: the merged table, already one row per district and month | [`load_data()`](../reference/load_data.md), [`load_cache_data()`](../reference/load_cache_data.md) |
| `.rds` | A dataset saved by this package, with the choices made about it | [`load_cache_data()`](../reference/load_cache_data.md) |

## The workbook

The example workbook has these sheets:

``` r

readxl::excel_sheets(path)
#>  [1] "Read_me"                "Data_checks"            "Admin_data"            
#>  [4] "Population_data"        "Reporting_completeness" "Service_data_1"        
#>  [7] "Service_data_2"         "Service_data_3"         "Vaccine_stock_data"    
#> [10] "Contextual_campaigns"
```

Four kinds of sheet are read. The others (the read-me, the workbook’s
own checks, stock and campaign data) are left alone.

| Sheet | One row per | Key columns | Holds |
|----|----|----|----|
| `Admin_data` | district | `district` | the country, the first administrative level (region) of each district, numbers of facilities and staff |
| `Population_data` | district and year | `district`, `year` | total population, under-fives, under-ones, live births, total births, women aged 15 to 49 |
| `Reporting_completeness` | district and month | `district`, `year`, `month` | reports expected and received, and the reporting rate, for each group of services |
| `Service_data_1`, `Service_data_2`, … | district and month | `district`, `year`, `month` | the monthly counts: one column per indicator |

Every sheet whose name contains `Service_data` is read, so indicators
can be spread over as many service sheets as is convenient. If your
workbook names its sheets differently, give the names:

``` r

load_data(
  "my-country.xlsx",
  admin_sheet_name = "Admin",
  population_sheet_name = "Population",
  reporting_sheet_name = "Completeness",
  service_sheet_names = c("ANC", "Delivery", "Vaccines")
)
```

## What loading does

``` r

data <- load_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths, ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
```

1.  **Column names are cleaned**: lower case, with the workbook’s
    headings mapped to the names the package uses (`First_admin_level`
    becomes `adminlevel_1`, `Penta1` becomes `penta1`).
2.  **The sheets are merged** into one table with a row for each
    district and month.
3.  **The country is recognised** from the Admin sheet, and its ISO3
    code is attached. The name can be any usual form of it (`"Kenya"`,
    `"Republic of Kenya"`, `"KEN"`, `"RDC"`, `"Côte d'Ivoire"`,
    `"Ivory Coast"`), whatever the case or accents, and a small
    misspelling is accepted. A name that could be two countries stops
    the load and names both. The country must be one of those the
    package holds reference data for.
4.  **The indicator group is detected**: the group whose indicators best
    match the columns in the file.
5.  **Empty columns are reported**, as in the message above. They are
    not an error: an indicator your country does not collect stays empty
    and its results are left out.

The result is a tibble of class `cd_data`. The country and group travel
with it:

``` r

attr(data, "country")
#> [1] "Kenya"
attr(data, "iso3")
#> [1] "KEN"
attr(data, "indicator_group")
#> [1] "rmncah"
```

## Indicator groups

An indicator group says which indicators a dataset has and how they are
grouped for reporting rates and adjustment. Two are built in.

``` r

list_indicator_groups()
#> [1] "rmncah"  "vaccine"
```

These are the groups and indicators of the one the example file was
matched to:

``` r

get_indicator_groups()
#> $anc
#> [1] "anc1"           "anc_1trimester" "anc4"           "ipt2"           "ipt3"          
#> [6] "syphilis_test"  "ifa90"          "hiv_test"      
#> 
#> $idelv
#>  [1] "sba"              "ideliv"           "instlivebirths"   "csection"         "low_bweight"     
#>  [6] "pnc48h"           "total_stillbirth" "stillbirth_f"     "stillbirth_m"     "maternal_deaths" 
#> [11] "neonatal_deaths" 
#> 
#> $vacc
#> [1] "penta1"   "penta3"   "measles1" "measles2" "bcg"     
#> 
#> $opd
#> [1] "opd_total"  "opd_under5"
#> 
#> $ipd
#> [1] "ipd_total"  "ipd_under5"
```

A group of indicators has a reporting rate column named after it
(`anc_rr`, `idelv_rr`, `vacc_rr`, `opd_rr`), which is what the
`Reporting_completeness` sheet supplies.

To load a file as a particular group, name it:
`load_data(path, indicator_group = "vaccine")`. To add indicators of
your own to a built-in group, register them before loading:

``` r

register_indicator_group("rmncah", list(hiv = c("hiv_test", "pmtct1")), on_conflict = "merge")
```

## What the columns mean

[`cd_dictionary()`](../reference/cd_dictionary.md) holds the package’s
vocabulary: the indicators, the populations, the denominators and the
pattern of the computed column names.

``` r

head(cd_dictionary()$indicators)
#>               id             label group computed
#> 1           anc1             ANC 1   anc    FALSE
#> 2 anc_1trimester ANC 1st Trimester   anc    FALSE
#> 3           anc4      ANC 4 Visits   anc    FALSE
#> 4           ipt2      IPT 2nd Dose   anc    FALSE
#> 5           ipt3      IPT 3rd Dose   anc    FALSE
#> 6  syphilis_test     Syphilis Test   anc    FALSE
```

[`cd_describe_columns()`](../reference/cd_describe_columns.md) explains
any column name, including the computed ones that appear later in the
analysis.

``` r

cd_describe_columns(c("anc1", "vacc_rr", "cov_penta3_dhis2", "totunder1_un"))[, c("column", "type", "description")]
#>             column           type
#> 1             anc1          count
#> 2          vacc_rr reporting_rate
#> 3 cov_penta3_dhis2       coverage
#> 4     totunder1_un     population
#>                                                                       description
#> 1                                                         ANC 1 (number reported)
#> 2                    Reporting rate, vaccination (% of expected reports received)
#> 3           Coverage of Pentavalent 3 (%), denominator: DHIS2 projections (dhis2)
#> 4 Children under 1 (thousands) estimated with the UN projections denominator (un)
```

## When a file does not load

[`load_data()`](../reference/load_data.md) stops with a message when the
file cannot be used. The usual causes:

- **A sheet or a key column is missing.** The message names the sheet
  and the column.
- **The country is not recognised**, or the Admin sheet names more than
  one country.
- **A district is not the same throughout**: it is placed in two
  regions, or is missing from one of the years. It has usually been
  renamed or misspelled in part of the workbook.
- **A month is missing or not valid.** Each district needs a row for
  every month of every year it appears in.

The last two are checks on the data, not on the structure of the file.
To load the file anyway and see every problem at once, turn them off and
run the checks yourself:

``` r

data <- load_data("my-country.xlsx", validate = FALSE)
run_all_quality_checks(data)
```

Each check returns what it found, or `NULL` when there is nothing to
report. The Load Data screen of the Countdown apps runs the same checks
and shows the findings before the data is accepted.

## Reference data for the country

For the countries it knows, the package holds UN population estimates,
UN mortality estimates, WUENIC immunization estimates and household
survey estimates. [`load_cache_data()`](../reference/load_cache_data.md)
attaches them to the dataset:

``` r

cache <- load_cache_data(path)
#> ℹ Loading Excel "kenya.xlsx" for parts
#> ! The following columns are empty: anc_1trimester, under5_deaths, total_deaths, ipv2, measles_cases
#> ℹ Successfully loaded and cleaned data
#> ℹ Auto-detect candidates (|group|): vaccine=19, rmncah=28 -> selected rmncah
cache$un_estimates
#> # A tibble: 9 × 14
#>   country countrycode iso3  iso2   year un_under1y un_under5y un_wom15_49 un_population un_popgrowth
#>   <chr>         <dbl> <chr> <chr> <dbl>      <dbl>      <dbl>       <dbl>         <dbl>        <dbl>
#> 1 Kenya           404 KEN   KE     2017      1411.      6949.      12338.        49198.         2.11
#> 2 Kenya           404 KEN   KE     2018      1412.      6937.      12651.        50207.         1.96
#> 3 Kenya           404 KEN   KE     2019      1407.      6934.      12971.        51203.         1.97
#> 4 Kenya           404 KEN   KE     2020      1407.      6938.      13330.        52217.         1.95
#> 5 Kenya           404 KEN   KE     2021      1419.      6949.      13700.        53219.         1.85
#> 6 Kenya           404 KEN   KE     2022      1436.      6982.      14084.        54252.         2.00
#> 7 Kenya           404 KEN   KE     2023      1453.      7037.      14494.        55339.         1.97
#> 8 Kenya           404 KEN   KE     2024      1472.      7110.      14908.        56433.         1.94
#> 9 Kenya           404 KEN   KE     2025      1493.      7201.      15320.        57532.         1.92
#> # ℹ 4 more variables: un_births <dbl>, un_cbr <dbl>, un_tfr <dbl>, un_cdr <dbl>
```

A country’s own files can replace them: see
[`load_un_estimates()`](../reference/load_un_estimates.md),
[`load_wuenic_data()`](../reference/load_wuenic_data.md),
[`load_survey_data()`](../reference/load_survey_data.md) and the
matching `cache$set_...()` methods in
[`?CacheConnection`](../reference/CacheConnection.md).

# Population filter chip

A filter chip that chooses the DHIS2 population the growth-projected
denominators (ANC1 and Penta1 population growth) are built from. The
choice is kept in the dataset.

## Usage

``` r
cd_population_ui(id)

cd_population_server(id, cache)
```

## Arguments

- id:

  The module's id.

- cache:

  A reactive that returns the dataset, a
  [CacheConnection](CacheConnection.md).

## Value

`cd_population_ui()` returns the UI as Shiny tags (the chip).

`cd_population_server()` returns a reactive holding the chosen
population's id as a string (`NULL` until the chip has reported a
value).

## Details

The choices are `"totlivebirths_dhis2"` (live births),
`"totbirths_dhis2"` (total births), `"totpop_dhis2"` (total population)
and `"totunder1_dhis2"` (population under one year).

Once the chip is on the page, the server sets it to the dataset's value,
`cache()$derivation_population`, when there is one, and does so again
whenever `cache()` changes. Each choice the chip reports is saved with
the dataset's `set_derivation_population()`.

The ui takes no translator: its labels are translated with the
translator the app registered with `cd_use_i18n()`.

## Examples

``` r
if (FALSE) { # \dontrun{
# in a page's ui
cd_population_ui(ns("population"))

# in the page's server
population <- cd_population_server("population", cache)
} # }
```

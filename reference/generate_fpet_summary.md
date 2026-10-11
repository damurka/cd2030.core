# Load and generate FPET output

Processes raw FPET data (e.g., from Track20 or UNFPA) into a structured
tibble for visualization and interpretation of modern contraceptive
prevalence and demand satisfied.

## Usage

``` r
generate_fpet_summary(.data)
```

## Arguments

- .data:

  An object of class `cd_fpet_data`.

## Value

A `cd_fpet_data` object.

## Examples

``` r
if (FALSE) { # \dontrun{
# an FPET results file (.csv) for the country
fpet <- load_fpet_data(path = "fpet_kenya.csv", country_iso = "KEN")

summary <- generate_fpet_summary(fpet)
plot(summary)
interpret(summary)
} # }
```

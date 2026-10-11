# Describe the adjustment settings as a report footnote

Writes the adjustment settings out in sentences, for the footnote of a
report: the years and areas removed, then the rules that apply
everywhere and those of each area (k factors, and whether outliers are
corrected and missing values filled).

## Usage

``` r
adjustment_settings_footnote(
  settings,
  group_labels = NULL,
  indicator_labels = NULL
)
```

## Arguments

- settings:

  The settings list.

- group_labels, indicator_labels:

  Named character: how groups and indicators are called (by default
  their ids).

## Value

A character vector, one sentence per rule. The Countdown default is one
rule (each group's k, everywhere); settings that change nothing give
none.

## Examples

``` r
settings <- adjustment_settings_default(k = 0.1, groups = c("anc", "vacc"))
settings$removed_years <- 2020
settings$everywhere$outliers <- list(penta3 = FALSE)
settings$areas <- list(list(area = "Coast", level = "adminlevel_1", all_missing = FALSE))
adjustment_settings_footnote(settings)
#> [1] "2020 removed everywhere."                                            
#> [2] "Everywhere: anc k 0.1; vacc k 0.1; no outlier correction for penta3."
#> [3] "Coast: missing values not filled; the rest as everywhere."           

# With the names a report uses
adjustment_settings_footnote(
  settings,
  group_labels = c(anc = "Antenatal care", vacc = "Immunization"),
  indicator_labels = c(penta3 = "Penta 3")
)
#> [1] "2020 removed everywhere."                                                                
#> [2] "Everywhere: Antenatal care k 0.1; Immunization k 0.1; no outlier correction for Penta 3."
#> [3] "Coast: missing values not filled; the rest as everywhere."                               
```

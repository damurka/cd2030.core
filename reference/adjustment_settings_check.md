# Check and tidy adjustment settings

Validates settings as the Data Adjustment page sends them (JSON read
with `simplifyVector = FALSE`) and returns them in one shape: numbers as
numbers, flags as logicals, empty maps as empty lists, unknown groups,
indicators and levels refused.

## Usage

``` r
adjustment_settings_check(settings)
```

## Arguments

- settings:

  The settings list.

## Value

The settings, tidied. An error says what is wrong.

# The Countdown default adjustment settings

Every indicator group adjusted for completeness with the method's k
(0.25), outliers corrected and missing values filled everywhere, no year
or area removed.

## Usage

``` r
adjustment_settings_default(k = .cd_method$adjustment$k, groups = NULL)
```

## Arguments

- k:

  The k of every group (by default the method's, `0.25`).

- groups:

  The groups that have a k (by default the app's, `cd_cfg("k_factors")`,
  else the method's).

## Value

The settings list (see
[`adjust_service_data()`](adjust_service_data.md)).

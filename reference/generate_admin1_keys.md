# Generate a simple, stable-within-one-load synthetic key per admin-1 region

The Load Data wizard's own Finish step (Phase 3 of the wizard redesign,
apps/rmncah) needs a key that consistently identifies the same admin-1
region across three separately-built tables (`countdown_data`,
`survey_mapping`, `map_mapping`) – there's no real ISO-3166-2 code
available for sub-national regions in general, so this is intentionally
arbitrary, not a real-world identifier: `sort(unique(...))` the
dataset's own admin-1 names and number them off. Applied once, from one
canonical source (the dataset's own `adminlevel_1` values), then joined
onto the other two tables by name – consistency across all three is
structural (the same join key everywhere), not something that can drift.

## Usage

``` r
generate_admin1_keys(admin1_names)
```

## Arguments

- admin1_names:

  Character vector of admin-1 names (typically
  `countdown_data$adminlevel_1`).

## Value

A tibble with one row per distinct name: `adminlevel_1`, `admin1_key`
(`"A1-001"`, ...).

## Details

Deliberately NOT stable across separate future re-uploads of the same
country's data (e.g. next month's file) – purely alphabetical,
regenerated fresh every time this is called. Nothing downstream needs
cross-session stability for this key today; if that's ever needed, it's
a materially different feature (a persisted, append-only name-to-key
lookup table), not this.

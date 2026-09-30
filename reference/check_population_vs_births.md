# Check that estimated population live births aren't lower than reported institutional counts

Per district-year, `Population_data$live_births` (an annual estimate)
should be at least as large as the sum of the service sheets' own
institutional counts (`instlivebirths`, or `instdeliveries` if that's
what the sheet has instead – the spec names both interchangeably) across
that district-year's months – not every birth happens in a facility, so
the population estimate being *lower* than what facilities alone
reported is a real, actionable data problem, not just an interesting
pattern. `margin` allows the population figure to fall a little short
before flagging, since these are independent estimates, not the same
count twice.

## Usage

``` r
check_population_vs_births(
  parts,
  population_sheet_name,
  service_sheet_names,
  margin = 0.1
)
```

## Arguments

- parts:

  Named list of cleaned per-sheet tibbles.

- population_sheet_name:

  Name of the population sheet within `parts`.

- service_sheet_names:

  Names of the service-data sheets within `parts`.

- margin:

  Fraction (0-1) of headroom allowed before flagging. Default `0.10`
  (10%).

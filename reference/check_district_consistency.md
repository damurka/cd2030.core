# Check a district's admin-1 pairing and spelling are stable across years

Flags a district that maps to more than one `adminlevel_1` value
(case/whitespace-insensitive first, so a genuine typo isn't hidden by
two spellings happening to normalize the same way), and separately flags
a district that isn't present in every year the dataset otherwise covers
(service-data districts are expected to be stable across years; a
district appearing in some years but not others is much more often a
rename/typo than a legitimate gap).

## Usage

``` r
check_district_consistency(.data)
```

## Arguments

- .data:

  The merged, standardized dataset (`countdown_data`-shaped: `district`,
  `adminlevel_1`, `year` columns).

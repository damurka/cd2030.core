# What the data quality checks found, for the Data Adjustment page

The numbers the Data Adjustment page shows beside its settings, from the
same computations as the check pages (Reporting rate, Outlier detection,
Data completeness): each indicator group's national reporting rate in
`year` and how many districts report below `threshold`; each indicator's
outlier months (more than 5 x MAD from the district's median) and empty
months; each region's and district's lowest group reporting rate in
`year`.

## Usage

``` r
adjustment_evidence(
  .data,
  threshold = .cd_method$data_quality$reporting_threshold,
  year = NULL
)
```

## Arguments

- .data:

  A `cd_data` tibble (the data before adjustment, its removed years
  already left out).

- threshold:

  The reporting threshold (percent) of the Reporting rate page.

- year:

  The year of the reporting rates (by default the latest).

## Value

A list: `year`, `threshold`, `groups` (named by group: `rr`, `below`),
`indicators` (named by indicator: `outliers`, `missing`, months),
`areas` (a list of
`list(region, rr, districts = list(list(name, rr)))`).

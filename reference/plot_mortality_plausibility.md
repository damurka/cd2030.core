# Plot Subnational Mortality Plausibility

Generates subnational scatter plots with annual medians and plausible
ranges as requested for the CAM 2026 subnational mortality analysis.

## Usage

``` r
plot_mortality_plausibility(
  x,
  indicator = c("fresh_total_sb", "ratio_md_sb", "ratio_md_nd"),
  title = NULL,
  y_axis = NULL,
  x_axis = NULL,
  note = NULL,
  legend_labels = NULL
)
```

## Arguments

- x:

  A `cd_mortality_summary` object.

- indicator:

  One of `"fresh_total_sb"`, `"ratio_md_sb"`, `"ratio_md_nd"`.

- title:

  (Optional) Custom translated title.

- y_axis:

  (Optional) Custom translated y-axis label.

- x_axis:

  (Optional) Custom translated x-axis label.

- note:

  (Optional) Custom translated footnote caption.

- legend_labels:

  (Optional) A named list to override default legend labels (keys:
  'median', 'plausible').

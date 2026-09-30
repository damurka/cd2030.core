# The standard reports

One per analysis section (data quality, adjustment, denominators,
national coverage, inequality, mortality, service utilization, health
system, private sector), then the synthesis chartbook and the
sub-national one-pager: the Countdown report templates rebuilt as
blocks, which the builder opens as editable copies. The one-pager is
about one region: its blocks use the report's region
(`region = "@report"`). It is a slide deck of one dense slide.

## Usage

``` r
report_presets(lang = "en", group = get_selected_group())
```

## Arguments

- lang:

  The language of the report's text: `"en"`, `"fr"` or `"pt"`.

- group:

  The indicator group (`"rmncah"` or `"vaccine"`); each has its own
  list.

## Value

A named list of reports in the order of the analysis, each
`list(name, description, kind, design, cover, blocks)` for a document
(`kind = "document"`), or
`list(name, description, kind = "deck", design, cover, slides)` for a
slide deck (see
[`export_deck()`](https://rdrr.io/pkg/datasuite.ui/man/export_deck.html)).
[`report_project_blocks()`](https://rdrr.io/pkg/datasuite.ui/man/report_project_blocks.html)
gives the blocks of either.

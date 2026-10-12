# cd2030.core 1.4.3

* Requires datasuite.ui 0.5.2: the Reports page lists the dataset's reports and the standard reports again, and the builder has its kinds of
  chart, its themes, years and regions. Since datasuite.ui 0.5.0 the page said "No reports yet" over a dataset that
  has reports, and often showed no standard reports.

# cd2030.core 1.4.2

* National Coverage & Continuum: the heat map of the regions is drawn. Since 1.4.0 it showed "subscript out of
  bounds" in the app, for every dataset: the numbers on its tiles were coloured through a scale that has no legend,
  and the app, listing the chart's legend for the customize panel, failed on it. The numbers are coloured without a
  scale, so it is drawn on any datasuite.ui (0.5.1 fixes the listing itself).
* National Inequality and Sub-National Inequality with no region chosen: the chart is drawn. In 1.4.1 it showed
  "The size of `nm` (2) must be compatible with the size of `x` (3)": the page gives the label of a region only when
  one is chosen, and the missing label left the colours one name short.
* Reporting Rate: the heat map writes each number in the colour that reads on its tile, as the other heat maps do
  (it was black on all three colours).
* Data Missingness: the charts for one indicator ("missing indicators by region", the trend) say "Select an indicator
  to see this chart" when every indicator is chosen; the loader turned for ever. And the heat map's card becomes
  small again when one indicator is chosen (datasuite.ui 0.5.1, now required).
* The bar charts with a panel a region (reporting rate, outliers by region and by indicator, missing indicators by
  region) are as tall as their rows of panels need (datasuite.ui 0.5.1).
* Denominator Selection: the National Coverage card shows its loader while the coverage is worked out. It was blank.
* `set_k_factors()` on a dataset that has stored adjustment settings (one adjusted on the Data Adjustment page)
  changes the k in those settings too: they are what `adjust_data()` reads, and the new k was not used.
* Internal Consistency: no deprecation warnings (`cur_data()`, `size` for a line), and the labels RMNCAH asked for
  and did not have (`opv1_opv3`, `opt_instdeliveries`) are translated.

# cd2030.core 1.4.1

* Bayesian Analysis no longer holds the app while a model is fitted. 1.4.0 asked for one background worker, and a
  plan of one worker is run in the app's own process: every page waited for the whole fit (10 to 13 seconds for a
  national model, minutes for a sub-national one). The worker is now a separate process whatever their number;
  starting a fit gives the app back in 0.2 seconds.
* Public/Private Share: the C-section bars are each country's own. A sector's share of the C-sections was taken
  from all the countries in the file together, so a country's two bars added up to a fraction of its rate (Kenya
  2022: 1.8 %, for a survey rate of 16.5 %). The built-in shares are corrected for the 32 countries, national and by
  area (`data-raw/private_share_csection.R` says how); the private share itself, the ratio of the two bars, was
  right and is unchanged. `load_private_sector_data()` takes the share within each country and year.
* Sub-national Bayesian Analysis has a region and a year to choose.
    * One region: its estimates over the years, the chart the national page has for the country, with the
      country's facility-data coverage beside the region's.
    * Every region: the regions compared in the year chosen (it was always 2025), each with its model estimate and
      interval and its facility-data value, and the country's facility-data value as a line. The year starts at
      the latest one the facility data has.
    * Facility-data values are with the indicator's denominator, as the model's are.
    * In R: `plot()` of a sub-national model takes `year`, `national` and `legend_labels`;
      `cache$bayes_national_routine()` gives the country's values.
* Sub-National Inequality with a region chosen shows the region's own coverage beside its districts' and the
  national coverage. It showed the national value under the region's name ("Central Coverage").
  `plot()` of such a table draws `region_value` when the table has it; `legend_labels` takes `region`.
* The tables read as one family.
    * The three formatted tables (overall data quality score, service utilization data quality, national health
      system) have one look: the same header, section rows, lines, alignment and text. A cell judged against the
      threshold has the charts' red, amber and green, with its number readable on each. They had three different
      section colours, their own borders, and "seagreen", "yellow" and "red".
    * The data tables of the pages (units with low reporting, with extreme outliers, with missing data, the
      adjustment's changes by year, the units meeting a target) have the same options (compact rows, paged in
      tens when there are more than ten) and write numbers the same way: a count whole with its thousands
      apart ("12,345"), a rate or a coverage to one decimal, a year as it is.

# cd2030.core 1.4.0

* A change of setting writes the dataset's file once. Each table a change cleared was a write of the whole file, so a
  new performance threshold (14 tables) took 1.7 seconds before the page could answer, a new denominator 0.7. In a
  running app the writes of one change are now gathered into one, made a moment after the page has its answer: the
  change itself takes no measurable time, the write about 0.1 second. An app that closes with a write waiting makes
  it; outside an app (a script, a test) the file is written at once, as before.
* A setting clears the tables it enters, and only those. A new performance threshold cleared all 16 data-quality
  tables, 11 of which (reporting rates, outliers, ratios) are computed without it and came out the same: it now
  clears five. Choosing a denominator or a maternal denominator cleared the coverage, inequality and health-system
  tables and the Bayesian models, though the choice is only applied when a table is read: it now clears nothing, and
  a model fitted for one denominator is still there when you come back to it. Rebuilding afterwards: threshold 0.9
  seconds where it took 3 to 7, denominator none where it took 2.2.
* A new survey year now clears the coverage and inequality tables. They are computed from it, and were left as they
  were for the year before until something else cleared them.
* What a dataset keeps is described once (`R/cache-tables.R`): for each kept table, what it is computed from and
  how. Its binding, the reactive dependencies it takes and what every setter clears come from that list; the
  29 bindings, the clearing cascades and the definitions' `depends_on` were three hand-kept copies that disagreed.
  `CacheConnection` is 400 lines shorter. What changes for a user:
  - a new first survey year clears the coverage, inequality and Bayesian results (the surveys they are computed
    from are read from that year on; the results stayed as they were);
  - a new performance threshold, national survey or WUENIC file clears the Bayesian models, which are fitted on
    the overall score and on the coverage with its surveys;
  - new WUENIC estimates no longer clear the coverage and inequality tables, and new UN mortality estimates no
    longer clear the mortality summary: neither is computed from them.
* `get_regional_estimates()` gives a region's own rates from the survey files (its latest survey value of each
  mortality rate and coverage, read through the survey mapping), a district its region's. A rate the region's
  surveys do not give keeps the national value; the national rates are returned whole only when the region is not
  in the survey files. It read a variable that did not exist.
* The print headers of the district completeness and outlier tables are shown (their methods were written for
  classes nothing makes). Documentation regenerated with roxygen2 8.1.0.
* Fixes from a review of the package:
  - Measles 2 is in the child continuum of care (its column was named `measle2`).
  - Data Missingness: with a region chosen, the district table showed the whole country.
  - Service utilization: the OPD chart's "Under-5" and "All ages" lines were labelled the wrong way round.
  - Coverage Target: a dropout indicator is described as a rate below its target, not a coverage above it.
  - `plot_comparison_opv1_opv3()` is titled and labelled OPV1 and OPV3 (it said Penta1 and Penta3).
  - Twenty error messages are shown. Written `cd_abort("x" = ...)`, they failed with "argument "message" is
    missing" (a chart's title, axis or caption that is not one string, a region given for national data, a file
    that is not a .dta). Three more named a variable where they meant its value.
  - `save_dhis2_excel()`'s admin sheet, the mortality summary helpers and a district-level
    `filter_service_utilization()` used variables that did not exist.
  - The survey estimates leave OPV1 and OPV3 out outside the vaccine group (the test compared values, not names),
    and the education survey's levels are ordered.
  - New survey estimates clear the ratios summary, whose expected-ratio row is made from them.
* One Bayesian fit runs at a time. A fit uses four more R processes for its chains; two fits together took longer
  than one after the other (about 135 seconds for the pair against 47 each, on 24 cores) and twice the memory. A
  second fit now waits for the first (`options(cd2030.bayes_workers = )` for more).
* Requires datasuite.ui 0.5.0, where an app starts a page when it is opened.

* Bayesian Analysis no longer stops the other pages while a fit starts. Handing a fit to its worker sent the worker
  the environment the request was written in as well as the fit's inputs: the page's server, so the dataset, the
  Shiny session and all they reach. Packing that took the app's own process minutes (211 seconds, profiled, where the
  inputs are 0.3 MB), during which the session was busy: no page answered and no chart was sent. The worker is now
  sent the inputs alone (`cd_bayes_fit_task()`), which takes no measurable time.
* Each coverage is defined once (`.cd_coverage_defs`: what it counts, over which population) and computed on every
  denominator. It was written out for each of the four (UN, DHIS2, ANC1, Penta1) and each indicator group: 156
  lines, now a table. The results are the same to the last digit, at every level, for both groups.
* A computation uses the indicator group of the dataset it is given, not the one the session last selected
  (`set_selected_group()`): with two datasets of different groups open in one session, each is computed with its
  own indicators. Data that does not say its group is computed with the session's, as before.
* New data (`set_countdown_data()`) clears the adjusted data made from the data before; it is made again from the
  new data when next read. It was kept, so the coverage that followed was computed from the old data.
* The dataset's file is written beside itself and moved into place, so a write cut short (the app closed, the disk
  full) leaves the file as it was, not half of a new one that cannot be opened.
* `adjustment_values`: the yearly numbers as reported and after each step of the dataset's adjustment are computed
  once and kept. A report comparing seven indicators ran the whole adjustment seven times (0.8 second each).
* The table of district outliers can be downloaded. Its button was on the page with nothing behind it and showed as
  busy for as long as the page was open; a table given no Excel writer now downloads what it shows.
* The population table (`prepare_population_metrics()`) prints its header: the method was written for a class
  nothing makes. Documentation: "admin level 1" has one spelling in words (the column is `adminlevel_1`), the
  performance threshold one name, and `calculate_overall_score()`'s `ratio_pairs` is described.
* The check of a class is named after the class: `check_cd_data()` checks for `cd_data`, `check_cd_equity_data()`
  for `cd_equity_data`, and so on, one for each class checked in more than one place, all made the same way
  (`.cd_class_check()`, in `R/utils.R`). Five had other names (`check_cd_fpet()` and `check_fpet_data()` for the same
  class, `check_equity_data()`, `check_un_mortality()` and `check_un_mortality_data()`, `check_service_utilization()`)
  and 14 places checked such a class by hand. Internal: nothing exported changes.
* Removed, as nothing called them: `check_cd_population_metrics()`, `check_cd_reporting_rate()`,
  `check_scalar_character()`, `coalesce_join()`, `extract_un_summary()`, `calculate_summary()` (with
  `aggregate_indicator()`, `derive_ratio()` and `threshold_metric()`, which only they used), `load_public_private()`,
  `local_cd_loud()` and `.rb_note()`. None was exported.
* The functions that take one indicator out of a computed table, ready to plot, are `select_*()`: `select_coverage()`,
  `select_inequality()`, `select_mapping_data()`, `select_mortality_summary()`, `select_service_utilization()` and
  `select_adjustment_value()`. They were `filter_*()`, which read as filtering rows; they choose an indicator and
  reshape. The former names still work and say once per session what to call instead (`?"cd2030-deprecated"`).
  `filter_out_years()` and `filter_high_performers()`, which do filter rows, keep their names, as do the dataset's
  methods (`cache$filter_mortality_summary()`, `cache$filter_service_utilization()`).
* The files of the app's interface are named by what they hold: `page-<page id>.R` (a page's part as
  `page-<page id>--<part>.R`), `filter-`, `chart-`, `layout-`, `wizard-` and `app-`. They were 58 files starting
  `ui-`, with two separator styles, the analysis step's number in the page files and `ui-wizard-wizard-*`. Nothing
  in them changed.
* A dataset's country is no longer taken for one that only looks like it. The country was the closest name by
  string distance, so "Sudan" loaded as South Sudan, "Libya" as Liberia, "Mauritius" as Mauritania, "Guyana" as
  Ghana, "Tonga" as Togo and "Congo Brazzaville" as the Democratic Republic of the Congo, with their UN estimates
  and surveys, and nothing said so. A name is now matched to a country it names (any of its names in the table,
  whatever the case, accents or punctuation, or its ISO3 code), to the one country whose name starts with it, or to
  the one country it is a misspelling of (a letter in a name of five or more, two in nine or more). A misspelling
  that fits two countries (Nigeria, Niger) is asked about, not guessed. Also found now: "RDC", "RCA", "Ivory
  Coast", "Republic of Kenya". A name far from every country gets no suggestion (it got an unrelated one). "Congo"
  on its own is still the Democratic Republic. Needs stringi.
* The help pages follow the usual form: a short title in sentence case (147 were in Title Case or were whole
  sentences), a description of what the function does for its caller, every argument, and what is returned (37
  exported functions did not say). Notes on the code's history that were in the help text are comments in the code.
  Where the help contradicted the code, the help is corrected: among them the class `generate_admin1_service_utilization()`
  returns, `plot.cd_overall_score()` and two others returning a table, not a plot, `compute_service_utilization()`
  taking districts, and `get_mapping_data()`, which joins coverage to the map and computes none. Four examples
  called functions that do not exist.
* `save_dhis2_master_data()` joined a table that was not defined, so it always failed; it joins the admin sheet.
  `generate_health_system_table()`'s error for data that is not national was cut off mid-word.
* The app's interface is documented like the rest of the package. Every page, wizard step, filter, chart and table
  card, layout piece and `cd_app()` has a help page with what it shows or does, each argument and what it returns,
  written next to its code and exported there (a `_ui` / `_server` pair shares a page); the helpers that are not
  exported are described the same way in the code. They were 158 names on one page that said to read the source,
  where 98 of 177 functions had no comment. `?"countdown-pages"` stays as the guide, and the site lists them by
  kind. The same names are exported as before.
* The table of districts with missing values downloads its rows (its Excel writer wrote a function in their
  place). A file named with a capital extension (`DATA.XLSX`) is accepted by the upload box.
* Guides to get started, as vignettes and on the site: `vignette("cd2030.core")` (load a dataset, look at its
  quality, compute coverage, save), `vignette("preparing-data")` (the workbook, what loading does, why a file does
  not load), `vignette("data-quality")`, `vignette("coverage")` (adjustment, denominators, coverage, reports) and
  `vignette("building-an-app")`. Their code runs on the example dataset when the package is built. Needs knitr and
  rmarkdown to build (Suggests).
* `plot()` of an indicator coverage table (`calculate_indicator_coverage()`) draws again: it failed for every chart
  type, with "`y_vars` and `legend_labels` must have the same length". The site's reference index lists
  `get_national_rates()` and `list_missing_units()`, which it left out.
* Every chart changes its text and its look the same way (`?cd_plot_arguments`). Each `plot()` method, the equiplots
  and `plot_comparison()` take `title`, `subtitle`, `caption`, `x_title`, `y_title` and `legend_title`, in that order,
  after the arguments that say what to draw, then chart options by name (`background_color`, `font_family`,
  `text_scale`, `legend_position`, ...) and `options`. They had `x_axis`, `x_label` or neither for the same thing,
  `legend` or `legend_title`, and many had no subtitle or caption.
* **Breaking:** the older names are gone. `x_axis` and `x_label` are `x_title`, `y_axis` and `y_label` are `y_title`,
  `legend` and `fill_label` are `legend_title`; a chart given an older name stops and names the one to use. The
  pages, the reports and the apps use the new names. Also renamed, so that one thing has one name:
    * a list of legend entries is `legend_labels` everywhere, by name, after `...`: it was `labels` on
      `plot()` of a coverage table, of a regional coverage table, of the mortality summary, of the completeness of
      death reporting and of national service utilization, and `legend` on `plot_comparison()`;
    * the quadrant texts of the preventive against curative chart are `quad_labels` (was `labels`), as on the
      primary health care chart;
    * titles are no longer read from those lists (`labels$title`, `labels$x_axis`, `labels$y_axis`,
      `labels$legend`): give `title`, `x_title`, `y_title`, `legend_title`. The two maps (mortality, service
      utilization) have no `labels` argument any more;
    * `plot_mortality_plausibility()`'s footnote is `caption` (was `note`);
    * `plot_line_graph()` takes `x_title` and `y_title`.
  The three `plot_comparison_*()` functions write their title and axis titles when none is given (they were default
  values in the signature). A text held in `options` wins over the text argument on every chart (it did only on
  charts with an argument of their own for that text). The three tables drawn by `plot()` (overall score,
  utilization data quality, health system) are not charts and are as they were.
* Charts that did not draw, or drew the wrong text:
    * the trend of completeness for an indicator with every value reported failed ("Faceting variables must have at
      least one value"): complete indicators were dropped before the one asked for was chosen;
    * a coverage chart (`plot()` of `calculate_indicator_coverage()`) draws the indicators the dataset has: the
      immunization and zero-dose charts failed on an RMNCAH dataset, which has no OPV or IPV;
    * the outlier heat map titled its axes "Year" (under the regions) and "Percent non-outliers" (beside the
      years), from R and on the Outlier page;
    * the chart of districts with missing values used its vertical title only when a horizontal one was also given,
      and the other way round.
* `save_data()` writes a Stata file for a dataset loaded from a workbook. It failed on `raw_month.x`, a column the
  merge of the sheets left behind (with `raw_month.y`); a loaded dataset no longer has them.
* `calculate_ratios_and_adequacy()` is exported: `calculate_ratios_summary()` takes its result, and could only be
  used through the dataset object.
* In the apps:
    * a Stata master file is saved when the wizard is finished. Nothing set in the wizard or after it was ever
      written for one, and the wizard did not go to edit mode;
    * the Bayesian page has no Custom tab. It offered every indicator, and the model takes only its own, so any
      other choice was an error;
    * the Custom tab of the coverage, inequality, map and equity cards starts its chart once and follows the
      choice (`serverInput` gets a reactive for it; `cd_tab_indicator()` reads it). It started another chart on the
      same ids for each choice, and a change to one chart's options was also written for the indicators chosen
      before;
    * a table card with a year control downloads the year shown, as its file's name and its sheet's title say. It
      held every year;
    * the Sub-National Inequality card has its own title (it read "National Inequality");
    * the consistency check no longer starts a second ratios chart that is on no page (the AI was told of it).
* `filter_high_performers()` (the table of units meeting a target) keeps units below the threshold for a dropout
  indicator, as the chart counts them. It kept those at or above it.
* Every help page has examples (187 had none). Those that can run from the example dataset do, and are run when the
  package is checked; the Shiny pieces show how they are used in a page.
* The private sector chart (`plot()` of `prepare_private_sector_plot_data()`) takes its texts as the other charts do:
  `legend_labels` (`public`, `private`), `indicator_labels`, `area_labels` and `share_label` in place of one `labels`
  list.
* Loading:
    * `load_data()` and `load_excel_parts()` with a `start_year` load the data from that year on. Any `start_year`
      stopped the load ("'length = ...' in coercion to 'logical(1)'");
    * a Stata file is read with its months as an ordered factor of the month names, as a workbook is. A file
      written by `save_data()` could not be read back ("Can't join `x$month` with `y$month`"), nor one with months
      as labelled values;
    * `load_private_sector_data()` and `load_csection_estimates()` keep the rows of `country_iso` when the data
      holds several countries (the argument was not read).
* The Bayesian model fits institutional deliveries (`"ideliv"`) on data that names them `instdeliveries` or
  `instlivebirths`, as the built-in surveys and the coverage tables do. That tab stopped with "object 'r_ideliv' not
  found".
* `plot()` of the health system comparison draws its default chart, delivery coverage against workforce density
  (the comparison did not carry `cov_instdeliveries_*`).
* `plot()` of the overall score table and of the utilization data quality table shows every year when `years` is not
  given (it stopped with "`years` cannot be null").
* Smaller: `adjustment_settings_footnote()` takes labels for some of the groups or indicators (a partial named
  vector stopped it); `get_national_rates()` returns its table visibly; `cd_bayes_install_command()` returns nothing
  when nothing is missing (it gave `install.packages(c(""), ...)`); the FPET text says "decreased by 0.005", not
  "decreased by -0.005 points"; a report's list of regions has each region once.
* Institutional deliveries have a coverage: `cov_ideliv_*`, the deliveries in facilities over the deliveries. There was
  none, so every chart, map and report asking for the coverage of `ideliv` was drawn empty ("Column cov_ideliv_anc1
  not found"): the column that existed is `cov_instdeliveries_*`, which is the live births in facilities over the
  deliveries (Stata's column). It is kept, and labelled for what it is ("Institutional Live Births per Delivery").
* Charts name indicators by their labels, not their codes. The heat maps of missing values and of outliers showed
  `anc_1trimester`, `bcg`, `instlivebirths`...; the continuum heat map showed `anc1` for an indicator its caller had
  not listed. `cd_indicator_labels()` gives the labels (translated with a translator), the two heat maps take
  `indicator_labels`, and the pages and reports give them the app's language.
* The heat maps read better: softer red, amber and green, numbers that stay readable on each colour and get smaller
  as the columns get many, axes titled for what they hold ("Indicator", "Admin level 1"), and on the continuum heat
  map each tile's value and the indicators' names level and wrapped.
* The PHC performance chart draws its quadrants as the preventive against curative chart does: a text in each corner
  (it was placed at half and one and a half times the median, over the points), dashed median lines, and a faint tint
  on the quadrant high on both axes and on the one low on both.

# cd2030.core 1.3.10

* Bayesian Analysis no longer holds the app up. The fit already ran in another R process, but its result did not: a
  fitted model carried the sampler's draws and the compiled Stan model (13 MB national, 41 MB sub-national), which
  were brought back from the worker, kept in the dataset and written to its file, taking 3 to 6 seconds when a fit
  ended and again, for every model kept, each time anything else in the dataset changed. `generate_bayes_model()`
  now returns the model without them (`keep_samples = FALSE`: about 30 KB and 170 KB), the charts and
  `bayes_model_estimates()` being drawn from the summary it keeps, pixel for pixel as before. Models already saved
  in a dataset are held without their draws when it is opened, and written so at its next save
  (`slim_bayes_model()`).

* Requires datasuite.ui 0.4.4 (the Ask AI button's hint is its text, not the markup around it).
* Maps: choosing years one after another no longer sets the maps redrawing without end. Each choice was sent back
  to the years chip, and arrived after the next click, undoing it; the two selections then replaced each other for
  good (`cd_years_sync()`, on every page with a years chip).
* Charts in reports are drawn without tick marks on their axes, as the charts on the pages are (`cd_report_theme()`).
  A chart's Tick marks option still draws them for that chart.
* Reports take the app's colour: the Countdown report theme (accent and headings) is the vaccine app's blue in the
  vaccine app, as its pages are, where every app's reports were the RMNCAH maroon (`cd_app(theme = )`). A report
  saved before keeps the colours saved with it; choosing the Countdown theme again in its Design gives it the app's.

# cd2030.core 1.3.9

* Load Data: the required columns are checked at the Data Quality step, not only at Finish. `new_countdown()`'s
  check (`check_required_columns_exist()`) now also covers the population columns (`Total_Population`,
  `Population_under_5years`, `Population_under_1year`, `Live_births`, `Total_births`, `Women_15_49_years`,
  `Pop_growth_rate`) besides the group's indicators and reporting rates, and the wizard asks the same question of
  the unmerged sheets (`check_required_columns_presheet()`), naming what is missing by sheet, as the workbook
  spells it. A workbook without `Pop_growth_rate` used to pass every check and fail at Finish with "`false` must
  be a vector, not `NULL`" in the first district.
* Load Data: every data quality issue can be downloaded as an Excel workbook from the Data Quality step: a
  summary of the checks and one row per issue, with nothing shortened (`quality_issues_table()`,
  `write_quality_issues()`).
* Bayesian model, sub-national: it is fitted. `generate_bayes_model()` stopped with "Column `source` doesn't exist"
  for every indicator: the regional coverage had the survey's `source` as `source.x` beside the admin mapping's own
  `source` (`source.y`), because the mapping was joined whole. Only its two names are joined now
  (`calculate_coverage()` and `calculate_indicator_coverage()` at admin level 1), so regional coverage has `source`
  again and no `admin1_key`.
* The Bayesian models' estimates as tables: `bayes_model_estimates()` (coverage by year, 2010 to 2030, in percent,
  with the 95% and 80% intervals; a row per region for a sub-national model) and a dataset's
  `$bayes_estimates(admin_level)`, every model already fitted at a level in one table.
* The Bayesian Analysis pages are here (`bayesian_ui()`, `bayesian_page_server()`, moved from cd2030.rmncah), for
  every app: their tabs are `cd_cfg("bayes_indicators")` (default `cd_bayes_indicators`). future and promises are
  imported for them.

# cd2030.core 1.3.8

* `calculate_indicator_coverage()`: zero-dose and under-vaccinated coverage were wrong by a factor of about a million
  (the population in thousands was multiplied by 1000 instead of divided: `(pop*1000 - penta1)/pop*1000`), and for the
  ANC1-, Penta1- and derived denominators, which are counts, the 1000 did not belong at all. They are now the share of
  surviving infants without penta1 (zero-dose) or penta3 (under-vaccinated), as in the Countdown 2030 Stata code.
* Measles2 coverage is divided by the infants surviving to the second dose (`totmeasles2_*`), as in the Stata code and
  as the derived denominators already did, not by those surviving to the first.
* Notebook data: a dataset's notebooks get every table the CacheConnection has (51: the data, the results each page
  shows, the reference data), each listed with what it holds (`ds_list()`'s new `description`, and the list DataSuite
  shows in Stata's `dslist`). `notebook_data("prepare", tables = )` writes only the tables asked for, so Stata
  notebooks get a table when a cell first uses it; Python's are the usual twelve, as before. `wealth_survey` is the
  wealth-quintile survey again (it read a member that does not exist, so it was always empty).
* `notebook_data("describe")`: the notebook's dataset's tables with their columns and what each column holds
  (`cd_describe_columns()`), its grain and key columns, read from the `.rds` without changing it. DataSuite gives it to
  its assistant when it writes a notebook's code, and shows it when you hover a table or a column in a notebook.
* In R notebooks, the attached data (`datasuite:data`) names its tables in the attribute `jovian.tables`, so the
  kernel's variables pane and data viewer list and show them without reading the others or the `ds_*` functions.
* Requires datasuite.ui 0.4.3: charts and tables already drawn follow a change of language.
* `STATA-DIFFERENCES.md` lists where the package and the Countdown 2030 Stata code still differ, by choice.

# cd2030.core 1.3.7

* `cd_table_card_ui()` / `cd_table_card_server()`: a flextable in a chart card, with its picture and its data (Excel)
  in the card's header; the screen and the picture are drawn by the same function. The Overall Score page uses it (and
  rmncah's Service Utilization data quality and national Health System pages). DataSuite's AI can read the table.
* `cd_upload_data_ui()` / `cd_upload_data_server()`: the Load Data screen the apps had each kept a copy of; `cd_app()`
  uses it unless the app passes its own. An app describes its part of the wizard with `options(cd2030.wizard = ...)`
  as before.
* `cd_minimal_theme()`: `ggplot2::theme_minimal()` with a choice of grid lines (the subnational coverage dot plot and
  heat map, and cd2030.pooled's charts). The colours several charts share (the traffic-light categories, the year
  colours, Data Adjustment's steps...) and the theme pieces they repeated (the dashed grid, the maps' theme) are
  defined once (`R/utils-plot-themes.R`); the charts look as before.
* A failed reference-data upload (UN, WUENIC or UN mortality estimates) says why in its banner, instead of
  "Unsupported file format" for every error, and no longer prints the error to the console.
* sf is used through `sf::` instead of imported, so loading cd2030.core no longer loads sf (and GDAL, GEOS and PROJ)
  until a map is drawn or a shapefile read. officer is no longer imported whole (`officer::fp_border()` is its only
  use). No longer imports janitor, which nothing used.
* Needs datasuite.ui 0.4.2: inside DataSuite, `cd_request_bayes_packages()` asks it to install the Bayesian model's
  packages through `datasuite.ui::ds_host_request()`.

# cd2030.core 1.3.6

* `notebook_data()`: a folder's Countdown datasets for DataSuite's notebooks (an app's `notebookData`) -- by name in
  R, and as Stata files for Python and Stata notebooks, made again when their `.rds` changes.
* The Bayesian model's packages are installed when it is first wanted: `cd_bayes_packages_missing()` (checked without
  loading Stan), `cd_request_bayes_packages()` (inside DataSuite, asks it to install them) and
  `cd_bayes_install_command()` (the `install.packages()` call, for plain R). DESCRIPTION's `Config/datasuite/onDemand`
  keeps DataSuite's background install from fetching them; R itself ignores it.
* No longer suggests chromote, countrycode, png, ragg, rsvg, svglite or systemfonts, which nothing used.

# cd2030.core 1.3.5

* Data Adjustment is one page for the data kept and how it is corrected (the Remove Years page is gone; its years
  are the page's first section):
  - Remove years everywhere, or a region's or district's data for some or every year.
  - Completeness by each indicator group's k or an indicator's own, outliers and missing values -- each can be
    switched off everywhere or for a region or district, with its own k; a district's rules come before its
    region's, a region's before everywhere's.
  - Beside each setting, what the check pages found (reporting rates, districts below the threshold, outliers and
    missing values by indicator: `adjustment_evidence()`).
  - The settings are saved in the dataset (`cache$adjustment_settings`, `cache$set_adjustment_settings()`); a dataset
    saved before reads its k-factors and removed years as settings (`adjustment_settings_from_k()`).
  - New: `adjustment_settings_default()`, `adjustment_settings_check()`, `adjustment_settings_footnote()` (the rules in
    a sentence each, for reports) and `adjustment_steps_used()`; `adjust_service_data()` and
    `generate_adjustment_values()` take `settings` (and the latter an `area` and `level`).
* Data Adjustment Changes shows, for each year, the reported count beside the adjusted count made of its parts
  (completeness, missing values, the outliers' correction; a correction that lowers the count drawn as removed), with
  the same in a table -- a step an indicator does not get reads "Off" -- for every area, a region or a district, and
  the rules in force. The adjustment report chart is the same.
* Tables show a table's loader while they are computed.
* Bayesian models: `bayes_model_key()`, `bayes_model_cached()`, `bayes_model_inputs()` and `keep_bayes_model()`, so
  an app can fit a model in the background and keep it.
* Requires datasuite.ui 0.4.0 (reports written by Quire's writers).

# cd2030.core 1.3.4

* The AI can read and change a saved report instead of replacing it: new AI bridge actions (datasuite.ui 0.3.4's
  `report_list()`, `report_read()` and `report_update_blocks()`):
  - `listReports` (read): the reports saved in the dataset.
  - `readReport` (read): a report's blocks in order -- the text of its headings, paragraphs and notes, and for each
    chart and table its kind, settings, options and a short table of the data it shows -- and its language.
  - `updateBlocks` (replace): targeted changes by block id -- write or rewrite text, change a chart's kind, settings,
    chart options or layout, insert blocks after one, remove or move blocks -- checked as a whole and saved once,
    with the report's id kept; everything else in the report stays as it is. The user's permission setting may ask
    them first, with a summary such as `Write 5 paragraphs in the report "Benin National Coverage" (benin.rds)` or
    each change (`Chart "Coverage trend" (anc4): Coverage trend -> Coverage map; year none -> 2023`). The Reports
    page shows the change at once, the open report too.
* A report the AI saves (`saveReport`) carries its own id, as the builder's reports do: the Reports page saves edits
  by it, so edits to a report the AI had saved were not saved (datasuite.ui 0.3.4 also repairs the reports saved
  before).
* Needs datasuite.ui 0.3.4; every package in Imports has a minimum version.

# cd2030.core 1.3.3

* `CacheConnection$denominator_comparison(indicator, admin_level, region)`: the Denominator Selection comparison as
  one tidy table -- for each indicator and year, its coverage under each denominator option (id and label) next to
  the survey estimate of that year with its bounds, the difference in percentage points, and which denominator is
  the one chosen for the indicator. The same numbers as the Denominator Selection charts
  (`calculate_derived_coverage()`), one row per denominator, so the Countdown AI can compare the options in one call.
  By default it compares the indicators the page does. It is chartable, defined in `cache_definition()`, and its
  new columns (`denominator_label`, `selected`, `coverage`, `survey`, `survey_lower`, `survey_upper`, `difference`,
  `survey_year`) are in the data dictionary.

# cd2030.core 1.3.2

* Portuguese: the translations and the report presets' questions read as Portuguese is written in Mozambique and Angola (European norm) instead of Brazilian Portuguese ("Contagem decrescente para 2030", "nados vivos", "Dados em falta", "Transferir"...).

# cd2030.core 1.3.1

* A data dictionary: `cd_dictionary()` says what the ids and column names in the package's data mean -- the six
  denominator options (id, label, what it is, levels), indicators, target populations, reporting rates, fixed columns
  and how names are built (`cov_<indicator>_<denominator>`, `<population>_<denominator>`, `r_<indicator>`, ...).
  `cd_describe_columns()` reads column names with it ("Coverage of Pentavalent 3 (%), denominator: Penta1 population
  growth (penta1derived)") and never guesses a name it can't read. `cd_denominator_labels()` gives the labels,
  translated when given a translator.
* The denominators have one set of labels everywhere -- UN projections, DHIS2 projections, ANC1-derived,
  Penta1-derived, ANC1 population growth, Penta1 population growth -- in the denominator chip, the Denominator
  Selection charts, the reports and the plot legends (new translation keys `lbl_denom_anc1_growth` and
  `lbl_denom_penta1_growth`). `anc1`/`penta1` are the -derived options and `anc1derived`/`penta1derived` the
  population-growth ones; the ids are unchanged.
* `inst/scripts/export-data-dictionary.R` writes the docs' "Data dictionary" reference page from it.
* Every public member of `CacheConnection` is defined (`R/cache-definitions.R`): `cache_definition()` says what each
  data point is in the methodology's terms -- its kind (data, setting, reference, mapping, check, value, store,
  state, method, action), its grain (what one row is) and key columns, its unit, where the user sets it in the app
  and which pages show it, the methodology docs section it comes from, the defaults it follows (ids of
  `cd_methodology_defaults()`) and the members it is computed from. Columns are left to the data dictionary.
  `cache_manifest()` includes each member's `definition`. A test fails when a member is added without one, or when a
  docs link or default reference doesn't resolve. Eight members are marked draft with a note (among them
  `get_regional_estimates()`, which fails for a region because it reads an undefined object).
* `inst/scripts/export-cache-reference.R` writes the docs' "CacheConnection reference" page from the definitions.

# cd2030.core 1.3.0

The constants of the Countdown methodology are defined once, in `R/methodology-defaults.R`:

* `cd_methodology_defaults()` lists them (the adjustment's k and reporting-rate cutoff, the 5 x MAD outlier rule, the
  district reporting threshold, the ratio ranges and score components, the default rates of the denominators, the
  coverage targets, the mortality flags), each with its step, indicator group, unit, label, note and source file.
  The functions that use them read them from there, so the documented values are the ones the code runs with.
* `inst/scripts/export-methodology-defaults.R` writes them as the JSON the DataSuite docs read; the AI guide sync
  workflow also regenerates it on each release and opens a pull request on the docs.

The AI bridge actions:

* `setFilters` only changes the view; `saveReport` and `addGraph` add, or replace when the id given is already saved;
  `generateReport` adds a file, or replaces one of the same name. Each describes itself for the user's confirmation,
  which DataSuite asks only before a replacement.
* A report's image block that names a figure the AI saved in the dataset's analysis folder is stored in the dataset as
  a picture, so the report keeps it (PNG or JPEG from that folder only, up to 5 MB).
* Generated reports go in the analysis folder's `reports/`.
* Requires datasuite.ui 0.3.0.

# cd2030.core 1.2.0

For the Countdown AI in DataSuite (countdown-analytics/docs/AI-PLAN.md), everything around `CacheConnection`:

* The MCP server (`cd2030_mcp_server()` and its tools) is removed; the AI works from `CacheConnection` itself.
* `cache_manifest()`: every public member of `CacheConnection` with its arguments (defaults, allowed values), its
  documentation and whether it writes or can be charted, plus the report kinds, read from the installed package.
* `CacheConnection$decompose_change()`: which districts (or regions) drive a change in an indicator's coverage between
  two years, split into service delivery and denominator, with a reporting-rate flag.
* `CacheConnection$revision` goes up with every saved change; `init_CacheConnection(read_only = TRUE)` opens a dataset
  without ever writing it (the AI's copy).
* Custom charts: report kind `custom_chart` (data from a `CacheConnection` member, fixed transforms, a plot
  description; never code), `cd_chartable_members()`, `cd_member_data()`, `cd_custom_chart_data()`, and saved graphs
  in the dataset (`set_graph()`, `graphs`), which reports can use.
* The AI bridge: the Countdown pages' charts and tables say which report kind they are and with which options; the
  state has the dataset's path, country and revision; new actions `saveReport`, `addGraph` and `generateReport`.
* Requires datasuite.ui 0.2.0.

# cd2030.core 1.1.1

Documentation only; no change to the code.

* A new README: what the package does, where it fits (DataSuite, the Countdown apps, datasuite.ui), installing from
  r-universe, a walkthrough on the bundled Kenya data, `CacheConnection`, indicator groups, reports, building an app
  with `cd_app()`, developing and releasing.
* `?cd2030.core` and `?countdown-pages` give overviews of the entry points and the Countdown pages.
* The pkgdown reference index lists every help topic; `URL` and `BugReports` point to github.com/damurka/cd2030.core.
* The Bayesian coverage packages come from https://alkemalab.r-universe.dev (`Additional_repositories`).

# cd2030.core 1.1.0

* Report builder: standard reports rebuilt as blocks (`report_presets()`), exported to Word, PowerPoint and PDF
  through datasuite.ui's report engine; `cd_report_context()` is a dataset's report context.
* The Countdown pages every Countdown app shares (data quality, denominators, coverage, equity, the Load Data
  wizard, filters, nav sections and `cd_app()`) moved here from the apps, built on datasuite.ui.
* Chart options (`cd_chart_options()` and friends) and the report engine now live in datasuite.ui; they are
  imported and re-exported here, so existing code keeps working.
* Countdown's translations (indicator names, chart titles, page texts) are in `inst/translation/cd2030.json`.

# cd2030.core 1.0.0
* Initial Release
* `CacheConnection` now names a file-backed cache after its source file's
  basename (`<stem>.rds`) instead of `<country>_<timestamp>.rds`, and loads
  an existing matching cache directly instead of treating a fresh parse as
  authoritative when one is already present -- this decision now lives
  entirely in `CacheConnection` itself, so it applies uniformly regardless
  of caller.
* Added `cd2030_mcp_server()`, an optional (`mcptools`/`ellmer` `Suggests`)
  Model Context Protocol server exposing read-only tools -- data quality,
  coverage, inequality, mortality, service utilization, health system, and
  private-sector queries, plus report generation and coverage charts -- over
  an already-processed `.rds` cache, for use with LLM clients like Claude
  Desktop or Claude Code.
* Expanded the MCP server from 12 to 38 tools, covering every remaining
  read-only `CacheConnection` method (mutating setters and non-data methods
  remain deliberately unreachable).
* Standardized MCP tool naming/documentation against the CD2030 analytical
  framework's own vocabulary (`get_coverage_targets`, `get_continuum_of_care`
  renamed to match; DQA/mortality/health-system tool descriptions now cite
  the framework's official metric IDs and named indices), and added the
  three "Equity Assessment" equiplot tools (`get_equiplot_area`,
  `get_equiplot_wealth`, `get_equiplot_education`), bringing the total to 41.
* Fixed stray `print()` debug statements in `generate_report()`,
  `generate_coverage_data()`, and `generate_bayes_model()` that corrupted the
  MCP server's stdio JSON-RPC stream (stdout doubles as the wire protocol,
  so any incidental console output there breaks every client response).
* MCP tool results are now also capped by total cell count
  (`max_cells`, default 5000), not just row count: a row-only cap doesn't
  protect against a very wide table (e.g. `get_indicator_coverage` at
  district level, ~190 columns), where even a handful of rows produced a
  megabyte-scale response that crashed a live client connection.
* Six MCP tools (`get_overall_score`, `get_inequality`,
  `get_completeness_summary`, `get_outliers_summary`, `get_reporting_rate`,
  `get_service_utilization_summary`) now read `CacheConnection`'s cached
  active bindings (e.g. `reporting_rate_district`) instead of always calling
  the always-recomputing `calculate_*`/`compute_*` method, whenever no
  `region` filter is requested -- the exact case those bindings cover.
  Verified identical output to a direct recompute for all six.

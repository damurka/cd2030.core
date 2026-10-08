# cd2030.core and the Countdown 2030 Stata code

Where cd2030.core’s results can differ from the Countdown 2030 Stata
do-files (`0_import_data.do` … `5b_Mapping_districts.do`), and why. Bugs
found in the comparison are fixed (see NEWS, 1.3.8); what is left here
are choices, where the two do different but defensible things. Stata
line numbers refer to the do-files as reviewed.

## Different by choice

| Step | Stata | cd2030.core | Effect |
|----|----|----|----|
| Outlier tables (1a Table 2a/2b, 1d) | Each district-month is flagged; a missing value is never an outlier (`1a_checks.do` 292); Table 2a is the mean over district-months | Monthly values are summed over the level asked for before flagging (`1a_checks_outlier.R`); a missing month counts as 0 in the sum | Tables 2a/2b and the overall score differ where data are missing; national/admin-1 flags are on the aggregated series |
| Overall data quality score (1a Table 5) | 26 items, 20 of them outlier-related, then `trunc(mean)` (`1a_checks.do` 459-461) | 8 items (`score_components`, `methodology-defaults.R`), not truncated | Scores are not comparable between the two |
| Districts with reporting rate below the threshold (1a Table 1b, 1d) | A missing district-year counts as at or above the threshold (`1a_checks.do` 220-221, `1d_admin1_checks.do` 171) | Missing district-years are left out (`na.rm = TRUE`) | Differs where reporting rates are missing |
| Reporting rates at import | Kept as reported; rescaled from 0-1 to 0-100 only when some rate was missing (`0_import_data.do` 121) | Rounded to whole numbers; not rescaled | Rates near the 75% (adjustment) and 90% cut-offs can fall on the other side |
| National ratios (1a Table 3a/b) | Mean of the district ratios (`1a_checks.do` 389) | Ratio of the yearly sums | Moderate |
| Rounding | Outlier bounds and adjusted counts to integers | One decimal | Small, at the boundaries |
| Outlier bounds with no earlier year | Missing, so every value is flagged | Median and MAD fall back to the maximum, so nothing is flagged | Edge case: one year of data |
| Coverage thresholds (4a) | `> 80`, `> 90` | `>= 80`, `>= 90` | Small |
| Subnational ANC1/Penta1 denominators | National survey rates everywhere (`2_denominators.do` 668, 1173) | Each region’s own survey rates ([`get_national_rates()`](reference/countdown-pages.md)); needs regional survey data | Admin-1 and district ANC1/Penta1-based coverage, inequality and maps differ by design |
| Admin-1 maps (5) | Fixed classes (0/30/50/90, 0/5/10/15) | A continuous colour scale | Looks different, same values |
| Years and countries | Hard-coded (from 2019; 2023 as the last year; Tanzania and Ethiopia specifics) | `start_year` / `end_year` and the data’s own years | None when the same years are used |

## Not in cd2030.core

- District maps (`5b_Mapping_districts.do`):
  [`get_mapping_data()`](reference/get_mapping_data.md) stops below
  admin-1.
- 1d’s “% of district-months with a reporting rate of 90 or more” per
  admin-1.

## Bugs in the Stata code (cd2030.core does not copy them)

- `4a_subnational_equity.do` 66-67: the national value used for
  MADM/MRDM is the last year’s, for every year
  (`replace national_... = r(mean)` without `if year == ...`).
- `3_national.do` 15: `"dropout_penta3mcv1 "` has a trailing space, so
  that indicator cannot be chosen.
- `1c_adjustment.do` 126: the adjusted columns’ labels are in the wrong
  order; 120 saves whatever is in memory when option 3 is not chosen.
- `1a_checks.do` 451: `mat colnames missings` should be `missingsd`.
- `5_Mapping.do` 42 lists zerodose twice and leaves out
  dropout_penta1mcv1; `5b_Mapping_districts.do` 116-126 uses `if` (the
  first observation only) where it means `if` as a condition, so NAME_1
  is not made outside Tanzania.

Both compute `cov_instdeliveries_* = instlivebirths / totdeliv_*`; the
numerator should arguably be `ideliv` (the derived denominators already
use it).

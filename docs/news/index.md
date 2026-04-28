# Changelog

## EasyStat 2.0.0

### New Features

- Added
  [`easy_logistic_regression()`](https://itsmdivakaran.github.io/Easystat/reference/easy_logistic_regression.md)
  for binary logistic regression with odds ratios, approximate
  odds-ratio confidence intervals, likelihood-ratio model tests,
  McFadden pseudo-R2, and automated narrative reporting.

- Added richer supporting tables:

  - ANOVA now includes group descriptives, assumption checks, and Tukey
    post-hoc comparisons.
  - Chi-square tests now include observed contingency tables, expected
    counts, row percentages, column percentages, and total percentages.
  - Regression now includes ANOVA, diagnostic, and
    influential-observation tables.

- Added
  [`easy_wilcox()`](https://itsmdivakaran.github.io/Easystat/reference/easy_wilcox.md)
  and
  [`easy_kruskal()`](https://itsmdivakaran.github.io/Easystat/reference/easy_kruskal.md)
  for common non-parametric workflows.

- Added regression figures:
  [`easy_regression_diagnostics()`](https://itsmdivakaran.github.io/Easystat/reference/easy_regression_diagnostics.md)
  and
  [`easy_odds_ratio_plot()`](https://itsmdivakaran.github.io/Easystat/reference/easy_odds_ratio_plot.md).

- Added comprehensive descriptive statistics:
  [`easy_describe()`](https://itsmdivakaran.github.io/Easystat/reference/easy_describe.md)
  and
  [`easy_group_summary()`](https://itsmdivakaran.github.io/Easystat/reference/easy_group_summary.md)
  with 21 statistics per variable (mean, median, mode, SD, variance,
  skewness, kurtosis, normality test, CI, and more).

- Extended inferential test suite with four new functions:

  - [`easy_chisq()`](https://itsmdivakaran.github.io/Easystat/reference/easy_chisq.md):
    Chi-square test of independence and goodness-of-fit, with Cramér’s V
    effect size.
  - [`easy_ztest()`](https://itsmdivakaran.github.io/Easystat/reference/easy_ztest.md):
    One- and two-sample z-tests with Cohen’s d.
  - [`easy_ftest()`](https://itsmdivakaran.github.io/Easystat/reference/easy_ftest.md):
    Levene-style F-test for equality of variances via
    [`stats::var.test()`](https://rdrr.io/r/stats/var.test.html), with
    variance ratio CI.
  - [`easy_correlation()`](https://itsmdivakaran.github.io/Easystat/reference/easy_correlation.md):
    Pearson/Spearman/Kendall bivariate and pairwise matrix correlation
    with confidence intervals.

- New visualization functions (all return `easystat_result` objects with
  plain-language interpretations):

  - [`easy_histogram()`](https://itsmdivakaran.github.io/Easystat/reference/easy_histogram.md):
    distribution histogram with normal-curve overlay.
  - [`easy_boxplot()`](https://itsmdivakaran.github.io/Easystat/reference/easy_boxplot.md):
    grouped box-and-whisker plots with outlier marking.
  - [`easy_scatter()`](https://itsmdivakaran.github.io/Easystat/reference/easy_scatter.md):
    scatter plot with regression line and R-squared label.
  - [`easy_barplot()`](https://itsmdivakaran.github.io/Easystat/reference/easy_barplot.md):
    count or mean (+/- SE) bar charts with group support.
  - [`easy_qqplot()`](https://itsmdivakaran.github.io/Easystat/reference/easy_qqplot.md):
    Q-Q normality plot.
  - [`easy_density()`](https://itsmdivakaran.github.io/Easystat/reference/easy_density.md):
    kernel density curve, optionally grouped.
  - [`easy_correlation_heatmap()`](https://itsmdivakaran.github.io/Easystat/reference/easy_correlation_heatmap.md):
    annotated pairwise correlation heatmap.
  - [`easy_autoplot()`](https://itsmdivakaran.github.io/Easystat/reference/easy_autoplot.md):
    smart dispatcher that picks the right plot type for a given
    `easystat_result`.

- New theme:
  [`theme_easystat()`](https://itsmdivakaran.github.io/Easystat/reference/theme_easystat.md)
  — a professional ggplot2 theme and color system applied uniformly
  across all visualization functions.

- Word export:
  [`export_to_word()`](https://itsmdivakaran.github.io/Easystat/reference/export_to_word.md)
  creates a fully formatted `.docx` report (via `flextable` and
  `officer`) with title, authors, narrative, and tables.

### Improvements

- User-facing p-values now display as percentages rounded to 4 decimal
  places across result tables, plot summaries, and narrative text.
- Narrative Generator Module expanded with 15 conditional narrative
  templates covering all new test and plot types.
- All functions return a unified `easystat_result` S3 object with
  consistent fields: `test_type`, `formula_str`, `raw_model`,
  `coefficients_table`, `model_fit_table`, and `explanation`.
- HTML Viewer output (`print.easystat_result`) redesigned with improved
  typography and responsive layout.

------------------------------------------------------------------------

## EasyStat 1.0.0

- Initial release with
  [`easy_regression()`](https://itsmdivakaran.github.io/Easystat/reference/easy_regression.md),
  [`easy_ttest()`](https://itsmdivakaran.github.io/Easystat/reference/easy_ttest.md),
  [`easy_anova()`](https://itsmdivakaran.github.io/Easystat/reference/easy_anova.md),
  and basic [`print()`](https://rdrr.io/r/base/print.html) /
  [`summary()`](https://rdrr.io/r/base/summary.html) S3 methods.

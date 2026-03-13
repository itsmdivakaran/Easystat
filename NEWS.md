# EasyStat 2.0.0

## New Features

* Added comprehensive descriptive statistics: `easy_describe()` and
  `easy_group_summary()` with 21 statistics per variable (mean, median, mode,
  SD, variance, skewness, kurtosis, normality test, CI, and more).

* Extended inferential test suite with four new functions:
  - `easy_chisq()`: Chi-square test of independence and goodness-of-fit,
    with Cramer's V effect size.
  - `easy_ztest()`: One- and two-sample z-tests with Cohen's d.
  - `easy_ftest()`: Levene-style F-test for equality of variances via
    `stats::var.test()`, with variance ratio CI.
  - `easy_correlation()`: Pearson/Spearman/Kendall bivariate and pairwise
    matrix correlation with confidence intervals.

* New visualization functions (all return `easystat_result` objects with
  plain-language interpretations):
  - `easy_histogram()`: distribution histogram with normal-curve overlay.
  - `easy_boxplot()`: grouped box-and-whisker plots with outlier marking.
  - `easy_scatter()`: scatter plot with regression line and R-squared label.
  - `easy_barplot()`: count or mean (+/- SE) bar charts with group support.
  - `easy_qqplot()`: Q-Q normality plot.
  - `easy_density()`: kernel density curve, optionally grouped.
  - `easy_correlation_heatmap()`: annotated pairwise correlation heatmap.
  - `easy_autoplot()`: smart dispatcher that picks the right plot type
    for a given `easystat_result`.

* New theme: `theme_easystat()` — a professional ggplot2 theme and color
  system applied uniformly across all visualization functions.

* Word export: `export_to_word()` creates a fully formatted `.docx` report
  (via `flextable` and `officer`) with title, authors, narrative, and tables.

## Improvements

* Narrative Generator Module expanded with 15 conditional narrative templates
  covering all new test and plot types.
* All functions return a unified `easystat_result` S3 object with consistent
  fields: `test_type`, `formula_str`, `raw_model`, `coefficients_table`,
  `model_fit_table`, and `explanation`.
* HTML Viewer output (`print.easystat_result`) redesigned with improved
  typography and responsive layout.

---

# EasyStat 1.0.0

* Initial release with `easy_regression()`, `easy_ttest()`, `easy_anova()`,
  and basic `print()` / `summary()` S3 methods.

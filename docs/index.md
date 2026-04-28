# EasyStat

**Automated Statistical Analysis, Visualization, and Multi-Format
Narrative Reporting in R**

> **Authors:** Mr. Mahesh Divakaran & Dr. Gunjan Singh (Amity School of
> Applied Sciences, Amity University Lucknow) - Prof. Dr. Jayadevan
> Shreedharan (Gulf Medical University)

## Overview

EasyStat bridges the gap between statistical output and actionable
insight. A single function call delivers the statistical result, a
plain-language narrative interpretation, and publication-ready tables,
rendered in the RStudio Viewer, the R console, or Microsoft Word.

User-facing p-values are reported as percentages rounded to 4 decimal
places, while raw model objects still retain the original numeric
p-values for advanced use.

## Installation

``` r
# From CRAN (when available)
install.packages("EasyStat")

# Development version from GitHub
# install.packages("devtools")
devtools::install_github("itsmdivakaran/EasyStat")

# From local source
install.packages("path/to/EasyStat", repos = NULL, type = "source")
```

## Quick Start

``` r
library(EasyStat)

# Linear regression with narrative
easy_regression(mpg ~ wt + hp, data = mtcars)

# Logistic regression with odds ratios
easy_logistic_regression(am ~ mpg + wt, data = mtcars)

# t-test
easy_ttest(mpg ~ am, data = mtcars)

# One-way ANOVA
easy_anova(Sepal.Length ~ Species, data = iris)

# Descriptive statistics for multiple variables
easy_describe(mtcars, vars = c("mpg", "hp", "wt"))

# Correlation heatmap
easy_correlation_heatmap(mtcars, vars = c("mpg", "hp", "wt", "qsec", "drat"))

# Export any result to Word
result <- easy_logistic_regression(am ~ mpg + wt, data = mtcars)
export_to_word(result, file = "report.docx", title = "Transmission Model",
               author = "Mahesh Divakaran, Gunjan Singh, Jayadevan Shreedharan")
```

## Four-Step Pipeline

| Step | Module | Role |
|----|----|----|
| 1 | Core Statistical Engine | Wraps [`lm()`](https://rdrr.io/r/stats/lm.html), [`glm()`](https://rdrr.io/r/stats/glm.html), [`t.test()`](https://rdrr.io/r/stats/t.test.html), [`aov()`](https://rdrr.io/r/stats/aov.html), [`chisq.test()`](https://rdrr.io/r/stats/chisq.test.html), [`var.test()`](https://rdrr.io/r/stats/var.test.html), [`cor.test()`](https://rdrr.io/r/stats/cor.test.html) |
| 2 | Metric Extractor | Uses model summaries and `broom` helpers to extract p-values, effect sizes, CIs, and fit metrics |
| 3 | Narrative Generator Module | Applies conditional logic to produce plain-language explanations |
| 4 | Unified Result Object | Returns `easystat_result` S3 objects with tables, narrative, and optional plots |

## Function Reference

### Descriptive Statistics

| Function | Description |
|----|----|
| [`easy_describe()`](https://EasyStat.github.io/EasyStat/reference/easy_describe.md) | 21-statistic summary for one or more numeric variables |
| [`easy_group_summary()`](https://EasyStat.github.io/EasyStat/reference/easy_group_summary.md) | Stratified descriptives by a grouping factor |

### Regression Models

| Function | Model | Key Output |
|----|----|----|
| [`easy_regression()`](https://EasyStat.github.io/EasyStat/reference/easy_regression.md) | Linear regression | R-squared, ANOVA table, diagnostics, influential observations |
| [`easy_logistic_regression()`](https://EasyStat.github.io/EasyStat/reference/easy_logistic_regression.md) | Binary logistic regression | Odds ratios, OR CIs, classification table, McFadden pseudo-R2 |

### Inferential Tests

| Function | Test | Effect Size |
|----|----|----|
| [`easy_ttest()`](https://EasyStat.github.io/EasyStat/reference/easy_ttest.md) | Independent / one-sample t-test | Cohen’s d |
| [`easy_anova()`](https://EasyStat.github.io/EasyStat/reference/easy_anova.md) | One-way ANOVA with post-hoc context | eta-squared |
| [`easy_chisq()`](https://EasyStat.github.io/EasyStat/reference/easy_chisq.md) | Chi-square independence and GOF | Cramer’s V |
| [`easy_ztest()`](https://EasyStat.github.io/EasyStat/reference/easy_ztest.md) | One- and two-sample z-test | Cohen’s d |
| [`easy_ftest()`](https://EasyStat.github.io/EasyStat/reference/easy_ftest.md) | F-test for equality of variances | Variance ratio + CI |
| [`easy_correlation()`](https://EasyStat.github.io/EasyStat/reference/easy_correlation.md) | Pearson / Spearman / Kendall correlation and matrix | r, r-squared |
| [`easy_wilcox()`](https://EasyStat.github.io/EasyStat/reference/easy_wilcox.md) | Wilcoxon rank-sum / signed-rank test | Median comparison + CI |
| [`easy_kruskal()`](https://EasyStat.github.io/EasyStat/reference/easy_kruskal.md) | Kruskal-Wallis test | Rank-based eta-squared |

### Visualizations

| Function | Plot type |
|----|----|
| [`easy_histogram()`](https://EasyStat.github.io/EasyStat/reference/easy_histogram.md) | Histogram with normal-curve overlay |
| [`easy_boxplot()`](https://EasyStat.github.io/EasyStat/reference/easy_boxplot.md) | Grouped box-and-whisker plot |
| [`easy_scatter()`](https://EasyStat.github.io/EasyStat/reference/easy_scatter.md) | Scatter plot with regression line and R-squared |
| [`easy_barplot()`](https://EasyStat.github.io/EasyStat/reference/easy_barplot.md) | Count or mean (+/- SE) bar chart |
| [`easy_qqplot()`](https://EasyStat.github.io/EasyStat/reference/easy_qqplot.md) | Q-Q normality plot |
| [`easy_density()`](https://EasyStat.github.io/EasyStat/reference/easy_density.md) | Kernel density curve, optionally grouped |
| [`easy_correlation_heatmap()`](https://EasyStat.github.io/EasyStat/reference/easy_correlation_heatmap.md) | Annotated pairwise correlation heatmap |
| [`easy_regression_diagnostics()`](https://EasyStat.github.io/EasyStat/reference/easy_regression_diagnostics.md) | Fitted-vs-residuals diagnostic plot |
| [`easy_odds_ratio_plot()`](https://EasyStat.github.io/EasyStat/reference/easy_odds_ratio_plot.md) | Logistic regression odds-ratio plot |
| [`easy_autoplot()`](https://EasyStat.github.io/EasyStat/reference/easy_autoplot.md) | Smart dispatcher that picks the right plot for a result |

### Theme & Export

| Function | Description |
|----|----|
| [`theme_easystat()`](https://EasyStat.github.io/EasyStat/reference/theme_easystat.md) | Consistent ggplot2 theme for all plots |
| [`export_to_word()`](https://EasyStat.github.io/EasyStat/reference/export_to_word.md) | Formatted `.docx` report with flextable and officer |

## Output Modes

| Mode | Trigger |
|----|----|
| RStudio HTML Viewer | Auto-detected in interactive sessions |
| Console | Scripts, terminals, non-interactive sessions |
| Word `.docx` | [`export_to_word()`](https://EasyStat.github.io/EasyStat/reference/export_to_word.md) |

## Running the Smoke Test

``` r
source(system.file("smoke_test.R", package = "EasyStat"))
```

## Citation

If you use EasyStat in your research, please cite:

> Divakaran M., Singh G., & Shreedharan J. (2026). *EasyStat: Automated
> Statistical Analysis, Visualization and Multi-Format Narrative
> Reporting in R* (Version 2.0.0). Amity University Lucknow & Gulf
> Medical University.
> <https://itsmdivakaran.github.io/Easystat/index.html>

## License

MIT (c) 2026 EasyStat Authors. See
[LICENSE](https://EasyStat.github.io/EasyStat/LICENSE) for details.

# EasyStat <img src="man/figures/logo.svg" align="right" height="139" alt="EasyStat logo"/>

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/EasyStat)](https://CRAN.R-project.org/package=EasyStat)
[![R-CMD-check](https://github.com/itsmdivakaran/Easystat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/itsmdivakaran/Easystat/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-blue)](https://itsmdivakaran.github.io/Easystat/)
<!-- badges: end -->

**Automated Statistical Analysis, Visualization, and Multi-Format Narrative Reporting in R**

> **Authors:** Mr. Mahesh Divakaran & Dr. Gunjan Singh (Amity School of Applied Sciences, Amity University Lucknow) - Prof. Dr. Jayadevan Shreedharan (Gulf Medical University)

## Overview

EasyStat bridges the gap between statistical output and actionable insight. A single function call delivers the statistical result, a plain-language narrative interpretation, and publication-ready tables, rendered in the RStudio Viewer, the R console, or Microsoft Word.

User-facing p-values are reported as percentages rounded to 4 decimal places, while raw model objects still retain the original numeric p-values for advanced use.

## Installation

```r
# From CRAN (when available)
install.packages("EasyStat")

# Development version from GitHub
# install.packages("devtools")
devtools::install_github("itsmdivakaran/Easystat")

# From local source
install.packages("path/to/EasyStat", repos = NULL, type = "source")
```

## Quick Start

```r
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
|------|--------|------|
| 1 | Core Statistical Engine | Wraps `lm()`, `glm()`, `t.test()`, `aov()`, `chisq.test()`, `var.test()`, `cor.test()` |
| 2 | Metric Extractor | Uses model summaries and `broom` helpers to extract p-values, effect sizes, CIs, and fit metrics |
| 3 | Narrative Generator Module | Applies conditional logic to produce plain-language explanations |
| 4 | Unified Result Object | Returns `easystat_result` S3 objects with tables, narrative, and optional plots |

## Function Reference

### Descriptive Statistics

| Function | Description |
|----------|-------------|
| `easy_describe()` | 21-statistic summary for one or more numeric variables |
| `easy_group_summary()` | Stratified descriptives by a grouping factor |

### Regression Models

| Function | Model | Key Output |
|----------|-------|------------|
| `easy_regression()` | Linear regression | R-squared, ANOVA table, diagnostics, influential observations |
| `easy_logistic_regression()` | Binary logistic regression | Odds ratios, OR CIs, classification table, McFadden pseudo-R2 |

### Inferential Tests

| Function | Test | Effect Size |
|----------|------|-------------|
| `easy_ttest()` | Independent / one-sample t-test | Cohen's d |
| `easy_anova()` | One-way ANOVA with post-hoc context | eta-squared |
| `easy_chisq()` | Chi-square independence and GOF | Cramér's V |
| `easy_ztest()` | One- and two-sample z-test | Cohen's d |
| `easy_ftest()` | F-test for equality of variances | Variance ratio + CI |
| `easy_correlation()` | Pearson / Spearman / Kendall correlation and matrix | r, r-squared |
| `easy_wilcox()` | Wilcoxon rank-sum / signed-rank test | Median comparison + CI |
| `easy_kruskal()` | Kruskal-Wallis test | Rank-based eta-squared |

### Visualizations

| Function | Plot type |
|----------|-----------|
| `easy_histogram()` | Histogram with normal-curve overlay |
| `easy_boxplot()` | Grouped box-and-whisker plot |
| `easy_scatter()` | Scatter plot with regression line and R-squared |
| `easy_barplot()` | Count or mean (+/- SE) bar chart |
| `easy_qqplot()` | Q-Q normality plot |
| `easy_density()` | Kernel density curve, optionally grouped |
| `easy_correlation_heatmap()` | Annotated pairwise correlation heatmap |
| `easy_regression_diagnostics()` | Fitted-vs-residuals diagnostic plot |
| `easy_odds_ratio_plot()` | Logistic regression odds-ratio plot |
| `easy_autoplot()` | Smart dispatcher that picks the right plot for a result |

### Theme & Export

| Function | Description |
|----------|-------------|
| `theme_easystat()` | Consistent ggplot2 theme for all plots |
| `export_to_word()` | Formatted `.docx` report with flextable and officer |

## Output Modes

| Mode | Trigger |
|------|---------|
| RStudio HTML Viewer | Auto-detected in interactive sessions |
| Console | Scripts, terminals, non-interactive sessions |
| Word `.docx` | `export_to_word()` |

## Running the Smoke Test

```r
source(system.file("smoke_test.R", package = "EasyStat"))
```

## Citation

If you use EasyStat in your research, please cite:

> Divakaran M., Singh G., & Shreedharan J. (2026). *EasyStat: Automated Statistical Analysis, Visualization and Multi-Format Narrative Reporting in R* (Version 2.0.0). Amity University Lucknow & Gulf Medical University. <https://itsmdivakaran.github.io/Easystat/index.html>

## License

MIT (c) 2026 EasyStat Authors. See [LICENSE](LICENSE) for details.

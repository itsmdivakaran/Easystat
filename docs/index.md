# MIT 0a9 2026 EasyStat Authors. See [LICENSE](https://EasyStat.github.io/EasyStat/LICENSE) for details.

\<\<\<\<\<\<\< HEAD \# EasyStat ![EasyStat
logo](reference/figures/logo.svg)

**Automated Statistical Analysis, Visualization, and Multi-Format
Narrative Reporting in R**

> **Authors:** Mr. Mahesh Divakaran & Dr. Gunjan Singh (Amity School of
> Applied Sciences, Amity University Lucknow) — Prof. Dr. Jayadevan
> Shreedharan (Gulf Medical University)

------------------------------------------------------------------------

## Overview

EasyStat bridges the gap between complex statistical output and
actionable insight. A single function call delivers three outputs
simultaneously: the statistical result, a plain-language narrative
interpretation, and publication-ready tables — all rendered
automatically in the RStudio Viewer (HTML), the R console (ASCII), or
exported directly to Microsoft Word.

The core innovation is the **Narrative Generator Module**: conditional
logic applied to p-values, effect sizes, and model-fit metrics produces
statistically sound, human-readable explanations without any manual
writing.

------------------------------------------------------------------------

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

------------------------------------------------------------------------

## Quick Start

``` r
library(EasyStat)

# Linear regression with narrative
easy_regression(mpg ~ wt + hp, data = mtcars)

# t-Test
easy_ttest(mpg ~ am, data = mtcars)

# One-way ANOVA
easy_anova(Sepal.Length ~ Species, data = iris)

# Descriptive statistics for multiple variables
easy_describe(mtcars, vars = c("mpg", "hp", "wt"))

# Correlation heatmap
easy_correlation_heatmap(mtcars, vars = c("mpg", "hp", "wt", "qsec", "drat"))

# Export any result to Word
result <- easy_regression(mpg ~ wt, data = mtcars)
export_to_word(result, file = "report.docx", title = "Fuel Economy Study",
               author = "Mahesh Divakaran, Gunjan Singh, Jayadevan Shreedharan")
```

------------------------------------------------------------------------

## Four-Step Pipeline

| Step | Module | Role |
|----|----|----|
| 1 | **Core Statistical Engine** | Wraps [`lm()`](https://rdrr.io/r/stats/lm.html), [`t.test()`](https://rdrr.io/r/stats/t.test.html), [`aov()`](https://rdrr.io/r/stats/aov.html), [`chisq.test()`](https://rdrr.io/r/stats/chisq.test.html), [`var.test()`](https://rdrr.io/r/stats/var.test.html), [`cor.test()`](https://rdrr.io/r/stats/cor.test.html) |
| 2 | **Metric Extractor** | Uses [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html) / [`broom::glance()`](https://generics.r-lib.org/reference/glance.html) to extract p-values, effect sizes, CIs |
| 3 | **Narrative Generator Module** *(core invention)* | Applies conditional logic to produce plain-language explanations |
| 4 | **Unified Result Object** | Returns `easystat_result` S3 with tables, narrative, and optional plot |

------------------------------------------------------------------------

## Function Reference

### Descriptive Statistics

| Function | Description |
|----|----|
| [`easy_describe()`](https://EasyStat.github.io/EasyStat/reference/easy_describe.md) | 21-statistic summary for one or more numeric variables |
| [`easy_group_summary()`](https://EasyStat.github.io/EasyStat/reference/easy_group_summary.md) | Stratified descriptives by a grouping factor |

### Inferential Tests

| Function | Test | Effect Size |
|----|----|----|
| [`easy_regression()`](https://EasyStat.github.io/EasyStat/reference/easy_regression.md) | Linear regression (OLS) | R0b2, adjusted R0b2 |
| [`easy_ttest()`](https://EasyStat.github.io/EasyStat/reference/easy_ttest.md) | Independent / one-sample t-test | Cohen’s d |
| [`easy_anova()`](https://EasyStat.github.io/EasyStat/reference/easy_anova.md) | One-way ANOVA with post-hoc context | 3b70b2 (eta-squared) |
| [`easy_chisq()`](https://EasyStat.github.io/EasyStat/reference/easy_chisq.md) | Chi-square independence & GOF | Cram0e9r’s V |
| [`easy_ztest()`](https://EasyStat.github.io/EasyStat/reference/easy_ztest.md) | One- and two-sample z-test | Cohen’s d |
| [`easy_ftest()`](https://EasyStat.github.io/EasyStat/reference/easy_ftest.md) | F-test for equality of variances | Variance ratio + CI |
| [`easy_correlation()`](https://EasyStat.github.io/EasyStat/reference/easy_correlation.md) | Pearson / Spearman / Kendall correlation & matrix | r, r0b2 |

### Visualizations

| Function | Plot type |
|----|----|
| [`easy_histogram()`](https://EasyStat.github.io/EasyStat/reference/easy_histogram.md) | Histogram with normal-curve overlay |
| [`easy_boxplot()`](https://EasyStat.github.io/EasyStat/reference/easy_boxplot.md) | Grouped box-and-whisker plot |
| [`easy_scatter()`](https://EasyStat.github.io/EasyStat/reference/easy_scatter.md) | Scatter plot with regression line and R0b2 |
| [`easy_barplot()`](https://EasyStat.github.io/EasyStat/reference/easy_barplot.md) | Count or mean (0b1 SE) bar chart |
| [`easy_qqplot()`](https://EasyStat.github.io/EasyStat/reference/easy_qqplot.md) | Q-Q normality plot |
| [`easy_density()`](https://EasyStat.github.io/EasyStat/reference/easy_density.md) | Kernel density curve, optionally grouped |
| [`easy_correlation_heatmap()`](https://EasyStat.github.io/EasyStat/reference/easy_correlation_heatmap.md) | Annotated pairwise correlation heatmap |
| [`easy_autoplot()`](https://EasyStat.github.io/EasyStat/reference/easy_autoplot.md) | Smart dispatcher — picks the right plot for a result |

### Theme & Export

| Function | Description |
|----|----|
| [`theme_easystat()`](https://EasyStat.github.io/EasyStat/reference/theme_easystat.md) | Consistent ggplot2 theme for all plots |
| [`export_to_word()`](https://EasyStat.github.io/EasyStat/reference/export_to_word.md) | Formatted `.docx` report (flextable + officer) |

------------------------------------------------------------------------

## Output Modes

| Mode | Trigger |
|----|----|
| **RStudio HTML Viewer** | Auto-detected in interactive sessions |
| **Console (ASCII)** | Scripts, terminals, non-interactive sessions |
| **Word (.docx)** | [`export_to_word()`](https://EasyStat.github.io/EasyStat/reference/export_to_word.md) — one call, full report |

------------------------------------------------------------------------

## Running the Smoke Test

``` r
source(system.file("smoke_test.R", package = "EasyStat"))
```

Runs 25+ assertions across all analysis, visualization, and export
functions.

------------------------------------------------------------------------

## Citation

If you use EasyStat in your research, please cite:

> Divakaran M., Singh G., & Shreedharan J. (2026). *EasyStat: Automated
> Statistical Analysis, Visualization and Multi-Format Narrative
> Reporting in R* (Version 2.0.0). Amity University Lucknow & Gulf
> Medical University.
> <https://itsmdivakaran.github.io/Easystat/index.html>

------------------------------------------------------------------------

## License

# Easystat

> > > > > > > d4ca618a4a9a9eac7a1d157ce7b46df34e598e08

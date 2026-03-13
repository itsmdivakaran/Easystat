# Grouped Boxplot with Outlier Detection

Produces a boxplot for one variable, optionally grouped by a factor.
Adds a jittered dot overlay, labels each group's median, and highlights
outliers.

## Usage

``` r
easy_boxplot(formula, data, fill_palette = NULL, notch = FALSE, title = NULL)
```

## Arguments

- formula:

  A formula: `outcome ~ group` for grouped, or a bare column name /
  numeric vector for a single-variable boxplot.

- data:

  A data frame.

- fill_palette:

  Character vector of fill colours. Default EasyStat palette.

- notch:

  Logical; draw notched boxes? Default `FALSE`.

- title:

  Custom plot title.

## Value

An `"easystat_result"` object with `plot_object`.

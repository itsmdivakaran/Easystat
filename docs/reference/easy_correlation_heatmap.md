# Correlation Matrix Heatmap

Computes pairwise correlations and displays them as a color-coded
heatmap, annotating each cell with the correlation coefficient and a
significance star.

## Usage

``` r
easy_correlation_heatmap(data, vars = NULL, method = "pearson", title = NULL)
```

## Arguments

- data:

  A data frame.

- vars:

  Character vector of numeric column names. Default all numerics.

- method:

  Correlation method: `"pearson"` (default), `"spearman"`.

- title:

  Custom plot title.

## Value

An `"easystat_result"` object with `plot_object`.

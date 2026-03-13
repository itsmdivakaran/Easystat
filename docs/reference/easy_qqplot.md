# Normal Q-Q Plot with Shapiro-Wilk Annotation

Plots sample quantiles against theoretical normal quantiles and
annotates the Shapiro-Wilk p-value. Deviations from the diagonal
indicate non-normality.

## Usage

``` r
easy_qqplot(x, data = NULL, title = NULL)
```

## Arguments

- x:

  Column name or numeric vector.

- data:

  A data frame (required when `x` is a column name).

- title:

  Custom plot title.

## Value

An `"easystat_result"` object with `plot_object`.

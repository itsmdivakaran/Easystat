# Annotated Histogram with Normal Curve Overlay

Draws a histogram of a numeric variable, overlays a fitted normal
density curve, and annotates the plot with the mean, median, and
standard deviation. Normality is assessed via the Shapiro-Wilk test, and
the result is displayed in the subtitle.

## Usage

``` r
easy_histogram(
  x,
  data = NULL,
  bins = NULL,
  fill_color = NULL,
  show_normal = TRUE,
  title = NULL
)
```

## Arguments

- x:

  Character column name OR a numeric vector.

- data:

  A data frame (required when `x` is a column name).

- bins:

  Number of histogram bins. Default `NULL` (auto).

- fill_color:

  Bar fill colour. Default EasyStat primary blue.

- show_normal:

  Logical; overlay normal curve? Default `TRUE`.

- title:

  Custom plot title. Default auto-generated.

## Value

An `"easystat_result"` object with `plot_object`.

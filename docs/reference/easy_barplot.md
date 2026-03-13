# Annotated Bar Chart

Creates a frequency bar chart for categorical variables, or a
mean-and-error bar chart for numeric outcomes grouped by a factor.

## Usage

``` r
easy_barplot(
  x,
  data,
  group_by = NULL,
  stat = c("count", "mean"),
  fill_palette = NULL,
  title = NULL
)
```

## Arguments

- x:

  Column name of the variable to plot.

- data:

  A data frame.

- group_by:

  Optional grouping column for grouped frequency bars.

- stat:

  `"count"` (default) for frequency, or `"mean"` for mean ± SE bars.

- fill_palette:

  Color palette vector. Default EasyStat palette.

- title:

  Custom plot title.

## Value

An `"easystat_result"` object with `plot_object`.

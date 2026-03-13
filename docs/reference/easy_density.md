# Kernel Density Plot with Optional Group Overlay

Draws a smooth kernel density estimate for a numeric variable. If a
grouping variable is provided, separate overlapping density curves are
drawn per group.

## Usage

``` r
easy_density(x, data = NULL, group_by = NULL, fill_alpha = 0.35, title = NULL)
```

## Arguments

- x:

  Column name or numeric vector.

- data:

  A data frame.

- group_by:

  Optional grouping column for multi-group densities.

- fill_alpha:

  Alpha for filled area. Default `0.35`.

- title:

  Custom plot title.

## Value

An `"easystat_result"` object with `plot_object`.

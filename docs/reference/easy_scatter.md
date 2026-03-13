# Scatter Plot with Regression Line and Correlation Annotation

Draws a scatter plot for two numeric variables, overlays a linear
regression line with confidence band, and annotates the Pearson r and
p-value.

## Usage

``` r
easy_scatter(
  formula,
  data,
  color_by = NULL,
  smooth = TRUE,
  ellipse = TRUE,
  title = NULL
)
```

## Arguments

- formula:

  A formula: `y ~ x`.

- data:

  A data frame.

- color_by:

  Optional column name to colour points by a third variable.

- smooth:

  Logical; show regression line? Default `TRUE`.

- ellipse:

  Logical; draw a 95% data ellipse? Default `TRUE`.

- title:

  Custom plot title.

## Value

An `"easystat_result"` object with `plot_object`.

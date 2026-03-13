# Print an EasyStat Result Object

Automatically renders an `easystat_result` object. In an interactive
RStudio session the HTML Viewer is used; otherwise clean ASCII tables
and the plain-language narrative are written to the console.

## Usage

``` r
# S3 method for class 'easystat_result'
print(x, viewer = NULL, ...)
```

## Arguments

- x:

  An object of class `"easystat_result"`.

- viewer:

  Logical. Force HTML Viewer output (`TRUE`) or console output
  (`FALSE`). Default `NULL` auto-detects.

- ...:

  Currently ignored.

## Value

`x` invisibly.

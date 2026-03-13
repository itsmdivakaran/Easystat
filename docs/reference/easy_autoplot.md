# Automatically Plot an EasyStat Result

Chooses the most appropriate plot type based on the `test_type` of an
`easystat_result` object and renders it.

## Usage

``` r
easy_autoplot(result, data = NULL, ...)
```

## Arguments

- result:

  An `"easystat_result"` object.

- data:

  The original data frame (required for some plot types).

- ...:

  Additional arguments passed to the underlying plot function.

## Value

An `"easystat_result"` plot object, invisibly.

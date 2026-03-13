# Export an EasyStat Result to a Formatted Microsoft Word Document

Takes a unified `easystat_result` object and writes a fully formatted
`.docx` report using the `flextable` and `officer` packages. The report
contains a title page header, the plain-language narrative, both
statistical tables rendered as professional `flextable` objects, and a
footer with metadata. All of this is produced in a single function call.

## Usage

``` r
export_to_word(
  result,
  file = "EasyStat_Report.docx",
  title = NULL,
  author = "EasyStat"
)
```

## Arguments

- result:

  An object of class `"easystat_result"` as returned by
  [`easy_regression`](https://EasyStat.github.io/EasyStat/reference/easy_regression.md),
  [`easy_ttest`](https://EasyStat.github.io/EasyStat/reference/easy_ttest.md),
  or
  [`easy_anova`](https://EasyStat.github.io/EasyStat/reference/easy_anova.md).

- file:

  Character string. Path to the output `.docx` file. Defaults to
  `"EasyStat_Report.docx"` in the current working directory.

- title:

  Character string. Report title printed at the top of the document. If
  `NULL` (default) a title is auto-generated from the test type.

- author:

  Character string. Author name(s) for the report header. Default
  `"EasyStat"`.

## Value

The `file` path invisibly. The `.docx` file is written to disk as a
side-effect.

## Examples

``` r
if (FALSE) { # \dontrun{
  result <- easy_regression(mpg ~ wt + hp, data = mtcars)
  export_to_word(result, file = tempfile(fileext = ".docx"),
                author = "Mr. Mahesh Divakaran")
} # }
```

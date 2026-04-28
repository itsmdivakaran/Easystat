# Run an Independent-Samples t-Test with Automated Narrative Reporting

Executes a two-sample (or one-sample) t-test using
[`stats::t.test()`](https://rdrr.io/r/stats/t.test.html), extracts key
metrics via `broom`, and generates a plain-language narrative via the
Narrative Generator Module.

## Usage

``` r
easy_ttest(
  x,
  y = NULL,
  data = NULL,
  mu = 0,
  var.equal = FALSE,
  conf.level = 0.95,
  alpha = 0.05
)
```

## Arguments

- x:

  A numeric vector, OR a formula of the form `outcome ~ group` when
  `data` is provided.

- y:

  A numeric vector (second group) when `x` is not a formula. Ignored
  when `x` is a formula.

- data:

  A data frame. Required when `x` is a formula.

- mu:

  Null hypothesis value for the mean (one-sample test). Default `0`.

- var.equal:

  Logical; assume equal variances? Default `FALSE` (Welch).

- conf.level:

  Confidence level. Default `0.95`.

- alpha:

  Significance threshold for narrative. Default `0.05`.

## Value

An object of class `"easystat_result"` with:

- `test_type`:

  Character: `"ttest"`

- `formula_str`:

  Description of the comparison

- `raw_model`:

  The raw `htest` object

- `coefficients_table`:

  Group means and confidence interval

- `model_fit_table`:

  t-statistic, df, and p-value

- `explanation`:

  Plain-language narrative string

## Examples

``` r
result <- easy_ttest(mpg ~ am, data = mtcars)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: TTEST
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>          Metric Label    Value
#>  Mean (Group 1)     0  17.1474
#>  Mean (Group 2)     1  24.3923
#>  95% CI (lower)     - -11.2802
#>  95% CI (upper)     -  -3.2097
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>              Metric   Value
#>         t-statistic -3.7671
#>  Degrees of Freedom   18.33
#>             p-value 0.1374%
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> INDEPENDENT-SAMPLES t-TEST Comparison: mpg ~ am
#> 
#> An independent-samples t-test revealed a statistically significant (p =
#>   0.1374%) difference between the two groups (t(18.33) = -3.767). The mean
#>   for '0' was 17.1474 and the mean for '1' was 24.3923. The 95% confidence
#>   interval for the difference in means ranged from -11.2802 to -3.2097. These
#>   results provide statistically significant evidence that '0' and '1' differ
#>   meaningfully on the measured variable.
#> 
#> ================================================================================
#> 
```

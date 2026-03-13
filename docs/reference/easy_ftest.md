# F-Test for Equality of Variances with Automated Narrative Reporting

Performs an F-test to compare the variances of two independent groups
using [`stats::var.test()`](https://rdrr.io/r/stats/var.test.html),
extracts the F-statistic, degrees of freedom, p-value, variance ratio,
and confidence interval, and generates a plain-language narrative that
includes a practical recommendation for downstream t-test selection
(equal vs. unequal variances).

## Usage

``` r
easy_ftest(
  x,
  y = NULL,
  data = NULL,
  ratio = 1,
  alternative = "two.sided",
  conf_level = 0.95,
  alpha = 0.05
)
```

## Arguments

- x:

  A numeric vector (Group 1), OR a formula `outcome ~ group`.

- y:

  A numeric vector (Group 2). Ignored when `x` is a formula.

- data:

  A data frame. Required when `x` is a formula.

- ratio:

  Hypothesised ratio of variances under H0. Default `1`.

- alternative:

  `"two.sided"` (default), `"less"`, or `"greater"`.

- conf_level:

  Confidence level for the variance ratio CI. Default `0.95`.

- alpha:

  Significance threshold for narrative. Default `0.05`.

## Value

An `"easystat_result"` object.

## Examples

``` r
result <- easy_ftest(mpg ~ am, data = mtcars)
#> Multiple parameters; naming those columns num.df and den.df.
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: FTEST
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>                Metric     Value
#>          Variance — 0 14.699298
#>          Variance — 1 38.025769
#>                SD — 0  3.833966
#>                SD — 1  6.166504
#>                 n — 0 19.000000
#>                 n — 1 13.000000
#>    Variance Ratio (F)  0.386561
#>  95% CI lower (ratio)  0.124372
#>  95% CI upper (ratio)  1.070343
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>          Metric               Value
#>     F-statistic              0.3866
#>    Numerator df                  18
#>  Denominator df                  12
#>         p-value             0.06691
#>     Alternative           two.sided
#>      Conclusion Variances are EQUAL
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> F-TEST FOR EQUALITY OF VARIANCES Comparison: mpg ~ am
#> 
#> An F-test for equality of variances found not statistically significant (p =
#>   0.0669) evidence of a difference in variance between the two groups (F(18,
#>   12) = 0.3866). The ratio of variances is 0.3866. The 95% CI for the
#>   variance ratio is [0.1244, 1.0703]. IMPLICATION: The assumption of equal
#>   variances (homoscedasticity) is SUPPORTED. Both the classical t-test and
#>   Welch's t-test are appropriate.
#> 
#> ================================================================================
#> 
```

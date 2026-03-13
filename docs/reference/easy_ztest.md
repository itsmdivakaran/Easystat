# One-Sample and Two-Sample Z-Tests with Automated Narrative Reporting

Performs a z-test using the normal distribution. When the population
standard deviation (`sigma`) is not provided, the sample SD is used
(valid for large samples, n \\\geq\\ 30, by the Central Limit Theorem).
Key metrics — z-statistic, p-value, confidence interval, and Cohen's d —
are extracted and fed to the Narrative Generator Module.

## Usage

``` r
easy_ztest(
  x,
  y = NULL,
  data = NULL,
  mu = 0,
  sigma = NULL,
  sigma2 = NULL,
  alternative = "two.sided",
  conf_level = 0.95,
  alpha = 0.05
)
```

## Arguments

- x:

  A numeric vector (Group 1), OR a formula `outcome ~ group` for a
  two-sample test when `data` is provided.

- y:

  A numeric vector (Group 2) for a two-sample test. Ignored when `x` is
  a formula.

- data:

  A data frame. Required when `x` is a formula.

- mu:

  Hypothesised population mean (one-sample) or mean difference
  (two-sample). Default `0`.

- sigma:

  Known population SD for Group 1 (or the single group). If `NULL`
  (default), the sample SD is used.

- sigma2:

  Known population SD for Group 2. If `NULL`, uses the sample SD of
  Group 2.

- alternative:

  `"two.sided"` (default), `"less"`, or `"greater"`.

- conf_level:

  Confidence level. Default `0.95`.

- alpha:

  Significance threshold for narrative. Default `0.05`.

## Value

An `"easystat_result"` object.

## Examples

``` r
# One-sample z-test (large n, CLT)
result <- easy_ztest(mtcars$mpg, mu = 20)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: ZTEST
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>                    Metric     Value
#>  Sample mean (mtcars$mpg) 20.090625
#>    Hypothesised mean (μ₀) 20.000000
#>           Mean difference  0.090625
#>              95% CI lower 18.002432
#>              95% CI upper 22.178818
#>           SD used (sigma)  6.026948
#>            Standard Error  1.065424
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>             Metric                 Value
#>        z-statistic                0.0851
#>            p-value                0.9322
#>        Alternative             two.sided
#>          Cohen's d                 0.015
#>  Effect size class negligible (d < 0.20)
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> Z-TEST Comparison: One-sample test
#> 
#> A one-sample z-test found not statistically significant (p = 0.9322) evidence
#>   that the sample mean (20.0906) differs from the hypothesised population
#>   mean of 20 (z = 0.085). The standardised effect size (Cohen's d = 0.015) is
#>   classified as negligible (d < 0.20). The 95% CI for the population mean is
#>   [18.0024, 22.1788].
#> 
#> ================================================================================
#> 

# Two-sample z-test via formula
result <- easy_ztest(mpg ~ am, data = mtcars)
#> Warning: n < 30 and sigma unknown: z-test assumes CLT (large-sample approximation). Consider t-test instead.
#> Warning: Group 2: n < 30 and sigma unknown. Using CLT approximation.
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: ZTEST
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>           Metric      Value
#>         Mean — 0  17.147368
#>         Mean — 1  24.392308
#>  Mean difference  -7.244939
#>     95% CI lower -11.014346
#>     95% CI upper  -3.475532
#>           SD (0)   3.833966
#>           SD (1)   6.166504
#>            n (0)  19.000000
#>            n (1)  13.000000
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>             Metric            Value
#>        z-statistic          -3.7671
#>            p-value        0.0001651
#>        Alternative        two.sided
#>          Cohen's d          -1.4779
#>  Effect size class large (d ≥ 0.80)
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> Z-TEST Comparison: mpg ~ am
#> 
#> A two-sample z-test revealed a highly statistically significant (p < 0.001)
#>   difference between the two group means (z = -3.767). Mean₁ = 17.1474, Mean₂
#>   = 24.3923. The standardised effect size (Cohen's d = 1.4779) is classified
#>   as large (d ≥ 0.80). The 95% CI for the mean difference is [-11.0143,
#>   -3.4755].
#> 
#> ================================================================================
#> 
```

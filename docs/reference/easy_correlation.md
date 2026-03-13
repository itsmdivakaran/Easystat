# Correlation Analysis with Automated Narrative Reporting

Computes bivariate or pairwise correlations (Pearson, Spearman, or
Kendall) with significance tests and confidence intervals. For two
variables a full narrative is generated; for multiple variables a
correlation matrix is returned with a summary digest.

## Usage

``` r
easy_correlation(
  x,
  y = NULL,
  data = NULL,
  vars = NULL,
  method = "pearson",
  conf_level = 0.95,
  alpha = 0.05
)
```

## Arguments

- x:

  A numeric vector, a data frame, OR a formula `~ x + y`.

- y:

  A numeric vector (paired with `x`). Ignored when `x` is a formula or
  data frame.

- data:

  A data frame. Required when `x` is a formula.

- vars:

  Character vector of column names when `x` is a data frame and pairwise
  analysis is desired. Default `NULL` = all numeric cols.

- method:

  Correlation method: `"pearson"` (default), `"spearman"`, or
  `"kendall"`.

- conf_level:

  Confidence level for Pearson CI. Default `0.95`.

- alpha:

  Significance threshold for narrative. Default `0.05`.

## Value

An `"easystat_result"` object.

## Examples

``` r
result <- easy_correlation(~ mpg + wt, data = mtcars)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: CORRELATION
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>                  Metric     Value
#>             r (Pearson) -0.867659
#>  r² (shared variance %)    75.28%
#>            95% CI lower -0.933826
#>            95% CI upper -0.744087
#>             t-statistic    -9.559
#>         n (valid pairs)        32
#>        Regression slope -0.140862
#>    Regression intercept  6.047255
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>                Metric            Value
#>               p-value          < 1e-04
#>  Correlation strength           strong
#>             Direction         Negative
#>     Effect size class large (d ≥ 0.80)
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> CORRELATION ANALYSIS (Pearson)
#> 
#> A Pearson correlation analysis revealed a strong negative correlation between
#>   the two variables (r = -0.8677), which is highly statistically significant
#>   (p < 0.001). The coefficient of determination (r² = 0.7528) indicates that
#>   approximately 75.3% of the variance in one variable is shared with the
#>   other. The 95% confidence interval for the correlation coefficient is
#>   [-0.9338, -0.7441]. This strong relationship may have meaningful practical
#>   implications and warrants further investigation.
#> 
#> ================================================================================
#> 

result <- easy_correlation(mtcars, vars = c("mpg", "hp", "wt", "disp"))
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: CORRELATION_MATRIX
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>  Var1 Var2       r r_squared p_value Strength Direction Sig
#>   mpg   hp -0.7762    0.6024 < 1e-04   strong  Negative Yes
#>   mpg   wt -0.8677    0.7528 < 1e-04   strong  Negative Yes
#>   mpg disp -0.8476    0.7183 < 1e-04   strong  Negative Yes
#>    hp   wt  0.6587    0.4339 < 1e-04 moderate  Positive Yes
#>    hp disp  0.7909    0.6256 < 1e-04   strong  Positive Yes
#>    wt disp  0.8880    0.7885 < 1e-04   strong  Positive Yes
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>                 Metric   Value
#>                 Method Pearson
#>              Variables       4
#>         Pairs examined       6
#>  Strongest correlation   0.888
#>    Weakest correlation  0.6587
#>      Pairs significant       6
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> CORRELATION HEATMAP INTERPRETATION
#> 
#> The heatmap displays pairwise pearson correlations among 4 variables. Cell
#>   colour intensity reflects the strength of association: dark blue = strong
#>   positive, dark red = strong negative, white = no correlation. Among the 6
#>   pairs examined, 5 show strong correlations (|r| ≥ 0.70) and 1 show moderate
#>   correlations (0.30 ≤ |r| < 0.70). Diagonal values are 1.0 by definition
#>   (each variable correlates perfectly with itself).
#> 
#> ================================================================================
#> 
```

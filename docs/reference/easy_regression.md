# Run a Linear Regression with Automated Narrative Reporting

Executes a standard OLS linear regression using
[`stats::lm()`](https://rdrr.io/r/stats/lm.html), extracts key metrics
via the `broom` package, and automatically generates a plain-language
narrative explanation via the Narrative Generator Module.

## Usage

``` r
easy_regression(formula, data, alpha = 0.05)
```

## Arguments

- formula:

  A `formula` object or a character string formula (e.g.,
  `"mpg ~ wt + hp"`). Passed directly to
  [`stats::lm()`](https://rdrr.io/r/stats/lm.html).

- data:

  A data frame containing the variables referenced in `formula`.

- alpha:

  Significance threshold used in narrative generation. Default `0.05`.

## Value

An object of class `"easystat_result"` (an R `list`) with:

- `test_type`:

  Character: `"regression"`

- `formula_str`:

  Character string of the formula used

- `raw_model`:

  The raw `lm` object for advanced use

- `coefficients_table`:

  Tidy data frame of coefficients, SEs, t-stats, p-values

- `model_fit_table`:

  Data frame with R\\^2\\, Adjusted R\\^2\\, F-statistic, p-value

- `explanation`:

  Plain-language narrative string

## Examples

``` r
result <- easy_regression(mpg ~ wt + hp, data = mtcars)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: REGRESSION
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>         Term Estimate Std. Error t Statistic  p-value
#>  (Intercept)  37.2273     1.5988     23.2847 <0.0001%
#>           wt  -3.8778     0.6327     -6.1287  0.0001%
#>           hp  -0.0318     0.0090     -3.5187  0.1451%
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>              Metric    Value
#>           R-squared 0.826785
#>  Adjusted R-squared  0.81484
#>         F-statistic  69.2112
#>            Model df        2
#>         Residual df       29
#>     Overall p-value <0.0001%
#> 
#> TABLE 3 — REGRESSION ANOVA TABLE
#> --------------------------------------------------------------------------------
#>       Term Df   Sum_Sq  Mean_Sq  F_value  p_value
#>         wt  1 847.7252 847.7252 126.0411 <0.0001%
#>         hp  1  83.2742  83.2742  12.3813  0.1451%
#>  Residuals 29 195.0478   6.7258       NA       NA
#> 
#> TABLE 4 — REGRESSION DIAGNOSTICS
#> --------------------------------------------------------------------------------
#>                   Metric   Value
#>                   N used      32
#>                     RMSE  2.4689
#>                      MAE  1.9015
#>              Residual SD  2.5084
#>            Mean residual       0
#>  Shapiro-Wilk residual p 3.4275%
#>  Durbin-Watson statistic  1.3624
#> 
#> TABLE 5 — INFLUENTIAL OBSERVATIONS
#> --------------------------------------------------------------------------------
#>  Observation Cook_Distance Leverage Std_Residual Influential
#>           17      0.423611 0.186487       2.3545         Yes
#>           31      0.272040 0.394208       1.1199         Yes
#>           20      0.208393 0.099503       2.3786         Yes
#>           18      0.157426 0.079910       2.3319         Yes
#>           28      0.073540 0.153641       1.1024          No
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> LINEAR REGRESSION ANALYSIS Formula: mpg ~ wt + hp
#> 
#> The overall regression model is highly statistically significant (p <
#>   0.0001%), indicating that the set of 2 predictor(s) collectively explains a
#>   meaningful portion of the variance in the outcome variable (F(2, 29) =
#>   69.211). The model accounts for 82.7% (large effect) of the total variance
#>   in the response variable (Adjusted R² = 81.5%). The intercept is estimated
#>   at 37.2273, representing the predicted value of the outcome when all
#>   predictors equal zero (highly statistically significant (p < 0.0001%)). The
#>   predictor 'wt' is associated with a decrease of 3.8778 in the outcome for
#>   each one-unit increase, and this effect is highly statistically significant
#>   (p = 0.0001%). The predictor 'hp' is associated with a decrease of 0.0318
#>   in the outcome for each one-unit increase, and this effect is statistically
#>   significant (p = 0.1451%). Overall, the model provides statistically
#>   meaningful insight and may be suitable for predictive or inferential
#>   purposes.
#> 
#> ================================================================================
#> 
```

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
#>         Term    Estimate Std. Error t Statistic      p-value
#>  (Intercept) 37.22727012 1.59878754   23.284689 2.565459e-20
#>           wt -3.87783074 0.63273349   -6.128695 1.119647e-06
#>           hp -0.03177295 0.00902971   -3.518712 1.451229e-03
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>              Metric    Value
#>           R-squared 0.826785
#>  Adjusted R-squared  0.81484
#>         F-statistic  69.2112
#>            Model df        2
#>         Residual df       29
#>     Overall p-value  < 1e-04
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> LINEAR REGRESSION ANALYSIS Formula: mpg ~ wt + hp
#> 
#> The overall regression model is highly statistically significant (p < 0.001),
#>   indicating that the set of 2 predictor(s) collectively explains a
#>   meaningful portion of the variance in the outcome variable (F(2, 29) =
#>   69.211). The model accounts for 82.7% (large effect) of the total variance
#>   in the response variable (Adjusted R² = 81.5%). The intercept is estimated
#>   at 37.2273, representing the predicted value of the outcome when all
#>   predictors equal zero (highly statistically significant (p < 0.001)). The
#>   predictor 'wt' is associated with a decrease of 3.8778 in the outcome for
#>   each one-unit increase, and this effect is highly statistically significant
#>   (p < 0.001). The predictor 'hp' is associated with a decrease of 0.0318 in
#>   the outcome for each one-unit increase, and this effect is statistically
#>   significant (p = 0.0015). Overall, the model provides statistically
#>   meaningful insight and may be suitable for predictive or inferential
#>   purposes.
#> 
#> ================================================================================
#> 
```

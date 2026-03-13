# Run a One-Way ANOVA with Automated Narrative Reporting

Executes a one-way ANOVA using
[`stats::aov()`](https://rdrr.io/r/stats/aov.html), extracts key metrics
via `broom`, computes eta-squared as an effect-size measure, and
generates a plain-language narrative via the Narrative Generator Module.

## Usage

``` r
easy_anova(formula, data, alpha = 0.05)
```

## Arguments

- formula:

  A `formula` of the form `outcome ~ group_factor`, or a character
  string. Passed directly to
  [`stats::aov()`](https://rdrr.io/r/stats/aov.html).

- data:

  A data frame containing the variables in `formula`.

- alpha:

  Significance threshold for the narrative. Default `0.05`.

## Value

An object of class `"easystat_result"` with:

- `test_type`:

  Character: `"anova"`

- `formula_str`:

  Character string of the formula used

- `raw_model`:

  The raw `aov` object

- `coefficients_table`:

  ANOVA table (SS, df, MS, F, p)

- `model_fit_table`:

  Summary metrics (F-statistic, eta-squared, p-value)

- `explanation`:

  Plain-language narrative string

## Examples

``` r
result <- easy_anova(Sepal.Length ~ Species, data = iris)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: ANOVA
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>     Source  df Sum of Squares Mean Square F Statistic p-value
#>    Species   2        63.2121     31.6061    119.2645 < 1e-04
#>  Residuals 147        38.9562      0.2650          NA      NA
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>            Metric    Value
#>       F-statistic 119.2645
#>          Group df        2
#>       Residual df      147
#>   Overall p-value  < 1e-04
#>  Eta-squared (η²)   0.6187
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> ONE-WAY ANOVA Formula: Sepal.Length ~ Species
#> 
#> A one-way ANOVA revealed a highly statistically significant (p < 0.001)
#>   difference across the 3 groups (F(2, 147) = 119.265). The effect size
#>   (eta-squared = 0.6187) indicates a large practical significance of the
#>   group factor, meaning the grouping variable accounts for approximately
#>   61.9% of the total variance in the outcome. Post-hoc tests (e.g., Tukey
#>   HSD) are recommended to determine which specific group pairs differ
#>   significantly.
#> 
#> ================================================================================
#> 
```

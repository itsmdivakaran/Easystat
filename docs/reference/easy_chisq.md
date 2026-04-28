# Chi-Square Tests with Automated Narrative Reporting

Runs either a **chi-square test of independence** (two categorical
variables) or a **goodness-of-fit test** (one variable vs. expected
proportions), extracts Cramér's V as the effect-size measure, and
generates a plain-language narrative via the Narrative Generator Module.

## Usage

``` r
easy_chisq(x, y = NULL, data = NULL, p = NULL, correct = TRUE, alpha = 0.05)
```

## Arguments

- x:

  A factor/character vector, OR a contingency table (matrix), OR a
  formula `~ var1 + var2` for independence, or `~ var1` for GOF.

- y:

  A factor/character vector (second categorical variable) for the
  independence test. Ignored when `x` is a table or formula.

- data:

  A data frame. Required when `x` is a formula.

- p:

  Numeric vector of expected probabilities for the GOF test. If `NULL`
  (default), equal probabilities are assumed.

- correct:

  Logical; apply Yates' continuity correction? Default `TRUE`.

- alpha:

  Significance threshold for narrative. Default `0.05`.

## Value

An `"easystat_result"` object with:

- `coefficients_table`:

  Observed vs. expected frequency table

- `model_fit_table`:

  Chi-square statistic, df, p-value, Cramér's V

- `explanation`:

  Plain-language narrative

## Examples

``` r
# Independence test
result <- easy_chisq(~ cyl + am, data = mtcars)
#> Warning: Chi-squared approximation may be incorrect
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: CHISQ
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>  Category Observed Expected Residual Std_Residual
#>     4 | 0        3     6.53  -3.5312      -1.3818
#>     4 | 1        4     4.16  -0.1562      -0.0766
#>     6 | 0       12     8.31   3.6875       1.2790
#>     6 | 1        8     4.47   3.5312       1.6705
#>     8 | 0        3     2.84   0.1562       0.0927
#>     8 | 1        2     5.69  -3.6875      -1.5462
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>                     Metric       Value
#>  Chi-square statistic (χ²)      8.7407
#>         Degrees of Freedom           2
#>                    p-value     1.2647%
#>                  N (total)          32
#>                 Cramér's V      0.5226
#>            Effect Strength very strong
#> 
#> TABLE 3 — OBSERVED CONTINGENCY TABLE
#> --------------------------------------------------------------------------------
#>  Category  0 1
#>         4  3 8
#>         6  4 3
#>         8 12 2
#> 
#> TABLE 4 — EXPECTED COUNTS
#> --------------------------------------------------------------------------------
#>  Category      0      1
#>         4 6.5312 4.4688
#>         6 4.1562 2.8438
#>         8 8.3125 5.6875
#> 
#> TABLE 5 — ROW PERCENTAGES
#> --------------------------------------------------------------------------------
#>  Category       0       1
#>         4 27.2727 72.7273
#>         6 57.1429 42.8571
#>         8 85.7143 14.2857
#> 
#> TABLE 6 — COLUMN PERCENTAGES
#> --------------------------------------------------------------------------------
#>  Category       0       1
#>         4 15.7895 61.5385
#>         6 21.0526 23.0769
#>         8 63.1579 15.3846
#> 
#> TABLE 7 — TOTAL PERCENTAGES
#> --------------------------------------------------------------------------------
#>  Category      0      1
#>         4  9.375 25.000
#>         6 12.500  9.375
#>         8 37.500  6.250
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> CHI-SQUARE TEST OF INDEPENDENCE
#> 
#> A Pearson chi-square test of independence revealed a statistically
#>   significant (p = 1.2647%) association between 'cyl' and 'am' (χ²(2) =
#>   8.741). The effect size, measured by Cramér's V = 0.5226, indicates a very
#>   strong practical association between the two categorical variables. The
#>   observed cell frequencies deviate meaningfully from what would be expected
#>   under statistical independence, suggesting a genuine relationship between
#>   'cyl' and 'am'.
#> 
#> ================================================================================
#> 

# Goodness-of-fit
result <- easy_chisq(~ cyl, data = mtcars)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: CHISQ
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>  Category Observed Expected Residual Std_Residual
#>         4       11    10.67   0.3333       0.1021
#>         6        7    10.67  -3.6667      -1.1227
#>         8       14    10.67   3.3333       1.0206
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>                     Metric    Value
#>  Chi-square statistic (χ²)   2.3125
#>         Degrees of Freedom        2
#>                    p-value 31.4664%
#>                  N (total)       32
#>                 Cramér's V   0.2688
#>            Effect Strength moderate
#> 
#> TABLE 3 — GOODNESS-OF-FIT TABLE
#> --------------------------------------------------------------------------------
#>  Category Observed Expected Percentage
#>         4       11  10.6667     34.375
#>         6        7  10.6667     21.875
#>         8       14  10.6667     43.750
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> CHI-SQUARE GOODNESS-OF-FIT TEST
#> 
#> A chi-square goodness-of-fit test for 'cyl' is not statistically significant
#>   (p = 31.4664%) (χ²(2) = 2.312). The observed frequency distribution is
#>   consistent with the expected (theoretical) distribution.
#> 
#> ================================================================================
#> 
```

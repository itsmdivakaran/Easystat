# Group-Wise Summary Statistics with Narrative

Computes descriptive statistics for a numeric outcome variable
stratified by a grouping factor, providing both a comparison table and a
narrative highlighting which group has the highest/lowest mean and
variability.

## Usage

``` r
easy_group_summary(formula, data, digits = 4)
```

## Arguments

- formula:

  A formula of the form `outcome ~ group`.

- data:

  A data frame containing the variables.

- digits:

  Number of decimal places. Default `4`.

## Value

An `"easystat_result"` object.

## Examples

``` r
result <- easy_group_summary(mpg ~ cyl, data = mtcars)
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: GROUP_SUMMARY
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>  Group  N    Mean Median     SD     SE  Min  Max  IQR  CV_pct Skewness CI_lower
#>      6  7 19.7429   19.7 1.4536 0.5494 17.8 21.4 2.35  7.3625  -0.2586  18.3985
#>      4 11 26.6636   26.0 4.5098 1.3598 21.4 33.9 7.60 16.9138   0.3485  23.6339
#>      8 14 15.1000   15.2 2.5600 0.6842 10.4 19.2 1.85 16.9540  -0.4558  13.6219
#>  CI_upper
#>   21.0872
#>   29.6934
#>   16.5781
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>             Metric   Value
#>   Outcome variable     mpg
#>  Grouping variable     cyl
#>   Number of groups       3
#>       Overall Mean 20.0906
#>         Overall SD  6.0269
#>     Overall Median    19.2
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> GROUP SUMMARY: mpg by cyl
#> 
#> Descriptive statistics were computed for 'mpg' across 3 groups of 'cyl'. The
#>   group with the highest mean is '4' (M = 26.6636), while the group with the
#>   lowest mean is '8' (M = 15.1). The group with the greatest variability
#>   (highest SD) is '4' (SD = 4.5098). Overall, the grand mean across all
#>   groups is 20.0906 (SD = 6.0269, Median = 19.2). These group-level
#>   statistics provide the foundation for inferential comparisons using ANOVA
#>   or t-tests.
#> 
#> ================================================================================
#> 
```

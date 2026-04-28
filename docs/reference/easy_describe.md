# Comprehensive Descriptive Statistics with Narrative

Computes a rich set of descriptive statistics for one or more numeric
variables, including measures of central tendency, dispersion, shape
(skewness, kurtosis), and normality (Shapiro-Wilk), together with an
automatic plain-language narrative interpretation.

## Usage

``` r
easy_describe(data, vars = NULL, digits = 4, conf_level = 0.95)
```

## Arguments

- data:

  A numeric vector **or** a data frame.

- vars:

  Character vector of column names to describe when `data` is a data
  frame. If `NULL` (default), all numeric columns are used.

- digits:

  Number of decimal places in the summary table. Default `4`.

- conf_level:

  Confidence level for the mean CI. Default `0.95`.

## Value

An `"easystat_result"` object with:

- `coefficients_table`:

  Wide-format summary statistics table

- `model_fit_table`:

  Shape and normality digest

- `explanation`:

  Plain-language narrative (one per variable)

## Examples

``` r
result <- easy_describe(mtcars, vars = c("mpg", "hp", "wt"))
print(result)
#> 
#> ================================================================================
#>  EasyStat Result :: DESCRIBE
#> ================================================================================
#> 
#> TABLE 1 — MAIN RESULTS
#> --------------------------------------------------------------------------------
#>  Variable  N Missing     Mean  Median   Mode      SD      SE  Variance    Min
#>       mpg 32       0  20.0906  19.200  21.00  6.0269  1.0654   36.3241 10.400
#>        hp 32       0 146.6875 123.000 110.00 68.5629 12.1203 4700.8669 52.000
#>        wt 32       0   3.2172   3.325   3.44  0.9785  0.1730    0.9574  1.513
#>       Q1     Q3     Max   Range     IQR  CV_pct Skewness Kurtosis CI_lower
#>  15.4250  22.80  33.900  23.500  7.3750 29.9988   0.6724  -0.0220  17.9177
#>  96.5000 180.00 335.000 283.000 83.5000 46.7408   0.7994   0.2752 121.9679
#>   2.5812   3.61   5.424   3.911  1.0288 30.4129   0.4659   0.4166   2.8645
#>  CI_upper Shapiro_p
#>   22.2636  12.2881%
#>  171.4071   4.8808%
#>    3.5700   9.2655%
#> 
#> TABLE 2 — MODEL FIT / SUMMARY
#> --------------------------------------------------------------------------------
#>  Variable                   Shape
#>       mpg moderately right-skewed
#>        hp moderately right-skewed
#>        wt approximately symmetric
#>                                                                 Kurtosis
#>  approximately mesokurtic (similar tail weight to a normal distribution)
#>  approximately mesokurtic (similar tail weight to a normal distribution)
#>  approximately mesokurtic (similar tail weight to a normal distribution)
#>                                         Normality Shapiro_p
#>  approximately normal (Shapiro-Wilk p = 12.2881%)  12.2881%
#>             non-normal (Shapiro-Wilk p = 4.8808%)   4.8808%
#>   approximately normal (Shapiro-Wilk p = 9.2655%)   9.2655%
#> 
#> ================================================================================
#>  PLAIN-LANGUAGE INTERPRETATION
#> ================================================================================
#> 
#> DESCRIPTIVE STATISTICS: mpg
#> 
#> The variable 'mpg' has 32 valid observations (missing: 0). The central
#>   tendency is characterised by a mean of 20.0906 and a median of 19.2, with a
#>   standard deviation of 6.0269. Values range from 10.4 to 33.9 (range = 23.5;
#>   IQR = 7.375). The distribution is moderately right-skewed and approximately
#>   mesokurtic (similar tail weight to a normal distribution). Based on the
#>   Shapiro-Wilk test, the data are approximately normal (Shapiro-Wilk p =
#>   12.2881%). The coefficient of variation is 30%, indicating moderate
#>   relative variability. The 95% confidence interval for the population mean
#>   is [17.9177, 22.2636].
#> 
#> ---
#> 
#> DESCRIPTIVE STATISTICS: hp
#> 
#> The variable 'hp' has 32 valid observations (missing: 0). The central
#>   tendency is characterised by a mean of 146.6875 and a median of 123, with a
#>   standard deviation of 68.5629. Values range from 52 to 335 (range = 283;
#>   IQR = 83.5). The distribution is moderately right-skewed and approximately
#>   mesokurtic (similar tail weight to a normal distribution). Based on the
#>   Shapiro-Wilk test, the data are non-normal (Shapiro-Wilk p = 4.8808%). The
#>   coefficient of variation is 46.7%, indicating high relative variability.
#>   The 95% confidence interval for the population mean is [121.9679,
#>   171.4071].
#> 
#> ---
#> 
#> DESCRIPTIVE STATISTICS: wt
#> 
#> The variable 'wt' has 32 valid observations (missing: 0). The central
#>   tendency is characterised by a mean of 3.2172 and a median of 3.325, with a
#>   standard deviation of 0.9785. Values range from 1.513 to 5.424 (range =
#>   3.911; IQR = 1.0288). The distribution is approximately symmetric and
#>   approximately mesokurtic (similar tail weight to a normal distribution).
#>   Based on the Shapiro-Wilk test, the data are approximately normal
#>   (Shapiro-Wilk p = 9.2655%). The coefficient of variation is 30.4%,
#>   indicating high relative variability. The 95% confidence interval for the
#>   population mean is [2.8645, 3.57].
#> 
#> ================================================================================
#> 
```

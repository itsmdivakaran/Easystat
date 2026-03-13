# Narrative Generator Module
# Internal module that converts extracted statistical metrics into
# plain-language, report-ready narrative strings. This is the core inventive
# component of the EasyStat System, applying conditional logic to assembled
# metric values and populating pre-written glue templates to produce
# statistically sound, human-readable explanations.
# (Internal module)

# ---------------------------------------------------------------------------
# Helper: significance label
# ---------------------------------------------------------------------------
.sig_label <- function(p_value, alpha = 0.05) {
  if (is.na(p_value)) return("could not be determined")
  if (p_value < 0.001) return("highly statistically significant (p < 0.001)")
  if (p_value < 0.01)  return(glue::glue("statistically significant (p = {round(p_value, 4)})"))
  if (p_value < alpha) return(glue::glue("statistically significant (p = {round(p_value, 4)})"))
  return(glue::glue("not statistically significant (p = {round(p_value, 4)})"))
}

# ---------------------------------------------------------------------------
# Helper: direction label for coefficients
# ---------------------------------------------------------------------------
.direction_label <- function(estimate) {
  if (is.na(estimate)) return("an unknown change")
  if (estimate > 0) return(glue::glue("an increase of {round(estimate, 4)}"))
  return(glue::glue("a decrease of {abs(round(estimate, 4))}"))
}

# ---------------------------------------------------------------------------
# Helper: effect-size adjective for R-squared
# ---------------------------------------------------------------------------
.r2_label <- function(r_squared) {
  if (is.na(r_squared)) return("unknown")
  if (r_squared >= 0.75) return(glue::glue("{round(r_squared * 100, 1)}% (large effect)"))
  if (r_squared >= 0.50) return(glue::glue("{round(r_squared * 100, 1)}% (moderate effect)"))
  if (r_squared >= 0.25) return(glue::glue("{round(r_squared * 100, 1)}% (small-to-moderate effect)"))
  return(glue::glue("{round(r_squared * 100, 1)}% (small effect)"))
}

# ---------------------------------------------------------------------------
# Narrative: Linear Regression
# ---------------------------------------------------------------------------
.generate_regression_narrative <- function(metrics, formula_str) {
  sig      <- .sig_label(metrics$p_value_overall)
  r2_text  <- .r2_label(metrics$r_squared)
  adj_r2   <- if (!is.na(metrics$adj_r_squared)) round(metrics$adj_r_squared * 100, 1) else "N/A"
  f_stat   <- if (!is.na(metrics$f_statistic)) round(metrics$f_statistic, 3) else "N/A"
  df1      <- if (!is.na(metrics$df1)) metrics$df1 else "N/A"
  df2      <- if (!is.na(metrics$df2)) metrics$df2 else "N/A"
  n_pred   <- if (!is.na(metrics$n_predictors)) metrics$n_predictors else "unknown"

  # Significance sentence
  sig_sentence <- if (!is.na(metrics$p_value_overall) && metrics$p_value_overall < 0.05) {
    glue::glue(
      "The overall regression model is {sig}, indicating that the set of {n_pred} ",
      "predictor(s) collectively explains a meaningful portion of the variance ",
      "in the outcome variable (F({df1}, {df2}) = {f_stat})."
    )
  } else {
    glue::glue(
      "The overall regression model is {sig}. This suggests that the predictor(s) ",
      "included in the model do not collectively explain a significant portion of ",
      "the variance in the outcome variable (F({df1}, {df2}) = {f_stat})."
    )
  }

  # R-squared sentence
  r2_sentence <- glue::glue(
    "The model accounts for {r2_text} of the total variance in the response variable ",
    "(Adjusted R\u00b2 = {adj_r2}%)."
  )

  # Predictor sentences
  pred_sentences <- ""
  if (!is.null(metrics$term_details) && nrow(metrics$term_details) > 0) {
    term_lines <- apply(metrics$term_details, 1, function(row) {
      term_name <- row["term"]
      est       <- suppressWarnings(as.numeric(row["estimate"]))
      pv        <- suppressWarnings(as.numeric(row["p.value"]))
      dir_text  <- .direction_label(est)
      sig_text  <- .sig_label(pv)

      if (term_name == "(Intercept)") {
        glue::glue(
          "The intercept is estimated at {round(est, 4)}, representing the predicted ",
          "value of the outcome when all predictors equal zero ({sig_text})."
        )
      } else {
        glue::glue(
          "The predictor '{term_name}' is associated with {dir_text} in the outcome ",
          "for each one-unit increase, and this effect is {sig_text}."
        )
      }
    })
    pred_sentences <- paste(term_lines, collapse = " ")
  }

  conclusion <- if (!is.na(metrics$p_value_overall) && metrics$p_value_overall < 0.05) {
    "Overall, the model provides statistically meaningful insight and may be suitable for predictive or inferential purposes."
  } else {
    "Overall, caution is warranted in using this model for prediction or inference given the lack of statistical significance."
  }

  glue::glue(
    "LINEAR REGRESSION ANALYSIS\n",
    "Formula: {formula_str}\n\n",
    "{sig_sentence} {r2_sentence} {pred_sentences} {conclusion}"
  )
}

# ---------------------------------------------------------------------------
# Narrative: Independent-Samples t-Test
# ---------------------------------------------------------------------------
.generate_ttest_narrative <- function(metrics, formula_or_label) {
  sig     <- .sig_label(metrics$p_value)
  t_val   <- if (!is.na(metrics$statistic)) round(metrics$statistic, 3) else "N/A"
  df_val  <- if (!is.na(metrics$parameter)) round(metrics$parameter, 2) else "N/A"
  m1      <- if (!is.na(metrics$estimate1)) round(metrics$estimate1, 4) else "N/A"
  m2      <- if (!is.na(metrics$estimate2)) round(metrics$estimate2, 4) else "N/A"
  lo      <- if (!is.na(metrics$conf_low))  round(metrics$conf_low, 4) else "N/A"
  hi      <- if (!is.na(metrics$conf_high)) round(metrics$conf_high, 4) else "N/A"
  grp1    <- if (!is.null(metrics$group1)) metrics$group1 else "Group 1"
  grp2    <- if (!is.null(metrics$group2)) metrics$group2 else "Group 2"

  sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    glue::glue(
      "An independent-samples t-test revealed a {sig} difference between ",
      "the two groups (t({df_val}) = {t_val})."
    )
  } else {
    glue::glue(
      "An independent-samples t-test found {sig} evidence of a difference between ",
      "the two groups (t({df_val}) = {t_val})."
    )
  }

  means_sentence <- glue::glue(
    "The mean for '{grp1}' was {m1} and the mean for '{grp2}' was {m2}. ",
    "The 95% confidence interval for the difference in means ranged from {lo} to {hi}."
  )

  conclusion <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    glue::glue(
      "These results provide statistically significant evidence that '{grp1}' and ",
      "'{grp2}' differ meaningfully on the measured variable."
    )
  } else {
    glue::glue(
      "Based on this sample, there is insufficient statistical evidence to conclude ",
      "that '{grp1}' and '{grp2}' differ on the measured variable."
    )
  }

  glue::glue(
    "INDEPENDENT-SAMPLES t-TEST\n",
    "Comparison: {formula_or_label}\n\n",
    "{sig_sentence} {means_sentence} {conclusion}"
  )
}

# ---------------------------------------------------------------------------
# Narrative: One-Way ANOVA
# ---------------------------------------------------------------------------
.generate_anova_narrative <- function(metrics, formula_str) {
  sig      <- .sig_label(metrics$p_value)
  f_val    <- if (!is.na(metrics$f_statistic)) round(metrics$f_statistic, 3) else "N/A"
  df1      <- if (!is.na(metrics$df_group))  metrics$df_group  else "N/A"
  df2      <- if (!is.na(metrics$df_resid))  metrics$df_resid  else "N/A"
  n_groups <- if (!is.na(metrics$n_groups))  metrics$n_groups  else "N/A"
  eta_sq   <- if (!is.na(metrics$eta_squared)) round(metrics$eta_squared, 4) else "N/A"

  effect_label <- if (!is.na(metrics$eta_squared)) {
    if (metrics$eta_squared >= 0.14)     "large"
    else if (metrics$eta_squared >= 0.06) "medium"
    else if (metrics$eta_squared >= 0.01) "small"
    else "negligible"
  } else "unknown"

  sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    glue::glue(
      "A one-way ANOVA revealed a {sig} difference across the {n_groups} groups ",
      "(F({df1}, {df2}) = {f_val})."
    )
  } else {
    glue::glue(
      "A one-way ANOVA found {sig} evidence of a difference across the {n_groups} groups ",
      "(F({df1}, {df2}) = {f_val})."
    )
  }

  effect_sentence <- glue::glue(
    "The effect size (eta-squared = {eta_sq}) indicates a {effect_label} practical ",
    "significance of the group factor, meaning the grouping variable accounts for ",
    "approximately {round(as.numeric(eta_sq) * 100, 1)}% of the total variance in the outcome."
  )

  conclusion <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    "Post-hoc tests (e.g., Tukey HSD) are recommended to determine which specific group pairs differ significantly."
  } else {
    "The data do not provide sufficient evidence to conclude that the group means differ. Post-hoc testing is not warranted at this stage."
  }

  glue::glue(
    "ONE-WAY ANOVA\n",
    "Formula: {formula_str}\n\n",
    "{sig_sentence} {effect_sentence} {conclusion}"
  )
}

# ===========================================================================
#  EXTENDED NARRATIVE FUNCTIONS  (v1.1)
# ===========================================================================

# ---------------------------------------------------------------------------
# Helpers: effect-size labels (shared across tests)
# ---------------------------------------------------------------------------
.cohens_d_label <- function(d) {
  d <- abs(d)
  if (is.na(d))        return("unknown")
  if (d >= 0.80)       return("large (d \u2265 0.80)")
  if (d >= 0.50)       return("medium (0.50 \u2264 d < 0.80)")
  if (d >= 0.20)       return("small (0.20 \u2264 d < 0.50)")
  return("negligible (d < 0.20)")
}

.cramers_v_label <- function(v) {
  if (is.na(v))   return("unknown")
  if (v >= 0.50)  return("very strong")
  if (v >= 0.30)  return("strong")
  if (v >= 0.10)  return("moderate")
  return("weak")
}

.corr_label <- function(r) {
  r <- abs(r)
  if (is.na(r))   return("unknown")
  if (r >= 0.90)  return("very strong")
  if (r >= 0.70)  return("strong")
  if (r >= 0.50)  return("moderate")
  if (r >= 0.30)  return("weak")
  return("very weak or negligible")
}

.skew_label <- function(sk) {
  if (is.na(sk))   return("unknown")
  if (sk >  1.0)   return("strongly right-skewed (positive skew)")
  if (sk >  0.5)   return("moderately right-skewed")
  if (sk > -0.5)   return("approximately symmetric")
  if (sk > -1.0)   return("moderately left-skewed")
  return("strongly left-skewed (negative skew)")
}

.kurt_label <- function(k) {
  if (is.na(k))  return("unknown")
  if (k >  1.0)  return("leptokurtic (heavy-tailed, sharper peak than normal)")
  if (k < -1.0)  return("platykurtic (light-tailed, flatter than normal)")
  return("approximately mesokurtic (similar tail weight to a normal distribution)")
}

.norm_label <- function(p) {
  if (is.na(p)) return("normality could not be assessed")
  if (p < 0.05) return(glue::glue("non-normal (Shapiro-Wilk p = {round(p, 4)})"))
  return(glue::glue("approximately normal (Shapiro-Wilk p = {round(p, 4)})"))
}

# ---------------------------------------------------------------------------
# Narrative: Descriptive Statistics
# ---------------------------------------------------------------------------
.generate_describe_narrative <- function(metrics, var_name) {
  skew_txt <- .skew_label(metrics$skewness)
  kurt_txt <- .kurt_label(metrics$kurtosis)
  norm_txt <- .norm_label(metrics$shapiro_p)

  cv_note <- if (!is.na(metrics$cv_pct)) {
    cv <- round(metrics$cv_pct, 1)
    if (cv > 30) glue::glue("The coefficient of variation is {cv}%, indicating high relative variability.")
    else if (cv > 15) glue::glue("The coefficient of variation is {cv}%, indicating moderate relative variability.")
    else glue::glue("The coefficient of variation is {cv}%, indicating low relative variability.")
  } else ""

  glue::glue(
    "DESCRIPTIVE STATISTICS: {var_name}\n\n",
    "The variable '{var_name}' has {metrics$n} valid observations (missing: {metrics$n_missing}). ",
    "The central tendency is characterised by a mean of {round(metrics$mean, 4)} and a ",
    "median of {round(metrics$median, 4)}, with a standard deviation of {round(metrics$sd, 4)}. ",
    "Values range from {round(metrics$min, 4)} to {round(metrics$max, 4)} (range = {round(metrics$range_val, 4)}; ",
    "IQR = {round(metrics$iqr, 4)}). ",
    "The distribution is {skew_txt} and {kurt_txt}. ",
    "Based on the Shapiro-Wilk test, the data are {norm_txt}. ",
    "{cv_note} ",
    "The 95% confidence interval for the population mean is [{round(metrics$ci_lower, 4)}, {round(metrics$ci_upper, 4)}]."
  )
}

# ---------------------------------------------------------------------------
# Narrative: Chi-Square
# ---------------------------------------------------------------------------
.generate_chisq_narrative <- function(metrics, chisq_type, var1, var2 = NULL) {
  sig      <- .sig_label(metrics$p_value)
  x2_val   <- if (!is.na(metrics$statistic)) round(metrics$statistic, 3) else "N/A"
  df_val   <- if (!is.na(metrics$df))        metrics$df                  else "N/A"
  v_label  <- .cramers_v_label(metrics$cramers_v)
  v_val    <- if (!is.na(metrics$cramers_v)) round(metrics$cramers_v, 4) else "N/A"

  if (chisq_type == "independence") {
    sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
      glue::glue(
        "A Pearson chi-square test of independence revealed a {sig} association ",
        "between '{var1}' and '{var2}' (\u03c7\u00b2({df_val}) = {x2_val})."
      )
    } else {
      glue::glue(
        "A Pearson chi-square test of independence found {sig} evidence of an ",
        "association between '{var1}' and '{var2}' (\u03c7\u00b2({df_val}) = {x2_val})."
      )
    }
    effect_sentence <- glue::glue(
      "The effect size, measured by Cram\u00e9r's V = {v_val}, indicates a {v_label} ",
      "practical association between the two categorical variables."
    )
    conclusion <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
      glue::glue(
        "The observed cell frequencies deviate meaningfully from what would be expected ",
        "under statistical independence, suggesting a genuine relationship between '{var1}' and '{var2}'."
      )
    } else {
      "The observed cell frequencies are consistent with statistical independence. No meaningful relationship between the two variables is supported by these data."
    }
    glue::glue("CHI-SQUARE TEST OF INDEPENDENCE\n\n{sig_sentence} {effect_sentence} {conclusion}")

  } else {
    sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
      glue::glue(
        "A chi-square goodness-of-fit test for '{var1}' is {sig} ",
        "(\u03c7\u00b2({df_val}) = {x2_val})."
      )
    } else {
      glue::glue(
        "A chi-square goodness-of-fit test for '{var1}' is {sig} ",
        "(\u03c7\u00b2({df_val}) = {x2_val})."
      )
    }
    conclusion <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
      "The observed frequency distribution differs significantly from the expected (theoretical) distribution."
    } else {
      "The observed frequency distribution is consistent with the expected (theoretical) distribution."
    }
    glue::glue("CHI-SQUARE GOODNESS-OF-FIT TEST\n\n{sig_sentence} {conclusion}")
  }
}

# ---------------------------------------------------------------------------
# Narrative: Z-Test
# ---------------------------------------------------------------------------
.generate_ztest_narrative <- function(metrics, label) {
  sig      <- .sig_label(metrics$p_value)
  z_val    <- if (!is.na(metrics$z_stat))   round(metrics$z_stat, 3)   else "N/A"
  d_label  <- .cohens_d_label(metrics$cohens_d)
  d_val    <- if (!is.na(metrics$cohens_d)) round(abs(metrics$cohens_d), 4) else "N/A"

  if (metrics$test_type_z == "one_sample") {
    sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
      glue::glue(
        "A one-sample z-test revealed that the sample mean ({round(metrics$x_bar, 4)}) ",
        "differs {sig} from the hypothesised population mean of {metrics$mu} (z = {z_val})."
      )
    } else {
      glue::glue(
        "A one-sample z-test found {sig} evidence that the sample mean ({round(metrics$x_bar, 4)}) ",
        "differs from the hypothesised population mean of {metrics$mu} (z = {z_val})."
      )
    }
    effect_sentence <- glue::glue(
      "The standardised effect size (Cohen's d = {d_val}) is classified as {d_label}. ",
      "The 95% CI for the population mean is [{round(metrics$ci_lower, 4)}, {round(metrics$ci_upper, 4)}]."
    )
  } else {
    sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
      glue::glue(
        "A two-sample z-test revealed a {sig} difference between the two group means ",
        "(z = {z_val}). Mean\u2081 = {round(metrics$x_bar, 4)}, Mean\u2082 = {round(metrics$x_bar2, 4)}."
      )
    } else {
      glue::glue(
        "A two-sample z-test found {sig} evidence of a difference between the two group means ",
        "(z = {z_val}). Mean\u2081 = {round(metrics$x_bar, 4)}, Mean\u2082 = {round(metrics$x_bar2, 4)}."
      )
    }
    effect_sentence <- glue::glue(
      "The standardised effect size (Cohen's d = {d_val}) is classified as {d_label}. ",
      "The 95% CI for the mean difference is [{round(metrics$ci_lower, 4)}, {round(metrics$ci_upper, 4)}]."
    )
  }
  glue::glue("Z-TEST\nComparison: {label}\n\n{sig_sentence} {effect_sentence}")
}

# ---------------------------------------------------------------------------
# Narrative: F-Test (Variance Ratio)
# ---------------------------------------------------------------------------
.generate_ftest_narrative <- function(metrics, label) {
  sig      <- .sig_label(metrics$p_value)
  f_val    <- if (!is.na(metrics$f_stat)) round(metrics$f_stat, 4) else "N/A"
  df1      <- if (!is.na(metrics$df1))    metrics$df1               else "N/A"
  df2      <- if (!is.na(metrics$df2))    metrics$df2               else "N/A"
  ratio    <- if (!is.na(metrics$var_ratio)) round(metrics$var_ratio, 4) else "N/A"

  sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    glue::glue(
      "An F-test for equality of variances revealed a {sig} difference in variance ",
      "between the two groups (F({df1}, {df2}) = {f_val}). ",
      "The ratio of variances is {ratio}."
    )
  } else {
    glue::glue(
      "An F-test for equality of variances found {sig} evidence of a difference in variance ",
      "between the two groups (F({df1}, {df2}) = {f_val}). ",
      "The ratio of variances is {ratio}."
    )
  }

  implication <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    "IMPLICATION: The assumption of equal variances (homoscedasticity) is VIOLATED. It is recommended to use Welch's t-test (var.equal = FALSE) rather than the classical t-test."
  } else {
    "IMPLICATION: The assumption of equal variances (homoscedasticity) is SUPPORTED. Both the classical t-test and Welch's t-test are appropriate."
  }

  glue::glue(
    "F-TEST FOR EQUALITY OF VARIANCES\n",
    "Comparison: {label}\n\n",
    "{sig_sentence} ",
    "The 95% CI for the variance ratio is [{round(metrics$ci_lower, 4)}, {round(metrics$ci_upper, 4)}]. ",
    "{implication}"
  )
}

# ---------------------------------------------------------------------------
# Narrative: Correlation
# ---------------------------------------------------------------------------
.generate_correlation_narrative <- function(metrics) {
  r_val    <- round(metrics$r, 4)
  p_sig    <- .sig_label(metrics$p_value)
  strength <- .corr_label(metrics$r)
  dir      <- if (metrics$r >= 0) "positive" else "negative"
  method   <- tools::toTitleCase(metrics$method)
  r2_pct   <- round(metrics$r^2 * 100, 1)

  sig_sentence <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    glue::glue(
      "A {method} correlation analysis revealed a {strength} {dir} correlation ",
      "between the two variables (r = {r_val}), which is {p_sig}."
    )
  } else {
    glue::glue(
      "A {method} correlation analysis found a {strength} {dir} correlation ",
      "between the two variables (r = {r_val}), which is {p_sig}."
    )
  }

  r2_sentence <- glue::glue(
    "The coefficient of determination (r\u00b2 = {round(metrics$r^2, 4)}) indicates that ",
    "approximately {r2_pct}% of the variance in one variable is shared with the other."
  )

  ci_sentence <- glue::glue(
    "The 95% confidence interval for the correlation coefficient is [{round(metrics$ci_lower, 4)}, {round(metrics$ci_upper, 4)}]."
  )

  conclusion <- if (!is.na(metrics$p_value) && metrics$p_value < 0.05) {
    if (abs(metrics$r) >= 0.70) "This strong relationship may have meaningful practical implications and warrants further investigation."
    else if (abs(metrics$r) >= 0.30) "The moderate relationship suggests a real but imperfect association between the variables."
    else "Though statistically significant, the weak correlation indicates limited practical association."
  } else {
    "The data do not provide sufficient evidence to conclude that the two variables are linearly related."
  }

  glue::glue(
    "CORRELATION ANALYSIS ({method})\n\n",
    "{sig_sentence} {r2_sentence} {ci_sentence} {conclusion}"
  )
}

# ---------------------------------------------------------------------------
# Narrative: Plot Interpretations
# ---------------------------------------------------------------------------
.generate_histogram_interpretation <- function(metrics) {
  skew_txt <- .skew_label(metrics$skewness)
  kurt_txt <- .kurt_label(metrics$kurtosis)
  norm_txt <- .norm_label(metrics$shapiro_p)
  glue::glue(
    "HISTOGRAM INTERPRETATION\n\n",
    "The histogram displays the frequency distribution of '{metrics$var_name}' (n = {metrics$n}). ",
    "The distribution appears {skew_txt} and {kurt_txt}. ",
    "The data are {norm_txt}. ",
    "The mean ({round(metrics$mean, 3)}) and median ({round(metrics$median, 3)}) ",
    if (abs(metrics$mean - metrics$median) / metrics$sd < 0.1)
      "are very close together, consistent with a symmetric distribution."
    else if (metrics$mean > metrics$median)
      "suggest a right-skewed distribution with the mean pulled toward the upper tail."
    else
      "suggest a left-skewed distribution with the mean pulled toward the lower tail."
  )
}

.generate_boxplot_interpretation <- function(metrics) {
  glue::glue(
    "BOXPLOT INTERPRETATION\n\n",
    "The boxplot visualises the distribution of '{metrics$outcome}' ",
    if (!is.null(metrics$group)) glue::glue("across {metrics$n_groups} levels of '{metrics$group}'. ") else ". ",
    "The central box spans from Q1 ({round(metrics$q1, 3)}) to Q3 ({round(metrics$q3, 3)}), ",
    "with a median of {round(metrics$median, 3)} (IQR = {round(metrics$iqr, 3)}). ",
    if (metrics$n_outliers > 0)
      glue::glue("{metrics$n_outliers} outlier(s) are visible beyond the whiskers and may warrant further investigation. ")
    else
      "No outliers are detected beyond the whiskers. ",
    "The whiskers extend to the most extreme non-outlier values."
  )
}

.generate_scatter_interpretation <- function(metrics) {
  strength <- .corr_label(metrics$r)
  dir      <- if (metrics$r >= 0) "positive" else "negative"
  sig_txt  <- .sig_label(metrics$p_value_r)
  glue::glue(
    "SCATTERPLOT INTERPRETATION\n\n",
    "The scatterplot shows the relationship between '{metrics$x_var}' (x-axis) and ",
    "'{metrics$y_var}' (y-axis) across {metrics$n} observations. ",
    "The Pearson correlation is r = {round(metrics$r, 4)}, indicating a {strength} {dir} linear ",
    "relationship that is {sig_txt}. ",
    "The regression line (slope = {round(metrics$slope, 4)}) ",
    if (metrics$r >= 0) "slopes upward, confirming the positive association." else "slopes downward, confirming the negative association.",
    " Approximately {round(metrics$r^2 * 100, 1)}% of variance in '{metrics$y_var}' is explained by '{metrics$x_var}'."
  )
}

.generate_qqplot_interpretation <- function(metrics) {
  norm_txt <- .norm_label(metrics$shapiro_p)
  glue::glue(
    "Q-Q PLOT INTERPRETATION\n\n",
    "The Q-Q plot compares the quantiles of '{metrics$var_name}' against theoretical normal quantiles. ",
    "Points closely following the diagonal reference line indicate normality. ",
    "The Shapiro-Wilk test indicates the data are {norm_txt}. ",
    if (!is.na(metrics$shapiro_p) && metrics$shapiro_p < 0.05)
      "Noticeable deviations from the diagonal \u2014 particularly at the tails \u2014 suggest departure from normality. Consider data transformations or non-parametric alternatives."
    else
      "Points lie close to the diagonal, supporting the assumption of normality."
  )
}

.generate_density_interpretation <- function(metrics) {
  skew_txt <- .skew_label(metrics$skewness)
  glue::glue(
    "DENSITY PLOT INTERPRETATION\n\n",
    "The kernel density plot provides a smooth estimate of the probability density of '{metrics$var_name}'. ",
    "The distribution is {skew_txt}. ",
    "The peak (mode \u2248 {round(metrics$mode_approx, 3)}) represents the most frequently occurring value region. ",
    "The shaded area under the curve integrates to 1, representing 100% of the data."
  )
}

.generate_corr_heatmap_interpretation <- function(metrics) {
  n_strong    <- sum(abs(metrics$corr_values) >= 0.7 & abs(metrics$corr_values) < 1, na.rm = TRUE)
  n_moderate  <- sum(abs(metrics$corr_values) >= 0.3 & abs(metrics$corr_values) < 0.7, na.rm = TRUE)
  glue::glue(
    "CORRELATION HEATMAP INTERPRETATION\n\n",
    "The heatmap displays pairwise {metrics$method} correlations among {metrics$n_vars} variables. ",
    "Cell colour intensity reflects the strength of association: dark blue = strong positive, ",
    "dark red = strong negative, white = no correlation. ",
    "Among the {metrics$n_pairs} pairs examined, {n_strong} show strong correlations (|r| \u2265 0.70) ",
    "and {n_moderate} show moderate correlations (0.30 \u2264 |r| < 0.70). ",
    "Diagonal values are 1.0 by definition (each variable correlates perfectly with itself)."
  )
}

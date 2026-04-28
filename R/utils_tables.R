# Internal table helpers ------------------------------------------------------

.model_diagnostic_tables <- function(model) {
  resid <- stats::residuals(model)
  fitted <- stats::fitted(model)
  complete <- stats::complete.cases(resid, fitted)
  resid <- resid[complete]
  fitted <- fitted[complete]
  n <- length(resid)

  rmse <- sqrt(mean(resid^2, na.rm = TRUE))
  mae <- mean(abs(resid), na.rm = TRUE)
  shapiro_p <- .shapiro_p(resid)
  dw <- if (n > 1) sum(diff(resid)^2, na.rm = TRUE) / sum(resid^2, na.rm = TRUE) else NA_real_

  diagnostics <- data.frame(
    Metric = c("N used", "RMSE", "MAE", "Residual SD", "Mean residual",
               "Shapiro-Wilk residual p", "Durbin-Watson statistic"),
    Value = c(n, round(rmse, 4), round(mae, 4), round(stats::sd(resid), 4),
              round(mean(resid), 4), .format_p_value(shapiro_p), round(dw, 4)),
    stringsAsFactors = FALSE
  )

  infl <- stats::influence.measures(model)
  cooks <- stats::cooks.distance(model)
  hat <- stats::hatvalues(model)
  std_resid <- stats::rstandard(model)
  top_idx <- utils::head(order(cooks, decreasing = TRUE), min(5, length(cooks)))
  influence <- data.frame(
    Observation = as.integer(top_idx),
    Cook_Distance = round(cooks[top_idx], 6),
    Leverage = round(hat[top_idx], 6),
    Std_Residual = round(std_resid[top_idx], 4),
    Influential = ifelse(apply(infl$is.inf[top_idx, , drop = FALSE], 1, any), "Yes", "No"),
    stringsAsFactors = FALSE
  )

  list(
    "Regression Diagnostics" = diagnostics,
    "Influential Observations" = influence
  )
}

.anova_support_tables <- function(model, formula, data, alpha = 0.05) {
  vars <- all.vars(formula)
  outcome_var <- vars[1]
  group_var <- vars[2]

  grp <- factor(data[[group_var]])
  y <- data[[outcome_var]]
  group_levels <- levels(grp)
  group_rows <- lapply(group_levels, function(g) {
    vals <- y[grp == g]
    vals <- vals[!is.na(vals)]
    n <- length(vals)
    sd_val <- if (n > 1) stats::sd(vals) else NA_real_
    se <- if (n > 1) sd_val / sqrt(n) else NA_real_
    ci <- if (n > 1) stats::qt(0.975, df = n - 1) * se else NA_real_
    data.frame(
      Group = g,
      N = n,
      Mean = round(mean(vals), 4),
      SD = round(sd_val, 4),
      SE = round(se, 4),
      CI_Lower = round(mean(vals) - ci, 4),
      CI_Upper = round(mean(vals) + ci, 4),
      stringsAsFactors = FALSE
    )
  })
  group_summary <- do.call(rbind, group_rows)

  resid <- stats::residuals(model)
  shapiro_p <- .shapiro_p(resid)
  bartlett_p <- tryCatch(stats::bartlett.test(stats::as.formula(paste(outcome_var, "~", group_var)),
                                             data = data)$p.value,
                         error = function(e) NA_real_)
  assumptions <- data.frame(
    Check = c("Residual normality (Shapiro-Wilk)",
              "Equal variances (Bartlett)",
              "Recommended next step"),
    Result = c(.format_p_value(shapiro_p),
               .format_p_value(bartlett_p),
               if (!is.na(bartlett_p) && bartlett_p < alpha)
                 "Consider Welch ANOVA or Kruskal-Wallis"
               else "Classical one-way ANOVA assumptions are broadly supported"),
    stringsAsFactors = FALSE
  )

  tukey_table <- tryCatch({
    tk <- stats::TukeyHSD(model)
    tk_df <- as.data.frame(tk[[1]])
    tk_df$Comparison <- rownames(tk_df)
    rownames(tk_df) <- NULL
    data.frame(
      Comparison = tk_df$Comparison,
      Difference = round(tk_df$diff, 4),
      CI_Lower = round(tk_df$lwr, 4),
      CI_Upper = round(tk_df$upr, 4),
      Adj_p_value = .format_p_value(tk_df$`p adj`),
      Significant = ifelse(tk_df$`p adj` < alpha, "Yes", "No"),
      stringsAsFactors = FALSE
    )
  }, error = function(e) NULL)

  out <- list(
    "Group Descriptives" = group_summary,
    "Assumption Checks" = assumptions
  )
  if (!is.null(tukey_table)) out[["Tukey Post-hoc Comparisons"]] <- tukey_table
  out
}

.contingency_tables <- function(tbl, expected) {
  observed_df <- as.data.frame.matrix(tbl)
  observed_df <- cbind(Category = rownames(observed_df), observed_df, row.names = NULL)

  expected_df <- as.data.frame.matrix(round(expected, 4))
  expected_df <- cbind(Category = rownames(expected_df), expected_df, row.names = NULL)

  row_pct <- round(prop.table(tbl, margin = 1) * 100, 4)
  row_pct_df <- as.data.frame.matrix(row_pct)
  row_pct_df <- cbind(Category = rownames(row_pct_df), row_pct_df, row.names = NULL)

  col_pct <- round(prop.table(tbl, margin = 2) * 100, 4)
  col_pct_df <- as.data.frame.matrix(col_pct)
  col_pct_df <- cbind(Category = rownames(col_pct_df), col_pct_df, row.names = NULL)

  total_pct <- round(prop.table(tbl) * 100, 4)
  total_pct_df <- as.data.frame.matrix(total_pct)
  total_pct_df <- cbind(Category = rownames(total_pct_df), total_pct_df, row.names = NULL)

  list(
    "Observed Contingency Table" = observed_df,
    "Expected Counts" = expected_df,
    "Row Percentages" = row_pct_df,
    "Column Percentages" = col_pct_df,
    "Total Percentages" = total_pct_df
  )
}

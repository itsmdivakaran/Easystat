#' Run a Logistic Regression with Automated Narrative Reporting
#'
#' Executes a binary logistic regression using \code{stats::glm()} with
#' \code{family = binomial}, extracts coefficients, odds ratios, approximate
#' confidence intervals, and model-fit metrics, then generates a plain-language
#' narrative via the Narrative Generator Module.
#'
#' @param formula A \code{formula} object or a character string formula (e.g.,
#'   \code{"am ~ mpg + wt"}). The outcome must be binary.
#' @param data A data frame containing the variables referenced in \code{formula}.
#' @param alpha Significance threshold used in narrative generation. Default \code{0.05}.
#' @param conf_level Confidence level for odds-ratio intervals. Default \code{0.95}.
#'
#' @return An object of class \code{"easystat_result"} with coefficient, odds-ratio,
#'   model-fit, raw \code{glm}, and narrative components.
#'
#' @examples
#' result <- easy_logistic_regression(am ~ mpg + wt, data = mtcars)
#' print(result)
#'
#' @export
easy_logistic_regression <- function(formula, data, alpha = 0.05, conf_level = 0.95) {

  if (is.character(formula)) formula <- stats::as.formula(formula)
  if (!inherits(formula, "formula")) stop("'formula' must be a formula object or a character string.")
  if (!is.data.frame(data))          stop("'data' must be a data frame.")

  formula_str <- deparse(formula)
  outcome_var <- all.vars(formula)[1]
  if (is.na(outcome_var) || !outcome_var %in% names(data)) {
    stop("The formula must include a valid binary outcome variable.")
  }

  outcome <- data[[outcome_var]]
  valid_outcome <- stats::na.omit(outcome)
  n_levels <- if (is.numeric(valid_outcome)) {
    length(unique(valid_outcome))
  } else {
    length(unique(as.character(valid_outcome)))
  }
  if (n_levels != 2) {
    stop("Logistic regression requires a binary outcome with exactly 2 observed levels.")
  }
  if (is.numeric(valid_outcome) && !all(sort(unique(valid_outcome)) %in% c(0, 1))) {
    warning("Numeric binary outcomes are interpreted by glm(binomial) on the logit scale; 0/1 coding is recommended.")
  }

  model <- stats::glm(formula, data = data, family = stats::binomial())
  model_summary <- summary(model)
  coef_mat <- as.data.frame(model_summary$coefficients)
  coef_mat$Term <- rownames(coef_mat)
  rownames(coef_mat) <- NULL

  z_crit <- stats::qnorm((1 + conf_level) / 2)
  estimate <- coef_mat$Estimate
  std_error <- coef_mat$`Std. Error`
  p_values <- coef_mat$`Pr(>|z|)`
  odds_ratio <- exp(estimate)
  or_low <- exp(estimate - z_crit * std_error)
  or_high <- exp(estimate + z_crit * std_error)

  coef_tbl <- data.frame(
    Term = coef_mat$Term,
    Estimate = round(estimate, 4),
    `Std. Error` = round(std_error, 4),
    `z Statistic` = round(coef_mat$`z value`, 4),
    `p-value` = .format_p_value(p_values),
    `Odds Ratio` = round(odds_ratio, 4),
    `OR CI Lower` = round(or_low, 4),
    `OR CI Upper` = round(or_high, 4),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  null_dev <- model$null.deviance
  resid_dev <- model$deviance
  model_df <- model$df.null - model$df.residual
  lrt_chisq <- null_dev - resid_dev
  p_overall <- stats::pchisq(lrt_chisq, df = model_df, lower.tail = FALSE)
  pseudo_r2 <- if (!is.na(null_dev) && null_dev > 0) 1 - (resid_dev / null_dev) else NA_real_

  fit_tbl <- data.frame(
    Metric = c("Null deviance", "Residual deviance", "Model df",
               "Likelihood-ratio \u03c7\u00b2", "Overall p-value",
               "McFadden pseudo-R\u00b2", "AIC", "BIC", "N"),
    Value = c(round(null_dev, 4), round(resid_dev, 4), model_df,
              round(lrt_chisq, 4), .format_p_value(p_overall),
              round(pseudo_r2, 4), round(stats::AIC(model), 4),
              round(stats::BIC(model), 4), stats::nobs(model)),
    stringsAsFactors = FALSE
  )

  diagnostics <- data.frame(
    Metric = c("Classification cutoff", "Accuracy", "Sensitivity",
               "Specificity", "Null deviance", "Residual deviance"),
    Value = c("0.50",
              round(mean((stats::fitted(model) >= 0.5) == model$y, na.rm = TRUE), 4),
              round(sum(stats::fitted(model) >= 0.5 & model$y == 1, na.rm = TRUE) /
                      sum(model$y == 1, na.rm = TRUE), 4),
              round(sum(stats::fitted(model) < 0.5 & model$y == 0, na.rm = TRUE) /
                      sum(model$y == 0, na.rm = TRUE), 4),
              round(null_dev, 4), round(resid_dev, 4)),
    stringsAsFactors = FALSE
  )
  conf_tbl <- table(
    Actual = factor(model$y, levels = c(0, 1)),
    Predicted = factor(ifelse(stats::fitted(model) >= 0.5, 1, 0), levels = c(0, 1))
  )
  confusion <- as.data.frame.matrix(conf_tbl)
  confusion <- cbind(Actual = rownames(confusion), confusion, row.names = NULL)
  additional_tables <- list(
    "Classification Diagnostics" = diagnostics,
    "Confusion Matrix" = confusion
  )

  term_details <- data.frame(
    term = coef_mat$Term,
    estimate = estimate,
    odds_ratio = odds_ratio,
    p.value = p_values,
    stringsAsFactors = FALSE
  )

  metrics <- list(
    p_value_overall = p_overall,
    lrt_chisq       = lrt_chisq,
    model_df        = model_df,
    pseudo_r2       = pseudo_r2,
    aic             = stats::AIC(model),
    bic             = stats::BIC(model),
    term_details    = term_details
  )

  explanation <- .generate_logistic_regression_narrative(metrics, formula_str)

  structure(
    list(
      test_type          = "logistic_regression",
      formula_str        = formula_str,
      raw_model          = model,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      additional_tables  = additional_tables,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

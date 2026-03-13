#' Run a Linear Regression with Automated Narrative Reporting
#'
#' Executes a standard OLS linear regression using \code{stats::lm()}, extracts
#' key metrics via the \code{broom} package, and automatically generates a
#' plain-language narrative explanation via the Narrative Generator Module.
#'
#' @param formula A \code{formula} object or a character string formula (e.g.,
#'   \code{"mpg ~ wt + hp"}). Passed directly to \code{stats::lm()}.
#' @param data A data frame containing the variables referenced in \code{formula}.
#' @param alpha Significance threshold used in narrative generation. Default \code{0.05}.
#'
#' @return An object of class \code{"easystat_result"} (an R \code{list}) with:
#'   \describe{
#'     \item{\code{test_type}}{Character: \code{"regression"}}
#'     \item{\code{formula_str}}{Character string of the formula used}
#'     \item{\code{raw_model}}{The raw \code{lm} object for advanced use}
#'     \item{\code{coefficients_table}}{Tidy data frame of coefficients, SEs, t-stats, p-values}
#'     \item{\code{model_fit_table}}{Data frame with R\eqn{^2}, Adjusted R\eqn{^2}, F-statistic, p-value}
#'     \item{\code{explanation}}{Plain-language narrative string}
#'   }
#'
#' @examples
#' result <- easy_regression(mpg ~ wt + hp, data = mtcars)
#' print(result)
#'
#' @export
easy_regression <- function(formula, data, alpha = 0.05) {

  # ---- Input validation ----
  if (is.character(formula)) formula <- stats::as.formula(formula)
  if (!inherits(formula, "formula")) stop("'formula' must be a formula object or a character string.")
  if (!is.data.frame(data))          stop("'data' must be a data frame.")

  formula_str <- deparse(formula)

  # ---- Step 1: Core Statistical Engine ----
  model <- stats::lm(formula, data = data)

  # ---- Step 2: Metric Extractor Module (broom) ----
  coef_tbl <- broom::tidy(model)
  coef_tbl <- as.data.frame(coef_tbl)
  colnames(coef_tbl) <- c("Term", "Estimate", "Std. Error", "t Statistic", "p-value")

  glance_df  <- broom::glance(model)
  r_sq       <- glance_df$r.squared
  adj_r_sq   <- glance_df$adj.r.squared
  f_stat     <- glance_df$statistic
  p_overall  <- glance_df$p.value
  df1        <- glance_df$df
  df2        <- glance_df$df.residual

  fit_tbl <- data.frame(
    Metric  = c("R-squared", "Adjusted R-squared", "F-statistic",
                "Model df", "Residual df", "Overall p-value"),
    Value   = c(round(r_sq, 6), round(adj_r_sq, 6), round(f_stat, 4),
                df1, df2, format.pval(p_overall, digits = 4, eps = 0.0001)),
    stringsAsFactors = FALSE
  )

  # Metrics bundle fed to Narrative Generator
  term_df <- broom::tidy(model)
  metrics <- list(
    p_value_overall = p_overall,
    r_squared       = r_sq,
    adj_r_squared   = adj_r_sq,
    f_statistic     = f_stat,
    df1             = df1,
    df2             = df2,
    n_predictors    = df1,
    term_details    = term_df[, c("term", "estimate", "p.value")]
  )

  # ---- Step 3: Narrative Generator Module ----
  explanation <- .generate_regression_narrative(metrics, formula_str)

  # ---- Step 4: Unified Result Object ----
  result <- structure(
    list(
      test_type          = "regression",
      formula_str        = formula_str,
      raw_model          = model,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )

  result
}

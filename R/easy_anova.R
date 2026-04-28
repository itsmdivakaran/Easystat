#' Run a One-Way ANOVA with Automated Narrative Reporting
#'
#' Executes a one-way ANOVA using \code{stats::aov()}, extracts key metrics
#' via \code{broom}, computes eta-squared as an effect-size measure, and
#' generates a plain-language narrative via the Narrative Generator Module.
#'
#' @param formula A \code{formula} of the form \code{outcome ~ group_factor}, or
#'   a character string. Passed directly to \code{stats::aov()}.
#' @param data A data frame containing the variables in \code{formula}.
#' @param alpha Significance threshold for the narrative. Default \code{0.05}.
#'
#' @return An object of class \code{"easystat_result"} with:
#'   \describe{
#'     \item{\code{test_type}}{Character: \code{"anova"}}
#'     \item{\code{formula_str}}{Character string of the formula used}
#'     \item{\code{raw_model}}{The raw \code{aov} object}
#'     \item{\code{coefficients_table}}{ANOVA table (SS, df, MS, F, p)}
#'     \item{\code{model_fit_table}}{Summary metrics (F-statistic, eta-squared, p-value)}
#'     \item{\code{explanation}}{Plain-language narrative string}
#'   }
#'
#' @examples
#' result <- easy_anova(Sepal.Length ~ Species, data = iris)
#' print(result)
#'
#' @export
easy_anova <- function(formula, data, alpha = 0.05) {

  # ---- Input validation ----
  if (is.character(formula)) formula <- stats::as.formula(formula)
  if (!inherits(formula, "formula")) stop("'formula' must be a formula object or a character string.")
  if (!is.data.frame(data))          stop("'data' must be a data frame.")

  formula_str <- deparse(formula)

  # ---- Step 1: Core Statistical Engine ----
  model <- stats::aov(formula, data = data)

  # ---- Step 2: Metric Extractor Module (broom) ----
  tidy_df  <- broom::tidy(model)
  tidy_df  <- as.data.frame(tidy_df)

  # Build clean ANOVA table
  coef_tbl <- tidy_df
  colnames(coef_tbl) <- c("Source", "df", "Sum of Squares", "Mean Square",
                           "F Statistic", "p-value")
  coef_tbl[, 2:5] <- lapply(coef_tbl[, 2:5], function(v) round(as.numeric(v), 4))
  coef_tbl[, 6]   <- .format_p_value(as.numeric(coef_tbl[, 6]))

  # Extract primary effect row (first non-Residuals row)
  effect_row <- tidy_df[tidy_df$term != "Residuals", , drop = FALSE][1, ]
  resid_row  <- tidy_df[tidy_df$term == "Residuals", , drop = FALSE][1, ]

  f_stat  <- as.numeric(effect_row$statistic)
  p_val   <- as.numeric(effect_row$p.value)
  df_grp  <- as.numeric(effect_row$df)
  df_res  <- as.numeric(resid_row$df)
  ss_grp  <- as.numeric(effect_row$sumsq)
  ss_res  <- as.numeric(resid_row$sumsq)
  eta_sq  <- ss_grp / (ss_grp + ss_res)

  # Count groups
  grp_var  <- all.vars(formula)[2]
  n_groups <- length(unique(data[[grp_var]]))

  fit_tbl <- data.frame(
    Metric = c("F-statistic", "Group df", "Residual df",
               "Overall p-value", "Eta-squared (\u03b7\u00b2)"),
    Value  = c(round(f_stat, 4), df_grp, df_res,
               .format_p_value(p_val),
               round(eta_sq, 4)),
    stringsAsFactors = FALSE
  )

  additional_tables <- .anova_support_tables(model, formula, data, alpha)

  # Metrics bundle
  metrics <- list(
    p_value     = p_val,
    f_statistic = f_stat,
    df_group    = df_grp,
    df_resid    = df_res,
    eta_squared = eta_sq,
    n_groups    = n_groups
  )

  # ---- Step 3: Narrative Generator Module ----
  explanation <- .generate_anova_narrative(metrics, formula_str)

  # ---- Step 4: Unified Result Object ----
  result <- structure(
    list(
      test_type          = "anova",
      formula_str        = formula_str,
      raw_model          = model,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      additional_tables  = additional_tables,
      explanation        = explanation
    ),
    class = "easystat_result"
  )

  result
}

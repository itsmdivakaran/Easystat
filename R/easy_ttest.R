#' Run an Independent-Samples t-Test with Automated Narrative Reporting
#'
#' Executes a two-sample (or one-sample) t-test using \code{stats::t.test()},
#' extracts key metrics via \code{broom}, and generates a plain-language
#' narrative via the Narrative Generator Module.
#'
#' @param x A numeric vector, OR a formula of the form \code{outcome ~ group}
#'   when \code{data} is provided.
#' @param y A numeric vector (second group) when \code{x} is not a formula.
#'   Ignored when \code{x} is a formula.
#' @param data A data frame. Required when \code{x} is a formula.
#' @param mu Null hypothesis value for the mean (one-sample test). Default \code{0}.
#' @param var.equal Logical; assume equal variances? Default \code{FALSE} (Welch).
#' @param conf.level Confidence level. Default \code{0.95}.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An object of class \code{"easystat_result"} with:
#'   \describe{
#'     \item{\code{test_type}}{Character: \code{"ttest"}}
#'     \item{\code{formula_str}}{Description of the comparison}
#'     \item{\code{raw_model}}{The raw \code{htest} object}
#'     \item{\code{coefficients_table}}{Group means and confidence interval}
#'     \item{\code{model_fit_table}}{t-statistic, df, and p-value}
#'     \item{\code{explanation}}{Plain-language narrative string}
#'   }
#'
#' @examples
#' result <- easy_ttest(mpg ~ am, data = mtcars)
#' print(result)
#'
#' @export
easy_ttest <- function(x, y = NULL, data = NULL, mu = 0,
                       var.equal = FALSE, conf.level = 0.95, alpha = 0.05) {

  # ---- Input handling: formula vs. vectors ----
  formula_str <- NULL
  grp1_name   <- "Group 1"
  grp2_name   <- "Group 2"

  if (inherits(x, "formula") || is.character(x)) {
    if (is.character(x)) x <- stats::as.formula(x)
    if (is.null(data)) stop("'data' must be provided when 'x' is a formula.")

    formula_str <- deparse(x)
    vars        <- all.vars(x)
    outcome_var <- vars[1]
    group_var   <- vars[2]

    group_levels <- levels(factor(data[[group_var]]))
    if (length(group_levels) != 2) {
      stop("The grouping variable must have exactly 2 levels for an independent-samples t-test.")
    }
    grp1_name <- as.character(group_levels[1])
    grp2_name <- as.character(group_levels[2])

    # ---- Step 1: Core Statistical Engine ----
    ttest_result <- stats::t.test(x, data = data, var.equal = var.equal,
                                  conf.level = conf.level)
  } else {
    if (!is.numeric(x)) stop("'x' must be a numeric vector or a formula.")
    formula_str <- if (!is.null(y)) "Two-sample comparison (x vs. y)" else "One-sample test"
    # ---- Step 1: Core Statistical Engine ----
    if (!is.null(y)) {
      ttest_result <- stats::t.test(x, y, mu = mu, var.equal = var.equal,
                                    conf.level = conf.level)
      grp1_name <- deparse(substitute(x))
      grp2_name <- deparse(substitute(y))
    } else {
      ttest_result <- stats::t.test(x, mu = mu, conf.level = conf.level)
      grp1_name <- "sample"
      grp2_name <- NULL
    }
  }

  # ---- Step 2: Metric Extractor Module (broom) ----
  tidy_result <- broom::tidy(ttest_result)
  t_stat      <- tidy_result$statistic
  df_val      <- tidy_result$parameter
  p_val       <- tidy_result$p.value
  est1        <- tidy_result$estimate1
  est2        <- if ("estimate2" %in% names(tidy_result)) tidy_result$estimate2 else NA
  conf_lo     <- tidy_result$conf.low
  conf_hi     <- tidy_result$conf.high

  # Coefficients table (group means + CI)
  coef_rows <- list(
    c("Mean (Group 1)", grp1_name, round(est1, 4)),
    c("Mean (Group 2)", grp2_name, round(est2, 4)),
    c("95% CI (lower)", "-", round(conf_lo, 4)),
    c("95% CI (upper)", "-", round(conf_hi, 4))
  )
  coef_tbl <- as.data.frame(do.call(rbind, coef_rows), stringsAsFactors = FALSE)
  colnames(coef_tbl) <- c("Metric", "Label", "Value")

  # Model fit table
  fit_tbl <- data.frame(
    Metric = c("t-statistic", "Degrees of Freedom", "p-value"),
    Value  = c(round(t_stat, 4), round(df_val, 2), format.pval(p_val, digits = 4, eps = 0.0001)),
    stringsAsFactors = FALSE
  )

  # Metrics bundle
  metrics <- list(
    p_value   = p_val,
    statistic = t_stat,
    parameter = df_val,
    estimate1 = est1,
    estimate2 = est2,
    conf_low  = conf_lo,
    conf_high = conf_hi,
    group1    = grp1_name,
    group2    = grp2_name
  )

  # ---- Step 3: Narrative Generator Module ----
  explanation <- .generate_ttest_narrative(metrics, formula_str)

  # ---- Step 4: Unified Result Object ----
  result <- structure(
    list(
      test_type          = "ttest",
      formula_str        = formula_str,
      raw_model          = ttest_result,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )

  result
}

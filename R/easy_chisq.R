#' Chi-Square Tests with Automated Narrative Reporting
#'
#' Runs either a \strong{chi-square test of independence} (two categorical
#' variables) or a \strong{goodness-of-fit test} (one variable vs. expected
#' proportions), extracts Cramér's V as the effect-size measure, and generates
#' a plain-language narrative via the Narrative Generator Module.
#'
#' @param x A factor/character vector, OR a contingency table (matrix), OR a
#'   formula \code{~ var1 + var2} for independence, or \code{~ var1} for GOF.
#' @param y A factor/character vector (second categorical variable) for the
#'   independence test. Ignored when \code{x} is a table or formula.
#' @param data A data frame. Required when \code{x} is a formula.
#' @param p Numeric vector of expected probabilities for the GOF test.
#'   If \code{NULL} (default), equal probabilities are assumed.
#' @param correct Logical; apply Yates' continuity correction? Default \code{TRUE}.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An \code{"easystat_result"} object with:
#'   \describe{
#'     \item{\code{coefficients_table}}{Observed vs. expected frequency table}
#'     \item{\code{model_fit_table}}{Chi-square statistic, df, p-value, Cramér's V}
#'     \item{\code{explanation}}{Plain-language narrative}
#'   }
#'
#' @examples
#' # Independence test
#' result <- easy_chisq(~ cyl + am, data = mtcars)
#' print(result)
#'
#' # Goodness-of-fit
#' result <- easy_chisq(~ cyl, data = mtcars)
#' print(result)
#'
#' @export
easy_chisq <- function(x, y = NULL, data = NULL,
                       p = NULL, correct = TRUE, alpha = 0.05) {

  var1 <- "Variable 1"
  var2 <- NULL
  chisq_type <- "independence"

  # ---- Parse inputs ----
  if (inherits(x, "formula") || is.character(x)) {
    if (is.character(x)) x <- stats::as.formula(x)
    if (is.null(data)) stop("'data' must be provided when 'x' is a formula.")
    vars <- all.vars(x)
    if (length(vars) == 2) {
      var1 <- vars[1]; var2 <- vars[2]
      chisq_type <- "independence"
      tbl <- table(data[[var1]], data[[var2]])
      dimnames(tbl) <- list(var1 = levels(factor(data[[var1]])),
                            var2 = levels(factor(data[[var2]])))
    } else if (length(vars) == 1) {
      var1 <- vars[1]
      chisq_type <- "gof"
      tbl <- table(data[[var1]])
    } else {
      stop("Formula must have 1 or 2 variables.")
    }
  } else if (is.table(x) || is.matrix(x)) {
    tbl <- x
    chisq_type <- if (length(dim(tbl)) == 2) "independence" else "gof"
    var1 <- if (!is.null(rownames(tbl))) "Row Variable" else "Variable"
    var2 <- if (!is.null(colnames(tbl))) "Col Variable" else NULL
  } else {
    if (!is.null(y)) {
      var1 <- deparse(substitute(x))
      var2 <- deparse(substitute(y))
      chisq_type <- "independence"
      tbl <- table(x, y)
    } else {
      var1 <- deparse(substitute(x))
      chisq_type <- "gof"
      tbl <- table(x)
    }
  }

  formula_str <- if (chisq_type == "independence")
    paste0("~ ", var1, " + ", var2) else paste0("~ ", var1)

  # ---- Step 1: Core Statistical Engine ----
  test_result <- if (chisq_type == "gof") {
    if (!is.null(p)) {
      if (length(p) != length(tbl)) stop("'p' length must match the number of categories.")
      stats::chisq.test(tbl, p = p, correct = FALSE)
    } else {
      stats::chisq.test(tbl, correct = FALSE)
    }
  } else {
    stats::chisq.test(tbl, correct = correct)
  }

  # ---- Step 2: Metric Extractor ----
  x2_val  <- as.numeric(test_result$statistic)
  df_val  <- as.numeric(test_result$parameter)
  p_val   <- test_result$p.value
  n_total <- sum(tbl)

  # Cram\u00E9r's V
  k          <- min(dim(tbl)) - 1  # for 1-way GOF, dim(tbl) is 1 so k defaults to 0
  if (chisq_type == "gof") k <- 1
  cramers_v  <- sqrt(x2_val / (n_total * max(k, 1)))

  # Observed vs expected table
  obs_vec  <- as.vector(tbl)
  exp_vec  <- as.vector(test_result$expected)
  if (chisq_type == "independence") {
    cell_labels <- paste0(rep(rownames(tbl), each = ncol(tbl)),
                          " | ", rep(colnames(tbl), nrow(tbl)))
  } else {
    cell_labels <- names(tbl)
  }
  coef_tbl <- data.frame(
    Category         = cell_labels,
    Observed         = obs_vec,
    Expected         = round(exp_vec, 2),
    Residual         = round(obs_vec - exp_vec, 4),
    Std_Residual     = round((obs_vec - exp_vec) / sqrt(exp_vec), 4),
    stringsAsFactors = FALSE
  )

  fit_tbl <- data.frame(
    Metric = c("Chi-square statistic (\u03c7\u00b2)", "Degrees of Freedom",
               "p-value", "N (total)", "Cram\u00e9r's V", "Effect Strength"),
    Value  = c(round(x2_val, 4), df_val,
               .format_p_value(p_val),
               n_total, round(cramers_v, 4),
               .cramers_v_label(cramers_v)),
    stringsAsFactors = FALSE
  )

  additional_tables <- if (chisq_type == "independence") {
    .contingency_tables(tbl, test_result$expected)
  } else {
    list(
      "Goodness-of-fit Table" = data.frame(
        Category = names(tbl),
        Observed = as.vector(tbl),
        Expected = round(as.vector(test_result$expected), 4),
        Percentage = round(as.vector(prop.table(tbl) * 100), 4),
        stringsAsFactors = FALSE
      )
    )
  }

  # ---- Step 3: Narrative ----
  metrics <- list(
    p_value   = p_val,
    statistic = x2_val,
    df        = df_val,
    cramers_v = cramers_v
  )
  explanation <- .generate_chisq_narrative(metrics, chisq_type, var1, var2)

  structure(
    list(
      test_type          = "chisq",
      formula_str        = formula_str,
      raw_model          = test_result,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      additional_tables  = additional_tables,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

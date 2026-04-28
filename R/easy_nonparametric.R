#' Wilcoxon Tests with Automated Narrative Reporting
#'
#' Runs a one-sample, paired, or two-sample Wilcoxon test using
#' \code{stats::wilcox.test()} and returns an \code{"easystat_result"} object.
#'
#' @param x Numeric vector, or a formula of the form \code{outcome ~ group}.
#' @param y Optional numeric vector for paired or two-sample tests.
#' @param data Data frame used when \code{x} is a formula.
#' @param mu Null hypothesized location or location shift. Default \code{0}.
#' @param paired Logical. Use paired test? Default \code{FALSE}.
#' @param alternative \code{"two.sided"}, \code{"less"}, or \code{"greater"}.
#' @param conf_level Confidence level. Default \code{0.95}.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An \code{"easystat_result"} object.
#'
#' @examples
#' result <- easy_wilcox(mpg ~ am, data = mtcars)
#' print(result)
#'
#' @export
easy_wilcox <- function(x, y = NULL, data = NULL, mu = 0, paired = FALSE,
                        alternative = "two.sided", conf_level = 0.95,
                        alpha = 0.05) {
  alternative <- match.arg(alternative, c("two.sided", "less", "greater"))
  formula_str <- NULL
  group1 <- "Sample"
  group2 <- NULL

  if (inherits(x, "formula") || is.character(x)) {
    if (is.character(x)) x <- stats::as.formula(x)
    if (is.null(data)) stop("'data' must be provided when 'x' is a formula.")
    vars <- all.vars(x)
    outcome <- vars[1]
    group <- vars[2]
    levels_g <- levels(factor(data[[group]]))
    if (length(levels_g) != 2) stop("Wilcoxon formula tests require exactly 2 groups.")
    group1 <- levels_g[1]
    group2 <- levels_g[2]
    x_vec <- data[[outcome]][data[[group]] == group1]
    y_vec <- data[[outcome]][data[[group]] == group2]
    formula_str <- deparse(x)
  } else {
    x_vec <- x
    y_vec <- y
    formula_str <- if (is.null(y)) "One-sample Wilcoxon test" else "Wilcoxon comparison"
    if (!is.null(y)) {
      group1 <- deparse(substitute(x))
      group2 <- deparse(substitute(y))
    }
  }

  test <- stats::wilcox.test(x_vec, y_vec, mu = mu, paired = paired,
                             alternative = alternative,
                             conf.int = TRUE, conf.level = conf_level,
                             exact = FALSE)
  p_val <- test$p.value
  stat <- as.numeric(test$statistic)

  median1 <- stats::median(x_vec, na.rm = TRUE)
  median2 <- if (!is.null(y_vec)) stats::median(y_vec, na.rm = TRUE) else NA_real_
  n1 <- sum(!is.na(x_vec))
  n2 <- if (!is.null(y_vec)) sum(!is.na(y_vec)) else NA_integer_

  coef_tbl <- data.frame(
    Metric = c("Median Group 1", "Median Group 2", "n Group 1", "n Group 2",
               paste0(round(conf_level * 100), "% CI lower"),
               paste0(round(conf_level * 100), "% CI upper")),
    Value = c(round(median1, 4), round(median2, 4), n1, n2,
              round(test$conf.int[1], 4), round(test$conf.int[2], 4)),
    stringsAsFactors = FALSE
  )
  fit_tbl <- data.frame(
    Metric = c("W statistic", "p-value", "Alternative", "Paired"),
    Value = c(round(stat, 4), .format_p_value(p_val), alternative, paired),
    stringsAsFactors = FALSE
  )

  explanation <- glue::glue(
    "WILCOXON TEST\nComparison: {formula_str}\n\n",
    "The Wilcoxon test produced W = {round(stat, 4)} and was {.sig_label(p_val, alpha)}. ",
    if (!is.null(group2)) glue::glue("The medians were {round(median1, 4)} for '{group1}' and {round(median2, 4)} for '{group2}'. ")
    else glue::glue("The sample median was {round(median1, 4)}. "),
    if (!is.na(p_val) && p_val < alpha)
      "This supports a statistically meaningful difference in distribution/location."
    else
      "The data do not provide sufficient evidence of a distribution/location difference."
  )

  structure(
    list(
      test_type = "wilcox",
      formula_str = formula_str,
      raw_model = test,
      coefficients_table = coef_tbl,
      model_fit_table = fit_tbl,
      explanation = explanation
    ),
    class = "easystat_result"
  )
}

#' Kruskal-Wallis Test with Automated Narrative Reporting
#'
#' Runs a Kruskal-Wallis rank-sum test for comparing three or more groups.
#'
#' @param formula A formula of the form \code{outcome ~ group}.
#' @param data A data frame.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An \code{"easystat_result"} object.
#'
#' @examples
#' result <- easy_kruskal(Sepal.Length ~ Species, data = iris)
#' print(result)
#'
#' @export
easy_kruskal <- function(formula, data, alpha = 0.05) {
  if (is.character(formula)) formula <- stats::as.formula(formula)
  if (!inherits(formula, "formula")) stop("'formula' must be a formula object or character string.")
  if (!is.data.frame(data)) stop("'data' must be a data frame.")

  vars <- all.vars(formula)
  outcome <- vars[1]
  group <- vars[2]
  test <- stats::kruskal.test(formula, data = data)

  grp <- factor(data[[group]])
  y <- data[[outcome]]
  levels_g <- levels(grp)
  rows <- lapply(levels_g, function(g) {
    vals <- y[grp == g]
    vals <- vals[!is.na(vals)]
    data.frame(
      Group = g,
      N = length(vals),
      Median = round(stats::median(vals), 4),
      Mean_Rank = round(mean(rank(y, na.last = "keep")[grp == g], na.rm = TRUE), 4),
      stringsAsFactors = FALSE
    )
  })
  coef_tbl <- do.call(rbind, rows)

  h <- as.numeric(test$statistic)
  df <- as.numeric(test$parameter)
  p_val <- test$p.value
  n <- sum(!is.na(y) & !is.na(grp))
  k <- length(levels_g)
  eta_sq <- max(0, (h - k + 1) / (n - k))

  fit_tbl <- data.frame(
    Metric = c("Kruskal-Wallis H", "Degrees of Freedom", "p-value",
               "Eta-squared estimate", "Groups", "N"),
    Value = c(round(h, 4), df, .format_p_value(p_val),
              round(eta_sq, 4), k, n),
    stringsAsFactors = FALSE
  )

  explanation <- glue::glue(
    "KRUSKAL-WALLIS TEST\nFormula: {deparse(formula)}\n\n",
    "The Kruskal-Wallis test produced H({df}) = {round(h, 4)} and was {.sig_label(p_val, alpha)}. ",
    "The estimated rank-based eta-squared is {round(eta_sq, 4)}. ",
    if (!is.na(p_val) && p_val < alpha)
      "At least one group distribution differs; pairwise Wilcoxon tests with p-value adjustment are recommended."
    else
      "The data do not provide sufficient evidence that the group distributions differ."
  )

  structure(
    list(
      test_type = "kruskal",
      formula_str = deparse(formula),
      raw_model = test,
      coefficients_table = coef_tbl,
      model_fit_table = fit_tbl,
      explanation = explanation
    ),
    class = "easystat_result"
  )
}

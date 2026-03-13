#' F-Test for Equality of Variances with Automated Narrative Reporting
#'
#' Performs an F-test to compare the variances of two independent groups using
#' \code{stats::var.test()}, extracts the F-statistic, degrees of freedom,
#' p-value, variance ratio, and confidence interval, and generates a
#' plain-language narrative that includes a practical recommendation for
#' downstream t-test selection (equal vs. unequal variances).
#'
#' @param x A numeric vector (Group 1), OR a formula \code{outcome ~ group}.
#' @param y A numeric vector (Group 2). Ignored when \code{x} is a formula.
#' @param data A data frame. Required when \code{x} is a formula.
#' @param ratio Hypothesised ratio of variances under H0. Default \code{1}.
#' @param alternative \code{"two.sided"} (default), \code{"less"}, or \code{"greater"}.
#' @param conf_level Confidence level for the variance ratio CI. Default \code{0.95}.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An \code{"easystat_result"} object.
#'
#' @examples
#' result <- easy_ftest(mpg ~ am, data = mtcars)
#' print(result)
#'
#' @export
easy_ftest <- function(x, y = NULL, data = NULL, ratio = 1,
                       alternative = "two.sided",
                       conf_level = 0.95, alpha = 0.05) {

  alt_choices <- c("two.sided", "less", "greater")
  alternative <- match.arg(alternative, alt_choices)

  label     <- NULL
  grp1_name <- "Group 1"
  grp2_name <- "Group 2"

  # ---- Parse inputs ----
  if (inherits(x, "formula") || is.character(x)) {
    if (is.character(x)) x <- stats::as.formula(x)
    if (is.null(data)) stop("'data' must be provided when 'x' is a formula.")
    vars <- all.vars(x)
    outcome_var <- vars[1]; group_var <- vars[2]
    label <- deparse(x)
    grp_levels <- levels(factor(data[[group_var]]))
    if (length(grp_levels) != 2)
      stop("The grouping variable must have exactly 2 levels.")
    grp1_name <- grp_levels[1]; grp2_name <- grp_levels[2]
    x_vec <- data[[outcome_var]][data[[group_var]] == grp_levels[1]]
    y_vec <- data[[outcome_var]][data[[group_var]] == grp_levels[2]]
  } else {
    if (is.null(y)) stop("'y' is required for a two-sample F-test when 'x' is a vector.")
    x_vec     <- x
    y_vec     <- y
    grp1_name <- deparse(substitute(x))
    grp2_name <- deparse(substitute(y))
    label     <- paste(grp1_name, "vs.", grp2_name)
  }

  x_vec <- x_vec[!is.na(x_vec)]
  y_vec <- y_vec[!is.na(y_vec)]
  if (length(x_vec) < 2) stop("Group 1 must have at least 2 non-missing observations.")
  if (length(y_vec) < 2) stop("Group 2 must have at least 2 non-missing observations.")

  # ---- Step 1: Core Statistical Engine ----
  vtest <- stats::var.test(x_vec, y_vec, ratio       = ratio,
                            alternative = alternative,
                            conf.level  = conf_level)

  # ---- Step 2: Metric Extractor ----
  tidy_v   <- broom::tidy(vtest)
  f_stat   <- tidy_v$statistic
  df1_val  <- tidy_v$num.df
  df2_val  <- tidy_v$den.df
  p_val    <- tidy_v$p.value
  var_ratio <- f_stat
  ci_lo    <- tidy_v$conf.low
  ci_hi    <- tidy_v$conf.high

  var1  <- round(stats::var(x_vec), 6)
  var2  <- round(stats::var(y_vec), 6)
  sd1   <- round(stats::sd(x_vec), 6)
  sd2   <- round(stats::sd(y_vec), 6)
  n1    <- length(x_vec)
  n2    <- length(y_vec)

  coef_tbl <- data.frame(
    Metric = c(paste0("Variance \u2014 ", grp1_name), paste0("Variance \u2014 ", grp2_name),
               paste0("SD \u2014 ", grp1_name),       paste0("SD \u2014 ", grp2_name),
               paste0("n \u2014 ", grp1_name),        paste0("n \u2014 ", grp2_name),
               "Variance Ratio (F)",
               paste0(round(conf_level * 100), "% CI lower (ratio)"),
               paste0(round(conf_level * 100), "% CI upper (ratio)")),
    Value  = c(var1, var2, sd1, sd2, n1, n2,
               round(var_ratio, 6), round(ci_lo, 6), round(ci_hi, 6)),
    stringsAsFactors = FALSE
  )

  fit_tbl <- data.frame(
    Metric = c("F-statistic", "Numerator df", "Denominator df",
               "p-value", "Alternative", "Conclusion"),
    Value  = c(round(f_stat, 4), df1_val, df2_val,
               format.pval(p_val, digits = 4, eps = 0.0001),
               alternative,
               if (!is.na(p_val) && p_val < alpha) "Variances are UNEQUAL" else "Variances are EQUAL"),
    stringsAsFactors = FALSE
  )

  metrics <- list(
    p_value   = p_val,
    f_stat    = f_stat,
    df1       = df1_val,
    df2       = df2_val,
    var_ratio = var_ratio,
    ci_lower  = ci_lo,
    ci_upper  = ci_hi
  )

  explanation <- .generate_ftest_narrative(metrics, label)

  structure(
    list(
      test_type          = "ftest",
      formula_str        = label,
      raw_model          = vtest,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

#' One-Sample and Two-Sample Z-Tests with Automated Narrative Reporting
#'
#' Performs a z-test using the normal distribution. When the population
#' standard deviation (\code{sigma}) is not provided, the sample SD is used
#' (valid for large samples, n \eqn{\geq} 30, by the Central Limit Theorem).
#' Key metrics — z-statistic, p-value, confidence interval, and Cohen's d —
#' are extracted and fed to the Narrative Generator Module.
#'
#' @param x A numeric vector (Group 1), OR a formula \code{outcome ~ group}
#'   for a two-sample test when \code{data} is provided.
#' @param y A numeric vector (Group 2) for a two-sample test. Ignored when
#'   \code{x} is a formula.
#' @param data A data frame. Required when \code{x} is a formula.
#' @param mu Hypothesized population mean (one-sample) or mean difference
#'   (two-sample). Default \code{0}.
#' @param sigma Known population SD for Group 1 (or the single group).
#'   If \code{NULL} (default), the sample SD is used.
#' @param sigma2 Known population SD for Group 2. If \code{NULL}, uses
#'   the sample SD of Group 2.
#' @param alternative \code{"two.sided"} (default), \code{"less"},
#'   or \code{"greater"}.
#' @param conf_level Confidence level. Default \code{0.95}.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An \code{"easystat_result"} object.
#'
#' @examples
#' # One-sample z-test (large n, CLT)
#' result <- easy_ztest(mtcars$mpg, mu = 20)
#' print(result)
#'
#' # Two-sample z-test via formula
#' result <- easy_ztest(mpg ~ am, data = mtcars)
#' print(result)
#'
#' @export
easy_ztest <- function(x, y = NULL, data = NULL, mu = 0,
                       sigma = NULL, sigma2 = NULL,
                       alternative = "two.sided",
                       conf_level = 0.95, alpha = 0.05) {

  alt_choices <- c("two.sided", "less", "greater")
  alternative <- match.arg(alternative, alt_choices)

  label       <- NULL
  grp1_name   <- "Sample"
  grp2_name   <- NULL
  two_sample  <- FALSE

  # ---- Parse inputs ----
  if (inherits(x, "formula") || is.character(x)) {
    if (is.character(x)) x <- stats::as.formula(x)
    if (is.null(data)) stop("'data' must be provided when 'x' is a formula.")
    vars <- all.vars(x)
    outcome_var <- vars[1]; group_var <- vars[2]
    label <- deparse(x)
    grp_levels <- levels(factor(data[[group_var]]))
    if (length(grp_levels) != 2)
      stop("The grouping variable must have exactly 2 levels for a two-sample z-test.")
    grp1_name  <- grp_levels[1]; grp2_name <- grp_levels[2]
    x_vec <- data[[outcome_var]][data[[group_var]] == grp_levels[1]]
    y_vec <- data[[outcome_var]][data[[group_var]] == grp_levels[2]]
    two_sample <- TRUE
  } else {
    x_vec <- x
    if (!is.null(y)) { y_vec <- y; two_sample <- TRUE }
    label <- if (two_sample) "Two-sample comparison (x vs. y)" else "One-sample test"
    grp1_name <- deparse(substitute(x))
    grp2_name <- if (two_sample) deparse(substitute(y)) else NULL
  }

  x_vec <- x_vec[!is.na(x_vec)]
  n1    <- length(x_vec)
  if (n1 < 2) stop("Group 1 must have at least 2 observations.")
  x_bar <- mean(x_vec)
  s1    <- if (is.null(sigma))  stats::sd(x_vec) else sigma

  if (n1 < 30 && is.null(sigma))
    warning("n < 30 and sigma unknown: z-test assumes CLT (large-sample approximation). Consider t-test instead.")

  z_crit <- stats::qnorm((1 + conf_level) / 2)

  if (!two_sample) {
    # ---- ONE-SAMPLE Z-TEST ----
    se_1   <- s1 / sqrt(n1)
    z_stat <- (x_bar - mu) / se_1
    ci_lo  <- x_bar - z_crit * se_1
    ci_hi  <- x_bar + z_crit * se_1
    d      <- (x_bar - mu) / s1

    p_val  <- switch(alternative,
      two.sided = 2 * stats::pnorm(-abs(z_stat)),
      less      = stats::pnorm(z_stat),
      greater   = stats::pnorm(z_stat, lower.tail = FALSE)
    )

    coef_tbl <- data.frame(
      Metric = c(paste0("Sample mean (", grp1_name, ")"),
                 "Hypothesised mean (\u03bc\u2080)",
                 "Mean difference",
                 paste0(round(conf_level * 100), "% CI lower"),
                 paste0(round(conf_level * 100), "% CI upper"),
                 "SD used (sigma)",
                 "Standard Error"),
      Value  = c(round(x_bar, 6), mu, round(x_bar - mu, 6),
                 round(ci_lo, 6), round(ci_hi, 6),
                 round(s1, 6), round(se_1, 6)),
      stringsAsFactors = FALSE
    )
    metrics <- list(test_type_z = "one_sample", z_stat = z_stat, p_value = p_val,
                    x_bar = x_bar, mu = mu, ci_lower = ci_lo, ci_upper = ci_hi,
                    cohens_d = d)

  } else {
    # ---- TWO-SAMPLE Z-TEST ----
    y_vec  <- y_vec[!is.na(y_vec)]
    n2     <- length(y_vec)
    if (n2 < 2) stop("Group 2 must have at least 2 observations.")
    x_bar2 <- mean(y_vec)
    s2     <- if (is.null(sigma2)) stats::sd(y_vec) else sigma2

    if (n2 < 30 && is.null(sigma2))
      warning("Group 2: n < 30 and sigma unknown. Using CLT approximation.")

    se_2   <- sqrt(s1^2 / n1 + s2^2 / n2)
    diff   <- x_bar - x_bar2
    z_stat <- (diff - mu) / se_2
    ci_lo  <- diff - z_crit * se_2
    ci_hi  <- diff + z_crit * se_2

    # Pooled SD for Cohen's d
    sp     <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
    d      <- diff / sp

    p_val  <- switch(alternative,
      two.sided = 2 * stats::pnorm(-abs(z_stat)),
      less      = stats::pnorm(z_stat),
      greater   = stats::pnorm(z_stat, lower.tail = FALSE)
    )

    coef_tbl <- data.frame(
      Metric = c(paste0("Mean \u2014 ", grp1_name), paste0("Mean \u2014 ", grp2_name),
                 "Mean difference",
                 paste0(round(conf_level * 100), "% CI lower"),
                 paste0(round(conf_level * 100), "% CI upper"),
                 paste0("SD (", grp1_name, ")"), paste0("SD (", grp2_name, ")"),
                 paste0("n (", grp1_name, ")"),  paste0("n (", grp2_name, ")")),
      Value  = c(round(x_bar, 6), round(x_bar2, 6), round(diff, 6),
                 round(ci_lo, 6), round(ci_hi, 6),
                 round(s1, 6), round(s2, 6), n1, n2),
      stringsAsFactors = FALSE
    )
    metrics <- list(test_type_z = "two_sample", z_stat = z_stat, p_value = p_val,
                    x_bar = x_bar, x_bar2 = x_bar2, mu = mu,
                    ci_lower = ci_lo, ci_upper = ci_hi, cohens_d = d)
  }

  fit_tbl <- data.frame(
    Metric = c("z-statistic", "p-value", "Alternative", "Cohen's d", "Effect size class"),
    Value  = c(round(z_stat, 4),
               .format_p_value(p_val),
               alternative,
               round(metrics$cohens_d, 4),
               .cohens_d_label(metrics$cohens_d)),
    stringsAsFactors = FALSE
  )

  explanation <- .generate_ztest_narrative(metrics, label)

  structure(
    list(
      test_type          = "ztest",
      formula_str        = label,
      raw_model          = list(z = z_stat, p = p_val, ci = c(ci_lo, ci_hi)),
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

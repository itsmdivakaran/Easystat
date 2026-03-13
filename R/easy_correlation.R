#' Correlation Analysis with Automated Narrative Reporting
#'
#' Computes bivariate or pairwise correlations (Pearson, Spearman, or Kendall)
#' with significance tests and confidence intervals. For two variables a full
#' narrative is generated; for multiple variables a correlation matrix is
#' returned with a summary digest.
#'
#' @param x A numeric vector, a data frame, OR a formula \code{~ x + y}.
#' @param y A numeric vector (paired with \code{x}). Ignored when \code{x}
#'   is a formula or data frame.
#' @param data A data frame. Required when \code{x} is a formula.
#' @param vars Character vector of column names when \code{x} is a data frame
#'   and pairwise analysis is desired. Default \code{NULL} = all numeric cols.
#' @param method Correlation method: \code{"pearson"} (default),
#'   \code{"spearman"}, or \code{"kendall"}.
#' @param conf_level Confidence level for Pearson CI. Default \code{0.95}.
#' @param alpha Significance threshold for narrative. Default \code{0.05}.
#'
#' @return An \code{"easystat_result"} object.
#'
#' @examples
#' result <- easy_correlation(~ mpg + wt, data = mtcars)
#' print(result)
#'
#' result <- easy_correlation(mtcars, vars = c("mpg", "hp", "wt", "disp"))
#' print(result)
#'
#' @export
easy_correlation <- function(x, y = NULL, data = NULL, vars = NULL,
                              method = "pearson",
                              conf_level = 0.95, alpha = 0.05) {

  method <- match.arg(method, c("pearson", "spearman", "kendall"))

  # ---- Dispatch: bivariate vs. matrix ----
  if (is.data.frame(x) && is.null(y)) {
    return(.easy_corr_matrix(x, vars, method, conf_level, alpha))
  }

  if ((inherits(x, "formula") || is.character(x))) {
    if (is.character(x)) x <- stats::as.formula(x)
    if (is.null(data)) stop("'data' must be provided when 'x' is a formula.")
    vars2 <- all.vars(x)
    if (length(vars2) == 2) {
      xv <- data[[vars2[1]]]
      yv <- data[[vars2[2]]]
      xname <- vars2[1]; yname <- vars2[2]
      if (!is.numeric(xv) || !is.numeric(yv))
        stop("Both variables in the formula must be numeric for correlation.")
      formula_str <- deparse(x)
    } else if (length(vars2) > 2) {
      sub_data <- data[, vars2, drop = FALSE]
      return(.easy_corr_matrix(sub_data, vars2, method, conf_level, alpha))
    } else {
      stop("Formula must name at least two variables.")
    }
  } else {
    xv <- x
    yv <- y
    if (is.null(yv)) stop("'y' must be provided when 'x' is a numeric vector.")
    xname <- deparse(substitute(x))
    yname <- deparse(substitute(y))
    formula_str <- paste("~", xname, "+", yname)
  }

  # ---- Bivariate correlation ----
  complete_idx <- stats::complete.cases(xv, yv)
  xv <- xv[complete_idx]; yv <- yv[complete_idx]
  n  <- length(xv)
  if (n < 3) stop("At least 3 complete observations are required for correlation.")

  cor_test <- stats::cor.test(xv, yv, method = method, conf.level = conf_level)
  r_val    <- as.numeric(cor_test$estimate)
  p_val    <- cor_test$p.value
  ci_lo    <- if (!is.null(cor_test$conf.int)) cor_test$conf.int[1] else NA_real_
  ci_hi    <- if (!is.null(cor_test$conf.int)) cor_test$conf.int[2] else NA_real_
  t_stat   <- if (!is.null(cor_test$statistic)) as.numeric(cor_test$statistic) else NA_real_

  # Slope and intercept from simple regression (for scatter annotation)
  lm_fit <- stats::lm(yv ~ xv)
  slope  <- stats::coef(lm_fit)[2]
  interc <- stats::coef(lm_fit)[1]

  coef_tbl <- data.frame(
    Metric = c(paste0("r (", tools::toTitleCase(method), ")"),
               "r\u00b2 (shared variance %)",
               paste0(round(conf_level * 100), "% CI lower"),
               paste0(round(conf_level * 100), "% CI upper"),
               "t-statistic", "n (valid pairs)",
               "Regression slope", "Regression intercept"),
    Value  = c(round(r_val, 6),
               paste0(round(r_val^2 * 100, 2), "%"),
               round(ci_lo, 6), round(ci_hi, 6),
               round(t_stat, 4), n,
               round(slope, 6), round(interc, 6)),
    stringsAsFactors = FALSE
  )

  fit_tbl <- data.frame(
    Metric = c("p-value", "Correlation strength",
               "Direction", "Effect size class"),
    Value  = c(format.pval(p_val, digits = 4, eps = 0.0001),
               .corr_label(r_val),
               if (r_val >= 0) "Positive" else "Negative",
               .cohens_d_label(r_val)),
    stringsAsFactors = FALSE
  )

  metrics <- list(r = r_val, p_value = p_val, ci_lower = ci_lo,
                  ci_upper = ci_hi, method = method,
                  x_var = xname, y_var = yname,
                  n = n, slope = slope)

  explanation <- .generate_correlation_narrative(metrics)

  structure(
    list(
      test_type          = "correlation",
      formula_str        = formula_str,
      raw_model          = cor_test,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

# ---------------------------------------------------------------------------
# Internal: pairwise correlation matrix
# ---------------------------------------------------------------------------
.easy_corr_matrix <- function(data, vars = NULL, method = "pearson",
                               conf_level = 0.95, alpha = 0.05) {
  if (is.null(vars)) vars <- names(data)[sapply(data, is.numeric)]
  if (length(vars) < 2) stop("Need at least 2 numeric variables.")
  mat <- data[, vars, drop = FALSE]
  n_v <- length(vars)

  # Correlation matrix
  corr_mat <- stats::cor(mat, use = "pairwise.complete.obs", method = method)

  # p-value matrix
  p_mat <- matrix(NA_real_, nrow = n_v, ncol = n_v,
                  dimnames = list(vars, vars))
  for (i in seq_len(n_v)) {
    for (j in seq_len(n_v)) {
      if (i != j) {
        idx <- stats::complete.cases(mat[[i]], mat[[j]])
        if (sum(idx) >= 3) {
          ct <- stats::cor.test(mat[[vars[i]]][idx], mat[[vars[j]]][idx],
                                method = method)
          p_mat[i, j] <- ct$p.value
        }
      }
    }
  }

  # Build long-format coefficient table
  rows <- list()
  for (i in seq_len(n_v - 1)) {
    for (j in (i + 1):n_v) {
      rows[[length(rows) + 1]] <- data.frame(
        Var1      = vars[i],
        Var2      = vars[j],
        r         = round(corr_mat[i, j], 4),
        r_squared = round(corr_mat[i, j]^2, 4),
        p_value   = format.pval(p_mat[i, j], digits = 4, eps = 0.0001),
        Strength  = .corr_label(corr_mat[i, j]),
        Direction = if (corr_mat[i, j] >= 0) "Positive" else "Negative",
        Sig       = if (!is.na(p_mat[i, j]) && p_mat[i, j] < alpha) "Yes" else "No",
        stringsAsFactors = FALSE
      )
    }
  }
  coef_tbl <- do.call(rbind, rows)

  # Summary
  all_r <- corr_mat[lower.tri(corr_mat)]
  fit_tbl <- data.frame(
    Metric = c("Method", "Variables", "Pairs examined",
               "Strongest correlation", "Weakest correlation",
               "Pairs significant"),
    Value  = c(tools::toTitleCase(method), n_v, nrow(coef_tbl),
               round(max(abs(all_r), na.rm = TRUE), 4),
               round(min(abs(all_r), na.rm = TRUE), 4),
               sum(coef_tbl$Sig == "Yes", na.rm = TRUE)),
    stringsAsFactors = FALSE
  )

  # Narrative for matrix
  n_strong   <- sum(abs(all_r) >= 0.70, na.rm = TRUE)
  n_moderate <- sum(abs(all_r) >= 0.30 & abs(all_r) < 0.70, na.rm = TRUE)
  metrics    <- list(
    method = method, n_vars = n_v, n_pairs = nrow(coef_tbl),
    corr_values = all_r
  )
  explanation <- .generate_corr_heatmap_interpretation(metrics)

  structure(
    list(
      test_type          = "correlation_matrix",
      formula_str        = paste("Pairwise:", paste(vars, collapse = ", ")),
      raw_model          = list(corr_matrix = corr_mat, p_matrix = p_mat),
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation,
      corr_matrix_raw    = corr_mat  # extra: used by easy_correlation_heatmap
    ),
    class = "easystat_result"
  )
}

# Descriptive Statistics and Group Summary Functions
# Provides comprehensive descriptive statistics for numeric variables,
# including measures of central tendency, spread, shape, and normality,
# plus group-wise summaries and automatic narrative generation.

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------
.mode_val <- function(x) {
  x <- x[!is.na(x)]
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

.skewness_calc <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  if (n < 3) return(NA_real_)
  (n / ((n - 1) * (n - 2))) * sum(((x - mean(x)) / stats::sd(x))^3)
}

.kurtosis_calc <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  if (n < 4) return(NA_real_)
  k_raw <- ((n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3))) *
            sum(((x - mean(x)) / stats::sd(x))^4)
  k_cor <- (3 * (n - 1)^2) / ((n - 2) * (n - 3))
  k_raw - k_cor
}

.shapiro_p <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 3 || length(x) > 5000) return(NA_real_)
  tryCatch(stats::shapiro.test(x)$p.value, error = function(e) NA_real_)
}

.describe_one <- function(x, var_name = "x", digits = 4, conf_level = 0.95) {
  x_clean  <- x[!is.na(x)]
  n        <- length(x_clean)
  n_miss   <- sum(is.na(x))
  if (n == 0) stop("No non-missing values found in '", var_name, "'.")

  mn       <- mean(x_clean)
  med      <- stats::median(x_clean)
  mod      <- .mode_val(x_clean)
  trim_mn  <- mean(x_clean, trim = 0.05)
  s        <- if (n > 1) stats::sd(x_clean)  else NA_real_
  v        <- if (n > 1) stats::var(x_clean) else NA_real_
  se       <- if (n > 1) s / sqrt(n)         else NA_real_
  cv_pct   <- if (!is.na(s) && mn != 0) (s / abs(mn)) * 100 else NA_real_
  q        <- stats::quantile(x_clean, c(0, 0.25, 0.50, 0.75, 1))
  iqr_val  <- as.numeric(q[4] - q[2])
  rng      <- as.numeric(q[5] - q[1])
  sk       <- .skewness_calc(x_clean)
  kt       <- .kurtosis_calc(x_clean)
  sw_p     <- .shapiro_p(x_clean)

  # CI for mean
  t_crit   <- if (n > 1) stats::qt((1 + conf_level) / 2, df = n - 1) else NA_real_
  ci_lo    <- mn - t_crit * se
  ci_hi    <- mn + t_crit * se

  list(
    var_name   = var_name,
    n          = n,
    n_missing  = n_miss,
    mean       = mn,
    trimmed_mean = trim_mn,
    median     = med,
    mode       = mod,
    sd         = s,
    variance   = v,
    se_mean    = se,
    cv_pct     = cv_pct,
    min        = as.numeric(q[1]),
    q1         = as.numeric(q[2]),
    q3         = as.numeric(q[4]),
    max        = as.numeric(q[5]),
    range_val  = rng,
    iqr        = iqr_val,
    skewness   = sk,
    kurtosis   = kt,
    shapiro_p  = sw_p,
    ci_lower   = ci_lo,
    ci_upper   = ci_hi
  )
}

# ---------------------------------------------------------------------------
# easy_describe  \u2014 Comprehensive Descriptive Statistics
# ---------------------------------------------------------------------------

#' Comprehensive Descriptive Statistics with Narrative
#'
#' Computes a rich set of descriptive statistics for one or more numeric
#' variables, including measures of central tendency, dispersion, shape
#' (skewness, kurtosis), and normality (Shapiro-Wilk), together with an
#' automatic plain-language narrative interpretation.
#'
#' @param data A numeric vector \strong{or} a data frame.
#' @param vars Character vector of column names to describe when \code{data}
#'   is a data frame. If \code{NULL} (default), all numeric columns are used.
#' @param digits Number of decimal places in the summary table. Default \code{4}.
#' @param conf_level Confidence level for the mean CI. Default \code{0.95}.
#'
#' @return An \code{"easystat_result"} object with:
#'   \describe{
#'     \item{\code{coefficients_table}}{Wide-format summary statistics table}
#'     \item{\code{model_fit_table}}{Shape and normality digest}
#'     \item{\code{explanation}}{Plain-language narrative (one per variable)}
#'   }
#'
#' @examples
#' result <- easy_describe(mtcars, vars = c("mpg", "hp", "wt"))
#' print(result)
#'
#' @export
easy_describe <- function(data, vars = NULL, digits = 4, conf_level = 0.95) {

  # ---- Normalise input ----
  if (is.numeric(data)) {
    vname <- deparse(substitute(data))
    df    <- data.frame(x = data)
    colnames(df) <- vname
    vars  <- vname
  } else {
    if (!is.data.frame(data)) stop("'data' must be a numeric vector or data frame.")
    if (is.null(vars)) {
      vars <- names(data)[sapply(data, is.numeric)]
    }
    if (length(vars) == 0) stop("No numeric variables found.")
    df <- data[, vars, drop = FALSE]
  }

  # ---- Compute stats per variable ----
  stats_list <- lapply(vars, function(v) .describe_one(df[[v]], v, digits, conf_level))
  names(stats_list) <- vars

  # ---- Build summary table (one row per variable) ----
  rows <- lapply(stats_list, function(m) {
    data.frame(
      Variable   = m$var_name,
      N          = m$n,
      Missing    = m$n_missing,
      Mean       = round(m$mean, digits),
      Median     = round(m$median, digits),
      Mode       = round(m$mode, digits),
      SD         = round(m$sd, digits),
      SE         = round(m$se_mean, digits),
      Variance   = round(m$variance, digits),
      Min        = round(m$min, digits),
      Q1         = round(m$q1, digits),
      Q3         = round(m$q3, digits),
      Max        = round(m$max, digits),
      Range      = round(m$range_val, digits),
      IQR        = round(m$iqr, digits),
      CV_pct     = round(m$cv_pct, digits),
      Skewness   = round(m$skewness, digits),
      Kurtosis   = round(m$kurtosis, digits),
      CI_lower   = round(m$ci_lower, digits),
      CI_upper   = round(m$ci_upper, digits),
      Shapiro_p  = .format_p_value(m$shapiro_p),
      stringsAsFactors = FALSE
    )
  })
  coef_tbl <- do.call(rbind, rows)

  # ---- Shape / normality digest ----
  fit_rows <- lapply(stats_list, function(m) {
    data.frame(
      Variable    = m$var_name,
      Shape       = .skew_label(m$skewness),
      Kurtosis    = .kurt_label(m$kurtosis),
      Normality   = .norm_label(m$shapiro_p),
      Shapiro_p   = .format_p_value(m$shapiro_p),
      stringsAsFactors = FALSE
    )
  })
  fit_tbl <- do.call(rbind, fit_rows)

  # ---- Narrative (concatenate all variables) ----
  narratives <- sapply(stats_list, function(m) .generate_describe_narrative(m, m$var_name))
  explanation <- paste(narratives, collapse = "\n\n---\n\n")

  structure(
    list(
      test_type          = "describe",
      formula_str        = paste("Descriptive:", paste(vars, collapse = ", ")),
      raw_model          = stats_list,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

# ---------------------------------------------------------------------------
# easy_group_summary  \u2014 Group-Wise Descriptive Statistics
# ---------------------------------------------------------------------------

#' Group-Wise Summary Statistics with Narrative
#'
#' Computes descriptive statistics for a numeric outcome variable stratified
#' by a grouping factor, providing both a comparison table and a narrative
#' highlighting which group has the highest/lowest mean and variability.
#'
#' @param formula A formula of the form \code{outcome ~ group}.
#' @param data A data frame containing the variables.
#' @param digits Number of decimal places. Default \code{4}.
#'
#' @return An \code{"easystat_result"} object.
#'
#' @examples
#' result <- easy_group_summary(mpg ~ cyl, data = mtcars)
#' print(result)
#'
#' @export
easy_group_summary <- function(formula, data, digits = 4) {

  if (is.character(formula)) formula <- stats::as.formula(formula)
  if (!is.data.frame(data))  stop("'data' must be a data frame.")

  formula_str <- deparse(formula)
  vars        <- all.vars(formula)
  outcome_var <- vars[1]
  group_var   <- vars[2]

  if (!is.numeric(data[[outcome_var]]))
    stop("'", outcome_var, "' must be numeric.")

  groups  <- unique(data[[group_var]])
  n_grps  <- length(groups)

  # Compute stats per group
  rows <- lapply(groups, function(g) {
    x_g  <- data[[outcome_var]][data[[group_var]] == g]
    m    <- .describe_one(x_g, as.character(g))
    data.frame(
      Group   = as.character(g),
      N       = m$n,
      Mean    = round(m$mean, digits),
      Median  = round(m$median, digits),
      SD      = round(m$sd, digits),
      SE      = round(m$se_mean, digits),
      Min     = round(m$min, digits),
      Max     = round(m$max, digits),
      IQR     = round(m$iqr, digits),
      CV_pct  = round(m$cv_pct, digits),
      Skewness = round(m$skewness, digits),
      CI_lower = round(m$ci_lower, digits),
      CI_upper = round(m$ci_upper, digits),
      stringsAsFactors = FALSE
    )
  })
  coef_tbl <- do.call(rbind, rows)

  # Overall stats for model_fit_table
  overall <- .describe_one(data[[outcome_var]], outcome_var)
  fit_tbl <- data.frame(
    Metric = c("Outcome variable", "Grouping variable",
               "Number of groups", "Overall Mean",
               "Overall SD", "Overall Median"),
    Value  = c(outcome_var, group_var,
               n_grps, round(overall$mean, digits),
               round(overall$sd, digits), round(overall$median, digits)),
    stringsAsFactors = FALSE
  )

  # ---- Narrative ----
  max_mean_grp <- coef_tbl$Group[which.max(coef_tbl$Mean)]
  min_mean_grp <- coef_tbl$Group[which.min(coef_tbl$Mean)]
  max_sd_grp   <- coef_tbl$Group[which.max(coef_tbl$SD)]

  explanation <- glue::glue(
    "GROUP SUMMARY: {outcome_var} by {group_var}\n\n",
    "Descriptive statistics were computed for '{outcome_var}' across {n_grps} groups of '{group_var}'. ",
    "The group with the highest mean is '{max_mean_grp}' (M = {max(coef_tbl$Mean, na.rm=TRUE)}), ",
    "while the group with the lowest mean is '{min_mean_grp}' (M = {min(coef_tbl$Mean, na.rm=TRUE)}). ",
    "The group with the greatest variability (highest SD) is '{max_sd_grp}' ",
    "(SD = {coef_tbl$SD[coef_tbl$Group == max_sd_grp]}). ",
    "Overall, the grand mean across all groups is {round(overall$mean, digits)} ",
    "(SD = {round(overall$sd, digits)}, Median = {round(overall$median, digits)}). ",
    "These group-level statistics provide the foundation for inferential comparisons ",
    "using ANOVA or t-tests."
  )

  structure(
    list(
      test_type          = "group_summary",
      formula_str        = formula_str,
      raw_model          = rows,
      coefficients_table = coef_tbl,
      model_fit_table    = fit_tbl,
      explanation        = explanation
    ),
    class = "easystat_result"
  )
}

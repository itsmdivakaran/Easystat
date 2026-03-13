# EasyStat Visualization Functions
# A suite of ggplot2-based plotting functions, each returning an
# "easystat_result" object containing the plot object, a plain-language
# interpretation narrative, and a summary statistics table. All plots apply
# the unified theme_easystat() theme for a consistent visual identity.

# ---------------------------------------------------------------------------
# easy_histogram  \u2014  Distribution with Normal Curve Overlay
# ---------------------------------------------------------------------------

#' Annotated Histogram with Normal Curve Overlay
#'
#' Draws a histogram of a numeric variable, overlays a fitted normal density
#' curve, and annotates the plot with the mean, median, and standard deviation.
#' Normality is assessed via the Shapiro-Wilk test, and the result is displayed
#' in the subtitle.
#'
#' @param x Character column name OR a numeric vector.
#' @param data A data frame (required when \code{x} is a column name).
#' @param bins Number of histogram bins. Default \code{NULL} (auto).
#' @param fill_color Bar fill colour. Default EasyStat primary blue.
#' @param show_normal Logical; overlay normal curve? Default \code{TRUE}.
#' @param title Custom plot title. Default auto-generated.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_histogram <- function(x, data = NULL, bins = NULL,
                            fill_color = NULL, show_normal = TRUE,
                            title = NULL) {
  if (is.character(x) && !is.null(data)) {
    var_name <- x; x_vec <- data[[x]]
  } else {
    var_name <- deparse(substitute(x)); x_vec <- x
  }
  x_vec <- x_vec[!is.na(x_vec)]
  if (!is.numeric(x_vec)) stop("'x' must be numeric.")

  fill_c  <- if (is.null(fill_color)) .ES_COLORS["primary"] else fill_color
  n       <- length(x_vec)
  mn      <- mean(x_vec); med <- stats::median(x_vec); s <- stats::sd(x_vec)
  sw_p    <- .shapiro_p(x_vec)
  sk      <- .skewness_calc(x_vec); kt <- .kurtosis_calc(x_vec)
  nbins   <- if (is.null(bins)) max(10, round(sqrt(n))) else bins

  # Subtitle
  norm_badge <- if (!is.na(sw_p) && sw_p < 0.05) "Non-Normal" else "Approximately Normal"
  subtitle   <- glue::glue(
    "n = {n}  |  Mean = {round(mn,3)}  |  Median = {round(med,3)}  ",
    "|  SD = {round(s,3)}  |  {norm_badge}"
  )
  plot_title <- if (is.null(title)) paste0("Distribution of ", var_name) else title

  df_plot <- data.frame(v = x_vec)
  bw      <- (max(x_vec) - min(x_vec)) / nbins

  gg <- ggplot2::ggplot(df_plot, ggplot2::aes(x = v)) +
    ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density)),
                             bins  = nbins, fill = fill_c,
                             color = "white", alpha = 0.85) +
    ggplot2::geom_rug(color = fill_c, alpha = 0.4, linewidth = 0.3)

  if (show_normal) {
    x_seq <- seq(min(x_vec), max(x_vec), length.out = 300)
    norm_df <- data.frame(x = x_seq, y = stats::dnorm(x_seq, mn, s))
    gg <- gg +
      ggplot2::geom_line(data = norm_df, ggplot2::aes(x = x, y = y),
                          color = .ES_COLORS["secondary"], linewidth = 1.2,
                          linetype = "dashed")
  }

  # Mean & Median lines
  gg <- gg +
    ggplot2::geom_vline(xintercept = mn,  color = .ES_COLORS["accent2"],
                         linewidth = 1.0, linetype = "solid") +
    ggplot2::geom_vline(xintercept = med, color = .ES_COLORS["accent1"],
                         linewidth = 1.0, linetype = "longdash") +
    ggplot2::annotate("text", x = mn,  y = Inf, vjust = -0.3, hjust = -0.1,
                       label = paste0("Mean=", round(mn, 2)),
                       color = .ES_COLORS["accent2"], size = 3.2, fontface = "bold") +
    ggplot2::annotate("text", x = med, y = Inf, vjust = -0.3, hjust = 1.1,
                       label = paste0("Med=", round(med, 2)),
                       color = .ES_COLORS["accent1"], size = 3.2, fontface = "bold") +
    ggplot2::labs(title = plot_title, subtitle = subtitle,
                   x = var_name, y = "Density",
                   caption = .es_caption("Histogram")) +
    theme_easystat()

  metrics <- list(var_name = var_name, n = n, mean = mn, median = med,
                  sd = s, skewness = sk, kurtosis = kt, shapiro_p = sw_p)
  interp  <- .generate_histogram_interpretation(metrics)

  stats_tbl <- data.frame(
    Metric = c("n", "Mean", "Median", "SD", "Skewness", "Kurtosis", "Shapiro-Wilk p"),
    Value  = c(n, round(mn,4), round(med,4), round(s,4),
               round(sk,4), round(kt,4),
               format.pval(sw_p, digits=4, eps=0.0001)),
    stringsAsFactors = FALSE
  )

  .make_easystat_plot("histogram", gg, interp,
    list(stats_table = stats_tbl, formula_str = paste0("Histogram: ", var_name)))
}


# ---------------------------------------------------------------------------
# easy_boxplot  \u2014  Group Comparison Boxplot
# ---------------------------------------------------------------------------

#' Grouped Boxplot with Outlier Detection
#'
#' Produces a boxplot for one variable, optionally grouped by a factor. Adds
#' a jittered dot overlay, labels each group's median, and highlights outliers.
#'
#' @param formula A formula: \code{outcome ~ group} for grouped, or a bare
#'   column name / numeric vector for a single-variable boxplot.
#' @param data A data frame.
#' @param fill_palette Character vector of fill colours. Default EasyStat palette.
#' @param notch Logical; draw notched boxes? Default \code{FALSE}.
#' @param title Custom plot title.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_boxplot <- function(formula, data, fill_palette = NULL,
                          notch = FALSE, title = NULL) {
  if (!is.data.frame(data)) stop("'data' must be a data frame.")
  if (is.character(formula)) formula <- stats::as.formula(formula)
  formula_str <- deparse(formula)
  vars        <- all.vars(formula)

  if (length(vars) == 2) {
    outcome_var <- vars[1]; group_var <- vars[2]
    grouped <- TRUE
  } else {
    outcome_var <- vars[1]; group_var <- NULL
    grouped <- FALSE
    data$.group <- "All"
    group_var <- ".group"
  }

  if (!is.numeric(data[[outcome_var]]))
    stop("'", outcome_var, "' must be numeric.")

  data[[group_var]] <- factor(data[[group_var]])
  n_grps  <- nlevels(data[[group_var]])
  palette <- if (is.null(fill_palette)) .ES_CAT_PALETTE[seq_len(n_grps)]
             else fill_palette

  # Detect outliers
  outlier_fn <- function(x) {
    q <- stats::quantile(x, c(0.25, 0.75), na.rm = TRUE)
    iqr_v <- q[2] - q[1]
    x < (q[1] - 1.5 * iqr_v) | x > (q[2] + 1.5 * iqr_v)
  }
  data$.outlier <- ave(data[[outcome_var]], data[[group_var]],
                       FUN = outlier_fn)
  n_out <- sum(data$.outlier, na.rm = TRUE)

  # Medians for annotation
  med_df <- stats::aggregate(stats::as.formula(paste(outcome_var, "~", group_var)),
                              data, FUN = stats::median)
  names(med_df)[2] <- "med"

  plot_title <- if (is.null(title)) {
    if (grouped) paste0(outcome_var, " by ", group_var) else paste0("Distribution of ", outcome_var)
  } else title
  subtitle <- glue::glue("n groups = {n_grps}  |  Outliers detected = {n_out}")

  gg <- ggplot2::ggplot(data,
         ggplot2::aes(x = .data[[group_var]], y = .data[[outcome_var]],
                       fill = .data[[group_var]])) +
    ggplot2::geom_boxplot(notch = notch, outlier.shape = NA,
                           alpha = 0.85, color = "#444444", linewidth = 0.5) +
    ggplot2::geom_jitter(width = 0.15, alpha = 0.35, size = 1.5,
                          color = .ES_COLORS["dark_text"]) +
    ggplot2::geom_text(data = med_df,
                        ggplot2::aes(x = .data[[group_var]], y = med,
                                      label = round(med, 2)),
                        vjust = -0.6, size = 3.3, fontface = "bold",
                        color = .ES_COLORS["dark_text"],
                        inherit.aes = FALSE) +
    ggplot2::scale_fill_manual(values = palette) +
    ggplot2::labs(title = plot_title, subtitle = subtitle,
                   x = if (grouped) group_var else "",
                   y = outcome_var, fill = group_var,
                   caption = .es_caption("Boxplot")) +
    theme_easystat() +
    ggplot2::theme(legend.position = if (n_grps > 1) "right" else "none")

  # Metrics
  grp_vals <- data[[outcome_var]][!is.na(data[[outcome_var]])]
  q_all    <- stats::quantile(grp_vals, c(0.25, 0.5, 0.75))
  metrics  <- list(
    outcome = outcome_var, group = if (grouped) group_var else NULL,
    n_groups = n_grps, q1 = q_all[1], median = q_all[2], q3 = q_all[3],
    iqr = q_all[3] - q_all[1], n_outliers = n_out
  )
  interp <- .generate_boxplot_interpretation(metrics)

  stats_tbl <- med_df
  names(stats_tbl)[2] <- "Median"
  .make_easystat_plot("boxplot", gg, interp,
    list(stats_table = stats_tbl, formula_str = formula_str))
}


# ---------------------------------------------------------------------------
# easy_scatter  \u2014  Scatter Plot with Regression Line
# ---------------------------------------------------------------------------

#' Scatter Plot with Regression Line and Correlation Annotation
#'
#' Draws a scatter plot for two numeric variables, overlays a linear regression
#' line with confidence band, and annotates the Pearson r and p-value.
#'
#' @param formula A formula: \code{y ~ x}.
#' @param data A data frame.
#' @param color_by Optional column name to colour points by a third variable.
#' @param smooth Logical; show regression line? Default \code{TRUE}.
#' @param ellipse Logical; draw a 95\% data ellipse? Default \code{TRUE}.
#' @param title Custom plot title.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_scatter <- function(formula, data, color_by = NULL,
                          smooth = TRUE, ellipse = TRUE, title = NULL) {
  if (!is.data.frame(data)) stop("'data' must be a data frame.")
  if (is.character(formula)) formula <- stats::as.formula(formula)
  formula_str <- deparse(formula)
  vars <- all.vars(formula)
  if (length(vars) < 2) stop("Formula must specify y ~ x.")
  y_var <- vars[1]; x_var <- vars[2]
  if (!is.numeric(data[[y_var]]) || !is.numeric(data[[x_var]]))
    stop("Both variables must be numeric.")

  # Correlation for annotation
  complete_idx <- stats::complete.cases(data[[x_var]], data[[y_var]])
  xc <- data[[x_var]][complete_idx]; yc <- data[[y_var]][complete_idx]
  ct <- stats::cor.test(xc, yc)
  r_val  <- round(as.numeric(ct$estimate), 3)
  p_val  <- ct$p.value
  lm_fit <- stats::lm(stats::as.formula(paste(y_var, "~", x_var)), data = data)
  slope  <- stats::coef(lm_fit)[2]
  n      <- sum(complete_idx)

  badge <- .sig_badge(p_val)
  plot_title <- if (is.null(title))
    paste0(y_var, " \u2014 ", x_var) else title
  subtitle <- glue::glue("r = {r_val}  |  {badge}  |  n = {n}")

  aes_base <- if (!is.null(color_by)) {
    ggplot2::aes(x = .data[[x_var]], y = .data[[y_var]],
                  color = .data[[color_by]])
  } else {
    ggplot2::aes(x = .data[[x_var]], y = .data[[y_var]])
  }

  gg <- ggplot2::ggplot(data, aes_base) +
    ggplot2::geom_point(alpha = 0.7, size = 2.2,
      color = if (is.null(color_by)) .ES_COLORS["primary"] else NULL)

  if (ellipse && is.null(color_by)) {
    gg <- gg +
      ggplot2::stat_ellipse(color = .ES_COLORS["accent3"], linewidth = 0.8,
                             linetype = "dashed", level = 0.95, type = "norm")
  }

  if (smooth) {
    gg <- gg +
      ggplot2::geom_smooth(method = "lm", formula = y ~ x,
                            color = .ES_COLORS["secondary"],
                            fill  = paste0(.ES_COLORS["secondary"], "33"),
                            linewidth = 1.2, se = TRUE)
  }

  # Annotation box
  x_pos <- min(xc, na.rm = TRUE) + 0.05 * diff(range(xc, na.rm = TRUE))
  y_pos <- max(yc, na.rm = TRUE) - 0.05 * diff(range(yc, na.rm = TRUE))
  gg <- gg +
    ggplot2::annotate("label", x = x_pos, y = y_pos,
                       label = paste0("r = ", r_val, "\n", badge),
                       hjust = 0, vjust = 1, size = 3.2,
                       fill = .ES_COLORS["light_bg"],
                       color = .ES_COLORS["dark_text"],
                       label.border = ggplot2::unit(0.3, "lines")) +
    ggplot2::labs(title = plot_title, subtitle = subtitle,
                   x = x_var, y = y_var,
                   color = if (!is.null(color_by)) color_by else NULL,
                   caption = .es_caption("Scatterplot")) +
    theme_easystat()

  if (!is.null(color_by)) {
    gg <- gg + ggplot2::scale_color_manual(values = .ES_CAT_PALETTE)
  }

  metrics <- list(x_var = x_var, y_var = y_var, r = r_val, n = n,
                  p_value_r = p_val, slope = slope)
  interp  <- .generate_scatter_interpretation(metrics)

  stats_tbl <- data.frame(
    Metric = c("Pearson r", "p-value", "n", "Slope"),
    Value  = c(r_val, format.pval(p_val,4,eps=0.0001), n, round(slope,4)),
    stringsAsFactors = FALSE
  )
  .make_easystat_plot("scatter", gg, interp,
    list(stats_table = stats_tbl, formula_str = formula_str))
}


# ---------------------------------------------------------------------------
# easy_barplot  \u2014  Frequency / Mean Bar Chart
# ---------------------------------------------------------------------------

#' Annotated Bar Chart
#'
#' Creates a frequency bar chart for categorical variables, or a mean-and-error
#' bar chart for numeric outcomes grouped by a factor.
#'
#' @param x Column name of the variable to plot.
#' @param data A data frame.
#' @param group_by Optional grouping column for grouped frequency bars.
#' @param stat \code{"count"} (default) for frequency, or \code{"mean"} for
#'   mean ± SE bars.
#' @param fill_palette Color palette vector. Default EasyStat palette.
#' @param title Custom plot title.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_barplot <- function(x, data, group_by = NULL,
                          stat = c("count", "mean"),
                          fill_palette = NULL, title = NULL) {
  stat <- match.arg(stat)
  if (!is.data.frame(data)) stop("'data' must be a data frame.")
  if (!x %in% names(data)) stop("'", x, "' not found in data.")

  palette <- if (is.null(fill_palette)) .ES_CAT_PALETTE else fill_palette

  if (stat == "count") {
    data[[x]] <- factor(data[[x]])
    n_levels   <- nlevels(data[[x]])
    plot_title <- if (is.null(title)) paste0("Frequency: ", x) else title

    if (!is.null(group_by)) {
      data[[group_by]] <- factor(data[[group_by]])
      gg <- ggplot2::ggplot(data,
              ggplot2::aes(x = .data[[x]], fill = .data[[group_by]])) +
            ggplot2::geom_bar(position = "dodge", color = "white", alpha = 0.9) +
            ggplot2::scale_fill_manual(values = palette)
      subtitle <- glue::glue("Grouped by {group_by}")
    } else {
      cnt_df <- as.data.frame(table(data[[x]]))
      names(cnt_df) <- c("cat", "freq")
      cnt_df$pct <- round(cnt_df$freq / sum(cnt_df$freq) * 100, 1)

      gg <- ggplot2::ggplot(cnt_df, ggplot2::aes(x = cat, y = freq, fill = cat)) +
            ggplot2::geom_col(color = "white", alpha = 0.9, width = 0.7) +
            ggplot2::geom_text(ggplot2::aes(label = paste0(freq, "\n(", pct, "%)")),
                                vjust = -0.3, size = 3.2, fontface = "bold",
                                color = .ES_COLORS["dark_text"]) +
            ggplot2::scale_fill_manual(values = palette[seq_len(nrow(cnt_df))]) +
            ggplot2::guides(fill = "none")
      subtitle <- glue::glue("{n_levels} categories  |  n = {sum(cnt_df$freq)}")
    }

    gg <- gg +
      ggplot2::labs(title = plot_title, subtitle = subtitle,
                     x = x, y = "Frequency",
                     caption = .es_caption("Bar Chart")) +
      theme_easystat()

    stats_tbl <- as.data.frame(table(data[[x]]))
    names(stats_tbl) <- c("Category", "Count")
    interp <- glue::glue(
      "BAR CHART INTERPRETATION\n\n",
      "The bar chart displays the frequency distribution of '{x}'. ",
      "The most frequent category is '",
      stats_tbl$Category[which.max(stats_tbl$Count)], "' ",
      "(n = {max(stats_tbl$Count)}), and the least frequent is '",
      stats_tbl$Category[which.min(stats_tbl$Count)], "' ",
      "(n = {min(stats_tbl$Count)})."
    )

  } else {
    # Mean \u00B1 SE bar chart
    if (!is.numeric(data[[x]])) stop("For stat='mean', '", x, "' must be numeric.")
    if (is.null(group_by)) stop("'group_by' is required when stat='mean'.")
    data[[group_by]] <- factor(data[[group_by]])
    agg <- stats::aggregate(stats::as.formula(paste(x, "~", group_by)),
                             data, FUN = mean)
    agg$se <- stats::aggregate(stats::as.formula(paste(x, "~", group_by)),
                                data, FUN = function(v) stats::sd(v)/sqrt(length(v)))[[x]]
    names(agg)[2] <- "mean_val"

    plot_title <- if (is.null(title)) paste0("Mean ", x, " by ", group_by) else title
    subtitle   <- glue::glue("Mean (\u00b1 SE) bars  |  n groups = {nlevels(data[[group_by]])}")

    gg <- ggplot2::ggplot(agg,
            ggplot2::aes(x = .data[[group_by]], y = mean_val,
                          fill = .data[[group_by]])) +
          ggplot2::geom_col(color = "white", alpha = 0.9, width = 0.65) +
          ggplot2::geom_errorbar(ggplot2::aes(ymin = mean_val - se,
                                               ymax = mean_val + se),
                                  width = 0.2, color = .ES_COLORS["dark_text"],
                                  linewidth = 0.8) +
          ggplot2::geom_text(ggplot2::aes(label = round(mean_val, 2)),
                              vjust = -0.5, size = 3.3, fontface = "bold",
                              color = .ES_COLORS["dark_text"]) +
          ggplot2::scale_fill_manual(values = palette[seq_len(nrow(agg))]) +
          ggplot2::guides(fill = "none") +
          ggplot2::labs(title = plot_title, subtitle = subtitle,
                         x = group_by, y = paste0("Mean ", x),
                         caption = .es_caption("Bar Chart \u2014 Mean \u00b1 SE")) +
          theme_easystat()

    stats_tbl <- agg[, c(group_by, "mean_val", "se")]
    names(stats_tbl) <- c("Group", "Mean", "SE")
    interp <- glue::glue(
      "MEAN BAR CHART INTERPRETATION\n\n",
      "The chart displays mean values of '{x}' across groups of '{group_by}', ",
      "with error bars representing \u00b1 1 standard error. ",
      "The group with the highest mean is '{agg[[group_by]][which.max(agg$mean_val)]}' ",
      "(M = {round(max(agg$mean_val), 3)})."
    )
  }

  .make_easystat_plot("barplot", gg, interp,
    list(stats_table = stats_tbl, formula_str = paste0("Bar: ", x)))
}


# ---------------------------------------------------------------------------
# easy_qqplot  \u2014  Normal Q-Q Plot
# ---------------------------------------------------------------------------

#' Normal Q-Q Plot with Shapiro-Wilk Annotation
#'
#' Plots sample quantiles against theoretical normal quantiles and annotates
#' the Shapiro-Wilk p-value. Deviations from the diagonal indicate
#' non-normality.
#'
#' @param x Column name or numeric vector.
#' @param data A data frame (required when \code{x} is a column name).
#' @param title Custom plot title.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_qqplot <- function(x, data = NULL, title = NULL) {
  if (is.character(x) && !is.null(data)) {
    var_name <- x; x_vec <- data[[x]]
  } else {
    var_name <- deparse(substitute(x)); x_vec <- x
  }
  x_vec <- x_vec[!is.na(x_vec)]
  if (!is.numeric(x_vec)) stop("'x' must be numeric.")

  sw_p  <- .shapiro_p(x_vec)
  badge <- if (!is.na(sw_p) && sw_p < 0.05) "NON-NORMAL" else "APPROXIMATELY NORMAL"
  n     <- length(x_vec)

  plot_title <- if (is.null(title)) paste0("Normal Q-Q Plot: ", var_name) else title
  subtitle   <- glue::glue("Shapiro-Wilk: {badge}  |  ",
    "p = {format.pval(sw_p, digits=4, eps=0.0001)}  |  n = {n}")

  df_qq <- data.frame(v = x_vec)
  gg <- ggplot2::ggplot(df_qq, ggplot2::aes(sample = v)) +
    ggplot2::geom_qq_line(color = .ES_COLORS["secondary"],
                           linewidth = 1.0, linetype = "dashed") +
    ggplot2::geom_qq(color = .ES_COLORS["primary"], alpha = 0.7, size = 2) +
    ggplot2::labs(title = plot_title, subtitle = subtitle,
                   x = "Theoretical Quantiles (Normal)",
                   y = paste0("Sample Quantiles (", var_name, ")"),
                   caption = .es_caption("Q-Q Plot")) +
    theme_easystat()

  # Annotate Shapiro badge
  gg <- gg +
    ggplot2::annotate("label",
      x = -Inf, y = Inf, hjust = -0.1, vjust = 1.3,
      label = paste0("SW p = ", format.pval(sw_p, 4, eps = 0.0001),
                     "\n", badge),
      fill  = if (!is.na(sw_p) && sw_p < 0.05) "#FDECEA" else "#EBF9EE",
      color = if (!is.na(sw_p) && sw_p < 0.05) .ES_COLORS["sig_red"]
              else .ES_COLORS["sig_green"],
      size  = 3.2, fontface = "bold",
      label.border = ggplot2::unit(0.3, "lines")
    )

  metrics  <- list(var_name = var_name, shapiro_p = sw_p)
  interp   <- .generate_qqplot_interpretation(metrics)
  stats_tbl <- data.frame(
    Metric = c("Shapiro-Wilk p", "Verdict", "n"),
    Value  = c(format.pval(sw_p, 4, eps = 0.0001), badge, n),
    stringsAsFactors = FALSE
  )
  .make_easystat_plot("qqplot", gg, interp,
    list(stats_table = stats_tbl, formula_str = paste0("QQ: ", var_name)))
}


# ---------------------------------------------------------------------------
# easy_density  \u2014  Kernel Density Plot
# ---------------------------------------------------------------------------

#' Kernel Density Plot with Optional Group Overlay
#'
#' Draws a smooth kernel density estimate for a numeric variable. If a
#' grouping variable is provided, separate overlapping density curves are
#' drawn per group.
#'
#' @param x Column name or numeric vector.
#' @param data A data frame.
#' @param group_by Optional grouping column for multi-group densities.
#' @param fill_alpha Alpha for filled area. Default \code{0.35}.
#' @param title Custom plot title.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_density <- function(x, data = NULL, group_by = NULL,
                          fill_alpha = 0.35, title = NULL) {
  if (!is.null(data) && is.character(x)) {
    var_name <- x; x_vec <- data[[x]]
  } else {
    var_name <- deparse(substitute(x)); x_vec <- x; data <- data.frame(v = x_vec)
    x <- "v"
  }
  if (!is.numeric(data[[x]])) stop("'x' must be numeric.")

  mn   <- mean(data[[x]], na.rm = TRUE)
  md   <- stats::median(data[[x]], na.rm = TRUE)
  sk   <- .skewness_calc(data[[x]][!is.na(data[[x]])])
  sw_p <- .shapiro_p(data[[x]][!is.na(data[[x]])])
  n    <- sum(!is.na(data[[x]]))

  # Approximate mode from density estimate
  dens_obj    <- stats::density(data[[x]], na.rm = TRUE)
  mode_approx <- dens_obj$x[which.max(dens_obj$y)]

  plot_title <- if (is.null(title)) paste0("Density: ", var_name) else title
  subtitle   <- glue::glue("n = {n}  |  Mean = {round(mn,3)}  |  Skewness = {round(sk,3)}")

  if (!is.null(group_by)) {
    data[[group_by]] <- factor(data[[group_by]])
    gg <- ggplot2::ggplot(data,
            ggplot2::aes(x = .data[[x]], fill = .data[[group_by]],
                          color = .data[[group_by]])) +
          ggplot2::geom_density(alpha = fill_alpha, linewidth = 1.0) +
          ggplot2::scale_fill_manual(values  = .ES_CAT_PALETTE) +
          ggplot2::scale_color_manual(values = .ES_CAT_PALETTE)
  } else {
    gg <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[x]])) +
          ggplot2::geom_density(fill = .ES_COLORS["primary"], alpha = fill_alpha,
                                 color = .ES_COLORS["primary"], linewidth = 1.1) +
          ggplot2::geom_vline(xintercept = mn,  linetype = "solid",
                               color = .ES_COLORS["accent2"], linewidth = 0.9) +
          ggplot2::geom_vline(xintercept = md,  linetype = "longdash",
                               color = .ES_COLORS["accent1"], linewidth = 0.9) +
          ggplot2::geom_vline(xintercept = mode_approx, linetype = "dotted",
                               color = .ES_COLORS["accent3"], linewidth = 0.9)
  }

  gg <- gg +
    ggplot2::labs(title = plot_title, subtitle = subtitle,
                   x = var_name, y = "Density",
                   caption = .es_caption("Density Plot")) +
    theme_easystat()

  metrics <- list(var_name = var_name, mean = mn, median = md,
                  skewness = sk, mode_approx = mode_approx)
  interp  <- .generate_density_interpretation(metrics)
  stats_tbl <- data.frame(
    Metric = c("Mean", "Median", "Mode (approx.)", "Skewness"),
    Value  = round(c(mn, md, mode_approx, sk), 4),
    stringsAsFactors = FALSE
  )
  .make_easystat_plot("density", gg, interp,
    list(stats_table = stats_tbl, formula_str = paste0("Density: ", var_name)))
}


# ---------------------------------------------------------------------------
# easy_correlation_heatmap  \u2014  Correlation Matrix Heatmap
# ---------------------------------------------------------------------------

#' Correlation Matrix Heatmap
#'
#' Computes pairwise correlations and displays them as a colour-coded heatmap,
#' annotating each cell with the correlation coefficient and a significance star.
#'
#' @param data A data frame.
#' @param vars Character vector of numeric column names. Default all numerics.
#' @param method Correlation method: \code{"pearson"} (default), \code{"spearman"}.
#' @param title Custom plot title.
#'
#' @return An \code{"easystat_result"} object with \code{plot_object}.
#' @export
easy_correlation_heatmap <- function(data, vars = NULL,
                                      method = "pearson", title = NULL) {
  if (!is.data.frame(data)) stop("'data' must be a data frame.")
  if (is.null(vars)) vars <- names(data)[sapply(data, is.numeric)]
  if (length(vars) < 2) stop("Need at least 2 numeric variables.")

  corr_result <- .easy_corr_matrix(data, vars, method)
  corr_mat    <- corr_result$corr_matrix_raw

  # Melt to long format manually
  n_v  <- length(vars)
  long <- data.frame(
    Var1 = rep(vars, each = n_v),
    Var2 = rep(vars, times = n_v),
    r    = as.vector(corr_mat),
    stringsAsFactors = FALSE
  )
  long$Var1 <- factor(long$Var1, levels = vars)
  long$Var2 <- factor(long$Var2, levels = rev(vars))

  # Significance stars
  p_mat <- corr_result$raw_model$p_matrix
  long$stars <- ""
  for (i in seq_len(nrow(long))) {
    v1 <- as.character(long$Var1[i])
    v2 <- as.character(long$Var2[i])
    if (v1 != v2 && !is.na(p_mat[v1, v2])) {
      p <- p_mat[v1, v2]
      long$stars[i] <- if (p < 0.001) "***"
                       else if (p < 0.01) "**"
                       else if (p < 0.05) "*" else ""
    }
  }
  long$label <- paste0(round(long$r, 2), long$stars)
  long$label[long$Var1 == long$Var2] <- "1.00"

  plot_title <- if (is.null(title))
    paste0("Correlation Heatmap (", tools::toTitleCase(method), ")") else title

  gg <- ggplot2::ggplot(long,
          ggplot2::aes(x = Var1, y = Var2, fill = r)) +
    ggplot2::geom_tile(color = "white", linewidth = 0.5) +
    ggplot2::geom_text(ggplot2::aes(label = label),
                        color = ifelse(abs(long$r) > 0.55, "white", .ES_COLORS["dark_text"]),
                        size = 3.3, fontface = "bold") +
    ggplot2::scale_fill_gradientn(
      colors = .ES_DIV_PALETTE, limits = c(-1, 1), name = "r",
      breaks = c(-1, -0.5, 0, 0.5, 1)
    ) +
    ggplot2::labs(
      title    = plot_title,
      subtitle = paste0(n_v, " variables  |  * p<0.05  ** p<0.01  *** p<0.001"),
      x = NULL, y = NULL,
      caption  = .es_caption("Correlation Heatmap")
    ) +
    ggplot2::coord_fixed() +
    theme_easystat(legend_position = "right") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 40, hjust = 1),
      panel.grid  = ggplot2::element_blank()
    )

  all_r  <- corr_mat[lower.tri(corr_mat)]
  metrics <- list(method = method, n_vars = n_v,
                  n_pairs = n_v * (n_v - 1) / 2, corr_values = all_r)
  interp <- .generate_corr_heatmap_interpretation(metrics)

  .make_easystat_plot("correlation_heatmap", gg, interp,
    list(stats_table = corr_result$coefficients_table,
         formula_str = paste("Heatmap:", paste(vars, collapse = ", "))))
}


# ---------------------------------------------------------------------------
# easy_autoplot  \u2014  Smart Plot Dispatcher
# ---------------------------------------------------------------------------

#' Automatically Plot an EasyStat Result
#'
#' Chooses the most appropriate plot type based on the \code{test_type} of an
#' \code{easystat_result} object and renders it.
#'
#' @param result An \code{"easystat_result"} object.
#' @param data The original data frame (required for some plot types).
#' @param ... Additional arguments passed to the underlying plot function.
#'
#' @return An \code{"easystat_result"} plot object, invisibly.
#' @export
easy_autoplot <- function(result, data = NULL, ...) {
  if (!inherits(result, "easystat_result"))
    stop("'result' must be an easystat_result object.")

  formula_str <- result$formula_str

  p <- switch(result$test_type,
    regression = {
      if (is.null(data)) stop("'data' required for autoplot of regression.")
      vars <- all.vars(stats::as.formula(formula_str))
      easy_scatter(stats::as.formula(paste(vars[1], "~", vars[2])), data, ...)
    },
    ttest      = {
      if (is.null(data)) stop("'data' required for autoplot of t-test.")
      easy_boxplot(stats::as.formula(formula_str), data, ...)
    },
    anova      = {
      if (is.null(data)) stop("'data' required for autoplot of ANOVA.")
      easy_boxplot(stats::as.formula(formula_str), data, ...)
    },
    describe   = {
      var_name <- trimws(gsub("Descriptive:", "", formula_str))
      if (is.null(data)) stop("'data' required for autoplot of describe.")
      first_var <- strsplit(var_name, ", ")[[1]][1]
      easy_histogram(first_var, data, ...)
    },
    correlation = {
      vars <- all.vars(stats::as.formula(formula_str))
      if (is.null(data)) stop("'data' required for autoplot of correlation.")
      easy_scatter(stats::as.formula(formula_str), data, ...)
    },
    {
      message("No default autoplot for test type '", result$test_type, "'.")
      return(invisible(NULL))
    }
  )

  print(p)
  invisible(p)
}

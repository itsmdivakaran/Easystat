# ============================================================================
# EasyStat v2.0 — Full Smoke Test Suite
# ============================================================================
# INSTALL (once):
#   install.packages(c("broom","glue","ggplot2","knitr","kableExtra",
#                      "htmltools","flextable","officer"))
#   install.packages("path/to/EasyStat", repos=NULL, type="source")
#
# RUN:
#   source(system.file("smoke_test.R", package = "EasyStat"))
# ============================================================================

library(EasyStat)

PASS    <- function(lbl) cat(sprintf("  [PASS] %s\n", lbl))
SECTION <- function(lbl) cat(sprintf("\n%s\n  %s\n%s\n", strrep("=",58), lbl, strrep("=",58)))

# ============================================================
SECTION("1. DESCRIPTIVE STATISTICS")
# ============================================================

r <- easy_describe(mtcars$mpg)
stopifnot(inherits(r, "easystat_result"), r$test_type == "describe")
PASS("easy_describe (single vector)")

r <- easy_describe(mtcars, vars = c("mpg","hp","wt"))
stopifnot(nrow(r$coefficients_table) == 3)
PASS("easy_describe (data frame, 3 vars)")
print(r, viewer = FALSE)

r <- easy_group_summary(mpg ~ cyl, data = mtcars)
stopifnot(nrow(r$coefficients_table) == 3)
PASS("easy_group_summary (mpg ~ cyl)")
print(r, viewer = FALSE)

# ============================================================
SECTION("2. CORE INFERENTIAL TESTS")
# ============================================================

r <- easy_regression(mpg ~ wt + hp, data = mtcars)
stopifnot(r$test_type == "regression")
stopifnot("Regression Diagnostics" %in% names(r$additional_tables))
PASS("easy_regression (mpg ~ wt + hp)")
print(r, viewer = FALSE)

r <- easy_logistic_regression(am ~ mpg + wt, data = mtcars)
stopifnot(r$test_type == "logistic_regression")
stopifnot("Confusion Matrix" %in% names(r$additional_tables))
PASS("easy_logistic_regression (am ~ mpg + wt)")
print(r, viewer = FALSE)

r <- easy_ttest(mpg ~ am, data = mtcars)
stopifnot(r$test_type == "ttest"); PASS("easy_ttest (mpg ~ am)")

r <- easy_anova(Sepal.Length ~ Species, data = iris)
stopifnot(r$test_type == "anova")
stopifnot("Tukey Post-hoc Comparisons" %in% names(r$additional_tables))
PASS("easy_anova")
print(r, viewer = FALSE)

# ============================================================
SECTION("3. EXTENDED INFERENTIAL TESTS")
# ============================================================

r <- easy_chisq(~ cyl + am, data = mtcars)
stopifnot(r$test_type == "chisq")
stopifnot("Observed Contingency Table" %in% names(r$additional_tables))
PASS("easy_chisq independence")
print(r, viewer = FALSE)

r <- easy_chisq(~ cyl, data = mtcars)
stopifnot(r$test_type == "chisq"); PASS("easy_chisq GOF")

r <- easy_ztest(mtcars$mpg, mu = 20)
stopifnot(r$test_type == "ztest"); PASS("easy_ztest one-sample")
print(r, viewer = FALSE)

r <- easy_ztest(mpg ~ am, data = mtcars)
stopifnot(r$test_type == "ztest"); PASS("easy_ztest two-sample (formula)")

r <- easy_ftest(mpg ~ am, data = mtcars)
stopifnot(r$test_type == "ftest"); PASS("easy_ftest")
print(r, viewer = FALSE)

r <- easy_correlation(~ mpg + wt, data = mtcars)
stopifnot(r$test_type == "correlation"); PASS("easy_correlation bivariate")
print(r, viewer = FALSE)

r <- easy_correlation(mtcars, vars = c("mpg","hp","wt","disp"))
stopifnot(r$test_type == "correlation_matrix"); PASS("easy_correlation matrix")

r <- easy_wilcox(mpg ~ am, data = mtcars)
stopifnot(r$test_type == "wilcox"); PASS("easy_wilcox")

r <- easy_kruskal(Sepal.Length ~ Species, data = iris)
stopifnot(r$test_type == "kruskal"); PASS("easy_kruskal")

# ============================================================
SECTION("4. VISUALIZATIONS")
# ============================================================

p <- easy_histogram("mpg", data = mtcars)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_histogram")
print(p$plot_object)

p <- easy_boxplot(Sepal.Length ~ Species, data = iris)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_boxplot (grouped)")
print(p$plot_object)

p <- easy_scatter(mpg ~ wt, data = mtcars)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_scatter")
print(p$plot_object)

p <- easy_barplot("cyl", data = mtcars)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_barplot (count)")
print(p$plot_object)

p <- easy_barplot("mpg", data = mtcars, group_by = "cyl", stat = "mean")
PASS("easy_barplot (mean +/- SE)")

p <- easy_qqplot("mpg", data = mtcars)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_qqplot")
print(p$plot_object)

p <- easy_density("Sepal.Length", data = iris)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_density (single)")

p <- easy_density("Sepal.Length", data = iris, group_by = "Species")
PASS("easy_density (grouped by Species)")
print(p$plot_object)

p <- easy_correlation_heatmap(mtcars, vars = c("mpg","hp","wt","qsec","drat"))
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_correlation_heatmap")
print(p$plot_object)

reg_result <- easy_regression(mpg ~ wt, data = mtcars)
p <- easy_regression_diagnostics(reg_result)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_regression_diagnostics")

logit_result <- easy_logistic_regression(am ~ mpg + wt, data = mtcars)
p <- easy_odds_ratio_plot(logit_result)
stopifnot(inherits(p$plot_object, "gg")); PASS("easy_odds_ratio_plot")

easy_autoplot(reg_result, data = mtcars)
PASS("easy_autoplot (regression -> scatter)")

# ============================================================
SECTION("5. WORD EXPORT")
# ============================================================

tmp <- tempfile(fileext = ".docx")
export_to_word(reg_result, file = tmp,
  title  = "EasyStat v2.0 Smoke Test",
  author = "Mr. Mahesh Divakaran, Dr. Gunjan Singh, Prof. Dr. Jayadevan Shreedharan")
stopifnot(file.exists(tmp), file.size(tmp) > 5000)
PASS(paste0("export_to_word -> ", basename(tmp)))

cat(sprintf("\n%s\n  ALL TESTS PASSED\n%s\n\n", strrep("=",58), strrep("=",58)))

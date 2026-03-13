# zzz.R \u2014 Package-level declarations for R CMD check compliance

# Suppress "no visible binding for global variable" notes arising from
# ggplot2 aes() / dplyr non-standard evaluation in easy_plots.R.
utils::globalVariables(c(
  # ggplot2 .data pronoun
  ".data",
  # Variables created inside dplyr / base aggregation in easy_plots.R
  "freq", "pct", "mean_val", "se", "med",
  # Reshaping / melting variable names used in correlation heatmap
  "Var1", "Var2", "r", "label",
  # Misc intermediate columns in barplot / density helpers
  "v", "y", "ave",
  # stats::ave is imported separately; suppress the column name "ave" note
  "grp_mean",
  # ggplot2 computed aesthetic 'density' used in easy_histogram after_stat()
  "density"
))

# EasyStat ggplot2 Theme and Color System
# Provides a consistent, professional visual identity for all
# EasyStat plots through a custom ggplot2 theme and a unified color palette.
# (Internal module)

# ---------------------------------------------------------------------------
# EasyStat Color Palette
# ---------------------------------------------------------------------------
.ES_COLORS <- c(
  primary    = "#2E5FA3",   # deep blue  \u2014 main accent
  secondary  = "#E84C4C",   # coral red  \u2014 contrast
  accent1    = "#27AE60",   # emerald
  accent2    = "#F39C12",   # amber
  accent3    = "#8E44AD",   # purple
  accent4    = "#16A085",   # teal
  accent5    = "#2980B9",   # sky blue
  neutral    = "#95A5A6",   # grey
  light_bg   = "#F0F4FB",   # very light blue
  dark_text  = "#2C3E50",   # charcoal
  mid_text   = "#555F6D",   # mid grey
  grid_line  = "#E4EAF5",   # subtle grid
  sig_green  = "#1E8449",   # significance green
  sig_red    = "#C0392B",   # non-significant red
  sig_orange = "#D35400"    # borderline
)

# Categorical palette (for group factors \u2014 up to 8 groups)
.ES_CAT_PALETTE <- unname(c(
  .ES_COLORS["primary"],   .ES_COLORS["secondary"],
  .ES_COLORS["accent1"],   .ES_COLORS["accent2"],
  .ES_COLORS["accent3"],   .ES_COLORS["accent4"],
  .ES_COLORS["accent5"],   .ES_COLORS["neutral"]
))

# Diverging palette for heatmaps (red \u2192 white \u2192 blue)
.ES_DIV_PALETTE <- c("#C0392B", "#E74C3C", "#EC7063", "#F1948A",
                      "#FDFEFE", "#85C1E9", "#5DADE2", "#2E86C1", "#1A5276")

# ---------------------------------------------------------------------------
# Core EasyStat ggplot2 Theme
# ---------------------------------------------------------------------------

#' Apply EasyStat ggplot2 Theme
#'
#' Adds a clean, professional EasyStat visual theme to any ggplot2 object.
#'
#' @param base_size Base font size. Default \code{12}.
#' @param legend_position Where to place the legend. Default \code{"right"}.
#'
#' @return A \code{ggplot2::theme} object.
#' @export
theme_easystat <- function(base_size = 12, legend_position = "right") {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      # Titles
      plot.title    = ggplot2::element_text(
        face = "bold", size = base_size + 4, color = .ES_COLORS["primary"],
        margin = ggplot2::margin(b = 6)
      ),
      plot.subtitle = ggplot2::element_text(
        size = base_size, color = .ES_COLORS["mid_text"],
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption  = ggplot2::element_text(
        size = base_size - 2, color = .ES_COLORS["neutral"],
        hjust = 0, margin = ggplot2::margin(t = 8)
      ),
      # Panels
      panel.background = ggplot2::element_rect(fill = .ES_COLORS["light_bg"], color = NA),
      plot.background  = ggplot2::element_rect(fill = "white", color = "#D5DDEF", linewidth = 0.6),
      panel.grid.major = ggplot2::element_line(color = .ES_COLORS["grid_line"], linewidth = 0.5),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border     = ggplot2::element_blank(),
      # Axes
      axis.title    = ggplot2::element_text(size = base_size, color = .ES_COLORS["dark_text"], face = "bold"),
      axis.text     = ggplot2::element_text(size = base_size - 1, color = .ES_COLORS["mid_text"]),
      axis.line     = ggplot2::element_line(color = "#C0CBE0", linewidth = 0.4),
      axis.ticks    = ggplot2::element_line(color = "#C0CBE0", linewidth = 0.4),
      # Legend
      legend.position   = legend_position,
      legend.background = ggplot2::element_rect(fill = "white", color = "#D5DDEF", linewidth = 0.4),
      legend.key        = ggplot2::element_rect(fill = "white"),
      legend.title      = ggplot2::element_text(face = "bold", size = base_size - 1),
      legend.text       = ggplot2::element_text(size = base_size - 2),
      # Facets
      strip.background = ggplot2::element_rect(fill = .ES_COLORS["primary"], color = NA),
      strip.text       = ggplot2::element_text(color = "white", face = "bold", size = base_size - 1),
      # Margins
      plot.margin = ggplot2::margin(16, 16, 12, 16)
    )
}

# ---------------------------------------------------------------------------
# Helper: auto-generate caption with EasyStat branding
# ---------------------------------------------------------------------------
.es_caption <- function(test_label = NULL) {
  base <- "EasyStat | Automated Statistical Reporting"
  if (!is.null(test_label)) paste0(base, " | ", test_label) else base
}

# ---------------------------------------------------------------------------
# Helper: significance badge label for plots
# ---------------------------------------------------------------------------
.sig_badge <- function(p) {
  if (is.na(p))    return("p = NA")
  if (p < 0.001)   return(paste0(.format_p_statement(p), " ***"))
  if (p < 0.01)    return(paste0(.format_p_statement(p), " **"))
  if (p < 0.05)    return(paste0(.format_p_statement(p), " *"))
  if (p < 0.10)    return(paste0(.format_p_statement(p), " ."))
  paste0(.format_p_statement(p), " (ns)")
}

# ---------------------------------------------------------------------------
# Helper: smart class constructor for plot results
# ---------------------------------------------------------------------------
.make_easystat_plot <- function(plot_type, plot_object,
                                 interpretation, data_summary = list()) {
  structure(
    list(
      test_type      = plot_type,
      plot_type      = plot_type,
      plot_object    = plot_object,
      explanation    = interpretation,
      data_summary   = data_summary,
      # Stub tables so export_to_word still works
      coefficients_table = if (!is.null(data_summary$stats_table)) data_summary$stats_table
                           else data.frame(Metric = "See plot", Value = "-"),
      model_fit_table    = data.frame(Metric = "Plot Type", Value = plot_type),
      formula_str        = if (!is.null(data_summary$formula_str)) data_summary$formula_str else plot_type
    ),
    class = "easystat_result"
  )
}

# ---------------------------------------------------------------------------
# Print method extension: handle plot objects inside easystat_result
# ---------------------------------------------------------------------------
# (Patches into existing print.easystat_result dispatch)
.render_plot_console <- function(x) {
  cat("\n[EasyStat Plot: ", x$plot_type, "]\n", sep = "")
  print(x$plot_object)
  cat("\n")
  narrative_lines <- strwrap(x$explanation,
                             width = max(getOption("width", 80) - 2, 58),
                             exdent = 2)
  cat(paste(narrative_lines, collapse = "\n"), "\n\n")
}

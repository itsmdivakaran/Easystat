# Print and Display Methods for EasyStat Results
# Provides console, plain-text, and HTML Viewer rendering for
# easystat_result objects. Depending on whether the session is
# interactive and whether the RStudio Viewer is available, output is
# automatically directed to the most suitable output channel.
# (Internal module)

# ---------------------------------------------------------------------------
# print.easystat_result  \u2014  smart dispatcher
# ---------------------------------------------------------------------------

#' Print an EasyStat Result Object
#'
#' Automatically renders an \code{easystat_result} object. In an interactive
#' RStudio session the HTML Viewer is used; otherwise clean ASCII tables and
#' the plain-language narrative are written to the console.
#'
#' @param x An object of class \code{"easystat_result"}.
#' @param viewer Logical. Force HTML Viewer output (\code{TRUE}) or console
#'   output (\code{FALSE}). Default \code{NULL} auto-detects.
#' @param ... Currently ignored.
#'
#' @return \code{x} invisibly.
#' @export
print.easystat_result <- function(x, viewer = NULL, ...) {

  # Auto-detect preferred output mode
  use_viewer <- if (!is.null(viewer)) {
    isTRUE(viewer)
  } else {
    interactive() &&
      !is.null(getOption("viewer")) &&
      requireNamespace("htmltools", quietly = TRUE) &&
      requireNamespace("knitr",     quietly = TRUE) &&
      requireNamespace("kableExtra",quietly = TRUE)
  }

  if (use_viewer) {
    .render_html_viewer(x)
  } else {
    .render_console(x)
  }

  invisible(x)
}

# ---------------------------------------------------------------------------
# Console renderer  (ASCII / plain-text)
# ---------------------------------------------------------------------------
.render_console <- function(x) {
  width  <- max(getOption("width", 80), 60)
  border <- paste(rep("=", width), collapse = "")
  thin   <- paste(rep("-", width), collapse = "")

  cat("\n", border, "\n", sep = "")
  cat(" EasyStat Result :: ", toupper(x$test_type), "\n", sep = "")
  cat(border, "\n\n", sep = "")

  # --- Coefficients / Main Table ---
  cat("TABLE 1 \u2014 MAIN RESULTS\n")
  cat(thin, "\n", sep = "")
  print(x$coefficients_table, row.names = FALSE)
  cat("\n")

  # --- Model Fit / Summary Table ---
  cat("TABLE 2 \u2014 MODEL FIT / SUMMARY\n")
  cat(thin, "\n", sep = "")
  print(x$model_fit_table, row.names = FALSE)
  cat("\n")

  if (!is.null(x$additional_tables) && length(x$additional_tables) > 0) {
    table_no <- 3
    for (nm in names(x$additional_tables)) {
      cat("TABLE ", table_no, " \u2014 ", toupper(nm), "\n", sep = "")
      cat(thin, "\n", sep = "")
      print(x$additional_tables[[nm]], row.names = FALSE)
      cat("\n")
      table_no <- table_no + 1
    }
  }

  # --- Narrative ---
  cat(border, "\n", sep = "")
  cat(" PLAIN-LANGUAGE INTERPRETATION\n")
  cat(border, "\n\n", sep = "")

  # Word-wrap narrative to console width
  narrative_lines <- strwrap(x$explanation, width = width - 2, exdent = 2)
  cat(paste(narrative_lines, collapse = "\n"), "\n\n", sep = "")

  cat(border, "\n\n", sep = "")
}

# ---------------------------------------------------------------------------
# HTML Viewer renderer
# ---------------------------------------------------------------------------
.render_html_viewer <- function(x) {
  # Defensive require
  if (!requireNamespace("htmltools",  quietly = TRUE) ||
      !requireNamespace("knitr",      quietly = TRUE) ||
      !requireNamespace("kableExtra", quietly = TRUE)) {
    message("HTML Viewer packages not available. Falling back to console output.")
    .render_console(x)
    return(invisible(NULL))
  }

  test_label <- switch(x$test_type,
    regression          = "Linear Regression",
    logistic_regression = "Logistic Regression",
    ttest               = "Independent-Samples t-Test",
    anova               = "One-Way ANOVA",
    toupper(x$test_type)
  )

  # Build kable tables with kableExtra styling
  tbl1_html <- knitr::kable(x$coefficients_table, format = "html",
                             caption = "Table 1 \u2014 Main Results",
                             align = "l") |>
    kableExtra::kable_styling(
      bootstrap_options = c("striped", "hover", "condensed", "bordered"),
      full_width        = TRUE,
      font_size         = 13
    ) |>
    kableExtra::row_spec(0, bold = TRUE, background = "#2E5FA3", color = "white")

  tbl2_html <- knitr::kable(x$model_fit_table, format = "html",
                             caption = "Table 2 \u2014 Model Fit / Summary",
                             align = "l") |>
    kableExtra::kable_styling(
      bootstrap_options = c("striped", "hover", "condensed", "bordered"),
      full_width        = FALSE,
      font_size         = 13
    ) |>
    kableExtra::row_spec(0, bold = TRUE, background = "#2E5FA3", color = "white")

  extra_html <- ""
  if (!is.null(x$additional_tables) && length(x$additional_tables) > 0) {
    extra_html <- paste(vapply(names(x$additional_tables), function(nm) {
      tbl <- knitr::kable(x$additional_tables[[nm]], format = "html",
                          caption = paste("Table -", nm), align = "l") |>
        kableExtra::kable_styling(
          bootstrap_options = c("striped", "hover", "condensed", "bordered"),
          full_width = TRUE,
          font_size = 13
        ) |>
        kableExtra::row_spec(0, bold = TRUE, background = "#2E5FA3", color = "white")
      paste0('<div class="section-title" style="margin-top:28px;">',
             htmltools::htmlEscape(nm), "</div>", as.character(tbl))
    }, character(1)), collapse = "\n")
  }

  # Wrap narrative paragraphs
  narrative_paragraphs <- strsplit(x$explanation, "\n")[[1]]
  narrative_html <- paste0(
    '<p style="font-family:Arial,sans-serif;font-size:14px;line-height:1.7;',
    'color:#222;margin:8px 0;">',
    htmltools::htmlEscape(narrative_paragraphs),
    "</p>",
    collapse = "\n"
  )

  # Full HTML page
  full_html <- htmltools::HTML(paste0('
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>EasyStat \u2014 ', test_label, '</title>
<style>
  body { font-family: Arial, sans-serif; max-width: 900px; margin: 30px auto;
         padding: 0 20px; background: #F8F9FA; color: #222; }
  .header { background: #2E5FA3; color: white; padding: 18px 24px;
            border-radius: 8px 8px 0 0; margin-bottom: 0; }
  .header h1 { margin: 0; font-size: 20px; letter-spacing: 0.5px; }
  .header p  { margin: 4px 0 0; font-size: 13px; opacity: 0.85; }
  .card { background: white; border: 1px solid #DEE2E6; padding: 20px 24px;
          margin-bottom: 16px; border-radius: 0 0 8px 8px; }
  .section-title { font-size: 15px; font-weight: bold; color: #2E5FA3;
                   border-bottom: 2px solid #2E5FA3; padding-bottom: 6px;
                   margin: 20px 0 12px; }
  .narrative-box { background: #EEF3FB; border-left: 4px solid #2E5FA3;
                   padding: 16px 20px; border-radius: 4px; margin-top: 16px; }
  .narrative-box p { margin: 0 0 10px; }
  .narrative-box p:last-child { margin-bottom: 0; }
  .footer { font-size: 11px; color: #888; text-align: right;
            margin-top: 10px; padding-top: 8px; border-top: 1px solid #DEE2E6; }
</style>
</head>
<body>
<div class="header">
  <h1>EasyStat &mdash; ', htmltools::htmlEscape(test_label), '</h1>
  <p>Formula / Comparison: <em>', htmltools::htmlEscape(x$formula_str), '</em></p>
</div>
<div class="card">
  <div class="section-title">Main Results</div>
  ', as.character(tbl1_html), '
  <div class="section-title" style="margin-top:28px;">Model Fit / Summary</div>
  ', as.character(tbl2_html), '
  ', extra_html, '
  <div class="section-title" style="margin-top:28px;">Plain-Language Interpretation</div>
  <div class="narrative-box">
  ', narrative_html, '
  </div>
  <div class="footer">Generated by EasyStat &bull; ', format(Sys.time(), "%Y-%m-%d %H:%M"), '</div>
</div>
</body>
</html>
'))

  # Write to temp file and open in Viewer
  tmp <- tempfile(fileext = ".html")
  htmltools::save_html(full_html, file = tmp)
  viewer_fn <- getOption("viewer")
  if (!is.null(viewer_fn)) {
    viewer_fn(tmp)
  } else {
    utils::browseURL(tmp)
  }
  invisible(NULL)
}

# ---------------------------------------------------------------------------
# summary method \u2014 alias to print
# ---------------------------------------------------------------------------

#' Summarize an EasyStat Result Object
#' @param object An \code{"easystat_result"} object.
#' @param ... Passed to \code{print.easystat_result}.
#' @return Called for its side effects (printing to the console or RStudio
#'   Viewer). Returns \code{object} invisibly via
#'   \code{\link{print.easystat_result}}.
#' @export
summary.easystat_result <- function(object, ...) {
  print.easystat_result(object, ...)
}

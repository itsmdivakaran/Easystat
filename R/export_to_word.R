#' Export an EasyStat Result to a Formatted Microsoft Word Document
#'
#' Takes a unified \code{easystat_result} object and writes a fully formatted
#' \code{.docx} report using the \code{flextable} and \code{officer} packages.
#' The report contains a title page header, the plain-language narrative,
#' both statistical tables rendered as professional \code{flextable} objects,
#' and a footer with metadata. All of this is produced in a single function call.
#'
#' @param result An object of class \code{"easystat_result"} as returned by
#'   \code{\link{easy_regression}}, \code{\link{easy_logistic_regression}},
#'   \code{\link{easy_ttest}}, or \code{\link{easy_anova}}.
#' @param file Character string. Path to the output \code{.docx} file.
#'   Defaults to \code{"EasyStat_Report.docx"} in the current working directory.
#' @param title Character string. Report title printed at the top of the
#'   document. If \code{NULL} (default) a title is auto-generated from the
#'   test type.
#' @param author Character string. Author name(s) for the report header.
#'   Default \code{"EasyStat"}.
#'
#' @return The \code{file} path invisibly. The \code{.docx} file is written
#'   to disk as a side-effect.
#'
#' @examples
#' \dontrun{
#'   result <- easy_regression(mpg ~ wt + hp, data = mtcars)
#'   export_to_word(result, file = tempfile(fileext = ".docx"),
#'                 author = "Mr. Mahesh Divakaran")
#' }
#'
#' @export
export_to_word <- function(result,
                           file   = "EasyStat_Report.docx",
                           title  = NULL,
                           author = "EasyStat") {

  # ---- Dependency check ----
  for (pkg in c("officer", "flextable")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(paste0("Package '", pkg, "' is required for export_to_word(). ",
                  "Install with: install.packages('", pkg, "')"))
    }
  }

  if (!inherits(result, "easystat_result")) {
    stop("'result' must be an object of class 'easystat_result'.")
  }

  # ---- Auto-title ----
  test_label <- switch(result$test_type,
    regression          = "Linear Regression Analysis",
    logistic_regression = "Logistic Regression Analysis",
    ttest               = "Independent-Samples t-Test",
    anova               = "One-Way ANOVA",
    "Statistical Analysis"
  )
  if (is.null(title)) title <- paste("EasyStat Report:", test_label)

  # ---- Helper: build a themed flextable ----
  .make_ft <- function(df) {
    ft <- flextable::flextable(df)
    ft <- flextable::set_table_properties(ft, width = 1, layout = "autofit")
    ft <- flextable::bold(ft, part = "header")
    ft <- flextable::bg(ft, bg = "#2E5FA3", part = "header")
    ft <- flextable::color(ft, color = "white", part = "header")
    ft <- flextable::bg(ft, i = seq(2, nrow(df), by = 2),
                        bg = "#EEF3FB", part = "body")
    ft <- flextable::border_outer(ft,
            border = officer::fp_border(color = "#2E5FA3", width = 1.5))
    ft <- flextable::border_inner_h(ft,
            border = officer::fp_border(color = "#BED0E8", width = 0.5))
    ft <- flextable::fontsize(ft, size = 10, part = "all")
    ft <- flextable::font(ft, fontname = "Arial", part = "all")
    ft <- flextable::padding(ft, padding = 4, part = "all")
    ft
  }

  # ---- Helper: body text paragraph ----
  .body_text <- function(doc, text_str) {
    doc <- officer::body_add_par(doc, text_str,
             style = "Normal")
    doc
  }

  # ---- Build officer document ----
  doc <- officer::read_docx()

  # Title
  doc <- officer::body_add_par(doc, title, style = "heading 1")

  # Metadata line
  meta <- paste0("Test type: ", test_label,
                 "  |  Formula/Comparison: ", result$formula_str,
                 "  |  Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M"),
                 "  |  Author: ", author)
  doc <- officer::body_add_par(doc, meta, style = "Normal")
  doc <- officer::body_add_par(doc, "", style = "Normal")  # spacer

  # Section: Narrative
  doc <- officer::body_add_par(doc, "Plain-Language Interpretation", style = "heading 2")

  # Split narrative on newlines and add each as its own paragraph
  narrative_parts <- strsplit(result$explanation, "\n")[[1]]
  for (part in narrative_parts) {
    if (nchar(trimws(part)) > 0) {
      doc <- officer::body_add_par(doc, part, style = "Normal")
    }
  }
  doc <- officer::body_add_par(doc, "", style = "Normal")

  # Section: Main Results Table
  doc <- officer::body_add_par(doc, "Table 1 \u2014 Main Results", style = "heading 2")
  doc <- flextable::body_add_flextable(doc, .make_ft(result$coefficients_table))
  doc <- officer::body_add_par(doc, "", style = "Normal")

  # Section: Model Fit Table
  doc <- officer::body_add_par(doc, "Table 2 \u2014 Model Fit / Summary", style = "heading 2")
  doc <- flextable::body_add_flextable(doc, .make_ft(result$model_fit_table))
  doc <- officer::body_add_par(doc, "", style = "Normal")

  if (!is.null(result$additional_tables) && length(result$additional_tables) > 0) {
    table_no <- 3
    for (nm in names(result$additional_tables)) {
      doc <- officer::body_add_par(doc, paste0("Table ", table_no, " \u2014 ", nm), style = "heading 2")
      doc <- flextable::body_add_flextable(doc, .make_ft(result$additional_tables[[nm]]))
      doc <- officer::body_add_par(doc, "", style = "Normal")
      table_no <- table_no + 1
    }
  }

  # Footer note
  doc <- officer::body_add_par(doc,
    paste0("Report generated by the EasyStat R Package. ",
           "Authors: Mr. Mahesh Divakaran, Dr. Gunjan Singh, ",
           "Prof. Dr. Jayadevan Shreedharan. ",
           "Amity University Lucknow & Gulf Medical University."),
    style = "Normal")

  # ---- Write to disk ----
  print(doc, target = file)

  message("Word document saved: ", normalizePath(file, mustWork = FALSE))
  invisible(file)
}

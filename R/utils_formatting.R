# Internal formatting helpers -------------------------------------------------

.format_p_value <- function(p_value, digits = 4) {
  vapply(p_value, function(p) {
    if (is.na(p)) return("NA")

    pct <- p * 100
    eps <- 10^-digits

    if (pct > 0 && pct < eps) {
      paste0("<", formatC(eps, format = "f", digits = digits), "%")
    } else {
      paste0(formatC(pct, format = "f", digits = digits), "%")
    }
  }, character(1), USE.NAMES = FALSE)
}

.format_p_statement <- function(p_value, digits = 4) {
  p_text <- .format_p_value(p_value, digits = digits)
  ifelse(grepl("^<", p_text),
         paste0("p < ", sub("^<", "", p_text)),
         paste0("p = ", p_text))
}

.format_compact_number <- function(x, digits = 4) {
  vapply(x, function(value) {
    if (is.na(value)) return("NA")
    if (abs(value) >= 10000 || (abs(value) > 0 && abs(value) < 0.0001)) {
      formatC(value, format = "e", digits = digits)
    } else {
      formatC(value, format = "f", digits = digits)
    }
  }, character(1), USE.NAMES = FALSE)
}

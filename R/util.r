#' Pluralize
#' pluralize a string with either the default 's' according to the boolean statement
#'
#' @param string string to be pluralized
#' @param obj object to look at
#' @param plural plural string
#' @param bool_statement boolean to use to determine which string to use
#' @author Barret Schloerke \email{schloerke@@gmail.com}
#' @keywords internal 
pluralize <- function(string, obj, plural = str_c(string, "s"), bool_statement = NROW(obj)) {
  if (bool_statement) {
    plural
  } else {
    string
  }
}


#' Strip HTML
#' strip the HTML from a text string
#'
#' @param x text string in question
#' @author Hadley Wickham
#' @keywords internal 
strip_html <- function(x) {
  str_replace_all(x, "</?.*?>", "")
}

#' @importFrom highlight highlight renderer_html formatter_html
src_highlight <- function(text, index) {
  if (length(text) == 1L && str_trim(text) == "") return("")

  expr <- NULL
  try(expr <- utils::getParseData(parse(text = text, keep.source = TRUE)))
  if (length(expr) == 0) return(text)

  # Custom formatter that adds links to function calls
  formatter <- function(tokens, styles, ...) {
    funcall <- styles == "functioncall"
    for (i in which(funcall)) {
      loc <- find_topic(tokens[i], NULL, index = index)
      if (is.null(loc)) {
        message("Can't find help topic '", tokens[i], "'")
      } else {
        tokens[i] <- make_link(loc, label = tokens[i])
      }
    }

    formatter_html(tokens, styles, ...)
  }

  renderer <- renderer_html(document = FALSE, formatter = formatter)
  out <- utils::capture.output(highlight(parse.output = expr, renderer = renderer))
  # Drop pre tag
  out <- out[-c(1, length(out))]
  str_c(out, collapse = "\n")
}

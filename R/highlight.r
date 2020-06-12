# highlight_text mutates the linking scope because it has to register
# library()/require() calls in order to link unqualified symbols to the
# correct package.
highlight_text <- function(text) {
  out <- downlit::highlight(text, classes = downlit::classes_pandoc())
  if (is.na(out)) {
    escape_html(text)
  } else {
    out
  }
}

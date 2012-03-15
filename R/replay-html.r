# Replay a list of evaluated results, just like you'd run them in a R
# terminal, but rendered as html

replay_html <- function(x, ...) UseMethod("replay_html", x)

replay_html.list <- function(x, ...) {
  browser()
  pieces <- vapply(seq_along(x), function(i) {
    replay_html(x[[i]], obj_id = i, ...)
  }, FUN.VALUE = character(1))
  
  str_c(pieces, collapse = "\n")
}

replay_html.character <- function(x, ...) {
  str_c("<div class='output'>", str_c(x, collapse = ""), "</div>")
}

replay_html.value <- function(x, ...) {
  if (!x$visible) return()
  
  printed <- str_c(capture.output(print(x$value)), collapse = "\n")
  str_c("<div class='output'>", printed, "</div>")
}

replay_html.source <- function(x, ...) {
  if (str_trim(x$src) == "") return("")

  parsed <- parser(text = x$src)
  str_c("<div class='input'>", src_highlight(parsed), "</div>")
}

replay_html.warning <- function(x, ...) {
  str_c("<strong class='warning'>Warning message:\n", x$message, "</strong>")
}

replay_html.message <- function(x, ...) {
  str_c("<strong class='message'>", str_replace(x$message, "\n$", ""),
   "</strong>")
}

replay_html.error <- function(x, ...) {
  if (is.null(x$call)) {
    str_c("<strong class='error'>Error: ", x$message, "</strong>")
  } else {
    call <- deparse(x$call)
    str_c("<strong class='error'>Error in ", call, ": ", x$message,
     "</strong>")
  }
}

replay_html.recordedplot <- function(x, path_prefix, obj_id) {  
  path <- file.path(str_c(path_prefix, obj_id, ".png", collapse = ""))
  
  if (!file.exists(path)) { 
    png(path, width = 400, height = 400, res = 96)
    on.exit(dev.off())
    print(x)
  }

  str_c("<p><img src='", path, "' alt='' width='400' height='400' /></p>")
}

#' @importFrom highlight highlight
#' @importFrom highlight renderer_html
src_highlight <- function(expr) {
  if (length(expr) == 0) return("")
  
  renderer <- renderer_html(doc = FALSE)
  out <- capture.output(highlight(parser.output = expr, renderer = renderer))
  # Drop pre tag
  out <- out[-c(1, length(out))]
  str_c(out, collapse = "\n")
}

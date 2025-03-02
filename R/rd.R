rd_text <- function(x, fragment = TRUE) {
  con <- textConnection(x)
  on.exit(close(con), add = TRUE)

  set_classes(tools::parse_Rd(con, fragment = fragment, encoding = "UTF-8"))
}

rd_file <- function(path, pkg_path = NULL) {
  macros <- tools::loadPkgRdMacros(pkg_path)
  set_classes(tools::parse_Rd(path, macros = macros, encoding = "UTF-8"))
}

#' Translate an Rd string to its HTML output
#'
#' @param x Rd string. Backslashes must be double-escaped ("\\\\").
#' @param fragment logical indicating whether this represents a complete Rd file
#' @param ... additional arguments for as_html
#'
#' @examples
#' rd2html("a\n%b\nc")
#'
#' rd2html("a & b")
#'
#' rd2html("\\strong{\\emph{x}}")
#'
#' @export
rd2html <- function(x, fragment = TRUE, ...) {
  html <- as_html(rd_text(x, fragment = fragment), ...)
  str_trim(strsplit(str_trim(html), "\n")[[1]])
}

print.Rd <- function(x, ...) {
  utils::str(x)
}
#' @export
print.tag <- function(x, ...) {
  utils::str(x)
}

# Convert RD attributes to S3 classes -------------------------------------

set_classes <- function(rd) {
  if (is.list(rd)) {
    rd[] <- lapply(rd, set_classes)
  }
  set_class(rd)
}

set_class <- function(x) {
  structure(
    x,
    class = c(attr(x, "class"), tag(x), "tag"),
    Rd_tag = NULL,
    srcref = NULL,
    macros = NULL
  )
}

tag <- function(x) {
  tag <- attr(x, "Rd_tag")
  if (is.null(tag)) return()

  gsub("\\", "tag_", tag, fixed = TRUE)
}

#' @export
`[.tag` <- function(x, ...) {
  structure(NextMethod(), class = class(x))
}

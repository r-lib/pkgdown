rd_text <- function(x, fragment = TRUE) {
  con <- textConnection(x)
  on.exit(close(con), add = TRUE)

  set_classes(tools::parse_Rd(con, fragment = fragment))
}

rd_file <- function(path) {
  # Use permissive = TRUE to suppress warnings from unknown macros
  # These are someone's elses problem
  set_classes(tools::parse_Rd(path, permissive = TRUE))
}

rd2html <- function(x, fragment = TRUE, ...) {
  html <- as_html(rd_text(x, fragment = fragment), ...)
  trimws(strsplit(trimws(html), "\n")[[1]])
}

#' @export
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
  structure(x,
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

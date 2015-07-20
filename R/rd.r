#' Parse an rd file in to staticdocs format.
#'
#' Rd files are pretty printed with structural elements coloured blue, and
#' leaves are given a short prefix: \code{\"} = text, \code{\'} = verbatim, and
#' \code{>} = R code.
#'
#' @param topic topic name, as character vector
#' @param package package name, as character vector
#' @export
#' @examples
#' parse_rd("whisker.render", "whisker")
parse_rd <- function(topic, package) {
  rd <- utils:::.getHelpFile(rd_path(topic, package))
  structure(set_classes(rd), class = "Rd_doc")
}

package_rd <- function(package) {
  package <- as.sd_package(package)

  rd <- dir(file.path(package$path, "man"), full.names = TRUE)
  names(rd) <- basename(rd)
  lapply(rd, cached_parse_Rd)
}

clear_cache <- function() {
  rd_cache <<- new.env(TRUE, emptyenv())
}
rd_cache <- NULL
if (is.null(rd_cache)) clear_cache()

#' @importFrom digest digest
cached_parse_Rd <- function(path) {
  hash <- digest(path, file = TRUE)

  if (exists(hash, envir = rd_cache)) {
    rd_cache[[hash]]
  } else {
    raw_rd <- parse_Rd(path)
    rd <- structure(set_classes(raw_rd), class = "Rd_content")
    rd_cache[[hash]] <- rd
    rd
  }

}

rd_path <- function(topic, package = NULL) {
  topic <- as.name(topic)
  if (!is.null(package)) package <- as.name(package)

  help_call <- substitute(help(topic, package = package, try.all.packages = TRUE),
    list(topic = topic, package = package))

  res <- eval(help_call)
  if (length(res) == 0) return(NULL)

  res[[1]]
}

find_topic <- function(alias, package = NULL, index) {
  # Current package, so look in index first
  if (is.null(package)) {
    match <- Position(function(x) any(x == alias), index$alias)
    if (!is.na(match)) {
      return(list(package = NULL, file = index$file_out[match]))
    }
  }

  path <- rd_path(alias, package)
  if (is.null(path)) return(NULL)

  pieces <- str_split(path, .Platform$file.sep)[[1]]
  n <- length(pieces)

  list(package = pieces[n - 2], topic = pieces[n])
}

tag <- function(x) {
  tag <- attr(x, "Rd_tag")
  if (is.null(tag)) return()

  str_replace_all(tag, fixed("\\"), "")
}

set_class <- function(x) {
  structure(x, class = unique(c(tag(x), "Rd_content", class(x))))
}

# Recursively set classes of Rd objects
set_classes <- function(rd) {
  if (is.list(rd)) {
    new_rd <- lapply(rd, set_classes)
    attr(new_rd, "Rd_tag") <- attr(rd, "Rd_tag")
    attr(new_rd, "Rd_option") <- attr(rd, "Rd_option")
    set_class(new_rd)
  } else {
    set_class(rd)
  }
}

#' @export
as.list.Rd_content <- function(x, ...) {
  class(x) <- NULL
  x
}

#' @export
print.Rd_content <- function(x, ..., indent = 0) {
  cat(str_dup(" ", indent), "\\- ", crayon::blue(tag(x)),
    " (", length(x), ")\n", sep = "")
  # lapply(as.list(x), print.Rd_content, indent = indent + 2)
}

#' @export
print.TEXT <- function(x, ..., indent = 0) block(x, indent, '"')
#' @export
print.VERB <- function(x, ..., indent = 0) block(x, indent, "'")
#' @export
print.RCODE <- function(x, ..., indent = 0) block(x, indent, ">")
#' @export
print.COMMENT <- function(x, ..., indent = 0) block(x, indent, "%")

block <- function(x, indent = 0, prefix = "'") {
  x <- str_trim(x)

  start <- str_c(str_dup(" ", indent), crayon::blue(prefix), " ")
  cat(start, str_sub(x, 0, getOption("width") - str_length(start)), "\n",
    sep = "")
}

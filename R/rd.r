#' Parse an rd file in to staticdocs format.
#'
#' Rd files are pretty printed with structural elements coloured blue, and
#' leaves are given a short prefix: \code{"} = text, \code{'} = verbatim, and
#' \code{>} = R code.
#'
#' @examples 
#' rd <- parse_rd("geom_point", "ggplot2")
parse_rd <- function(topic, package) {
  help_call <- substitute(help(topic, package = package), 
    list(topic = as.name(topic), package = as.name(package)))
  
  rd_path <- eval(help_call)[[1]]
  rd <- utils:::.getHelpFile(rd_path)
  structure(set_classes(rd), class = c("Rd_doc", "Rd"))
}


#' @importFrom stringr str_replace_all
tag <- function(x) {
  tag <- attr(x, "Rd_tag")
  if (is.null(tag)) return()
  
  str_replace_all(tag, fixed("\\"), "")
}

set_class <- function(x) {
  structure(x, class = unique(c(tag(x), "Rd", class(x))))
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

is.Rd <- function(x) inherits(x, "Rd")

as.list.Rd <- function(x) {
  class(x) <- NULL
  x
}

print.Rd <- function(x, ..., indent = 0) {
  cat(str_dup(" ", indent), "\\- ", colourise(tag(x), "blue"), 
    " (", length(x), ")\n", sep = "")
  
  lapply(x, print, indent = indent + 2)    
}

print.TEXT <- function(x, ..., indent = 0) block(x, indent, '"')
print.VERB <- function(x, ..., indent = 0) block(x, indent, "'")
print.RCODE <- function(x, ..., indent = 0) block(x, indent, ">")
print.COMMENT <- function(x, ..., indent = 0) block(x, indent, "%")

#' @importFrom testthat colourise
block <- function(x, indent = 0, prefix = "'") {
  x <- str_trim(x)

  start <- str_c(str_dup(" ", indent), colourise(prefix, "blue"), " ")
  cat(start, str_sub(x, 0, getOption("width") - str_length(start)), "\n", 
    sep = "")  
}
#' @examples 
#' rd <- parse_rd("geom_point", "ggplot2")
parse_rd <- function(topic, package) {
  help_call <- substitute(help(topic, package = package), 
    list(topic = as.name(topic), package = as.name(package)))
  
  rd_path <- eval(help_call)[[1]]
  rd <- utils:::.getHelpFile(rd_path)
  set_classes(rd)
}


#' @importFrom stringr str_replace_all
tag <- function(x) {
  tag <- attr(x, "Rd_tag")
  if (is.null(tag)) return()
  
  str_replace_all(tag, fixed("\\"), "")
}

set_class <- function(x) {
  structure(x, class = c(tag(x), "Rd", class(x)))
}

# Recursively set classes of Rd objects
set_classes <- function(Rd) {
  if (is.list(Rd)) {
    new_Rd <- set_class(lapply(Rd, set_classes))
    attr(new_Rd, "Rd_tag") <- attr(Rd, "Rd_tag")
    attr(new_Rd, "Rd_option") <- attr(Rd, "Rd_option")
    new_Rd
  } else {
    set_class(Rd)
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

#' @importFrom testthat colourise
block <- function(x, indent = 0, prefix = "'") {
  x <- str_trim(x)

  start <- str_c(str_dup(" ", indent), colourise(prefix, "blue"), " ")
  cat(start, str_sub(x, 0, getOption("width") - str_length(start)), "\n", 
    sep = "")  
}
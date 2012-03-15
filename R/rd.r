#' @examples 
#' rd <- parse_rd("geom_point", "ggplot2")
parse_rd <- function(topic, package) {
  help_call <- substitute(help(topic, package = package), 
    list(topic = as.name(topic), package = as.name(package)))
  
  rd_path <- eval(help_call)[[1]]
  set_classes(utils:::.getHelpFile(rd_path))
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
    lapply(Rd, set_class)
  } else {
    set_class(Rd)
  }
}

is.Rd <- function(x) inherits(x, "Rd")

as.list.Rd <- function(x) {
  class(x) <- NULL
  x
}



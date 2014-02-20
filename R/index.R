# `index.r` is a regular R file - we parse it, evaluate each line, and then
# return all results that are a sd_section
load_index <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  path <- file.path(pkg$sd_path, "index.r")
  if (!file.exists(path)) return(list())

  env <- new.env(parent = globalenv())

  expr <- parse(path)
  out <- lapply(expr, eval, env = env)

  # Return all objects of class sd_section
  Filter(function(x) inherits(x, "sd_section"), out)
}

#' Define a section for the index page
#'
#' @param name Name of the section. Used as title.
#' @param description Paragraph description of the section. May use markdown.
#' @param elements Either a list containing either strings giving function
#'   names, or if you want to override defaults from the rd file,
#    objects created by \code{\link{sd_item}}
#' @export
sd_section <- function(name, description, elements) {
  elements <- as.list(elements)
  strings <- vapply(elements, is.character, logical(1))
  elements[strings] <- lapply(elements[strings], sd_item)

  topics <- unlist(lapply(elements, "[[", "name"))

  structure(list(name = name, description = description, elements = elements,
    topics = topics), class = "sd_section")
}

#' @export
print.sd_section <- function(x, ...) {
  cat("<sd_section> ", x$name, "\n", x$description, "\n", sep = "")
  cat("Topics: ", paste0(x$topics, collapse = ", "), "\n", sep = "")
}

#' Define an item in a section of the index.
#'
#' @param name name of the function
#' @param title override the default title extracted from the corresponding Rd
#'   file
#' @export
sd_item <- function(name, title = NULL) {
  list(name = name, title = title)
}

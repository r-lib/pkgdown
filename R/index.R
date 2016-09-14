# `index.r` is a regular R file - we parse it, evaluate each line, and then
# return all results that are a sd_section
load_index <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  path <- file.path.ci(pkg$sd_path, "index.R")
  if (!file.exists(path))
    return(load_index_yaml(pkg))

  library(staticdocs) # might only be attached.
  env <- new.env(parent = globalenv())

  expr <- parse(path)
  out <- lapply(expr, eval, env = env)

  # Return all objects of class sd_section
  Filter(function(x) inherits(x, "sd_section"), out)
}

#' @importFrom yaml yaml.load_file
load_index_yaml <- function(pkg) {

  path <- file.path.ci(pkg$sd_path, "index.yaml")
  if (!file.exists(path)) return(list())
  index_list=try(yaml.load_file(path))
  if(inherits(index_list, 'try-error'))
    stop("Invalid yaml index file: ", path)
  lapply(names(index_list),
         function (n) sd_section(n, index_list[[n]]$desc, index_list[[n]]$topics))
}

#' Write yaml index file for all help topics
#'
#' This function will produce a file `index-all.yaml` in `inst/staticdocs` that
#' you can edit and resave as `index.yaml`. This will then be accepted as an
#' alternative to the `index.R` used to generate a custom ordering of the
#' function reference section of a static docs site.
#'
#' @inheritParams build_site
#' @importFrom yaml as.yaml
#' @export
#' @seealso \code{\link{sd_section}}, \code{\link{write_index_r}}
write_index_yaml <- function(pkg = '.') {
  pkg <- as.sd_package(pkg)
  path <- file.path.ci(pkg$sd_path, "index-all.yaml")
  dir=dirname(path)
  if(!file.exists(dir))
    dir.create(dir, recursive = TRUE)
  topics=pkg$rd_index$name
  l=list("All topics"=list(description="", topics=topics))
  writeLines(yaml::as.yaml(l), con = path)
}

#' Write index.R file for all help topics
#'
#' This function will produce a file `index-all.R` in `inst/staticdocs` that you
#' can edit and resave as `index.R`. This will generate a custom ordering of the
#' function reference section of a static docs site.
#'
#' @inheritParams build_site
#' @importFrom yaml as.yaml
#' @export
#' @seealso \code{\link{sd_section}}, \code{\link{write_index_yaml}}
write_index_r <- function(pkg = '.') {
  pkg <- as.sd_package(pkg)
  path <- file.path.ci(pkg$sd_path, "index-all.r")
  dir=dirname(path)
  if(!file.exists(dir))
    dir.create(dir, recursive = TRUE)
  topics=pkg$rd_index$name
  # make R code representation of section
  ss=substitute(sd_section("All topics", description = "", elements = topics))
  dss=deparse(ss)
  # some formatting
  dss=paste(dss, collapse = "")
  dss=gsub('",','",\n', dss, fixed = TRUE)
  dss=gsub('c(','c(\n ', dss, fixed = TRUE)
  dss=gsub('\\n[ ]+','\n    ',dss)
  dss=gsub('\\)\\)$','\n))\n',dss)
  cat(dss, file = path)
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

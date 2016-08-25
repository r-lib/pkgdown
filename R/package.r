#' Return information about a package
#'
#' @param pkg name of package, as character vector
#' @param site_path root Directory in which to create documentation.
#' @param examples Run examples?
#' @param templates_path Path in which to look for templates. If this doesn't
#'   exist will look next in \code{pkg/inst/staticdocs/templates}, then
#'   in staticdocs itself.
#' @param bootstrap_path Path in which to look for bootstrap files. If
#'   this doesn't exist, will use files built into staticdocs.
#' @param mathjax Use mathjax to render math symbols?
#' @return A named list of useful metadata about a package
#' @export
#' @keywords internal
#' @importFrom devtools parse_deps as.package
as.sd_package <- function(pkg = ".",
                          site_path = "docs",
                          examples = TRUE,
                          templates_path = "inst/staticdocs/templates",
                          bootstrap_path = "inst/staticdocs/bootstrap",
                          mathjax = TRUE
                          ) {
  if (is.sd_package(pkg)) return(pkg)

  pkg <- as.package(pkg)
  class(pkg) <- c("sd_package", "package")
  pkg$sd_path <- pkg_sd_path(pkg)

  pkg$site_path <- site_path
  pkg$examples <- examples
  pkg$templates_path <- templates_path
  pkg$bootstrap_path <- bootstrap_path

  pkg$index <- load_index(pkg)
  pkg$icons <- load_icons(pkg)

  if (!is.null(pkg[["url"]])) {
    pkg$urls <- str_trim(str_split(pkg[["url"]], ",")[[1]])
    pkg[["url"]] <- NULL
  }

  # Author info
  if (!is.null(pkg$`authors@r`)) {
    pkg$authors <- eval(parse(text = pkg$`authors@r`))
    pkg$authors <- utils::as.person(pkg$authors)
    pkg$authors <- sapply(pkg$authors, str_person)
  }

  # Dependencies
  pkg$dependencies <- list(
    depends = str_c(parse_deps(pkg$depends)$name, collapse = ", "),
    imports = str_c(parse_deps(pkg$imports)$name, collapse = ", "),
    suggests = str_c(parse_deps(pkg$suggests)$name, collapse = ", "),
    extends = str_c(parse_deps(pkg$extends)$name, collapse = ", ")
  )
  pkg$dependencies <- ifelse(pkg$dependencies == "", FALSE, pkg$dependencies)

  pkg$rd <- package_rd(pkg)
  pkg$rd_index <- topic_index(pkg$rd)

  pkg
}

str_person <- function(pers) {
  s <- paste0(c(pers$given, pers$family), collapse = ' ')

  if (length(pers$email)) {
    s <- paste0("<a href='mailto:", pers$email, "'>", s, "</a>")
  }
  if (length(pers$role)) {
    s <- paste0(s, " [", paste0(pers$role, collapse = ", "), "]")
  }
  s
}

is.sd_package <- function(x) inherits(x, "sd_package")

topic_index <- function(rd) {
  aliases <- unname(lapply(rd, extract_alias))

  names <- unlist(lapply(rd, extract_name), use.names = FALSE)
  file_in <- names(rd)
  file_out <- str_replace(file_in, "\\.Rd$", ".html")

  data.frame(
    name = names,
    alias = I(aliases),
    file_in = file_in,
    file_out = file_out,
    stringsAsFactors = FALSE
  )
}

extract_alias <- function(x) {
  aliases <- Filter(function(x) attr(x, "Rd_tag") == "\\alias", x)
  vapply(aliases, function(x) x[[1]][[1]], character(1))
}

extract_name <- function(x) {
  alias <- Find(function(x) attr(x, "Rd_tag") == "\\name", x)
  alias[[1]][[1]]
}


#' @export
print.sd_package <- function(x, ...) {
  cat("Package: ", x$package, " @ ", dirname(x$path), " -> ", x$site_path,
    "\n", sep = "")

  topics <- strwrap(paste(sort(x$rd_index$name), collapse = ", "),
    indent = 2, exdent = 2, width = getOption("width"))
  cat("Topics:\n", paste(topics, collapse = "\n"), "\n", sep = "")

}

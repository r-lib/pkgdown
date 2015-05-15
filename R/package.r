#' Return information about a package
#'
#' @param package name of package, as character vector
#' @param base_path root directory in which to create documentation. The
#'   default, \code{NULL}, first looks at the value of \code{site_path} set in
#'   \file{DESCRIPTION}, and if not found uses \code{inst/web}.
#' @param examples include examples or not? The default, \code{NULL}, first
#'   looks at the value of \code{examples} set in \file{DESCRIPTION}, and if
#'   not found uses \code{TRUE}.
#' @param templates_path a specific directory path to use when searching for
#'   rendering templates, in addition to the default locations of
#'   packagedir/inst/staticdocs, packagedir/staticdocs, and the staticdocs
#'   package's included templates directory.
#' @param bootstrap_path a specific directory path to use when searching for
#'   bootstrap style files, in addition to the default locations of
#'   packagedir/inst/staticdocs, packagedir/staticdocs, and the staticdocs
#'   package's included bootstrap directory.
#' @param mathjax whether to use mathjax to render math symbols.
#' @return A named list of useful metadata about a package
#' @export
#' @keywords internal
#' @importFrom devtools parse_deps as.package
as.sd_package <- function(pkg = ".", site_path = NULL, examples = NULL,
  templates_path = NULL, bootstrap_path = NULL, mathjax = TRUE) {
  if (is.sd_package(pkg)) return(pkg)

  pkg <- as.package(pkg)
  class(pkg) <- c("sd_package", "package")
  pkg$sd_path <- pkg_sd_path(pkg)

  pkg$index <- load_index(pkg)
  pkg$icons <- load_icons(pkg)

  settings <- load_settings(pkg)
  pkg$site_path <- site_path %||% settings$site_path %||% "inst/web"
  pkg$examples <- examples %||% settings$examples %||% TRUE
  pkg$templates_path <- templates_path %||% settings$templates_path %||%
                                              "inst/staticdocs/templates"
  pkg$bootstrap_path <- bootstrap_path %||% settings$bootstrap_path %||%
                                              "inst/staticdocs/bootstrap"
  pkg$mathjax <- mathjax %||% settings$mathjax %||% TRUE
  if (!is.null(pkg$url)) {
    pkg$urls <- str_trim(str_split(pkg$url, ",")[[1]])
    pkg$url <- NULL
  }

  # Author info
  if (!is.null(pkg$`authors@r`)) {
    str_person <- function(pers) {
      s <- NULL
      if (length(pers$email))
        s <- paste('<a href="mailto:', pers$email, '">', sep='')
      if (length(pers$given))
        s <- paste(s, pers$given, sep='')
      if (length(pers$family))
        s <- paste(s, pers$family, sep=' ')
      if (length(pers$email))
        s <- paste(s, '</a>', sep='')
      if (length(pers$role))
        s <- paste(s, ' [', paste(pers$role, collapse=', '), ']', sep='')
      return(s)
    }

    pkg$authors <- eval(parse(text = pkg$`authors@r`))
    pkg$authors <- sapply(pkg$authors, str_person)
  }

  # Dependencies
  pkg$dependencies <- list(
    depends = str_c(parse_deps(pkg$depends)$name, collapse = ", "),
    imports = str_c(parse_deps(pkg$imports)$name, collapse = ", "),
    suggests = str_c(parse_deps(pkg$suggests)$name, collapse = ", "),
    extends = str_c(parse_deps(pkg$extends)$name, collapse = ", ")
  )

  pkg$rd <- package_rd(pkg)
  pkg$rd_index <- topic_index(pkg$rd)

  pkg
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

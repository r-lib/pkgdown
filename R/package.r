#' Return information about a package
#'
#' @param package name of package, as character vector
#' @return A named list of useful metadata about a package
#' @export
#' @keywords internal
#' @importFrom devtools as.package
package_info <- function(package, base_path = NULL, examples = NULL) {
  out <- as.package(package)
  settings <- load_settings(out$path)
  
  out$base_path <- base_path %||% settings$base_path %||% 
    stop("base_path not specified", call. = FALSE)
  out$examples <- examples %||% settings$examples %||% TRUE

  if (!is.null(out$url)) {
    out$urls <- str_trim(str_split(out$url, ",")[[1]])
    out$url <- NULL
  }
  # Dependencies 
  parse_deps <- devtools:::parse_deps
  out$dependencies <- list(
    depends = str_c(parse_deps(out$depends), collapse = ", "),
    imports = str_c(parse_deps(out$imports), collapse = ", "),
    suggests = str_c(parse_deps(out$suggests), collapse = ", "),
    extends = str_c(parse_deps(out$extends), collapse = ", ")
  )
  
  out$rd <- package_rd(package)
  out$rd_index <- topic_index(out$rd)

  structure(out, class = "package_info")
}

topic_index <- function(rd) {
  aliases <- lapply(rd, extract_alias)
  
  file_in <- rep(names(aliases), vapply(aliases, length, integer(1)))
  file_out <- str_replace(file_in, "\\.Rd$", ".html")
  
  data.frame(
    alias = unlist(aliases, use.names = FALSE),
    file_in = file_in,
    file_out = file_out,
    stringsAsFactors = FALSE
  )
  
}

extract_alias <- function(x) {
  alias <- Find(function(x) attr(x, "Rd_tag") == "\\alias", x)
  alias[[1]][[1]]
}


#' @S3method print package_info
print.package_info <- function(x, ...) {
  cat("Package: ", x$package, "\n", sep = "")
  cat(x$path, " -> ", x$base_path, "\n", sep = "")
  
  topics <- strwrap(paste(sort(x$rd_index$alias), collapse = ", "), 
    indent = 2, exdent = 2, width = getOption("width"))
  cat("Topics:\n", paste(topics, collapse = "\n"), "\n", sep = "")
  
}

#' @importFrom rjson fromJSON
load_settings <- function(package_path) {
  path <- file.path(package_path, "staticdocs.json")
  if (!file.exists(path)) return(list())

  fromJSON(file = path)
}
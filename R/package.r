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
  out$index <- settings$index
  out$icons <- settings$icon
  out$readme <- settings$readme
  
  out$base_path <- base_path %||% settings$base_path %||% 
    stop("base_path not specified", call. = FALSE)
  out$examples <- examples %||% settings$examples %||% TRUE

  if (!is.null(out$url)) {
    out$urls <- str_trim(str_split(out$url, ",")[[1]])
    out$url <- NULL
  }
  
  # Author info
  authors <- 
  if (!is.null(out$`authors@r`)) {
    authors <- eval(parse(text = out$`authors@r`))
	format(authors)
  }else if (!is.null(out$author)) {
	str_trim(str_split(out$author, ",")[[1]])
  }
  if( !is.null(authors) ){
	  m <- str_match(authors, "([^<]+)\\s*(<([^>]+)>)?")
	  authors <- str_c(m[,2], ifelse( m[,4] != '', str_c('(', cloak_email(m[,4]), ')'), ''))
	  out$authors <- list(author=unname(apply(cbind(name=authors), 1, as.list)))
	  out$author <- NULL
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


#' @S3method print package_info
print.package_info <- function(x, ...) {
  cat("Package: ", x$package, "\n", sep = "")
  cat(x$path, " -> ", x$base_path, "\n", sep = "")
  
  topics <- strwrap(paste(sort(x$rd_index$name), collapse = ", "), 
    indent = 2, exdent = 2, width = getOption("width"))
  cat("Topics:\n", paste(topics, collapse = "\n"), "\n", sep = "")
  
}

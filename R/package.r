#' @importFrom devtools parse_deps as.package
as.sd_package <- function(pkg = ".", ...) {
  if (is.sd_package(pkg)) return(pkg)

  pkg <- as.package(pkg)
  class(pkg) <- c("sd_package", "package")
  pkg$sd_path <- pkg_sd_path(pkg)

  pkg <- utils::modifyList(pkg, list(...))

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

  pkg$topics <- topic_index(pkg)
  pkg$meta <- read_meta(pkg)

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

topic_index <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  rd <- package_rd(pkg)
  aliases <- unname(lapply(rd, extract_alias))

  names <- purrr::map_chr(rd, extract_name)
  titles <- purrr::map_chr(rd, extract_title)
  titles <- purrr::map_chr(rd, extract_title)

  file_in <- names(rd)
  file_out <- str_replace(file_in, "\\.Rd$", ".html")

  tibble::tibble(
    name = names,
    file_in = file_in,
    file_out = file_out,
    alias = aliases,
    title = titles,
    rd = rd,
    internal = FALSE # TODO
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

extract_title <- function(x, pkg) {
  title <- Find(function(x) attr(x, "Rd_tag") == "\\title", x)
  to_html(title, pkg = pkg)
}


#' @export
print.sd_package <- function(x, ...) {
  cat("Package: ", x$package, " @ ", dirname(x$path), " -> ", x$site_path,
    "\n", sep = "")

  topics <- strwrap(paste(sort(x$topics$name), collapse = ", "),
    indent = 2, exdent = 2, width = getOption("width"))
  cat("Topics:\n", paste(topics, collapse = "\n"), "\n", sep = "")

}

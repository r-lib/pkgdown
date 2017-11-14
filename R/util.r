#' @importFrom magrittr %>%
#' @importFrom roxygen2 roxygenise
#' @importFrom R6 R6Class
#' @import rlang
NULL

inst_path <- function() {
  if (is.null(pkgload::dev_meta("pkgdown"))) {
    # pkgdown is probably installed
    system.file(package = "pkgdown")
  } else {
    # pkgdown was probably loaded with devtools
    file.path(getNamespaceInfo("pkgdown", "path"), "inst")
  }
}

markdown_text <- function(text, ...) {
  if (is.null(text))
    return(text)

  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  writeLines(text, tmp)
  markdown(tmp, ...)
}

markdown <- function(path = NULL, ..., depth = 0L) {
  tmp <- tempfile(fileext = ".html")
  on.exit(unlink(tmp), add = TRUE)

  if (rmarkdown::pandoc_available("2.0")) {
    from <- "markdown_github-hard_line_breaks+smart"
  } else {
    from <- "markdown_github-hard_line_breaks"
  }

  rmarkdown::pandoc_convert(
    input = path,
    output = tmp,
    from = from,
    to = "html",
    options = purrr::compact(list(
      if (!rmarkdown::pandoc_available("2.0")) "--smart",
      "--indented-code-classes=R",
      "--section-divs",
      ...
    ))
  )

  xml <- xml2::read_html(tmp, encoding = "UTF-8")
  tweak_code(xml, depth = depth)
  tweak_anchors(xml, only_contents = FALSE)

  # Extract body of html - as.character renders as xml which adds
  # significant whitespace in tags like pre
  xml %>%
    xml2::xml_find_first(".//body") %>%
    xml2::write_html(tmp, format = FALSE)

  lines <- readLines(tmp, warn = FALSE)
  lines <- sub("<body>", "", lines, fixed = TRUE)
  lines <- sub("</body>", "", lines, fixed = TRUE)
  paste(lines, collapse = "\n")
}

set_contains <- function(haystack, needles) {
  all(needles %in% haystack)
}

mkdir <- function(..., quiet = FALSE) {
  path <- file.path(...)

  if (!file.exists(path)) {
    if (!quiet)
      message("Creating '", path, "/'")
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
}

rule <- function(..., pad = "-") {
  if (nargs() == 0) {
    title <- ""
  } else {
    title <- paste0(..., " ")
  }
  width <- max(getOption("width") - nchar(title) - 1, 0)
  message(title, paste(rep(pad, width, collapse = "")))
}

out_path <- function(path, ...) {
  if (is.null(path)) {
    ""
  } else {
    file.path(path, ...)
  }

}

is_dir <- function(x) file.info(x)$isdir

split_at_linebreaks <- function(text) {
  if (length(text) < 1)
    return(character())
  trimws(strsplit(text, "\\n\\s*\\n")[[1]])
}

up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}
#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}

copy_dir <- function(from, to, exclude_matching = NULL) {

  from_dirs <- list.dirs(from, full.names = FALSE, recursive = TRUE)
  from_dirs <- from_dirs[from_dirs != '']

  if (!is.null(exclude_matching)) {
    exclude <- grepl(exclude_matching, from_dirs)
    from_dirs <- from_dirs[!exclude]
  }

  to_dirs <- file.path(to, from_dirs)
  purrr::walk(to_dirs, mkdir)

  from_files <- list.files(from, recursive = TRUE, full.names = TRUE)
  from_files_rel <- list.files(from, recursive = TRUE)

  if (!is.null(exclude_matching)) {
    exclude <- grepl(exclude_matching, from_files_rel)

    from_files <- from_files[!exclude]
    from_files_rel <- from_files_rel[!exclude]
  }

  to_paths <- file.path(to, from_files_rel)
  file.copy(from_files, to_paths, overwrite = TRUE)
}


find_first_existing <- function(path, ...) {
  paths <- file.path(path, c(...))
  for (path in paths) {
    if (file.exists(path))
      return(path)
  }

  NULL
}

#' Compute relative path
#'
#' @param path Relative path
#' @param base Base path
#' @param windows Whether the operating system is Windows. Default value is to
#'   check the user's system information.
#' @export
#' @examples
#' rel_path("a/b", base = "here")
#' rel_path("/a/b", base = "here")
rel_path <- function(path, base = ".", windows = on_windows()) {
  if (is_absolute_path(path)) {
    path
  } else {
    if (base != ".") {
      path <- file.path(base, path)
    }
    # normalizePath() on Windows expands to absolute paths,
    # so strip normalized base from normalized path
    if (windows) {
      parent_full <- normalizePath(".", mustWork = FALSE, winslash = "/")
      path_full <- normalizePath(path, mustWork = FALSE, winslash = "/")
      gsub(paste0(parent_full, "/"), "", path_full, fixed = TRUE)
    } else {
      normalizePath(path, mustWork = FALSE)
    }
  }
}

on_windows <- function() {
  Sys.info()["sysname"] == "Windows"
}

is_absolute_path <- function(path) {
  grepl("^(/|[A-Za-z]:|\\\\|~)", path)
}

package_path <- function(package, path) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(package, " is not installed", call. = FALSE)
  }

  pkg_path <- system.file("pkgdown", path, package = package)
  if (pkg_path == "") {
    stop(package, " does not contain 'inst/pkgdown/", path, "'", call. = FALSE)
  }

  pkg_path

}

out_of_date <- function(source, target) {
  if (!file.exists(target))
    return(TRUE)

  if (!file.exists(source)) {
    stop("'", source, "' does not exist", call. = FALSE)
  }

  file.info(source)$mtime > file.info(target)$mtime
}

#' Determine if code is executed by pkgdown
#'
#' This is occassionally useful when you need different behaviour by
#' pkgdown and regular documentation.
#'
#' @export
#' @examples
#' in_pkgdown()
in_pkgdown <- function() {
  identical(Sys.getenv("IN_PKGDOWN"), "true")
}

set_pkgdown_env <- function(x) {
  old <- Sys.getenv("IN_PKGDOWN")
  Sys.setenv("IN_PKGDOWN" = x)
  invisible(old)
}

read_file <- function(path) {
  lines <- readLines(path, warn = FALSE)
  paste0(lines, "\n", collapse = "")
}

write_yaml <- function(x, path) {
  cat(yaml::as.yaml(x), "\n", sep = "", file = path)
}

invert_index <- function(x) {
  stopifnot(is.list(x))

  if (length(x) == 0)
    return(list())

  key <- rep(names(x), purrr::map_int(x, length))
  val <- unlist(x, use.names = FALSE)

  split(key, val)
}

a <- function(text, href) {
  ifelse(is.na(href), text, paste0("<a href='", href, "'>", text, "</a>"))
}

# Used for testing
#' @keywords internal
#' @importFrom MASS addterm
#' @export
MASS::addterm

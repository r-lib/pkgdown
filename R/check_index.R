
#' Check Articles and Reference Index
#'
#' @param pkg Path to package.
#' @param check_articles Whether to check articles index
#' @param check_reference Whether to check reference index.
#'
#' @return If no errors are found returns `TRUE` otherwise a warning.
#' @export
check_index_missing <- function(pkg = ".", check_articles = TRUE, check_reference = TRUE) {
  check_expr <- tryCatch(
    {
      if (isTRUE(check_articles)) check_articles_index(pkg)
      if (isTRUE(check_reference)) check_reference_index(pkg)
    },
    error = function(e) e,
    warning = function(w) w
  )
  if (inherits(check_expr, c("error","warning"))) {
    text <- "Checking pkgdown index found errors"
    if (on_ci()) {
      abort(text, parent = check_expr)
    } else {
      warn(text, parent = check_expr)
    }
  } else TRUE
}

check_articles_index <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  dir_create(path(pkg$dst_path, "articles"))
  data_articles_index(pkg)
  invisible()
}

check_reference_index <- function(pkg = ".") {
  pkg <- section_init(pkg, depth = 1L)
  dir_create(path(pkg$dst_path, "reference"))

  # Copy icons, if needed
  src_icons <- path(pkg$src_path, "icons")
  dst_icons <- path(pkg$dst_path, "reference", "icons")
  if (file_exists(src_icons)) {
    dir_copy_to(pkg, src_icons, dst_icons)
  }
  data_reference_index(pkg)
  invisible()
}

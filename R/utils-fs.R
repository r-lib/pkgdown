
inst_path <- function() {
  if (is.null(pkgload::dev_meta("pkgdown"))) {
    # pkgdown is probably installed
    system.file(package = "pkgdown")
  } else {
    # pkgdown was probably loaded with devtools
    file.path(getNamespaceInfo("pkgdown", "path"), "inst")
  }
}


mkdir <- function(..., quiet = FALSE) {
  path <- file.path(...)

  if (!file.exists(path)) {
    if (!quiet)
      cat_line("Creating '", path, "/'")
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
}

is_dir <- function(x) file.info(x)$isdir


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

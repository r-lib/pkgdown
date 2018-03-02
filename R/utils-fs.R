copy_dir <- function(from, to, exclude_matching = NULL) {

  from_dirs <- list.dirs(from, full.names = FALSE, recursive = TRUE)
  from_dirs <- from_dirs[from_dirs != '']

  if (!is.null(exclude_matching)) {
    exclude <- grepl(exclude_matching, from_dirs)
    from_dirs <- from_dirs[!exclude]
  }

  to_dirs <- file.path(to, from_dirs)
  dir_create(to_dirs)

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

out_of_date <- function(source, target) {
  if (!file_exists(target))
    return(TRUE)

  if (!file_exists(source)) {
    stop("'", source, "' does not exist", call. = FALSE)
  }

  file.info(source)$mtime > file.info(target)$mtime
}

# Path helpers ------------------------------------------------------------

path_rel <- function(base, path) {
  if (is_absolute_path(path)) {
    path
  } else {
    path_norm(path(base, path))
  }
}

path_package_pkgdown <- function(package, ...) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(package, " is not installed", call. = FALSE)
  }

  pkg_path <- system.file("pkgdown", ..., package = package, mustWork = TRUE)
  if (pkg_path == "") {
    stop(package, " does not contain 'inst/pkgdown/", path, "'", call. = FALSE)
  }

  pkg_path
}

path_pkgdown <- function(...) {
  if (is.null(pkgload::dev_meta("pkgdown"))) {
    # pkgdown is probably installed
    system.file(..., package = "pkgdown")
  } else {
    # pkgdown was probably loaded with devtools
    path(getNamespaceInfo("pkgdown", "path"), "inst", ...)
  }
}

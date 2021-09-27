dir_copy_to <- function(pkg, from, to, overwrite = TRUE) {
  stopifnot(length(to) == 1)
  new_path <- function(path) {
    path_abs(path_rel(path, start = from), start = to)
  }

  contents <- dir_ls(from, recurse = TRUE)
  is_dir <- fs::is_dir(contents)

  # First create directories
  dir_create(to)
  dirs <- contents[is_dir]
  dir_create(new_path(dirs))

  # Then copy files
  file_copy_to(pkg, contents[!is_dir],
    to_dir = to,
    from_dir = from,
    overwrite = overwrite
  )
}

# Would be better to base on top of data structure that provides both
# files and root directory to use for printing
file_copy_to <- function(pkg,
                         from_paths,
                         to_dir = pkg$dst_path,
                         from_dir = path_common(from_paths),
                         overwrite = TRUE) {

  if (length(from_paths) == 0) {
    return()
  }

  from_rel <- path_rel(from_paths, from_dir)
  to_paths <- path_abs(from_rel, to_dir)

  # Ensure all the "to" directories exist
  dirs_to_paths <- unique(fs::path_dir(to_paths))
  dir_create(dirs_to_paths)

  eq <- purrr::map2_lgl(from_paths, to_paths, file_equal)
  if (any(!eq)) {
    cat_line(
      "Copying ", src_path(path_rel(from_paths[!eq], pkg$src_path)),
      " to ", dst_path(path_rel(to_paths[!eq], pkg$dst_path))
    )
  }

  file_copy(from_paths[!eq], to_paths[!eq], overwrite = overwrite)
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

path_abs <- function(path, start = ".") {
  is_abs <- is_absolute_path(path)

  path[is_abs] <- path_norm(path[is_abs])
  path[!is_abs] <- fs::path_abs(path(start, path))

  path_tidy(path)
}

path_first_existing <- function(...) {
  paths <- path(...)
  for (path in paths) {
    if (file_exists(path))
      return(path)
  }

  NULL
}

path_package_pkgdown <- function(package, bs_version = NULL, ...) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop(package, " is not installed", call. = FALSE)
  }

  path <- if (is.null(bs_version)) {
    file.path(...)
  } else {
    file.path(..., paste0("BS", bs_version))
  }

  if (is.null(devtools_meta(package))) {
    pkg_path <- system.file("pkgdown", path, package = package, mustWork = FALSE)
  } else {
    # Needed for testing packages that provide templates
    pkg_path <- path(getNamespaceInfo(package, "path"), "inst", "pkgdown", path)
  }

  if (!file.exists(pkg_path)) {
    # fall back on the bare templates directory
    if (!is.null(bs_version)) {
      return(path_package_pkgdown(package, bs_version = NULL, ...))
    }

    return(character())
  }

  pkg_path
}

path_pkgdown <- function(...) {
  if (is.null(devtools_meta("pkgdown"))) {
    # pkgdown is probably installed
    system.file(..., package = "pkgdown")
  } else {
    # pkgdown was probably loaded with devtools
    path(getNamespaceInfo("pkgdown", "path"), "inst", ...)
  }
}
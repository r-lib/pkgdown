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
    cli::cli_inform(c(
        "Copying {src_path(path_rel(from_paths[!eq], pkg$src_path))}",
        " to {dst_path(path_rel(to_paths[!eq], pkg$dst_path))}"
    ))
  }

  file_copy(from_paths[!eq], to_paths[!eq], overwrite = overwrite)
}

out_of_date <- function(source, target) {
  if (!file_exists(target))
    return(TRUE)

  if (!file_exists(source)) {
    cli::cli_abort(
      "{.fn {source}} does not exist",
      call = caller_env()
    )
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

path_package_pkgdown <- function(..., package, bs_version = NULL) {
  check_installed(package)
  base <- system_file("pkgdown", package = package)

  # If bs_version supplied, first try for versioned template
  if (!is.null(bs_version)) {
    path <- path(base, paste0("BS", bs_version), ...)
    if (file_exists(path)) {
      return(path)
    }
  }

  path(base, ...)
}

path_pkgdown <- function(...) {
  system_file(..., package = "pkgdown")
}

pkgdown_config_relpath <- function(pkg) {
  pkg <- as_pkgdown(pkg)
  config_path <- pkgdown_config_path(pkg$src_path)

  fs::path_rel(config_path, pkg$src_path)
}

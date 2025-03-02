dir_copy_to <- function(
  src_dir,
  dst_dir,
  src_root,
  dst_root,
  src_label = "",
  dst_label = ""
) {
  check_string(src_dir)
  check_string(dst_dir)

  if (!dir_exists(src_dir)) {
    return()
  }

  src_paths <- dir_ls(src_dir, recurse = TRUE)
  is_dir <- is_dir(src_paths)

  dst_paths <- path(dst_dir, path_rel(src_paths, src_dir))

  # First create directories
  dir_create(dst_paths[is_dir])
  # Then copy files
  file_copy_to(
    src_paths = src_paths[!is_dir],
    dst_paths = dst_paths[!is_dir],
    src_root = src_root,
    dst_root = dst_root,
    src_label = src_label,
    dst_label = dst_label
  )
}

file_copy_to <- function(
  src_paths,
  dst_paths,
  src_root,
  dst_root,
  src_label = NULL,
  dst_label = ""
) {
  # Ensure all the "to" directories exist
  dst_dirs <- unique(path_dir(dst_paths))
  dir_create(dst_dirs)

  eq <- purrr::map2_lgl(src_paths, dst_paths, file_equal)
  if (any(!eq)) {
    dst <- paste0(dst_label, path_rel(dst_paths[!eq], dst_root))
    if (is.null(src_label)) {
      purrr::walk(dst, function(dst) {
        cli::cli_inform("Copying {dst_path(dst)}")
      })
    } else {
      src <- paste0(src_label, path_rel(src_paths[!eq], src_root))
      purrr::walk2(src, dst, function(src, dst) {
        cli::cli_inform("Copying {src_path(src)} to {dst_path(dst)}")
      })
    }
  }

  file_copy(src_paths[!eq], dst_paths[!eq], overwrite = TRUE)
}

out_of_date <- function(source, target, call = caller_env()) {
  if (!file_exists(target)) {
    return(TRUE)
  }
  if (!file_exists(source)) {
    cli::cli_abort("{.path {source}} does not exist", call = call)
  }

  file_info(source)$modification_time > file_info(target)$modification_time
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
    if (file_exists(path)) return(path)
  }

  NULL
}

path_package_pkgdown <- function(
  path,
  package,
  bs_version,
  error_call = caller_env()
) {
  # package will usually be a github package, and check_installed()
  # tries to install from CRAN, which is highly likely to fail.
  if (!is_installed(package)) {
    cli::cli_abort(
      c(
        "Template package {.val {package}} is not installed.",
        i = "Please install before continuing."
      ),
      call = error_call
    )
  }
  base <- system_file("pkgdown", package = package)

  # If bs_version supplied, first try for versioned template
  if (!is.null(bs_version)) {
    ver_path <- path(base, paste0("BS", bs_version), path)
    if (file_exists(ver_path)) {
      return(ver_path)
    }
  }

  path(base, path)
}

path_pkgdown <- function(...) {
  system_file(..., package = "pkgdown")
}

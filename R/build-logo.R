copy_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (!is.null(logo_path)) {
    file_copy_to(
      src_paths = logo_path,
      src_root = pkg$src_path,
      dst_paths = path(pkg$dst_path, path_file(logo_path)),
      dst_root = pkg$dst_path
    )
  }
}

find_logo <- function(path) {
  path_first_existing(
    c(
      path(path, "logo.svg"),
      path(path, "man", "figures", "logo.svg"),
      path(path, "logo.png"),
      path(path, "man", "figures", "logo.png")
    )
  )
}

has_logo <- function(pkg) {
  logo_path <- find_logo(pkg$src_path)
  !is.null(logo_path)
}

logo_path <- function(pkg, depth) {
  path <- find_logo(pkg$src_path)
  if (is.null(path)) {
    return()
  }

  paste0(up_path(depth), path_file(path))
}

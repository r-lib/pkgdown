copy_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (!is.null(logo_path)) {
    file_copy_to(pkg, logo_path, from_dir = path_dir(logo_path))
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

  paste0(up_path(depth), fs::path_file(path))
}

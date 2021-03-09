build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (!is.null(logo_path)) {
    file_copy_to(pkg, logo_path, from_dir = path_dir(logo_path))
  }
}

build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (!is.null(logo_path)) {
    file_copy_to(pkg, logo_path, from_dir = path_dir(logo_path))
  }
}

find_logo <- function(path) {
  logo_path <- path(path, "logo.svg")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "man", "figures", "logo.svg")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "man", "figures", "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  NULL
}

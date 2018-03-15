build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (is.null(logo_path))
    return()

  file_copy_to(pkg, logo_path, from_dir = path_dir(logo_path))
  if (!requireNamespace("magick", quietly = TRUE)) {
    message("Magick not avaliable, not creating favicon.ico")
    return()
  }

  cat_line("Creating ", dst_path("favicon.ico"))
  magick::image_read(logo_path) %>%
	  magick::image_scale("32x32") %>%
	  magick::image_write(path(pkg$dst_path, "favicon.ico"), format = "png")
}


find_logo <- function(path) {
  logo_path <- path(path, "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  logo_path <- path(path, "man", "figures", "logo.png")
  if (file_exists(logo_path))
    return(logo_path)

  NULL
}

build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (is.null(logo_path))
    return()

  cat_line("Copying 'logo.png'")
  file_copy(logo_path, path(pkg$dst_path, "logo.png"), overwrite = TRUE)

  if (!requireNamespace("magick", quietly = TRUE)) {
    message("Magick not avaliable, not creating favicon.ico")
    return()
  }

  cat_line("Creating favicon")
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

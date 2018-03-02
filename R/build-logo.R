build_logo <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  logo_path <- find_logo(pkg$src_path)
  if (is.null(logo_path))
    return()

  cat_line("Copying 'logo.png'")
  file.copy(logo_path, file.path(pkg$dst_path, "logo.png"))

  if (!requireNamespace("magick", quietly = TRUE)) {
    message("Magick not avaliable, not creating favicon.ico")
    return()
  }

  cat_line("Creating favicon")
  magick::image_read(logo_path) %>%
	  magick::image_scale("32x32") %>%
	  magick::image_write(file.path(pkg$dest_path, "favicon.ico"), format = "png")
}


find_logo <- function(path) {
  logo_path <- file.path(path, "logo.png")
  if (file.exists(logo_path))
    return(logo_path)

  logo_path <- file.path(path, "man", "figures", "logo.png")
  if (file.exists(logo_path))
    return(logo_path)

  NULL
}

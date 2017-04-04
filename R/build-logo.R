build_logo <- function(pkg = ".", path = "docs/") {
  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  logo_path <- find_logo(pkg$path)
  if (is.null(logo_path))
    return()

  message("Copying logo")
  file.copy(logo_path, file.path(path, "logo.png"))

  message("Creating favicon")
  magick::image_read(logo_path) %>%
	  magick::image_scale("32x32") %>%
	  magick::image_write(file.path(path, "favicon.ico"), format = "png")
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

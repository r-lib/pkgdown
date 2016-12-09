build_logo <- function(pkg = ".", path = "docs/") {
  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  logo_path <- file.path(pkg$path, "logo.png")
  if (!file.exists(logo_path))
    return()

  message("Copying logo")
  file.copy(logo_path, file.path(path, "logo.png"))

  message("Creating favicon")
  magick::image_read(logo_path) %>%
	  magick::image_scale("32x32") %>%
	  magick::image_write(file.path(path, "favicon.ico"), format = "png")
}


has_logo <- function(path) {
  file.exists(file.path(path, "logo.png"))
}

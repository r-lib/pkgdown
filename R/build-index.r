build_index <- function(pkg) {
  out <- file.path(pkg$site_path, "index.html")
  message("Generating index.html")

  pkg$readme <- readme(pkg)
  pkg$pagetitle <- "Home"

  render_page(pkg, "readme", pkg, out)
}

readme <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  # First look in staticdocs path
  path <- file.path(pkg$sd_path, "README.md")
  if (file.exists(path)) {
    return(markdown(path = path))
  }

  # Then look in the package root
  path <- file.path(pkg$path, "README.md")
  if (file.exists(path)) {
    return(markdown(path = path))
  }

  # Otherwise fallback to description
  pkg$description
}

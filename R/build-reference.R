# Generate all topic pages for a package.
reference_build <- function(pkg = ".", site_path = NULL) {
  pkg <- as.sd_package(pkg)
  if (!is.null(site_path)) {
    mkdir(pkg$site_path, "reference")
  }

  pkg$topics %>%
    purrr::transpose() %>%
    purrr::map(reference_build_topic, pkg = pkg, site_path = site_path)

  reference_index_build(pkg, site_path = site_path)

  invisible()
}

reference_build_topic <- function(topic, pkg, site_path = NULL) {
  message("Generating reference topic '", topic$name, "'")

  html <- to_html.Rd_doc(
    topic$rd,
    env = new.env(parent = globalenv()),
    topic = topic$name,
    pkg = pkg
  )
  html$package <- pkg[c("package", "version")]

  if (is.null(site_path)) {
    out <- ""
  } else {
    out <- file.path(site_path, "reference", topic$file_out)
  }
  render_page(pkg, "topic", html, out)
}

build_home_index <- function(pkg = ".", quiet = TRUE) {
  pkg <- as_pkgdown(pkg)

  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)
  scoped_file_context(depth = 0L)

  src_path <- path_first_existing(
    pkg$src_path,
    c("index.Rmd", "README.Rmd", "index.md", "README.md")
  )
  dst_path <- path(pkg$dst_path, "index.html")
  data <- data_home(pkg)

  if (is.null(src_path)) {
    data$index <- linkify(pkg$desc$get("Description")[[1]])
    render_page(pkg, "home", data, "index.html")
  } else {
    file_ext <- path_ext(src_path)

    if (file_ext == "md") {
      data$index <- markdown(src_path)
      render_page(pkg, "home", data, "index.html")
    } else if (file_ext == "Rmd") {
      render_index(pkg, path_rel(src_path, pkg$src_path), data = data, quiet = quiet)
    }
  }

  strip_header <- isTRUE(pkg$meta$home$strip_header)
  update_html(dst_path, tweak_homepage_html, strip_header = strip_header)

  invisible()
}

# Stripped down version of build_article
render_index <- function(pkg = ".", path, data = list(), quiet = TRUE) {
  pkg <- as_pkgdown(pkg)

  format <- build_rmarkdown_format(pkg, depth = 0L, data = data, toc = FALSE)
  render_rmarkdown(
    pkg = pkg,
    input = path,
    output = "index.html",
    output_format = format,
    quiet = quiet,
    copy_images = FALSE
  )
}

data_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  print_yaml(list(
    pagetitle = pkg$desc$get("Title")[[1]],
    sidebar = data_home_sidebar(pkg),
    opengraph = list(description = pkg$desc$get("Description")[[1]])
  ))
}

data_home_sidebar <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  if (!is.null(pkg$meta$home$sidebar))
    return(pkg$meta$home$sidebar)

  paste0(
    data_home_sidebar_links(pkg),
    data_home_sidebar_license(pkg),
    data_home_sidebar_citation(pkg),
    data_home_sidebar_authors(pkg),
    collapse = "\n"
  )
}

data_home_sidebar_links <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  repo <- repo_link(pkg$package)
  meta <- purrr::pluck(pkg, "meta", "home", "links")

  links <- c(
    link_url(paste0("Download from ", repo$repo), repo$url),
    link_url("Browse source code", pkg$github_url),
    link_url("Report a bug", pkg$desc$get("BugReports")[[1]]),
    purrr::map_chr(meta, ~ link_url(.$text, .$href))
  )

  sidebar_section("Links", links)
}

sidebar_section <- function(heading, bullets, class = make_slug(heading)) {
  if (length(bullets) == 0)
    return(character())

  paste0(
    "<div class='", class, "'>\n",
    "<h2>", heading, "</h2>\n",
    "<ul class='list-unstyled'>\n",
    paste0("<li>", bullets, "</li>\n", collapse = ""),
    "</ul>\n",
    "</div>\n"
  )
}

repo_link <- memoise(function(pkg) {
  cran_url <- paste0("https://cloud.r-project.org/package=", pkg)
  if (!httr::http_error(cran_url)) {
    return(list(repo = "CRAN", url = cran_url))
  }

  # bioconductor always returns a 200 status, redirecting to /removed-packages/
  bioc_url <- paste0("https://www.bioconductor.org/packages/", pkg)
  req <- httr::HEAD(bioc_url)
  if (!httr::http_error(req) && !grepl("removed-packages", req$url)) {
    return(list(repo = "BIOC", url = bioc_url))
  }

  NULL
})

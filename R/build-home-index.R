build_home_index <- function(pkg) {
  scoped_package_context(pkg$package, pkg$topic_index, pkg$article_index)
  scoped_file_context(depth = 0)

  data <- data_home(pkg)
  data$opengraph <- list(description = pkg$desc$get("Description")[[1]])

  if (is.null(data$path)) {
    data$index <- linkify(pkg$desc$get("Description")[[1]])
    render_page(pkg, "home", data, "index.html")
  } else {
    file_name <- as.character(path_ext_remove(path_file(data$path)))
    file_ext <- path_ext(data$path)

    if (file_ext == "md") {
      data$index <- markdown(path = data$path)
      render_page(pkg, "home", data, "index.html")
    } else if (file_ext == "Rmd") {
      build_article(file_name, pkg = pkg, data = data)
    }
  }

  update_homepage_html(
    path(pkg$dst_path, "index.html"),
    isTRUE(pkg$meta$home$strip_header)
  )
}

update_homepage_html <- function(path, strip_header = FALSE) {
  html <- xml2::read_html(path, encoding = "UTF-8")
  tweak_homepage_html(html, strip_header = strip_header)

  xml2::write_html(html, path, format = FALSE)
  path
}

data_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  path <- path_first_existing(
    pkg$src_path,
    c("index.Rmd", "README.Rmd", "index.md", "README.md")
  )

  print_yaml(list(
    pagetitle = pkg$desc$get("Title")[[1]],
    sidebar = data_home_sidebar(pkg),
    path = path
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

  list_with_heading(links, "Links")
}

linkify <- function(text) {
  text <- escape_html(text)
  text <- gsub("&lt;doi:([^&]+)&gt;",  # DOIs with < > & are not supported
               "&lt;<a href='https://doi.org/\\1'>doi:\\1</a>&gt;",
               text, ignore.case = TRUE)
  text <- gsub("&lt;arXiv:([^&]+)&gt;",
               "&lt;<a href='https://arxiv.org/abs/\\1'>arXiv:\\1</a>&gt;",
               text, ignore.case = TRUE)
  text <- gsub("&lt;((http|ftp)[^&]+)&gt;",  # URIs with & are not supported
               "&lt;<a href='\\1'>\\1</a>&gt;",
               text)
  text
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

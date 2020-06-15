build_home_index <- function(pkg = ".", quiet = TRUE) {
  pkg <- as_pkgdown(pkg)

  src_path <- path_first_existing(
    pkg$src_path,
    c("pkgdown/index.md",
      "index.md",
      "README.md"
    )
  )
  dst_path <- path(pkg$dst_path, "index.html")
  data <- data_home(pkg)

  if (is.null(src_path)) {
    data$index <- linkify(pkg$desc$get("Description")[[1]])
  } else {
    local_options_link(pkg, depth = 0L)
    data$index <- markdown(src_path)
  }
  render_page(pkg, "home", data, "index.html", quiet = quiet)

  strip_header <- isTRUE(pkg$meta$home$strip_header)
  update_html(dst_path, tweak_homepage_html, strip_header = strip_header)

  invisible()
}

data_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  print_yaml(list(
    pagetitle = pkg$meta$home[["title"]] %||%
      cran_unquote(pkg$desc$get("Title")[[1]]),
    sidebar = data_home_sidebar(pkg),
    opengraph = list(description = pkg$meta$home[["description"]] %||%
                       cran_unquote(pkg$desc$get("Description")[[1]]))
  ))
}

data_home_sidebar <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  if (!is.null(pkg$meta$home$sidebar))
    return(pkg$meta$home$sidebar)

  paste0(
    data_home_sidebar_links(pkg),
    data_home_sidebar_license(pkg),
    data_home_sidebar_community(pkg),
    data_home_sidebar_citation(pkg),
    data_home_sidebar_authors(pkg),
    collapse = "\n"
  )
}

data_home_sidebar_links <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  repo <- cran_link(pkg$package)
  meta <- purrr::pluck(pkg, "meta", "home", "links")

  links <- c(
    link_url(paste0("Download from ", repo$repo), repo$url),
    link_url("Browse source code", repo_home(pkg)),
    if (pkg$desc$has_fields("BugReports"))
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

#' @importFrom memoise memoise
NULL

cran_link <- memoise(function(pkg) {
  if (!has_internet()) {
    return(NULL)
  }

  cran_url <- paste0("https://cloud.r-project.org/package=", pkg)

  if (!httr::http_error(cran_url)) {
    return(list(repo = "CRAN", url = cran_url))
  }

  # bioconductor always returns a 200 status, redirecting to /removed-packages/
  bioc_url <- paste0("https://www.bioconductor.org/packages/", pkg)
  req <- httr::RETRY("HEAD", bioc_url, quiet = TRUE)
  if (!httr::http_error(req) && !grepl("removed-packages", req$url)) {
    return(list(repo = "BIOC", url = bioc_url))
  }

  NULL
})

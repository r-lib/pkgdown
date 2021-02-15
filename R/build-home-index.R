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

  update_html(
    dst_path,
    tweak_homepage_html,
    strip_header = strip_header,
    sidebar = !isFALSE(pkg$meta$home$sidebar)
  )

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
  if (isFALSE(pkg$meta$home$sidebar))
    return(pkg$meta$home$sidebar)

  html_path <- file.path(pkg$src_path, pkg$meta$home$sidebar$html)

  if (length(html_path)) {
    if (!file.exists(html_path)) {
      abort(
        sprintf(
          "Can't find file '%s' specified by %s.",
          pkg$meta$home$sidebar$html,
          pkgdown_field(pkg = pkg, "home", "sidebar", "html")
        )
      )
    }
    return(paste0(read_lines(html_path), collapse = "\n"))
  }

  sidebar_structure <- pkg$meta$home$sidebar$structure %||%
    default_sidebar_structure()

  # compute all default sections
  sidebar_components <- list(
    links = data_home_sidebar_links(pkg),
    license = data_home_sidebar_license(pkg),
    community = data_home_sidebar_community(pkg),
    citation = data_home_sidebar_citation(pkg),
    authors = data_home_sidebar_authors(pkg),
    dev = sidebar_section("Dev Status", "placeholder"),
    readme = data_home_readme(pkg)
  )

  if (is.null(pkg$meta$home$sidebar$structure)) {
    sidebar_html <- paste0(
      purrr::compact(sidebar_components[default_sidebar_structure()]),
      collapse = "\n"
    )
    return(sidebar_html)
  }

  # compute any custom component
  components <- pkg$meta$home$sidebar$components

  sidebar_components <- utils::modifyList(
    sidebar_components,
    purrr::map2(
      components,
      names(components),
      data_home_component,
      pkg = pkg
      ) %>%
      set_names(names(components))
  )

  missing <- setdiff(sidebar_structure, names(sidebar_components))

  if (length(missing) > 0) {
    missing_components <- lapply(
      missing, append,
      c("home", "sidebar", "components"),
      after = 0
    )
    missing_fields <- pkgdown_fields(pkg = pkg, fields = missing_components)

    abort(
      sprintf(
        "Can't find component%s %s.",
        if (length(missing) > 1) "s" else "",
        paste0(
          missing_fields, collapse = " nor "
        )
      )
    )
  }

  sidebar_final_components <- purrr::compact(
    sidebar_components[sidebar_structure]
    )

  paste0(sidebar_final_components, collapse = "\n")

}

default_sidebar_structure <- function() {
  c("links", "license", "community", "citation", "authors", "dev")
}

data_home_component <- function(component, component_name, pkg) {

  if (!all(c("title", "html") %in% names(component))) {
    abort(
      sprintf(
        "Can't find %s for the component %s",
        paste0(
          c("title", "html")[!c("title", "html") %in% names(component)],
          collapse = " nor "
          ),
        pkgdown_field(pkg = pkg, "home", "sidebar", "components", component_name)
        )
      )
  }

  sidebar_section(component$title, bullets = component$html)
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

data_home_readme <- function(pkg) {
  sidebar_section(
    "In this README",
    '<nav id="toc" data-toggle="toc" class="sticky-top"></nav>'
    )
}

sidebar_section <- function(heading, bullets, class = make_slug(heading)) {
  if (length(bullets) == 0)
    return(character())

  paste0(
    "<div class='", class, "'>\n",
    "<h2 data-toc-skip>", heading, "</h2>\n",
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

#' @export
#' @rdname build_home
build_home_index <- function(pkg = ".", quiet = TRUE) {
  pkg <- section_init(pkg, depth = 0L)

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
    data$index <- markdown_body(src_path, pkg = pkg)
  }
  render_page(pkg, "home", data, "index.html", quiet = quiet)

  strip_header <- isTRUE(pkg$meta$home$strip_header)

  update_html(
    dst_path,
    tweak_homepage_html,
    strip_header = strip_header,
    sidebar = !isFALSE(pkg$meta$home$sidebar),
    bs_version = pkg$bs_version,
    logo = logo_path(pkg, depth = 0)
  )

  check_missing_images(pkg, path_rel(src_path, pkg$src_path), "index.html")

  invisible()
}

data_home <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  print_yaml(list(
    pagetitle = pkg$meta$home[["title"]] %||%
      cran_unquote(pkg$desc$get("Title")[[1]]),
    sidebar = data_home_sidebar(pkg),
    opengraph = list(description = pkg$meta$home[["description"]] %||%
                       cran_unquote(pkg$desc$get("Description")[[1]])),
    has_trailingslash = pkg$meta$template$trailing_slash_redirect %||% FALSE
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
    return(read_file(html_path))
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
    dev = sidebar_section(tr_("Dev Status"), "placeholder", class = "dev-status"),
    toc = data_home_toc(pkg)
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

  check_components(
    needed = sidebar_structure,
    present = names(sidebar_components),
    where = c("home", "sidebar", "components"),
    pkg = pkg
  )

  sidebar_final_components <- purrr::compact(
    sidebar_components[sidebar_structure]
    )

  paste0(sidebar_final_components, collapse = "\n")

}

# Update sidebar-configuration.Rmd if this changes
default_sidebar_structure <- function() {
  c("links", "license", "community", "citation", "authors", "dev")
}

data_home_component <- function(component, component_name, pkg) {

  check_components(
    needed = c("title", "text"),
    present = names(component),
    where = c("home", "sidebar", "components", component_name),
    pkg = pkg
  )

  sidebar_section(
    component$title,
    bullets = markdown_text_block(component$text, pkg = pkg)
  )
}

data_home_sidebar_links <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  repo <- cran_link(pkg$package)
  links <- purrr::pluck(pkg, "meta", "home", "links")

  links <- c(
    link_url(sprintf(tr_("View on %s"), repo$repo), repo$url),
    link_url(tr_("Browse source code"), repo_home(pkg)),
    link_url(tr_("Report a bug"), pkg$desc$get_field("BugReports", default = NULL)),
    purrr::map_chr(links, ~ link_url(.$text, .$href))
  )

  sidebar_section(tr_("Links"), links)
}

data_home_toc <- function(pkg) {
  sidebar_section(
    tr_("Table of contents"),
    '<nav id="toc"></nav>'
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
    return(list(repo = "Bioconductor", url = bioc_url))
  }

  NULL
})


check_missing_images <- function(pkg, src_path, dst_path) {
  html <- xml2::read_html(path(pkg$dst_path, dst_path), encoding = "UTF-8")
  src <- xml2::xml_attr(xml2::xml_find_all(html, ".//img"), "src")

  rel_src <- src[xml2::url_parse(src)$scheme == ""]
  rel_path <- fs::path_norm(path(fs::path_dir(dst_path), rel_src))
  exists <- fs::file_exists(path(pkg$dst_path, rel_path))

  if (any(!exists)) {
    paths <- encodeString(rel_src[!exists], quote = "'")
    warn(c(
      paste0("Missing images in '", src_path, "': ", paste0(paths, collapse = ", ")),
      i = "pkgdown can only use images in 'man/figures' and 'vignettes'"
    ))
  }
}

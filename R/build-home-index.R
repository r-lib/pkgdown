#' @export
#' @rdname build_home
build_home_index <- function(pkg = ".", quiet = TRUE) {
  pkg <- section_init(pkg, depth = 0L)

  src_path <- path_index(pkg)
  dst_path <- path(pkg$dst_path, "index.html")
  data <- data_home(pkg)

  if (is.null(src_path)) {
    data$index <- linkify(pkg$desc$get_field("Description", ""))
  } else {
    local_options_link(pkg, depth = 0L)
    data$index <- markdown_body(src_path)
  }
  render_page(pkg, "home", data, "index.html", quiet = quiet)

  strip_header <- config_pluck_bool(pkg, "home.strip_header", default = FALSE)
  hide_badges <- pkg$development$mode == "release" && !pkg$development$in_dev

  update_html(
    dst_path,
    tweak_homepage_html,
    strip_header = strip_header,
    sidebar = !isFALSE(pkg$meta$home$sidebar),
    show_badges = !hide_badges,
    bs_version = pkg$bs_version,
    logo = logo_path(pkg, depth = 0)
  )

  invisible()
}

path_index <- function(pkg) {
  path_first_existing(
    pkg$src_path,
    c("pkgdown/index.md",
      "index.md",
      "README.md"
    )
  )
}

data_home <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  config_pluck_list(pkg, "home", call = call)

  title <- config_pluck_string(
    pkg,
    "home.title",
    default = cran_unquote(pkg$desc$get_field("Title", "")),
    call = call
  )
  description <- config_pluck_string(
    pkg,
    "home.description",
    default = cran_unquote(pkg$desc$get_field("Description", "")),
    call = call
  )
  trailing_slash <- config_pluck_bool(
    pkg,
    "template.trailing_slash_redirect",
    default = FALSE,
    call = call
  )

  print_yaml(list(
    pagetitle = title,
    sidebar = data_home_sidebar(pkg, call = call),
    opengraph = list(description = description),
    has_trailingslash = trailing_slash
  ))
}


data_home_sidebar <- function(pkg = ".", call = caller_env()) {
  pkg <- as_pkgdown(pkg)

  sidebar <- config_pluck(pkg, "home.sidebar")
  if (isFALSE(sidebar)) {
    return(FALSE)
  }

  html_path <- config_pluck_string(pkg, "home.sidebar.html")
  if (!is.null(html_path)) {
    html_path_abs <- path(pkg$src_path, html_path)

    if (!file_exists(html_path_abs)) {
      config_abort(
        pkg,
        "{.field home.sidebar.html} specifies a file that doesn't exist ({.file {html_path}}).",
        call = call
      )
    }
    return(read_file(html_path_abs))
  }

  sidebar_structure <- config_pluck_character(
    pkg, 
    "home.sidebar.structure",
    default = default_sidebar_structure()
  ) 

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

  custom <- config_pluck_sidebar_components(pkg, call = call)
  sidebar_custom <- purrr::map(custom, function(x) {
    sidebar_section(x$title, bullets = markdown_text_block(x$text))
  })
  sidebar_components <- utils::modifyList(sidebar_components, sidebar_custom)

  config_check_list(
    sidebar_components,
    has_names = sidebar_structure,
    error_pkg = pkg,
    error_path = "home.sidebar.components",
    error_call = call
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

config_pluck_sidebar_components <- function(pkg, call = caller_env()) {
  base_path <- "home.sidebar.components"
  components <- config_pluck(pkg, base_path, default = list())

  if (!is_dictionaryish(components)) {
    msg <- "The components of {.field home.sidebar.components} must be named uniquely."
    config_abort(pkg, msg, call = call)
  }

  for (name in names(components)) {
    component <- components[[name]]
    component_path <- paste0(base_path, ".", name)
    
    config_pluck_list(pkg, component_path, has_names = c("title", "text"), call = call)
    config_pluck_string(pkg, paste0(component_path, ".title"), call = call)
    config_pluck_string(pkg, paste0(component_path, ".text"), call = call)
  }

  components
}

data_home_sidebar_links <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  repo <- cran_link(pkg$package)
  links <- config_pluck(pkg, "home.links")

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

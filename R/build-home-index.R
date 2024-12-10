#' @export
#' @rdname build_home
build_home_index <- function(pkg = ".", override = list(), quiet = TRUE) {
  pkg <- section_init(pkg, override = override)

  src_path <- path_index(pkg)
  dst_path <- path(pkg$dst_path, "index.html")
  data <- data_home(pkg)

  if (is.null(src_path)) {
    cli::cli_inform("Reading {.file DESCRIPTION}")
    data$index <- linkify(pkg$desc$get_field("Description", ""))
  } else {
    cli::cli_inform("Reading {src_path(path_rel(src_path, pkg$src_path))}")
    local_options_link(pkg, depth = 0L)
    data$index <- markdown_body(pkg, src_path)
  }

  cur_digest <- file_digest(dst_path)
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

  new_digest <- file_digest(dst_path)
  if (cur_digest != new_digest) {
    writing_file(path_rel(dst_path, pkg$dst_path), "index.html")
  }

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

  config_pluck_list(pkg, "home", call = call)
  html_path <- config_pluck_string(pkg, "home.sidebar.html", call = call)
  if (!is.null(html_path)) {
    html_path_abs <- path(pkg$src_path, html_path)

    if (!file_exists(html_path_abs)) {
      msg <- "{.field home.sidebar.html} specifies a file that doesn't exist ({.file {html_path}})."
      config_abort(pkg, msg, call = call)
    }
    return(read_file(html_path_abs))
  }

  structure <- config_pluck_character(
    pkg,
    "home.sidebar.structure",
    default = default_sidebar_structure(),
    call = call
  )

  # compute all default sections
  default_components <- list(
    links = data_home_sidebar_links(pkg),
    license = data_home_sidebar_license(pkg),
    community = data_home_sidebar_community(pkg),
    citation = data_home_sidebar_citation(pkg),
    authors = data_home_sidebar_authors(pkg),
    dev = sidebar_section(tr_("Dev Status"), "placeholder", class = "dev-status"),
    toc = data_home_toc(pkg)
  )

  needs_components <- setdiff(structure, names(default_components))
  custom_yaml <- config_pluck_sidebar_components(pkg, needs_components, call = call)
  custom_components <- purrr::map(custom_yaml, function(x) {
    sidebar_section(x$title, markdown_text_block(pkg, x$text))
  })
  components <- modify_list(default_components, custom_components)

  sidebar <- purrr::compact(components[structure])
  paste0(sidebar, collapse = "\n")
}

# Update sidebar-configuration.Rmd if this changes
default_sidebar_structure <- function() {
  c("links", "license", "community", "citation", "authors", "dev")
}

config_pluck_sidebar_components <- function(pkg, new_components, call = caller_env()) {
  base_path <- "home.sidebar.components"
  components <- config_pluck_list(pkg, base_path, has_names = new_components, call = call)

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

  bug_reports <- pkg$desc$get_field("BugReports", default = NULL)
  if (!is.null(bug_reports) && grepl("@", bug_reports) && !startsWith(bug_reports, "http")) {
    bug_reports <- paste0("mailto:", bug_reports)
  }

  links <- c(
    link_url(sprintf(tr_("View on %s"), repo$repo), repo$url),
    link_url(sprintf("See dependencies"), repo$repo), repo$url),
    link_url(tr_("Browse source code"), repo_home(pkg)),
    link_url(tr_("Report a bug"), bug_reports),
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

cran_link <- function(pkg) {
  if (!has_internet()) {
    return(NULL)
  }

  cran_url <- paste0("https://cloud.r-project.org/package=", pkg)
  req <- httr2::request(cran_url)
  req <- req_pkgdown_cache(req)
  req <- httr2::req_error(req, function(resp) FALSE)
  resp <- httr2::req_perform(req)
  if (!httr2::resp_is_error(resp)) {
    return(list(repo = "CRAN", url = cran_url))
  }

  # bioconductor always returns a 200 status, redirecting to /removed-packages/
  bioc_url <- paste0("https://www.bioconductor.org/packages/", pkg)
  req <- httr2::request(bioc_url)
  req <- req_pkgdown_cache(req)
  req <- httr2::req_error(req, function(resp) FALSE)
  req <- httr2::req_retry(req, max_tries = 3)
  resp <- httr2::req_perform(req)

  if (!httr2::resp_is_error(resp) && !grepl("removed-packages", httr2::resp_url(resp))) {
    return(list(repo = "Bioconductor", url = bioc_url))
  }

  NULL
}

req_pkgdown_cache <- function(req) {
  cache_path <- dir_create(path(tools::R_user_dir("pkgdown", "cache"), "http"))
  httr2::req_cache(
    req,
    path = cache_path,
    max_age = 86400 # 1 day
  )
}

# authors forced to wrap words in '' to prevent spelling errors
cran_unquote <- function(string) {
  gsub("\\'(.*?)\\'", "\\1", string)
}

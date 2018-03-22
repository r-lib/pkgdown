#' Build news section
#'
#' Your `NEWS.md` is parsed in to sections based on your use of
#' headings. Each minor version (i.e. the combination of first and second
#' components) gets on one page, with all patch versions (i.e. the third
#' component) on a single page. News items for development versions (by
#' convention those versions with a fourth component) are displayed on an
#' an "unreleased" page.
#'
#' The `NEWS.md` file should be formatted somewhat like this:
#'
#' ```
#' # pkgdown 0.1.0.9000
#'
#' ## Major changes
#'
#'  - Fresh approach based on the staticdocs package. Site configuration now based on YAML files.
#'
#' ...
#' ```
#'
#' Commonly used subsection headers include 'Major changes', 'Bug fixes', 'Minor
#' changes'.
#'
#' Issues and contributors mentioned in news items are automatically linked to
#' github if a `URL` entry linking to github.com is provided in the package
#' `DESCRIPTION`.
#'
#' ```
#' ## Major changes
#'
#'   - Lots of bug fixes (@hadley, #100)
#' ```
#'
#' If the package is available on CRAN, release dates will be added for listed versions.
#'
#' @section YAML config:
#'
#' To automatically link to release announcements, include a `releases`
#' section.
#'
#' ```
#' news:
#'  releases:
#'  - text: "usethis 1.3.0"
#'    href: https://www.tidyverse.org/articles/2018/02/usethis-1-3-0/
#'  - text: "usethis 1.0.0 (and 1.1.0)"
#'    href: https://www.tidyverse.org/articles/2017/11/usethis-1.0.0/
#' ```
#'
#' Control whether news is present on one page or multiple pages with the
#' `one_page` field. The default is `true`.
#'
#' ```
#' news:
#' - one_page: false
#' ```
#'
#' @inheritParams build_articles
#' @export
build_news <- function(pkg = ".",
                       override = list(),
                       preview = NA) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  one_page <- purrr::pluck(pkg, "meta", "news", "one_page", .default = TRUE)

  if (!has_news(pkg$src_path))
    return()

  rule("Building news")
  dir_create(path(pkg$dst_path, "news"))

  if (one_page) {
    build_news_single(pkg)
  } else {
    build_news_multi(pkg)
  }

  preview_site(pkg, "news", preview = preview)
}

build_news_single <- function(pkg) {
  news <- data_news(pkg)

  render_page(
    pkg,
    "news",
    list(
      contents = purrr::transpose(news),
      pagetitle = "Changelog",
      source = github_source_links(pkg$github_url, "NEWS.md")
    ),
    path("news", "index.html")
  )
}

build_news_multi <- function(pkg) {
  news <- data_news(pkg)
  major <- factor(news$major_dev, levels = unique(news$major_dev))

  news_paged <- tibble::tibble(
    version = levels(major),
    file_out = paste0("news-", version, ".html"),
    contents = news[c("html", "version", "anchor")] %>% split(major)
  )

  render_news <- function(version, file_out, contents) {
    render_page(
      pkg,
      "news",
      list(
        version = version,
        contents = rev(purrr::transpose(contents)),
        pagetitle = paste0("Version ", version)
      ),
      path("news", file_out),
    )
  }
  news_paged %>% purrr::pmap(render_news)

  render_page(
    pkg,
    "news-index",
    list(versions = news %>% purrr::transpose(), pagetitle = "News"),
    path("news", "index.html")
  )
}

globalVariables(".")

data_news <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  scoped_file_context(depth = 1L)

  html <- markdown(path(pkg$src_path, "NEWS.md"))

  sections <- xml2::read_html(html) %>%
    xml2::xml_find_all("./body/div")

  titles <- sections %>%
    xml2::xml_find_first(".//h1|h2") %>%
    xml2::xml_text(trim = TRUE)

  if (any(is.na(titles))) {
    stop("Invalid NEWS.md: bad nesting of titles", call. = FALSE)
  }

  anchors <- sections %>%
    xml2::xml_attr("id")

  re <- regexec("^([[:alnum:],\\.]+)\\s+((\\d+[.-]\\d+)(?:[.-]\\d+)*)", titles)
  pieces <- regmatches(titles, re)

  # Only keep sections with unambiguous version
  is_version <- purrr::map_int(pieces, length) == 4
  pieces <- pieces[is_version]
  sections <- sections[is_version]
  anchors <- anchors[is_version]

  major <- purrr::map_chr(pieces, 4)
  version <- purrr::map_chr(pieces, 3)

  timeline <- pkg_timeline(pkg$package)
  html <- sections %>%
    purrr::walk(tweak_code) %>%
    purrr::walk2(version, tweak_news_heading, timeline = timeline) %>%
    purrr::map_chr(as.character) %>%
    purrr::map_chr(add_github_links, pkg = pkg)

  news <- tibble::tibble(
    version = version,
    is_dev = is_dev(version),
    major = major,
    major_dev = ifelse(is_dev, "unreleased", major),
    anchor = anchors,
    html = html
  )

  news
}

navbar_news <- function(pkg) {
  releases_meta <- pkg$meta$news$releases
  if (!is.null(releases_meta)) {
    menu("News",
      c(
        list(menu_text("Releases")),
        releases_meta,
        list(
          menu_spacer(),
          menu_link("Changelog", "news/index.html")
        )
      )
    )
  } else if (has_news(pkg$src_path)) {
    menu_link("Changelog", "news/index.html")
  }
}

has_news <- function(path = ".") {
  file_exists(path(path, "NEWS.md"))
}

is_dev <- function(version) {
  dev_v <- version %>%
    package_version() %>%
    purrr::map(unclass) %>%
    purrr::map_dbl(c(1, 4), .null = 0)

  dev_v > 0
}

pkg_timeline <- function(package) {
  url <- paste0("http://crandb.r-pkg.org/", package, "/all")

  resp <- httr::GET(url)
  if (httr::http_error(resp)) {
    return(NULL)
  }

  content <- httr::content(resp)
  timeline <- content$timeline

  data.frame(
    version = names(timeline),
    date = as.Date(unlist(timeline)),
    stringsAsFactors = FALSE
  )
}

rel_date_html <- function(date) {
  if (is.na(date))
    return("<small> Unreleased</small>")

  paste0("<small> ", date, "</small>")
}

tweak_news_heading <- function(x, versions, timeline) {
  x %>%
    xml2::xml_find_all(".//h1") %>%
    xml2::xml_set_attr("class", "page-header")

  if (is.null(timeline))
    return(x)

  date <- timeline$date[match(versions, timeline$version)]
  date_str <- ifelse(is.na(date), "Unreleased", as.character(date))

  date_nodes <- paste(" <small>", date_str, "</small>", collapse = "") %>%
    xml2::read_html() %>%
    xml2::xml_find_all(".//small")

  x %>%
    xml2::xml_find_all(".//h1") %>%
    xml2::xml_add_child(date_nodes, .where = 1)

  invisible()
}

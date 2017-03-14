#' Build news section
#'
#' Your \code{NEWS.md} is parsed in to sections based on your use of
#' headings. Each minor version (i.e. the combination of first and second
#' components) gets on one page, with all patch versions (i.e. the third
#' component) on a single page. News items for development versions (by
#' convention those versions with a fourth component) are displayed on an
#' an "unreleased" page.
#'
#' The \code{NEWS.md} file should be formatted somewhat like this:
#'
#' \preformatted{
#' # pkgdown 0.1.0.9000
#'
#' ## Major changes
#'
#'  - Fresh approach based on the staticdocs package. Site configuration now based on YAML files.
#'
#' ...
#' }
#'
#' Commonly used subsection headers include 'Major changes', 'Bug fixes', 'Minor changes'.
#'
#' @section YAML config:
#'
#' There are currently no configuration options.
#'
#' @inheritParams build_articles
#' @param one_page If \code{TRUE}, writes all news to a single file.
#'   If \code{FALSE}, writes one file per major version.
#' @export
build_news <- function(pkg = ".",
                       path = "docs/news",
                       one_page = TRUE,
                       depth = 1L) {
  old <- set_pkgdown_env("true")
  on.exit(set_pkgdown_env(old))

  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)
  if (!has_news(pkg$path))
    return()

  rule("Building news")
  mkdir(path)

  if (one_page) {
    build_news_single(pkg, path, depth)
  } else {
    build_news_multi(pkg, path, depth)
  }

  invisible()
}

build_news_single <- function(pkg, path, depth) {
  news <- data_news(pkg, depth = depth)

  render_page(
    pkg,
    "news",
    list(
      version = "All releases",
      contents = news %>% purrr::transpose(),
      pagetitle = "All news"
    ),
    file.path(path, "index.html"),
    depth = depth
  )
}

build_news_multi <- function(pkg, path, depth) {
  news <- data_news(pkg, depth = depth)
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
      file.path(path, file_out),
      depth = depth
    )
  }
  news_paged %>% purrr::pmap(render_news)

  render_page(
    pkg,
    "news-index",
    list(versions = news %>% purrr::transpose(), pagetitle = "News"),
    file.path(path, "index.html"),
    depth = depth
  )
}

globalVariables(".")

data_news <- function(pkg = ".", depth = 1L) {
  pkg <- as_pkgdown(pkg)
  html <- markdown(
    file.path(pkg$path, "NEWS.md"),
    "--section-divs",
    depth = depth,
    index = pkg$topics
  )

  sections <- xml2::read_html(html) %>%
    xml2::xml_find_all("./body/div")

  titles <- sections %>%
    xml2::xml_find_first(".//h1|h2") %>%
    xml2::xml_text(trim = TRUE)

  anchors <- sections %>%
    xml2::xml_attr("id")

  re <- regexec("^([[:alnum:],\\.]+)\\s+((\\d+[.-]\\d+)(?:[.-]\\d+)*)", titles)
  pieces <- regmatches(titles, re)

  # Only keep sections with unambiguous version
  is_version <- purrr::map_int(pieces, length) == 4
  pieces <- pieces[is_version]
  sections <- sections[is_version]
  anchors <- anchors[is_version]

  major <- pieces %>% purrr::map_chr(4)

  html <- sections %>%
    purrr::walk(autolink_html, depth = depth, index = pkg$topics) %>%
    purrr::map_chr(as.character)

  news <- tibble::tibble(
    version = pieces %>% purrr::map_chr(3),
    is_dev = is_dev(version),
    major = major,
    major_dev = ifelse(is_dev, "unreleased", major),
    anchor = anchors,
    html = html
  )
  news[is_version, , drop = FALSE]
}

has_news <- function(path = ".") {
  file.exists(file.path(path, "NEWS.md"))
}

is_dev <- function(version) {
  dev_v <- version %>%
    package_version() %>%
    purrr::map(unclass) %>%
    purrr::map_dbl(c(1, 4), .null = 0)

  dev_v > 0
}

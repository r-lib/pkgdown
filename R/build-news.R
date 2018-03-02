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
#' Commonly used subsection headers include 'Major changes', 'Bug fixes', 'Minor
#' changes'.
#'
#' Issues and contributors mentioned in news items are automatically linked to
#' github if a `URL` entry linking to github.com is provided in the package
#' `DESCRIPTION`.
#'
#' \preformatted{
#' ## Major changes
#'
#'   - Lots of bug fixes (@hadley, #100)
#' }
#'
#' @section YAML config:
#'
#' There are currently no configuration options.
#'
#' @inheritParams build_articles
#' @param one_page If `TRUE`, writes all news to a single file.
#'   If `FALSE`, writes one file per major version.
#' @export
build_news <- function(pkg = ".",
                       one_page = TRUE,
                       preview = NA) {
  pkg <- section_init(pkg, depth = 1L)

  if (!has_news(pkg$src_path))
    return()

  rule("Building news")
  dir_create(path(pkg$dst_path, "news"))

  if (one_page) {
    build_news_single(pkg)
  } else {
    build_news_multi(pkg)
  }

  section_fin(pkg, "news", preview = preview)
}

build_news_single <- function(pkg) {
  news <- data_news(pkg)

  render_page(
    pkg,
    "news",
    list(
      version = "All releases",
      contents = news %>% purrr::transpose(),
      pagetitle = "All news"
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

  major <- pieces %>% purrr::map_chr(4)

  html <- sections %>%
    purrr::walk(tweak_code) %>%
    purrr::map_chr(as.character) %>%
    purrr::map_chr(add_github_links, pkg = pkg)

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
  file_exists(path(path, "NEWS.md"))
}

is_dev <- function(version) {
  dev_v <- version %>%
    package_version() %>%
    purrr::map(unclass) %>%
    purrr::map_dbl(c(1, 4), .null = 0)

  dev_v > 0
}

add_github_links <- function(x, pkg) {
  user_link <- paste0("<a href='http://github.com/\\1'>@\\1</a>")
  x <- gsub("@(\\w+)", user_link, x)

  gh_link <- github_link(pkg$src_path)
  if (is.null(gh_link)) {
    return(x)
  }

  gh_link_href <- github_link(pkg$src_path)$href
  issue_link <- paste0("<a href='", gh_link_href, "/issues/\\1'>#\\1</a>")
  x <- gsub("#(\\d+)", issue_link, x)

  x
}

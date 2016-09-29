#' Build news section
#'
#' Your \code{NEWS.md} is parsed in to sections based on your use of
#' headings. Each minor version (i.e. the combination of first and second
#' components) gets on one page, with all patch versions (i.e. the third
#' comoponent) on a single page. News items for development versions (by
#' convention those versions with a four component) are displayed on an
#' an "unreleased" page.
#'
#' @section YAML config:
#'
#' There are currently no configuration options.
#'
#' @inheritParams build_articles
#' @export
build_news <- function(pkg = ".", path = "docs/news", depth = 1L) {
  pkg <- as_staticdocs(pkg)
  if (!has_news(pkg$path))
    return()

  rule("Building news")
  mkdir(path)

  news <- data_news(pkg, depth = depth)

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
  news %>% purrr::pmap(render_news)

  render_page(
    pkg,
    "news-index",
    list(versions = news %>% purrr::transpose(), pagetitle = "News"),
    file.path(path, "index.html"),
    depth = depth
  )

  invisible()
}

data_news <- function(pkg = ".", depth = 1L) {
  pkg <- as_staticdocs(pkg)
  html <- markdown(file.path(pkg$path, "NEWS.md"), "--section-divs")

  sections <- xml2::read_html(html) %>%
    xml2::xml_find_all("./body/div")

  titles <- sections %>%
    xml2::xml_find_first(".//h1|h2") %>%
    xml2::xml_text()
  anchor <- sections %>%
    xml2::xml_attr("id")

  re <- regexec("^([[:alpha:]]+)\\s+((\\d+\\.\\d+)(?:\\.\\d+)*)", titles)
  pieces <- regmatches(titles, re)
  is_version <- purrr::map_int(pieces, length) == 4

  # TODO: do all the subsetting in one place.
  major <- pieces[is_version] %>% purrr::map_chr(4)

  news <- tibble::tibble(
    version = pieces %>% purrr::map_chr(3),
    is_dev = is_dev(version),
    anchor = anchor,
    major = major,
    major_dev = ifelse(is_dev, "unreleased", major),
    html = sections %>% purrr::map_chr(as.character)
  )
  news <- news[is_version, , drop = FALSE]

  major <- factor(news$major_dev, levels = unique(news$major_dev))

  tibble::tibble(
    version = levels(major),
    file_out = paste0("news-", version, ".html"),
    contents = news[c("html", "version", "anchor")] %>% split(major)
  )
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

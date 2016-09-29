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

  news <- data_news(pkg)

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

data_news <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  major <- factor(pkg$news$major_dev, levels = unique(pkg$news$major_dev))

  contents <- pkg$news[c("html", "version", "anchor")] %>%
    split(major)

  tibble::tibble(
    version = levels(major),
    file_out = paste0("news-", version, ".html"),
    contents = contents
  )
}

has_news <- function(path = ".") {
  file.exists(file.path(path, "NEWS.md"))
}

#' Build news section
#'
#' Your `NEWS.md` is parsed in to sections based on your use of headings.
#'
#' The `NEWS.md` file should be formatted with level one headings (`#`)
#' containing the package name and version number, level two headings (`##`)
#' with topic headings and lists of news bullets. Commonly used level two
#' headings include 'Major changes', 'Bug fixes', or 'Minor changes'.
#'
#' ```
#' # pkgdown 0.1.0.9000
#'
#' ## Major changes
#'
#' - Fresh approach based on the staticdocs package. Site configuration now based
#'   on YAML files.
#' ```
#'
#' If the package is available on CRAN, release dates will be added to versions
#' in level-one headings, and "Unreleased" will be added versions that are not on
#' CRAN.
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
#'   one_page: false
#' ```
#'
#' Suppress the default addition of CRAN release dates with:
#'
#' ```
#' news:
#'   cran_dates: false
#' ```
#'
#' @seealso [Tidyverse style for News](http://style.tidyverse.org/news.html)
#'
#' @inheritParams build_articles
#' @export
build_news <- function(pkg = ".",
                       override = list(),
                       preview = NA) {
  pkg <- section_init(pkg, depth = 1L, override = override)
  if (!has_news(pkg$src_path))
    return()

  rule("Building news")
  dir_create(path(pkg$dst_path, "news"))

  switch(news_style(pkg$meta),
    single = build_news_single(pkg),
    multi = build_news_multi(pkg)
  )

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
      source = repo_source(pkg, "NEWS.md")
    ),
    path("news", "index.html")
  )
}

build_news_multi <- function(pkg) {
  news <- data_news(pkg)
  page <- factor(news$page, levels = unique(news$page))

  news_paged <- tibble::tibble(
    version = levels(page),
    file_out = paste0("news-", version, ".html"),
    contents = news[c("html", "version", "anchor")] %>% split(page)
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
    list(versions = news_paged %>% purrr::transpose(), pagetitle = "News"),
    path("news", "index.html")
  )
}

globalVariables(".")

data_news <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  html <- markdown(path(pkg$src_path, "NEWS.md"))
  xml <- xml2::read_html(html)
  downlit::downlit_html_node(xml)

  sections <- xml2::xml_find_all(xml, "./body/div")

  titles <- sections %>%
    xml2::xml_find_first(".//h1|h2") %>%
    xml2::xml_text(trim = TRUE)
  anchors <- sections %>% xml2::xml_attr("id")

  if (any(is.na(titles))) {
    stop("Invalid NEWS.md: bad nesting of titles", call. = FALSE)
  }

  versions <- news_version(titles)
  sections <- sections[!is.na(versions)]
  anchors <- anchors[!is.na(versions)]
  versions <- versions[!is.na(versions)]

  show_dates <- purrr::pluck(pkg, "meta", "news", "cran_dates", .default = TRUE)
  if (show_dates) {
    timeline <- pkg_timeline(pkg$package)
  } else {
    timeline <- NULL
  }

  html <- sections %>%
    purrr::walk2(versions, tweak_news_heading, timeline = timeline) %>%
    purrr::map_chr(as.character) %>%
    purrr::map_chr(repo_auto_link, pkg = pkg)

  news <- tibble::tibble(
    version = versions,
    page = purrr::map_chr(versions, version_page),
    anchor = anchors,
    html = html
  )

  news
}

news_version <- function(x) {
  pattern <- "(?x)
    ^(?<package>[[:alnum:],\\.]+)\\s+ # alpha-numeric package name
    (?<version>
      v?                              # optional v
      (\\d+[.-]\\d+)(?:[.-]\\d+)*     # followed by digits, dots and dashes
      |                               # OR
      (\\(development\\ version\\))   # literal used by usethis
    )
  "
  pieces <- rematch2::re_match(x, pattern)
  gsub("^[v(]|[)]$", "", pieces$version)
}

version_page <- function(x) {
  if (x == "development version") {
    return("dev")
  }

  ver <- unclass(package_version(x))[[1]]

  if (length(ver) == 4 && ver[[4]] > 0) {
    "dev"
  } else {
    paste0(ver[[1]], ".", ver[[2]])
  }
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

pkg_timeline <- function(package) {
  if (!has_internet()) {
    return(NULL)
  }

  url <- paste0("https://crandb.r-pkg.org/", package, "/all")

  resp <- httr::RETRY("GET", url, quiet = TRUE)
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

tweak_news_heading <- function(x, versions, timeline) {
  x %>%
    xml2::xml_find_all(".//h1") %>%
    xml2::xml_set_attr("class", "page-header")

  x %>%
    xml2::xml_find_all(".//h1") %>%
    xml2::xml_set_attr("data-toc-text", versions)

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

news_style <- function(meta) {
  one_page <- purrr::pluck(meta, "news", "one_page") %||%
    purrr::pluck(meta, "news", 1, "one_page") %||%
    TRUE

  if (one_page) "single" else "multi"
}

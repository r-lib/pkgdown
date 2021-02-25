#' Build news section
#'
#' @description
#' A `NEWS.md` will be broken up into versions using level one (`#`) or
#' level two headings (`##`) that (partially) match one of the following forms
#' (ignoring case):
#'
#' * `{package name} 1.3.0`
#' * `{package name} v1.3.0`
#' * `Version 1.3.0`
#' * `Changes in 1.3.0`
#' * `Changes in v1.3.0`
#'
#' @details
#' A [common structure](https://style.tidyverse.org/news.html) for news files
#' is to use a top level heading for each release, and use a second level
#' heading to break up individual bullets into sections.
#'
#' ```
#' # foofy 1.0.0
#'
#' ## Major changes
#'
#' * Can now work with all grooveable grobbles!
#'
#' ## Minor improvements and bug fixes
#'
#' * Printing scrobbles no longer errors (@githubusername, #100)
#'
#' * Wibbles are now 55% less jibbly (#200)
#' ```
#'
#' Issues and contributors will be automatically linked to the corresponding
#' pages on GitHub if the GitHub repo can be discovered from the `DESCRIPTION`
#' (typically from a `URL` entry containing `github.com`)
#'
#' If a version is available on CRAN, the release date will automatically
#' be added to the heading (see below for how to suppress); if not
#' available on CRAN, "Unreleased" will be added.
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
#' @seealso [Tidyverse style for News](https://style.tidyverse.org/news.html)
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

  html <- markdown(path(pkg$src_path, "NEWS.md"), pkg = pkg)
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

  versions <- news_version(titles, pkg$package)
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

news_version <- function(x, pkgname) {
  pattern <- paste0("(?x)
    (?:", pkgname, "|version|changes\\ in)
    \\s+   # whitespace
    v?     # optional v followed by
    (?<version>
      (?:\\d+[.-]\\d+)(?:[.-]\\d+)*     # digits, dots, and dashes
      |                             # OR
      \\(development\\ version\\)   # literal used by usethis
    )
  ")
  pieces <- rematch2::re_match(x, pattern, ignore.case = TRUE)
  gsub("^[(]|[)]$", "", pieces$version)
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
    xml2::xml_set_attrs(c("class" = "pb-2 mt-4 mb-2 border-bottom"))

  x %>%
    xml2::xml_find_all(".//h1") %>%
    xml2::xml_set_attr("data-toc-text", versions)

  if (is.null(timeline))
    return(x)

  date <- timeline$date[match(versions, timeline$version)]
  date_str <- ifelse(is.na(date), "Unreleased", as.character(date))

  cran_release_string <- sprintf(
    "<h6 class='text-muted' data-toc-skip> CRAN release: %s</h6>",
    date_str
  )
  date_nodes <- cran_release_string %>%
    xml2::read_html() %>%
    xml2::xml_find_all(".//h6")

  x %>%
    xml2::xml_find_all(".//h1") %>%
    xml2::xml_add_sibling(date_nodes, .where = "after")

  invisible()
}

news_style <- function(meta) {
  one_page <- purrr::pluck(meta, "news", "one_page") %||%
    purrr::pluck(meta, "news", 1, "one_page") %||%
    TRUE

  if (one_page) "single" else "multi"
}

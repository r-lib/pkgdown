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
#' ```yaml
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
#' # YAML config
#'
#' To automatically link to release announcements, include a `releases`
#' section.
#'
#' ```yaml
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
#' ```yaml
#' news:
#'   one_page: false
#' ```
#'
#' Suppress the default addition of CRAN release dates with:
#'
#' ```yaml
#' news:
#'   cran_dates: false
#' ```
#' @family site components
#'
#' @seealso [Tidyverse style for News](https://style.tidyverse.org/news.html)
#'
#' @inheritParams build_articles
#' @export
build_news <- function(pkg = ".",
                       override = list(),
                       preview = FALSE) {
  pkg <- section_init(pkg, "news", override = override)
  if (!has_news(pkg$src_path))
    return(invisible())

  cli::cli_rule("Building news")

  one_page <- config_pluck_bool(pkg, "news.one_page", default = TRUE)
  if (one_page) {
    build_news_single(pkg)
  } else {
    build_news_multi(pkg)
  }
  preview_site(pkg, "news", preview = preview)
}

build_news_single <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  news <- data_news(pkg)

  render_page(
    pkg,
    "news",
    list(
      contents = purrr::transpose(news),
      pagetitle = tr_("Changelog"),
      source = repo_source(pkg, "NEWS.md")
    ),
    path("news", "index.html")
  )
}

build_news_multi <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)
  news <- data_news(pkg)
  page <- factor(news$page, levels = unique(news$page))

  news_paged <- tibble::tibble(
    version = levels(page),
    file_out = paste0("news-", version, ".html"),
    contents = split(news[c("html", "version", "anchor")], page)
  )

  render_news <- function(version, file_out, contents) {
    # Older, major, versions first on each page
    # https://github.com/r-lib/pkgdown/issues/2285#issuecomment-2070966518
    render_page(
      pkg,
      "news",
      list(
        version = version,
        contents = rev(purrr::transpose(contents)),
        pagetitle = sprintf(tr_("Version %s"), version)
      ),
      path("news", file_out),
    )
  }
  purrr::pwalk(news_paged, render_news)

  render_page(
    pkg,
    "news-index",
    list(
      versions = purrr::transpose(news_paged),
      pagetitle = tr_("News")
    ),
    path("news", "index.html")
  )
}

data_news <- function(pkg, call = caller_env() ) {
  html <- markdown_body(pkg, path(pkg$src_path, "NEWS.md"))
  xml <- xml2::read_html(html)

  sections <- xml2::xml_find_all(xml, "./body/div")
  footnotes <- has_class(sections, "footnotes")
  if (any(footnotes)) {
    cli::cli_warn("Footnotes in NEWS.md are not currently supported")
  }
  sections <- sections[!footnotes]

  headings <- xml2::xml_find_first(sections, ".//h1|.//h2|.//h3|.//h4|.//h5")
  levels <- xml2::xml_name(headings)
  ulevels <- unique(levels)
  if (!identical(ulevels, "h1") && !identical(ulevels, "h2")) {
    msg <- c(
      "inconsistent use of section headings.",
      i = "Top-level headings must be either all <h1> or all <h2>.",
      i = "See {.help pkgdown::build_news} for more details."
    )
    config_abort(pkg, msg, path = "NEWS.md", call = call)
  }
  if (ulevels == "h1") {
    # Bump every heading down a level so to get a single <h1> for the page title
    tweak_section_levels(xml)
  }

  titles <- xml2::xml_text(xml2::xml_find_first(sections, ".//h2"), trim = TRUE)

  versions <- news_version(titles, pkg$package)
  sections <- sections[!is.na(versions)]

  if (length(sections) == 0) {
    msg <- c(
      "no version headings found",
      i = "See {.help pkgdown::build_news} for expected structure."
    )
    config_warn(pkg, msg, path = "NEWS.md", call = call)
  }

  versions <- versions[!is.na(versions)]

  show_dates <- config_pluck_bool(pkg, "news.cran_dates", default = !is_testing())
  if (show_dates) {
    timeline <- pkg_timeline(pkg$package)
  } else {
    timeline <- NULL
  }

  purrr::walk2(
    sections,
    versions,
    tweak_news_heading,
    timeline = timeline,
    bs_version = pkg$bs_version
  )
  html <- purrr::map_chr(sections, as.character, options = character())
  html <- purrr::map_chr(html, repo_auto_link, pkg = pkg)

  anchors <- xml2::xml_attr(sections, "id")
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
  pieces <- re_match(x, pattern, ignore.case = TRUE)
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
  releases_meta <- config_pluck_list(pkg, "news.releases")
  if (!is.null(releases_meta)) {
    menu_submenu(tr_("News"),
      list2(
        menu_heading(tr_("Releases")),
        !!!releases_meta,
        menu_separator(),
        menu_link(tr_("Changelog"), "news/index.html")
      )
    )
  } else if (has_news(pkg$src_path)) {
    menu_link(tr_("Changelog"), "news/index.html")
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
  req <- httr2::request(url)
  req <- httr2::req_retry(req, max_tries = 3)
  req <- httr2::req_error(req, function(resp) FALSE)

  resp <- httr2::req_perform(req)
  if (httr2::resp_is_error(resp)) {
    return(NULL)
  }

  content <- httr2::resp_body_json(resp)
  timeline <- unlist(content$timeline)

  data.frame(
    version = names(timeline),
    date = as.Date(timeline),
    row.names = NULL
  )
}

tweak_news_heading <- function(html, version, timeline, bs_version) {
  class <- if (bs_version == 3) "page-header" else "pkg-version"

  h2 <- xml2::xml_find_all(html, ".//h2")
  xml2::xml_set_attr(h2, "class", class)
  xml2::xml_set_attr(h2, "data-toc-text", version)

  # Add release date, if known
  if (!is.null(timeline)) {
    date <- timeline$date[match(version, timeline$version)]
    if (!is.na(date)) {
      if (bs_version == 3) {
        release_str <- paste0(" <small>", date, "</small>")
        release_html <- xml2::xml_find_first(xml2::read_html(release_str), ".//small")
        xml2::xml_add_child(h2, release_html, .where = 1)
      } else {
        release_date <- sprintf(tr_("CRAN release: %s"), date)
        release_str <- paste0("<p class='text-muted'>", release_date, "</p>")
        release_html <- xml2::xml_find_first(xml2::read_html(release_str), ".//p")
        xml2::xml_add_sibling(h2, release_html, .where = "after")
      }
    }
  }

  tweak_news_anchor(html, version)

  invisible()
}

# Manually de-duplicate repeated section anchors using version
tweak_news_anchor <- function(html, version) {
  div <- xml2::xml_find_all(html, ".//div")
  div <- div[has_class(div, "section")]

  id <- xml2::xml_attr(div, "id")
  id <- gsub("-[0-9]+", "", id) # remove pandoc de-duplication suffixes
  id <- paste0(id, "-", gsub("[^a-z0-9]+", "-", version)) # . breaks scrollspy
  xml2::xml_attr(div, "id") <- id

  invisible()
}

tweak_section_levels <- function(html) {
  sections <- xml2::xml_find_all(html, ".//div[contains(@class, 'section level')]|//main/section")

  # Update headings
  xml2::xml_set_name(xml2::xml_find_all(sections, ".//h5"), "h6")
  xml2::xml_set_name(xml2::xml_find_all(sections, ".//h4"), "h5")
  xml2::xml_set_name(xml2::xml_find_all(sections, ".//h3"), "h4")
  xml2::xml_set_name(xml2::xml_find_all(sections, ".//h2"), "h3")
  xml2::xml_set_name(xml2::xml_find_all(sections, ".//h1"), "h2")

  # Update section
  xml2::xml_attr(sections, "class") <- paste0("section level", get_section_level(sections) + 1)

  invisible()
}

news_style <- function(pkg) {
  one_page <- config_pluck_bool(pkg, "new.one_page")
  if (one_page) "single" else "multi"
}

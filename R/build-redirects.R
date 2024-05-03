#' Build redirects
#' 
#' @description
#' If you change the structure of your documentation (by renaming vignettes or 
#' help topics) you can setup redirects from the old content to the new content.
#' One or several now-absent pages can be redirected to a new page (or to a new 
#' section of a new page). This works by creating a html page that performs a 
#' "meta refresh", which isn't the best way of doing a redirect but works 
#' everywhere that you might deploy your site.
#' 
#' The syntax is the following, with old paths on the left, and new paths or 
#' URLs on the right.
#' 
#' ```yaml
#' redirects:
#'   - ["articles/old-vignette-name.html", "articles/new-vignette-name.html"]
#'   - ["articles/another-old-vignette-name.html", "articles/new-vignette-name.html"]
#'   - ["articles/yet-another-old-vignette-name.html", "https://pkgdown.r-lib.org/dev"]
#' ```
#' 
#' If for some reason you choose to redirect an existing page make sure to 
#' exclude it from the search index, see `?build_search`.
#'
#' @inheritParams as_pkgdown
#' @export
build_redirects <- function(pkg = ".",
                            override = list()) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  redirects <- c(
    article_redirects(pkg),
    pkg$meta$redirects
  )

  if (is.null(redirects)) {
    return(invisible())
  }

  cli::cli_rule("Building redirects")
  if (is.null(pkg$meta$url)) {
    msg_fld <- pkgdown_field("url", fmt = TRUE)
    config_abort(
      pkg,
      paste0(msg_fld, " is required to generate redirects.")
    )
  }

  purrr::iwalk(
    redirects,
    build_redirect,
    pkg = pkg
  )
}

build_redirect <- function(entry, index, pkg) {
  if (!is.character(entry) || length(entry) != 2) {
    msg_fld <- pkgdown_field("redirects")
    config_abort(
      pkg,
      "{.field {msg_fld}[[{index}]]} must be a character vector of length 2.",
      call = caller_env()
    )
  }

  new <- entry[2]
  old <- path(pkg$dst_path, entry[1])

  path <- find_template("layout", "redirect", pkg = pkg)
  template <- read_file(path)

  url <- sprintf("%s/%s%s", pkg$meta$url, pkg$prefix, new)
  lines <- whisker::whisker.render(template, list(url = url))
  dir_create(path_dir(old))
  write_lines(lines, old)
}

article_redirects <- function(pkg) {
  if (is.null(pkg$meta$url)) {
    return(NULL)
  }

  is_vig_in_articles <- path_has_parent(pkg$vignettes$name, "articles")
  if (!any(is_vig_in_articles)) {
    return(NULL)
  }

  articles <- pkg$vignettes$file_out[is_vig_in_articles]
  purrr::map(articles, ~ paste0(c("articles/", ""), .x))
}

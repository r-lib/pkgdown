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
build_redirects <- function(pkg = ".", override = list()) {
  pkg <- section_init(pkg, override = override)
  has_url <- !is.null(config_pluck_string(pkg, "url"))

  redirects <- data_redirects(pkg, has_url)
  if (length(redirects) == 0) {
    return(invisible())
  }

  cli::cli_rule("Building redirects")
  if (!has_url) {
    config_abort(pkg, "{.field url} is required to generate redirects.")
  }

  # Ensure user redirects override automatic ones
  from <- purrr::map_chr(redirects, 1)
  redirects <- redirects[!duplicated(from)]

  purrr::iwalk(redirects, build_redirect, pkg = pkg)
}

build_redirect <- function(entry, index, pkg) {
  new <- entry[2]
  old <- path(pkg$dst_path, entry[1])

  path <- find_template("layout", "redirect", pkg = pkg)
  template <- read_file(path)

  url <- sprintf("%s/%s%s", config_pluck_string(pkg, "url"), pkg$prefix, new)
  lines <- whisker::whisker.render(template, list(url = url))
  dir_create(path_dir(old))

  if (!file_exists(old)) {
    cli::cli_inform("Adding redirect from {entry[1]} to {entry[2]}.")
  }
  write_lines(lines, old)
}

data_redirects <- function(pkg, has_url = FALSE, call = caller_env()) {
  c(
    if (has_url) reference_redirects(pkg),
    if (has_url) article_redirects(pkg),
    config_pluck_redirects(pkg, call = call)
  )
}

reference_redirects <- function(pkg) {
  aliases <- unname(pkg$topics$alias)
  aliases <- purrr::map2(aliases, pkg$topics$name, setdiff)
  names(aliases) <- pkg$topics$file_out

  redirects <- invert_index(aliases)
  if (length(redirects) == 0) {
    return(list())
  }

  names(redirects) <- paste0(names(redirects), ".html")

  # Ensure we don't create an invalid file name
  redirects <- redirects[valid_filename(names(redirects))]

  # Ensure we don't override an existing file
  redirects <- redirects[setdiff(names(redirects), pkg$topics$file_out)]

  unname(purrr::imap(
    redirects,
    function(to, from) paste0("reference/", c(from, to))
  ))
}

valid_filename <- function(x) {
  x == path_sanitize(x)
}

article_redirects <- function(pkg) {
  is_vig_in_articles <- path_has_parent(pkg$vignettes$name, "articles")
  if (!any(is_vig_in_articles)) {
    return(NULL)
  }

  articles <- pkg$vignettes$file_out[is_vig_in_articles]
  purrr::map(articles, ~ paste0(c("articles/", ""), .x))
}

config_pluck_redirects <- function(pkg, call = caller_env()) {
  redirects <- config_pluck_list(pkg, "redirects", call = call)
  for (i in seq_along(redirects)) {
    redirect <- redirects[[i]]
    if (!is.character(redirect) || length(redirect) != 2) {
      not <- obj_type_friendly(redirect)
      config_abort(
        pkg,
        "{.field redirects[{i}]} must be a character vector of length 2, not {not}.",
        call = call
      )
    }
  }
  redirects
}

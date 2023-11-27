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
    cli::cli_abort("{.field {pkgdown_field('url')}} in {.file {pkgdown_config_relpath(pkg)}} required to generate redirects")
  }

  purrr::iwalk(
    redirects,
    build_redirect,
    pkg = pkg
  )
}

build_redirect <- function(entry, index, pkg) {
  if (!is.character(entry) || length(entry) != 2) {
    cli::cli_abort(
      "Entry {.emph {index}} in {.field {pkgdown_field('redirects')}} must be a character vector of length 2.",
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

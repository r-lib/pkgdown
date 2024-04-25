build_redirects <- function(pkg = ".",
                            override = list()) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  redirects <- c(
    reference_redirects(pkg),
    article_redirects(pkg),
    pkg$meta$redirects
  )

  # Ensure user redirects override automatic ones
  from <- purrr::map_chr(redirects, 1)
  redirects <- redirects[!duplicated(from)]

  if (is.null(redirects)) {
    return(invisible())
  }

  cli::cli_rule("Building redirects")
  if (is.null(pkg$meta$url)) {
    msg_fld <- pkgdown_field(pkg, "url", cfg = TRUE, fmt = TRUE)
    cli::cli_abort(
      paste0(msg_fld, " is required to generate redirects."),
      call = caller_env()
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
    msg_fld <- pkgdown_field(pkg, "url", cfg = TRUE, fmt = TRUE)
    cli::cli_abort(
      c(
        "Entry {.emph {index}} must be a character vector of length 2.",
        x = paste0("Edit ", msg_fld, ".")
      ),
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

  if (!file_exists(old)) {
    cli::cli_inform("Adding redirect from {entry[1]} to {entry[2]}.")
  }
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

reference_redirects <- function(pkg) {
  if (is.null(pkg$meta$url)) {
    return(NULL)
  }

  aliases <- unname(pkg$topics$alias)
  aliases <- purrr::map2(aliases, pkg$topics$name, setdiff)
  names(aliases) <- pkg$topics$file_out

  redirects <- invert_index(aliases)
  if (length(redirects) == 0) {
    return(list())
  }

  names(redirects) <- paste0(names(redirects), ".html")

  # Ensure we don't override an existing file
  redirects <- redirects[setdiff(names(redirects), pkg$topics$file_out)]

  unname(purrr::imap(redirects, function(to, from) paste0("reference/", c(from, to))))
}

build_redirects <- function(pkg = ".",
                            override = list()) {
  pkg <- section_init(pkg, depth = 1L, override = override)

  if (is.null(pkg$meta$redirects)) {
    return(invisible())
  }

  rule("Building redirects")
  if (is.null(pkg$meta$url)) {
    abort(sprintf("Can't find %s.", pkgdown_field(pkg, "url")))
  }


  purrr::iwalk(
    pkg$meta$redirects,
    build_redirect,
    pkg = pkg
  )
}

build_redirect <- function(entry, index, pkg) {
  if (!is.character(entry)) || length(entry) != 2) {
    abort(
      sprintf(
        "Entry %s in %s must be a character vector of length 2.",
        index,
        pkgdown_field(pkg, "redirects")
      )
    )
  }

  new <- entry[2]
  old <- entry[1]

  path <- find_template(
    "content", "redirect",
    template_path = template_path(pkg),
    bs_version = pkg$bs_version
  )
  template <- read_file(path)

  url <- sprintf("%s/%s%s", pkg$meta$url, pkg$prefix, new)
  lines <- whisker::whisker.render(template, list(url = url))
  write_lines(lines, file.path(pkg$dst_path, old))
}

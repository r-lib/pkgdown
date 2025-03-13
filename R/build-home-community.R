has_contributing <- function(path = ".") {
  file_exists(path(path, 'CONTRIBUTING.md')) ||
    file_exists(path(path, '.github', 'CONTRIBUTING.md'))
}

has_coc <- function(path = ".") {
  file_exists(path(path, 'CODE_OF_CONDUCT.md')) ||
    file_exists(path(path, '.github', 'CODE_OF_CONDUCT.md'))
}

has_support <- function(path = ".") {
  file_exists(path(path, 'SUPPORT.md')) ||
    file_exists(path(path, '.github', 'SUPPORT.md'))
}

data_home_sidebar_community <- function(pkg) {
  pkg <- as_pkgdown(pkg)

  links <- NULL

  if (has_contributing(pkg$src_path)) {
    links <- c(links, a(tr_("Contributing guide"), "CONTRIBUTING.html"))
  }

  if (has_coc(pkg$src_path)) {
    links <- c(links, a(tr_("Code of conduct"), "CODE_OF_CONDUCT.html"))
  }

  if (has_support(pkg$src_path)) {
    links <- c(links, a(tr_("Getting help"), "SUPPORT.html"))
  }

  if (is.null(links)) {
    return("")
  }

  sidebar_section(tr_("Community"), links)
}

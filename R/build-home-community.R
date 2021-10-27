has_contributing <- function(path = ".") {
  file_exists(path(path, 'CONTRIBUTING.md')) ||
    file_exists(path(path, '.github', 'CONTRIBUTING.md'))
}

has_coc <- function(path = ".") {
  file_exists(path(path, 'CODE_OF_CONDUCT.md')) ||
    file_exists(path(path, '.github', 'CODE_OF_CONDUCT.md'))
}

data_home_sidebar_community <- function (pkg){

  pkg <- as_pkgdown(pkg)

  links <- NULL

  if (has_contributing(pkg$src_path)) {
    links <- c(links, a(translate("Contributing guide"), "CONTRIBUTING.html"))
  }

  if (has_coc(pkg$src_path)) {
    links <- c(links, a(translate("Code of conduct"), "CODE_OF_CONDUCT.html"))
  }

  if (is.null(links)) {
    return("")
  }

  sidebar_section(translate("Community"), links)

}

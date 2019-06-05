has_contributing <- function(path = ".") {
  file_exists(path(path, 'CONTRIBUTING.html'))
}

has_coc <- function(path = ".") {
  file_exists(path(path, 'CODE_OF_CONDUCT.html'))
}

data_home_sidebar_community <- function(pkg){

  links <- NULL

  if (has_contributing(pkg$dst_path)) {
    links <- c(links,
               '<a href="CONTRIBUTING.html">Contributing guide</a>')
  }

  if (has_coc(pkg$dst_path)) {
    links <- c(links,
               '<a href="CODE_OF_CONDUCT.html">Code of conduct</a>')
  }


  if (is.null(links)) {
    return("")
  }

  sidebar_section("Community", links)

}



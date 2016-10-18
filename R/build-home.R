#' Build home page
#'
#' First looks for \code{index.Rmd} or \code{README.Rmd}, then
#' \code{index.md} or \code{README.md}. If none are found, falls back to the
#' description field in \code{DESCRIPTION}.
#'
#' @section YAML config:
#' There are currently no options to control the appearance of the
#' homepage.
#'
#' @inheritParams build_articles
#' @export
build_home <- function(pkg = ".", path = "docs", depth = 0L) {
  pkg <- as_pkgdown(pkg)
  rule("Building home")

  home_path <- find_first_existing(
    pkg$path,
    c("index.Rmd", "README.Rmd", "index.md", "README.md")
  )
  title <- pkg$desc$get("Title")[[1]]



  if (identical(tools::file_ext(home_path), "Rmd")) {
    input <- file.path(path, basename(home_path))
    file.copy(home_path, path)
    render_article(pkg, input, "index.html", depth = depth,
      title = title,
      toc = FALSE,
      strip_header = TRUE)
    unlink(input)
  } else {
    data <- list(pagetitle = title)

    if (is.null(path)) {
      data$index <- pkg$description
    } else {
      data$index <- markdown(path = home_path, depth = 0L, index = pkg$topics)
    }
    render_page(pkg, "home", data, out_path(path, "index.html"), depth = depth)
  }

  invisible()
}

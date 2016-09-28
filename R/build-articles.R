#' Build articles
#'
#' Each Rmarkdown vignette in \code{vignettes/} and its subdirectories is
#' rendered. Vignettes are rendered using a special document format that
#' reconciles \code{\link[rmarkdown]{html_document}()} with your staticdocs
#' template.
#'
#' @section Supressing vignettes:
#'
#' If you want articles that are not vignettes, either put them in
#' subdirectories or list in \code{.Rbuildignore}. An articles link
#' will be automatically added to the default navbar if the vignettes
#' directory is present: if you do not want this, you will need to
#' customise the navbar. See \code{\link{build_site}} details.
#'
#' @param pkg Path to source package.
#' @param path Output path.
#' @param depth Depth of path relative to root of documentation.
#'   Used to adjust relative links in the navbar.
#' @export
build_articles <- function(pkg = ".", path = "docs/articles", depth = 1L) {
  pkg <- as_staticdocs(pkg)
  if (nrow(pkg$vignettes) == 0) {
    return()
  }

  rule("Building articles")
  mkdir(path)

  format <- build_rmarkdown_format(pkg, depth = depth)
  on.exit(unlink(format$path), add = TRUE)

  render_article <- function(file_in, file_out) {
    message("Building vignette '", file_in, "'")
    rmarkdown::render(
      file.path("vignettes", file_in),
      output_format = format$format,
      output_file = file.path(path, file_out),
      output_dir = path,
      quiet = TRUE,
      envir = new.env(parent = globalenv())
    )
  }
  purrr::walk2(pkg$vignettes$file_in, pkg$vignettes$file_out, render_article)

  build_articles_index(pkg, path = path, depth = depth)

  invisible()
}

build_rmarkdown_format <- function(pkg = ".", depth = 1L) {
  # Render vignette template to temporary file
  path <- tempfile(fileext = ".html")
  data <- list(
    pagetitle = "$title$"
  )
  suppressMessages(
    render_page(pkg, "vignette", data, path, depth = depth)
  )

  list(
    path = path,
    format = rmarkdown::html_document(
      toc = TRUE,
      self_contained = FALSE,
      theme = NULL,
      template = path
    )
  )
}


# Articles index ----------------------------------------------------------

build_articles_index <- function(pkg = ".", path = NULL, depth = 1L) {
  render_page(
    pkg,
    "vignette-index",
    data = data_articles_index(pkg),
    path = out_path(path, "index.html"),
    depth = depth
  )
}

data_articles_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  contents <-
    tibble::tibble(
      path = pkg$vignettes$file_out,
      title = pkg$vignettes$title
    ) %>%
    purrr::transpose()

  list(
    sections = list(
      title = "All vignettes",
      desc = NULL,
      contents = contents
    )
  )
}

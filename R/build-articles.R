#' Build articles
#'
#' @param pkg Path to package source.
#' @param path Output path.
#' @param depth Depth of path relative to root of documentation.
#'   Used to adjust relative links in the navbar.
#' @export
build_articles <- function(pkg = ".", path, depth = 0L) {
  pkg <- as_staticdocs(pkg)
  if (nrow(pkg$vignettes) == 0) {
    return()
  }

  rule("Building articles")
  mkdir(path)

  tibble::tibble(
      path_in = file.path("vignettes", pkg$vignettes$file_in),
      path_out = file.path(path, pkg$vignettes$file_out)
    ) %>%
    purrr::pwalk(render_vignette, pkg = pkg, depth = depth)

  build_articles_index(pkg, path = path, depth = depth)
}

render_vignette <- function(path_in, path_out, pkg, depth = depth) {

  out <- rmarkdown::render(path_in,
    output_format = rmarkdown::html_fragment(
      toc = TRUE,
      self_contained = FALSE
    ),
    output_file = gsub("\\.Rmd$", "-bare.html", basename(path_in)),
    output_dir = "docs/articles",
    quiet = TRUE,
    envir = new.env(parent = globalenv())
  )
  on.exit(unlink(out), add = TRUE)

  data <- list(
    contents = paste(readLines(out), collapse = "\n")
  )
  render_page(pkg, "vignette", data, path_out, depth = depth)
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

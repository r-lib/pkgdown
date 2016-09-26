build_articles <- function(pkg = ".", path) {
  pkg <- as_staticdocs(pkg)
  if (nrow(pkg$vignettes) == 0) {
    return()
  }

  rule("Building articles")
  mkdir(path)

  pkg$vignettes %>%
    dplyr::transmute(
      path_in = file.path("vignettes", file_in),
      path_out = file.path(path, file_out)
    ) %>%
    purrr::pwalk(render_vignette, pkg = pkg)


  build_articles_index(pkg, path = path)
}

render_vignette <- function(path_in, path_out, pkg) {

  out <- rmarkdown::render(path_in,
    output_format = rmarkdown::html_fragment(
      toc = TRUE,
      self_contained = FALSE
    ),
    output_dir = "docs/articles",
    quiet = TRUE,
    envir = new.env(parent = globalenv())
  )

  data <- list(
    contents = paste(readLines(out), collapse = "\n")
  )

  render_page(pkg, "vignette", data, path_out)
}


# Articles index ----------------------------------------------------------

build_articles_index <- function(pkg = ".", path = NULL) {
  data <- data_articles_index(pkg)
  render_page(pkg, "vignette-index", data, out_path(path, "index.html"))
}

data_articles_index <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)

  contents <- pkg$vignettes %>%
    dplyr::select(path = file_out, title) %>%
    purrr::transpose()

  list(
    sections = list(
      title = "All vignettes",
      desc = NULL,
      contents = contents
    )
  )
}

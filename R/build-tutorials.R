#' Build tutorials
#'
#' learnr tutorials must hosted be hosted elsewhere as they require an
#' R execution engine. Currently, pkgdown will not build or publish tutorials
#' for you, but makes it easy to embed (using `<iframe>`s) published tutorials.
#' Tutorials are automatically discovered from published tutorials in
#' `inst/tutorials` and `vignettes/tutorials`. Alternatively, you can
#' list in `_pkgdown.yml` as described below.
#'
#' @section YAML config:
#' To override the default discovery process, you can provide a `tutorials`
#' section. This should be a list where each element specifies:
#'
#' * `name`: used for the generated file name
#' * `title`: used in page heading and in navbar
#' * `url`: which will be embedded in an iframe
#' * `source`: optional, but if present will be linked to
#'
#' ```
#' tutorials:
#' - name: 00-setup
#'   title: Setting up R
#'   url: https://jjallaire.shinyapps.io/learnr-tutorial-00-setup/
#' - name: 01-data-basics
#'   title: Data basics
#'   url: https://jjallaire.shinyapps.io/learnr-tutorial-01-data-basics/
#' ```
#' @inheritParams build_articles
#' @export
build_tutorials <- function(pkg = ".", override = list(), preview = NA) {
  pkg <- section_init(pkg, depth = 1L, override = override)
  tutorials <- pkg$tutorials

  if (nrow(tutorials) == 0) {
    return(invisible())
  }

  rule("Building tutorials")
  dir_create(path(pkg$dst_path, "tutorials"))

  data <- purrr::transpose(tutorials)

  # Build index
  render_page(pkg, "tutorial-index",
    data = list(
      pagetitle = "Tutorial index",
      tutorials = purrr::transpose(list(
        path = path_rel(tutorials$file_out, "tutorials"),
        title = tutorials$title
      ))
    ),
    path = "tutorials/index.html"
  )

  purrr::pwalk(
    list(data = data, path = tutorials$file_out),
    render_page,
    pkg = pkg,
    name = "tutorial"
  )

  preview_site(pkg, "tutorials", preview = preview)
}

package_tutorials <- function(path = ".", meta = list()) {
  # Look first in meta data
  tutorials <- purrr::pluck(meta, "tutorials")

  # Then scan tutorials directories
  if (length(tutorials) == 0) {
    tutorials <- c(
      find_tutorials(path(path, "inst", "tutorials")),
      find_tutorials(path(path, "vignettes", "tutorials"))
    )
  }

  name <- purrr::map_chr(tutorials, "name")
  title <- purrr::map_chr(tutorials, "title")

  tibble::tibble(
    name = name,
    file_out = path("tutorials", name, ext = "html"),
    title = title,
    pagetitle = title,
    url = purrr::map_chr(tutorials, "url")
  )
}

find_tutorials <- function(path = ".") {
  if (!dir_exists(path)) {
    return(character())
  }

  if (!requireNamespace("rsconnect", quietly = TRUE)) {
    stop("rsconnect package must be installed to scan for tutorials", call. = FALSE)
  }

  rmds <- unname(dir_ls(path, recursive = TRUE, regexp = "\\.[Rr]md$"))
  info <- purrr::map(rmds, tutorial_info, base_path = path)
  purrr::compact(info)
}

tutorial_info <- function(path, base_path) {
  meta <- rmarkdown::yaml_front_matter(path)
  title <- meta$title
  if (is.null(title)) {
    return()
  }

  # Must have "runtime: shiny". Partial implementation of full algorithm:
  # https://github.com/rstudio/rmarkdown/blob/master/R/shiny.R#L72-L100
  runtime <- meta$runtime
  if (is.null(runtime) || !grepl("^shiny", runtime)) {
    return()
  }

  # Must have deployment url
  deploys <- rsconnect::deployments(path)
  if (!is.null(deploys) && nrow(deploys) >= 1) {
    latest <- which.max(deploys$when)
    url <- deploys$url[[latest]]
  } else {
    return()
  }

  list(
    name = as.character(path_ext_remove(path_file(path))),
    title = meta$title,
    url = url
    # source = as.character(path_rel(path, base_path))
  )
}

#' Build home section
#'
#' This function generates the home page, converts `.md` files found in the
#' package root (and in `.github/`), and builds an authors page from
#' `DESCRIPTION` and `inst/CITATION` (if present).
#' @includeRmd man/rmd-fragments/home-configuration.Rmd
#' @inheritParams build_articles
#' @export
build_home <- function(pkg = ".",
                       override = list(),
                       preview = NA,
                       quiet = TRUE) {

  pkg <- section_init(pkg, depth = 0L, override = override)
  rule("Building home")
  dir_create(pkg$dst_path)

  if (has_citation(pkg$src_path)) {
    build_citation_authors(pkg)
  } else {
    build_authors(pkg)
  }
  build_home_md(pkg)
  build_home_license(pkg)
  build_home_index(pkg, quiet = quiet)

  preview_site(pkg, "/", preview = preview)
}

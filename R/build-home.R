#' Build home section
#'
#' @description
#' `build_home()` function generates pages at the top-level of the site
#' including:
#'
#' * The home page
#' * HTML files from any `.md` files in `./` or `.github/`.
#' * The authors page (from `DESCRIPTION`)
#' * The citation page (from `inst/CITATION`, if present).
#' * The license page
#'
#' `build_home_index()` rebuilds just the index page; it's useful for rapidly
#' iterating when experimenting with site styles.
#'
#' ```{r child="man/rmd-fragments/home-configuration.Rmd"}
#' ```
#' ```{r child="man/rmd-fragments/authors-configuration.Rmd"}
#' ```
#'
#' @section Sidebar:
#' ```{r child="man/rmd-fragments/sidebar-configuration.Rmd"}
#' ```
#'
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

#' Build complete static documentation for a package.
#'
#' \code{build_site} calls \code{\link{build_index}()},
#' \code{\link{build_home}()}, and \code{\link{build_reference}}. See
#' the invidual documentation for how the code works.
#'
#' @param pkg path to source version of package.  See
#'   \code{\link[devtools]{as.package}} for details on how paths and package
#'   names are resolved.
#' @param site_path root Directory in which to create documentation.
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param templates_path Path in which to look for templates. If this doesn't
#'   exist will look next in \code{pkg/inst/staticdocs/templates}, then
#'   in staticdocs itself.
#' @param assets_path Path in which to look for assets files. If
#'   this doesn't exist, will use \code{pkg/inst/staticdocs/assets},
#'   then files built into staticdocs.
#' @param mathjax Use mathjax to render math symbols?
#' @param seed Seed used to initialize so that random examples are
#'   reproducible.
#' @param launch If \code{TRUE}, will open freshly generated site in web
#'   browser.
#' @export
#' @import stringr
#' @importFrom devtools load_all
#' @aliases staticdocs-package build_package
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       site_path = "docs",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       templates_path = "inst/staticdocs/templates",
                       assets_path = "inst/staticdocs/assets",
                       mathjax = TRUE,
                       launch = interactive(),
                       seed = 1014
                       ) {

  set.seed(seed)

  options <- list(
    examples = examples,
    run_dont_run = run_dont_run,
    templates_path = templates_path,
    mathjax = mathjax
  )

  pkg <- as_staticdocs(pkg, options)
  mkdir(site_path)

  copy_assets(assets_path, site_path)
  # build_navbar(pkg)
  build_home(pkg, path = site_path)
  build_reference(pkg, path = file.path(site_path, "reference"))
  # build_vignettes(pkg)
  # build_news(pkg)

  if (launch) {
    rule("Launching site")
    servr::httd(site_path)
  }
  invisible(TRUE)
}

copy_assets <- function(user_assets, path) {
  if (file.exists(user_assets)) {
    assets <- user_assets
  } else {
    assets <- file.path(inst_path(), "assets")
  }
  file.copy(dir(assets, full.names = TRUE), path, recursive = TRUE)
}

#' @importFrom tools pkgVignettes buildVignettes
build_vignettes <- function(pkg = ".") {
  pkg <- as_staticdocs(pkg)
  vigns <- pkgVignettes(dir = pkg$path)

  if (length(vigns$docs) == 0) return()

  message("Building vignettes")
  # Locate source and built versions of vignettes
  buildVignettes(dir = pkg$path)
  vigns <- pkgVignettes(dir = pkg$path, output = TRUE)

  message("Copying vignettes")
  dest <- file.path(pkg$site_path, "vignettes")
  if (!file.exists(dest)) dir.create(dest)
  file.copy(vigns$outputs, dest, overwrite = TRUE)
  file.remove(vigns$outputs)

  # Extract titles
  titles <- vapply(vigns$docs, FUN.VALUE = character(1), function(x) {
    contents <- str_c(readLines(x), collapse = "\n")
    str_match(contents, "\\\\VignetteIndexEntry\\{(.*?)\\}")[2]
  })
  names <- basename(vigns$outputs)

  list(vignette = unname(Map(list, title = titles, filename = names)))
}

#' Build pkgdown website
#'
#' @description
#' `build_site()` is a convenient wrapper around five functions:
#'
#' * `init_site()`
#' * [build_articles()]
#' * [build_home()]
#' * [build_reference()]
#' * [build_news()]
#'
#' See the documentation for the each function to learn how to control
#' that aspect of the site.
#'
#' @section Custom CSS/JS:
#' If you want to do minor customisation of your pkgdown site, the easiest
#' way is to add `pkgdown/extra.css` and `pkgdown/extra.js`. These
#' will be automatically copied to `docs/` and inserted into the
#' `<HEAD>` after the default pkgdown CSS and JSS.
#'
#' @section YAML config:
#' There are four top-level YAML settings that affect the entire site:
#' `url`, `title`, `template`, and `navbar`.
#'
#' `url` optionally specifies the url where the site will be published.
#' If you supply this, other pkgdown sites will link to your site when needed,
#' rather than using generic links to \url{rdocumentation.org}.
#'
#' `title` overrides the default site title, which is the package name.
#' It's used in the page title and default navbar.
#'
#' You can also provided information to override the default display of
#' the authors. Provided a list named with the name of each author,
#' including `href` to add a link, or `html` to override the
#' text:
#'
#' \preformatted{
#' authors:
#'   Hadley Wickham:
#'     href: http://hadley.nz
#'   RStudio:
#'     href: https://www.rstudio.com
#'     html: <img src="http://tidyverse.org/rstudio-logo.svg" height="24" />
#' }
#'
#' @section YAML config - navbar:
#' `navbar` controls the navbar at the top of the page. It uses the same
#' syntax as \href{http://rmarkdown.rstudio.com/rmarkdown_websites.html#site_navigation}{RMarkdown}.
#' The following YAML snippet illustrates some of the most important features.
#'
#' \preformatted{
#' navbar:
#'   type: inverse
#'   left:
#'     - text: "Home"
#'       href: index.html
#'     - text: "Reference"
#'       href: reference/index.html
#'     - text: "Articles"
#'       menu:
#'         - text: "Heading 1"
#'         - text: "Article A"
#'           href: articles/page_a.html
#'         - text: "Article B"
#'           href: articles/page_b.html
#'         - text: "---------"
#'         - text: "Heading 2"
#'         - text: "Article C"
#'           href: articles/page_c.html
#'         - text: "Article D"
#'           href: articles/page_d.html
#'   right:
#'     - icon: fa-github fa-lg
#'       href: https://example.com
#' }
#'
#' Use `type` to choose between "default" and "inverse" themes.
#'
#' You position elements by placing under either `left` or `right`.
#' Components can contain sub-`menu`s with headings (indicated by missing
#' `href`) and separators. Currently pkgdown only supports fontawesome
#' icons. You can see a full list of options at
#' \url{http://fontawesome.io/icons/}.
#'
#' Any missing components (`type`, `left`, or `right`)
#' will be automatically filled in from the default navbar: you can see
#' those values by running [template_navbar()].
#'
#' @section YAML config - template:
#' You can get complete control over the appearance of the site using the
#' `template` component. There are two components to the template:
#' the HTML templates used to layout each page, and the css/js assets
#' used to render the page in the browser.
#'
#' The easiest way to tweak the default style is to use a bootswatch template,
#' by passing on the `bootswatch` template parameter to the built-in
#' template:
#'
#' \preformatted{
#' template:
#'   params:
#'     bootswatch: cerulean
#' }
#'
#' See a complete list of themes and preview how they look at
#' \url{https://gallery.shinyapps.io/117-shinythemes/}:
#'
#' Optionally provide the `ganalytics` template parameter to enable
#' \href{Google Analytics}{https://www.google.com/analytics/}. It should
#' correspond to your
#' \href{tracking id}{https://support.google.com/analytics/answer/1032385}.
#'
#' \preformatted{
#' template:
#'   params:
#'     ganalytics: UA-000000-01
#' }
#'
#' You can also override the default templates and provide additional
#' assets. You can do so by either storing in a `package` with
#' directories `inst/pkgdown/assets` and `inst/pkgdown/templates`,
#' or by supplying `path` and `asset_path`. To suppress inclusion
#' of the default assets, set `default_assets` to false.
#'
#' \preformatted{
#' template:
#'   package: mycustompackage
#'
#' # OR:
#'
#' template:
#'   path: path/to/templates
#'   assets: path/to/assets
#'   default_assets: false
#' }
#'
#' These settings are currently recommended for advanced users only. There
#' is little documentation, and you'll need to read the existing source
#' for pkgdown templates to ensure that you use the correct components.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param path Location in which to save website, relative to package
#'   path.
#' @param preview If `TRUE`, will preview freshly generated site
#' @export
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       path = "docs",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       mathjax = TRUE,
                       preview = interactive(),
                       seed = 1014,
                       encoding = "UTF-8"
                       ) {
  old <- set_pkgdown_env("true")
  on.exit(set_pkgdown_env(old))

  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  init_site(pkg, path)

  build_home(pkg, path = path, encoding = encoding)
  build_reference(pkg,
    lazy = FALSE,
    examples = examples,
    run_dont_run = run_dont_run,
    mathjax = mathjax,
    seed = seed,
    path = file.path(path, "reference"),
    depth = 1L
  )
  build_articles(pkg, path = file.path(path, "articles"), depth = 1L, encoding = encoding)
  build_news(pkg, path = file.path(path, "news"), depth = 1L)

  if (preview) {
    preview_site(path)
  }
  invisible(TRUE)
}

preview_site <- function(path) {
  utils::browseURL(file.path(path, "index.html"))
}

build_site_rstudio <- function() {
  devtools::document()
  callr::r(function() pkgdown::build_site(), show = TRUE)
  preview_site("docs/")
  invisible()
}

#' @export
#' @rdname build_site
init_site <- function(pkg = ".", path = "docs") {
  pkg <- as_pkgdown(pkg)
  path <- rel_path(path, pkg$path)

  rule("Initialising site")
  if (!file.exists(path)) {
    mkdir(path)
    usethis::use_build_ignore(path)
  }

  # Ignore pkgdown yaml file and directory (if used)
  path_yaml <- file.path(pkg$path, "_pkgdown.yml")
  if (file.exists(path_yaml)) {
    usethis::use_build_ignore("_pkgdown.yml")
  }
  path_dir <- file.path(pkg$path, "pkgdown")
  if (file.exists(path_dir)) {
    usethis::use_build_ignore("pkgdown")
  }

  extras <- dir(file.path(pkg$path, "pkgdown"), pattern = "^extra", full.names = TRUE)
  assets <- data_assets(pkg)

  # Generate site meta data file (avaiable to website viewers)
  path_meta <- file.path(path, "pkgdown.yml")
  if (!is.null(pkg$meta$url)) {
    meta <- list(
      urls = list(
        reference = paste0(pkg$meta$url, "/reference"),
        article = paste0(pkg$meta$url, "/articles")
      ),
      articles = as.list(pkg$article_index)
    )
    write_yaml(meta, path_meta)
  } else {
    unlink(path_meta)
  }


  for (asset in c(extras, assets)) {
    message("Copying '", asset, "'")
    file.copy(asset, path, recursive = TRUE)
  }

  build_logo(pkg, path = path)

  invisible()
}

data_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  template <- pkg$meta[["template"]]

  if (!is.null(template$assets)) {
    path <- rel_path(template$assets, base = pkg$path)
    if (!file.exists(path))
      stop("Can not find asset path '", path, "'", call. = FALSE)

  } else if (!is.null(template$package)) {
    path <- package_path(template$package, "assets")
  } else {
    path <- character()
  }

  if (!identical(template$default_assets, FALSE)) {
    path <- c(path, file.path(inst_path(), "assets"))
  }

  dir(path, full.names = TRUE)
}


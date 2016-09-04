#' Build complete static documentation for a package.
#'
#' Currently, \code{build_site} builds documentation for help topics,
#' vignettes, demos, and a \code{README.md}, if present.
#'
#' @section Home page:
#'
#' The home page is generated from \code{inst/staticdocs/README.md},
#' \code{README.md}, or the \code{DESCRIPTION} if neither readme file is
#' present. On the homepage, you should show how to install the package,
#' describe what it does, and provide an example of how to use it.
#'
#' @param pkg path to source version of package.  See
#'   \code{\link[devtools]{as.package}} for details on how paths and package
#'   names are resolved.
#' @param site_path root Directory in which to create documentation.
#' @param news_path Directory in which to create NEWS entries.
#' @param news_singlepage Should all NEWS be rendered in a single page?
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param templates_path Path in which to look for templates. If this doesn't
#'   exist will look next in \code{pkg/inst/staticdocs/templates}, then
#'   in staticdocs itself.
#' @param bootstrap_path Path in which to look for bootstrap files. If
#'   this doesn't exist, will use files built into staticdocs.
#' @param mathjax Use mathjax to render math symbols?
#' @param with_vignettes If \code{TRUE}, will build vignettes.
#' @param with_demos If \code{TRUE}, will build demos.
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
                       news_path = "docs/news",
                       news_singlepage = TRUE,
                       examples = TRUE,
                       run_dont_run = FALSE,
                       templates_path = "inst/staticdocs/templates",
                       bootstrap_path = "inst/staticdocs/bootstrap",
                       mathjax = TRUE,
                       with_vignettes = TRUE,
                       with_demos = TRUE,
                       launch = interactive(),
                       seed = 1014
                       ) {

  set.seed(seed)

  pkg <- as.sd_package(
    pkg,
    site_path = site_path,
    news_singlepage = news_singlepage,
    news_path = news_path,
    examples = examples,
    run_dont_run = run_dont_run,
    templates_path = templates_path,
    bootstrap_path = bootstrap_path,
    mathjax = mathjax
  )
  load_all(pkg)

  if (!file.exists(pkg$site_path)) {
    dir.create(pkg$site_path, recursive = TRUE)
  }
  if (!is.null(pkg$news_path) && !file.exists(pkg$news_path)) {
    dir.create(pkg$news_path, recursive = TRUE)
  }
  copy_bootstrap(pkg)


  pkg$topics <- build_topics(pkg)
  if (with_vignettes) pkg$vignettes <- build_vignettes(pkg)
  if (with_demos) pkg$demos <- build_demos(pkg)

  build_index(pkg)
  build_reference(pkg)
  build_news(pkg)

  if (launch) launch(pkg)
  invisible(TRUE)
}

launch <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  index <- normalizePath(file.path(pkg$site_path, "index.html"))
  utils::browseURL(index)
}

#' @export
build_package <- function(...) {
  warning("build_package is deprecated, please use build_site() instead",
    call. = FALSE)
  build_site(...)
}

# Generate all topic pages for a package.
build_topics <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  # for each file, find name of one topic
  index <- pkg$rd_index
  paths <- file.path(pkg$site_path, index$file_out)

  # create columns for extra topic info
  index$title <- ""
  index$in_index <- TRUE

  for (i in seq_along(index$name)) {
    message("Generating ", basename(paths[[i]]))

    rd <- pkg$rd[[i]]
    html <- to_html.Rd_doc(rd,
      env = new.env(parent = globalenv()),
      topic = str_replace(basename(paths[[i]]), "\\.html$", ""),
      pkg = pkg)
    html$pagetitle <- html$name

    html$package <- pkg[c("package", "version")]
    render_page(pkg, "topic", html, paths[[i]])
    grDevices::graphics.off()

    if ("internal" %in% html$keywords) {
      index$in_index[i] <- FALSE
    }
    index$title[i] <- html$title
  }

  index
}

copy_bootstrap <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)
  user_bootstrap <- pkg$bootstrap_path
  if (file.exists(user_bootstrap)) {
    bootstrap <- user_bootstrap
  } else {
    bootstrap <- file.path(inst_path(), "bootstrap")
  }
  file.copy(dir(bootstrap, full.names = TRUE), pkg$site_path, recursive = TRUE)
}

#' @importFrom tools pkgVignettes buildVignettes
build_vignettes <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)
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

build_demos <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  demo_dir <- file.path(pkg$path, "demo")
  if (!file.exists(demo_dir)) return()

  message("Rendering demos")
  demos <- readLines(file.path(demo_dir, "00Index"))
  demos <- demos[demos != ""]

  pieces <- str_split_fixed(demos, "\\s+", 2)
  in_path <- str_c(pieces[, 1], ".[rR]")
  filename <- str_c("demo-", pieces[,1], ".html")
  title <- pieces[, 2]

  for (i in seq_along(title)) {
    demo_code <- readLines(Sys.glob(file.path(demo_dir, in_path[i])))
    demo_expr <- evaluate(demo_code, new.env(parent = globalenv()),
      new_device = FALSE)

    pkg$demo <- replay_html(demo_expr, pkg = pkg, name = str_c(pieces[i], "-"))
    pkg$pagetitle <- title[i]
    render_page(pkg, "demo", pkg,
      file.path(pkg$site_path, filename[i]))
  }

  list(demo = unname(apply(cbind(filename, title), 1, as.list)))
}

#' Build complete static documentation for a package.
#'
#' Currently, build_site builds documentation for:
#' \itemize{
#'   \item The package DESCRIPTION
#'   \item Help topics
#'   \item Vignettes
#'   \item Demos. Must be listed in \file{demos/00index}
#'   \item README.md files
#' }
#'
#' @param pkg path to source version of package.  See
#'   \code{\link[devtools]{as.package}} for details on how paths and package
#'   names are resolved.
#' @param ... Other additional arguments passed to \code{\link{as.sd_package}}
#'   used to override package defaults.
#' @param launch If \code{TRUE}, will open freshly generated site in web
#'   browser.
#' @export
#' @import stringr
#' @importFrom devtools load_all
#' @aliases staticdocs-package build_package
build_site <- function(pkg = ".", ..., launch = interactive()) {
  pkg <- as.sd_package(pkg, ...)
  load_all(pkg)

  if (!file.exists(pkg$site_path)) {
    dir.create(pkg$site_path, recursive = TRUE)
  }
  copy_bootstrap(pkg)

  pkg$topics <- build_topics(pkg)
  pkg$vignettes <- build_vignettes(pkg)
  pkg$demos <- build_demos(pkg)
  pkg$readme <- readme(pkg)
  build_index(pkg)

  if (launch) launch(pkg)
  invisible(TRUE)
}

launch <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  index <- normalizePath(file.path(pkg$site_path, "index.html"))
  browseURL(index)
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
    html <- to_html(rd,
      env = new.env(parent = globalenv()),
      topic = str_replace(basename(paths[[i]]), "\\.html$", ""),
      pkg = pkg)
    html$pagetitle <- html$name

    html$package <- pkg[c("package", "version")]

    if (!is.null(pkg$ganalytics))
      html$ganalytics <- pkg$ganalytics

    render_page(pkg, "topic", html, paths[[i]])
    graphics.off()

    if ("internal" %in% html$keywords) {
      index$in_index[i] <- FALSE
    }
    index$title[i] <- html$title
  }

  index
}

readme <- function(pkg = ".") {
  pkg <- as.sd_package(pkg)

  # First look in staticdocs path
  path <- file.path(pkg$sd_path, "README.md")
  if (file.exists(path)) {
    return(markdown(path = path))
  }

  # Then look in the package root
  path <- file.path(pkg$path, "README.md")
  if (file.exists(path)) {
    return(markdown(path = path))
  }

  # Otherwise fallback to description
  pkg$description
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

  pieces <- str_split_fixed(demos, "\\s+", 2)
  in_path <- str_c(pieces[, 1], ".r")
  filename <- str_c("demo-", pieces[,1], ".html")
  title <- pieces[, 2]

  for(i in seq_along(title)) {
    demo_code <- readLines(file.path(demo_dir, in_path[i]))
    demo_expr <- evaluate(demo_code, new.env(parent = globalenv()),
      new_device = FALSE)

    pkg$demo <- replay_html(demo_expr, pkg = pkg, name = str_c(pieces[i], "-"))
    pkg$pagetitle <- title[i]
    render_page(pkg, "demo", pkg,
      file.path(pkg$site_path, filename[i]))
  }

  list(demo = unname(apply(cbind(filename, title), 1, as.list)))
}

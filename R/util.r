#' @importFrom devtools dev_meta
inst_path <- function() {
  if (is.null(dev_meta("staticdocs"))) {
    # staticdocs is probably installed
    system.file(package = "staticdocs")
  } else {
    # staticdocs was probably loaded with devtools
    file.path(getNamespaceInfo("staticdocs", "path"), "inst")
  }
}

# Return the staticdocs path for a package
# Could be in pkgdir/inst/staticdocs/ (for non-installed source packages)
# or in pkgdir/staticdocs/ (for installed packages)
pkg_sd_path <- function(package) {
  if (!is.null(package$sd_path)) {
    return(package$sd_path)
  }

  pathsrc <- file.path(package$path, "inst", "staticdocs")
  pathinst <- file.path(package$path, "staticdocs")

  if (dir.exists(pathsrc)) {
    pathsrc
  } else if (dir.exists(pathinst)) {
    pathinst
  } else {
    dir.create(pathsrc, recursive = TRUE)
    pathsrc
  }
}

file.path.ci <- function(...) {
  default <- file.path(...)
  if (file.exists(default)) return(default)

  dir <- dirname(default)
  if (!file.exists(dir)) return(default)

  pattern <- utils::glob2rx(basename(default)) # Not perfect, but safer than raw name
  matches <- list.files(dir, pattern, ignore.case = TRUE,
                        full.names = TRUE, include.dirs = TRUE, all.files = TRUE)
  if (length(matches) == 0) return(default)

  matches[[1]]
}


"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

rows_list <- function(df) {
  lapply(seq_len(nrow(df)), function(i) as.list(df[i, ]))
}

#' @importFrom markdown markdownToHTML
markdown <- function(x = NULL, path = NULL) {
  if (is.null(path)) {
    if (is.null(x) || x == "") return("")
  }

  (markdownToHTML(text = x, file = path, fragment.only = TRUE,
                  options = c("safelink", "use_xhtml", "smartypants")))
}

# Given the name or vector of names, returns a named vector reporting
# whether each exists and is a directory.
dir.exists <- function(x) {
  res <- file.exists(x) & file.info(x)$isdir
  stats::setNames(res, x)
}

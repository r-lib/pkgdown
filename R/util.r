#' @importFrom magrittr %>%
NULL

inst_path <- function() {
  if (is.null(devtools::dev_meta("staticdocs"))) {
    # staticdocs is probably installed
    system.file(package = "staticdocs")
  } else {
    # staticdocs was probably loaded with devtools
    file.path(getNamespaceInfo("staticdocs", "path"), "inst")
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

markdown <- function(x = NULL, path = NULL) {
  if (is.null(path)) {
    if (is.null(x) || x == "") return("")
  }

  (markdown::markdownToHTML(text = x, file = path, fragment.only = TRUE,
                  options = c("safelink", "use_xhtml", "smartypants")))
}

# Given the name or vector of names, returns a named vector reporting
# whether each exists and is a directory.
dir.exists <- function(x) {
  res <- file.exists(x) & file.info(x)$isdir
  stats::setNames(res, x)
}


set_contains <- function(haystack, needles) {
  all(needles %in% haystack)
}

compact <- function (x) Filter(function(x) !is.null(x) & length(x), x)

mkdir <- function(..., quiet = FALSE) {
  path <- file.path(...)

  if (!file.exists(path)) {
    if (!quiet)
      message("Creating '", path, "/'")
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
}

rule <- function(..., pad = "-") {
  if (nargs() == 0) {
    title <- ""
  } else {
    title <- paste0(..., " ")
  }
  width <- max(getOption("width") - nchar(title) - 1, 0)
  message(title, paste(rep(pad, width, collapse = "")))
}

out_path <- function(path, ...) {
  if (is.null(path)) {
    ""
  } else {
    file.path(path, ...)
  }

}

is_dir <- function(x) file.info(x)$isdir

split_at_linebreaks <- function(text) {
  if (length(text) < 1)
    return(character())
  trimws(strsplit(text, "\\n\\s*\\n")[[1]])
}

up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

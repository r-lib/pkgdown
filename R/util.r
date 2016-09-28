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

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}


markdown <- function(path = NULL, ...) {
  tmp <- tempfile(fileext = ".html")
  on.exit(unlink(tmp), add = TRUE)

  rmarkdown::pandoc_convert(
    input = path,
    output = tmp,
    from = "markdown_github",
    to = "html5",
    options = list(
      "--smart",
      "--indented-code-classes=R",
      ...
    )
  )

  paste(readLines(tmp), collapse = "\n")
}

set_contains <- function(haystack, needles) {
  all(needles %in% haystack)
}

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

print_yaml <- function(x) {
  structure(x, class = "print_yaml")
}
#' @export
print.print_yaml <- function(x, ...) {
  cat(yaml::as.yaml(x), "\n", sep = "")
}

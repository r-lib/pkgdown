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

markdown_text <- function(text, ...) {
  if (is.null(text))
    return(text)

  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  writeLines(text, tmp)
  markdown(tmp, ...)
}

markdown <- function(path = NULL, ..., depth = 0L, index = NULL) {
  tmp <- tempfile(fileext = ".html")
  on.exit(unlink(tmp), add = TRUE)

  rmarkdown::pandoc_convert(
    input = path,
    output = tmp,
    from = "markdown_github-hard_line_breaks",
    to = "html",
    options = list(
      "--smart",
      "--indented-code-classes=R",
      ...
    )
  )

  xml <- xml2::read_html(tmp, encoding = "UTF-8")
  autolink_html(xml, depth = depth, index = index)

  # Extract body of html - as.character renders as xml which adds
  # significant whitespace in tags like pre
  xml %>%
    xml2::xml_find_first(".//body") %>%
    xml2::write_html(tmp)

  lines <- readLines(tmp, warn = FALSE)
  lines <- sub("<body>", "", lines, fixed = TRUE)
  lines <- sub("</body>", "", lines, fixed = TRUE)
  paste(lines, collapse = "\n")
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

#' Generate reference index and topics.
#'
#' @param path Path in which to save files
#' @export
build_reference <- function(pkg = ".", path = NULL) {
  rule("Building function reference")
  if (!is.null(path)) {
    mkdir(path)
  }

  pkg$topics %>%
    purrr::transpose() %>%
    purrr::map(build_reference_topic, pkg = pkg, path)

  build_reference_index(pkg, path = path)

  invisible()
}

build_reference_topic <- function(topic, pkg, path = NULL) {
  data <- data_reference_topic(topic, pkg, path)
  render_page(pkg, "reference-topic", data, out_path(path, topic$file_out))

  invisible()
}

data_reference_topic <- function(topic, pkg, path = NULL) {
  tag_names <- purrr::map_chr(topic$rd, tag)
  tags <- split(topic$rd, tag_names)

  out <- list()

  # Single top-level converted to string
  out$name <- to_html(tags$name[[1]])
  out$title <- to_html(tags$title[[1]])
  out$author <- to_html(tags$author[[1]])

  # Multiple top-level converted to string
  out$aliases <- purrr::map_chr(tags$alias, to_html)
  out$keywords <- purrr::map_chr(tags$keyword %||% list(), to_html)

  # Sections that contain arbitrary text and need cross-referencing
  out$seealso <- to_html(tags$seealso[[1]], pkg = pkg)
  out$usage <- to_html(tags$usage[[1]], pkg = pkg)
  out$arguments <- to_html(tags$arguments[[1]], pkg = pkg)
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }

  # Examples
  # TODO: setwd()
  env <- new.env(parent = globalenv())
  out$examples <- to_html(tags$examples[[1]], env = env, pkg = pkg)

  # Everything else stays in original order, and becomes a list of sections.
  sections <- topic$rd[!(tag_names %in% c("name", "title", "alias", "keyword",
    "usage", "author", "seealso", "arguments", "examples", "TEXT", "COMMENT"))]
  out$sections <- compact(to_html(sections, pkg = pkg))

  out$pagetitle <- out$name
  out$package <- pkg[c("package", "version")]
  out
}

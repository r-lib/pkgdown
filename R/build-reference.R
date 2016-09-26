#' Generate reference index and topics.
#'
#' @param path Path in which to save files
#' @export
build_reference <- function(pkg = ".", path = NULL) {
  rule("Building function reference")
  pkg <- as.sd_package(pkg)
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
  html <- spec_reference_topic(
    topic$rd,
    env = new.env(parent = globalenv()),
    topic = topic$name,
    pkg = pkg
  )
  html$package <- pkg[c("package", "version")]

  if (is.null(path)) {
    out <- ""
  } else {
    out <- file.path(path, topic$file_out)
  }
  render_page(pkg, "topic", html, out)
}

spec_reference_topic <- function(x, ...) {
  tags <- vapply(x, tag, FUN.VALUE = character(1))
  get_tags <- function(tag) x[tags == tag]
  get_tag <- function(tag) {
    if (tag %in% tags) {
      x[[which(tags == tag)]]
    }
  }

  # Remove line breaks between sections
  line_breaks <- tags == "TEXT"
  x <- x[!line_breaks]
  tags <- tags[!line_breaks]

  out <- list()

  # Capture name, title and aliasess
  out$name <- to_html(get_tag("name"), ...)
  out$title <- to_html(get_tag("title"), ...)
  out$aliases <- vapply(get_tags("alias"), to_html, character(1), ...)
  out$keywords <- vapply(get_tags("keyword"), to_html, character(1), ...)

  out$usage <- to_html(get_tag("usage"), ...)
  out$arguments <- to_html(get_tag("arguments"), ...)
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }
  out$author <- to_html(get_tag("author"), ...)

  out$seealso <- to_html(get_tag("seealso"), ...)
  out$examples <- to_html(get_tag("examples"), ...)

  # Everything else stays in original order, and becomes a list of sections.
  sections <- x[!(tags %in% c("name", "title", "alias", "keyword",
    "usage", "author", "seealso", "arguments", "examples"))]
  out$sections <- compact(to_html(sections, topic = out$name, ...))

  out$pagetitle <- out$name

  out
}

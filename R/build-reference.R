#' Build reference section
#'
#' By default, pkgdown will generate an index that simply lists all
#' the functions in alphabetical order. To override this, provide a
#' \code{reference} section in your \code{_pkgdown.yml} as described
#' below.
#'
#' @section YAML config:
#' To tweak the index page, you need a section called \code{reference}
#' which provides a list of sections containing, a \code{title}, list of
#' \code{contents}, and optional \code{description}.
#'
#' For example, the following code breaks up the functions in pkgdown
#' into two groups:
#'
#' \preformatted{
#' reference:
#' - title: Render components
#'   desc:  Build each component of the site.
#'   contents:
#'   - starts_with("build_")
#'   - init_site
#' - title: Templates
#'   contents:
#'   - render_page
#' }
#'
#' Note that \code{contents} can contain either a list of function names,
#' or if the functions in a section share a common prefix or suffix, you
#' can use \code{starts_with("prefix")} and \code{ends_with("suffix")} to
#' select them all. For more complex naming schemes you can use an aribrary
#' regular expression with \code{matches("regexp")}.
#'
#' pkgdown will check that all non-internal topics are included on
#' this page, and will generate a warning if you have missed any.
#'
#' @inheritParams build_articles
#' @param run_dont_run Run examples that are surrounded in \\dontrun?
#' @param examples Run examples?
#' @param mathjax Use mathjax to render math symbols?
#' @param seed Seed used to initialize so that random examples are
#'   reproducible.
#' @export
build_reference <- function(pkg = ".",
                            examples = TRUE,
                            run_dont_run = FALSE,
                            mathjax = TRUE,
                            seed = 1014,
                            path = "docs/reference",
                            depth = 1L
                            ) {
  pkg <- as_pkgdown(pkg)

  rule("Building function reference")
  if (!is.null(path)) {
    mkdir(path)
  }

  if (examples) {
    devtools::load_all(pkg$path)
    set.seed(seed)
  }

  pkg$topics %>%
    purrr::transpose() %>%
    purrr::map(build_reference_topic, path,
      pkg = pkg,
      depth = depth,
      examples = examples,
      run_dont_run = run_dont_run,
      mathjax = mathjax
    )

  build_reference_index(pkg, path = path, depth = depth)

  invisible()
}

build_reference_topic <- function(topic,
                                  pkg,
                                  examples = TRUE,
                                  run_dont_run = FALSE,
                                  mathjax = TRUE,
                                  path = NULL,
                                  depth = 1L
                                  ) {
  render_page(
    pkg, "reference-topic",
    data = data_reference_topic(
      topic,
      pkg,
      path = path,
      examples = examples,
      run_dont_run = run_dont_run,
      mathjax = mathjax
    ),
    path = out_path(path, topic$file_out),
    depth = depth
  )
  invisible()
}


# Convert Rd to list ------------------------------------------------------

data_reference_topic <- function(topic,
                                 pkg,
                                 examples = TRUE,
                                 run_dont_run = FALSE,
                                 mathjax = TRUE,
                                 path = NULL
                                 ) {

  tag_names <- purrr::map_chr(topic$rd, ~ class(.)[[1]])
  tags <- split(topic$rd, tag_names)

  out <- list()

  # Single top-level converted to string
  out$name <- as_html(tags$tag_name[[1]][[1]])
  out$title <- as_html(tags$tag_title[[1]][[1]])

  out$pagetitle <- out$name

  # Multiple top-level converted to string
  out$aliases <- purrr::map_chr(tags$tag_alias %||% list(), flatten_text)
  out$author <- purrr::map_chr(tags$tag_author %||% list(), flatten_text)
  out$keywords <- purrr::map_chr(tags$tag_keyword %||% list(), flatten_text)

  # Sections that contain arbitrary text and need cross-referencing
  out$description <- as_data(
    tags$tag_description[[1]],
    index = pkg$topics,
    current = topic$name
  )

  out$usage <- as_data(
    tags$tag_usage[[1]],
    index = pkg$topics,
    current = topic$name
  )

  out$arguments <- as_data(
    tags$tag_arguments[[1]],
    index = pkg$topics,
    current = topic$name
  )
  if (length(out$arguments)) {
    out$has_args <- TRUE # Work around mustache deficiency
  }

  out$examples <- as_data(
    tags$tag_examples[[1]],
    env = new.env(parent = globalenv()),
    index = pkg$topics,
    current = topic$name,
    path = path
  )

  # Everything else stays in original order, and becomes a list of sections.
  section_tags <- c(
    "tag_details", "tag_references", "tag_source", "tag_format",
    "tag_note", "tag_seealso", "tag_section", "tag_value"
  )
  sections <- topic$rd[tag_names %in% section_tags]
  out$sections <- sections %>%
    purrr::map(as_data, index = pkg$topics, current = topic$name)

  out
}


